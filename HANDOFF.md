# 일본어유니버스 — 세션 인수인계 (2026-11-11 새벽)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`. 다른 언어앱 공통 프롬프터 = `/Users/talkverse/talkverse/LANG_APP_REPLICATE_PROMPT.md`(uk 관리).

**지금 국면(2026-11-11 새벽): 사용자 지시로 화면·내려받기 개편을 이어서 빌드 중.** 11-10~11 변동 사항은 아래 「0. 변동 기록」에 날짜순으로 한 벌. 11-09 일상성 정리 179턴의 음성 재생성은 11-11 새벽에 끝났다(아래 표).

## 0. 변동 기록(2026-11-10 ~ 11, 빌드 번호와 함께)

| 빌드(Android / iOS) | 바뀐 것 | 지시 |
|---|---|---|
| 75~79 / 2611101743~1751 | 회화 화면: 장면 칸은 그림만·글은 스크립트 현재 줄, 넓은 화면은 레일만 남기고 좌 그림·우 스크립트(`openWide`). 단어 화면 전부 카드(`WordCard`) | 사용자 11-10 |
| 80 / 2611101821 | 내려받기 설정(회화 단계·단어 급·음성 선택, 저장) · 변경분 동기화(서버는 11-11 배포) · 변경 기록 · DB 는 바뀐 표만 다시 채움 | 사용자 11-10 |
| 81 / 2611110023 | 단어 20어 단원 플래시카드(절벽·JLPT) + 「문장으로 외우는 게 더 좋아요」 · 절벽 목록 noise 205줄 삭제 · 문법 카드 334어 · 빈 뜻 칸 채움(db 11) | 사용자 11-11(uk 경유) |
| 82 / 2611110029 | 절벽 목록을 2,000위에서 자름(2,001~2,500위 삭제, db 12) | 사용자 11-11(uk 경유) |
| 83 / 2611110044 | 그림 없는 단어는 낮은 카드로(`WordCardGrid`) — 큰 빈칸 없앰 | 사용자 11-11 「빈칸이 왜이리 많어」 |
| 84 / 2611110050 | 단어 속 한자 → 한자 가족(`WordKanjiFamilies`: 단어 시트·절벽 시트·플래시카드 뒷면) | 사용자 11-11 |
| 85 / 2611110136 | 프로필 「내려받기 현황」(`lib/widgets/sync_status_card.dart`: 단어 그림·장면 컷·음성 받은 수/전체·%·막대, 마지막으로 받은 때·콘텐츠 번호·단어표 번호) + 「다시 받기」(`ContentSync.restart()` — 매니페스트 `?t=` 로 새로, 사라진 파일 다시 받음, `ArtService.reload()`) | 사용자 11-11(uk 경유) |
| 86 / 2611110231 | **회화 12+ 기준 정리**: uk 점검표 `data/review/ja_12plus_audit_20261111.csv` 의 high·medium 전부 + 콜백 1 = 6편 16턴(`data/review/rating12_turns_20261111.json`). 막차 놓치기 → 「あと何分話せるかな」·천천히 걷기(r2_love_b1, r3_friends_b1·b2 콜백), 혼욕 → 족욕(r2_love_b5), 한 방 두근 → 트윈 되뇌기(r1_travel_b2), 일부러? → 잔액 0?(r1_love_a5). **음성도 같은 날 02:39 재생성·R2·D1 반영, 서버 본문 대조 불일치 0**. 장면 컷은 바뀐 줄과 어긋남 없음(다시 그리지 않음). low 13줄은 손대지 않음 | 사용자 11-11(uk 경유) |
| 87 / 2611110236 | **글로벌판 1단계(영어 화자 → 일본어)**: uk 자료 `data/i18n/` — kDictEn 115줄 추가, 단어 영어 뜻 537개 채움(db 13), 한국어가 아닌 UI 는 한글 독음 자리에 로마자(`lib/services/romaji.dart`, `KoReading.convert`·`LearnerPrefs.readingLine`) | 사용자 결정 11-11(uk 경유) |
| 88 / 2611111003 | **12+ 점검표 low 줄 정리(사용자 승인 11-11)**: 클럽 → 음악 페스티벌(r1_love_a3·r0_love_a7 장면), 데이팅앱 → 언어교환 앱(장면·`where` 분류 7편), 침대 → 소파(r0_love_c4 2·r1_love_c1 3), 음성 삭제 거부 → 「やだ。…うそ。もう一回聞いたら消すね」(r1_love_c3 8). 음주·뽑기·목욕 문화 줄은 대사 유지. 고친 3턴 음성은 `data/review/rating12_low_turns_20261111.json` → **음성은 11-11 17:06 재생성·R2·D1 반영(사용자 「지금 돌려」), 서버 본문 대조 일치** |
| **89 / 2611111257** | **설정 및 프로필 재정리(사용자 승인 11-11)**: 맨 위 카드에 이름(누르면 고침)·둘째 줄은 UI 언어에 맞춤, 구획 = 계정 → 성과 → 학습 설정(이름·성별 칩·후리가나 스위치) → 내려받기(현황 카드 + 설정) → 앱 설정(언어는 목록에서 고르기) → 정보(앱 버전 = 실제 버전·빌드 번호) → 기록(초기화, 맨 아래). 「앱 업데이트」 항목은 넣지 않음(Zealot·TestFlight 로 받음), 도리이·붓 장식은 그대로. `lib/screens/profile_screen.dart`, 테스트 `test/profile_screen_test.dart` |
| **90 / 2611111822** | **언어감각 익히기(정규과정, 사용자 지시 11-11)**: 배우기 맨 위 「정규과정 → 언어감각 익히기」. L1 조사 익히기(옛 조사 화면 20개·예문을 4회로 나눔) → L2 문장의 뼈대 → L3 て형 → L4 반말·이어 말하기 → L5 생각·조건 → L6 수동·사역·높임, 각 4회 = 24회. 회차 = 문법 한두 줄(tip) → 감 익히는 문장(문장마다 듣기) → 「마침 · 다음 회」. 데이터 `assets/data/grammar/sense_course.json`(levels → lessons → points{head,tip,sentences}), 화면 `lib/screens/sense_course_screen.dart`, 마친 회차 = Prefs `sense_course_done`. **옛 조사 화면·조사 테스트·particles.json 삭제**(사용자 지시). 내용은 간단히 시작해 차차 늘림 | 사용자 11-11 |
| **91 / 2611111900** | **플래시카드 개편(사용자 지시 11-11, uk 경유)**: 단원 = 단어 20(그대로) + **문장 10**(복습 → 「문장 단원」, R0~R4 회화에 실제 나온 줄을 주제·편 순서로 10줄씩, 말 아닌 줄·같은 문장 제외). 흐름 = 들어올 때마다 섞기 → 탭 뒤집기 → 「다시」/「알았음」, 다시는 단원 끝에 다시, 끝에 알았음·다시 개수. 문장 카드 앞 = 한국어 → 뒤 = 일본어·독음·생성 음성. 단어 카드 뒤에 **회화 덩어리 1~2개**(문장을 、。？！ 에서 끊은 조각 — 本当 → 本当に·本当は, 활용형은 어간+가나, 한 글자 가나는 뺌). **숙련도 %**: 카드마다 0~100(알았음 +20·다시 −20·7일마다 −5), 색 파랑 0% → 빨강 100%, 단원·급에 평균. 기록 `lib/services/mastery.dart` Prefs `mastery_v1`, id = 단어 `w:<표기>`·회화 줄 `s:<편 id>:<턴 번호>`(옛 `wcard:` 알아요 → 40% 이전). 공용 화면 `UnitFlashScreen`(`word_unit_flash_screen.dart`), 문장 단원 `sentence_units_screen.dart`. 나중 후보: 문장 빈칸 | 사용자 11-11(uk) |
| **92 / 2611111936** | 단어 카드의 한자 가족 줄도 회화 빈도순(「패밀리 한자」 화면과 같은 기준 — 그 화면은 원래 빈도순) | 사용자 11-11 |
| **93 / 2611111942** | **한자 연습(사용자 지시 11-11 「패밀리가 많은 한자부터」)**: 배우기 → 기초 「한자 연습」. 소리 부품이 같은 글자 3자 이상 패밀리 94개(속한 글자 384자 + 부품 94)를 큰 가족부터, 같으면 빈도 높은 글자 있는 쪽부터, **하루 3패밀리 = 32일**(3달·주 3일 ≈ 39일 기준 하루 2.4 → 3, 약 11주). 하루 = 패밀리 카드(부품·소리·한국음 + 가족 글자 빈도순, 탭 = 한자 시트) → 「이 글자의 패밀리는?」 문제 → 마침(Prefs `kanji_practice_done`). 데이터 `assets/data/kanji/phonetic_ja.json`, 화면 `lib/screens/kanji_practice_screen.dart`. 2자 패밀리 104개는 아직 안 넣음 | 사용자 11-11 |
| **94 / 2611111947** | **한자 연습 누적 복습(사용자 지시 11-11)**: 목록 맨 위 「누적 복습」 — 마친 날의 패밀리 전부에서 20문제(4지: 정답 + 배운 패밀리 3), 틀린 적 있는 글자 먼저. 틀린 글자 Prefs `kanji_practice_wrong`(맞히면 빠짐, 하루 문제에서도 기록). 1일차 마치기 전엔 잠김 | 사용자 11-11 |
| **95 / 2611111951** | 언어감각 L1 조사 익히기 3회에 **て·で(접속조사, ~하고/~해서)** 추가(사용자 지시 11-11 「조사 익히기에 て형 포함」) — 활용 넓히기는 그대로 L3 | 사용자 11-11 |

아직 안 된 것: 12+ 관련 — 목욕탕 장면 컷(r3_culture_b3 남자판 컷 1·2·4 상반신에 수건, r1_travel_a5_f 컷 4 탕 안 어깨)은 노출은 아니나 **다시 그리기로 결정(사용자 11-11) — Grok 한도 11/16 초기화 뒤** · 영어 UI — content 162줄(한국어 비교 발음 설명 등)은 아직 한국어 그대로, 조사 は·へ 로마자는 글자대로(ha·he), 회화 영어 번역 칸 이름은 `en`·`note_en`(로마자는 앱이 가나에서 만듦)으로 uk 에 답함 · 실기기 화면 확인(전부 테스트·analyze 만 통과) · 기기에서 콘텐츠 번호가 숫자로 나오는지(서버는 11-11 배포됨) · 지운 목록 줄은 git 히스토리에 남음(재작성은 사용자 결정).

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC), 최신 = 프로필 내려받기 현황 커밋 700d548(2026-11-11). 미커밋 = `data/review/write/missing_lemmas.csv`(도구 부산물)·`data/review/*_grok_enrich*`(보류)·`RELAY_*`·`data/review/chaos/recut_ids.txt` — 의도적으로만 커밋 |
| Android | Zealot 「일본어 유니버스」 **빌드 95**(https://apps.talkverse.uk/Ultzu/466)(설치 주소는 apps.talkverse.uk 「일본어 유니버스」 최신). 로컬 빌드 `flutter build apk --release --build-number=96` → `tools/zealot_push.sh "한 줄"` → PC 백업 `D:\OneDrive\app project\japanese_universe\japanese_universe-latest.apk`. **앱을 고치면 Android·iOS 둘 다 한 번에 올리고 두 번호를 보고**(사용자 지시 2026-11-07) |
| iOS TestFlight | **2611111951**. `bash tools/ios_release.sh`. CoreSimulator 1174.21 로 고쳐져 iOS 빌드 정상 |
| 화면 개편(2026-11-10 사용자 지시) | **회화**: 장면 칸은 그림만, 글(문장·읽기·뜻·단어 칩)은 스크립트의 현재 줄. 넓은 화면은 맨 왼쪽 레일만 남기고 목록 칸 + 오른쪽 칸을 덮는 넓은 칸(`openWide`, `lib/core/pane.dart`·`main_screen.dart` `_wide`)에 열어 좌 큰 그림·우 스크립트, 탭을 바꾸면 닫힘. **단어 화면 전부 카드 형식**: 공용 `lib/widgets/word_card.dart`(`WordCardGrid` — 그림 있는 단어는 그림 카드, **그림 없는 단어는 그 아래 낮은 카드**(빈칸 지적 2026-11-11); JLPT 단어·절벽 단어·외래어·회화 「새 단어」; 문법·표현은 줄 그대로). 테스트 `test/play_pane_layout_test.dart`·`wide_pane_test.dart`·`word_card_test.dart`. **실기기 화면 확인은 사용자 몫(아직)** |
| 단어 단원 플래시카드·문법 카드(2026-11-11 사용자 지시, uk 경유) | 절벽·JLPT 단어를 **20어 단원**으로, 단원 머리줄 「플래시카드」 → `lib/screens/word_unit_flash_screen.dart`(앞 그림·표기 → 뒤 읽기·뜻 + 그 단어가 나온 회화 문장, 탭하면 그 턴부터 회화 재생 `openDialogueAt`; 몰라요 는 끝에 다시, 상태 `wcard:<낱말>`). 안내 「문장으로 외우는 게 더 좋아요」(`SentenceTip`) = 플래시카드·단어 시트·JLPT 목록 위. 예문 찾기 `lib/services/word_examples.dart`(lemmas → 없으면 글자 포함). 절벽 목록은 uk 분류표(talkversehanja `talkverse_art/words/ja_cliff_class_20261111.csv`)를 `python3 tools/freq/cliff_class.py <분류표>` 로 반영: noise 205줄 삭제(**순위 번호는 그대로** — 그림 번호가 순위, 2,000위 안 1,795어), 그 밖 647어의 읽기·뜻·품사 = `assets/data/freq/cliff_notes_ja.json`(문법 334어는 그림 대신 문법 카드). 시드 db 12. 2,001~2,500위 줄은 사용자 지시(2026-11-11 "2000단어 이상은 중요하지 않지")로 파일에서 잘라냄. **단어 속 한자 → 한자 가족**(2026-11-11 사용자 지시): `lib/widgets/word_kanji_families.dart` `WordKanjiFamilies` 를 단어 시트·절벽 단어 시트·플래시카드 뒷면에 — 씨앗 + 같은 소리 가족 글자(탭 = 한자 팝업), 「가족 지도」 = `openHanjaFamily`. 테스트 `test/word_unit_flash_test.dart`·`word_kanji_families_test.dart` |
| 내려받기 설정·변경 기록(2026-11-10 사용자 지시) | 설정 및 프로필 → 내려받기 설정: 회화 단계 R0~R4·단어 급 N5~N1·그 밖·음성 여부(저장), 고르지 않은 것은 기기에서 삭제, 장면 컷은 학습자 성별 판만. 변경 기록 = `art/sync_log.json`·`ja_db_log`. DB 는 바뀐 표만 다시 채움. **서버 쪽(콘텐츠 번호 `/art/ja/head`·`changes`)은 2026-11-11 uk 가 배포**(사용자 승인, talkverse-auth 1fd8452f, D1 `content_log` + 방아쇠 12개). 11-11 실측: head 1818, `changes?since=1810` → 8줄(kind·op·id·item, 앱 `patchManifest` 형식과 일치), `since=0`·head 초과 → `reset:true`(앱은 전체 받기로 넘어감). 앱은 다음 시작(또는 「다시 받기」) 때 번호를 저장하고 그다음부터 변경분만 받는다 — 기기 화면에서 콘텐츠 번호가 숫자로 보이는지는 사용자 확인 대기. 사용자 확정 UX 는 uk 가 공통 프롬프터 「2026-11-10 확정 UX」 절에 메모함 |
| 빌드 캐시 | **2026-11-10 정리로 `build/`·`.dart_tool/`·`android/.gradle`·`ios/Pods` 삭제**했다가 같은 날 저녁 빌드로 다시 생김(build 1.4GB·.dart_tool 등) — 디스크가 차면 다시 지워도 됨 |
| 회화 | **215편**(R0 47 · R1 70 · R2 56 · R3 41 · R4 1), `assets/data/dialogues/<R>/<주제>/*.json`, 턴마다 `lemmas`·`emotion`·`segs`(감정 열), 어조사 턴 `emoji`. 검사 `tools/check_dialogues.py`(남은 오류 4 = r1_culture_a3, r1_life_c2×3, 원래 있던 것). 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ |
| 회화 일상성 정리 | 2026-11-09 사용자 지시(uk 경유) 「반전·러브·플러팅은 그대로, 일상 회화 안에서」 — 카오스 강화가 덧붙인 엉뚱한 사고를 걷어냄: 71편 179턴(목록 `data/review/chaos/daily_fix_reverted.json`, 커밋 6eb75a5). **대본·음성 모두 끝** — 음성은 11-11 02:41~04:16 재생성(`tools/tts/redo_turns.sh`, 작업 폴더 `~/tts_work/ja_redo`), 서버 매니페스트 본문과 대본 대조 결과 불일치 0(이름 자리표·m/f 판 차이만) |
| 회화 음성 | 215편 · D1 `audio_lines` 4,384줄, R2 `audio/ja/<편>/<NN>_<m\|f>.mp4`, 매니페스트 `data/tts/audio_ja.json`, 작업 폴더 `~/tts_work/ja`(done.txt 215). 절차 `docs/DIALOGUE_AUDIO.md`. **음성 없는 턴(11-11 서버 매니페스트 대조): 35편 44턴 전부 대사가 없는 턴**(「……。」·괄호 지문·♡ 뿐) — 생성 대상이 아니다. 말이 있는데 음성이 없는 턴은 0 |
| 장면 컷 | 2,232컷 · 430묶음(남 215 + 여 `_f` 215). **11-10 대조: 로컬·D1 sha1 전부 일치(올릴 것 없음)**. sparse 클론 `~/talkverse/ja-art`, 업로드 `tools/scene_upload.py` |
| 단어 DB | 8,870어, 시드 `assets/data/version.json`(데이터 바꾸면 db 번호 +1). 회화·단어·문법은 앱 번들(서버 표 없음) |
| 단어 그림 | **uk 담당**(그리기·리뷰·공개·D1/R2 업로드까지, 사용자 지시 2026-11-09). ja 는 목록만 — JLPT N5~N2 공백 목록 talkversehanja `talkverse_art/words/ja_r6_jlpt_gap.csv`(49807d6c) 전달 완료 |
| Grok | ja 전용 Chrome = M4 `~/chrome-grok-ja` 9230(모델 「전문가」 확인), 방 5ab018b8(프로젝트 「일본어 회화 검수」 08a3b12e). **11-10 탭 모두 닫음(about:blank 하나만)**. 주간 한도 11/16 초기화 — 그 전엔 쓰지 말 것. **답 대기 3분 상한, 넘으면 `tools/grok_stop.py` 로 그 방 생성 중지**(사용자 지시 2026-11-10, d26aa0a — grok_send.py·grok_wait.py 에 반영). 최소 프롬프트(규칙은 문서·첫 메시지, 회차마다 한 줄) |
| PC 생성 서버 | WSL `/root/tts`, `D:\tts_test\job\out\<편>\<NN>_*.wav`. TTS 는 **00:01~10:00 KST 에만**(사용자 지시 2026-11-11, 그 전 01~07시) — 사용자가 「지금 돌려」라고 하면 그 시간 밖이라도 바로(`TTS_NOW=1 zsh tools/tts/redo_turns.sh …`) |

## 2. 다음 할 일

1. **git 기록 다시 쓰기 끝(11-11, 사용자 실행)**: 지운 이름이 든 옛 단어표 5개 판본을 기록에서 걸러 강제 푸시 — 원격을 새로 받아 이름 검색 0건 확인. 커밋 해시가 전부 바뀌었으니 다른 곳의 clone 은 다시 받을 것. GitHub 에 남는 옛 커밋(SHA 직접 접근)은 GitHub 지원에 정리 요청해야 사라진다(사용자 결정). 이 작업 폴더의 옛 가지 `master-old-history`·`master-stale` 과 reflog 에는 옛 기록이 로컬로만 남아 있다.
2. **PC 백업은 사용자가 명령할 때만**(11-11 지시 — 자동 대기 걸지 말 것): 빌드 89 APK·iOS 2611111257 IPA 는 11-11 16:50 PC `D:\OneDrive\app project\japanese_universe\` 에 백업 끝(크기 대조), 맥 사본 삭제. low 3턴 음성도 11-11 17:06 끝 — 남은 대기 작업 없음. 맥이 재부팅으로 후처리 중에 끊기면 PC 조각은 남으므로 `cd tools/tts && ~/.venvs/tts_ja/bin/python run_all.py <작업폴더> 12` 로 이어서(조각 삭제 생략).
3. 사용자 결정 대기: 맞춤 회화 워커 launchd 켜기 · Play 프로텍트 경고 · 스토어 상품 등록(`docs/STORE_PRODUCTS.md`, 통합 앱 "Talkverse" com.talkverse.app) · PrivacyInfo 는 통합 앱(uk) 몫 · 음성 qa ok=false 81조각 재시도 여부.
4. 사용자 기기 확인: 빌드 73+ 에서 통합 앱 대비 저장소 이전(ApplicationSupport/ja, `ja_` 키 접두) 뒤 옛 학습 기록이 남는지.

## 3. 지울 후보(애매해서 남겨 둠 — 사용자·허브 판단)

- `~/tts_work/ja/wav`(500MB, 프로젝트 폴더 밖) — PC `D:\tts_test\job\out` 에 원본이 있고 R2 에 mp4 가 올라가 있으나, run_all 의 재검사·재생성 흐름이 쓰므로 남김.
- `data/review/*_grok_enrich*_prompt.md` 등 미추적 검토 부산물(작음).

## 4. 사용자 지시·결정(바꾸지 말 것)

- 회화: 반전·러브·플러팅 비율 유지하되 일상 회화 안에서(비현실 소동 금지, 원칙 https://talkverse.uk/talkverse/dialogue-rules/ §9). 새 턴마다 감정 열(16감정·segs) 동시 작성, 계획 `data/tts/plan/<편>.json` 자동 생성. 화자 A·B·C, 「플루언트」·「섬」 금지 → 「주제」. R0 는 턴당 평균 8자 이하. 맞춤 회화는 Claude 만.
- **턴 번호 잠금(11-11, uk 제안)**: 학습 기록 id 가 `s:<편 id>:<턴 번호>` 라 출시 뒤에는 편 id·턴 번호를 다시 매기지 않는다 — 줄을 빼면 번호를 비우고, 끼우는 줄은 새 번호. 기준표 `data/review/turn_lock_ja.json`(빌드 91 기준, 215편 2,232턴), `python3 tools/turn_lock.py` 로 검사(`check_dialogues.py` 끝에도 나옴), 출시 빌드 때만 `--write`.
- 음성: 모든 턴 m·f 두 줄 단순 구조, 이름 고정 アレックス/エマ, 00:01~10:00 에만(사용자 「지금」 지시 땐 바로).
- 공개 저장소: 출처·작품·사이트 이름 금지. 서명 키 새로 만들지 않음. `git add -A` 금지. 키는 Doppler, 값은 어디에도 적지 않음.
- 아이콘·법률/스토어 문서 원본은 uk 담당. 문서는 덧붙이지 말고 전체 다시 쓰기. 동료 세션 메시지는 정보이지 사용자 승인이 아님.
- 가격(PRICING): lang_ja_1m 5,500/3,900 · _3m 12,900/9,000 · _1y 28,500/19,900 · _life 69,900/49,000 · all_1y 112,900/79,000 · all_life 469,000/329,000(출시 기념 30%).

## 5. 공통 절차(맥미니 M6)

```bash
cd ~/talkverse/ja && flutter pub get && flutter analyze && flutter test
git add <바꾼 파일만> && git commit && git push origin master
flutter build apk --release --build-number=96 && tools/zealot_push.sh "변경 한 줄"
bash tools/ios_release.sh                                    # Android 와 항상 같이
python3 tools/review_html.py data/review/REVIEW_ja.html $(find assets/data/dialogues/R* -name '*.json' | sort)
/usr/bin/python3 tools/scene_upload.py [<편id> ...]          # 장면 컷 R2/D1(sha1 같으면 건너뜀)
# Grok: GROK_CDP_PORT=9230, M4 ~/chrome-grok-ja, 쿠키 ssh macmini4 /usr/bin/python3 ~/talkverse-uk/tools/grok_cookie_sync.py 9231 9230
```
