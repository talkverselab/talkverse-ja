# 회화 작성 프롬프트 — R1 (이 세션이 편을 쓸 때 따르는 규칙, 2026-11-02)

설계 원본 `docs/DIALOGUE_DESIGN_JA.md`, 공통 원칙 https://talkverse.uk/talkverse/dialogue-rules/ . 아래는 편 하나를 쓸 때의 체크리스트다.

## 입력
- 편 id(`r1_<주제>_<a|b|c><n>` / `r1_survival_s<n>`), 주제, 종류(short/long/chat/survival), 장면 한 줄, 상대 B(주제 고정 인물), 노출할 표현 풀 2~4개(§1 분배표에서), 앞 편의 누적 어휘(검사기 `--dump-vocab`), 반전 종류 1개.

## 쓰기 규칙
1. **최우선**: 일본 사람이 지금 실제로 쓰는 짧은 구어·채팅 표현을 편에 2개 이상, 자연스럽게 맞장구·추임새로. 교과서체·번역투 금지. 설명하듯 말하지 말 것(AI 티).
2. A = 학습자, 국적·이름 고정 금지 — `{name}`·`{country}`·`{city}`·`{lang}` 만. 본문에 특정 나라 대사 금지.
3. 턴 수: survival 6 · short 6~8 · long 6~8 · chat 6~8. 단어 수: short/survival 2~5 · long 3~8 · chat 1~5. R1 1단어 단답 금지(chat 제외). 독음 20음절 이하.
4. 새 단어 턴당 ≤3(표현 풀·변수 제외), 턴의 절반 이상이 앞 편 단어를 다시 씀, 단어는 R1 누적 목록 안(벗어나면 편당 1개, note 에 뜻).
5. 말투: 낯선 사이·가게 = です·ます, 친구 = 반말(a4 전환 편 이후), 채팅 = 반말+줄임. ko 번역도 같은 말투.
6. 반전 1회(말실수+정정 / 읽씹 / 갑작스러운 감정 / 의외 사실 / 카오스) → `twist` 턴 번호. 수위 iOS 12+(`flags`).
7. 메타 표현(もう一回·〜って何?·わかんない 등) 턴은 survival 외엔 편당 ≤1.
8. 채팅 편: 턴에 `"ui": "bubble"`, 스탬프·이모지 1~2개(`"stamp": "😂"`), 읽씹은 `"read": false`, 시간 표시 `"at": "23:12"`.
9. note = 그 턴의 핵심 하나 "X = 뜻"(한국어), tags = 문법 포인트(`particle:は`·`form:て`·`expr:マジで`), `new` = 이 턴에서 처음 나온 단어(기본형).
10. 출처·작품명·원문 금지, 전부 자체 작문. 실존 브랜드는 최소.

## 출력 형식 (JSON, 파일 `assets/data/dialogues/R1/<주제>/<id>.json`)
```json
{"id":"r1_friends_a1","region":"R1","island":"friends","kind":"chat",
 "purpose":["making_friends"],"domain":["friends"],
 "title":"매칭됐다!","emoji":"📱","scene":"언어교환 앱에서 매칭된 첫 메시지",
 "speakers":{"A":"{name}","B":"ユカ"},"register":"chat","twist":5,"flags":[],
 "expressions":["はじめまして","よろしく","マジで?","いいね"],
 "turns":[{"num":1,"speaker":"B","ja":"はじめまして！ユカです。","kana":"はじめまして！ゆかです。","rd":"","ko":"처음 뵙겠습니다! 유카예요.","note":"はじめまして = 첫인사","tags":["expr:はじめまして"],"new":["はじめまして"],"ui":"bubble","at":"21:03"}]}
```
rd 는 비워 두고 `python tools/check_dialogues.py --fix-rd <파일>` 로 채운 뒤, 틀린 곳만 손으로 고치고 `rd_manual: true`.

## 쓴 뒤
`tools/check_dialogues.py` 통과 → Grok 검수(`tools/prompts/review_grok.md`) → Gemini 검수(`review_gemini.md`) → 이 세션 최종 → `draft` 유지.
