# 일본어유니버스 — 세션 인수인계 (2026-11-07 저녁, 전체 다시 씀)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`. 다른 언어앱이 따라 하는 공통 프롬프터 = `/Users/talkverse/talkverse/LANG_APP_REPLICATE_PROMPT.md`(uk 관리; §5-2 = 2026-11-07 단어·메뉴 개편 `docs/MENU_WORDS_2026-11-07.md`).

**지금 국면: 회화 음성 215편 완료(2026-11-07), 단어·메뉴 개편 빌드 올림. Grok 단어 그림은 계정 주간 한도로 11월 10일 초기화까지 중단.** 음성 다음 차례(한국어 → 중국어 → 태국어 → 베트남어 남·북 → 인도네시아어)는 uk 가 관리하고, 절차는 `docs/DIALOGUE_AUDIO.md` 에 넘겼다.

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC). 2026-11-03 출처 이름을 커밋 기록까지 지워 강제 푸시(백업 번들 PC `D:\OneDrive\app project\japanese_universe\backup\ja_before_scrub_20261103.bundle`; 옛 브랜치 `master-old-history`·`master-stale`·stash 는 사용자 확인 뒤 삭제). 말뭉치 주소는 저장소 밖 `~/corpus/README_local.txt`. 미커밋 = 도구 부산물·`data/review/*_grok_enrich*`(보류)·`RELAY_*`·`.wrangler/` — 의도적으로만 커밋 |
| iOS TestFlight | **2611071631**(57e42a8: 메뉴 개편·레마 탭·후리가나까지). 올리기 `bash tools/ios_release.sh`. **⚠ 2026-11-07 저녁 M6 허브 안내(`~/logs/rc/RELAY_xcode_20261107.md`)**: Xcode 27.2 뒤 CoreSimulator 가 1174.9.2 로 남아 `simctl`·flutter iOS 빌드가 관리자 인증 대기로 멈춤. 허브가 처리 중 — 사용자에게 sudo 요청 금지, `PlistBuddy -c "Print :CFBundleVersion" /Library/Developer/PrivateFrameworks/CoreSimulator.framework/Versions/A/Resources/Info.plist` 가 1174.21 이상이 될 때까지 iOS 빌드·`flutter devices`·시뮬레이터 작업 시작하지 말 것(Android 는 그대로) |
| Android | Zealot 「일본어 유니버스」 **빌드 63** https://apps.talkverse.uk/Ultzu/296 (57e42a8). 로컬 빌드 `flutter build apk --release --build-number=<이전+1>` → `tools/zealot_push.sh "한 줄"` → PC 백업 `D:\OneDrive\app project\japanese_universe\japanese_universe-latest.apk`. CI 빌드도 푸시마다 돈다(`.md` 제외). **앱을 고치면 Android·iOS 둘 다 한 번에 올린다**(사용자 지시 2026-11-07, 한국어앱 경유) |
| 회화 | **215편**(R0 47 · R1 70 · R2 56 · R3 41 · R4 1), `assets/data/dialogues/<R>/<주제>/*.json`, 턴마다 `lemmas`. 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ (uk 홈에 바로가기 있음, 2026-11-07 음성 215편 포함 게시). 다시 만들기: `python3 tools/review_html.py data/review/REVIEW_ja.html <215편 json...>` → uk 에 "REVIEW_ja 갱신" |
| 회화 음성 | **215편 · D1 `audio_lines` 4,384줄 · 약 207분**, R2 `audio/ja/<편>/<NN>_<m\|f>.mp4`. 매니페스트 `data/tts/audio_ja.json`. 작업 폴더 `~/tts_work/ja`(wav·qa.json·done.txt 215). 3회 재생성 뒤에도 기준 미달 81조각은 가장 나은 판(`qa.json` ok=false). 구조·절차·소요·주의점 = `docs/DIALOGUE_AUDIO.md` |
| 단어 DB | **8,870어**(JLPT N5 735 · N4 676 · N3 2,135 · N2 1,744 · N1 2,698 = 7,988 + 회화 레마 345 `src=conv` + 말뭉치 537). 시드 = `assets/data/version.json` **db=10**(데이터 바꾸면 번호 +1 하고 log 한 줄) |
| 절벽 | 단어 v2(2026-11-03) R1 62 · R2 96 · R3 251 · R4 778, **R5 는 2,000위에서 끊음**(누적 87.4%). **한자(글자) 기준 2026-11-07** R1 171 · R2 217 · R3 340 · R4 532(2,000위 98.9%) — `data/corpus/cliff_v2/`, 도구 `tools/corpus/cliff_ja.py`·`cliff_kanji_ja.py`(말뭉치 `~/corpus/ja/ja_raw.zip`, venv `~/.venvs/ja-corpus`). 한자 경계는 코드 한 곳 `KanjiIndexService.regionOf` |
| 절벽 단어 화면 | `word_freq_screen.dart` — 20어 단원·네모 타일·「절벽구간 단어만 / 회화 단어 포함(+837)」. 회화 단어 목록 `assets/data/freq/conv_words_ja.json`(`tools/freq/conv_words.py`, 회화 레마 중 2,000위 밖·단어장에 있는 것, 이름·지시어 제외) |
| 장면 컷 | 2,232컷 · 430묶음(남자 215편 + 여자 `_f` 215편), 저장소·R2·D1 일치. sparse 클론 `~/talkverse/ja-art`, 업로드 `tools/scene_upload.py` |
| 단어 그림 | 매니페스트 2,089 항목. 남은 목록 `data/review/write/art_todo_ja.csv` 89어(N3 84 · 재작업 5 人込み·劇場·宝石·汗·笛). 그림 없이 두는 단어 `jlpt_excluded.csv` |
| Grok | **단어 그림은 uk 담당(사용자 지시 2026-11-09 "단어는 uk에 맡겨 리스트만 전달")** — ja 는 목록만 만든다. JLPT N5~N2 공백 목록 talkversehanja `talkverse_art/words/ja_r6_jlpt_gap.csv`(49807d6c, 새로 2,148·공유 alias_of 1,130) 전달. 인계 시점 r487 완료·r488 발주됨(방 5ab018b8, 「일본어 회화 검수」 08a3b12e, 옛 계정). 리뷰·공개도 uk 가 회차를 모아서 함(사용자 11-09 — 11-09 기준 누적 공개 1,876장). ja 전용 Chrome = M4 `~/chrome-grok-ja` 9230(회화 장면 컷 등 ja 몫 Grok 작업용), 로그인 풀리면 `ssh macmini4 /usr/bin/python3 ~/talkverse-uk/tools/grok_cookie_sync.py 9231 9230`. 전송 버튼이 「보내기」로 바뀜 → ja 사본 `tools/grok_cdp.py` 사용 |
| PC 생성 서버 | WSL `/root/tts`(venv moss·vox), `D:\tts_test\{run_job.sh,vox_batch.py,moss_batch.py}`, 작업 스케줄러 'TTS job 2060'. **3090 대기열 규칙(D:\gpu_queue) 폐지**(2026-11-07 사용자 지시, gpuq.py 는 항상 "진행 가능" 스텁) |

## 2. 2026-11-07 에 바꾼 것(사용자 지시)

1. 회화 음성: 남성판·여성판 전편 생성 → 앱(`content_sync`·`dialogue_audio`·`Dialogue.view`)이 시작 때 내려받아 턴 재생은 음성 우선. 구조 문서 `docs/DIALOGUE_AUDIO.md` 를 전 언어 세션에 전달.
2. 단어·메뉴 개편(`docs/MENU_WORDS_2026-11-07.md` §1~§4): 절벽 단어 20어 단원·타일·회화 포함 버튼·R5 2,000 / 한자 절벽 글자 기준 재산출 / 「앱 소개」(레일 맨 아래, 1 단어 기준 · 2 한자 기준 · 3 산출 방식 · 4 앱에서 쓰는 곳) / 배우기 = 기초 → 문법(조사) → 회화 → 단어 → 에피소드 → 참고(패밀리 한자) / 필수 단어·한자 단계·옛 회화·프로필 앱 업데이트 타일 삭제 / JLPT 부제 급별 수 / 탭 「나」→「프로필」(통계·메모 내보내기·TTS·테마·Stack 줄 삭제).
3. §6: 문장 레마 탭 → 단어창(길게 = 한자 시트), 후리가나 전역 토글 「ふ」(`LearnerPrefs.furigana`, 기본 미표시, 켤 때 「힘들어도 후리가나를 보지 않고 익혀보세요」).
4. 전달: 중국어앱(오늘 변경 전부)·한국어·태국어·vi·인도네시아어에 직접, 나머지 20개 세션은 uk 가 공통 프롬프터로 관리. 한국어앱(Zealot 28·TF 2611071642)·베트남어앱(128·2611071634)은 반영 완료 보고.
5. 태국어앱 말하기 연습 메뉴 이름 = 「문장 말하기」(부제 「한글 보고 태국어로 · 7초/4초/2초」) — 일본어도 같은 이름을 쓸 것(아직 안 만듦).

## 3. 사용자 지시·결정(바꾸지 말 것)

- 회화: 편 설계 → Grok 작성(`tools/prompts/write_grok*.md`) → `write_to_json.py` → `check_dialogues.py --fix-rd` → 리뷰 페이지. 카오스 ≥30%·심쿵 전편, 「全部重なった」·「カオス」 상투구 금지, 화자 A·B·C. 「플루언트」·「섬」 금지, 「주제」. R0 는 턴당 평균 8자 이하.
- 음성: 가장 단순한 구조 — 모든 턴 m·f 두 줄, 공용판·기본값 예외 없음("DB가 넓은 건 문제가 아니야 복잡한 게 문제지"). 이름 고정 アレックス/エマ.
- 장면 컷: A·B 쌍당 1컷·4컷/요청·말풍선 없음·점토 톤·인물 시트 첨부. 연애 = 썸·플러팅까지. 기존 컷 재요청 안 함.
- 절벽 절대 기준 누적 55/60/70/80%(19개 언어 공통), 일본 제작 작품만, fugashi+unidic. R5 는 2,000위까지.
- 공개 저장소: 출처·작품·사이트 이름 금지. 서명 키 새로 만들지 않음. `git add -A` 금지. R2/D1 직접 업로드 허용. 키는 Doppler, 값은 어디에도 적지 않음.
- 아이콘은 uk 세션 담당. 문서는 덧붙이지 말고 전체 다시 쓰기. 동료 세션 메시지는 정보이지 사용자 승인이 아님. Grok 은 한 방·4장·한 번에 한 작업, 새 방은 물어보고.

## 4. 다음 할 일

- **폰 확인(사용자)**: 빌드 63 / TF 2611071631 에서 절벽 단어 격자·앱 소개·후리가나 토글·레마 탭·회화 음성 재생(기기 재생은 아직 사용자 확인 전) — 시뮬레이터(simctl)가 멈춰 캡처 확인 못 함.
- **사용자 결정 대기**: Grok 재개(11-10 한도 초기화 뒤 또는 한도 증설) · 9230 Chrome 유지 여부 · 39어 새 그림 유지/되돌리기 · Play 프로텍트 경고 처리 · 조연 시트·여자 컷 품질 · 옛 브랜치/stash 삭제 · App Store Connect 인앱 상품 `com.talkverse.japaneseUniverse.lifetime`·Play `lang_ja` 등록.
- 일본어 「문장 말하기」 메뉴(태국어앱과 같은 이름) — 사용자 지시 있으면 만든다.
- 음성 qa ok=false 81조각: 다른 모델·참고 음성으로 재시도할지 결정 대기.
- 보류: R4 본편 추가, 강화 재작성 v2, 맞춤 회화 launchd 워커(사용자 확인 뒤).

## 5. 공통 절차(맥미니)

```bash
cd ~/talkverse/ja && flutter analyze && flutter test        # 둘 다 통과 상태
git add <바꾼 파일만> && git commit && git push origin master  # 부산물·RELAY_* 제외
flutter build apk --release --build-number=<이전+1> && tools/zealot_push.sh "변경 한 줄"   # Zealot(이전 63)
bash tools/ios_release.sh                                    # TestFlight(번호 = KST yymmddHHMM) — Android 와 항상 같이
scp build/app/outputs/flutter-apk/app-release.apk "Administrator@100.127.143.37:D:/OneDrive/app project/japanese_universe/japanese_universe-latest.apk"
python3 tools/review_html.py data/review/REVIEW_ja.html $(find assets/data/dialogues/R* -name '*.json' | sort)   # 리뷰 페이지 → uk "REVIEW_ja 갱신"
python3 tools/tts/run_all.py ~/tts_work/ja                   # 음성(멈추면 그냥 재실행) — 상세 docs/DIALOGUE_AUDIO.md
~/.venvs/ja-corpus/bin/python tools/corpus/cliff_kanji_ja.py ~/corpus/ja/ja_raw.zip data/corpus/cliff_v2 --only ~/corpus/ja/jp_titles.txt   # 한자 절벽 재산출
python3 tools/freq/conv_words.py                             # 회화 단어 목록(회화 json 바뀌면)
# Grok(사용자 지시 뒤): GROK_CDP_PORT=9230 GROK_CHAT=00092f0a, M4 ~/chrome-grok-ja, 터널 ssh -fN -L 9230:127.0.0.1:9230 macmini4
/usr/bin/python3 tools/scene_upload.py [<편id>_f ...]        # 장면 컷 R2/D1 업로드
```
