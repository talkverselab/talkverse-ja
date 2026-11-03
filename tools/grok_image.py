#!/usr/bin/python3
"""Grok 에 그림 1장을 요청해 받아 저장(캐릭터 시트 등). 새 대화(GROK_HOME)에서, 첨부는 M4 경로.
  GROK_HOME=https://grok.com/ GROK_CDP_PORT=9230 /usr/bin/python3 tools/grok_image.py <요청문.md> <저장.jpg> --attach a,b"""
import base64, json, os, subprocess, sys, time
sys.path.insert(0, '/Users/talkverse/Hanja/tools'); import grok_cdp as g
g.BASE = 'http://127.0.0.1:' + os.environ.get('GROK_CDP_PORT', '9230')
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
a = sys.argv[1:]; src, dst = a[0], a[1]
att = a[a.index('--attach') + 1] if '--attach' in a else ''
c = g.CDP(g.tab('grok.com')); c.call('Page.navigate', url=os.environ.get('GROK_HOME', 'https://grok.com/')); time.sleep(8)
before = set(c.ev("[...document.querySelectorAll('img')].map(i=>i.src)") or [])
subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_send.py'), src, dst + '.answer.md', '--tab', 'grok.com', '--wait', '90'] + (['--attach', att] if att else []), capture_output=True, text=True)
url = None
for _ in range(80):
    c = g.CDP(g.tab('grok.com'))
    imgs = [s for s in (c.ev("[...document.querySelectorAll('img')].filter(i=>i.src.includes('assets.grok.com')&&i.naturalWidth>=300).map(i=>i.src)") or []) if s not in before]
    busy = c.ev("!![...document.querySelectorAll('button')].find(e=>(e.getAttribute('aria-label')||'').includes('응답 중지'))")
    if imgs and not busy: url = imgs[0]; break
    time.sleep(15)
if not url: print('FAIL 그림 없음', src); sys.exit(1)
d = c.ev("fetch(%s,{credentials:'include'}).then(r=>r.blob()).then(b=>new Promise(ok=>{const f=new FileReader();f.onload=()=>ok(f.result);f.readAsDataURL(b)}))" % json.dumps(url))
open(dst, 'wb').write(base64.b64decode(d.split(',', 1)[1]))
print('OK', dst)
