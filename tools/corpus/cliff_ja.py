#!/usr/bin/env python3
"""일본어 절벽구간 재산출 — 한국어앱 cliff_ko.py 와 같은 방식(사용자 결정 2026-11-03: 일본 제작 영화·드라마만, fugashi+unidic).

  python cliff_ja.py <자막 말뭉치.zip> <출력 폴더> --only <작품 번호 목록>   (목록 = select_titles.py <zip> Q17 <목록>)

- 단위: unidic 형태소. 조사·조동사(た·ます·ない…)·접사도 각각 한 토큰으로 세어 분자·분모 모두에 넣는다.
  용언(動詞·形容詞·形状詞·助動詞)은 기본형(書字形基本形 orthBase). 기호·보조기호·공백·숫자·로마자는 뺀다. 고유명사·감동사는 남긴다.
- frequency = 토큰 수 ÷ 전체 토큰 수(가중 없음), cum_pct = 1위부터 누적.
- 구간: 2,500위 최대 누적 max 를 80%로 보고 비례 — R1 = cum ≥ max×55/80 첫 순위, R2 = ×60/80, R3 = ×70/80, R4 = 2,500(다른 언어와 같음).
- 작품당 자막 1판, 청각장애인용 소리 설명 제거. 공개 저장소에는 말뭉치 이름을 적지 않는다.
출력: lang_ja_top2500.csv(rank,word,pos,frequency,cum_pct,region) · ja_cliff_summary.json
"""
import csv, json, re, sys, zipfile, gzip, time
from collections import Counter
import fugashi, unidic

src, out = sys.argv[1], sys.argv[2]
only = set(open(sys.argv[sys.argv.index('--only') + 1]).read().split()) if '--only' in sys.argv else None
tagger = fugashi.Tagger('-d "%s"' % unidic.DICDIR)
BASE = ('動詞', '形容詞', '形状詞', '助動詞')
DROP1 = ('補助記号', '記号', '空白')
TAG_RE = re.compile(r'<[^>]+>')
SDH_PAT = re.compile(r'\([^)]*\)|（[^）]*）|\[[^\]]*\]|［[^］]*］|【[^】]*】|＜[^＞]*＞|<[^>]*>|♪[^♪]*♪?|♬[^♬]*♬?|^\s*[-－]\s*')
SDH_LINE = re.compile(r'^(笑い?声?|拍手|音楽|BGM|ため息|悲鳴|泣き声|足音|ノック|チャイム|電話の音|着信音|咳|歓声|効果音|歌)+[\s.…！!]*$')

def docs(zf):
    seen = set()
    for name in zf.namelist():
        if not name.endswith('.xml'):
            continue
        key = name.rsplit('/', 1)[0]
        folder = key.rsplit('/', 1)[1]
        if only is not None:
            parts = folder.split('_'); lead = parts[0].lstrip('0')
            if lead not in only and not (len(parts) > 1 and parts[1].lstrip('0') in only):
                continue
        if key in seen:  # 작품당 자막 1판(내용 있는 첫 파일)
            continue
        text = zf.read(name).decode('utf-8', 'ignore')
        body = TAG_RE.sub(' ', text)
        jp = len(re.findall(r'[ぁ-んァ-ヶ一-龥]', body)); hira = len(re.findall(r'[ぁ-ん]', body))
        if jp < 500 or hira / jp < 0.35:  # 빈 판·OCR 로 깨진 판은 뺀다(일본어 원본은 빈 파일이 많음, 2026-11-03)
            continue
        seen.add(key)
        lines = [TAG_RE.sub(' ', l) for l in re.findall(r'<s\b[^>]*>(.*?)</s>', text, re.S)] or [TAG_RE.sub(' ', text)]
        lines = [SDH_PAT.sub(' ', l) for l in lines]
        yield [l for l in (re.sub(r'\s+', '', x) for x in lines) if l and not SDH_LINE.match(l)]

cnt = Counter(); pos = {}; total = 0; ndoc = 0; t0 = time.time()
with zipfile.ZipFile(src) as zf:
    for lines in docs(zf):
        ndoc += 1
        for l in lines:
            for w in tagger(l):
                f = w.feature
                p1 = f.pos1
                if p1 in DROP1 or f.pos2 == '数詞' or not re.search(r'[ぁ-んァ-ヶー一-龥々〆]', w.surface):
                    continue
                base = f.orthBase if (p1 in BASE and f.orthBase and f.orthBase != '*') else w.surface
                cnt[base] += 1; total += 1; pos.setdefault(base, p1)
        if ndoc % 200 == 0:
            print(f'{ndoc}편 {total/1e6:.2f}M 토큰 {time.time()-t0:.0f}s', flush=True)

top = cnt.most_common(2500); acc = 0.0; rows = []
for i, (w, c) in enumerate(top, 1):
    fr = c / total; acc += fr; rows.append([i, w, pos[w], round(fr, 8), round(acc * 100, 4)])
mx = rows[-1][4]; cut = {}
for name, p in (('R1', 55), ('R2', 60), ('R3', 70)):
    cut[name] = next(r[0] for r in rows if r[4] >= mx * p / 80)
cut['R4'] = 2500
for r in rows:
    r.append('R1' if r[0] <= cut['R1'] else 'R2' if r[0] <= cut['R2'] else 'R3' if r[0] <= cut['R3'] else 'R4')
with open(f'{out}/lang_ja_top2500.csv', 'w', encoding='utf-8', newline='') as fo:
    wr = csv.writer(fo); wr.writerow(['rank', 'word', 'pos', 'frequency', 'cum_pct', 'region']); wr.writerows(rows)
summ = {'docs': ndoc, 'tokens': total, 'types': len(cnt), 'max_cum_2500': mx, 'R1': cut['R1'], 'R2': cut['R2'], 'R3': cut['R3'], 'R4': 2500,
        'cum_at': {k: rows[v - 1][4] for k, v in cut.items()},
        'method': 'fugashi+unidic 형태소, 조사·조동사 각각 한 토큰, 용언 기본형(orthBase), 기호·숫자·로마자 제외, 가중 없음, 비례 구간(55/60/70/80 ÷ 80 × max)',
        'corpus': f'일본 제작 영화·드라마 대사 자막 {ndoc}편(작품당 1판), 청각장애인용 소리 설명 제거', 'date': time.strftime('%Y-%m-%d')}
json.dump(summ, open(f'{out}/ja_cliff_summary.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(json.dumps(summ, ensure_ascii=False))
