#!/usr/bin/env python3
"""절벽 단어 분류표 반영 — noise 줄은 목록에서 빼고(순위 번호는 그대로), 나머지의 읽기·뜻·품사를 앱 에셋으로.

  python3 tools/freq/cliff_class.py <분류표.csv>

분류표 열: rank,word,action(noise|grammar|alias|draw),reading,ko,en,pos,…
- noise → assets/data/freq·data/corpus 의 lang_ja_with_regions.csv 에서 삭제(순위는 다시 매기지 않는다 — 그림 번호가 순위)
- 그 밖 → assets/data/freq/cliff_notes_ja.json {낱말: {k 읽기, ko 뜻, pos 품사, g 문법이면 1}}
"""
import csv, json, sys

cls = list(csv.DictReader(open(sys.argv[1], encoding='utf-8-sig')))
noise = {(r['rank'], r['word']) for r in cls if r['action'] == 'noise'}
for path in ('assets/data/freq/lang_ja_with_regions.csv', 'data/corpus/lang_ja_with_regions.csv'):
    raw = open(path, encoding='utf-8-sig', newline='').read()
    lines = raw.split('\n')
    keep = [l for l in lines if tuple(l.split(',')[:2]) not in noise]
    open(path, 'w', encoding='utf-8-sig', newline='').write('\n'.join(keep))
    print(path, len(lines) - len(keep), '줄 삭제')
notes = {}
for r in cls:
    if r['action'] == 'noise' or not (r['ko'] or r['reading']):
        continue
    n = {}
    if r['reading'] and r['reading'] != r['word']: n['k'] = r['reading']
    if r['ko']: n['ko'] = r['ko']
    if r['pos']: n['pos'] = r['pos']
    if r['action'] == 'grammar': n['g'] = 1
    notes[r['word']] = n
json.dump({'words': notes}, open('assets/data/freq/cliff_notes_ja.json', 'w'), ensure_ascii=False, separators=(',', ':'))
print('cliff_notes', len(notes), '문법', sum(1 for n in notes.values() if n.get('g')))
