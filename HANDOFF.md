# 일본어유니버스 — 세션 인수인계 (2026-11-02 오후, 전체 다시 씀)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`.

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC) · origin = 로컬 `7d1e3bb`(한자 배우기·맞춤 회화·워커). 미커밋 = CRLF 노이즈 + 도구 부산물 + `data/review/*_grok_enrich*`(보류 작업) + `data/review/wire/`(와이어프레임) — 의도적으로만 커밋 |
| iOS TestFlight | 2611021502(새 회화 뷰어·단어 섹션·라이트너·한자 DB) → 2611021514(한자 배우기·맞춤 회화) → 2611021602(시안 02 만화 읽기형) → **2611021731**(프로필·성과·왕초보 재분배·「주제」·Talkverse ID 로그인·결제) 업로드 완료 — 단 프로파일에 `applesignin` 없음(사용자가 포털 App ID 에 Sign in with Apple capability 켠 뒤 재빌드 필요) — `tools/ios_release.sh`, 번들 `com.talkverse.japaneseUniverse`, 유니버설(아이폰+아이패드) |
| Android | CI 빌드 = 푸시마다 자동, Zealot 「일본어 유니버스」 빌드 14 https://apps.talkverse.uk/Ultzu/174 (`tools/zealot_push.sh --ci`) |
| 회화 콘텐츠 | R0 26(**2026-11-02 사용자 지시로 재분배** — R1 77편 중 턴당 평균 8.0자 이하를 R0 로 이동, `review.level_note`) · R1 51 · R2 56 · R3 24(친구·사랑·생활·여행 각 6) · R4 1 = 158편(+R0 26 = 중복 없음), `assets/data/dialogues/<R>/<주제>/*.json`, 검사기 오류 5 = 강화 재작성 v2 시험 2편(culture_a3·life_c2)의 단어 수 초과(보류 중). 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ (157편, 턴·편 저장칸, API `https://talkverse.uk/api/review/ja`) |
| 단어 DB | 8,525어 한국어 뜻 100%, 시드 키 `db_seeded_v7`(데이터 바꾸면 v8) |
| 그림 | 단어 그림 = `ArtService`(`GET https://auth.talkverse.uk/art/ja/manifest`, 512 webp). 장면 그림(만화 1컷)은 아직 없음 → 턴 `art` 필드 비어 있음 |
| Grok 프로젝트 | 「일본어 회화 검수」 `project/08a3b12e`(재작성) · 「talkverse UXUI」 `832d5dbe-6d57-4114-b17d-d4a52e41bf45`(2026-11-02 15:40 세 번째 생성, 전용 Chrome 9223 — 시안 1개+그림 1장씩, Grok 이 git push) · 전용 Chrome CDP 127.0.0.1:9222 |

## 2. 2026-11-02 에 만든 것(전부 푸시됨)

- **새 회화 뷰어**: `lib/screens/dialogue_screen.dart`(주제 → 편 → 편 화면, 왕초보/초보 전환), `lib/services/dialogue_service.dart`(R0~R4 로더, `speakerName()` = `{name}` → 「나」), `lib/widgets/episode_play_pane.dart`(「모든 문장 듣기」 순차 TTS·배속·자막 단계·그림 칸, 컨트롤 줄 가로 스크롤), `lib/screens/dialogue_card_screen.dart`(그림만 앞면 카드).
- **배우기 탭**: 「회화 (새)」(주제별 회화 + 맞춤 회화) · 「단어」(절벽·필수·JLPT) · 기초에 **「한자 배우기」** 추가.
- **한자 배우기** `lib/screens/kanji_learn_screen.dart`: 단계(20자)를 한 글자씩 `KanjiInfoBody`(한자 팝업과 같은 내용 — 훈음·읽기·한자유니버스 공용 DB 글자 형성·팁·어원·소리 가족·그림·대표 단어·읽기별 단어)로 먼저 보고 → 「이 단계 문제 풀기」(기존 4지선다). 아이패드 = 왼쪽 20자 격자 + 오른쪽 정보. `KanjiStagesScreen(learn: true)`. 「한자 단계」(바로 문제)는 그대로.
- **맞춤 회화(유료 메뉴, 첫 1편 무료)**: 계약 `docs/CUSTOM_SCRIPT_API.md`. 앱 `lib/services/custom_script_service.dart`(기기 ID, POST/GET `https://talkverse.uk/api/script/ja`, ready 편 로컬 보관) + `lib/screens/custom_script_screen.dart`(주제 8 칩 → 상황 입력+추천 칩 → 레벨 4 → 만들기, 「내 맞춤 회화」 서랍 1분 폴링). Worker·D1(`custom_scripts`·`paid_devices`)은 talkverse.uk 세션이 배포, 시크릿 `SCRIPT_KEY` 는 사용자가 넣음(완료). 코드 서버 워커 `tools/custom_script_worker.py`(pending → claim → `claude-lab -p` 초안(`tools/prompts/custom_script.md`) → Grok 재작성(`rewrite_grok.md`) → `check_dialogues --fix-rd` → result). 키는 `doppler run -p keys -c prd --`(`TALKVERSE_SCRIPT_KEY`), Claude 호출 때는 `ANTHROPIC_*` 환경변수를 뺀다(안 빼면 "Invalid API key"). launchd plist `tools/launchd/com.talkverse.ja.custom-script.plist`(5분) — **아직 올리지 않음, 사용자 확인 뒤**. 작업 파일 `data/custom_scripts/`(gitignore).
- **라이트너** `lib/review`(uk 공용 엔진, 테스트 7개), 복습 탭 「오늘의 복습」, 카드 앞면 단어 그림.
- **Grok UXUI 시안 02 「만화책 읽기형」 적용(사용자 확정 2026-11-02 15:45, 커밋 97cfa75→69e8f65)**: 편 화면 = `EpisodePlayPane(autoPlay:false)` 하나로 통일 — 칸 너비 900 이상(아이패드 가로) 좌 「대화 스크립트」·우 장면 컷(`SceneCut`, 말풍선·400ms 페이드)+캡션(`SelectableJaText` 한자 팝업), 900 미만(아이패드 세로 칸·폰) 컷 위·스크립트 아래, 하단 고정 컨트롤(▶ 재생·슬라이더·속도·자막 칩). 회화 홈 맨 위 「오늘의 컷/이어서 읽기」(`DialogueService.lastOpenedId`). 아이패드 세로 스크린샷 10장 통과(넘침 없음). 시안 자료 `data/review/uxui/sian_01.md|jpg`(데스크형), `sian_02.md|jpg`(만화형, 채택), `sian_01_clay.jpg`(우리 점토풍 그림 3장을 첨부해 Grok 이 그린 참고 — 장면 그림 톤 기준). Grok UXUI 방 = `832d5dbe…`(전용 Chrome 9223), 요청은 시안 1개+그림 1장씩, Grok GitHub 쓰기 권한 없어 답은 세션이 커밋.
- **Grok UXUI 요청 2회(옛 방, 참고)**(`data/review/uxui_ipad_request_01/02.md`, 답 `answer_01/02.md`): 시안 3개(①만화 읽기형 ②채팅형 ③학습 데스크형, 1순위 ③) + 성과 표시 원칙(세는 것: 편 완주·라이트너 단계·핵심 표현·한자·빈도 커버율 / 안 세는 것: 앱 오픈·스트릭·포인트·순위) + 맞춤 회화 메뉴 배치. **이미지는 6장 전부 실패** → Claude 가 SVG 로 그림: `data/review/wire/wire_01_desk.png`(홈→편→재생) · `wire_02_achievement.png`(「나」 탭 성과) · `wire_03_custom.png`(맞춤 회화). 생성기 `tools/wireframes.py`(SVG → `data/review/wire/*.svg`, PNG 는 CDP Chrome 캡처).

## 3. 사용자 지시·결정(2026-11-02, 바꾸지 말 것)

- **회화(다이얼로그) 작성은 사용자 지시 전까지 하지 않는다**(2026-11-02 16:50 "아직 다이얼로그는 작성하지 말고") — R3 문화·일·학업, R4 본편, 강화 재작성 v2, 맞춤 회화 워커 전부 보류. 앱 구조·UX·성과·그림 연결 작업만.

- **Grok UXUI 적용 전 기준 커밋 = 태그 `pre-grok-uxui`**(= 이 줄을 넣기 직전 origin/master, `git log -1 pre-grok-uxui`). 되돌리기: `git checkout pre-grok-uxui -- lib/` 또는 `git revert`. 태그는 origin 에도 푸시됨.

- Grok **그림 요청은 한 메시지에 1장**. 지연·실패가 난 Grok 방은 복구 안 됨 → 지우고 새로 만든다(UXUI 방 재생성 사유). UXUI 큰 변경은 다음 요청 때 한꺼번에 Grok 에.
- 맞춤 회화: 외부 LLM API 안 씀(코드 서버 + Grok), Cloudflare 에 ID 로 저장, 1회 무료, "많이 쓰면 그때 생각".
- 한자: 바로 문제가 아니라 **배우기 먼저** → 문제. 한자 DB 자체는 바꾸지 않는다(한자유니버스 공용).
- 강화 재작성 v2(`tools/prompts/rewrite_grok_v2.md`, `data/review/*_grok_enrich*`)는 보류 — Grok 스크립트 변경은 사용자가 요청할 때.
- 아이콘은 talkverse.uk 세션 담당. 메모·문서는 덧붙이지 말고 전체 다시 쓰기.

## 4. 다음 할 일

1. TestFlight 빌드(한자 배우기·맞춤 회화) 번호 확인 → 사용자에게. 사용자 피드백 대기 항목: "다이얼로그 한번에 보기"·"단어장 안 보임"(둘 다 2611021424 에 없던 기능, 1502 이후 포함 — 다른 뜻이면 확인).
2. 맞춤 회화 워커 — **사용자 지시(2026-11-02 15:30)로 일단 멈춤.** 끝까지 2회 성공 확인됨(`ja-4inaalel`·`ja-fao34isa`, 편당 1.5~3분). launchd 는 설치하지 않았고 프로세스도 없음. 재개 = 사용자 지시 뒤 `cp tools/launchd/com.talkverse.ja.custom-script.plist ~/Library/LaunchAgents/ && launchctl bootstrap gui/501 ~/Library/LaunchAgents/com.talkverse.ja.custom-script.plist`(수동 1편은 §5 명령). 앱에서 요청하면 서버에 queued 로 쌓이기만 한다. janome 은 `~/.venvs/ja`.
3. ~~시안 02 TestFlight~~(2611021602 완료) · ~~`{name}` 치환~~(`lib/services/learner_prefs.dart` — 「나」 탭 학습자 프로필: 이름·성별, A 목소리 = 성별, `{name}` = 이름 또는 「〇〇」, 사용자 지시 "성별이 정해지면 나가 나오는 거니까"). 장면 그림 들어오면 턴 `art` 채우기(톤 = `sian_01_clay.jpg`; A 그림은 성별별 `art_m`/`art_f` 허용 예정).
4. **다음 TestFlight 빌드**에 학습자 프로필(b7721f6) + 성과 표시를 함께 넣는다(사용자 지시 2026-11-02 16:05 "다음 빌드에 넣자" — 프로필만으로 빌드하지 않음).
5. ~~성과 표시~~ 완료(b7b6291→1c2b0b2: `lib/services/achievement_service.dart` 편 완주·본 한자·그림 카드·일별 기록·라이트너 분포·빈도 커버율(라이트너 3단계 이상 단어 빈도 합), `lib/widgets/achievement_desk.dart` 「나」 탭 데스크 + `EpisodeDoneOverlay` 편 끝 연출. 아이패드 스크린샷 11장 통과). 남은 것: 폰 레이아웃 다듬기, 홈 「오늘의 작은 성과」 카드(선택).
5. 장면 그림(만화 1컷) 들어오면 턴 `art` 채우기. R3 문화·일·학업, R4 본편 작성 재개.

## 4-1. 다른 언어앱 복제(2026-11-02 17:00)

- 복제 안내 `docs/REPLICATE_FOR_OTHER_LANGS.md`(구조·규칙·도구 한 벌). 한국어앱에 착수 프롬프터 `~/talkverse/ko/RELAY_from_ja.md` 전달(SendMessage 「한국어앱」): 우리 회화가 기초, Gemini 없음, K-드라마·K-팝 상황 추가, Grok 방·Chrome(9224) 분리. 한국어앱 쪽 "콘텐츠 생성 금지"와 충돌 → 사용자 확인 필요하다고 적음. 태국어앱에도 `~/talkverse/th/RELAY_from_ja.md`(Gemini 없음 — Grok 재작성에 ❓ 표시 요구, 성별판 + 프로필 성별, Chrome 9225) 전달(17:10). 17:30 사용자 지적("우리 톤은 점토 톤인데 쟤들은 모르네")으로 복제 안내 §1 점토 톤·§2 UX 확정·§7 참고 파일을 넣어 전부 다시 쓰고 두 세션에 재전달.
- **Talkverse ID 로그인·결제(평생 이용권)**: uk 세션 경유 사용자 지시(17:20 착수 → 17:25 보류 → 17:35 보류 해제 "지금 바로 착수"). 가이드 `/Users/talkverse/talkverse/TALKVERSE_ID_APP_GUIDE.md`, 원본 한자앱 `~/Hanja/hanja-app`. 값 4개(uk 에 전달): client_id `ja`, 딥링크 `talkverse.ja://auth`, 이용권 lang `ja`(상품 iOS `com.talkverse.japaneseUniverse.lifetime`·Android `lang_ja`), 번들 iOS `com.talkverse.japaneseUniverse`·Android `com.talkverse.japanese_universe`. **구현 완료(e154d98)**: `lib/services/account.dart`·`purchase.dart`·`entitlement.dart`(premium = 로컬 스위치 OR 계정 이용권 ja OR 스토어 구매), `lib/screens/login_screen.dart`(구글·네이버·카카오·Apple + 이메일 데모)·`paywall_screen.dart`(참고가 ₩14,900, 혜택 = 맞춤 회화 무제한), 「나」 탭 계정 칸(로그인/이름·이메일·로그아웃·계정 삭제/평생 이용권), 맞춤 회화 POST 에 Bearer 토큰(uk Worker 가 이용권 ja 확인해 402 면제 — 배포됨), 402 → 잠금 시트, AndroidManifest 콜백 `talkverse.ja`, `ios/Runner/Runner.entitlements` + pbxproj CODE_SIGN_ENTITLEMENTS·SystemCapabilities, `docs/store/review_notes.md`·`data_safety.md`. 사용자가 할 일: App Store Connect 인앱 상품 `com.talkverse.japaneseUniverse.lifetime`·Play 일회성 상품 `lang_ja` 등록, 개발자 포털 App ID 에 Sign in with Apple capability 켜기(없으면 TestFlight 프로파일에 applesignin 이 빠짐 — `security cms -D -i embedded.mobileprovision | grep applesignin` 로 확인). 데모 계정 review@talkverse.uk 는 lang ja 이용권 보유. 방침 페이지 https://talkverse.uk/talkverse/ja/privacy/ 게시됨(uk 세션, 2026-11-02 — 스토어 등록 때 이 URL).

## 5. 공통 절차(맥미니)

```bash
cd ~/talkverse/ja && flutter analyze && flutter test        # 둘 다 통과 상태
git add <바꾼 파일만> && git commit && git push origin master  # CRLF 노이즈·부산물·RELAY_* 제외
bash tools/ios_release.sh                                    # TestFlight(번호 = KST yymmddHHMM)
tools/zealot_push.sh --ci "변경 한 줄"                        # CI 빌드 뒤 Zealot
/usr/bin/python3 tools/grok_send.py <프롬프트> <답> --tab project/<id> --wait 600   # Grok(이미지는 1장씩)
/usr/bin/python3 tools/grok_fetch.py project/<id> <답>       # 끝난 답 다시 받기
doppler run -p keys -c prd --no-check-version -- /usr/bin/python3 tools/custom_script_worker.py --once   # 맞춤 회화 1편
```
