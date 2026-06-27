# ja (일본어) — 룸 사령탑

> 갱신: 2026-05-17
> 카테고리: Main 14 (canonical 후보 — vi와 함께 SOT 그룹)

## 한 페이지 요약

Talkverse ja 룸. 한국어 화자 대상 일본어 학습. **한국어 1:1 매핑이 이상적으로 강한 언어** (어순 SOV·조사 매핑·교착어·경어 체계 동일). v4 schema 적용 (L1 5ep×40 / L2 23dial / L3 23dial). 현재 skeleton만 (north/south _meta.json 골격), 콘텐츠 미작성.

## 콘텐츠 위치

```
talkverse-lab/ja/
├── README.md                       ← 룸 핸드오프 (2026-05-15)
├── north/dialogues/_meta.json      ← 도쿄·표준 (TBD)
└── south/dialogues/_meta.json      ← 오사카·간사이 (TBD)
```

옛 자료 (`Word/MD/episodes/Statical`) = 아카이브 완료, 새 출발.

## 현재 상태

| 항목 | 상태 |
|---|---|
| L1 콘텐츠 | ⚪ skeleton만 (_meta.json만 존재, dialogue 0) |
| L2 콘텐츠 | ⚪ skeleton만 |
| L3 콘텐츠 | ⚪ skeleton만 |
| 어휘 빈도 분석 | 🟢 chriskempson 12,277편 자막 → top 2,500 + native top 80 |
| 절벽 분석 | 🟢 R1=294 / R2=437 / R3=998 / R4=2,500 도출 |
| 챗 코퍼스 | 🟢 JMultiWOZ + RealPersonaChat 확보 (대용량 다중턴) |
| TTS | ⚪ 미합성 (ElevenLabs ja or Google Wavenet ja-JP 후보) |
| dialect | 🟡 north=표준, south=간사이 — 격차 작음, north 우선 |

## 핵심 자산

### 어휘 데이터 (BOOKS/_assets/data/)
- `lang_ja_native_top80.csv` — chriskempson 자막 top 80 (조사·종조사·기초어휘)
- `lang_ja_top2500.csv` — chriskempson 자막 top 2,500 (정본)
- `lang_ja_wordfreq_top2500.csv` — wordfreq lib 백업 (subtitle+wiki+web+twitter 혼합)
- `cliff_region_data/lang_ja_with_regions.csv` — 2,500어 R1-R4 라벨 부착

### 챗 코퍼스 (DATA_Raw/languages/ja/chat/)
- **JMultiWOZ_1.0** — 멀티도메인 다중턴 task-oriented (호텔·식당·관광·교통·쇼핑·날씨) ⭐
- **RealPersonaChat 1.0.0** — persona 기반 다중턴 일상 채팅 + LLM 변형 (GPT-3.5/GPT-4 with persona/personality)

→ **mn 부재 자원**(다중턴 챗)이 ja에는 풍부. vi 수준 검증 가능.

### 검증 데이터
- `_shared/hanja_crossref.json` — 80 entry 한자 4-way (ja-kanji ↔ zh-simp/zh-trad ↔ ko-hanja)
- `_shared/jp_l1_kanji_70.json` (코어 70 한자) — hanja_crossref 소스

## 핵심 발견

| 발견 | 출처 |
|---|---|
| ja top1000 누적 **70.3%** (17 lang 중 동급 top4) | all17_cliff_summary |
| top1 단어 **の (4.46%)** — 조사 압도적 | top2500 |
| top10 누적 **18.3%** — 조사·종조사 코어 매우 작음 | all17 |
| R1 = **294 어** (회화 골격), R2 = +143 = 437, R3 = 998, R4 = 2,436 | with_regions |
| 종조사 **よ·ね·か·な·わ·ぞ** 모두 top80 진입 (자막체 강함) | native_top80 |
| 인칭 다양 — 私·俺·僕·あなた·お前·君 모두 top80 | native_top80 |
| 챗 코퍼스 **JMultiWOZ + RealPersonaChat** 확보 = vi 수준 다중턴 검증 가능 ⭐ | DATA_Raw |

## ja 특성 (요약)

1. **표기 3종**: 한자(漢字) + 히라가나(ひらがな) + 가타카나(カタカナ)
2. **교착어 SOV** — 한국어와 동일 구조
3. **조사 1:1 매핑**: は=은/는, が=이/가, を=을/를, に=에/에게, で=에서, から=부터/에서, と=와/과, へ=로
4. **종조사 회화 톤 핵심**: ね(공감) · よ(알림) · か(의문) · な(독백) · わ(부드러움) · ぞ(강조) · さ(말꼬리)
5. **경어 3단**: 정중체(です/ます) · 보통체(だ/る) · 존경/겸양 — 한국어 합쇼체/해요체/반말 매핑
6. **pitch accent (도쿄 高低)** — vi tone과 유사하지만 의미 구별 부담 ↓
7. **한자 음독/훈독** — 동일 한자가 2발음 (ko·zh와 cross-ref 가능)

## 진행 중 결정 (3가지)

1. **L1 narrative 컨셉** — vi처럼 데이팅 스토리 (한국 화자 × 일본 화자) vs ja 특수 (료칸·여행·캠퍼스 등). 5ep × 40turn 골격은 확정.
2. **dialect 분량 배정** — north(표준) 우선, south(간사이)는 후속. mn의 standard 단일과 vi의 N/S 분리 사이.
3. **챗 코퍼스 활용도** — JMultiWOZ task-oriented(L2 카오스 채팅 직접 활용 가능) + RealPersonaChat persona(L3 narrative reference).

상세는 [[todo]].

## 관련 문서

- [[cliff-report]] — 절벽 R1-R4·검증
- [[content-spec]] — L1/L2/L3 schema·dialect 정책
- [[grammar-frameworks]] — 조사·어미·경어 ko 1:1 매핑
- [[todo]] — 다음 단계
- [[_shared/dialogue_principles]] — Main 14 lang 표준 (960 줄)
- [[_shared/hanja_crossref_schema]] — 4-way 한자 cross-ref

## mn 룸과의 차이

| | mn (Discover, 무료) | ja (Main 14, 유료 후보) |
|---|---|---|
| 카테고리 | Discover | Main 14 (canonical 후보) |
| L1 형식 | 나열 (부사 hook × 반복) | 다이얼로그 narrative (5ep×40) |
| 어휘 검증 | 4중 비교 (챗 X) | top2500 + native_top80 + 챗 2종 확보 |
| 한국어 매핑 | 조사·어미 강함 (교착어 동족) | **이상적 1:1** (조사·어미·경어·SOV 모두 매핑) |
| 표기 | 키릴 1종 | 한자+히라가나+가타카나 3종 |
| dialect | standard 1개 | north(표준) + south(간사이) 2개 |
| 챗 코퍼스 | 부재 (옵션 ②로 합성 검토) | JMultiWOZ + RealPersonaChat 보유 ⭐ |
| TTS | 미합성 | 미합성 (ElevenLabs ja or Google ja-JP) |

vi 자료 위치: `talkverse-lab/vi/` (canonical reference).
