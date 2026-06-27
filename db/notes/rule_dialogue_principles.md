---
title: Talkverse Dialogue 작성 원칙 마스터
description: L1-L4 표준 + 톤·어기조사·호칭·윤리·검수 원칙 종합. 22 flavor 콘텐츠 룸 공용 SOT. VI = canonical reference.
generated: 2026-05-15
canonical_reference: vi
levels: [L1, L2, L3, L4]
deprecated_levels: [L5, L6]
sources:
  - talkverse-learning-flavors/docs/00-playbook.md
  - talkverse-learning-flavors/docs/_share_dialogue_writing_master.md
  - talkverse-learning-flavors/docs/_share_minority_language_briefing.md
  - talkverse-learning-flavors/docs/_grammar_planning.md
  - talkverse-lab/vi/MD/l1_v2_migration_2026-05-13.md
  - talkverse-lab/vi/MD/l2_v2_migration_2026-05-13.md
  - talkverse-lab/vi/vi_l2_workflow_v2.md
  - talkverse-lab/vi/MD/vi_l3_workflow.md
  - talkverse-lab/vi/MD/conv200_v2_review_brief.md
---

# Talkverse Dialogue 작성 원칙 마스터

> **목적**: 22 flavor 콘텐츠 룸 (vi · th · ru · mn · ms · my · lo · id · es · de · fr · pt · zh · ja · ar · fa · kk · tr · pl · hi · uzb · amh · ita) 어느 방이든 같은 원칙으로 dialogue 작성 가능하게 함.
>
> **위치**: `talkverse-lab/_shared/dialogue_principles.md` — 콘텐츠 룸 공통.
> 코드 산출물 정책은 `talkverse-learning-flavors/docs/_share_dialogue_writing_master.md` SOT.
>
> **읽는 사람**: 신규 언어 룸 진입 사용자 + AI 어시스턴트 + 검수자 (Claude/Gemini/GPT). 엔지니어·기획자 둘 다.

---

## 목차

1. [핵심 철학 5 원칙](#1-핵심-철학-5-원칙)
2. [L1-L4 표준 KPI](#2-l1-l4-표준-kpi)
3. [dialogue 구조 (5-에피소드 narrative · 5-block · 반전 요소)](#3-dialogue-구조)
4. [톤 분배 (긍정·카오스·부정 균형)](#4-톤-분배-긍정카오스부정-균형)
5. [어기조사 분포 (언어별)](#5-어기조사-분포-언어별)
6. [호칭 운용 (동적 시스템)](#6-호칭-운용-동적-시스템)
7. [윤리 가드레일](#7-윤리-가드레일)
8. [검수 3-stage 파이프라인](#8-검수-3-stage-파이프라인)
9. [v4 결정 적용 (dialect 분리·L4 신규·한자 cross-ref)](#9-v4-결정-적용)
10. [새 언어 30일 적용 체크리스트](#10-새-언어-30일-적용-체크리스트)
11. [부록 A. 폐기된 옵션 (하지 마)](#부록-a-폐기된-옵션-하지-마)
12. [부록 B. 룸 산출물 인덱스](#부록-b-룸-산출물-인덱스)

> **범위 결정 (2026-05-15)**: 본 문서는 **L1-L4 만** 다룬다. L5-L6 폐지. VI 룸 = canonical reference.
> VI 의 5 ep · 23 dial · 5-block · 14 어기조사 · 22 부사 · 14 카오스 카테고리 · 반전 요소 룰 = **모든 22 flavor 표준**.

---

## 1. 핵심 철학 5 원칙

> **모든 KPI·구조·톤 결정의 상위 원칙**. 어떤 언어 룸이든 변하지 않음.

### 1.1 한국 화자 한정·최적화

- 번역·예시·문법 설명·유추 모두 **한국어 직관 기반**
- 영어 기반 외국어 학습 앱과 차별화 — "이 언어는 한국어와 어떻게 다른가" 가 메인 axis
- 적용 예:
  - VI: 호칭 anh/chị/em ↔ 한국어 형/누나/동생
  - JA: 격조사 を/に/が ↔ 한국어 을/를/에/이
  - MN: 7격 ↔ 한국어 조사 (이/가, 을/를, 에서, 으로)
  - RU: 6격 변화 ↔ 한국어 자유 어순

**왜**: 영어 잘하는 한국인 < 한국어로만 외국어 배우는 한국인 (시장이 더 큼).

### 1.2 한 언어 한 앱 (one-app-per-language fork)

- 여러 언어 한 앱에 안 넣음 — **언어별 별도 앱** (스토어 페이지·아이콘·로고 분리)
- 콘텐츠 룸도 언어별 1방 (vi 룸은 vi 만, 다른 언어 폴더 손대지 X)
- 부록 언어 예외: LO=TH 부록 / MS=ID 부록 (DB 분리 `language_code` 유지)

### 1.3 100일 강요 X — 반년·1년 단위 도파민

- "30일 마스터" 압박 X. 1주 streak (X/10 일일 목표).
- 계절·반기 단위 시각화. "오늘 안 했어도 내일 회복 가능".

### 1.4 콘텐츠 = 자산 (Content is the moat)

- 기능·디자인은 모방 가능. **품질 좋은 한-X 1500 turns** (또는 Light 750t) 가 차별화.
- 단순 AI 생성 X — narrative arc + 캐릭터 일관 + 문화 고증 + 윤리 가드레일.
- VI 적용 사례: 옛 L1 (Day 06 길찾기·Day 07 쇼핑·Day 08 날씨) 폐기. **"영어로 우회 가능한 건 안 가르친다"** 원칙 부합 (L1 v2.3 마이그 결정).

### 1.5 언어별 특이성 = LanguageProfile 캡슐화

- 화면 코드에 `if (lang == 'ru')` 흩뿌리지 X.
- 모든 차이는 `lib/config/profiles/{lang}_profile.dart` 하나에 모음.
- 새 언어 추가 = profile 파일 1개 + brand 색상 + `LanguageRegistry` 등록.

---

## 2. L1-L4 표준 KPI

### 2.1 그룹별 분량 정책

| 그룹 | 언어 | 어휘 KPI | turn KPI | 근거 |
|---|---|---|---|---|
| **Heavy** | zh / ja / es / de / fr | 1,500 (표층) | ~1,500t | register 다양성 (구어/문어/존비) |
| **Mid 완료** | **vi** / th / ru | 1,500 | ~1,500t | sunk cost — 재작업 X |
| Mid 미시작 | ar / pl / id | 1,000~1,200 | ~1,500t | Pareto 정합성 (Decision 53) |
| **Light** | fa / kk / ms / my / mn / lo | 800 cap | ~750t | Top-800 = 94% 커버 |

→ **VI 는 Mid 완료** 그룹. 본 문서는 vi 정책을 baseline 으로 일반화.

### 2.2 L1-L4 분량 (Mid 표준 / Light 표준)

| Level | 주제 | Mid turns / dial | Light turns / dial |
|---|---|---|---|
| **L1 trailer** | 데이팅 압축 (매칭·데이트·가족·갈등·미래) | 200t / 5 ep × 40t | 80t / 13d |
| **L2 채팅** | 메신저·카톡 / **데이팅앱 카오스** | 280~300t / 20~23d | 130t / 18d |
| **L3 연애** | narrative arc (만남→갈등→헤어짐→방황→진정) | 280~322t / 20~23d | 130t / 18d |
| **L4 테마 보완 (TBD)** | L1-L3 narrative arc 의 갈등·관계 테마 심화 | ~280t / ~23d (예상) | 130t / 18d |
| **합** | | **~1,080t / ~74d** | **~470t / ~67d** |

→ L5·L6 폐지 (Decision 2026-05-15). 옛 L5 (취미·K-pop·축구) 와 L6 (어른) 콘텐츠는 본 표준에서 제외.

### 2.3 VI 실측 KPI (Mid 완료 reference)

| Level | turns | dialogues | structure | 비고 |
|---|---|---|---|---|
| L1 v2.3 | **200** | **5 ep × 40 turn** | 5-에피소드 데이팅 trailer | conv200_v2 (John+Linh/Mai/Trang/Hương/Linh-Future) |
| L2 v2.0 | **300** | **23 dial** | 5-block 데이팅앱 카오스 | B1-B5 (매칭→카톡→카오스→좌절→회복) |
| L3 v1 | 300 (계획) | 23 dial | 5-block 연애 narrative | B1-B5 (사랑→균열→헤어짐→방황→진정) |
| L4 v1 | **~280 (TBD)** | **~23 dial (예상)** | (TBD — 신규 작성 예정) | 테마 보완: 영어 우회 불가 갈등·관계 심화 |

### 2.4 어휘·통계 KPI (VI L2 합격선)

| 지표 | 목표 |
|---|---|
| Token freq 등재율 (top5k) | ≥ 98% |
| R1+R2+R3 coverage (top800) | 70~78% |
| 평균 문장 길이 | 5~7 token |
| TTR (어휘 다양성) | ≥ 0.30 (L3+ ≥ 0.19) |
| 어기조사 14종 모두 등장 | ✅ 필수 |
| 부사 ≥ 20종 등장 | ✅ 필수 |
| 카오스 카테고리 ≥ 12종 | L2 필수 |
| 톤 비율 정확 (8/8/7) | ✅ 필수 |

### 2.5 bottom-up KPI 원칙 (Decision 46)

- **KPI 사전 락 X**. L1 작성 → 측정 → 자연 도달점에서 cap 결정.
- 신규 언어 진입 시 1,500 자동 적용 X (Pareto: Top-800 = 94%, Top-1500 = 96~97%).

---

## 3. dialogue 구조

> **VI 검증 룰 = 모든 lang 표준 (2026-05-15)**:
> - L1 = 5 에피소드 × 40 turn = 200 turn (trailer)
> - L2-L4 = 23 dialogue × 5 block (B1-B5) = ~280-300 turn
> - 어기조사 14종 분포 + 부사 ≥ 22종
> - 카오스 카테고리 14종 (L2 reference)
> - **반전 요소 룰** (3.8 참고) — 모든 dialogue 에 1회 의외성 turn 필수

### 3.1 sentence id 표준

```
{lang}:sent:l{N}_d{NN}_t{NN}       기본 (L2-L4)
{lang}:sent:l1_ep{1-5}_t{01-40}    L1 5-에피소드 (VI L1 v2.3 채택)
```

### 3.2 14 컬럼 SQL row

```sql
(id, type, target_text, korean, romanization, category, course,
 tags, notes, comment, language_code, speaker, turn_order, scenario)
```

| 컬럼 | 의미 |
|---|---|
| `category` | `'대화N'` 또는 `Ep{N} {label}` (L1 v2.3) |
| `tags` | `'{new}'` 또는 `'{new,review_required,l2,block:1,tone:positive}'` |
| `notes` | 어휘·문법 학습 메모 (학습자용, 25-35자) |
| `comment` | narrative 맥락 (작성자용, 콜백 마커 등) |
| `speaker` | `'A'` (학습자 = 한국 남) / `'B'` (현지 주인공) / `'C'` (가족·3rd) / `'D'` (4th) |
| `turn_order` | dialogue 내 순서 |
| `scenario` | 첫 turn 풀, 나머지 짧게 |

### 3.3 Drift Schema 보조 컬럼 (언어별)

| 컬럼 | 적용 언어 | 의미 |
|---|---|---|
| `target_south`, `romanization_south` | **vi** | dialect 분리 (남부 변형) |
| `korean_south` | **vi** | 의역 다른 경우 |
| `is_polite` | vi | row 단위 polite/casual flag |
| `applicable_scenario` | vi | 1~5 시나리오 lock / NULL = universal |
| `morph_tags` jsonb | ru · mn | 격·성·모음조화 시각화 |
| `vocab_hints` jsonb | 모든 언어 | 단어 매핑 (DE 합성어 분해 hint 등) |
| `tier` | 모든 언어 (LO 제외) | beginner/intermediate/advanced |

### 3.4 5-에피소드 narrative 구조 (L1 trailer 모델, VI 사례)

```
Ep 1 매칭     (40 turn) — 매칭앱 → 첫 카페 만남
Ep 2 데이트   (40 turn) — 회사 동료 카페 + 산책
Ep 3 가족     (40 turn) — 부모 식사 + 동생
Ep 4 갈등     (40 turn) — 전화 다툼 → 화해
Ep 5 미래     (40 turn) — 결혼 + 가족·부모
─────────────
합 200 turn (L1 trailer — "이 200만 끝내도 진짜 만남 가능")
```

**캐릭터 4명 (hybrid 구조)**:
- John (학습자 = anh, 외국인, 국적 모호)
- Linh (Ep 1, 5) / Mai (Ep 2) / Trang (Ep 3) / Hương (Ep 4) — 5 다른 여성, 판타지 충족
- 가족: Trang 부모 (cô/chú), 동생 (em)

**말실수 + 정정** (학습 차별화, 챕터당 1-2개):
| Ep | 카테고리 | 시나리오 |
|---|---|---|
| 1 | 호칭 | em 자기/상대 혼동 → Linh 정정 |
| 2 | 현지화 | 영어 직역 (rất đẹp) → Mai 자연 표현 안내 |
| 3 | 격식 어기조사 | 엄마한테 đi (캐주얼) → Trang 정정 (ạ) |
| 4 | 성조 | ma(귀신) vs má(엄마) 혼동 → 분위기 풀림 |
| 5 | 발음 | đắp(쌓다) vs đặp(부수다) 혼동 → 가족 폭소 |

### 3.5 5-block 구조 (L2-L4 본편 모델, VI L2 사례)

```
B1 진입       (4 dial, 50 turn) — 들뜸 + 첫 의심
B2 전개       (5 dial, 60 turn) — 카오스 시작
B3 정점       (5 dial, 70 turn) — 진짜 현실
B4 좌절·실험 (5~7 dial, 70~90 turn) — 핵심 결제 유도 구간 (L3)
B5 회복·예고 (4 dial, 50 turn) — 균형 회복 + 다음 L 시그널
─────────────
합 23 dial / 300 turn
```

**각 dialogue 12~15 turn 구조**:
1. 오프닝 (1-3 turn) — self-onboarding (B3·B4·B5만 의무)
2. 본론 (8-10 turn) — 주제 전개 + 감정/반전 1회
3. 반전 (1-2 turn) — 의외성·말실수·갑작스러운 감정
4. 클로징 (1-2 turn) — 결말 또는 다음 떡밥

### 3.6 self-onboarding 8 패턴 (L2-L4 모든 block 첫 dial)

각 block 의 시작 dialogue 가 독립 진입 가능해야 함 (L2 안 봐도 L3 이해 가능).

| # | 패턴 | 예시 |
|---|---|---|
| 1 | 외모 첫인상 | "Ngoài đời anh khác ảnh nhiều" / "사진보다 키 크네요" |
| 2 | 시간·관계 | "Mình quen nhau 6 tháng rồi" / "우리 6개월 됐어" |
| 3 | 앱·매칭 | "Hồi đó mình match qua app" / "그때 앱에서 매칭됐었지" |
| 4 | 친구·소문 | "Bạn em bảo người Hàn rất ga lăng" / "친구가 한국 남자 매너 좋다고" |
| 5 | 한국·현지 | "Em sang Việt Nam mấy lần rồi" / "베트남 몇 번 왔어요" |
| 6 | 직업·일 | "Anh làm việc ở Việt Nam phải không" / "베트남에서 일하시죠" |
| 7 | 긴장·설렘 | "Em hồi hộp quá" / "긴장돼" |
| 8 | 음료·환경 | "Em uống gì cũng được" / "아무거나 마실래" |

### 3.7 화자 ID 일관성

- **A** = main 화자 1 (본편 main pair 의 한국인 남) ← 학습자 동일시
- **B** = main 화자 2 (본편 main pair 의 현지인 여)
- **C** = 3-way 추가 등장 (가족·친구·낯선 사람)
- **D** = 4th (필요 시, VI L1 v2.3 Trang 아빠 등)
- L1 익명 = default A=남 / B=여

### 3.8 반전 요소 룰 (VI 검증 → 표준 채택)

> **모든 dialogue 에 1회 의외성 turn 필수**. 진부함 회피 + 학습자 몰입 + 자연 회화 시뮬레이션.
>
> VI L2 23 dialogue 가 검증: "예상된 흐름 → 의외 turn → 회복/대응" 3-스텝 micro-arc.

#### 반전 카테고리 (5종, 1 dialogue 1개)

| # | 카테고리 | 설명 | VI 사례 |
|---|---|---|---|
| 1 | **가짜→진짜 화해** | 갈등 turn 후 가짜 화해 (B 의 식어 있음) → 진짜 화해 turn 1회 | L2 d18 "한국 남자 다 그래" 비하 → 학습자 반박 → 가짜 사과 → 진짜 정정 |
| 2 | **말실수 + 정정** | A 의 의도 X 실수 (호칭·발음·격식·성조) → B 의 자연 정정 | L1 ep4 ma/má 성조 혼동 → 분위기 풀림 |
| 3 | **갑작스러운 감정** | 일상 톤 → 1 turn 감정 폭발 (질투·불안·기쁨) → 회복 | L2 d13 외도 사진 발각 turn |
| 4 | **의외 사실 공개** | 캐릭터 숨겨진 사실 1 turn 공개 (직업·가족·과거) | L2 봇 의심 d → 진짜 사람 확인 |
| 5 | **카오스 진입** | 정상 dialogue → 갑작스러운 카오스 (변태·스캠·잘못 보낸 메시지) | L2 d07 그룹 메시지 사고 |

#### 배치 원칙

- 23 dialogue 중 **반전 0 회 dialogue ≤ 3개** (단순 self-onboarding 만 예외)
- 반전 turn 위치: 본론 후반부 (8-10 turn 위치 권장 — 너무 이르면 진부, 너무 늦으면 클로징과 겹침)
- B5 (회복) 의 반전 = "가짜 화해 → 진짜 화해" 패턴 우선 적용 (narrative 진정성 ↑)

---

## 4. 톤 분배 (긍정·카오스·부정 균형)

### 4.1 톤 비율 (L2 reference)

L2 23 dialogue 기준:

| 톤 | dial 수 | 비고 |
|---|---:|---|
| **긍정·재미** | 8 | 자연 매칭·진심·농담·위로·희망 |
| **카오스·황당** | 8 | 변태·광고·봇·잘못 보낸 메시지 등 |
| **부정·좌절** | 7 | 잠수·스캠·집착·외도·비하 |
| **합** | **23** | 균형 — 좌절 편중 X |

**왜 균형**: 좌절 편중 시 학습자 이탈. 카오스 편중 시 진부화. 긍정 편중 시 cliché.

### 4.2 L별 톤 분배 (VI 사례)

| Level | 긍정 | 카오스 | 부정 | narrative 톤 |
|---|---:|---:|---:|---|
| L1 (trailer) | 5 ep 균형 | (말실수 1-2개/ep) | 갈등 1 ep | 압축·진심 |
| L2 (본편 시작) | 8 | 8 | 7 | 데이팅앱 카오스 |
| L3 (연애 narrative) | 8 | 7 (B4 카오스) | 8 (B2·B3 균열) | 사랑→방황→진정 |
| L4 (테마 보완 — TBD) | 8 | 4 | ~11 | 갈등·관계 심화 (영어 우회 불가) |

### 4.3 카오스 카테고리 14종 (L2 reference)

매 카오스 dialogue 에 1개씩 명확히 배정.

| # | 카테고리 | 학습 가치 |
|---|---|---|
| 1 | 너무 적극·자기야 호칭 | 거리 두기 표현 |
| 2 | 봇 의심 — "너무 완벽" | 의심·확인 질문 |
| 3 | catfish (사진 거부) | "Gửi ảnh thật đi" 직설 |
| 4 | 영어로만 답 | "Nói tiếng Việt với em đi" |
| 5 | 매칭 후 즉시 사라짐 | 잠수 표현 |
| 6 | 셀카 칭찬 폭주 | xinh thế / ghê / quá |
| 7 | 잘못 보낸 메시지 (그룹 사고) | 변명·웃음 |
| 8 | 변태 메시지 (모르는 번호) | 차단·"Ai đấy?" |
| 9 | 로맨스 스캠 (가족 핑계 돈) | 돈 요구 위험 신호 |
| 10 | MLM·코인 광고 | 광고 차단 |
| 11 | 영상통화 (진짜 사람 확인) | "Video call đi" |
| 12 | 친구 폰 뺏기 장난 | 농담 톤 |
| 13 | 외도 사진 발각 | 추궁·해명 |
| 14 | 집착·과한 연락 | 거리 두기·부드러운 거절 |

### 4.4 후킹 톤 원칙

> **콘텐츠 양 ≠ 시장 성공**. 언어앱 풀코스 완료율 ~8%, freemium 유료 4~8%.
> 적정 양 + **자연성 + 흡인력** 우선.

- L2 = 인물·관계·갈등 골격 (단순 일상 X)
- L3 = 연애 narrative 메인 축 (만남 → 밀당 → 관계 정의 → 갈등 → 회복)
- L4 = 사건 전개·반전 (오해/배신/숨겨진 정체/예상 외 폭로) — TBD
- 재미 = 위트·문화 대비·아이러니 (cross-cultural 코메디)

**첫 dialogue 컨펌 룰**: 톤 약하면 사용자 재작성 요청. 첫 dialogue 후 사용자 컨펌.

---

## 5. 어기조사 분포 (언어별)

### 5.1 공통 정책

> **친한 사이 정중 어기조사 stacking 안 함.**
> **L1 은 학습 일관성 위해 정중 어기조사 노출 필수**, L2+ narrative 자연성 우선으로 자유.

### 5.2 언어별 어기조사

| 언어 | 어기조사 | 친한 사이 빈도 | L1 도입 | L2+ stacking |
|---|---|---|---|---|
| **VI** | ạ / nhé / nhỉ / đấy / đây / thế / thôi / đi / mà / đâu / đã / à / chứ / cơ (14종) | 1~2회/dial | Day 2 | L2~ 자유 |
| TH | ครับ/ค่ะ/นะ/ไหม/คะ | 1~2회/dial | Day 1 (성별 어미 절대) | L3+ (นะคะ, สิคะ) |
| JA | です/ます/ね/よ | 정중 친근 균형 | — | — |
| KO | -요/-습니다 | 친구 캐주얼 | — | — |
| MN | -уу/-ээ | 정중 어미 (또래 반말) | — | — |
| ID | ya/dong/sih/banget/kan/loh | 1~2회/dial 절제 | L1 도입 (vocab_hints) | L2~ 자유 |

### 5.3 VI 어기조사 14종 분포 KPI (300 turn 중)

L2 reference. 14종 모두 등장 필수.

| 어기조사 | 의미 | 최소 등장 |
|---|---|---:|
| `nhé` | 부드러운 제안 | 25 |
| `nhỉ` | 동의 구하기 | 12 |
| `đấy` | 알려주듯 | 15 |
| `đây` | 강조·현장감 | 8 |
| `thế` | 호기심 의문 | 15 |
| `thôi` | 그냥·만 | 10 |
| `đi` | 명령·권유 | 18 |
| `mà` | 반박·강조 | 12 |
| `đâu` | 부정 강조 | 10 |
| `đã` | 완료 | 12 |
| `à` | 의문·확인 | 15 |
| `chứ` | 당연 | 8 |
| `cơ` | 더 강조 | 5 |
| `ạ` | 격식 (B3·B5 일부만) | 5 |

**실측 (L1 v2.3 200 turn 북부)**: 184건 / 15종 모두 등장 (nha 1건 추가).

### 5.4 부사 ≥ 20종 등장 (L2+ KPI)

```
rồi · vừa · mới · cũng · chỉ · lại · hay · vẫn ·
hơi · khá · quá · lắm · thật · chắc · có lẽ · hình như ·
tự nhiên · bỗng · nữa · cứ · ngay · sắp · đang · sẽ · luôn
```

**활용 패턴**:
- `vừa ... xong` (방금 막)
- `cũng ... mà` (나도 ~인데)
- `lại ... rồi` (또 ~)
- `vẫn ... đấy` (여전히)
- `quá` (감탄) vs `lắm` (일반 강조)

---

## 6. 호칭 운용 (동적 시스템)

### 6.1 VI 5 시나리오 + 동적 호칭 (Drift v17)

> 실제 구현: `lib/services/scenario_resolver.dart` — gender·age 기반 (학습자 자기 정체성).
> 옛 설계 (부모 만남·카페·친구·직장·쇼핑) 폐기. 5번만 친구 register 로 살아남음.

```
시나리오 5가지 (학습자 ← 상대):
1. 여 연하 → 남 연상 (em → anh)         ← default
2. 여 연하 → 여 연상 (em → chị)
3. 남 연하 → 남 연상 (em → anh)
4. 남 연하 → 여 연상 (em → chị)
5. 동년배 친구 (tớ ↔ cậu)               ← 친구 register lock
```

**치환 규칙** (`scenario_resolver.dart`):
- placeholder: `{{self}}`, `{{other}}`
- `speaker == 'A'` (학습자 발화) → `{{self}}` = 시나리오의 self preset
- `speaker == 'B'` (상대 발화) → `{{self}}` = 시나리오의 other preset (역치환)
- romanization 컬럼은 한글 음역 매핑 사용 (anh → 안, chị → 찌, tớ → 떠, cậu → 꺼우)

### 6.2 VI 호칭 컬럼 운용

| 컬럼 | 의미 |
|---|---|
| `is_polite` | row 단위 polite/casual flag |
| `applicable_scenario` | 1~5 = 시나리오 lock / NULL = universal (모든 시나리오 노출) |
| `target_text`, `romanization` | 북부 (기본) |
| `target_south`, `romanization_south` | 남부 변형 (Gemini 검수 ~700 row) |

**적용 통계 (seed_vi.sql)**:
- L1 v2.3: hardcoded honorific (placeholder X — 사용자 결정) — 5 ep narrative 일관성 위해
- L2: applicable_scenario=5 (246 row peer 친구 dialogue lock)
- L3·L4: NULL universal (캐릭터 narrative)

### 6.3 호칭 L 진도 (L3 reference)

```
B1: anh/em 정착 → "người yêu" 호칭 가능
B2: anh/em 균열 시작
B3: anh/em (이별 후 호칭 변화)
B4: bạn → em (새 만남 호칭 변화)
B5: bạn → anh/em (조심스럽게 정착)
```

### 6.4 언어별 호칭 시스템

| 언어 | 호칭 | 차원 |
|---|---|---|
| VI | anh/em/chị/ông/bà/cô/chú/cháu/mình/bạn | 나이·관계 맞춤 |
| ID | aku/kamu (친근) + saya/anda (정중) | 격식 두 차원 |
| TH | ครับ/ค่ะ 성별 어미 (절대) | 성별 절대 |
| MN | би/чи (또래 반말) | 단순 |
| JA | 私/僕/俺/うち | 성별·격식 mismatch 주의 |
| RU | я/ты/Вы (formal 구분) | 격식 |

### 6.5 한국 캐릭터 명명 룰

- ✅ **영어 이름** (Daniel · Kevin · Brian · Justin · Ethan) — 글로벌 친화 + 발음 부담 ↓
- ❌ 한국식 (민준·지훈) — 발음 부담 (외국 화자 입장)
- VI 예외: **John** (영어 이름 — Ep1-5 학습자 anh 본인. 사용자 명시: 이름 명시 X 권장이나 narrative 위해 John 채택)
- 사이드 캐릭터 (어머니·친구) = 한국식 OK (narrative 진정성)

**현지 캐릭터**: 그 언어 native 발음 어려운 이름 회피.
- VI: Linh · Mai · Trang · Hương · Vy · Yến · Quỳnh (200 turn 사례)
- FR: Sophie · Anna · María
- DE: Anna (베를린 22, Humboldt 박사)
- TH: Nene · Pla (A/B arc)

---

## 7. 윤리 가드레일

### 7.1 일반 콘텐츠 (모든 L)

| 항목 | 정책 |
|---|---|
| 베트남 여성 전체 비하 X | 캐릭터 비율 6:3:2 (긍정·중립·부정) — 다양화 |
| "베트남 여자는 다 ~" 일반화 | 학습자 발언 X. 캐릭터 입에서만 (비합리적 시그널) |
| "한국 남자 다 그래" 비하 | 캐릭터 비합리성 묘사 — 학습자 반박 turn 필수 |
| 정치·종교 논쟁 | 회피 |
| 인종·성별·국적 stereotypes | 회피 |
| 직업·외모 비하 | X |
| 약물·과음 미화 | X (술자리 자연 묘사는 OK) |
| 마지막 인상 (B5) | 회복·희망 톤 |

**VI L2 적용 사례**:
- d05 친구 자조 "한국 남자 다 그래" → 학습자 즉시 반박 (turn 6)
- d18 Mai 비하 "한국 남자 다 그래" → 학습자 2회 합리 반박 + 정정 받아냄
- d21 친구 일반화 "베트남 여자 다 그래" → 학습자 즉시 반박
- 스캠·집착·변태 turn = `key` 필드에 "⚠️ 위험 신호" / "💡 학습 가치" 명시

### 7.2 L3 R-17 라인 (L1-L4 전체 max sensual)

L3 = Apple 17+ 등급 / Google Play 정책 안 max sensual. 명시적 X.
**L5·L6 폐지 (2026-05-15)** — L1-L4 표준에서는 R-17 이 절대 상한선.

**✅ 가능**:
- 클럽·Bar 자연 묘사 (Lush · Apocalypse · Bui Vien · Tạ Hiện)
- 작업 멘트·호감 표현
- 헤어짐·감정
- 키스·포옹 언급 (묘사 X)
- 가벼운 신체 접촉 언급
- 데이트·동거 암시
- 술자리 분위기

**❌ 금지**:
- 명시적 성적 묘사
- 호텔로 가는 명확한 표현
- 가라오케·KTV (한국인 신호 + 윤리)
- 호스티스 바
- 미성년 (모든 캐릭터 22+)
- 매춘·유흥
- 강압·비동의

**R-17 표현 트릭**:
| ❌ 금지 | ✅ 가능 |
|---|---|
| "Anh muốn ngủ với em" | "Anh không muốn đêm nay kết thúc" |
| "Mình về khách sạn nhé?" | "Đi đâu đó hai mình không?" |
| "Em đẹp [신체]" | "Em đẹp khủng khiếp hôm nay" |

→ 사용자 머릿속에서 완성. 어른은 다 안다.

### 7.3 L3 윤리 4중 방패 (방황·플러팅 B4)

```
방패 1: narrative arc 정당화
  방황·플러팅은 "단계"
  → 진정한 사랑 (B5 Vy) 으로 귀결
  → 단순 픽업 가이드 ≠ 본 콘텐츠

방패 2: 학습 자료 frame
  "이런 표현 알아두라" (정보 제공)
  "쓰라" 가 아니라 학습자 선택

방패 3: 가상 narrative (소설)
  캐릭터 = 가상
  실제 사람 X

방패 4: B5 = 진정한 사랑 결말
  플러팅 → 회한 → 진짜 사랑
  도덕적 메시지
```

### 7.4 "영어로 우회 가능한 건 안 가르친다" (브랜드 원칙)

VI 룸 사용자 결정 (2026-05-12 절벽 검토 후).

**가르치는 것 ✅**:
- 데이팅앱·메신저 카오스 대응 (현지 여성과 진짜 카톡)
- 호칭 운용 (anh/em + 친밀도 변화)
- 어기조사·부사 자연 분포 (감정·뉘앙스)
- 일상 안부·감정·관계·놀림
- 좌절·갈등 표현 (스캠·잠수·집착 대응)

**가르치지 않는 것 ❌** (옛 L1 폐기 사유):
- 호텔·식당 예약 (영어 우회 가능)
- 비행기·공항·길 묻기 (Google Maps)
- 비즈니스 메신저 (옛 L5 영역 — 폐기)
- 정중 격식 메일 (타겟 X)
- 날씨 잡담·쇼핑 가격 묻기 (번역기 우회)

---

## 8. 검수 3-stage 파이프라인

### 8.1 단계 개요

```
Stage 1 Claude self-review (작성 직후)
  각 dialogue 끝 self_check 객체 강제
  ↓
Stage 2 Python 통계 자동 검증
  token freq · TTR · 어기조사 분포 · 톤 비율 · 카오스 카테고리
  ↓
Stage 3 외부 LLM 검수 (Gemini / GPT 분담)
  북부 자연성 → 남부 변환 → 남부 뉘앙스
  ↓
Stage 4 사용자 최종 검증
  TTS 락업 직전 자연성·재미·윤리 직판단
```

### 8.2 Stage 1 — Claude self-check

각 dialogue 끝에 `self_check` 객체:

```json
"self_check": {
  "particles_count": 4,
  "adverbs_count": 5,
  "chaos_clarity": "명확함",
  "tone_match": true,
  "address_consistency": true,
  "self_onboarding_clear": true,
  "R17_line_respected": true,
  "ethics_guard_passed": true,
  "verified_word_ratio": 0.75
}
```

합격선: particles ≥ 3, adverbs ≥ 4, verified_word_ratio ≥ 0.70.

### 8.3 Stage 2 — Python 통계 검증

```python
- token freq 등재율 ≥ 98% (top5k)
- R1+R2+R3 coverage 70~78% (top800)
- TTR ≥ 0.30 (L3+ ≥ 0.19)
- 어기조사 14종 분포 (목표 ±30%)
- 부사 등장 종수 ≥ 20
- 카오스 요소 등장 (14종 중 ≥ 12종)
- 톤 비율 정확 (긍정 8 / 카오스 8 / 부정 7)
- 호칭 일관성 (한 turn 내 anh/em 혼동 X)
- L3 신규 65 단어 중 ≥ 50개 등장
- R-17 라인 위반 0건 (금지 표현 자동 검출)
```

스크립트: `tools/_analyze_<lang>_token_freq.py`.

### 8.4 Stage 3 — 외부 LLM 분담 (VI 모델)

| 단계 | 모델 | 역할 |
|---|---|---|
| 1차 북부 자연성 | **Gemini** | 책투·호칭·카오스 시그널·윤리 |
| 2차 남부 변환 1차 | **GPT** | 자동 변환 잔존 (ạ·어순) |
| 3차 남부 뉘앙스 | **Gemini** | ghê·quá trời·hen 다양화 |

**입력 형식**:
1. brief md 첫 메시지 (`_<lang>_review_session_brief.md`)
2. sample SQL/JSON 두 번째 메시지 (`_<lang>_review_for_gemini.sql` 또는 chunk JSON)

**응답 형식**:
```
## 발견 N
- ID: xx:sent:lX_dYY_tZZ
- 원문: [text]
- romanization: [현재]
- 문제: [어감/번역/표기/어기조사/문화/윤리]
- 제안: [수정안]
- 우선순위: 높음/중간/낮음

## 패턴 (반복 오류)
- 패턴: ...
- 영향 범위: 추정 row 수
- 일괄 수정 SQL UPDATE 제안
```

### 8.5 검수 우선순위 (모든 언어 공통)

```
1. native 자연성 (target_text)
2. 한국어 번역 정확성
3. romanization 정확성·일관성
4. 어기조사·호칭 적절성
5. vocab_hints 어휘 매핑
6. 문화 정확성 (wai·sin sod·게르 등)
7. R-17 라인 (L3 max sensual · consent · 미성년 X)
8. 격·성·수 정확성 (굴절어/교착어)
```

### 8.6 VI L2 검수 가치 사례

- 31 patches 누적 적용
  - Final v1 (첫 라운드): 8건
  - v2 청크 라운드: 13건 (B1·3 / B2·5 / B3·2 / B4·2 / B5·1)
  - Claude self-review (mismatch dialogue 12건): 10건 — 핵심 `nha` 남부 어기조사 3건·pron 한글 깨짐 1건
  - Gemini mismatch (hallucination 의심): 12건 skip → Claude self-review 가 실질 보완
- 남부 어기조사 전환률 90.6% (87/96) — Gemini 2차 검수 효과
- 치명 오역 0건 (Stage 1+2 가 효과)

### 8.7 chunk 분할 정책

- Gemini context 한도 ~30K tokens 안전
- dialogue 단위 보존 (잘림 X)
- Light 언어: level 별 1~2 chunk 충분
- Mid/Heavy: level 별 세분 (L3 300t → 2~3 chunk, B 단위)
- 도구: `tools/_chunk_for_review.py` 자동 생성

### 8.8 검수 결과 적용

- notes 컬럼에 변경 사유 기록 ("Gemini 검수: ..." 또는 "내부 검수: ...")
- `supabase/_apply_<lang>_review.sql` 수집 → Studio 실행 → seed 본문 동기화
- seed·청크 재빌드

---

## 9. v4 결정 적용

> 2026-05-13 ~ 14 VI 룸 사용자 결정 사항. 새 언어 룸 진입 시 적용 검토.

### 9.1 Section 4: 파일명 원칙 (콘텐츠 룸)

```
talkverse-lab/{lang}/
├── episodes/                  L1 5-에피소드 narrative (JSON SOT)
│   ├── conv200_v2_north.json
│   └── conv200_v2_south.json
├── l2/                        L2 본편 5-block
│   ├── L2_combined_{north,south}.json
│   ├── chunks/b{1-5}_{north,south}.json   ← 검수 청크
│   ├── _review_*.md           ← 검수 프롬프트 4개 (north_gemini, south_gpt, south_gemini, pipeline)
│   ├── reviews/gemini_*.md    ← 검수 결과
│   └── patches/b{1-5}_*.json  ← 패치 누적
├── l3/                        L3 narrative arc (동일 구조)
├── MD/                        프로젝트 메모 (migration, workflow, review brief)
├── Word/                      어휘·빌드 스크립트
│   └── scripts/build_l{N}_v{X}_seed.py + patch_seed_{lang}_l{N}.py
└── vi_l{N}_workflow_v{X}.md   워크플로우 SOT (룸 루트)
```

### 9.2 Section 4.2: dialect 별 분리 (VI 모델)

VI = 북부 baseline + 남부 자동 변환 (수동 검수).

```
DB 컬럼:
  target_text · romanization · korean             (북부 = baseline)
  target_south · romanization_south · korean_south (남부 변형)

JSON SOT:
  conv200_v2_north.json  (베이스 — Claude 작성 + Gemini 1차 북부 검수)
  conv200_v2_south.json  (자동 변환 + GPT 1차 + Gemini 2차)

자동 변환 룰 (북부 → 남부):
  어기조사: nhỉ→hả, đấy→đó, thế→vậy, nhé→nha, chứ→chớ
  어휘:    vâng→dạ, Ơ→Ủa, nghìn→ngàn, vào→vô, bố→ba
  발음:    조이→로이 (r), 저이→요이 (gi→y), 제→예 (d→y)
  지명:    Hà Nội→Sài Gòn, Tạ Hiện→Bui Vien, quận Hoàn Kiếm→quận 1
  강조:    quá/lắm→quá trời/ghê, ngay→liền, không sao→không có chi
```

**자동 변환 한계** (외부 LLM 검수 필요):
- ạ 격식 (남부는 줄임)
- 어순 미세 차이
- 5성조 통합 (ngã = hỏi — ToneCurve 위젯 region 분기 처리)
- 남부 특유 표현 추가 (ghê / quá trời / vậy đó / hen)

**baseline 일관 원칙** (2026-05-13): 북부 baseline = **모든 지명·표현 하노이 통일**. 남부 변환은 자동 단계에서.

### 9.3 Section 4.3: L4 = TBD - 신규 작성 예정

> **결정 (2026-05-15)**: L4 = 골격만. KPI 예상치만 설정. 본격 작성은 신규 세션에서.

**TBD 골격**:

| 항목 | 값 (예상) |
|---|---|
| turns | **~280** (L2/L3 와 동급) |
| dialogues | **~23 dial** (5-block 구조 유지) |
| 주제 | L3 narrative arc 의 테마별 심화 (영어 우회 불가) |
| 구조 | 5-block (B1-B5) 또는 5-에피소드 (TBD — 작성 시 결정) |
| 톤 | 긍정 8 · 카오스 4 · 부정 ~11 (갈등·관계 심화 비중 ↑) |
| 카오스 카테고리 | L2 14종 reference 활용 |
| 어기조사 분포 | 14종 모두 등장 필수 (VI 표준) |
| 반전 요소 | 모든 dialogue 1회 (3.8 룰) |

**탐색 주제 후보** (작성 시 사용자 결정):
- 옛 L4 (호텔·식당·교통·길) = "영어 우회 가능" → 폐기
- "베트남 여친이 화날 때 한 마디"
- "헤어지고 방황한 한국 남자의 회복기"
- "이별의 베트남어 — 끝까지 가는 사람만"
- "장거리 + 시차 + 의심"
- "결혼·sin sod·visa·가족 압박"

**옛 L4-L6 콘텐츠 처리**: 옛 1138 turn = 재구성 X. archive 만.

### 9.4 한자 cross-ref (ZH·JA 전용)

- `hanja_master` + `hanja_related` 테이블 별도
- 한자 메뉴 + 부수 학습 (screens/hanzi_list_screen.dart)
- LanguageProfile `hasHanjaSupport => true`
- 한자 = D 의미문자 축. 학습 비중 큼.

### 9.5 ID 체계 (L1 5-에피소드 vs L2-L4 23-dialogue)

```
L1 v2.3:  vi:sent:l1_ep{1-5}_t{01-40}    ← 에피소드 기반
L2-L4:    vi:sent:l{N}_d{NN}_t{NN}       ← dialogue 기반
```

옛 ID → 신규 ID 마이그레이션 시 `DELETE FROM items WHERE id LIKE 'vi:sent:l1_d%';` 청소 SQL 필요.

---

## 10. 새 언어 30일 적용 체크리스트

### 10.1 진입 30분 결정 트리 12개

신규 언어 룸 brief 작성 시 다음 12개 채우기.

1. **형태론 분류** — 굴절 / 교착 / 분석 / SOV·SVO·VSO 등
2. **표기 체계** — 라틴 / 키릴 / 아랍 / 한자 / 자체 + 한글 음역
3. **성조** — 있음·없음 (표기 정책)
4. **Demographic** — 메인 1~2 + 제외
5. **시장 크기** — 화자 수 + 한국 거주/결혼/노동
6. **부록 언어** — 해당 시 (LO=TH, MS=ID 모델)
7. **데이터셋 1순위** — HermitDave / UniMorph / Stanza / Underthesea 등
8. **형태 분석** — 격·성·모음조화 시각화 여부
9. **한-X 평행 corpora** — Tatoeba / OPUS / 부재 시 직접 작성
10. **TTS** — Google Cloud / 자체 API / 무료 fallback
11. **윤리·문화** — 종교·문화 가드 (sin sod·visa·풍습)
12. **KPI** — 어휘 cap / total turns / tier 비율 (bottom-up 락)

### 10.2 콘텐츠 작성 체크리스트

- [ ] **L1 trailer 200t** 작성 (5 에피소드 narrative, 데이팅 압축)
  - [ ] 캐릭터 4명 (학습자 + 메인 여 + 가족 + 친구)
  - [ ] 말실수 + 정정 5회 (호칭·현지화·격식·성조·발음)
  - [ ] 어기조사 14종 모두 등장
  - [ ] 호칭 다양화 (7-10종)
  - [ ] freq top800 커버 ≥ 70%
  - [ ] **반전 요소 ≥ 1회/ep** (3.8 룰)
- [ ] **L2 본편 ~300t** 작성 (5-block 카오스 데이팅앱)
  - [ ] 톤 비율 8/8/7 (긍정/카오스/부정)
  - [ ] 카오스 카테고리 ≥ 12종 (14종 reference)
  - [ ] 캐릭터 풀 11명 + 카오스
  - [ ] self-onboarding 8 패턴 활용 (B3·B4·B5)
  - [ ] 윤리 가드 (비하·일반화 0건)
  - [ ] **반전 요소 ≥ 20/23 dial** (3.8 룰)
- [ ] **L3 narrative ~300t** (사랑→균열→헤어짐→방황→진정)
  - [ ] R-17 라인 엄수
  - [ ] 윤리 4중 방패 (B5 회복 결말)
  - [ ] B4 분량 가장 큼 (결제 유도)
  - [ ] B5 "가짜→진짜 화해" 반전 패턴 (3.8 카테고리 1)
- [ ] **L4 테마 보완 ~280t (TBD)** — 신규 작성 예정
- [ ] dialect 변형 (해당 시 — VI 북부/남부)

### 10.3 인프라 (코드) 체크리스트

- [ ] `lib/theme/app_colors.dart` — brand 컬러
- [ ] `lib/config/profiles/{lang}_profile.dart` — Profile 등록
- [ ] `lib/config/language_registry.dart` — appendices 매핑 (해당 시)
- [ ] TTS locale 매핑 (`ttsLocale`)
- [ ] 굴절어·교착어 시 `grammarTagColors` 정의
- [ ] sync_service 부록 언어 처리 (필요 시)
- [ ] 키보드 IME 안내 (RTL/키릴/한자)
- [ ] Hero image asset (선택)

### 10.4 검수·출시 체크리스트

- [ ] Stage 1 Claude self-check 통과
- [ ] Stage 2 Python 통계 검증 통과
- [ ] Stage 3 외부 LLM 검수 (Gemini 북부 → GPT 남부 → Gemini 남부 — dialect 있는 경우)
- [ ] Stage 4 사용자 최종 검수
- [ ] TTS 합성 (~$5/level, ElevenLabs / Google Cloud / native)
- [ ] Supabase 업로드 (`_split_for_upload.py` 1MB 분할)
- [ ] 디바이스 검증 (`flutter run --flavor {lang}`)
- [ ] 윤리 가드 위반 0건 검증

### 10.5 페이스 권장 (VI 검증)

| Week | 작업 | 학습 (개인) |
|---|---|---|
| W1 | L1 trailer 작성 + 검수 | — |
| W2 | L2 Claude 의뢰 (B1-B5) | L1 ep1 |
| W3 | L2 자동 남부 변환 + GPT/Gemini 검수 | L1 ep2-3 |
| W4 | L2 SQL 빌드 + 앱 적용 | L1 ep4-5 |
| W5 | TTS 합성 + 출시 | 출국·실전 |

→ Mid 1500t = 4~5 주말 / Light 750t = 2~3 주말.

---

## 부록 A. 폐기된 옵션 (하지 마)

| # | 옵션 | 폐기 사유 |
|---|---|---|
| 1 | L1 외부 freq top-N 미리 확정 | Decision 47 — OpenSubtitles freq ≠ 우리 narrative 분포 |
| 2 | L1 캐릭터 이름 등장 | lemma 풀 낭비 + universal 원칙 위반 + 재활용성 ↓ |
| 3 | VI 호칭 1개 컬럼 (target_text 만) | 5 시나리오 placeholder 치환으로 대체 |
| 4 | VI 옛 시나리오 5종 (부모/카페/직장/쇼핑) | 5 시나리오 (em-anh / em-chị / tớ-cậu) 로 통합 |
| 5 | LO 단독 앱 | TH 부록 모델 (Decision 41) — 라오 700만 < 태국 6,900만 |
| 6 | 다차원 tier (길이·문법·정중도) | 1차원 빈도 + content-aware override 만 |
| 7 | ID 별도 IndonesianProfile | 불필요 (DefaultProfile + appendices) |
| 8 | 신규 언어 1,500 자동 적용 | bottom-up KPI (Decision 46·53) |
| 9 | 옛 L1 (Day 06 길찾기 · Day 07 쇼핑 · Day 08 날씨) | 영어/Google Maps/번역기 우회 가능 → 폐기 |
| 10 | 옛 L2 random 토픽 (Shopee·고양이·더위·배달·창업 실패) | 일부 영어 우회 가능 → 데이팅앱 카오스로 교체 |
| 11 | rất + 형용사 (책투) | 회화체 자연 표현 (xinh thế / đẹp ghê / lắm) 우선 |
| 12 | 학습자가 "베트남 여자는 다 ~" 일반화 | 반대 캐릭터 발언으로만 (학습자 입에서 X) |
| 13 | 가라오케·KTV·호스티스 바 | 한국인 신호 + 윤리 |
| 14 | 호텔로 가는 명확한 표현 | R-17 라인 위반 — "Đi đâu đó hai mình không?" 식 암시만 |
| 15 | 미성년 캐릭터 | 모든 캐릭터 22+ |
| 16 | 친밀해진 사이 `bạn` 호칭 | 어색 — anh/em 으로 진화 |
| 17 | L5 (취미·K-pop·축구·게임·SNS) | Decision 2026-05-15 — 본 표준 제외 |
| 18 | L6 (어른·8 테마·19+ 친밀) | Decision 2026-05-15 — 본 표준 제외 (R-17 이 상한) |
| 19 | L6 vignette arc 별 캐릭터 페어 | L6 폐지로 자동 폐기 |
| 20 | AdultHub UX·AdultVerificationService 21+ 게이트 | L6 폐지로 자동 폐기 |

---

## 부록 B. 룸 산출물 인덱스

### B.1 콘텐츠 룸 (talkverse-lab/{lang}/)

| 파일 | 용도 |
|---|---|
| `episodes/conv200_v2_{north,south}.json` | L1 trailer SOT |
| `l2/L2_combined_{north,south}.json` | L2 본편 통합 |
| `l2/chunks/b{1-5}_{north,south}.json` | 검수 청크 |
| `l2/_review_{pipeline,north_gemini,south_gpt,south_gemini}_prompt.md` | 검수 프롬프트 4개 |
| `l2/reviews/gemini_*.md` | 검수 결과 |
| `l2/patches/b{1-5}_*.json` | 패치 누적 |
| `l3/` | L3 동일 구조 |
| `MD/l{N}_v{X}_migration_*.md` | 마이그레이션 리포트 |
| `MD/vi_l{N}_workflow.md` | 워크플로우 SOT |
| `MD/conv200_v2_review_brief.md` | 검수 컨텍스트 |
| `Word/scripts/build_l{N}_v{X}_seed.py` | JSON → SQL 빌더 |
| `Word/scripts/patch_seed_{lang}_l{N}.py` | seed.sql in-place 외과 패치 |
| `Word/freq_5k.txt` | top 5000 빈도 reference |
| `Word/lang_{lang}_with_regions.csv` | R1/R2/R3 region 분류 |

### B.2 코드 산출물 (talkverse-learning-flavors/)

| 파일 | 용도 |
|---|---|
| `docs/00-playbook.md` | (구) L1-L6 표준 — 본 _shared/dialogue_principles.md 가 신규 SOT |
| `docs/_share_dialogue_writing_master.md` | (구) dialogue 작성 — 본 문서가 SOT |
| `docs/_share_minority_language_briefing.md` | Light lexicon 정책 |
| `docs/_grammar_planning.md` | 형태론·색칠·morph_tags |
| `docs/_{lang}_session_brief.md` | 신규 언어 진입 30분 결정 12개 |
| `docs/status/status_{lang}.md` | 언어별 최신 상태 |
| `docs/planning/decisions_log.md` | 50+ 결정 누적 |
| `supabase/seed_{lang}.sql` | 통합 SOT |
| `supabase/seed_dialogue_{lang}_l{N}_{north,south}.sql` | standalone INSERT/UPDATE |
| `supabase/_upload_{lang}_seed.sql` | 업로드 (1MB 분할) |
| `supabase/_archive/` | 옛 버전 archive |
| `lib/config/profiles/{lang}_profile.dart` | LanguageProfile |
| `lib/services/scenario_resolver.dart` | VI 5 시나리오 동적 호칭 |
| `lib/widgets/{lang}_morph_text.dart` | 격·성·모음조화 색칠 |
| `assets/data/{lang}/items.json` | USE_LOCAL_DATA 기본 빌드 |
| `assets/audio/tts/{lang}/{north,south}_{male,female}/` | TTS mp3 cache |

### B.3 빌드 검증 명령

```powershell
# 콘텐츠 룸
py vi/Word/scripts/build_l1_v2_seed.py
py vi/Word/scripts/patch_seed_vi_l1.py

# 통계 검증
py vi/scripts/_analyze_vi_token_freq.py

# 코드 빌드
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter build apk --flavor draft --dart-define=APP_FLAVOR=vi --dart-define=DEV_UNLOCK=true
flutter run --flavor vi --target lib/main_vi.dart --dart-define=APP_FLAVOR=vi
```

---

## 마무리

본 문서는 **22 flavor 콘텐츠 룸 공통 dialogue 작성 SOT** (L1-L4).

- **VI 룸** = canonical reference (Mid 완료 + L1 v2.3 + L2 v2.0 + L3 v1 계획 + L4 TBD)
- **VI 검증 룰 → 모든 lang 표준** (2026-05-15):
  - 5 ep × 40 turn (L1) / 23 dial × 5 block (L2-L4)
  - 14 어기조사 분포 + 22 부사 + 14 카오스 카테고리 (L2 reference)
  - **반전 요소 룰** (3.8) — 모든 dialogue 1회 의외성 turn
- **L5·L6 폐지** (2026-05-15) — 본 표준은 L1-L4 만
- **신규 언어 룸** 진입 시: 본 문서 → 30분 결정 12개 (10.1) → L1 trailer → L2 본편 → L3 narrative → L4 TBD 순서
- **변동 시**: 본 파일 갱신 → 다른 메모는 참조만

격리 정책 — 다른 언어 폴더 손대지 X. 본 `_shared/dialogue_principles.md` 만 공통 영역.

작성 출처: 9 메모 종합 (VI 룸 5 + flavors docs 4).
마지막 갱신: 2026-05-15 (L5-L6 폐지 + 반전 요소 룰 추가 + L4 TBD 골격).
