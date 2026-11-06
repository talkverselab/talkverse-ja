#!/usr/bin/python3
"""감정 계획(data/tts/plan/<편>.json) → PC 2060 작업 파일(vox_jobs.json·moss_jobs.json).
인물 기본 목소리(글 지시) → 같은 목소리로 감정별 참고 음성 → MOSS 가 참고 음성을 따라 문장을 읽는다.
  python3 tools/tts/make_jobs.py <출력폴더> <편id>...   문장 조각 = out/<편>/<turn>_<seg>_<목소리>.wav"""
import json, sys, os
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
V = json.load(open(f'{R}/data/tts/voices.json', encoding='utf-8'))
out, eps = sys.argv[1], sys.argv[2:]
vox, moss, need = [], [], set()
for ep in eps:
    P = json.load(open(f'{R}/data/tts/plan/{ep}.json', encoding='utf-8'))
    for num, segs in P['turns'].items():
        sp = P['speakers'][num] if 'speakers' in P else None
        for si, (emo, text) in enumerate(segs):
            for v in P['cast'][sp]:
                need.add((v, emo))
                moss.append({'out': f'{ep}/{int(num):02d}_{si}_{v}.wav', 'text': text.replace('{name}', P.get('name_sample', '')),
                             'language': 'Japanese', 'reference': f'out/ref/{v}_{emo}.wav'})
for v in sorted({v for v, _ in need}):
    vox.append({'out': f'ref/{v}_base.wav', 'text': V['base_text'], 'instruct': V['voices'][v]['desc']})
for v, e in sorted(need):
    E = V['emotions'][e]
    text = E.get('ref_kansai') if V['voices'][v]['kansai'] else E.get('ref')
    text = text or E.get('ref') or E.get('ref_kansai')
    vox.append({'out': f'ref/{v}_{e}.wav', 'text': text, 'instruct': f"{V['voices'][v]['desc']}, {E['instruct']}", 'reference': f'out/ref/{v}_base.wav'})
json.dump(vox, open(f'{out}/vox_jobs.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
json.dump(moss, open(f'{out}/moss_jobs.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
print(len(vox), 'vox', len(moss), 'moss')
