#!/usr/bin/python3
"""편 설계 JSON 을 읽어 편마다 Grok 작성 요청을 보내고 답을 저장한다(한 요청 = 편 1개, 순서대로).
  /usr/bin/python3 tools/grok_write_batch.py data/review/write/specs_r3.json [--only id1,id2] [--tab project/08a3b12e]
이미 답 파일이 있는 편은 건너뛴다. 한도(LIMIT)·실패면 멈추고 그 줄을 출력한다."""
import json, os, re, subprocess, sys, time
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
a = sys.argv[1:]
specs = json.load(open(a[0], encoding='utf-8'))
only = set(a[a.index('--only') + 1].split(',')) if '--only' in a else None
tab = a[a.index('--tab') + 1] if '--tab' in a else 'project/08a3b12e'
TPL = a[a.index('--tpl') + 1] if '--tpl' in a else 'tools/prompts/write_grok.md'
tpl = open(os.path.join(ROOT, TPL), encoding='utf-8').read()
tpl = tpl.split('```\n', 1)[1].rsplit('\n```', 1)[0]
REG = {'casual': '친구·연인 반말', 'polite': '직장·낯선 사이 です・ます(경어)', 'mixed': '인물에 따라 반말·경어 섞임'}
out = os.path.join(ROOT, 'data/review/write')
for i, s in enumerate(specs, 1):
    if only and s['id'] not in only:
        continue
    dst = os.path.join(out, s['id'] + '_grok_write.md')
    if os.path.exists(dst) and os.path.getsize(dst) > 200:
        print('SKIP', s['id'], flush=True); continue
    cast = ', '.join(f'{k} = {v}' for k, v in s['speakers'].items()).replace('{name}', '{name}(학습자)')
    reg = s.get('region', 'R3')
    nt = {'R0': 6, 'R1': 8, 'R2': 12}.get(reg, 16)
    TW = {'chaos': '카오스', 'slip': '말실수·오해', 'reveal': '의외 사실', 'emotion': '감정', 'ignore': '읽씹'}
    p = (tpl.replace('{levelko}', {'R0': '왕초보(R0)', 'R1': '초보(R1)'}.get(reg, reg)).replace('{nturns}', str(nt))
         .replace('{lenrule}', '한 턴은 8자 안팎의 아주 짧은 말(단어 1~3개)' if reg == 'R0' else '한 턴 1~2문장, 쉬운 일상 단어(상위 300~500 수준)')
         .replace('{twistko}', TW.get(s.get('twist_type', ''), '의외'))
         .replace('{simkung}', str(s.get('simkung_turn', '')))
         .replace('{tag}', 'W' + s['id'].upper()).replace('{cast}', cast).replace('{scene}', s['scene'])
         .replace('{beats}', s['beats']).replace('{targets}', s['targets']).replace('{twist}', str(s['twist']))
         .replace('{register}', REG.get(s['register'], s['register'])).replace('{{name}}', '{name}'))
    pf = os.path.join(out, s['id'] + '_grok_write_prompt.md')
    open(pf, 'w', encoding='utf-8').write(p)
    # 편마다 새 대화(긴 대화에서 Grok 이 한국어를 빼고 대충 씀 — 2026-11-03)
    sys.path.insert(0, '/Users/talkverse/Hanja/tools'); import grok_cdp as g
    g.BASE = 'http://127.0.0.1:' + os.environ.get('GROK_CDP_PORT', '9230')
    _c = g.CDP(g.tab(tab)); _c.call('Page.navigate', url='https://grok.com/project/08a3b12e-5761-4a2b-a074-daa6902fd222'); time.sleep(8)
    def send():
        r = subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_send.py'), pf, dst, '--tab', tab, '--wait', '90'],
                           capture_output=True, text=True)
        return (r.stdout.strip().splitlines() or [''])[-1], r.stderr
    last, err = send()
    if not last.startswith('OK') and not last.startswith('LIMIT'):
        # TIMEOUT·NOINPUT: 답이 화면에 와 있으면 받고, 없으면 프로젝트 첫 화면으로 새로 열어 한 번 더(2026-11-03 여러 번)
        subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_fetch.py'), tab, dst], capture_output=True, text=True)
        got = os.path.exists(dst) and len(re.findall(r'^\s*\d{1,2}\s*[A-D]\s*[:：].*/', open(dst, encoding='utf-8').read(), re.M)) >= nt
        if got:
            last = 'OK(fetched)'
        else:
            sys.path.insert(0, '/Users/talkverse/Hanja/tools'); import grok_cdp as g
            g.BASE = 'http://127.0.0.1:' + os.environ.get('GROK_CDP_PORT', '9230')
            c = g.CDP(g.tab(tab)); c.call('Page.navigate', url='https://grok.com/' + tab if tab.count('-') >= 4 else 'https://grok.com/project/08a3b12e-5761-4a2b-a074-daa6902fd222'); time.sleep(10)
            last, err = send()
    print(s['id'], last, flush=True)
    if not last.startswith('OK'):
        print('STOP', s['id'], err[-400:], flush=True); sys.exit(1)
    # grok_send 는 답이 스트리밍 중일 때 끝났다고 볼 때가 있다(2026-11-03 첫 편 4턴에서 잘림) → 16턴이 되고 길이가 멈출 때까지 다시 받는다
    prev, n = -1, 0
    for _ in range(40):
        f = subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_fetch.py'), tab, dst], capture_output=True, text=True,
                           env=dict(os.environ, GROK_CDP_PORT=os.environ.get('GROK_CDP_PORT', '9230')))
        txt = open(dst, encoding='utf-8').read()
        n = len(re.findall(r'^\s*\d{1,2}\s*[A-D]\s*[:：].*/', txt, re.M))
        if n >= nt and len(txt) == prev:
            break
        prev = len(txt)
        time.sleep(15)
    print('   turns', n, len(txt), flush=True)
