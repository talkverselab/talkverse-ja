#!/usr/bin/env python3
"""자막 묶음에서 「자국 제작」 작품만 고르기 — 한국어앱 select_titles.py 복사 — 일본어는 Q17(일본).

  python select_titles.py <자막.zip> <국가 QID> <출력 목록.txt>   예) ... Q884(대한민국) / Q17(일본)

1) 공개 지식 DB SPARQL: 「제작 국가(P495) = 국가」 이고 작품DB ID(P345, tt…) 가 있는 작품(영화·드라마 시리즈)
2) 작품DB 공개 회차 목록 title.episode.tsv.gz(https://datasets.workdb.com/): 부모(시리즈)가 1) 에 있는 회차 번호를 더한다
3) zip 안 폴더 <연도>/<폴더>/<파일>.xml 의 폴더 이름 앞 번호(= 작품DB 번호, 회차 폴더는 「시리즈_회차_시즌_회」)가 1)·2) 에 있으면 채택
출력: 채택한 앞 번호 목록 → cliff_ko.py --only 로 넘긴다.
"""
import gzip, re, sys, urllib.parse, urllib.request, zipfile, os
# 공개 지식 DB SPARQL 주소·작품 회차 목록 주소는 저장소에 적지 않는다 — 환경변수 WD_SPARQL·EP_URL(값은 ~/corpus/README_local.txt)
WD_SPARQL, EP_URL = os.environ['WD_SPARQL'], os.environ['EP_URL']
src, qid, out = sys.argv[1:4]
q = f'SELECT DISTINCT ?workid WHERE {{ ?i wdt:P495 wd:{qid} ; wdt:P345 ?workid . FILTER(STRSTARTS(?workid,"tt")) }}'
req = urllib.request.Request(WD_SPARQL + '?' + urllib.parse.urlencode({'query': q}),
                             headers={'Accept': 'text/csv', 'User-Agent': 'talkverse-cliff/1.0'})
ids = {l.strip()[2:].lstrip('0') for l in urllib.request.urlopen(req, timeout=300).read().decode().splitlines() if l.startswith('tt')}
ep_path = os.path.join(os.path.dirname(out) or '.', 'title.episode.tsv.gz')
if not os.path.exists(ep_path):
    urllib.request.urlretrieve(EP_URL, ep_path)
eps = set()
with gzip.open(ep_path, 'rt') as f:
    next(f)
    for line in f:
        t, parent = line.split('\t', 2)[:2]
        if parent[2:].lstrip('0') in ids:
            eps.add(t[2:].lstrip('0'))
keep = set(); films = epn = 0
for n in zipfile.ZipFile(src).namelist():
    m = re.match(r'.*/raw/[^/]+/[^/]+/([^/]+)/[^/]+\.xml$', n)
    if not m:
        continue
    parts = m.group(1).split('_'); lead = parts[0].lstrip('0')
    if lead in ids or lead in eps or (len(parts) > 1 and parts[1].lstrip('0') in eps):
        if lead not in keep:
            keep.add(lead); epn += '_' in m.group(1); films += '_' not in m.group(1)
open(out, 'w').write('\n'.join(sorted(keep)))
print(f'제작국 작품 {len(ids)} · 회차 {len(eps)} · 채택 앞 번호 {len(keep)}(영화 {films} · 회차 폴더 {epn})')
