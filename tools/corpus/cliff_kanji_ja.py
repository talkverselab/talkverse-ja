"""일본어 절벽구간 — 한자(글자) 기준 재산출(사용자 지시 2026-11-07). 단어 기준 cliff_ja.py 와 같은 말뭉치·같은 공식.
  python cliff_kanji_ja.py <자막 말뭉치.zip> <출력 폴더> --only <작품 번호 목록>
단위 = 대사에 나온 한자 한 글자(一-龥·々·〆). frequency = 글자 수 ÷ 전체 한자 글자 수(가중 없음).
구간 = 절대 기준(누적 55·60·70·80% 에 처음 닿는 순위 → R1~R4, 80% 밖 = R5). 출력 kanji_ja_top2500.csv · ja_kanji_cliff_summary.json."""
import csv, json, re, sys, zipfile, time
from collections import Counter
src, out = sys.argv[1], sys.argv[2]
only = None
if '--only' in sys.argv:
    only = {l.strip().lstrip('0') for l in open(sys.argv[sys.argv.index('--only') + 1], encoding='utf-8') if l.strip()}
TAG_RE = re.compile(r'<[^>]+>')
SDH_PAT = re.compile(r'\([^)]*\)|（[^）]*）|\[[^\]]*\]|［[^］]*］|【[^】]*】|＜[^＞]*＞|<[^>]*>|♪[^♪]*♪?|♬[^♬]*♬?|^\s*[-－]\s*')
SDH_LINE = re.compile(r'^(笑い?声?|拍手|音楽|BGM|ため息|悲鳴|泣き声|足音|ノック|チャイム|電話の音|着信音|咳|歓声|効果音|歌)+[\s.…！!]*$')
KANJI = re.compile(r'[一-龥々〆]')

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
        if key in seen:
            continue
        text = zf.read(name).decode('utf-8', 'ignore')
        body = TAG_RE.sub(' ', text)
        jp = len(re.findall(r'[ぁ-んァ-ヶ一-龥]', body)); hira = len(re.findall(r'[ぁ-ん]', body))
        if jp < 500 or hira / jp < 0.35:
            continue
        seen.add(key)
        lines = [TAG_RE.sub(' ', l) for l in re.findall(r'<s\b[^>]*>(.*?)</s>', text, re.S)] or [TAG_RE.sub(' ', text)]
        lines = [SDH_PAT.sub(' ', l) for l in lines]
        yield [l for l in (re.sub(r'\s+', '', x) for x in lines) if l and not SDH_LINE.match(l)]

cnt = Counter(); total = 0; ndoc = 0; t0 = time.time()
with zipfile.ZipFile(src) as zf:
    for lines in docs(zf):
        ndoc += 1
        for l in lines:
            ks = KANJI.findall(l); cnt.update(ks); total += len(ks)
top = cnt.most_common(2500); acc = 0.0; rows = []
for i, (w, c) in enumerate(top, 1):
    fr = c / total; acc += fr; rows.append([i, w, round(fr, 8), round(acc * 100, 4)])
cut = {}
for name, p in (('R1', 55), ('R2', 60), ('R3', 70), ('R4', 80)):
    cut[name] = next((r[0] for r in rows if r[3] >= p), None)
for r in rows:
    r.append(next((n for n in ('R1', 'R2', 'R3', 'R4') if cut[n] and r[0] <= cut[n]), 'R5'))
with open(f'{out}/kanji_ja_top2500.csv', 'w', encoding='utf-8', newline='') as fo:
    wr = csv.writer(fo); wr.writerow(['rank', 'kanji', 'frequency', 'cum_pct', 'region']); wr.writerows(rows)
summ = {'docs': ndoc, 'kanji_tokens': total, 'kanji_types': len(cnt), 'max_cum_2500': rows[-1][3] if rows else None,
        **cut, 'cum_at': {n: next((r[3] for r in rows if r[0] == cut[n]), None) for n in cut},
        'cum_at_rank': {str(k): next((r[3] for r in rows if r[0] == k), None) for k in (300, 500, 1000, 1500, 2000, 2136)},
        'method': '대사의 한자 글자(一-龥·々·〆) 하나를 한 토큰으로 세어 글자별 빈도, 가중 없음, 절대 구간(누적 55/60/70/80% 첫 순위, 80% 밖 = R5). 단어 기준 cliff_ja.py 와 같은 말뭉치·같은 자막 정리',
        'corpus': '일본 제작 영화·드라마 대사 자막(작품당 1판), 청각장애인용 소리 설명 제거', 'date': time.strftime('%Y-%m-%d')}
json.dump(summ, open(f'{out}/ja_kanji_cliff_summary.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(json.dumps(summ, ensure_ascii=False))
