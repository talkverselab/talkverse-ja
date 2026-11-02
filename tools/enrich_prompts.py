#!/usr/bin/env python3
"""강화 재작성 프롬프트 생성: python tools/enrich_prompts.py <시작코드번호> <편id>... → data/review/<id>_grok_enrich_prompt.md"""
import json, re, sys, glob
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
tpl = open(ROOT / 'tools/prompts/rewrite_grok_v2.md', encoding='utf-8').read().split('```')[1].strip() + '\n'
REG = {'polite': '정중체(です·ます)', 'casual': '친구·연인 반말', 'chat': '채팅 반말·줄임(w·〜 그대로)', 'mixed': '정중체와 반말 혼합(장면에 맞게)'}
TARGET = {'R1': 13, 'R2': 18, 'R3': 22}
files = {Path(f).stem: f for f in glob.glob(str(ROOT / 'assets/data/dialogues/R*/*/*.json'))}
n = int(sys.argv[1])
for i, eid in enumerate(sys.argv[2:]):
    ep = json.load(open(files[eid], encoding='utf-8'))
    chars = [len(re.sub(r'[（(].*?[)）]', '', t['ja'])) for t in ep['turns']]
    avg = round(sum(chars) / len(chars), 1)
    vars_ = sorted(set(re.findall(r'\{[a-z_]+\}', json.dumps(ep, ensure_ascii=False))))
    roles = '화자 A = 외국인 학습자(국적 비고정; ' + '·'.join(vars_) + ' 는 나중에 치환되는 변수이니 그대로 둘 것), ' + ', '.join(f'{k} = {v}' for k, v in ep['speakers'].items() if k != 'A') + '.'
    lines = '\n'.join(f"{t['num']} {t['speaker']}: {t['ja']} / {t['ko']}" for t in ep['turns'])
    pr = tpl.format(code=f'E{n + i:03d}', roles=roles, scene=ep['scene'], register=REG.get(ep.get('register'), ep.get('register')), avg_chars=avg,
                    target_chars=TARGET.get(ep['region'], 15), targets='·'.join(ep.get('expressions', [])[:4]), lines=lines)
    (ROOT / f"data/review/{eid}_grok_enrich_prompt.md").write_text(pr, encoding='utf-8')
print('ok', len(sys.argv) - 2)
