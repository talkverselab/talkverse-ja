#!/usr/bin/python3
"""골라 둔 편의 반전을 카오스로 조금 고치게 Grok 에 한 편씩 요청한다(답 = data/review/chaos/<id>_grok_chaos.md).
  /usr/bin/python3 tools/grok_chaos_batch.py data/review/chaos/picks.json [--tab project/08a3b12e]"""
import glob, json, os, re, subprocess, sys, time
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
a = sys.argv[1:]
picks = json.load(open(a[0], encoding='utf-8'))
tab = a[a.index('--tab') + 1] if '--tab' in a else 'project/08a3b12e'
TPL = a[a.index('--tpl') + 1] if '--tpl' in a else 'tools/prompts/chaos_grok.md'
KIND = 'boost' if 'boost' in TPL else ('simkung' if 'simkung' in TPL else 'chaos')
tpl = open(os.path.join(ROOT, TPL), encoding='utf-8').read().split('```\n', 1)[1].rsplit('\n```', 1)[0]
for p in picks:
    f = glob.glob(os.path.join(ROOT, f"assets/data/dialogues/R*/*/{p['id']}.json"))[0]
    ep = json.load(open(f, encoding='utf-8'))
    dst = os.path.join(ROOT, 'data/review/chaos', p['id'] + f'_grok_{KIND}.md')
    if os.path.exists(dst) and os.path.getsize(dst) > 200: print('SKIP', p['id'], flush=True); continue
    lines = '\n'.join(f"{t['num']} {t['speaker']}: {t['ja']} / {t['ko']}" for t in ep['turns'])
    cast = ', '.join(f'{k} = {v}' for k, v in ep['speakers'].items()).replace('{name}', '{name}(학습자)')
    pr = (tpl.replace('{tag}', ({'simkung': 'S-', 'boost': 'B-'}.get(KIND, 'C-')) + p['id']).replace('{twist}', str(ep['twist'])).replace('{cast}', cast).replace('{scene}', ep['scene'])
          .replace('{idea}', p['idea']).replace('{n}', str(len(ep['turns']))).replace('{level}', ep['region']).replace('{lines}', lines).replace('{{name}}', '{name}'))
    pf = dst.replace('.md', '_prompt.md'); open(pf, 'w', encoding='utf-8').write(pr)
    r = subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_send.py'), pf, dst, '--tab', tab, '--wait', '600'], capture_output=True, text=True)
    last = (r.stdout.strip().splitlines() or [''])[-1]
    if not last.startswith('OK'): print('STOP', p['id'], last, flush=True); sys.exit(1)
    prev = -1
    for _ in range(40):  # 스트리밍 중 저장 방지 — 턴 수가 차고 길이가 멈출 때까지
        subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_fetch.py'), tab, dst], capture_output=True, text=True)
        txt = open(dst, encoding='utf-8').read()
        n = len(re.findall(r'^\s*\d{1,2}\s*[A-D]\s*[:：]', txt, re.M))
        if n >= len(ep['turns']) and len(txt) == prev: break
        prev = len(txt); time.sleep(15)
    print('OK', p['id'], n, flush=True)
