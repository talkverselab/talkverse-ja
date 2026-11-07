#!/usr/bin/env python3
"""새 회화(편 JSON) 검사기 — 설계 docs/DIALOGUE_DESIGN_JA.md §3 (2026-11-02).

  python tools/check_dialogues.py [--fix-rd] [assets/data/dialogues/R1/**.json ...]

검사 항목: 턴 수(구간·종류) · 턴 길이(단어 수·독음 음절) · 새 단어/턴 · 앞 편 단어 재사용 · 구간 어휘 · 표현 풀 노출 ·
반전 1회 · 메타 턴 ≤1 · rd(한글 독음) 규칙 · 금지어 · 변수 · 채팅 편 규칙. 오류가 있으면 종료 코드 1.
janome 필요(pip install janome). 실행은 저장소 루트에서.
"""
import csv
import glob
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import rd_ja  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
EXPR_CSV = ROOT / 'data/expressions/top_expressions.csv'
REGION_CSV = ROOT / 'data/corpus/lang_ja_with_regions.csv'
FORBIDDEN = ROOT / 'data/expressions/forbidden.txt'  # 출처·작품명 등, 한 줄 하나(없으면 생략)
REGION_ORDER = ['R1', 'R2', 'R3', 'R4']
ALIAS = {'R0': 'R1'}  # 왕초보(R0) = 옛 짧은 R1 편 그대로, 규칙은 R1
TURNS = {'R1': {'survival': (6, 8), 'short': (6, 8), 'long': (6, 8), 'chat': (6, 8)}, 'R2': (8, 12), 'R3': (12, 16), 'R4': (12, 16)}
WORDS = {('R1', 'short'): (2, 9), ('R1', 'survival'): (2, 9), ('R1', 'long'): (1, 10), ('R1', 'chat'): (1, 7), ('R2', None): (1, 12)}
NEW_PER_TURN = {'R1': 3, 'R2': 4}
RD_OK = re.compile(r'^[가-힣0-9A-Za-z ,.!?…"·~\-{}_()（）×=→#○△]*$')
VARS = {'{name}', '{country}', '{city}', '{lang}', '{anime}', '{photo_word}', '{name_jp}', '{hotel}', '{drama}', '{anime_line}', '{mondegreen}', '{station}', '{city_jp}', '{food}', '{name_meaning}', '{love_word}', '{idol}', '{band_song}', '{idol_song}', '{company}', '{greeting_wrong}', '{age}', '{lang_slowly}', '{lang_no_thanks}'}
SKIP_POS = {'助詞', '助動詞', '記号', '接頭詞', 'フィラー'}
SKIP_SURF = {'てる', 'でる', 'とく', 'どく', 'ちゃう', 'じゃう', 'てく', 'でく', 'する', 'いる', 'ある', 'なる'}  # 보조 동사·경동사
LEMMA_FIX = {('行っ', '行う'): '行く', ('行か', '行う'): '行く'}  # janome 오분석 보정
CHAT_SCENES = {'채팅'}


def load_expr():
    rows = list(csv.DictReader(open(EXPR_CSV, encoding='utf-8')))
    return rows


def load_region_vocab():
    vocab = defaultdict(set)
    for r in csv.DictReader(open(REGION_CSV, encoding='utf-8-sig')):
        vocab[{'R5': 'R4'}.get(r['region'], r['region'])].add(r['word'])  # 절벽 v2 절대 기준: 80% 밖(R5)은 R4 회화 어휘로
    cum = {}
    acc = set()
    for reg in REGION_ORDER:
        acc |= vocab.get(reg, set())
        cum[reg] = set(acc)
    return cum


def lemmas(text, with_reading=False):
    """내용어 기본형 목록(조사·조동사·보조동사·기호·변수 제외). with_reading 이면 (기본형, 히라가나 읽기) 쌍."""
    text = re.sub(r'\{[a-z_]+\}', ' ', text)
    out = []
    for t in rd_ja._tokenizer().tokenize(text):
        feats = t.part_of_speech.split(',')
        pos, pos2 = feats[0], feats[1] if len(feats) > 1 else ''
        if pos in SKIP_POS or pos2 == '非自立' or re.fullmatch(r'[A-Za-z0-9]+', t.surface):  # 영문·숫자 토큰은 새 단어로 안 셈
            continue
        base = t.base_form if t.base_form != '*' else t.surface
        base = LEMMA_FIX.get((t.surface, base), base)
        if base in SKIP_SURF or t.surface in SKIP_SURF:
            continue
        rd = ''.join(chr(ord(c) - 0x60) if 'ァ' <= c <= 'ヶ' else c for c in (t.reading if t.reading != '*' else t.surface))
        out.append((base, rd) if with_reading else base)
    return out


def in_vocab(pair, vocab):
    base, rd = pair
    return base in vocab or rd in vocab


def word_count(text, exprs=()):
    text = re.sub(r'\{[a-z_]+\}', 'X', text)
    for e in sorted(exprs, key=len, reverse=True):  # 표현 풀 한 덩이 = 단어 1개
        e = e.replace('〜', '')
        if e and e in text:
            text = text.replace(e, ' X ', 1)
    return sum(1 for t in rd_ja._tokenizer().tokenize(text) if t.part_of_speech.split(',')[0] not in ('記号', '助詞', '助動詞'))


def check_file(path, exprs, cum_vocab, island_seen, fix_rd, forbidden):
    errs, warns = [], []
    ep = json.load(open(path, encoding='utf-8'))
    eid = ep.get('id', path.name)
    region, kind = ALIAS.get(ep.get('region', 'R1'), ep.get('region', 'R1')), ep.get('kind', 'long')
    if kind == 'custom':  # 맞춤 회화(docs/CUSTOM_SCRIPT_API.md) — 규칙은 그 레벨의 long 편과 같게
        kind = 'long'
    turns = ep.get('turns', [])
    E = lambda m: errs.append(f'{eid}: {m}')
    W = lambda m: warns.append(f'{eid}: {m}')

    # 턴 수
    rng = TURNS[region][kind] if isinstance(TURNS[region], dict) else TURNS[region]
    if not rng[0] <= len(turns) <= rng[1]:
        E(f'턴 수 {len(turns)} (허용 {rng[0]}~{rng[1]})')
    # 메타
    for k in ('purpose', 'domain', 'island', 'scene', 'title', 'speakers', 'register'):
        if not ep.get(k):
            E(f'메타 {k} 없음')
    if not isinstance(ep.get('twist'), int) or not (1 <= ep.get('twist', 0) <= max(len(turns), 1)):
        E('twist(반전 턴 번호) 없음/범위 밖')
    for f in ep.get('flags', []):
        if f not in ('alcohol', 'profanity_mild', 'jealousy', 'haggle', 'romance'):
            W(f'flags 값 확인: {f}')

    expr_map = {r['expr']: r for r in exprs}
    expr_lemmas = set()
    for e in expr_map:
        expr_lemmas.update(lemmas(e.replace('〜', '')))
    names = {v for v in ep.get('speakers', {}).values() if not v.startswith('{')}
    expr_hits = Counter()
    meta_turns = 0
    new_total = Counter()
    seen_words = island_seen.setdefault(ep.get('island', ''), set())
    reuse_hits = 0
    wrng = WORDS.get((region, kind)) or WORDS.get((region, None))
    for t in turns:
        n = t.get('num')
        ja = t.get('ja', '')
        if not ja:
            E(f'턴 {n}: ja 없음'); continue
        if t.get('speaker') not in ('A', 'B', 'C', 'D'):
            E(f'턴 {n}: speaker')
        for k in ('kana', 'ko'):
            if not t.get(k):
                E(f'턴 {n}: {k} 없음')
        # 변수
        for v in re.findall(r'\{[a-z_]+\}', ja + t.get('ko', '')):
            if v not in VARS:
                E(f'턴 {n}: 모르는 변수 {v}')
        # 길이
        wc = word_count(ja, expr_map)
        is_expr_only = any(re.fullmatch(re.escape(e.replace('〜', '')) + r'[！!？?。…]*', ja.strip('…。 ')) for e in expr_map)
        if wrng and wc > wrng[1]:
            E(f'턴 {n}: 단어 수 {wc} > {wrng[1]} — {ja}')
        elif wrng and wc < wrng[0] and not (is_expr_only or n == ep.get('twist') or n == len(turns) or wc == 0 or re.fullmatch(r'\{[a-z_]+\}[！!？?。…]*', ja)):
            W(f'턴 {n}: 단어 수 {wc} < {wrng[0]} — {ja}')  # 짧은 반응·침묵(…)·표현 한마디·반전·펀치라인은 허용, 그 외는 경고
        # rd
        rd = t.get('rd')
        auto = rd_ja.to_rd(ja)
        if not rd:
            if fix_rd:
                t['rd'] = auto; W(f'턴 {n}: rd 채움 → {auto}')
            else:
                E(f'턴 {n}: rd 없음 (자동: {auto})')
        else:
            if not RD_OK.match(rd):
                E(f'턴 {n}: rd 에 허용 밖 글자 — {rd}')
            if not t.get('rd_manual') and rd != auto:
                W(f'턴 {n}: rd 가 변환기와 다름 (rd={rd} / 자동={auto}) — 맞으면 rd_manual: true')
            if len(re.sub(r'[^가-힣]', '', rd)) > 20 and region == 'R1' and kind != 'chat':
                W(f'턴 {n}: 독음 {len(re.sub(r"[^가-힣]", "", rd))}음절 > 20')
        # 표현 풀·메타
        rest = ja.replace('？', '?').replace('！', '!')
        for e in sorted(expr_map, key=len, reverse=True):  # 긴 표현 먼저, 맞은 자리는 지워 짧은 표현이 겹쳐 세이지 않게
            ee = e.replace('〜', '').replace('？', '?').replace('！', '!')
            if not ee:
                continue
            kana = r'[ぁ-んァ-ン]'
            pre = r'(?<!' + kana + ')' if re.match(kana, ee) else ''   # 가나로 시작하면 앞 경계
            post = r'(?!' + kana + ')' if re.search(kana + '$', ee) else ''  # 가나로 끝나면 뒤 경계(?·w 로 끝나면 없음)
            pat = pre + re.escape(ee) + post
            if re.search(pat, rest):
                expr_hits[e] += 1
                rest = re.sub(pat, ' ', rest, count=1)
                if expr_map[e].get('scene') == '메타':
                    meta_turns += 1
        # 새 단어·재사용
        pairs = [pr for pr in lemmas(ja, with_reading=True) if pr[0] not in expr_lemmas and pr[0] not in names]
        lm = [pr[0] for pr in pairs]
        new = [pr[0] for pr in pairs if pr[0] not in seen_words and not in_vocab(pr, cum_vocab.get(region, set()))]
        declared = set(t.get('new', []))
        norm = lambda w: re.sub(r'^お', '', w)
        if declared:
            undeclared = [w for w in set(new) if norm(w) not in {norm(x) for x in declared} and not any(norm(w) in norm(x) or norm(x) in norm(w) for x in declared)]
            if undeclared:
                W(f'턴 {n}: new 에 없는 새 단어 {undeclared}')
            count = len(declared)
        else:
            count = len(set(new))
        if region in NEW_PER_TURN and count > NEW_PER_TURN[region]:
            E(f'턴 {n}: 새 단어 {count}개 > {NEW_PER_TURN[region]} — {sorted(declared or set(new))}')
        if any(w in seen_words for w in lm):
            reuse_hits += 1
        for w in new:
            new_total[w] += 1
        seen_words.update(lm)  # 같은 편 앞 턴의 단어는 다음 턴에서 새 단어가 아님
        # 금지어
        for bad in forbidden:
            if bad and bad in ja + t.get('ko', '') + t.get('note', ''):
                E(f'턴 {n}: 금지어 "{bad}"')
    # 음성용 감정 열(2026-11-07 사용자 지시) — 감정 계획 파일이 따로 없는 편은 소리 낼 글이 있는 턴마다 emotion 또는 segs 가 있어야 한다
    if not (ROOT / f'data/tts/plan/{eid}.json').exists():
        emos = {'emotion': 0, 'neutral': 0}
        for t in turns:
            if not re.sub(r'[\s　…。、！？!?.・〜~♪]', '', t.get('ja', '')):
                continue
            segs = t.get('segs') or ([[t['emotion'], t['ja']]] if t.get('emotion') else None)
            if not segs:
                E(f"턴 {t.get('num')}: 음성 감정(emotion/segs) 없음 — data/tts/PLAN_GUIDE.md 16감정")
                continue
            emos['emotion'] += 1
            emos['neutral'] += all(s[0] == 'neutral' for s in segs)
            if t.get('segs') and re.sub(r'[\s　…]|（[^）]*）|\([^)]*\)', '', ''.join(s[1] for s in segs)) != re.sub(r'[\s　…]|（[^）]*）|\([^)]*\)', '', t['ja']):
                E(f"턴 {t.get('num')}: segs 를 이어 붙인 글이 ja 와 다름")
        if emos['emotion'] and emos['neutral'] > emos['emotion'] / 2:
            W(f"neutral 턴 {emos['neutral']}/{emos['emotion']} — 밋밋함, 대사 맥락대로 감정을 고를 것")
    # 편 단위
    if sum(expr_hits.values()) < 2:
        E(f'표현 풀 노출 {sum(expr_hits.values())}회 < 2')
    for e, c in expr_hits.items():
        if c > 2:
            W(f'표현 "{e}" {c}회 > 2')
    if kind == 'chat' and not any(expr_map[e].get('scene') == '채팅' or expr_map[e].get('register') == '채팅' for e in expr_hits):
        E('채팅 편인데 채팅 표현(scene 또는 register 채팅) 없음')
    if meta_turns > 1 and kind != 'survival':
        W(f'메타 표현 턴 {meta_turns} > 1')
    if region == 'R1' and kind != 'survival' and turns and reuse_hits < len(turns) / 2 and seen_words:
        W(f'앞 편 단어 재사용 턴 {reuse_hits}/{len(turns)} < 절반')  # 통계용 경고(장면이 바뀌면 절반 재사용은 비현실적 — 2026-11-03)
    outside = list(new_total)
    if region == 'R1' and len(outside) > 1 + sum(len(t.get('new', [])) for t in turns):
        W(f'구간 밖 새 단어 {len(outside)}: {outside[:8]}')
    # 섬 누적 어휘 갱신
    for t in turns:
        seen_words.update(lemmas(t.get('ja', '')))
    if fix_rd:
        json.dump(ep, open(path, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    return errs, warns


def main():
    a = sys.argv[1:]
    fix = '--fix-rd' in a
    files = [Path(p).resolve() for p in a if not p.startswith('--')]
    if not files:
        files = [Path(p).resolve() for p in sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/**/*.json'), recursive=True))]
    exprs = load_expr()
    cum = load_region_vocab()
    forbidden = [l.strip() for l in open(FORBIDDEN, encoding='utf-8')] if FORBIDDEN.exists() else []
    island_seen = {}
    all_err = 0
    for f in files:  # 파일명 순 = 편 순서(서바이벌 → a → b → c)
        errs, warns = check_file(f, exprs, cum, island_seen, fix, forbidden)
        for w in warns:
            print('  warn', w)
        for e in errs:
            print('  ERR ', e)
        all_err += len(errs)
        print(f'{f.relative_to(ROOT)}: 오류 {len(errs)} 경고 {len(warns)}')
    print('총 오류', all_err)
    sys.exit(1 if all_err else 0)


if __name__ == '__main__':
    main()
