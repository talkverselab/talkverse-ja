# Claude 업데이트 메모 — japanese_universe (ja)

> 기준 앱: chinese_universe(zh). 이식 세부 규격은 `zh/docs/PORTING_GUIDE_2026-09.md` 참고.
> 작성: 2026-09-05 (Claude Code 세션). 이후 변경은 git log 참고.

## 변경 이력
- `45768c3` (2026-09-02) 가나→한글독음 전역 토글 + Day별 필수 단어 975어 + 외우기 모드

## 변경 내용
### 가나 → 한글독음 자동 변환
- `services/kana_hangul_map.dart`(생성, 212음절: 50음·탁음·반탁음·요음·가타카나) + `services/ko_reading.dart`의 `KoReading.convert()`.
- 규칙: 요음 2글자 우선 매칭, `ん`=앞 음절 ㄴ받침, `っ`=ㅅ받침, `ー` 생략, 가나 이외 문자는 통과. 학습용 근사 표기.
### 한글독음 전역 토글 ([한] 버튼)
- 앱바 우측 `[한]` 버튼으로 독음 표시/숨김. SharedPreferences `show_ko_reading`에 영구 저장, 모든 화면이 즉시 동기화.
- 위젯: `KoReadingPrefs`(ValueNotifier) · `KoReadingToggleAction`(앱바 버튼) · `KoReadingText`(off면 빈 위젯).
- 적용: 에피소드 버블(`episode_screen.dart`) · 문장 플래시카드(`sentence_flashcard_screen.dart`) · 조사 예문(`grammar_lesson_screen.dart`) · JLPT 단어(`jlpt_words_screen.dart`, 후리가나 아래) · 복습 덱 플래시카드(`flashcard_screen.dart`). `main.dart`에서 `KoReadingPrefs.load()`.

### 콘텐츠 — Day별 필수 단어 (co-Trip 대체)
- 파서 `tool/parse_essential_days.py`(신설): "1 단어 익히기" 구간만, `□ 단어` / (후리가나) / `품사 뜻` 패턴. Day 헤더는 페이지 꼬리에 섞여 신뢰 불가 → 학습 헤더 순번으로 Day 결정.
- 산출: `assets/data/vocab/essential_days.json` — Day 1–20, 975어, 5일 묶음 4테마. 뜻 앞에 `[명]`/`[동]` 품사 태그.

### 화면
- `screens/topic_vocab_screen.dart` 신설(es 템플릿에서 색·필드 변환): 홈 메뉴 `필수 단어` 추가(seal 単語). 1×1 아이콘 타일(아이콘·일본어·가나·독음·뜻).
### 외우기 모드 + 외움 체크
- `MemorizedStore`: 외운 항목을 원문 키로 SharedPreferences `memorized_words`에 저장. `version` ValueNotifier로 전 위젯 동기화.
- 모드 버튼: 전체 → 원문가림 → 뜻가림 순환. 가려진 항목은 `???`, 탭하면 공개+TTS.
- 외우기 모드에서 항목별 체크(외웠어요) 버튼, 외운 항목은 배경·테두리 강조.
- 모드 라벨: 전체 / 일본어가림 / 뜻가림. `services/memorized_store.dart` 신설.

## 검토 필요
- **zh는 이후(09-03) 한글독음을 버리고 성조 병음으로 전환**했음. ja는 가나→한글독음 변환이 그대로 남아 있음 — 일본어도 독음을 빼고 가나만 남길지는 사용자 결정 사항. 빼려면 `KoReadingText` 호출부 6곳 제거 + `kana_hangul_map.dart` 삭제.
