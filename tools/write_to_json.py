#!/usr/bin/env python3
"""Grok 작성 답(data/review/write/<id>_grok_write.md) + 편 설계(specs_*.json) → 편 JSON(assets/data/dialogues/R3/<주제>/<id>.json).
kana = janome 읽기(변수는 그대로), rd 는 비움(검사기 --fix-rd 로 채움), tags = 목표 표현이 들어간 턴에 expr:, note 는 비움(뒤에 채움).
  ~/.venvs/ja/bin/python tools/write_to_json.py data/review/write/specs_r3.json [id ...]"""
import json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'tools')); import rd_ja

def hira(text):
    out = []
    for part in re.split(r'(\{[a-z_]+\})', text):
        if part.startswith('{'):
            out.append(part); continue
        for t in rd_ja._tokenizer().tokenize(part):
            r = t.reading if t.reading != '*' else t.surface
            out.append(''.join(chr(ord(c) - 0x60) if 'ァ' <= c <= 'ヶ' else c for c in r))
    return ''.join(out)

def parse(md):
    title, turns, rec = '', {}, []
    in_rec = False
    for line in md.splitlines():
        s = line.strip()
        if not s: continue
        if s.startswith('제목'):
            title = s.split(':', 1)[-1].split('：', 1)[-1].strip(); continue
        if s.startswith('추천 표현'):
            in_rec = True; rest = s.split(':', 1)[-1].strip()
            if rest: rec.append(rest)
            continue
        m = re.match(r'^(\d{1,2})\s*([A-D])\s*[:：]\s*(.+?)\s*/\s*(.+)$', s)
        if m and not in_rec:
            turns[int(m.group(1))] = (m.group(2), m.group(3).strip(), m.group(4).strip()); continue
        if in_rec:
            rec.append(s.lstrip('-•*0123456789. '))
    return title, turns, rec

def main():
    specs = {s['id']: s for s in json.load(open(sys.argv[1], encoding='utf-8'))}
    ids = sys.argv[2:] or list(specs)
    for eid in ids:
        s = specs[eid]
        md = ROOT / 'data/review/write' / f'{eid}_grok_write.md'
        if not md.exists():
            print('없음', eid); continue
        title, turns, rec = parse(md.read_text(encoding='utf-8'))
        reg = s.get('region', 'R3'); nt = {'R0': 6, 'R1': 8, 'R2': 12}.get(reg, 16)
        if len(turns) < nt:
            print('턴 부족', eid, len(turns)); continue
        targets = [x.strip() for x in s['targets'].split('・') if x.strip()]
        rec_ja = [r.split('/')[0].strip() for r in rec if '/' in r]
        exprs = [t for t in targets if any(t.rstrip('?') in v[1] for v in turns.values())] + [r for r in rec_ja if r and r not in targets]
        out = []
        for n in sorted(turns):
            sp, ja, ko = turns[n]
            tags = [f'expr:{e}' for e in exprs if e and e.rstrip('?') in ja]
            out.append({'num': n, 'speaker': sp, 'ja': ja, 'kana': hira(ja), 'rd': '', 'ko': ko, 'note': '', 'tags': tags, 'new': [], **({'ui': 'bubble'} if s.get('kind') == 'chat' else {})})
        flags = []
        if any(k in s['scene'] + s['beats'] for k in ('술', 'ビール', '飲み', '忘年会', '접대')): flags.append('alcohol')
        if s['island'] == 'culture' and 'サクラ' in s['speakers'].values(): flags.append('romance')
        ep = {'id': eid, 'region': reg, 'island': s['island'], 'kind': s.get('kind', 'long'), 'draft': True,
              'purpose': [f"conversation_{s['island']}"], 'domain': [s['island']],
              'title': s['title'] if not title else title, 'emoji': s['emoji'], 'scene': s['scene'],
              'speakers': s['speakers'], 'register': s['register'], 'twist': s['twist'], 'flags': flags,
              'goal': f"목표 표현: {s['targets']}", **({'twist_type': s['twist_type']} if s.get('twist_type') else {}), 'expressions': exprs, 'turns': out,
              'review': {'grok_write': f'data/review/write/{eid}_grok_write.md', 'final': '2026-11-03 Grok 작성본(처음부터) 그대로 — 검사기 통과용 최소 수정만'}}
        dst = ROOT / 'assets/data/dialogues' / reg / s['island'] / f'{eid}.json'
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(json.dumps(ep, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
        print('OK', eid, len(out), title)

if __name__ == '__main__':
    main()
