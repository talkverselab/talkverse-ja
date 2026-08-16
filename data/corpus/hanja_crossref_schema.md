---
title: hanja_crossref.json schema (v4)
generated: 2026-05-15
supersedes: talkverse-learning-flavors/assets/data/_shared/hanja_master.json (empty `[]` — 미사용)
---

# hanja_crossref.json 신규 schema 설명

## 결정 (2026-05-15)

- **id 체계**: `hanja:NNNN` sequential (0001, 0002, ...). 버전 간 stable.
- **목적**: ZH·JA·KO 룸 vocab 분석 cross-lookup **reference only**. 학습 X.
- **소스**: JP top kanji freq (`jp_l1_kanji_70.json` 2026-05-11) + 한국·중국 common hanja 보완.

## 옛 hanja_master.json 와의 차이

| 항목 | 옛 hanja_master | 신 hanja_crossref |
|---|---|---|
| **파일 상태** | `[]` 빈 array — 미사용 | 80 entry seed (확장 가능) |
| **위치** | `talkverse-learning-flavors/assets/data/_shared/` (코드 산출물) | `talkverse-lab/_shared/` (콘텐츠 룸 SOT) |
| **id 체계** | 미정 (스키마 없음) | `hanja:NNNN` sequential 명시 |
| **cross-ref** | 단일 한자 1개 column 추정 | zh_simp / zh_trad / ja_kanji / ko_hanja 4-way |
| **용도** | 학습용 hanja 메뉴 (LanguageProfile hasHanjaSupport) | **reference only** — 학습 메뉴 X |
| **scope** | L1-L6 학습 대상 | L1-L4 표준에서 학습 X. 검수 cross-lookup 만 |
| **freq** | 없음 | JP conversation freq rank (1=최상위) — JP 룸 우선 적용 |
| **meaning** | 영어 또는 중문 추정 | `meaning_ko` 한국어 "뜻 음" 형식 (e.g. "사랑 애") |

## entry 스키마

```json
{
  "id": "hanja:0001",
  "ko_hanja": "事",
  "ko_hanja_yumeum": "사",
  "zh_simp": "事",
  "zh_trad": "事",
  "ja_kanji": "事",
  "meaning_ko": "일 사",
  "freq_rank": 1
}
```

| 필드 | 타입 | 의미 |
|---|---|---|
| `id` | string | `hanja:NNNN` 4자리 zero-padded. unique primary key. |
| `ko_hanja` | string | 한국 전통 한자 (정자) |
| `ko_hanja_yumeum` | string | 음 (한 글자) |
| `zh_simp` | string | 중국 간체 (PRC) |
| `zh_trad` | string | 중국 번체 (TW/HK) — 주로 `ko_hanja` 와 동일 |
| `ja_kanji` | string | 일본 신자체 (현대) |
| `meaning_ko` | string | "뜻 음" 형식 (e.g. "사랑 애") — 한국 화자 직관 |
| `freq_rank` | int / null | JP top-150 R4 회화 freq rank. null = 미랭크 (보완 entry) |

## 현재 entry (80개) 구성

- **rank 1~70**: JP top kanji freq (jp_l1_kanji_70.json 의 70 kanji 1:1 매핑)
- **rank null (보완 8개)**: 한국 화자 직관 high-freq 한자 (愛 國 韓 學 語 心 水 火 月 山) — JP freq 외 보강

## 확장 시 추가 entry 룰

1. `id` = `hanja:NNNN` 다음 sequential 번호 (`hanja:0081` 부터)
2. `freq_rank` = 새 freq 기준 시 표기 / 없으면 null
3. 한 자 = 1 entry. 변형 form 은 zh_trad/zh_simp/ja_kanji 분리 컬럼만으로 표현
4. 이체자 (이형 한자, 예: 国/國) = ja_kanji = 신자체, zh_trad = 정자, ko_hanja = 정자 표기

## 참조 외 활용 금지

- ❌ 학습 메뉴 노출 X (사용자 결정 2026-05-15)
- ❌ LanguageProfile `hasHanjaSupport => true` 의존 X
- ❌ TTS 합성 대상 X
- ✅ ZH/JA 룸 vocab 검수 시 cross-lookup
- ✅ 학습자 (한국어 native) 가 ja/zh 어휘 만났을 때 한자 hint 표시 (reference)
- ✅ 통계 분석 (freq cross-corpus)
