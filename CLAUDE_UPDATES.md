# Claude 업데이트 메모 — japanese_universe (ja)

> 기준 앱: chinese_universe(zh). 이식 세부 규격은 `zh/docs/PORTING_GUIDE_2026-09.md` 참고.
> 작성: 2026-09-05 (Claude Code 세션). 이후 변경은 git log 참고.

## 변경 이력
- (2026-09-08) 발음·한자 대확장 세션 — 아래 "2026-09-08 세션" 참고

## 2026-09-08 세션 요약 (git log 02166da..HEAD)
### 신규 화면·메뉴
- **50음도와 발음** (메뉴명 변경): 가나 탭 → 발음 시트. 1초 지연 자동재생 + 재생버튼,
  IPA·조음 위치, **모음 비교 차트**(사다리꼴 1장에 일본어 빨강 vs 영어 파랑 점, `vowel_compare_chart.dart`),
  영어/한국어 비교. 데이터 `services/kana_phonetics.dart` (청음·탁음·요음 전부).
  위키미디어 IPA 이미지 2장 번들(`assets/images/ipa/`, CC BY-SA 출처 표기).
- **발음부(音符)** 신설: `tool/gen_phonetic_ja.py` — IDS 분해(cjkvi-ids, /tmp/ids.txt 빌드타임)
  + 음독 탁음정규화 일치 + 부수 블랙리스트 + 일치율 필터 → `phonetic_ja.json` 198가족·592자.
  카드는 절벽구간(R1~R4) 정렬·필터. 가족 시트 4분류:
  **완전공유 = 일본 음독 + 한국 한자음 모두 같음** (可·歌=가) / 부분공유(음독 같고 한자음 다름·탁음차)
  / 비슷한 음차(첫소리 같음 or 한자음만 같음) / 예외. 루트 대표음은 멤버 최다 일치음,
  db 밖 루트 한자음은 멤버 최빈음(尞→료). 검수: 완전 434·부분 145·유사 13·오분류 0.
- **영어등유래단어** 신설(`gairaigo_screen.dart`, `assets/data/vocab/gairaigo.json`):
  음차 규칙 8줄기(모음삽입·L=R·F·V·TH·장음·축약·화제영어) + 유래 언어 5줄기(포·네·독·프·기타).
  **1단계 핵심 248어(디폴트) / 2단계 JLPT 전체 636어** 토글, N급수 배지, 재생버튼, [예외] 배지.
  생성기 `tool/gen_gairaigo.py` + 한국어 뜻·분류 보정 `tool/gairaigo_ko_fix.py` (331어 수동 번역).
### 화면 개편
- **한자음 매핑**: zh 발음부 스타일 그리드(검색+2열 카드+가족 시트). 한자 상세 시트에
  한자 밑 훈음 + 대표 단어(빈도순 2개) 추가 (`selectable_ja_text.dart`).
- **한자 단계**: **빈도순(디폴트)/JLPT순 토글**. 빈도순은 회화 빈도 20자 단위·절벽(R1~R4) 헤더,
  기록은 stageResults에 +500 오프셋 키로 분리 저장 (`kanji_quiz_screen.resultOffset`).
### 분석 결과 (기록)
- JLPT 카타카나 외래어 실측: N5 61·N4 46·N3 121·N2 121·N1 177 = **526** (영어유래 약 450).
- 한자 절벽 vs JLPT: R1(최빈 294자) 중 N5+N4는 44%뿐, 최다는 N3(112자).
  N2의 56%·N1의 76%는 회화 2500위 밖 → **학습은 빈도(절벽) 기준** 방침 확정.
### 절벽구간 정의 (회화 빈도)
- R1 1-294 · R2 295-437 · R3 438-998 · R4 999- (`lang_ja_with_regions.csv` 기준, 한자에도 동일 적용)
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

## 결정 사항
- **한글독음 유지 확정** (2026-09-08 사용자 결정): zh는 09-03에 한글독음을 버리고 성조 병음으로 전환했지만, ja는 가나→한글독음 변환·[한] 토글을 그대로 유지한다.
- **소스 표기 금지**: 단어 콘텐츠의 출처(교재명 등)는 앱·코드·에셋 어디에도 표기하지 않는다 (`02166da`).
