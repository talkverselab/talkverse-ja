#!/usr/bin/env python3
"""Grok 이 처음부터 쓴 편(번호 화자: 일본어 / 한국어)을 새 편 JSON 으로 만든다 — 대사·번역은 그대로, 감정·메모는 메타 파일에서.
  ~/.venvs/ja/bin/python tools/new_from_grok.py <메타.json>
메타: {id, region, island, title, emoji, register, twist, speakers, where, scene, goal, flags, emotions:[16], notes:{턴:메모}}"""
import json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools')); from apply_rewrite import to_hira
m = json.load(open(sys.argv[1], encoding='utf-8'))
src = ROOT / 'data/review/write' / f"{m['id']}_grok_write.md"
turns, expr, title = [], [], None
for ln in open(src, encoding='utf-8'):
    ln = ln.strip()
    if ln.startswith('제목'): title = ln.split(':', 1)[1].strip()
    g = re.match(r'^(\d+)\s+([A-D])\s*[:：]\s*(.+?)\s*/\s*(.+)$', ln)
    if g:
        n, sp, ja, ko = int(g[1]), g[2], g[3].strip(), g[4].strip()
        turns.append({'num': n, 'speaker': sp, 'ja': ja, 'kana': to_hira(ja), 'rd': '', 'ko': ko,
                      'note': m.get('notes', {}).get(str(n), ''), 'tags': [], 'new': [], 'emotion': m['emotions'][n - 1]})
    if ln.startswith('추천'):
        expr = [x.split('/')[0].strip() for x in re.split(r'[,、]\s*|\s{2,}', ln.split(':', 1)[1]) if x.strip()]
assert [t['num'] for t in turns] == list(range(1, 17)), [t['num'] for t in turns]
ep = {'id': m['id'], 'region': 'R4', 'island': m['island'], 'kind': 'long', 'draft': True, 'flags': m.get('flags', []),
      'purpose': [f"conversation_{m['island']}"], 'domain': [m['island']], 'title': title or m['title'], 'emoji': m['emoji'],
      'register': m['register'], 'twist': m['twist'], 'speakers': m['speakers'], 'where': m['where'], 'scene': m['scene'],
      'goal': m['goal'], 'expressions': m.get('expressions') or expr, 'turns': turns, 'twist_type': 'emotion',
      'review': {'grok_write': f"{src.name} {m.get('date','2026-11-22')} — 16턴 모두 Grok 작성 그대로(사용자 「R4 진행」)"}}
if m.get('cast'): ep['cast'] = m['cast']
out = ROOT / 'assets/data/dialogues/R4' / m['island'] / f"{m['id']}.json"
json.dump(ep, open(out, 'w', encoding='utf-8'), ensure_ascii=False, indent=1); open(out, 'a').write('\n')
print('OK', out.relative_to(ROOT), len(turns), '턴', ep['title'])
