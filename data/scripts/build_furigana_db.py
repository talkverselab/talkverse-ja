# -*- coding: utf-8 -*-
"""
한자 ↔ 읽기 ↔ 단어(후리가나 분절) DB 빌드 — JLPT 기준.

입력 (data/raw/, gitignore):
  kanji-data.json        davidluzgouveia/kanji-data (MIT)  — 13k 한자: jlpt_new/grade/strokes/on/kun/en meanings
  jlpt_n1..n5.csv        elzup/jlpt-word-list (MIT)         — JLPT 어휘 7,972 (expression, reading, en meaning)
  JmdictFurigana.txt     Doublevil/JmdictFurigana (CC BY-SA) — 표기|읽기|후리가나 분절 (235k)
  kyuji.cson             hakatashi/kyujitai.js              — 新字体 → 舊字体 (한국 한자 매칭용)
입력 (data/corpus/):
  kanji_meanings_ko.json 우리 1,078자 훈음·읽기 gloss
  edu/hanja_1800_kr.json, edu/hanja_eomunhoe_kr.json  한국 한자 훈음 (舊字体)
  ja_kanji_weighted_freq.csv  회화 가중 빈도
assets/data/decks/*.json, assets/data/kanji/kanji_index.json  한국어 단어 뜻

출력:
  assets/data/kanji/kanji_db.json     한자 (JLPT N5-N1 ∪ 회화 1,078)
  assets/data/words/words_jlpt.json   단어 + 후리가나 분절 (JLPT 7,972 ∪ 회화 top2500 한자어)
"""
import csv
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')
ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / 'data' / 'raw'
CORPUS = ROOT / 'data' / 'corpus'
ASSETS = ROOT / 'assets' / 'data'


def is_kanji(c):
    o = ord(c)
    return 0x4E00 <= o <= 0x9FFF or 0x3400 <= o <= 0x4DBF or c == '々'


def has_kanji(s):
    return any(is_kanji(c) for c in s)


def kata(s):
    return ''.join(chr(ord(c) + 0x60) if 0x3041 <= ord(c) <= 0x3096 else c for c in s)


def hira(s):
    return ''.join(chr(ord(c) - 0x60) if 0x30A1 <= ord(c) <= 0x30F6 else c for c in s)


# ── 1. 한자 ────────────────────────────────────────────────────────────────
kd = json.load(open(RAW / 'kanji-data.json', encoding='utf-8'))
ko_meanings = json.load(open(CORPUS / 'kanji_meanings_ko.json', encoding='utf-8'))
ko_extra = {k: v for k, v in json.load(open(CORPUS / 'kanji_meanings_ko_extra.json', encoding='utf-8')).items() if not k.startswith('_')}
kanji_index = json.load(open(ASSETS / 'kanji' / 'kanji_index.json', encoding='utf-8'))['entries']
our_rank = {e['char']: (e['rank'], e['pct']) for e in kanji_index}

# 舊字体 map: 新 → 舊
shin2kyu = {}
for line in open(RAW / 'kyuji.cson', encoding='utf-8'):
    m = re.match(r'\s*\["(.)", "(.)"', line)
    if m:
        shin2kyu.setdefault(m.group(1), m.group(2))

# 한국 훈음: 舊字体 기준 dict
hanja_ko = {}
for f in ['hanja_eomunhoe_kr.json', 'hanja_1800_kr.json']:
    for e in json.load(open(CORPUS / 'edu' / f, encoding='utf-8')):
        hanja_ko.setdefault(e['hanja'], f"{e['meaning']} {e['sound']}")


def ko_meaning_for(ch):
    if ch in ko_meanings and ko_meanings[ch].get('meanings'):
        return list(ko_meanings[ch]['meanings']), 'corpus'
    for cand in (ch, shin2kyu.get(ch)):
        if cand and cand in hanja_ko:
            return [hanja_ko[cand]], 'hanja_kr'
    if ch in ko_extra:
        return [ko_extra[ch]], 'authored'
    return [], None


kanji_set = {c for c, v in kd.items() if v.get('jlpt_new')} | set(our_rank)
kanji_out = []
src_count = defaultdict(int)
for ch in kanji_set:
    v = kd.get(ch, {})
    meanings_ko, src = ko_meaning_for(ch)
    src_count[src] += 1
    on = [kata(r) for r in v.get('readings_on', [])]
    kun = [r.replace('.', '-') for r in v.get('readings_kun', [])]
    glosses = {}
    if ch in ko_meanings:
        for r in ko_meanings[ch].get('readings', []):
            key = hira(r['reading'].split('-')[0].replace('.', ''))
            glosses[key] = r.get('gloss', '')
        # 우리 데이터에만 있는 읽기 보강
        for r in ko_meanings[ch].get('readings', []):
            rr = r['reading']
            if r['kind'] == '음독' and kata(rr) not in on:
                on.append(kata(rr))
            if r['kind'] == '훈독' and rr.replace('.', '-') not in kun:
                kun.append(rr.replace('.', '-'))
    rank, pct = our_rank.get(ch, (None, None))
    kanji_out.append({
        'char': ch,
        'jlpt': v.get('jlpt_new'),
        'grade': v.get('grade'),
        'strokes': v.get('strokes'),
        'freq_kd': v.get('freq'),
        'rank': rank,
        'pct': pct,
        'meanings_ko': meanings_ko,
        'meanings_en': v.get('meanings', [])[:3],
        'on': on,
        'kun': kun,
        'glosses': glosses,  # 읽기(히라가나 base) → 한국어 gloss
        'ko_src': src,
    })


def kanji_sort_key(k):
    return (k['jlpt'] is None, -(k['jlpt'] or 0), k['rank'] or 9999, k['freq_kd'] or 9999)


kanji_out.sort(key=kanji_sort_key)
print(f"kanji: {len(kanji_out)}  ko src: {dict(src_count)}")
print('  jlpt dist:', {n: sum(1 for k in kanji_out if k['jlpt'] == n) for n in [5, 4, 3, 2, 1, None]})

# ── 2. 후리가나 사전 ─────────────────────────────────────────────────────
furi = defaultdict(list)  # surface → [(reading, spec)]
for line in open(RAW / 'JmdictFurigana.txt', encoding='utf-8-sig'):
    parts = line.rstrip('\n').split('|')
    if len(parts) != 3:
        continue
    furi[parts[0]].append((parts[1], parts[2]))


PAREN = re.compile(r'\s*[（(][^)）]*[)）]\s*')


def clean_variants(expr):
    """'伯母さん; 叔母さん' → ['伯母さん','叔母さん'], '結婚 (する)' → ['結婚'], '～中' → ['～中']"""
    out = []
    for v in re.split(r'[;；、]\s*', expr):
        v = PAREN.sub('', v).strip()
        if v and v not in out:
            out.append(v)
    return out


def lookup_key(surface):
    return surface.replace('～', '').replace('〜', '').replace('…', '')


def segments(surface, reading):
    """(surface, reading) → [[text, furigana|None], ...]  없으면 None"""
    spec = None
    key = lookup_key(surface)
    rkey = lookup_key(reading)
    for r, s in furi.get(key, []):
        if r == rkey:
            spec = s
            break
    if spec is None:
        return None
    if key != surface:
        # ～ 접두/접미: 접두 '～' 는 분절 앞에, 접미는 뒤에 붙임
        pre = surface[:len(surface) - len(surface.lstrip('～〜'))]
        suf = surface[len(surface.rstrip('～〜')):]
        segs = segments(key, rkey)
        if segs is None:
            return None
        if pre:
            segs = [[pre, None]] + segs
        if suf:
            segs = segs + [[suf, None]]
        return segs
    surface = key
    covered = {}
    for part in spec.split(';'):
        if not part:
            continue
        idx, rd = part.split(':', 1)
        if '-' in idx:
            a, b = idx.split('-')
            covered[(int(a), int(b))] = rd
        else:
            covered[(int(idx), int(idx))] = rd
    segs = []
    i = 0
    n = len(surface)
    while i < n:
        hit = None
        for (a, b), rd in covered.items():
            if a == i:
                hit = (b, rd)
                break
        if hit:
            b, rd = hit
            segs.append([surface[i:b + 1], rd])
            i = b + 1
        else:
            j = i
            while j < n and not any(a == j for (a, _b) in covered):
                j += 1
            segs.append([surface[i:j], None])
            i = j
    return segs


# ── 3. 한국어 단어 뜻 소스 ───────────────────────────────────────────────
ko_word = {}
for f in sorted((ASSETS / 'decks').glob('deck_*.json')):
    if f.name == 'deck_kanji.json':
        continue  # 한자 훈음 ('앞 전') 은 단어 뜻이 아님
    for c in json.load(open(f, encoding='utf-8'))['cards']:
        if c.get('front') and c.get('back') and len(c['front']) <= 12:
            ko_word.setdefault(c['front'], c['back'])
for e in kanji_index:
    for w in e.get('words', []):
        if w.get('ko'):
            ko_word.setdefault(w['word'], w['ko'])
print('ko word glosses available:', len(ko_word))

# 수동 한국어 뜻 (data/corpus/ko_gloss/done_*.json: "surface|kana" → 뜻)
ko_pair = {}
for f in sorted((CORPUS / 'ko_gloss').glob('done_*.json')):
    for k, v in json.load(open(f, encoding='utf-8')).items():
        if isinstance(v, str) and v.strip():
            ko_pair[k] = v.strip()
print('ko pair glosses (manual):', len(ko_pair))

# ── 4. 단어: JLPT 리스트 ─────────────────────────────────────────────────
words = {}  # (surface, reading) → dict
for n in [5, 4, 3, 2, 1]:
    with open(RAW / f'jlpt_n{n}.csv', encoding='utf-8') as fh:
        for row in csv.DictReader(fh):
            surfaces = clean_variants(row['expression']) or [row['expression'].strip()]
            readings = clean_variants(row['reading']) or surfaces
            for si, surface in enumerate(surfaces):
                # 표기 변형이 여럿이고 읽기도 여럿이면 1:1, 아니면 모든 읽기
                rds = [readings[si]] if len(readings) == len(surfaces) and len(surfaces) > 1 else readings
                for reading in rds:
                    if reading.endswith('する') and not surface.endswith('する') and len(reading) > 2:
                        reading = reading[:-2]
                    key = (surface, reading)
                    if key in words:
                        words[key]['jlpt'] = max(words[key]['jlpt'], n)
                        continue
                    words[key] = {
                        'surface': surface,
                        'kana': reading,
                        'jlpt': n,
                        'en': row['meaning'].strip(),
                        'ko': ko_pair.get(f'{surface}|{reading}') or ko_word.get(surface) or ko_word.get(lookup_key(surface)),
                        'rank': None,
                        'src': 'jlpt',
                    }
print('jlpt words:', len(words))

# ── 5. 단어: 회화 top2500 (한자 포함, JLPT 밖) ────────────────────────────
added = 0
with open(CORPUS / 'lang_ja_with_regions.csv', encoding='utf-8-sig') as fh:
    for row in csv.DictReader(fh):
        w = row['word'].strip()
        if not has_kanji(w):
            continue
        rank = int(row['rank'])
        matched = [k for k in words if k[0] == w]
        if matched:
            for k in matched:
                if words[k]['rank'] is None:
                    words[k]['rank'] = rank
            continue
        readings = []
        for r, _s in furi.get(w, []):
            if r not in readings:
                readings.append(r)
        for r in readings[:2]:
            words[(w, r)] = {
                'surface': w, 'kana': r, 'jlpt': None, 'en': '',
                'ko': ko_pair.get(f'{w}|{r}') or ko_word.get(w), 'rank': rank, 'src': 'corpus',
            }
            added += 1
print('corpus words added:', added)

# ── 6. 분절 + 출력 ────────────────────────────────────────────────────────
out_words = []
seg_hit = seg_miss = 0
for i, (key, w) in enumerate(sorted(words.items(), key=lambda kv: (-(kv[1]['jlpt'] or 0), kv[1]['rank'] or 99999, kv[0]))):
    segs = None
    if has_kanji(w['surface']):
        segs = segments(w['surface'], w['kana'])
        if segs:
            seg_hit += 1
        else:
            seg_miss += 1
    w = dict(w)
    w['id'] = i + 1
    w['segs'] = segs
    out_words.append(w)
print(f'segments: hit {seg_hit} miss {seg_miss}')

# 한자별 읽기 커버리지 리포트
kanji_chars = {k['char'] for k in kanji_out}
link = defaultdict(set)
for w in out_words:
    for s in (w['segs'] or []):
        if s[1] and len(s[0]) == 1 and s[0] in kanji_chars:
            link[s[0]].add(s[1])
print('kanji with ≥1 linked reading:', len(link), '/', len(kanji_chars))

(ASSETS / 'words').mkdir(exist_ok=True)
json.dump({'version': 'v1-2026-08-17', 'sources': ['kanji-data (MIT)', 'kanji_meanings_ko', 'hanja_kr'], 'total': len(kanji_out), 'entries': kanji_out},
          open(ASSETS / 'kanji' / 'kanji_db.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
json.dump({'version': 'v1-2026-08-17', 'sources': ['jlpt-word-list (MIT)', 'JmdictFurigana (CC BY-SA)', 'lang_ja_top2500'], 'total': len(out_words), 'entries': out_words},
          open(ASSETS / 'words' / 'words_jlpt.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print('written', (ASSETS / 'kanji' / 'kanji_db.json').stat().st_size // 1024, 'KB /', (ASSETS / 'words' / 'words_jlpt.json').stat().st_size // 1024, 'KB')
