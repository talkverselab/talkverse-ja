#!/usr/bin/env python3
"""편 JSON 의 턴마다 `lemmas`(내용어 [표면형, 기본형, 읽기]) 를 채운다 — 문장 레마 ↔ 단어장 연결(사용자 지시 2026-11-04).
검사기(check_dialogues.lemmas)와 같은 기준(조사·조동사·기호·보조동사 제외). 단어장(words_jlpt.json)에 없는 레마는 data/review/write/missing_lemmas.csv 로(uk 세션에 넘김).
  ~/.venvs/ja/bin/python tools/add_lemmas.py"""
import csv, glob, json, re, sys
from collections import Counter
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'tools')); import rd_ja
from check_dialogues import lemmas
VAR = re.compile(r'\{[a-z_]+\}')
wj = json.load(open(ROOT / 'assets/data/words/words_jlpt.json', encoding='utf-8'))['entries']
db = {e['surface'] for e in wj} | {e['kana'] for e in wj}
miss = Counter(); ex = {}; tot = hit = 0
for f in sorted(glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json'))):
    d = json.load(open(f, encoding='utf-8')); ch = False
    for t in d['turns']:
        out = []
        for tok in rd_ja._tokenizer().tokenize(VAR.sub(' ', t['ja'])):
            pass
        # 표면형도 필요하므로 lemmas() 와 같은 필터를 토큰 단위로 다시 적용
        from check_dialogues import SKIP_POS, SKIP_SURF, LEMMA_FIX
        for tok in rd_ja._tokenizer().tokenize(VAR.sub(' ', t['ja'])):
            feats = tok.part_of_speech.split(','); pos, pos2 = feats[0], feats[1] if len(feats) > 1 else ''
            if pos in SKIP_POS or pos2 == '非自立' or re.fullmatch(r'[A-Za-z0-9]+', tok.surface): continue
            base = tok.base_form if tok.base_form != '*' else tok.surface
            base = LEMMA_FIX.get((tok.surface, base), base)
            if base in SKIP_SURF or tok.surface in SKIP_SURF: continue
            if not re.search(r'[ぁ-んァ-ヶ一-龥々]', base): continue  # 기호·숫자·w 같은 것
            rd = ''.join(chr(ord(c) - 0x60) if 'ァ' <= c <= 'ヶ' else c for c in (tok.reading if tok.reading != '*' else tok.surface))
            out.append([tok.surface, base, rd]); tot += 1
            if base in db or rd in db: hit += 1
            else: miss[base] += 1; ex.setdefault(base, (rd, t['ja']))
        if t.get('lemmas') != out: t['lemmas'] = out; ch = True
    if ch: open(f, 'w', encoding='utf-8').write(json.dumps(d, ensure_ascii=False, indent=1) + '\n')
with open(ROOT / 'data/review/write/missing_lemmas.csv', 'w', encoding='utf-8', newline='') as fo:
    w = csv.writer(fo); w.writerow(['lemma', 'reading', 'count', 'example'])
    for b, n in miss.most_common(): w.writerow([b, ex[b][0], n, ex[b][1]])
print(f'내용어 {tot} · 단어장 있음 {hit/tot:.0%} · 없는 레마 {len(miss)} → missing_lemmas.csv')
