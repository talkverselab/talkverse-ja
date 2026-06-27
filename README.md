# talkverse-ja

> 일본어 학습 앱 — 신규 단일 앱 (2026-05-17 시작)
> 옛 `D:/OneDrive/PROJECT/talkverse-lab/` monorepo 폐기, JA 만 독립 앱으로.

---

## 한 줄 정리

한국 화자 → 일본어. **Flutter** 단일 앱. **git local-only** (GitHub X). 옛 콘텐츠·DB schema 재사용.

---

## 폴더 구조

```
ja/
├── .git/                    ← local only (GitHub push 안 함)
├── app/                     ← Flutter 앱
│   ├── lib/                   Dart 소스
│   ├── android/               (flutter create 시 생성)
│   ├── ios/                   (옵션)
│   ├── assets/
│   │   ├── audio/             dialogue mp3 (north_*/south_*)
│   │   ├── data/              JSON (L1-L3, wordsets, annotations)
│   │   ├── fonts/             일본어 폰트 (Noto Sans JP 등)
│   │   └── images/
│   ├── test/
│   └── pubspec.yaml
│
├── content/                 ← 학습 콘텐츠 SOT (앱이 참조)
│   ├── north/                 도쿄·표준 (canonical, 우선)
│   │   ├── dialogues/         L1-L3 json + _meta.json
│   │   └── audio/             north_male / north_female mp3
│   ├── south/                 오사카·간사이 (후속)
│   │   ├── dialogues/
│   │   └── audio/
│   ├── wordsets/              words_base / delta / chat_additions
│   └── annotations/           빨간펜 annotation JSON
│
├── db/                      ← 분석 자료 / 옛 데이터 보존
│   ├── corpus/                lang_ja_top2500, native_top80, cliff, hanja_crossref, jp_l1_kanji_70
│   ├── scripts/               JMultiWOZ / RealPersonaChat 빈도 분석 .py
│   ├── notes/                 옛 메모 카피본 (overview, content-spec, grammar-frameworks, cliff-report)
│   └── legacy/                옛 ja-lab TSX 핵심 (포팅 reference)
│
└── README.md                ← 이 파일

# 메모는 별도 폴더
# D:/OneDrive/memo/ja/   ← ADR + 결정 + 작업 로그
```

---

## 원칙

### 1. git local-only
- `git init` 후 local commit 만. **GitHub push 안 함**.
- `.gitignore` 에 audio raw / build artifact 포함.
- 백업 = OneDrive sync (이 폴더가 OneDrive 안에 있음).

### 2. 옛 자료는 read-only reference
- `D:/OneDrive/PROJECT/talkverse-lab/ja/` = 옛 콘텐츠 SOT, 신규 앱이 수정 X.
- `D:/OneDrive/PROJECT/talkverse-lab/apps/ja-lab/` = 옛 TSX 앱, 포팅 reference 만.
- `D:/OneDrive/memo/03-Languages/ja/` = 옛 메모, read-only.
- 수동 cherry-pick: 필요할 때만 신규 폴더로 복사.

### 3. 차별화 (옛 brand 룰 그대로)
- "영어 우회 X" — 영어 통하는 phrase 안 가르침
- 한국 화자 한정 — 번역·예시 모두 한국어 기반 (조사·종조사·경어 1:1 매핑)
- L1 narrative (data) / L2 카오스 채팅 / L3 사랑 narrative

### 4. UX 전면 재설계
- 옛 vi-lab 패턴 (dating narrative + 14 어기조사) 답습 X.
- 일본어 특수성 우선: kana_chart / kanji_cards / katakana_reader / pitch_accent 화면 신규.
- 옛 ja-lab `app/*.tsx` (index, main, conversation_200, chat_dialogue_*, adverbs_200, tone_practice, textbook, profile, adverbs_200) = reference, 그대로 포팅 X.

### 5. dialect = north/south split
- **north (도쿄·표준) 우선** 완성.
- south (간사이) = 어휘·종조사 변형판으로 후속.
- 음성 합성 = north 우선 (TTS 엔진 결정 후).

---

## Stack

| | |
|---|---|
| Framework | Flutter 3.27+ |
| Language | Dart 3.6+ |
| State | Riverpod |
| Audio | just_audio |
| Storage | shared_preferences (옛 AsyncStorage 키 schema 동일 유지) |
| Routing | go_router |
| Targets | Android (우선), iOS (옵션) |
| Fonts | Noto Sans JP / Noto Serif JP (한자·가나) + Pretendard (한국어) |

---

## "DB" 재사용 범위 (4종 — ADR 0003 참조)

1. **AsyncStorage → shared_preferences 동일 키** (WordReviews / FavoriteWords / UserStats / UserMemo / AnnotationOverride)
2. **콘텐츠 JSON schema** (ja/kana/romaji/ko/key + annotations 필드)
3. **분석 데이터** (chriskempson top2500, native_top80, R1-R4 cliff, hanja 80, jp_l1_kanji_70, JMultiWOZ, RealPersonaChat)
4. **audioMap** (옛 mp3 있다면 그대로, 없으면 신규 합성)

---

## 작업 계획 (M0 ~ M3)

### M0 — Bootstrap (현재)
- ✅ 폴더 하이어라키
- ⏭ git init (local)
- ⏭ `flutter create` 또는 수동 `pubspec.yaml`
- ⏭ 옛 자료 Phase A import (메타, 분석 CSV, 한자 ref, 옛 메모 카피)

### M1 — MVP 화면
- 홈 (lang 단일 = 메인 진입 단순)
- kana_chart / katakana_reader (사전 학습)
- L1 conversation viewer (200 turn) — L1 콘텐츠 미완 단계에선 _meta + sample turn 만
- 오디오 재생 (north male/female 토글)
- shared_preferences SRS 토대

### M2 — 빨간펜 시스템
- Flutter 로 AnnotatedText 재구현
- AnnotationOverride (shared_preferences)
- MemoButton + Export → Clipboard
- L1 자동 추출 스크립트 (Python or Dart)

### M3 — L2/L3 + TTS
- L2 카오스 채팅 화면 (JMultiWOZ task-oriented 어휘 풀 활용)
- L3 사랑 narrative (RealPersonaChat persona reference)
- TTS 합성 (ElevenLabs ja or Google Wavenet ja-JP)
- 본인 폰 검수 cycle (long-press → export → Claude 적용)

---

## 옛 monorepo 참조 경로

| 자료 | 옛 위치 |
|---|---|
| dialogues skeleton | `D:/OneDrive/PROJECT/talkverse-lab/ja/{north,south}/dialogues/_meta.json` |
| 옛 TSX 화면 | `D:/OneDrive/PROJECT/talkverse-lab/apps/ja-lab/app/*.tsx` |
| 옛 services (AsyncStorage) | `D:/OneDrive/PROJECT/talkverse-lab/apps/ja-lab/services/*.ts` |
| 옛 components (빨간펜) | `D:/OneDrive/PROJECT/talkverse-lab/apps/vi-lab/components/AnnotatedText.tsx` (vi-lab 가 canonical) |
| 분석 CSV | `D:/OneDrive/BOOKS/_assets/data/lang_ja_*` |
| 한자 ref | `D:/OneDrive/PROJECT/talkverse-lab/rules/hanja_crossref.json`, `_shared/jp_l1_kanji_70.json` |
| JMultiWOZ | `D:/OneDrive/DATA_Raw/languages/ja/chat/jmultiwoz-data/JMultiWOZ_1.0/dialogues.json` |
| RealPersonaChat | `D:/OneDrive/DATA_Raw/languages/ja/chat/real-persona-chat-data/` |
| 옛 메모 (read-only) | `D:/OneDrive/memo/03-Languages/ja/` |
| 신규 메모 vault | `D:/OneDrive/memo/ja/` |

---

_갱신: 2026-05-17_
