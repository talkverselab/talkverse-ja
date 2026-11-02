#!/usr/bin/env python3
"""편 JSON → Grok/Gemini 검수 프롬프트 파일 생성.  python tools/review_prompts.py <편.json> <회차번호>
→ data/review/<id>_grok_prompt.md, <id>_gemini_prompt.md"""
import json, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
GROK = """[{code}] 아래는 일본어 학습 앱의 회화 1편입니다. {roles} 장면: {scene}. 말투: {register}. 학습 목표: {goal}
당신은 지금 실제 일본 사람들이 {where} 에서 쓰는 말을 가장 잘 아는 검수자입니다. **고치지 말고 지적만** 하세요. 각 줄은 「일본어 / 한국어 번역」 쌍입니다.
① 각 줄마다: 줄 번호 · 판정(이상 없음 / 부자연 / 실제 안 씀 / AI티(교과서체·번역투·과한 설명) / 말투 불일치 / 요즘 안 씀 / 번역 어긋남) · 이유 한 줄 · 더 자연스러운 대안 1개(일본어 + 한국어 뜻, 이상 없음이면 생략). "이상 없음"도 왜 자연스러운지 한 줄.
② 편 전체: 자연스러움 점수(10점 만점)와 한 줄 이유 · 반전(턴 {twist})이 재미있는지, 실제로 일어날 법한지 · 이 장면에서 일본 사람이 진짜 많이 쓰는데 빠진 짧은 표현 3개(일본어 + 한국어 뜻 + 어느 줄에 넣으면 좋은지).
③ 종류별 개수 표. 답은 한국어로.

{lines}
"""
GEM = """[{code}] 아래는 일본어 학습 앱의 회화 1편(도쿄 표준어 기준). {roles} 장면: {scene}. 말투: {register}. 각 줄은 「일본어 / 한국어 번역」 쌍입니다.
당신은 일본의 방언·소수언어 전문 검수자입니다. 고치지 말고, 방언·소수언어 관점에서만 답해 주세요.
① 이 편의 대사 가운데 특정 지역 말(간사이·규슈·도호쿠·홋카이도·오키나와 등)로 들리거나 지역에 따라 뜻·어감이 달라지는 줄이 있으면 줄 번호와 이유. 없으면 "없음".
② 이 편을 간사이 말투로 바꾼다면 달라질 줄 번호와 바뀌는 어미·단어만(대사 전체는 쓰지 말 것). 규슈(하카타)·오키나와(우치나구치) 도 같은 방식으로 각 1~2줄 예.
③ 외국인 학습자가 이 대사를 도쿄 밖 지방 가게에서 그대로 썼을 때 오해·위화감이 생길 줄이 있으면 번호와 이유.
④ 소수언어(아이누어·류큐 제어)에 이 장면과 맞닿는 표현·관습이 있으면 한 줄(없으면 생략).
답은 한국어로, 간결하게.

{lines}
"""
REG = {'polite': '정중체(です·ます)', 'casual': '친구 반말', 'chat': '채팅 반말·줄임', 'mixed': '정중체에 반말 섞임'}
def main():
    ep = json.load(open(sys.argv[1], encoding='utf-8')); n = int(sys.argv[2])
    sp = ep['speakers']
    roles = '화자 A = 외국인 학습자(국적 비고정, {name}·{country}·{city} 는 나중에 학습자 정보로 바뀌는 변수이니 그대로 두고 판단), ' + ', '.join(f'{k} = {v}' for k, v in sp.items() if k != 'A') + '.'
    lines = '\n'.join(f"{t['num']} {t['speaker']}: {t['ja']} / {t['ko']}" for t in ep['turns'])
    ctx = dict(roles=roles, scene=ep['scene'], register=REG.get(ep.get('register'), ep.get('register')), goal=ep.get('goal', '이 장면에서 실제로 쓰는 짧은 표현을 몸에 익히기'), where=ep.get('where', '가게·X·LINE'), twist=ep.get('twist'), lines=lines)
    out = ROOT / 'data/review'; out.mkdir(exist_ok=True)
    (out / f"{ep['id']}_grok_prompt.md").write_text(GROK.format(code=f'J{n:02d}', **ctx), encoding='utf-8')
    (out / f"{ep['id']}_gemini_prompt.md").write_text(GEM.format(code=f'G{n:02d}', **ctx), encoding='utf-8')
    print(out / f"{ep['id']}_grok_prompt.md"); print(out / f"{ep['id']}_gemini_prompt.md")
if __name__ == '__main__':
    main()
