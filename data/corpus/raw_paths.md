# Raw 코퍼스 path 참조

> 큰 raw 파일은 db/corpus/ 카피 X. 분석 시 아래 path 를 그대로 참조.

## 교육부 별책 Ⅱ + 한자 사전 (2026-05-17 cycle13 import)
- `db/corpus/edu/ja_vocab.json` — 한국 교육부 별책 Ⅱ 일본어 기본 어휘 (940 unique, 정제 후 854)
- `db/corpus/edu/ja_vocab_raw.txt` — 원본 PDF 추출 텍스트
- `db/corpus/edu/ja_lang_i.json` — 일본어 Ⅰ 의사소통 기본 표현 (9 topics: 인사·소개·배려·의향·정보 요구·…)
- `db/corpus/edu/ja_namu_japanese1.txt` — 나무위키 수능 일본어 Ⅰ 메타
- `db/corpus/edu/hanja_1800_kr.json` — 한국 한문교육용 한자 1800자 (참고용)
- `db/corpus/edu/hanja_eomunhoe_kr.json` — 한국 어문회 한자 등급별 (참고용)
- 출처: `D:/OneDrive/PROJECT/mlab-2woecode/assets/edu_2026-04-26/datasets/`



## JMultiWOZ 1.0 (task-oriented 다중턴)
- dialogues.json: D:/OneDrive/DATA_Raw/languages/ja/chat/jmultiwoz-data/JMultiWOZ_1.0/dialogues.json
- ontology.json:  D:/OneDrive/DATA_Raw/languages/ja/chat/jmultiwoz-data/JMultiWOZ_1.0/ontology.json
- informable_slots.json: 동상
- split_list.json: 동상
- HF loader (jmultiwoz.py): .../chat/jmultiwoz/jmultiwoz.py
- 도메인: 호텔·식당·관광·교통·쇼핑·날씨

## RealPersonaChat 1.0.0 (persona 다중턴)
- 루트: `D:/OneDrive/DATA_Raw/languages/ja/chat/real-persona-chat-data/real-persona-chat-1.0.0/`
- subfolders: `llm_dialogue_system/`, `real_persona_chat/`
- HF loader: `.../chat/real-persona-chat/real-persona-chat.py`

## japanese-daily-dialogue (5 토픽)
- `D:/OneDrive/DATA_Raw/languages/ja/chat/japanese-daily-dialogue/data/topic{1-5}.json` (각 ~18KB)
- 소량이라 필요 시 `db/corpus/` 직접 카피 가능

## OpenSubtitles 2024 (대용량, 참조만)
- `D:/OneDrive/DATA_Raw/languages/ja/chat/opensubtitles_v2024.txt.gz` (33MB)
- 분석 시 압축 해제 후 빈도 추출

## drama_modern 자막 (회화 빈도 보조)
- `D:/OneDrive/DATA_Raw/languages/ja/drama_modern/*.srt`
- Asura_EP01-02, FirstLove_Netflix, Ikusagami_S01E01, Makanai_S01E01
- INDEX.md 에 메타정보
