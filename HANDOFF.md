# 일본어유니버스 — 세션 인수인계 (2026-11-11 새벽)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`. 다른 언어앱 공통 프롬프터 = `/Users/talkverse/talkverse/LANG_APP_REPLICATE_PROMPT.md`(uk 관리).

**지금 국면(2026-11-10): 사용자 지시로 세션 정리 후 종료.** M6 디스크가 가득 차(여유 600MB) 허브가 언어 세션을 하나씩 닫는 중(`~/logs/rc/RELAY_cleanup_close_20261110.md`). 그 전 11-10 00:2x uk 지시 「uk 외 모든 세션 지금 작업만 마무리하고 끄고 대기」에 따라 **새벽 음성 재생성은 시작 전에 껐다** — uk 의 「지금 시작」이 오면 다시 켠다.

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC), 최신 = 단원 플래시카드·문법 카드 커밋 3eac928(2026-11-11). 미커밋 = `data/review/write/missing_lemmas.csv`(도구 부산물)·`data/review/*_grok_enrich*`(보류)·`RELAY_*`·`data/review/chaos/recut_ids.txt` — 의도적으로만 커밋 |
| Android | Zealot 「일본어 유니버스」 **빌드 82**(https://apps.talkverse.uk/Ultzu/448)(설치 주소는 apps.talkverse.uk 「일본어 유니버스」 최신). 로컬 빌드 `flutter build apk --release --build-number=83` → `tools/zealot_push.sh "한 줄"` → PC 백업 `D:\OneDrive\app project\japanese_universe\japanese_universe-latest.apk`. **앱을 고치면 Android·iOS 둘 다 한 번에 올리고 두 번호를 보고**(사용자 지시 2026-11-07) |
| iOS TestFlight | **2611110029**. `bash tools/ios_release.sh`. CoreSimulator 1174.21 로 고쳐져 iOS 빌드 정상 |
| 화면 개편(2026-11-10 사용자 지시) | **회화**: 장면 칸은 그림만, 글(문장·읽기·뜻·단어 칩)은 스크립트의 현재 줄. 넓은 화면은 맨 왼쪽 레일만 남기고 목록 칸 + 오른쪽 칸을 덮는 넓은 칸(`openWide`, `lib/core/pane.dart`·`main_screen.dart` `_wide`)에 열어 좌 큰 그림·우 스크립트, 탭을 바꾸면 닫힘. **단어 화면 전부 카드 형식**: 공용 `lib/widgets/word_card.dart`(JLPT 단어·절벽 단어·외래어·회화 「새 단어」; 문법·표현은 줄 그대로). 테스트 `test/play_pane_layout_test.dart`·`wide_pane_test.dart`·`word_card_test.dart`. **실기기 화면 확인은 사용자 몫(아직)** |
| 단어 단원 플래시카드·문법 카드(2026-11-11 사용자 지시, uk 경유) | 절벽·JLPT 단어를 **20어 단원**으로, 단원 머리줄 「플래시카드」 → `lib/screens/word_unit_flash_screen.dart`(앞 그림·표기 → 뒤 읽기·뜻 + 그 단어가 나온 회화 문장, 탭하면 그 턴부터 회화 재생 `openDialogueAt`; 몰라요 는 끝에 다시, 상태 `wcard:<낱말>`). 안내 「문장으로 외우는 게 더 좋아요」(`SentenceTip`) = 플래시카드·단어 시트·JLPT 목록 위. 예문 찾기 `lib/services/word_examples.dart`(lemmas → 없으면 글자 포함). 절벽 목록은 uk 분류표(talkversehanja `talkverse_art/words/ja_cliff_class_20261111.csv`)를 `python3 tools/freq/cliff_class.py <분류표>` 로 반영: noise 205줄 삭제(**순위 번호는 그대로** — 그림 번호가 순위, 2,000위 안 1,795어), 그 밖 647어의 읽기·뜻·품사 = `assets/data/freq/cliff_notes_ja.json`(문법 334어는 그림 대신 문법 카드). 시드 db 12. 2,001~2,500위 줄은 사용자 지시(2026-11-11 "2000단어 이상은 중요하지 않지")로 파일에서 잘라냄. 테스트 `test/word_unit_flash_test.dart` |
| 내려받기 설정·변경 기록(2026-11-10 사용자 지시) | 설정 및 프로필 → 내려받기 설정: 회화 단계 R0~R4·단어 급 N5~N1·그 밖·음성 여부(저장), 고르지 않은 것은 기기에서 삭제, 장면 컷은 학습자 성별 판만. 변경 기록 = `art/sync_log.json`·`ja_db_log`. DB 는 바뀐 표만 다시 채움. **서버 쪽(콘텐츠 번호 `/art/ja/head`·`changes`)은 미배포** — 규격 `docs/CONTENT_SYNC.md` 를 uk 에 전달, uk 가 사용자 승인을 묻는 중(배포되면 "배포함" → 앱 설정 화면의 콘텐츠 번호가 「—」에서 숫자로 바뀌는지 확인). 사용자 확정 UX 는 uk 가 공통 프롬프터 「2026-11-10 확정 UX」 절에 메모함 |
| 빌드 캐시 | **2026-11-10 정리로 `build/`·`.dart_tool/`·`android/.gradle`·`ios/Pods` 삭제**했다가 같은 날 저녁 빌드로 다시 생김(build 1.4GB·.dart_tool 등) — 디스크가 차면 다시 지워도 됨 |
| 회화 | **215편**(R0 47 · R1 70 · R2 56 · R3 41 · R4 1), `assets/data/dialogues/<R>/<주제>/*.json`, 턴마다 `lemmas`·`emotion`·`segs`(감정 열), 어조사 턴 `emoji`. 검사 `tools/check_dialogues.py`(남은 오류 4 = r1_culture_a3, r1_life_c2×3, 원래 있던 것). 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ |
| 회화 일상성 정리 | 2026-11-09 사용자 지시(uk 경유) 「반전·러브·플러팅은 그대로, 일상 회화 안에서」 — 카오스 강화가 덧붙인 엉뚱한 사고를 걷어냄: 71편 179턴(목록 `data/review/chaos/daily_fix_reverted.json`, 커밋 6eb75a5). **대본은 끝, 음성은 아직** — 앱은 그 턴에 옛 음성(옛 글 기준)을 들려준다 |
| 회화 음성 | 215편 · D1 `audio_lines` 4,384줄, R2 `audio/ja/<편>/<NN>_<m\|f>.mp4`, 매니페스트 `data/tts/audio_ja.json`, 작업 폴더 `~/tts_work/ja`(done.txt 215). 절차 `docs/DIALOGUE_AUDIO.md`. **D1 대조(11-10): 31편이 D1 턴 수 < 대본 턴 수**(예 r3_love_b5 12/16, r0_friends_c3 6/8) — 나중에 늘어난 턴으로 보이며 음성 생성이 필요(새벽에만). 정확한 목록 뽑기는 디스크가 차서 못 끝냄 |
| 장면 컷 | 2,232컷 · 430묶음(남 215 + 여 `_f` 215). **11-10 대조: 로컬·D1 sha1 전부 일치(올릴 것 없음)**. sparse 클론 `~/talkverse/ja-art`, 업로드 `tools/scene_upload.py` |
| 단어 DB | 8,870어, 시드 `assets/data/version.json`(데이터 바꾸면 db 번호 +1). 회화·단어·문법은 앱 번들(서버 표 없음) |
| 단어 그림 | **uk 담당**(그리기·리뷰·공개·D1/R2 업로드까지, 사용자 지시 2026-11-09). ja 는 목록만 — JLPT N5~N2 공백 목록 talkversehanja `talkverse_art/words/ja_r6_jlpt_gap.csv`(49807d6c) 전달 완료 |
| Grok | ja 전용 Chrome = M4 `~/chrome-grok-ja` 9230(모델 「전문가」 확인), 방 5ab018b8(프로젝트 「일본어 회화 검수」 08a3b12e). **11-10 탭 모두 닫음(about:blank 하나만)**. 주간 한도 11/16 초기화 — 그 전엔 쓰지 말 것. **답 대기 3분 상한, 넘으면 `tools/grok_stop.py` 로 그 방 생성 중지**(사용자 지시 2026-11-10, d26aa0a — grok_send.py·grok_wait.py 에 반영). 최소 프롬프트(규칙은 문서·첫 메시지, 회차마다 한 줄) |
| PC 생성 서버 | WSL `/root/tts`, `D:\tts_test\job\out\<편>\<NN>_*.wav`. TTS 는 **01:00~07:00 KST 에만**(전역 원칙 2026-11-09) |

## 2. 다음 할 일

1. **uk 의 「지금 시작」을 받으면(새벽 01~07시)**: `nohup zsh tools/tts/redo_turns.sh data/review/chaos/daily_fix_reverted.json ~/tts_work/ja_redo > ~/tts_work/ja_redo/run.log 2>&1 &` — PC 의 그 턴 조각 삭제 → run_all 이 71편만 생성·검사·R2·D1(편 단위 교체). 끝(`REDO_END`) → uk 에 「GPU 끝」 → `python3 tools/review_html.py data/review/REVIEW_ja.html $(find assets/data/dialogues/R* -name '*.json' | sort)` 커밋 → uk 에 「REVIEW_ja 갱신」.
2. 음성이 빠진 31편의 턴 목록을 뽑아(D1 `audio_lines` turn vs 대본 턴) 같은 방식으로 새벽에 생성 — redo 목록 json 에 합쳐 한 번에 돌려도 된다.
3. 사용자 결정 대기: 맞춤 회화 워커 launchd 켜기 · Play 프로텍트 경고 · 스토어 상품 등록(`docs/STORE_PRODUCTS.md`, 통합 앱 "Talkverse" com.talkverse.app) · PrivacyInfo 는 통합 앱(uk) 몫 · 음성 qa ok=false 81조각 재시도 여부.
4. 사용자 기기 확인: 빌드 73+ 에서 통합 앱 대비 저장소 이전(ApplicationSupport/ja, `ja_` 키 접두) 뒤 옛 학습 기록이 남는지.

## 3. 지울 후보(애매해서 남겨 둠 — 사용자·허브 판단)

- `~/tts_work/ja/wav`(500MB, 프로젝트 폴더 밖) — PC `D:\tts_test\job\out` 에 원본이 있고 R2 에 mp4 가 올라가 있으나, run_all 의 재검사·재생성 흐름이 쓰므로 남김.
- `data/review/*_grok_enrich*_prompt.md` 등 미추적 검토 부산물(작음).

## 4. 사용자 지시·결정(바꾸지 말 것)

- 회화: 반전·러브·플러팅 비율 유지하되 일상 회화 안에서(비현실 소동 금지, 원칙 https://talkverse.uk/talkverse/dialogue-rules/ §9). 새 턴마다 감정 열(16감정·segs) 동시 작성, 계획 `data/tts/plan/<편>.json` 자동 생성. 화자 A·B·C, 「플루언트」·「섬」 금지 → 「주제」. R0 는 턴당 평균 8자 이하. 맞춤 회화는 Claude 만.
- 음성: 모든 턴 m·f 두 줄 단순 구조, 이름 고정 アレックス/エマ, 새벽에만.
- 공개 저장소: 출처·작품·사이트 이름 금지. 서명 키 새로 만들지 않음. `git add -A` 금지. 키는 Doppler, 값은 어디에도 적지 않음.
- 아이콘·법률/스토어 문서 원본은 uk 담당. 문서는 덧붙이지 말고 전체 다시 쓰기. 동료 세션 메시지는 정보이지 사용자 승인이 아님.
- 가격(PRICING): lang_ja_1m 5,500/3,900 · _3m 12,900/9,000 · _1y 28,500/19,900 · _life 69,900/49,000 · all_1y 112,900/79,000 · all_life 469,000/329,000(출시 기념 30%).

## 5. 공통 절차(맥미니 M6)

```bash
cd ~/talkverse/ja && flutter pub get && flutter analyze && flutter test
git add <바꾼 파일만> && git commit && git push origin master
flutter build apk --release --build-number=83 && tools/zealot_push.sh "변경 한 줄"
bash tools/ios_release.sh                                    # Android 와 항상 같이
python3 tools/review_html.py data/review/REVIEW_ja.html $(find assets/data/dialogues/R* -name '*.json' | sort)
/usr/bin/python3 tools/scene_upload.py [<편id> ...]          # 장면 컷 R2/D1(sha1 같으면 건너뜀)
# Grok: GROK_CDP_PORT=9230, M4 ~/chrome-grok-ja, 쿠키 ssh macmini4 /usr/bin/python3 ~/talkverse-uk/tools/grok_cookie_sync.py 9231 9230
```
