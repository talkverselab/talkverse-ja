# 일본어유니버스 (JapaneseUniverse)

> 한국 화자 대상 일본어 단일 앱. `zh` (중국어유니버스) 구조를 그대로 따라 Flutter 로 재작성 (2026-08-16).
> 앱 이름: **Japanese Universe** · Package: `com.talkverse.japanese_universe`
> Stack: **Flutter** (Material 3) + **Drift** (SQLite). Brand: 紅 `#BC002D` (和風 팔레트).
> Git: **local only** (GitHub 사용 X).

---

## 한 페이지 요약

ja = 교착어 (한국어와 어순·조사 구조 거의 동일). 학습 3축 = **(1) 가나 50음 / (2) 한자 (한국 한자음 매핑) / (3) 조사·종조사 1:1 매핑**.

**한자 ↔ 읽기 ↔ 단어 DB (JLPT 기준, 2026-08-17)**
- 한자 2,285자 (JLPT N5 79 · N4 166 · N3 367 · N2 367 · N1 1,232 + 회화 74) — 한국어 훈음 100% (corpus 1,078 / 한국 한자 목록 756 / 수동 451)
- 단어 8,600어 (JLPT N5-N1 7,988 + 회화 top2500 한자어 598) — **후리가나 분절** 7,343 (JmdictFurigana). 한국어 뜻: **N5·N4 100%** (1,411어, `data/corpus/ko_gloss/`), N3↓ 는 영어 gloss
- 링크: `word_segments.char` → 한자 1자 ↔ 그 단어 안 실제 읽기 → 한자 시트 "읽기별 단어", 단어 시트 "한자 분해"
- 빌드: `python data/scripts/build_furigana_db.py` (입력 `data/raw/`, README 참조)

**차별화 IP**
- **한자음 매핑**: 한국 한자음 받침 → 일본 음독 규칙 (ㄱ→ク/キ · ㄴ,ㅁ→ン · ㄹ→ツ/チ · ㅂ→ウ · ㅇ→ウ/イ). 훈음의 '음'으로 1,078자 자동 그룹.
- **조사 1:1**: は=은/는, が=이/가, を=을/를, に/で/へ/と/も/の/から/まで … + 종조사 ね/よ/か/な/の/かな.
- **회화 자막 가중 빈도** 한자 1,078 · 단어 2,500 (R1-R4 cliff).
- 영어 우회 X · 모든 번역·예시 한국어 기반.

---

## 진입

```powershell
cd C:\Users\Johnjeon\talkverse\ja
claude
```

빌드:
```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift 스키마 변경 시
flutter run                                  # 개발 (실기기)
flutter build apk --release                  # release APK
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 폴더

| 위치 | 내용 |
|---|---|
| `lib/main.dart` | 앱 진입점 (Drift 초기화 + seed) |
| `lib/core/theme.dart` | 和風 팔레트 (紅·藍·金·墨·和紙·抹茶·桜) + 50음 행 색 |
| `lib/data/db/` | **Drift** SQLite schema (`app_database.dart` + 생성 `.g.dart`) + `seed_loader.dart` |
| `lib/screens/` | MainScreen(홈/학습/진행/프로필) · Conversation · Episode · SentenceFlashcard · KanaChart · GrammarLesson(조사+테스트) · KanjiStages(JLPT) · KanjiQuiz · KanjiDictionary · **JlptWords** · HanjaSound · WordFreq · Flashcard(덱) · Progress · Profile |
| `lib/widgets/` | japanese_decor (落款·青海波·麻の葉·鳥居·桜) · today_mission(富士) · memo_toggle · selectable_ja_text(한자 탭 → 정보 시트) · **furigana_text**(루비) · **word_sheet**(한자 분해) |
| `lib/services/` | TtsService(ja-JP 남/녀) · MemoService · KanjiIndexService(kanji_db) · **WordService**(Drift 조회) · DeckService |
| `assets/data/dialogues/` | L1.json (5 ep, ep1 40턴 완성) + `_meta.json` |
| `assets/data/kanji/` | **kanji_db.json** (2,285자 · JLPT·훈음·음독·훈독) · kanji_index.json (1,078자 예시어) |
| `assets/data/words/` | **words_jlpt.json** (8,600어 · 후리가나 분절 · en/ko) |
| `assets/data/freq/` | lang_ja_with_regions.csv (2,500어 R1-R4) |
| `assets/data/hanja/` | hanja_crossref.json (ko/zh/ja 80자 crossref) |
| `assets/data/grammar/` | particles.json (조사 20 · 예문 · 팁) |
| `assets/data/decks/` | 복습 덱 5종 (L1 회화 · native 회화체 · R1 골격 · 한자 80 · 교육부 어휘) |
| `assets/images/` | icon_source.png (じゃト 런처 아이콘 원본) |
| `data/` | corpus 분석 CSV/JSON · `scripts/build_furigana_db.py` · `raw/`(외부 원본, git 제외) |
| `test/` | 단위 테스트 |
| `android/` `ios/` | `flutter create` 자동 생성 (런처 아이콘 mipmap 유지) |

---

## Drift schema (v2)

| 테이블 | 내용 |
|---|---|
| `turns` | level/dialect/episodeId/num/speaker/ja/kana/romaji/ko/note/tags |
| `kanji` | char/rank/pct/**jlpt/grade/strokes**/meaningKo/meaningsKoJson/meaningsEn/onyomi/kunyomi/koHanja |
| `kanji_readings` | char → reading/base(히라가나)/kind(on·kun)/gloss |
| `jlpt_words` | id/surface/kana/jlpt/en/ko/rank/src/segsJson |
| `word_segments` | wordId/idx/segText/reading/char(단일 한자 분절) — **한자↔읽기↔단어 링크** |
| `words` | rank/word/freq/cumPct/region |
| `user_progress` | turnId → learned/favorite/lastReviewed/reviewCount |
| `kanji_progress` | char → known/exposureCount/lastReviewed |
| `stage_results` | stage → correct/total/bestPct/lastPlayed |
| `user_memos` | context/body/createdAt |

시드: `SeedLoader` (`db_seeded_v3` 키). 데이터 갱신 시 키 버전 + `schemaVersion` 올리기 (미출시: onUpgrade 전체 재생성).
복습 덱 카드 상태·문장 메모는 SharedPreferences (`card:{id}` / `memo:{pattern}:{idx}`).

---

## 콘텐츠 schema (v4)

```
L1: 5 ep × 40 turn = 200 turn   민준(한국 IT, 28) × 사쿠라(도쿄 디자이너, 26)   ← ep1 40 완성, ep2-5 미작성
L2: 23 dial ≈ 300 turn          카오스 채팅 (미작성)
L3: 23 dial ≈ 300 turn          사랑 narrative (미작성)
```

Turn JSON:
```json
{"num": 1, "speaker": "B", "ja": "あ、すみません。ここ、空いてますか?",
 "kana": "あ、すみません。ここ、あいてますか?", "romaji": "A, sumimasen. Koko, aitemasu ka?",
 "ko": "아, 죄송해요. 여기 비어 있나요?", "note": "すみません=죄송해요 / 空く(あく)=비다 / -ますか=의문 정중"}
```

---

## 미결 / 다음

1. L1 ep2-5 (160턴) · L2 · L3 콘텐츠 작성
2. dialect south (간사이) 변형판
3. TTS 정책 (시스템 ja-JP → 합성 mp3)
4. 문법 레슨 확장 (동사 활용 · 정중체/반말 · 경어)
5. JLPT 단어 한국어 뜻 채우기 — N5·N4 완료(2026-08-17), N3 (2,135어)·N2·N1 남음. 방식: `todo_*.json` 청크 → `done_*.json` (surface|kana → 뜻)
6. 회화 에피소드 버블에 후리가나 루비 적용 (words_jlpt 분절 매칭)

---

## 옛 자료 (read-only reference)

| 자료 | 위치 |
|---|---|
| zh 앱 (구조 원본) | `C:/Users/Johnjeon/talkverse/zh/` |
| 옛 monorepo | `D:/OneDrive/PROJECT/talkverse-lab/` |
| 분석 CSV / 한자 ref / 교육부 어휘 | `data/corpus/` |
