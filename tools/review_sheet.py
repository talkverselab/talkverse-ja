#!/usr/bin/env python3
"""편 JSON 들 → 사용자 리뷰용 마크다운(턴마다 일본어/독음/한국어 세 줄).  python tools/review_sheet.py <출력.md> <편.json>..."""
import json, sys
from pathlib import Path
out = Path(sys.argv[1]); parts = ['# 회화 리뷰 시트 — ' + __import__('datetime').date.today().isoformat(), '',
 '턴마다 세 줄: 일본어 / 한글 독음 / 한국어. 각 편 아래 「상태」에 Grok 재작성 반영 여부. 고칠 곳은 편 id·턴 번호로 적어 주세요.', '']
for p in sys.argv[2:]:
    ep = json.load(open(p, encoding='utf-8'))
    sp = ' · '.join(f'{k}={v}' for k, v in ep['speakers'].items())
    rv = ep.get('review', {})
    parts += [f"## {ep['id']} 「{ep['title']}」", f"장면: {ep['scene']}  ", f"말투: {ep.get('register')} · 턴 {len(ep['turns'])} · 반전 {ep.get('twist')}턴 · {sp}  ",
              f"상태: {rv.get('final', '제 초안(Grok 재작성 대기)')}", '']
    for t in ep['turns']:
        parts += [f"**{t['num']} {t['speaker']}** {t['ja']}  ", f"　{t.get('rd','')}  ", f"　{t['ko']}", '']
    if ep.get('expressions'):
        parts += ['표현 풀: ' + ' · '.join(ep['expressions']), '']
out.write_text('\n'.join(parts), encoding='utf-8'); print(out)
