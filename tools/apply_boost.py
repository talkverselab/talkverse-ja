#!/usr/bin/env python3
"""카오스·심쿵 수정 답(data/review/chaos/<id>_grok_{chaos,simkung,boost}.md)에서 「바꿈」 줄만 편 JSON 에 반영.
kana 는 janome 으로 다시, rd 는 비움(검사기 --fix-rd), 바뀐 턴의 note 는 비움(뒤에 채움). 바뀐 턴은 review.boost_turns 에 쌓아 장면 컷 재요청에 쓴다.
  ~/.venvs/ja/bin/python tools/apply_boost.py <답.md> ...   (출력: OK id 바뀐턴들)"""
import glob, json, re, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / 'tools')); import rd_ja

def hira(text):
    out = []
    for part in re.split(r'(\{[a-z_]+\})', text):
        if part.startswith('{'): out.append(part); continue
        for t in rd_ja._tokenizer().tokenize(part):
            r = t.reading if t.reading != '*' else t.surface
            out.append(''.join(chr(ord(c) - 0x60) if 'ァ' <= c <= 'ヶ' else c for c in r))
    return ''.join(out)

for md in sys.argv[1:]:
    md = Path(md).resolve()
    eid = re.sub(r'_grok_(chaos|simkung|boost)\.md$', '', md.name)
    kind = re.search(r'_grok_(chaos|simkung|boost)\.md$', md.name).group(1)
    f = glob.glob(str(ROOT / f'assets/data/dialogues/R*/*/{eid}.json'))[0]
    ep = json.load(open(f, encoding='utf-8'))
    by = {t['num']: t for t in ep['turns']}
    changed = []
    summary = ''
    for line in md.read_text(encoding='utf-8').splitlines():
        s = line.strip()
        if s.startswith(('카오스:', '심쿵:', '요약:')): summary += s + ' '
        m = re.match(r'^(\d{1,2})\s*([A-D])\s*[:：]\s*(.+?)\s*/\s*(.+?)\s*/\s*(바꿈|그대로)\s*$', s)
        if not m or m.group(5) != '바꿈': continue
        n = int(m.group(1)); t = by.get(n)
        if not t: continue
        if m.group(2) != t['speaker']: print(f'  화자 불일치 {eid} 턴 {n} {t["speaker"]}→{m.group(2)} (화자는 유지)')
        ja, ko = m.group(3).strip(), m.group(4).strip()
        if ja == t['ja'] and ko == t['ko']: continue
        t.update(ja=ja, kana=hira(ja), rd='', ko=ko, note='', new=[])
        t.pop('rd_manual', None)
        changed.append(n)
    rv = ep.setdefault('review', {})
    rv[kind] = f'{md.resolve().relative_to(ROOT)}: 턴 {changed} 교체 · {summary.strip()}'
    rv['boost_turns'] = sorted(set(rv.get('boost_turns', [])) | set(changed))
    if kind in ('chaos',) or (kind == 'boost' and '카오스' in summary and '없음' not in summary.split('카오스')[1][:6]):
        ep['twist_type'] = 'chaos'
    open(f, 'w', encoding='utf-8').write(json.dumps(ep, ensure_ascii=False, indent=1) + '\n')
    print('OK', eid, changed)
