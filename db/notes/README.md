# Talkverse Content Room - JA (구 JP)

Room ID: `TALKVERSE_CONTENT_JA`
Content dir: `C:\Users\Johnjeon\OneDrive\PROJECT\talkverse-lab\ja\`
Chat dir: `C:\Users\Johnjeon\.claude\projects\C--Users-Johnjeon-OneDrive-PROJECT-talkverse-lab-ja\`
(주의: .claude/projects 는 OneDrive 의 `claude-sessions/projects/` 로 junction — 다중 머신 동기화)

## 실행 방법

```powershell
cd C:\Users\Johnjeon\OneDrive\PROJECT\talkverse-lab\ja
claude
```

## Sessions (UUID = jsonl 파일명)

| sessionId | size | last activity |
|---|---|---|
| `9da330f6-2f43-4996-af7c-2c79e7b1d4dd` | 3.48MB | 2026-05-11 23:00 |

재개:  `claude --resume <sessionId>` (가장 최근 = 첫 row)

## 이름 변경 이력 (2026-05-12)

- 폴더: `jp` → `ja` (flavor 표준 `ja` 정합)
- 세션 dir: `D--OneDrive-PROJECT-talkverse-lab-jp` → `C--Users-Johnjeon-OneDrive-PROJECT-talkverse-lab-ja`
- jsonl 내부 cwd: `D:\OneDrive\PROJECT\talkverse-lab\jp` → `C:\Users\Johnjeon\OneDrive\PROJECT\talkverse-lab\ja` (1,109 occurrences patched)
- 정답: laptop canonical (C:\Users\Johnjeon\OneDrive). PC(D:) 또는 Mac 측 사용 시 별도 junction 필요.
- 이전 이력: 옛 cwd `D:\OneDrive\PROJECT\talkverse-lab\JP` → `talkverse-lab\jp` (2026-05-11) → `talkverse-lab\ja` (2026-05-12).

## 백업 위치 (2026-05-12 rename 직전)

`C:\Users\Johnjeon\claude-session-backup-2026-05-12\D--OneDrive-PROJECT-talkverse-lab-jp\` — 복구 필요 시 사용.

---

# JA 룸 핸드오프 — 일본어 학습 콘텐츠

> 작성: 2026-05-15 (VI 룸에서 cross-lang v4 마이그레이션 후)
> 너는 일본어 룸 운영자. 일본어 콘텐츠만 작성. 다른 lang 폴더 절대 손대지 X.

---

## 1. 위치 & 격리

```
talkverse-lab/ja/                    ← 너의 룸 (여기만 작업)
├── README_ROOM.md
├── north/dialogues/L1.json + L2.json + L3.json + _meta.json (L4 = TBD)
└── south/dialogues/...
```

옛 자료 (`Word/MD/episodes/Statical`) = 다 archive 됨 → 삭제. 새 출발.

## 2. v4 schema

- **L1**: 5 ep × 40 turn = 200 turn (narrative 데이팅 또는 lang 맞춤 컨셉)
- **L2**: 23 dial × 5 block ≈ 300 turn (카오스 채팅)
- **L3**: 23 dial × 5 block ≈ 304 turn (사랑 narrative)
- **L4**: TBD (현재 골격만)
- **L5/L6**: 폐지 (`_shared/dialogue_principles.md` 명시)

## 3. dialect

JA = north (도쿄·표준) / south (오사카·간사이) 2개. 단 격차 크지 않음 — 우선 표준 (north) 부터.

## 4. canonical = VI 룸 참고

`talkverse-lab/vi/` 가 SOT. 패턴 참고:
- 5 ep dating narrative (John ↔ Linh/Mai/Trang/Hương)
- 23 dial chaos chat (5 block)
- 23 dial love narrative (5 block)
- 반전 요소 룰 (가짜→진짜 화해 / 말실수 정정 / 갑작스 감정 / 의외 사실 / 카오스)
- 14 어기조사 + 22 부사 + 14 카오스 카테고리

JA 적용 시:
- 일본인 화자 ↔ 한국 화자 narrative 가능 (예: 일본 여행, 일본 친구)
- 어기조사 → ね/よ/か/さ/わ/ぞ/ぜ/かな/かしら 등
- 호칭 → 君/さん/先輩/後輩/お兄さん 등
- 격조사 = 핵심 차별 (を/に/が/で → 한국어 을/를/에/이/에서)

## 5. 일본어 특수성

### 한자 (kanji)
- `_shared/hanja_crossref.json` = 80 entry (zh-simp/zh-trad/ja-kanji/ko-hanja cross-ref) 참고
- JA 한자 = 음독/훈독 2 발음 + 의미. 학습 콘텐츠에 한자 vocab 포함

### 가나 (kana)
- 히라가나/카타카나 alphabet 화면 = `lab/apps/ja-lab/app/kana_chart.tsx` (이미 scaffold)
- 카타카나 reader = `lab/apps/ja-lab/app/katakana_reader.tsx`
- JA 만의 화면 (kanji_cards, kana_chart, katakana_reader) 가 vi-lab 보다 많음

### Pitch accent
- 도쿄 表音 (高低) — 단어 별 액센트
- VI 의 tone 처럼 단어 학습 시 표시 권장

## 6. 자료 위치 (참고)

- 원시 코퍼스: `D:/OneDrive/DATA_Raw/languages/ja/` (있는지 확인)
- 빈도 자료: Leipzig JA OpenSubtitles freq_5k.txt
- 코어 어휘 메모: `_shared/jp_l1_kanji_70.json` (70 한자) — hanja_crossref 소스

## 7. lab 앱

`talkverse-lab/apps/ja-lab/` = vi-lab 복제 (브랜드 #BC002D 일본 적). 콘텐츠 채워지면 lab 자동 sync (현재 placeholder).

화면:
- index, main, conversation_200, chat_dialogue_*, adverbs_200, tone_practice, textbook (vi 동일)
- + kana_chart, kanji_cards, katakana_reader, l1 (JA 확장)

## 8. 작업 우선순위

| 단계 | 작업 |
|---|---|
| 1 | `Word/` corpus 분석 (Leipzig freq + cliff 분석) → 핵심 800 어휘 도출 |
| 2 | L1 200 turn 5 ep 작성 (VI 패턴 따라) |
| 3 | L2 23 dial 300 turn (카오스 채팅) |
| 4 | L3 23 dial 304 turn (사랑 narrative) |
| 5 | TTS 합성 (ElevenLabs 또는 Google Wavenet ja-JP) |
| 6 | lab 앱 sync + 검증 |

## 9. 격리 위반 안티 패턴

- ❌ 다른 lang 폴더 (vi/ko/zh) read/write
- ❌ `_shared/` 룰 자체 수정 (요청만 가능)
- ❌ `hanja_crossref.json` 직접 수정 (zh 룸 cross-ref 영향 — root 룸 협의)
- ❌ JA 특화 패턴을 VI 룸에 강요

## 10. 막힘 처리

- ISSUE 발견 시: `_shared/issues_{date}.md` 에 기록 (root 룸 또는 본인 ISSUE 파일)
- schema 변경 필요 → 절대 자체 변경 X. root 룸 협의
- corpus 부재 → Leipzig 또는 단국대 표준교재 (전자책 폴더) 활용

## 11. 관련 문서

- `_shared/dialogue_principles.md` — Main 14 lang 표준 (960 줄)
- `_shared/hanja_crossref.json` — 한자 4-way (ja-kanji 포함)
- `talkverse-lab/INDEX.md` — v4 schema 전체
- `talkverse-lab/vi/` — canonical reference

---

_작성: VI 룸 (2026-05-15) → JA 룸 핸드오프_
