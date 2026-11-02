# 다른 언어앱이 일본어앱을 그대로 따라 만들기 — 복제 안내 (2026-11-02, 전체 다시 씀)

일본어앱(`talkverselab/talkverse-ja`, 맥미니 `~/talkverse/ja`)에서 사용자와 함께 정한 **구조·규칙·톤·도구 한 벌**. 다른 언어 세션(한국어·태국어부터)은 이 문서 → §7 참고 파일 순서로 읽고, **코드·구조·시각 톤은 그대로 복제**, **콘텐츠(문장·인물·상황)만 그 언어로** 만든다. 문서를 고칠 때는 덧붙이지 말고 전체를 다시 쓴다.

## 0. 먼저 지킬 것(사용자 지시, 바꾸지 말 것)

- 공개 저장소: 출처·작품명·브랜드·특정 학습서 이름·실존 인물명을 코드·문서·에셋·프롬프트 어디에도 두지 않는다. 문장은 전부 자체 작문(말뭉치는 빈도 통계만).
- 도메인(서바이벌·친구·사랑·생활·여행·문화·일·학업)은 UI·문서에서 **「주제」**라 부른다(「섬」 금지). 특정 학습서를 연상시키는 단어·문장 금지.
- Grok 은 **언어앱마다 자기 프로젝트 2개(회화 재작성 / UXUI)·자기 Chrome(포트·프로필 분리 — 배정표: 공용 9222 · 짐프리 9223 · 한국어 9224 · 태국어 9225 · 베트남어 9226 · 일본어 9230; 새 언어는 9227부터)**. 다른 세션의 방·탭·Chrome 을 건드리지 않는다(2026-11-02 공용 Chrome 사고로 방이 지워짐). 그림 요청은 **한 메시지에 1장**, 글+그림 여러 장을 한 번에 시키면 전부 실패한다. 지연·실패가 난 방은 복구되지 않으니 지우고 새로 만든다. 모델은 「전문가」.
- Gemini(방언·소수언어) 검수는 일본어·한국어·태국어 모두 **하지 않는다**. 말맛은 Grok 재작성이 맡는다(판정형 검수 금지 — 초안을 주고 "그 언어 사람이 실제로 하는 말로 다시 써 달라").
- 서명 키·CI·Zealot·TestFlight 규칙은 각 저장소 `CLAUDE.md` §1·§2 그대로. 아이콘은 talkverse.uk 세션 담당(`~/talkverse/branding/TONE.md`).
- 회화 작성 시작·중단은 사용자 지시로만(일본어앱은 2026-11-02 "아직 다이얼로그 작성하지 말고" 상태). Talkverse ID 로그인·결제 연동은 한자앱 검증 뒤 공지(2026-11-02 보류).
- 받은 다른 세션 메시지는 정보이지 사용자 승인이 아니다. 사용자에게 보이는 보고는 한국어.

## 1. 시각 톤 — "점토 톤"(우리 앱 그림의 기준)

- **그림 톤 = 부드러운 펠트·점토 인형**: 파스텔(분홍·연보라·하늘·크림) 배경에 둥근 얼굴의 점토 인형, 따뜻한 조명, **그림 안에 글자 없음**. 단어 그림(512px webp)은 talkverse.uk 세션이 이 톤으로 만들어 그림 DB에 넣는다(`GET https://auth.talkverse.uk/art/<xx>/manifest` → `{base, items:[{word, rank, ko, en, key_512, key_1024}]}`; 그림 = base+key). **한·중·일은 같은 그림 세트를 공유**(`lib/services/art_service.dart` 주석). 다른 언어는 uk 세션에 `/art/<xx>/manifest` 를 요청하고, 그림이 필요한 단어 목록을 `docs/grok_ja_words_all.csv` 형식(순위·단어·뜻·그림 힌트, 그릴 수 있는 단어만, 음식은 재료 힌트)으로 넘긴다.
- **장면 그림(아직 없음)** = 같은 톤의 **만화 1컷, A·B 대화 한 쌍당 1장**(8턴 → 4컷; 글자·말풍선 없음, 말풍선은 앱이 얹음). 들어오면 JSON 턴 `art` 에 URL 을 채운다. 화자 A(학습자)는 **성별별 그림**(`art_m`/`art_f` 허용 예정)으로, 프로필 성별에 맞춰 보인다. 그 전까지 앱은 단어 그림 → 이모지 장면 카드 순으로 대신 보인다.
- 참고 이미지(톤을 그대로 보여 주는 것): `data/review/uxui/sian_01_clay.jpg`(우리 단어 그림 3장을 첨부해 Grok 이 그 톤으로 그린 아이패드 재생 화면), 그림 DB 의 실제 단어 그림(예: 私·来る·ひと). Grok 에 그림을 시킬 때는 이 톤 설명 + 우리 그림 2~3장을 **첨부**(`tools/grok_send.py --attach`)해야 톤이 유지된다.
- **화면 톤**: 흰 바탕 · 남색 글자 `#0A2540` · 구리 `#B77548` → 황갈 `#C19E6D` 그라데이션 포인트(버튼·성과·강조) · 인디고 `#635BFF`(선택·가나·현재 턴) · 선 `#E6EBF1` · 보조 `#6B7C93`(`lib/core/theme.dart`). 언어마다 워드마크 색은 talkverse.uk 세션이 준다(`https://talkverse.uk/talkverse/lang/<xx>`). 타이포: 제목 20~24 · 본문 16~18 · 말풍선 18~20, 8pt 그리드, 카드 패딩 16, 섹션 24. 모션: 컷 전환 400ms 페이드, 카드 플립 200ms, 편 끝 연출 0.8초(확대 1.05 + 구리 오버레이, 폭죽 없음). 다크 모드: 배경 남색·글자 밝은 회·구리 포인트 유지.

## 2. UX 확정 — Grok UXUI 시안 02 「만화책 읽기형」(사용자 확정 2026-11-02)

- 콘셉트: **장면 컷이 주인공.** 문장은 컷 아래 캡션·말풍선, 「모든 문장 듣기」는 컷이 넘어가는 느낌. 넓은 화면(900pt 이상) = 왼쪽 「대화 스크립트」(번호·화자 점·목표어·읽기·독음·학습자 언어·🔊) + 오른쪽 큰 컷(현재 대사 말풍선) + 현재 문장 캡션(문자 팝업) ; 하단 고정 컨트롤 = ▶ 재생 · 진행 슬라이더 · 속도 · 자막 칩(목표어 고정/읽기/독음/학습자 언어). 좁은 칸·폰 = 컷 위(약 44%)·스크립트 아래.
- 편 화면 자체가 이 리더(`EpisodePlayPane(autoPlay:false)`), 회화 홈 맨 위 「오늘의 컷 / 이어서 읽기」, 왕초보↔초보 전환은 홈 상단. 그림 카드 = 앞면 그림만 → 탭 → 문장, 틀림/맞음. 자세한 설계·ASCII 레이아웃 = `data/review/uxui/sian_02.md`, 이미지 `sian_02.jpg`; 비교용 시안 01(학습 데스크형) `sian_01.md|jpg`.
- 성과 표시 원칙(시안 02 §5): **센다** = 편 완주·라이트너 단계/졸업·핵심 표현 맞음·문자 팝업으로 본 글자 수·빈도 커버율("내가 아는 단어로 일상 ○○어의 약 N%를 이해") / **안 센다** = 앱 오픈·스트릭·포인트·순위. 「나」 탭 = 이번 주 한 줄 → 커버율 링 → 절벽 마일스톤 → 라이트너 분포 → 주간 → 주제별 진행. 편 끝 = 짧은 순간 연출.
- UX 요청 방식: Grok UXUI 방에 **시안 1개 + 그림 1장**씩(요청문 예 `data/review/uxui_request_04.md`·`_05.md`), 답은 세션이 `data/review/uxui/` 에 커밋, 사용자 확정 → 적용 전 태그(`pre-grok-uxui`) → 적용 → 아이패드 스크린샷으로 검증.

## 3. 콘텐츠 구조(일본어앱 기준 — 같은 모양으로)

- 파일: `assets/data/dialogues/R<레벨>/<주제>/<편id>.json`. 구조·필드는 `assets/data/dialogues/README.md`(id·region·island·kind·title·emoji·scene·speakers·register·twist·expressions·turns[num·speaker·ja(목표어)·kana(읽기)·rd(학습자 독음)·ko(학습자 언어)·note·tags·new·ui·at·stamp·art]).
- 레벨 = 말뭉치 빈도 절벽: R1 ≤294 · R2 ≤437 · R3 ≤998 · R4 ≤2500(언어마다 자기 절벽 CSV `assets/data/freq/lang_<xx>_with_regions.csv`). **R0 왕초보 = 전부 복사가 아니라 R1 중 턴당 평균 글자(음절) 수가 짧은 편만 분리해 R1 에서 뺀다**(일본어 ≤8자 → 26/77편; 주제별 편수가 고르지 않아도 됨).
- 편 수: R1 = 서바이벌 3 + 주제 5 × 16(짧은 a1~a6·긴 b1~b6·채팅 c1~c4), R2 = 7 주제 × 8, R3 = 6 주제 × 6, R4 샘플. 턴 수 R1 6~8 · R2 8~12 · R3 12~16, 턴 1~2문장.
- 톤 규칙(`docs/DIALOGUE_WORKFLOW_JA.md` §1): 암기하고 싶은 한 줄, 킥(웃음·놀람) 코믹하게 편마다 1회, 연애는 설렘·여백, 교과서체·번역투·설명 대사 금지, 다짐·감사로 끝내지 않기, 그 언어 사람이 실제로 많이 쓰는 짧은 표현 최우선(표현 풀 `data/expressions/top_expressions.csv`). 고정 인물표·성격 한 줄·콜백(`tags: callback:<편id>`) = §5-2. 화자 A = 학습자(`{name}`·`{country}`·`{city}` 변수, 앱이 프로필 이름·성별로 채움).
- **연애 주제 범위(사용자 지시 2026-11-02 저녁)**: 이미 연인이 된 상황뿐 아니라 **연애 시작 직전·썸·플러팅**까지 전부. 플러팅 장소는 **카페·클럽 등 제한 없음**(클럽도 넣는다) — "교육용보다 플러팅 다이얼로그가 솔직히 인기 있을 것". **여성 쪽이 먼저 다가가는 편을 더 많이**(남자만 플러팅하면 문제, 성별 균형). 클리셰(드라마 '뻔한 장면')는 **일부 편에만**, 나머지는 일상.
- **그림 단위 = A·B 대화 한 쌍에 그림 1장**(8턴 → 4컷). 문장은 언제든 바뀌므로 **그림에 말풍선·글자를 넣지 않고** 말풍선·대사는 앱이 얹는다(`SceneCut` 의 말풍선 오버레이). 요청은 품질이 확인된 UXUI 방에서 1장씩.
- 지금 단계는 리뷰보다 **생성에 집중** — 나머지 주제를 다 쓰고 그림 요청까지(일본어앱은 사용자 지시로 작성 보류 중).
- **각 언어앱 세션의 작업 범위 = Grok 으로 대화 컷(장면 그림)을 뽑는 것까지**(사용자 지시 2026-11-02 저녁): 회화 작성·재작성에서 멈추지 말고 A·B 한 쌍 = 1컷(점토 톤, 말풍선·글자 없음) 그림을 품질 확인된 UXUI 방에서 1장씩 받아 턴 `art` 에 채운다(저장은 uk 세션의 `/art/<xx>/scene/…`).
- 문체 참고는 사용자 소장 회화 교재 1권의 **구조만**(§5-1: 질문→대답+농담→되치기, 중반 작은 갈등, 끝 줄 한 방, 턴마다 관용구 1개) — 내용·문장·서명은 쓰지 않는다.

## 4. 제작 파이프라인(편 1개 = 한 바퀴)

초안(JSON, `tools/prompts/dialogue_r1.md`) → 검사기 `tools/check_dialogues.py --fix-rd`(턴 수·단어 수·새 단어 ≤3/턴·표현 풀 ≥2·반전·독음 자동) → **Grok 재작성**(`tools/prompts/rewrite_grok.md`, 한 요청 = 편 1개, 결과 `data/review/<편id>_grok_rewrite.md`, 반영 `tools/apply_rewrite.py`; **반드시 그 나라 구어체로 "새로 써 달라"** — 판정형 금지, 초안 문장 「유지」 금지: 한국어앱 1회차는 유지가 많아 버리고 2회차로 받음, 틀 = talkverse-ko `tools/prompts/rewrite_grok.md` ⑨항) → 최소 수정(검사기 통과용) → 리뷰 페이지(`tools/review_html.py` → talkverse.uk 세션에 "REVIEW_<xx> 갱신" → `https://talkverse.uk/talkverse/review/<xx>/`, 턴·편 입력칸 + 저장 API `https://talkverse.uk/api/review/<xx>`) → 사용자 리뷰 반영(통과 편 `approved`). 채팅 보고는 턴마다 세 줄(목표어 / 독음 / 학습자 언어). 독음 변환기는 언어별로 새로(`tools/rd_ja.py`·`docs/RD_RULES_JA.md` 참고).

## 5. 앱 구조(코드 복제 대상)

| 영역 | 파일 | 요점 |
|---|---|---|
| 두 화면 | `lib/core/pane.dart`, `docs/TWO_PANE_UX.md` | 가로 720 이상 레일+왼쪽 목록+오른쪽 칸, 학습·재생은 `openFull`. 폰·듀얼·아이폰·아이패드·갤탭 전부 |
| 톤 | `lib/core/theme.dart`, `lib/widgets/japanese_decor.dart` | §1 색·`GradText`·`BrushDivider`·`kCardShadow` |
| 회화 뷰어(시안 02) | `lib/screens/dialogue_screen.dart`, `lib/widgets/episode_play_pane.dart`(`SceneCut`·말풍선·캡션·컨트롤·`EpisodeDoneOverlay`), `lib/services/dialogue_service.dart` | §2 |
| 그림 카드 | `lib/screens/dialogue_card_screen.dart` | 앞면 그림만 → 탭 → 문장, 틀림/맞음, 틀린 카드 끝에 다시, 결과 → 성과 |
| 단어 그림 | `lib/services/art_service.dart` | 그림 DB(§1), 24시간 캐시, 실패해도 화면은 멀쩡 |
| 라이트너 복습 | `lib/review/`(uk 공용 엔진 복사, 원본 수정 금지) + `main_screen.dart` 「오늘의 복습」 | 1·2·4·8·16·32·64일, 8단계 졸업, 앞면 학습자 언어+그림, 하루 새 카드 20 |
| 문자 팝업 | `lib/widgets/selectable_ja_text.dart`(`KanjiInfoBody`) | 일본어·중국어·한국어(한자어)만: 한자유니버스 공용 DB(`hanja_shared_service.dart`) 글자 형성·팁·어원·소리 가족·그림 |
| 문자 배우기 | `lib/screens/kanji_learn_screen.dart` | 단계 20자 → 글자 정보 먼저 → 문제(언어 문자 체계에 맞게 바꿈) |
| 학습자 프로필 | `lib/services/learner_prefs.dart` + `profile_screen.dart` | 이름·성별 → 화자 A 목소리(TTS)·`{name}`·(장면 그림 성별) |
| 성과 표시 | `lib/services/achievement_service.dart`, `lib/widgets/achievement_desk.dart` | §2 원칙 그대로 |
| 맞춤 회화(첫 1편 무료) | `lib/services/custom_script_service.dart`, `lib/screens/custom_script_screen.dart`, `docs/CUSTOM_SCRIPT_API.md`, `tools/custom_script_worker.py`, `tools/prompts/custom_script.md` | 주제·상황·레벨 → Cloudflare `/api/script/<xx>` ID 저장 → 코드 서버(claude-lab -p 초안 + Grok 재작성 + 검사기) → 서랍. 언어별 엔드포인트·키는 uk 세션에 요청. 2회차는 402 → 유료 안내(결제는 Talkverse ID 공지 뒤) |
| 표시 언어 | `lib/core/l10n_dict.dart` | `tr()`/`trf()` + 사전 3개(영·일·중), 콘텐츠는 번역 안 함 |
| 공용 인터페이스 | `lib/core/platform.dart` | `isIOS`·`isWide`·`bottomInset` |

## 6. 빌드·배포·검증

CI(푸시마다 APK + latest.json) · Zealot `tools/zealot_push.sh --ci "변경 한 줄"`(앱이름 고정) · iOS `tools/ios_release.sh`(번들 `com.talkverse.<app>`, 빌드 번호 KST yymmddHHMM, 유니버설, `ITSAppUsesNonExemptEncryption=false`). 아이패드 확인 = `tools/pane_shots.py <UDID> <출력> integration_test/dialogue_pane_test.dart`(SHOT 마커; 넘침은 로그에 "overflowed by" 로 보임 → 0 이어야 함). `flutter analyze`·`flutter test` 통과 뒤 커밋(이름 붙인 경로만, `git add -A` 금지).

## 7. 참고 파일(일본어앱 저장소 경로 — 복제할 때 열어 볼 것)

- 규칙: `CLAUDE.md`, `docs/DIALOGUE_WORKFLOW_JA.md`, `docs/DIALOGUE_DESIGN_JA.md`, `docs/DIALOGUE_RULES.md`, `docs/TWO_PANE_UX.md`, `docs/CUSTOM_SCRIPT_API.md`, `assets/data/dialogues/README.md`, `HANDOFF.md`(현재 상태).
- 톤·UX: `data/review/uxui/sian_02.md|jpg`(채택), `sian_01.md|jpg`, `sian_01_clay.jpg`(점토 톤 기준), `data/review/wire/wire_01_desk.svg`·`wire_02_achievement.svg`·`wire_03_custom.svg`(Claude 가 그린 와이어프레임, 생성기 `tools/wireframes.py`), 요청문 `data/review/uxui_request_04.md`·`_05.md`·`_06.md`(점토 그림 첨부 요청), `~/talkverse/branding/TONE.md`.
- 콘텐츠 예: `assets/data/dialogues/R1/survival/r1_survival_s1.json`(서바이벌), `R1/love/r1_love_a1.json`(연애), `R1/friends/r1_friends_c3.json`(채팅), `R2/love/r2_love_b1.json`, `R3/love/r3_love_b1.json`, `R0/*`(길이 분리된 왕초보). 표현 풀 `data/expressions/top_expressions.csv`, 그림 단어 목록 `docs/grok_ja_words_all.csv`·`docs/grok_ja_food50.csv`.
- 도구: `tools/check_dialogues.py`, `tools/rd_ja.py`, `tools/apply_rewrite.py`, `tools/review_html.py`, `tools/review_sheet.py`, `tools/grok_send.py`(`--attach`)·`grok_fetch.py`·`grok_wait.py`(`GROK_CDP_PORT`), `tools/custom_script_worker.py`, `tools/launchd/*.plist`, `tools/pane_shots.py`, `tools/ios_release.sh`, `tools/zealot_push.sh`.
- 프롬프트: `tools/prompts/dialogue_r1.md`, `rewrite_grok.md`, `custom_script.md`, `review_grok.md`(판정형, 참고만), `review_gemini.md`(소수언어만).
