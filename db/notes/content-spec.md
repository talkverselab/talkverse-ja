# ja 콘텐츠 명세 (L1·L2·L3)

> 갱신: 2026-05-17
> Schema 버전: v4 (vi canonical 동일)

## 상태 종합

| 레벨 | 상태 | 분량 | 형식 |
|---|---|---|---|
| L1 | ⚪ skeleton (_meta.json만) | 5 ep × 40 turn = 200 | narrative |
| L2 | ⚪ skeleton (_meta.json만) | 23 dial × 5 block ≈ 300 | 카오스 채팅 |
| L3 | ⚪ skeleton (_meta.json만) | 23 dial × 5 block ≈ 304 | 사랑 narrative |
| L4 | ⚪ TBD | TBD | TBD |
| L5/L6 | ❌ 폐지 | — | `_shared/dialogue_principles.md` |

## Dialect 정책

```
talkverse-lab/ja/
├── north/dialogues/   ← 도쿄·표준 (canonical, 우선)
└── south/dialogues/   ← 오사카·간사이 (후속)
```

JA dialect 격차 = vi(N/S) 대비 작음. **north 우선 완성 후 south 변형**. 어휘 차이 위주 (간사이 종조사·인칭·お疲れ系 등).

## Schema (turn 단위 — v4 canonical)

```json
{
  "num": 1,
  "speaker": "A",
  "ja": "今、ちょっと行ってくる。",
  "kana": "いま、ちょっといってくる。",
  "romaji": "Ima, chotto itte kuru.",
  "ko": "지금 잠깐 다녀올게.",
  "key": "今(いま, 지금), ちょっと(잠깐), -てくる(다녀오다)"
}
```

필드:
- `num`: turn 순번
- `speaker`: A/B (L1 narrative는 캐릭터명 가능)
- `ja`: 정본 한자+가나 혼용 표기
- `kana`: 히라가나 표기 (발음 학습용)
- `romaji`: 로마자 (옵션, 초급 ep만)
- `ko`: 한국어 자연 의역
- `key`: 어휘·문법 메모 (한자 음·뜻 + 문법 포인트)

→ vi의 `pron` ToneCurve와 달리 ja는 **kana + pitch accent**가 발음 cue.

## L1 (200 turn, 5 ep × 40)

### 컨셉 옵션 (결정 대기)

| 옵션 | 컨셉 | 장점 | 단점 |
|---|---|---|---|
| A. vi 패턴 | 한국 화자 × 일본 화자 데이팅 narrative | canonical 정합 | 일본 특수성 부족 |
| B. 일본 여행 | 한국 화자 × 일본 친구 가이드 (료칸·신사·전철·라멘 등) | 일본 특수 어휘 자연 도입 | 데이팅 정서 약함 |
| C. 캠퍼스 | 한국 유학생 × 일본 대학 동기 | 경어·반말 자연 전환 | 좁은 시나리오 |

→ **vi 패턴 + 일본 여행 mix** 권장. 5 ep narrative에 일본 특수성 흡수.

### 부사·종조사 hook (mn 부사 30 패턴 차용 옵션)

option: L1에 부사·종조사 hook 30개를 분산 노출 (mn처럼). 후보:
- 부사 12: 今・もう・ちょっと・もしかして・たぶん・きっと・必ず・絶対・だから・でも・けど・なんか
- 종조사 8: よ・ね・か・な・わ・ぞ・さ・し
- 부정·강조 6: ない・なんで・なんて・だって・なんだ・ですか
- 호칭·응답 4: さん・はい・うん・ええ

→ 30 hook × 평균 7회 = 210 turn 노출 (200 turn 안에 자연 흡수).

### 어휘 KPI (L1)

| 지표 | 목표 |
|---|---|
| R1 등재율 (top 294) | ≥ 85% |
| 종조사 분포 | 8종 모두 등장 |
| 한자 노출 | 70 코어 한자 (`_shared/jp_l1_kanji_70.json`) 모두 ≥1회 |
| 평균 turn 길이 | 8-12 문자 (kana 환산) |
| 의문문 비율 | 25-30% |
| 경어 비율 | 정중체 50% / 보통체 50% (ep별 분기) |

## L2 (≈300 turn, 23 dial × 5 block)

### 컨셉

**카오스 채팅** (vi canonical 패턴). 14 카오스 카테고리 + 22 부사 + 14 어기조사 = vi 룰 그대로 ja 적용.

### Block 후보 (vi 패턴)

| Block | 테마 후보 | dial 수 |
|---|---|---:|
| B1 | 일상 채팅 (인사·근황·날씨) | 4-5 |
| B2 | 여행·교통·식당 | 5-6 |
| B3 | 관계·감정·갈등 | 4-5 |
| B4 | 일·학교·취미 | 4-5 |
| B5 | 카오스·반전 | 3-4 |

### JMultiWOZ 활용 ⭐

`DATA_Raw/languages/ja/chat/jmultiwoz-data/JMultiWOZ_1.0/dialogues.json` = task-oriented 다중턴.

도메인: 호텔·식당·관광·교통·쇼핑·날씨 — **L2 B2(여행·교통·식당) 직접 활용 가능**.

→ vi의 어휘 풀 합성 작업 없이 실제 native 다중턴 채팅 빈도 확보.

### 어휘 KPI (L2)

| 지표 | 목표 |
|---|---|
| R1+R2 등재율 (top 437) | ≥ 80% |
| L1 hook 30 재노출 | ≥ 20종 |
| 종조사 분포 8종 | 모두 ≥ 3회 |
| 한자 노출 추가 | +50 (cum 120) |
| 평균 turn 길이 | 10-15 문자 |

## L3 (≈304 turn, 23 dial × 5 block)

### 컨셉

**사랑 narrative** (vi canonical). 5 block 사랑 단계 진행. vi L3 = 만남→교제→갈등→이별/극복→결합.

### RealPersonaChat 활용

`DATA_Raw/languages/ja/chat/real-persona-chat-data/.../dialogues/00001~.json` = persona 기반 일상 채팅.

→ L3 narrative에서 캐릭터 persona 설계 reference. 어휘 풀은 L2와 동일.

### 반전 요소 룰 (vi 차용)

- 가짜→진짜 화해
- 말실수 정정
- 갑작스 감정 표출
- 의외 사실 공개
- 카오스 (vi의 14 카테고리)

## L4 (TBD)

vi에 없음 → ja-only 확장 후보. 옵션:
- 경어 심화 (존경어/겸양어/정중어 분리)
- 한자 심화 (음독·훈독 패턴)
- pitch accent 훈련

## 어휘 정책 종합

| 우선순위 | 어휘 풀 | 출처 |
|---|---|---|
| 1순위 | R1 (top 294) | `lang_ja_with_regions.csv` |
| 2순위 | R2 (top 295-437) | 동상 |
| 3순위 | native_top80 종조사·인칭·응답 | `lang_ja_native_top80.csv` |
| 4순위 | 한자 코어 70 | `_shared/jp_l1_kanji_70.json` |
| 5순위 | JMultiWOZ 다중턴 빈출 (분석 후) | DATA_Raw 챗 |
| 예외 | 자연 보강 (native 인정) | 자율 |

→ vi 룸과 동일: **자연성 ≥ 통계**.

## 일본어 학습 화면 (lab/apps/ja-lab/)

vi-lab 복제 + ja 확장:
- index, main, conversation_200, chat_dialogue_*, adverbs_200, tone_practice, textbook (vi 동일)
- **+ kana_chart, kanji_cards, katakana_reader, l1** (JA 확장)

→ vi-lab 보다 화면 4개 추가. 한자·가나 학습 보조.

## 관련 문서

- [[overview]] — 룸 사령탑
- [[cliff-report]] — 절벽·검증
- [[grammar-frameworks]] — 조사·어미·경어 ko 매핑
- [[todo]] — 다음 작업
- [[_shared/dialogue_principles]] — Main 14 lang 표준 (960 줄)
