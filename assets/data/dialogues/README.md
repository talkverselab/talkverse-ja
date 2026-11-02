# 회화 데이터 구조 (talkverse-ja) — 2026-11-03

```
assets/data/dialogues/
  R0/<주제>/r0_<주제>_<편>.json   왕초보 — R1 중 턴당 평균 8자 이하인 짧은 편 26(2026-11-02 길이 기준 재분배, R1 에서 제거). 앱 기본은 R1, "너무 힘들면 왕초보" 전환
  R1/<주제>/r1_<주제>_<편>.json   초보(기본). 서바이벌 3 + 주제 5개 × 16편(a1~a6 짧은·b1~b6 긴·c1~c4 채팅), 6~8턴
  R2/<주제>/r2_<주제>_<편>.json   중급. 주제 7개 × 8편(b1~b8), 8~12턴
  R3/<주제>/r3_<주제>_<편>.json   고급. 주제 7개 × 6편, 12~16턴
  R4/<주제>/r4_<주제>_<편>.json   최상급. 12~16턴, 복문·완곡 표현 (샘플 1편)
```
주제(island) = 도메인: survival · friends · love · life · travel · culture · work · study.
레벨 R1~R4 = 말뭉치 빈도 절벽 구간(단어 순위 ≤294 / ≤437 / ≤998 / ≤2500). 고정 인물·콜백·규칙은 `docs/DIALOGUE_WORKFLOW_JA.md`.

## 편 JSON
```json
{"id":"r1_friends_a1","region":"R1","island":"friends","kind":"short|long|chat|survival",
 "title":"...","emoji":"☕","scene":"장면 한 줄","speakers":{"A":"{name}","B":"ユカ"},
 "register":"polite|casual|chat|mixed","twist":3,"flags":[],"purpose":[...],"domain":[...],
 "goal":"학습 목표","expressions":["표현 풀에서 노출된 것"],
 "turns":[{"num":1,"speaker":"B","ja":"일본어","kana":"가나 읽기","rd":"한글 독음","ko":"한국어",
           "note":"턴 핵심 한 줄","tags":["expr:〜","form:〜","callback:<편id>"],"new":["새 단어"],
           "ui":"bubble","at":"21:03","stamp":"😂"}],
 "review":{"grok_rewrite":"...","final":"..."},"approved":"날짜(통과 시)"}
```
A = 학습자(국적·이름 비고정, `{name}` `{country}` `{city}` `{lang}` 등 변수). `callback:` 태그는 앞 편 대사를 되살린 줄.
검사기 `tools/check_dialogues.py --fix-rd`, 독음 변환 `tools/rd_ja.py`, 리뷰 페이지 `tools/review_html.py` → https://talkverse.uk/talkverse/review/ja/
