# ja TODO + 결정 큐

> 갱신: 2026-05-17

## 결정 대기 (3가지 — 우선순위 순)

### 1. L1 narrative 컨셉 결정 ⭐

200 turn × 5 ep 컨셉. 선택지:

| 옵션 | 컨셉 | 권장도 |
|---|---|---|
| A | vi 패턴 — 한국 화자 × 일본 화자 데이팅 narrative | ⭐⭐ |
| B | 일본 여행 — 료칸·신사·전철·라멘·관광지 가이드 (한국 화자 × 일본 친구) | ⭐⭐⭐ |
| C | 캠퍼스 — 한국 유학생 × 일본 대학 동기 (경어·반말 자연 전환) | ⭐⭐ |
| D | A+B mix — 데이팅 정서 + 여행지 어휘 흡수 | ⭐⭐⭐⭐ |

→ **D 권장** ([[content-spec]] §"L1 컨셉 옵션" 참조). vi의 narrative 정서 + ja 특수 어휘 자연 도입.

### 2. dialect 분량 배정

`talkverse-lab/ja/north/` + `south/` 둘 다 skeleton. 결정 필요:
- (a) north만 완성 후 south = 어휘 변형판 (mn standard 1개 패턴)
- (b) north L1-L3 + south L1만 (vi 패턴 — 부분 분리)
- (c) north·south 동시 진행

→ **(a) 권장**. 간사이는 종조사·인칭·お疲れ系 어휘 변형 위주, 별도 narrative 불필요.

### 3. JMultiWOZ + RealPersonaChat 분석 수행 시점

vi의 Alpaca 등가물이 **이미 보유** (ja 강점). 분석 옵션:
- (a) **L1 작성 전** 분석 → 어휘 빈도 cross-check 후 L1 설계 (권장)
- (b) L1 작성과 병행
- (c) L2-L3 단계에서 분석

→ **(a) 권장**. mn처럼 chriskempson + JMultiWOZ 4중 비교 (compare A-D) 한 번에 수행.

## A. 즉시 가능 작업 (분석 정리)

### A1. chriskempson top2500 데이터 검토 (1시간)

- R1-R4 단어 카테고리 분류 (조사·종조사·인칭·동사·형용사·기타)
- OCR 노이즈 식별 (27위 尾, 38위 流, 48위 鋳る, 58위 照る, 74위 柄, 77위 増す 등)
- native_top80과 cross-check

### A2. JMultiWOZ 빈도 분석 (2-3시간) ⭐

작업:
1. `DATA_Raw/languages/ja/chat/jmultiwoz-data/JMultiWOZ_1.0/dialogues.json` 파싱
2. 다중턴 발화 어휘 빈도 추출 (top 2,500)
3. chriskempson top 2,500 vs JMultiWOZ top 2,500 교집합 측정 (예상 ≥75%)
4. 도메인별 어휘 분포 (호텔·식당·관광·교통·쇼핑·날씨)
5. 종조사·격조사 분포 cross-check

→ **L2 B2(여행·교통·식당) 어휘 풀 직접 도출**.

### A3. RealPersonaChat 분석 (2시간)

작업:
1. `real_persona_chat/dialogues/*.json` 파싱 (수십~수백 파일)
2. persona 정보 추출 (캐릭터 설계 reference)
3. 어휘 빈도 추출 + chriskempson 교차

→ **L3 narrative persona 풀** 도출.

### A4. 한자 cross-ref 검토 (30분)

- `_shared/hanja_crossref.json` 80 entry 확인
- `_shared/jp_l1_kanji_70.json` 70 한자가 L1 어휘에 충분 등장하는지 점검
- 추가 한자 30개 (cum 100) 후보 선정

## B. L1 작성 (다음 큰 작업)

### B1. 컨셉 결정 (위 결정 1) — 차단

### B2. 5 ep 구조 설계

vi 패턴:
| ep | 라벨 | turn |
|---|---|---:|
| 1 | 만남·인사 | 40 |
| 2 | 일상·소개 | 40 |
| 3 | 친밀·관심 | 40 |
| 4 | 갈등·해결 | 40 |
| 5 | 결합·약속 | 40 |

ja 적용: 일본 여행 컨셉으로 hook (도쿄 만남 → 료칸 1박 → 신사 → 갈등 → 작별/재회).

### B3. 부사·종조사 hook 30 (mn 패턴 차용)

- 부사 12: 今・もう・ちょっと・もしかして・たぶん・きっと・必ず・絶対・だから・でも・けど・なんか
- 종조사 8: よ・ね・か・な・わ・ぞ・さ・し
- 부정·강조 6: ない・なんで・なんて・だって・なんだ・ですか
- 호칭·응답 4: さん・はい・うん・ええ

→ 30 hook × 평균 7회 노출 = 210 turn 안에 자연 분배.

### B4. 어휘 KPI 점검

[[content-spec]] §"L1 어휘 KPI" 참조. R1 등재율 ≥85%, 종조사 8종 모두, 한자 70 코어 모두 등장.

## C. L2 작성

### C1. JMultiWOZ 어휘 풀 활용

- B2 블록 (여행·교통·식당) 직접 활용
- task-oriented 어휘 + 카오스 채팅 mix

### C2. 23 dial × 5 block 마스터 리스트 (vi 패턴)

L2 = 카오스 채팅. vi L2의 14 카오스 카테고리 + 22 부사 + 14 어기조사 그대로 ja 적용.

## D. L3 작성

### D1. 사랑 narrative (vi 패턴 + ja persona)

- RealPersonaChat persona reference
- 5 block 사랑 단계 (만남→교제→갈등→이별/극복→결합)
- 반전 요소 룰 (가짜→진짜 화해 / 말실수 정정 / 갑작스 감정 / 의외 사실 / 카오스)

## E. 챗 코퍼스 활용 옵션

### E1. JMultiWOZ 다중턴 직접 인용 (라이선스 검토 후)

- 학습용 부분 발췌 → 어휘 풀 직접 추출
- 라이선스 확인 필요 (NTT 산하 데이터)

### E2. JMultiWOZ를 reference로만 사용 (안전)

- 빈도 통계 추출 (fair use)
- 도메인별 어휘 풀 도출
- 직접 인용 X, 신규 다이얼로그 작성

### E3. RealPersonaChat persona 모방 (LLM 합성)

- persona 정보만 차용
- ChatGPT/Gemini로 신규 다이얼로그 합성
- mn의 옵션 ②와 유사 (ja는 이미 native 자료 있어 보조용)

## F. dialect (south = 간사이) 후속

### F1. 간사이 어휘 변형 추출

- 北(north) L1-L3 완성 후 변형
- 종조사: ね→なぁ, よ→で, か→かいな
- 인칭: 俺→わて/うち, 私→自分
- 형용사: いい→ええ, ありがとう→おおきに
- 부정: -ない→-へん

### F2. 음운 변형 (옵션)

- 간사이 pitch accent (도쿄와 반대 패턴)
- 음변화 (おそい→おそろしい 등)

## G. TTS 합성

### G1. 엔진 선정

| 엔진 | 장점 | 단점 |
|---|---|---|
| **ElevenLabs ja** | 자연성 ↑, vi와 동일 워크플로 | 비용 |
| **Google Wavenet ja-JP** | 안정, 일본어 native | 자연성 중 |
| **Azure ja-JP** | 캐릭터 다양 (女性/男性/子供) | API 학습 비용 |

→ vi 워크플로 동일성 = ElevenLabs 우선.

### G2. L1 합성 (북부 표준)

- 캐릭터 2-3명 (남성·여성·아동)
- pitch accent 검수 (도쿄 표준)
- 200 turn × ~10초 = 약 33분 오디오

## H. 영구 보존 (Archive)

- 옛 `Word/MD/episodes/Statical/` ja 자료 = 이미 아카이브 완료 (README.md 명시)
- 추가 archive 후보: 분석 산출물의 옛 버전

## I. 우선순위 매트릭스

| 작업 | 시간 | 효과 | 차단 여부 |
|---|---|---|---|
| A1 chriskempson top2500 검토 | 1시간 | OCR 노이즈 식별 | 차단 X |
| A2 JMultiWOZ 빈도 분석 ⭐ | 2-3시간 | L2 어휘 풀 직접 도출 | 차단 X |
| A3 RealPersonaChat 분석 | 2시간 | L3 persona reference | 차단 X |
| A4 한자 cross-ref 검토 | 30분 | L1 한자 70 검증 | 차단 X |
| L1 컨셉 결정 | 결정 | L1 작성 가능 | 차단 ⭐ |
| L1 200 turn 작성 | 1-2일 | 첫 콘텐츠 완성 | 결정 1 |
| L2 23 dial 작성 | 3-4일 | 카오스 채팅 완성 | A2 권장 선행 |
| L3 23 dial 작성 | 3-4일 | 사랑 narrative | A3 권장 선행 |
| dialect south 변형 | 1-2일 | 간사이 확장 | north 선행 |
| TTS 합성 (L1) | 1-2일 | 듣기 학습 | 엔진 선정 |

## 관련 문서

- [[overview]] — 룸 사령탑
- [[cliff-report]] — 절벽·검증
- [[content-spec]] — L1·L2·L3 schema
- [[grammar-frameworks]] — 조사·어미·경어 ko 매핑

## 다음 결정 흐름

```
1. L1 narrative 컨셉 결정 (옵션 A/B/C/D)
2. JMultiWOZ + RealPersonaChat 빈도 분석 (A2+A3)
3. 어휘 풀 cross-check 후 L1 200 turn 작성
4. L2 카오스 채팅 (JMultiWOZ 어휘 활용)
5. L3 사랑 narrative (RealPersonaChat persona 참고)
6. dialect south 변형 (north 완성 후)
7. TTS 엔진 선정 + L1 합성
```
