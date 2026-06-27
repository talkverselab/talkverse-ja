# Corpus & Wordset 작업 표준

> 각 lang 룸 운영자가 본인 lang 의 wordset 만들 때 따라하는 표준.
> VI 룸의 경험을 일반화. lang 별 결과 (수치·단어) = `{lang}/notes/corpus_report.md`.

---

## 1. 핵심 원칙

**800 단어 + 청크 = 영어 1,500 단어 동등** (학습 부담).

→ 빈도 50,000 단어 다운 + cliff 분석으로 800 cut-off + 청크 보강.

---

## 2. 5-corpus 교차 검증

가능한 한 5 종류 corpus 비교 (lang 별로 사용 가능 set 다름):

| Corpus | 도메인 | 적용 |
|---|---|---|
| **OPUS OpenSubtitles** | 자막 (회화) | 모든 lang ★ |
| **Tatoeba** | 일상 회화 | 30+ lang |
| **Alpaca / WuDaoCorpus** | 채팅 | EN/ZH |
| **PhoMT (VI)** / WMT 다른 lang | 다양 | 도메인 비교용 |
| **AIHub (KR/VI)** | 사회·정치 (격식) | KR + VI 만 |
| **단국대 표준교재** | 학습용 정제 | 검증용 |

VI 결과 예시:
- OPUS R4 (80%) = 519 단어 (남부 746)
- Alpaca = 856 단어 (+14.7%)
- AIHub = 942 (한자어 청크 56.9%)

---

## 3. 빈도 추출 (50k → 5k)

```python
# Leipzig OpenSubtitles freq_5k.txt (lang 별)
url = f"https://wortschatz.uni-leipzig.de/.../{lang}-..."
# top 50,000 → freq_50k.txt
# top 5,000 → freq_5k.txt
```

저장: `{lang}/data/corpus/freq_5k.txt`, `freq_50k.txt`

---

## 4. Cliff 분석 (R1-R4)

누적 % 기준 단계:

| 단계 | 누적 % | VI 예시 |
|---|---|---|
| R1 | 55% | 120 단어 |
| R2 | 60% | 158 |
| R3 | 70% | 279 |
| R4 | 80% | 519 |

→ R3-R4 사이 "cliff" 가파른 정도 = lang 별 학습 부담 측정.

### lang 별 cliff (R3 → R4 배율)

| Lang | 배율 | 학습 난이도 |
|---|---|---|
| VI | 1.86× | ★ 가장 완만 |
| TH | 2.28× | ★★ |
| KR | 2.21× | ★★ |
| JA | 2.28× | ★★ |
| EN | 2.65× | ★★★ |

낮을수록 = 800 단어로 더 많이 cover.

---

## 5. 청크 (chunk) 식별 기준

단순 단어 외 의미 단위:

### 5.1 한자어 청크 (CJK lang)
- `ví_dụ`, `bao_gồm`, `phát_triển` (VI)
- `例如`, `包括`, `发展` (ZH)
- 밑줄 표기 (split 방지)

### 5.2 관용구 / 구문 청크
- `thấy buồn cười` (VI: 우습다고 느끼다)
- `수 있다`, `것 같다` (KR)
- 의미 단위 ≠ 단어 단위

### 5.3 어기조사·호칭 청크
- `anh à`, `em ơi` (VI: 친밀 부름)
- `~です`, `~ます` (JA)

### 추출 도구
- VI: `underthesea.word_tokenize`
- JA: MeCab + 한자어 mapping
- KR: KoNLPy + chunk parser
- ZH: jieba

저장: `{lang}/data/wordsets/{lang}_chunks.json` (밑줄 표기 + count)

---

## 6. wordset schema (3-tier)

```json
// {lang}/data/wordsets/words_base.json
{
  "lang": "vi",
  "kind": "base",
  "source": "subtitle_base (OPUS + freq_5k)",
  "count": 746,
  "notes": "양 방언 공통. R1-R4 누적 80%.",
  "words": [
    { "word": "tôi", "rank": 1, "is_chunk": false, "source": "subtitle_base" },
    ...
  ]
}
```

3 tier:
- **base** (R1-R4, ~800): subtitle 빈도 SOT
- **delta**: 콘텐츠 (dialogue) 에서 추가 등장
- **chat_additions**: 채팅 (L2) 한자어 청크 등 별도 분류

---

## 7. 검증 기준

| 항목 | 목표 |
|---|---|
| 다른 corpus 매칭률 | ≥ 95% (R3 단어가 다른 corpus 에 등장) |
| 어기조사 14 종 (lang 별) | 모두 wordset 안 |
| 호칭 7-10 종 | 모두 wordset 안 |
| 청크 식별률 | ≥ 80% (전문 사전 또는 native 검수) |

---

## 8. REPORT 형식

### `{lang}/notes/REPORT_phase1.md`

```
# {Lang} Wordset Phase 1 — 빈도 분석 + cliff

## 자료
- corpus: OPUS, Alpaca, ...
- 50k → 5k

## Cliff (R1-R4)
| 단계 | 누적 % | 단어 수 |
| ... | ... | ... |

## 도메인 비교
| corpus | R4 단어 | 차이 |
| ... | ... | ... |

## 다른 lang 비교
| Lang | R3→R4 | 비고 |
| ... | ... | ... |

## R1 top 30
...
```

### `{lang}/notes/REPORT_FINAL.md`

```
# {Lang} Wordset Final — 마케팅·검증

## 800 단어 = 영어 1,500 동등
## 한자어 청크 ~120 (lang 별)
## 어기조사 + 호칭 100% 포함
## 마케팅 카피
```

VI 예시: `vi/notes/REPORT_FINAL.md` + `REPORT_phase1.md` (이미 작성).

---

## 9. 작업 순서 (lang 별)

```
1. Leipzig {lang} freq_5k.txt 다운        → data/corpus/
2. corpus 추가 (Alpaca / AIHub / 단국대)  → data/corpus/
3. cliff 분석 스크립트 실행                → REPORT_phase1.md
4. 청크 식별 (underthesea / MeCab / jieba)  → data/wordsets/{lang}_chunks.json
5. base wordset 확정 (R1-R4 ~800)         → data/wordsets/words_base.json
6. dialogue 작성 → delta wordset            → data/wordsets/words_delta.json
7. 검증 (매칭률 / 어기조사·호칭 cover)
8. REPORT_FINAL.md 작성                    → notes/REPORT_FINAL.md
```

---

## 10. 산출물 위치 정합성

| 자료 | 위치 |
|---|---|
| 빈도 raw | `{lang}/data/corpus/freq_5k.txt + freq_50k.txt` |
| 청크 추출 | `{lang}/data/wordsets/{lang}_chunks.json` |
| wordset (base/delta/chat) | `{lang}/data/wordsets/words_*.json` |
| 분석 스크립트 | `{lang}/data/scripts/*.py` |
| 분석 보고서 | `{lang}/notes/REPORT_phase1.md + REPORT_FINAL.md` |
| dialogue 학습 SOT | `{lang}/{north,south}/dialogues/L1-L3.json` |

---

## 11. lang 별 특수 메모

- **VI**: 6 성조, north/south dialect (50 marker), 한자어 청크 25%+
- **ZH**: 4성 + 경성, 간체/번체/대만 3-way, 양사 핵심
- **JA**: pitch accent, 음독/훈독, 가나/한자 혼용
- **KR**: 격조사, 존댓말 단계, 한자어 50%+
- **TH**: 5성, 단어 경계 없음 (tokenizer 필수)

각 lang notes/quirks.md 에 자세히.

---

## 12. VI canonical 예시

`vi/notes/REPORT_FINAL.md` + `vi/notes/REPORT_phase1.md` = 이 표준의 첫 적용 사례. 다른 lang 운영자는 동일 패턴 따라가기.

---

_관련: rules/dialogue_principles.md (L1-L4 표준), rules/tts.md (합성)_
