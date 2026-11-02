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
tpl = open(os.path.join(ROOT, 'tools/prompts/write_grok.md'), encoding='utf-8').read()
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
    p = (tpl.replace('{tag}', 'W' + s['id'].replace('r3_', '').upper()).replace('{cast}', cast).replace('{scene}', s['scene'])
         .replace('{beats}', s['beats']).replace('{targets}', s['targets']).replace('{twist}', str(s['twist']))
         .replace('{register}', REG.get(s['register'], s['register'])).replace('{{name}}', '{name}'))
    pf = os.path.join(out, s['id'] + '_grok_write_prompt.md')
    open(pf, 'w', encoding='utf-8').write(p)
    r = subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_send.py'), pf, dst, '--tab', tab, '--wait', '600'],
                       capture_output=True, text=True)
    last = (r.stdout.strip().splitlines() or [''])[-1]
    print(s['id'], last, flush=True)
    if not last.startswith('OK'):
        print('STOP', s['id'], r.stderr[-400:], flush=True); sys.exit(1)
    # grok_send 는 답이 스트리밍 중일 때 끝났다고 볼 때가 있다(2026-11-03 첫 편 4턴에서 잘림) → 16턴이 되고 길이가 멈출 때까지 다시 받는다
    prev, n = -1, 0
    for _ in range(40):
        f = subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_fetch.py'), tab, dst], capture_output=True, text=True,
                           env=dict(os.environ, GROK_CDP_PORT=os.environ.get('GROK_CDP_PORT', '9230')))
        txt = open(dst, encoding='utf-8').read()
        n = len(re.findall(r'^\s*\d{1,2}\s*[A-C]\s*[:：]', txt, re.M))
        if n >= 16 and len(txt) == prev:
            break
        prev = len(txt)
        time.sleep(15)
    print('   turns', n, len(txt), flush=True)
