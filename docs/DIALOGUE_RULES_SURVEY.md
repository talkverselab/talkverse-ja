# 언어앱 회화(다이얼로그) 작성 규칙 조사 — 2026-11-02

사용자 지시: "각 세션의 다이얼로그 메모를 일본어 세션에 모아 요약하고, 서로 충돌하는 것을 모아 하나씩 질문해 원칙을 만든다."
회신 19개(zh ko vi th id es fa fr hi de pt it tr hu mn ar ru en my). 원본 메모 경로는 §3. 옛 공용 원칙 마스터(2026-05-15, VI 기준) 사본 = `data/notes/rule_dialogue_principles.md`(원본 `talkverse-lab/_shared/dialogue_principles.md` 는 옛 PC OneDrive — 맥에 없음).

## 1. 앱별 한눈에

| 앱 | 규칙 문서 | 인물·관계 | 구조·분량 | 말투 | 표기 칸 | 구간(R)·문법 순서 | 검수 |
|---|---|---|---|---|---|---|---|
| **zh** | PORTING_GUIDE §1 + `_meta.json`(원칙 원본은 OneDrive, 맥에 없음) | A Mark(외국인 남)·B Lily(중국 여), L2 소그룹·L3 가족·L4 매편 다른 남녀 | L1 매칭 서사·L2 메신저 카오스·L3 사랑·L4 플러팅, **8턴 고정** 129편 1,032턴 | 반말·캐주얼, 어기조사 13종 L1 풀노출 | zh·pinyin·ko·note·tags, 앱에서 병음→한글 독음 토글 | 한자 209 게이트, HSK4 상한; R 과 L 1:1 아님 | 5-way 병렬 검수 + 자동 7항목 |
| **ja** | 옛 마스터 사본 + CLAUDE.md §4 | A 민준(한국 남)·B 사쿠라(일본 여), 시부야 | L1 스토리 5편(ep1 40턴만)·L2 카오스 챗·L3 사랑 계획 | 정중체 기본(ます) | ja·kana·romaji·ko·note | 절벽 R1~R4 는 단어·한자 순서에만 | 자동 검산만 |
| **ko** | 없음(시드 `assets/seed/*.json`) | 학습자 "Visitor" + 역할명(Barista·Driver…), 이름은 Minjun 하나 | 서울 생활 8장면 55턴, 6~8턴 | **95% 존댓말** | ko·romanization·**en_gloss·learner_note_en(설명 전부 영어)** + 글자 오프셋 주석 | difficulty 1~2뿐, R 미연결 | 없음 |
| **vi** | ★ `corpus/analysis_vi/vi_R1_R4_design.md`, corpus/HANDOFF.md, build_*.py docstring | A 민수(anh, 남)·B 린(em, 여) **anh→em 고정**(데이팅) | **R1 기초 10세트·R2 데이팅 50세트·플러팅 10세트, 1세트 8줄**, 세트끼리 안 이어짐, R2 마지막 줄 반전(막장) | A 반말·B Dạ+존댓말 혼용 | vi·ko·read(한글 독음, 남부)·targets; R2 에 read 없음 | 축 = 호칭+종결사(상위 10), R1 ≥3음절 | 원어민 0, 자체 |
| **th** | ★ `drafts/script_engine/00_DESIGN.md` 외 | 학습자 민호/민지 + 현지인, **성별판 4종**(mf·fm·mm·ff) | **8턴 고정**, 무대 8×욕구 4×레벨 3(beg·mid·adv) 전 칸, 회차 #2·#3 떡밥 | 공손/반말은 질문 답으로 선택 | th·한글 독음·ko·노트(로마자 금지, 외국어 UI 만 로마자) | 초급 문법 1군 전부·2군 반·3군 금지, 독음 20음절 이하; R 과 미연결 | REVIEW*.md 체크박스, 원어민 전 |
| **id** | README「콘텐츠 schema(zh v4)」·`_meta.json` | A Mark(외국인 남)·B Sari(여), 매칭앱 | zh v4 이식: L1 5ep×40턴(80턴만)·L2·L3 미작성 | 표준어+자카르타 구어, saya/kamu | id·**ms(말레이 변이)**·ko·gloss·note·tags, 독음 없음 | 접사 중심, 순서표 없음 | 없음 |
| **es** | 없음(`_meta.json`·README) | A Minjun·B Lucía(es-ES, vosotros) | L1 매칭 5편×40턴 목표(ep1 20턴만), L2·L3 각 300 목표 | tú 반말 | es·ko·note·tags, **rd 없음** | 기능어 12개 먼저; R 미연결 | 없음 |
| **키트 7종** fa fr hi de pt it tr hu | `_update_kit/content/<lang>.py` + `build_content.py`, CLAUDE.md「화면 구성」·§4 | A Minjun(한국 남)·B 현지 여(Sara·Camille·Priya·Lena·Inês·Giulia·Elif·Anna), 언어교환 앱 → 친구/설렘 | **5편×8턴 = 40턴**(첫 인사·카페·길 묻기·약속·감정), L1 만 | 처음부터 반말(tu/du/तुम/sen/te), 낯선 사람만 존칭 | tl(칸 이름 `es`)·**rd 한글 독음**·ko·note "x = 뜻" | 없음(편마다 메모 1개) | 없음(원어민 0) |
| **mn** | `db/notes/mn_ko_transcription.md`(독음 SOT)+normalize_pron.py, 제미나이 검수 스크립트 | A 민(한국 남)·B 사라(여), 게스트하우스 | L1 2편×8턴(16턴, 옛 판 200턴) | 첫 만남 존대(Та)→반말(Чи) | es(키릴)·rd·ko·note·tags, 음성 Azure 사전 합성 | 빈도 build_corpus | 제미나이 "지적만" + 실사용 검증 |
| **ar** | 없음(옛 앱 기계 이관) | A 아흐마드(한국 남)·B 파티마(이집트 여) | 7편 77턴(2~19턴 들쭉날쭉) | 규칙 없음(성별 활용 섞임) | ar(타슈킬 없음)·rd·ko | Top500~5000 코스 배분만 | 없음 |
| **ru** | ★ `notes/00_strategy/curriculum_decisions.md` | A Daniel(한국 남)·B 현지인(이름 없음), 챗앱 | 18편×8턴, **편마다 반전 1회** | ты 반말 | ru(강세 부호)·rd·ko·note·tags | R1·R3 격 시연 우선, R2 채팅체, R1 3단어 이상 | 없음 |
| **en** | — | — | 유튜브 자막 듣기 앱, 회화 생성 없음 | — | — | — | — |
| **my** | — | 미착수 | — | — | — | — | — |

공통으로 지켜진 것(충돌 없음): ① 공개 저장소 — 출처·작품명·원문 금지, 문장 자체 제작, 빈도 통계만 사용 ② 한국 화자 한정(한국어 직관) ③ 화자 A=학습자·B=현지인 2인 기본 ④ 생성은 Claude 세션이 직접(프롬프트 파일 없음) ⑤ 원어민 검수 0건(th·zh 만 체크표/병렬 검수).

## 2. 충돌·결정 필요 항목 (사용자에게 하나씩 질문)

| # | 쟁점 | 지금 상태 | 선택지 |
|---|---|---|---|
| Q1 | **턴 수** | 8턴 고정(zh·th·키트·ru·vi·mn) vs 40턴 에피소드(ja·es·id, 옛 마스터) vs 6~8(ko) vs 들쭉날쭉(ar) | ① 8턴 고정 ② 레벨/구간별(초급 6~8·중급 8~12·고급 12~16) ③ 40턴 에피소드 유지 |
| Q2 | **서사(주제) 축** | 연애·데이팅(zh L1·L3·L4, vi, es, id, 키트 7종 설렘, 옛 마스터) vs 생활·여행 장면(ko·ar·th 무대 8) vs 학습목적×도메인(LEARNER_PROFILE 9×7) | ① 학습목적×도메인 축으로 통일(연애는 `love` 도메인 하나) ② 연애 서사 유지 + 도메인 추가 |
| Q3 | **구간(R1~R4)과 레벨(L1~L4) 관계** | vi 만 R 기준, zh·ja·es·id 는 L 서사 기준, 키트는 L1 만, th 는 beg/mid/adv | ① R 로 통일(L 폐지) ② L=서사·R=어휘 상한(지금 zh 식) ③ 3단(초·중·고)=R1 / R2 / R3+R4 |
| Q4 | **말투 기본값** | 반말 기본(키트·zh·es·ru·hu 처음부터) vs 존댓말 기본(ko 95%, ja ます, mn 첫 만남 존대→반말, th 선택) vs de·fr 지적(가게·낯선 사람은 Sie/vous 가 맞음) | ① 첫 만남·거래 장면 존댓말 → 친해지면 반말(관계 진행형) ② 학습자가 선택(th 식 질문) ③ 반말 고정 |
| Q5 | **학습자 성별·화자 구성** | 남 학습자 고정(거의 전부, vi anh→em, hi 동사 성별, ar 2인칭 성별, th 성별판 4종) | ① 남 고정 유지 ② 성별 선택 → 성 활용 언어(th·hi·ar·vi)만 성별판 생성 ③ 전 언어 성별판 |
| Q6 | **읽기 표기** | 한글 독음 rd(키트·vi·th·mn·ar·ru) vs 로마자(ko·ja romaji) vs 둘 다 없음(es·id) vs 병음→한글 토글(zh) | ① 한글 독음 필수 + 로마자/병음는 보조 ② 라틴 문자 언어(es·id·키트)는 독음 생략 |
| Q7 | **번역·설명 언어** | 한국어(대부분) vs 영어(ko 앱 전부 영어) vs 표시 언어 4종 문제(zh note 한국어뿐) | ① 콘텐츠 설명은 한국어 고정(표시 언어는 UI 만) ② ko 앱은 영어권 대상이므로 예외 |
| Q8 | **반전 규칙** | 편마다 반전 1회 필수(옛 마스터·ru, vi R2 막장 반전) vs 없음(키트·ko·th) | ① 모든 편 1회 ② 중급 이상만 ③ 없음 |
| Q9 | **한 턴 길이** | 3~8단어(키트)·평균 5~6단어(es·id)·독음 20음절 이하(th)·R1 3단어 이상(ru·vi) | ① 초급 3~8단어/20음절, 중급 ≤12, 고급 제한 없음 ② 언어별 |
| Q10 | **검수 절차** | 없음(대부분) vs th 체크표 vs zh 5-way + 자동 vs mn 제미나이 | ① 공통: 자동 검사(길이·구간 어휘 초과·호칭 일관) + 모델 교차 검수(지적만) + 원어민 검수 전 "초안" 표시 ② 앱별 |
| Q11 | **방언·변이** | vi 남부, ar 이집트 구어, pt 유럽, es 카스티야, zh 북방(남방 초안), id+ms 필드, mn 할흐 | ① 앱마다 기본 변이 하나 고정 + 변이 필드(id 의 ms 식) ② 기본 하나만 |
| Q12 | **수위(연애·카오스)** | th flags(alcohol·profanity_mild·jealousy·haggle), vi 막장, zh 카오스 14종, 옛 마스터 윤리 가드레일 | ① 공통 flags 로 필터 + 성적 묘사·불법·미성년 금지 ② 연애 수위는 학습자 질문(th heat) |
| Q13 | **스키마 칸 이름** | 키트 `es`(스페인어 흔적), vi `read`, 키트 `rd`, 보조 `note/targets/tags`, ko 오프셋 주석 | ① 공통: tl·rd·ko·note·tags(+variant 필드) 로 통일, 키트·ko 개명 |
| Q14 | **원칙 문서 위치** | 옛 원본 OneDrive(세션이 못 읽음) | ① 각 repo `docs/DIALOGUE_RULES.md` 로 복사(공개 저장소 규칙 준수) ② 공용 `~/talkverse/branding/` 옆 한 곳 |

## 3. 원본 경로 (M6)

- zh: `~/talkverse/zh/docs/PORTING_GUIDE_2026-09.md` §1-1·1-2·1-6, `assets/data/dialogues/north/_meta.json`·L1~L4.json 머리, `tool/split_dialogues_8.py`, `data/scripts/22_dialog_audit.py`
- ko: `~/talkverse/ko/assets/seed/{scenarios,turns,annotations}.json`, `tools/extract/subcorpus_scan.py`
- vi: `~/talkverse/vi/corpus/analysis_vi/vi_R1_R4_design.md`, `corpus/HANDOFF.md`, `corpus/analysis_vi/r2_chats_draft.md`, `vi_particle_ko_translation.md`, `_archive_old_db/content/README.md`, `tool/build_*_dialogues.py`
- th: `~/talkverse/th/drafts/script_engine/00_DESIGN.md`, `01_DOMAINS_RESEARCH.md`, `02_BEGINNER_GRAMMAR.md`, `REVIEW*.md`, `variants.py`, `build_scripts.py`, CLAUDE.md §7·7-1
- id: `~/talkverse/id/README.md`, `assets/data/dialogues/{id,ms}/_meta.json`, `HANDOFF.md`
- es: `~/talkverse/es/assets/data/dialogues/_meta.json`·L1.json, README.md
- 키트: `~/talkverse/_update_kit/content/{fa,fr,hi,de,pt,it,tr,hu}.py`, `build_content.py`, 각 앱 CLAUDE.md「화면 구성」·§4
- mn: `~/talkverse/mn/db/notes/mn_ko_transcription.md`, `scripts/normalize_pron.py`, `scripts/make_gemini_prompts.py`, `verify_*.py`
- ar: `~/talkverse/ar/app/assets/data/dialogues/L1.json`, `_update_kit/migrate_content.py` 181~238
- ru: `~/talkverse/ru/notes/00_strategy/curriculum_decisions.md`, `corpus_choice.md`, `01_grammar/r1_case_system.md`
- ja: `~/talkverse/ja/data/notes/rule_dialogue_principles.md`(옛 마스터 사본), `content-spec.md`, `rule_corpus.md`
- 잔재(공통 수정 필요): 키트·mn·ru·pt·tr·hu 홈 `¡Hola!`·`PRINCIPIANTE 1`·`Minjun & Lucía`, `_meta.json lang "de"`, 칸 이름 `es`, 메뉴「성·수」「발음(rr·ñ)」.
