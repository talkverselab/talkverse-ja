#!/usr/bin/env python3
"""점검표(audit_*.json) → 카오스+심쿵 picks(data/review/chaos/boost_picks.json). idea = 「고칠 것」 줄(카오스·심쿵 각각)."""
import glob, json, os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = []
for f in sorted(glob.glob(os.path.join(ROOT, 'data/review/chaos/audit_*.json'))):
    for e in json.load(open(f, encoding='utf-8')):
        parts = []
        if e.get('chaos_idea'): parts.append(f"- 반전을 **카오스**로: {e['chaos_idea']}")
        if e.get('simkung_idea') and not e.get('has_simkung'): parts.append(f"- **심쿵 포인트** 넣기: {e['simkung_idea']}")
        if parts: out.append({'id': e['id'], 'idea': '\n'.join(parts)})
json.dump(out, open(os.path.join(ROOT, 'data/review/chaos/boost_picks.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(len(out), 'picks')
