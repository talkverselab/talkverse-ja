#!/usr/bin/python3
"""Grok 프로젝트 챗에서 n번째(1부터) 답이 채워질 때까지 기다린다. 비어 보이면 reload.  grok_wait.py <url조각> <기대 응답 수> [최대초]"""
import sys, time
sys.path.insert(0, '/Users/talkverse/Hanja/tools'); import grok_cdp as g
frag, want, limit = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]) if len(sys.argv) > 3 else 240
t0 = time.time(); reloaded = False
while time.time() - t0 < limit:
    c = g.CDP(g.tab(frag))
    els = c.ev("[...document.querySelectorAll('.response-content-markdown')].map(e=>e.innerText.length)")
    busy = c.ev("document.body.innerText.includes('작업 중') || !![...document.querySelectorAll('button')].find(e=>(e.getAttribute('aria-label')||'')==='응답 중지')")
    if len(els) >= 2 * want and not busy:
        if els[2 * want - 1] > 200:
            print('READY', els); sys.exit(0)
        if not reloaded:
            c.call('Page.reload'); reloaded = True; time.sleep(8); continue
    time.sleep(10)
print('TIMEOUT', els); sys.exit(1)
