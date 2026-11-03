# 일본어유니버스 — 세션 인수인계 (2026-11-02 밤, 전체 다시 씀)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`.

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC) · origin = 로컬(한자 구조 표시까지). 미커밋 = CRLF 노이즈 + 도구 부산물 + `data/review/*_grok_enrich*`(보류 작업) + `data/review/wire/`(와이어프레임) — 의도적으로만 커밋 |
| iOS TestFlight | 2611021502(새 회화 뷰어·단어 섹션·라이트너·한자 DB) → 1514(한자 배우기·맞춤 회화) → 1602(시안 02 만화 읽기형) → 1731·1755(applesignin 누락) → 1801(applesignin 포함) → 1921(단어 그림 썸네일·패밀리 한자) → 2149(장면 컷 연결) → 2309(한자 GIF 모핑·패밀리 한자 화면, 단 f9288e1 수정 누락) → 2314(패밀리 한자 수정) → 2326(한자 구조 표시) → **2611022338**(패밀리 한자 원복까지 전부, 23:42 업로드) — `tools/ios_release.sh`, 번들 `com.talkverse.japaneseUniverse`, 유니버설 |
| Android | CI 빌드 = 푸시마다 자동, Zealot 「일본어 유니버스」 **빌드 37** https://apps.talkverse.uk/Ultzu/186 (2026-11-02 20:35, 352ff41 = 장면 컷 연결까지). GIF·패밀리·구조 표시는 CI 빌드 뒤 `tools/zealot_push.sh --ci` 로 올릴 것 |
| 회화 콘텐츠 | R0 26(**2026-11-02 사용자 지시로 재분배** — R1 77편 중 턴당 평균 8.0자 이하를 R0 로 이동, `review.level_note`) · R1 51 · R2 56 · R3 24(친구·사랑·생활·여행 각 6) · R4 1 = 158편(+R0 26 = 중복 없음), `assets/data/dialogues/<R>/<주제>/*.json`, 검사기 오류 5 = 강화 재작성 v2 시험 2편(culture_a3·life_c2)의 단어 수 초과(보류 중). 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ (157편, 턴·편 저장칸, API `https://talkverse.uk/api/review/ja`) |
| 단어 DB | 8,525어 한국어 뜻 100%, 시드 키 `db_seeded_v7`(데이터 바꾸면 v8) |
| 그림 | 단어 그림 = `ArtService`(`GET https://auth.talkverse.uk/art/ja/manifest`, 488장 공개). **장면 컷 저장소 개통(2026-11-02 20:30, uk)**: GitHub `talkverselab/talkversehanja` `talkverse_art/scene/ja/<편id>/cut<N>.jpg`(1168×784) 푸시 → R2 자동 → `GET …/art/ja/scene/manifest?episode=<편id>`. 앱은 `ArtService.sceneCut(편id, 턴번호)`(A·B 쌍당 1컷, 턴→컷 (num+1)÷2) → 턴 `art` → 단어 그림 → 이모지 순. **인물 기준 그림 v1 완성(2026-11-02 23:30, `data/review/art/chars_ja_v1.jpg` — 유카·사쿠라·켄·리쿠·학습자 남/여, 모든 컷 요청에 첨부, 사용자 "일본 느낌 난다. 굿")**. ja 컷 제작은 아직 미착수(편 하나 = 4컷을 한 요청에, 158편 ≈ 158회 요청; 샘플 1편부터 사용자 확인 뒤) |
| 한자(한자유니버스 공용 DB) | `https://hanja-api.talkverse-lab.workers.dev/rest/v1/hanja_chars`(≈4,163행, UA 는 파이썬 기본값 금지) + `hanja_mnemonic`(lang ko, form). **앱이 받는 것**: ① 모핑 GIF(`gif`/`gif_jp`, 파일 `https://gif.talkverse.uk/<이름>`, webp `_768`/`_1024` 우선, 상태 ok·pending) ② 소리 가족(`phonetic`) ③ **회의·형성 구조**(`liushu`·`components`[ch·base·code·known]·`explain` gif/compose/family·`etym`) ④ 팁·어원(`hanja_mnemonic` tip·origin). 구조 전용 표는 따로 없고 전부 `hanja_chars` 한 표(2026-11-02 23:20 확인 — 한자 세션에 요청할 것 없음). 책 가족·헷갈리는 쌍은 번들 `assets/data/hanja/book.json`·`confuse.json`(한자앱 복제) |
| Grok 프로젝트 | 「일본어 회화 검수」 `project/08a3b12e-5761-4a2b-a074-daa6902fd222`(재작성) · 「talkverse UXUI」 `832d5dbe-6d57-4114-b17d-d4a52e41bf45`(2026-11-02 15:40 세 번째 생성 — 시안 1개+그림 최대 4장씩) · 전용 Chrome CDP **127.0.0.1:9230**(프로필 `~/chrome-grok-ja`, 바이너리 직접 실행; 포트표는 `docs/REPLICATE_FOR_OTHER_LANGS.md` §0). 중국어앱용으로 만들어 준 방: 「talkverse UXUI zh」 `1b47fbcb-a9aa-43f4-a2e0-2f6548e49eca` · 「중국어 회화 검수」 `6cefdfc3-7a26-4c60-b666-da1e560f0e59`(쿠키는 zh 세션 요청으로 복사하지 않음) |

## 2. 2026-11-02 에 만든 것(전부 푸시됨)

- **새 회화 뷰어**: `lib/screens/dialogue_screen.dart`(주제 → 편 → 편 화면, 왕초보/초보 전환), `lib/services/dialogue_service.dart`(R0~R4 로더, `speakerName()` = `{name}` → 「나」, `lastOpenedId`), `lib/widgets/episode_play_pane.dart`(「모든 문장 듣기」 순차 TTS·배속·자막 단계·그림 칸), `lib/screens/dialogue_card_screen.dart`(그림만 앞면 카드).
- **배우기 탭**: 「회화 (새)」(주제별 회화 + 맞춤 회화) · 「단어」(절벽·필수·JLPT, 목록·타일에 단어 그림 썸네일 `lib/widgets/word_art_thumb.dart`) · 기초에 **「한자 배우기」·「패밀리 한자」·「한자 단계」**.
- **한자 배우기** `lib/screens/kanji_learn_screen.dart`: 단계(20자)를 한 글자씩 `KanjiInfoBody`(한자 팝업과 같은 내용)로 먼저 보고 → 「이 단계 문제 풀기」. 아이패드 = 왼쪽 20자 격자 + 오른쪽 정보. `KanjiStagesScreen(learn: true)`.
- **한자유니버스 GIF·가족 DB 적용(한자 세션 지시, 0bef295→f9288e1)**: `lib/widgets/morph_player.dart`+`lib/services/morph_cache.dart`(한자앱 복제 — webp 768/1024→gif, 기기 캐시 `morph/`, 한 번 재생 후 글자에서 멈춤+↻, pending 허용), 한자 팝업 그림 = `MorphPlayer`. 한자앱식 「패밀리 한자」(`lib/screens/hanja_family_screen.dart`·`lib/widgets/family_map.dart`·`lib/services/hanja_family_service.dart` — 소리 가족(공용 DB + 앱 판정 합침)·책 가족·헷갈리는 쌍)를 만들었으나 **사용자 지시(23:40 "원래 니 구조가 더 좋았어")로 메뉴는 앱 자체 발음부 화면 `PhoneticRootsScreen`(`phonetic_ja.json`, 절벽 구간별 뿌리 카드 → 가족 시트)으로 원복(7b79bc4)**. 한자앱식 파일은 남아 있지만 연결되지 않음(지우지 말 것 — 마인드맵 재활용 가능).
- **한자 구조(회의·형성) 표시 보강(2026-11-02 23:25, 사용자 "회의자·형성자 구조도 DB 화 되어 있어… 받아야")**: `HanjaInfo.components` 를 글자 문자열에서 `HanjaPart`(ch·base·code·known·hun)로 바꾸고 부품 훈음을 한 번에 조회(`code=in.(…)`), `phoneticCode` 보관, 기기 캐시 키 `hanja_shared2:`. 팝업 「글자 형성」(`_Formation`, `lib/widgets/selectable_ja_text.dart`) = 한자앱 `_howBuilt` 과 같은 식 — 부품마다 역할(형성: 뜻부분/소리부분, 회의: 뜻)·자형·훈, 변형 자형은 「사람 (人)」처럼 본래 글자 병기, 소리 부품은 `ai` 색, 부품 탭 → 그 글자 팝업, 아래 한 줄 설명(형성자/회의자). 중복이던 「글자 구성」 칩은 제거. 확인 캡처 `integration_test/kanji_formation_test.dart`(語·休·江, `scratchpad/shots11/`).
- **맞춤 회화(유료 메뉴, 첫 1편 무료)**: 계약 `docs/CUSTOM_SCRIPT_API.md`. 앱 `lib/services/custom_script_service.dart`(기기 ID, POST/GET `https://talkverse.uk/api/script/ja`, Bearer 토큰, ready 편 로컬 보관) + `lib/screens/custom_script_screen.dart`(주제 8 칩 → 상황 입력+추천 칩 → 레벨 4 → 만들기, 「내 맞춤 회화」 서랍 1분 폴링, 402 → 잠금 시트). Worker·D1(`custom_scripts`·`paid_devices`)은 talkverse.uk 세션이 배포, 시크릿 `SCRIPT_KEY` 는 사용자가 넣음(완료). 코드 서버 워커 `tools/custom_script_worker.py`(pending → claim → `claude-lab -p` 초안(`tools/prompts/custom_script.md`) → Grok 재작성(`rewrite_grok.md`) → `check_dialogues --fix-rd` → result). 키는 `doppler run -p keys -c prd --`(`TALKVERSE_SCRIPT_KEY`), Claude 호출 때는 `ANTHROPIC_*` 환경변수를 뺀다(안 빼면 "Invalid API key"). launchd plist `tools/launchd/com.talkverse.ja.custom-script.plist`(5분) — **아직 올리지 않음, 사용자 확인 뒤**. 작업 파일 `data/custom_scripts/`(gitignore). janome 은 `~/.venvs/ja`.
- **라이트너** `lib/review`(uk 공용 엔진, 테스트 7개), 복습 탭 「오늘의 복습」, 카드 앞면 단어 그림.
- **학습자 프로필** `lib/services/learner_prefs.dart`(「나」 탭: 이름·성별, A 목소리 = 성별, `{name}` = 이름 또는 「〇〇」 — 사용자 지시 "성별이 정해지면 나가 나오는 거니까").
- **성과 표시** `lib/services/achievement_service.dart`(편 완주·본 한자·그림 카드·일별 기록·라이트너 분포·빈도 커버율) + `lib/widgets/achievement_desk.dart` 「나」 탭 데스크 + `EpisodeDoneOverlay`. 남은 것: 폰 레이아웃 다듬기, 홈 「오늘의 작은 성과」 카드(선택).
- **Grok UXUI 시안 02 「만화책 읽기형」 적용(사용자 확정 2026-11-02 15:45, 커밋 97cfa75→69e8f65)**: 편 화면 = `EpisodePlayPane(autoPlay:false)` 하나로 통일 — 칸 너비 900 이상(아이패드 가로) 좌 「대화 스크립트」·우 장면 컷(`SceneCut`, 말풍선·400ms 페이드)+캡션(`SelectableJaText` 한자 팝업), 900 미만 컷 위·스크립트 아래, 하단 고정 컨트롤(▶ 재생·슬라이더·속도·자막 칩). 회화 홈 맨 위 「오늘의 컷/이어서 읽기」. 시안 자료 `data/review/uxui/sian_01.md|jpg`(데스크형), `sian_02.md|jpg`(만화형, 채택), `sian_01_clay.jpg`(점토풍 참고 — 장면 그림 톤 기준), `sian_words_01.md|jpg`(단어 메뉴 시안, **사용자 확정 대기**). Grok GitHub 쓰기 권한 없어 답은 세션이 커밋.
- **Grok UXUI 요청 2회(옛 방, 참고)**(`data/review/uxui_ipad_request_01/02.md`, 답 `answer_01/02.md`): 시안 3개 + 성과 표시 원칙(세는 것: 편 완주·라이트너 단계·핵심 표현·한자·빈도 커버율 / 안 세는 것: 앱 오픈·스트릭·포인트·순위) + 맞춤 회화 메뉴 배치. 이미지 실패 → Claude 가 SVG: `data/review/wire/wire_01_desk.png`·`wire_02_achievement.png`·`wire_03_custom.png`, 생성기 `tools/wireframes.py`.
- **Talkverse ID 로그인·결제(평생 이용권)**: uk 세션 경유 사용자 지시(17:20 착수 → 17:25 보류 → 17:35 "지금 바로 착수"). 가이드 `/Users/talkverse/talkverse/TALKVERSE_ID_APP_GUIDE.md`, 원본 한자앱 `~/Hanja/hanja-app`. 값: client_id `ja`, 딥링크 `talkverse.ja://auth`, 이용권 lang `ja`(상품 iOS `com.talkverse.japaneseUniverse.lifetime`·Android `lang_ja`), 번들 iOS `com.talkverse.japaneseUniverse`·Android `com.talkverse.japanese_universe`. **구현 완료(e154d98)**: `lib/services/account.dart`·`purchase.dart`·`entitlement.dart`(premium = 로컬 스위치 OR 계정 이용권 ja OR 스토어 구매), `lib/screens/login_screen.dart`(구글·네이버·카카오·Apple + 이메일 데모)·`paywall_screen.dart`(참고가 ₩14,900), 「나」 탭 계정 칸, uk Worker 가 이용권 ja 확인해 402 면제(배포됨), AndroidManifest 콜백 `talkverse.ja`, `ios/Runner/Runner.entitlements` + pbxproj(`ios_release.sh` 가 아카이브에 ad-hoc 서명으로 entitlements 심음 — 2611021801 부터 applesignin 확인), `docs/store/review_notes.md`·`data_safety.md`. **사용자가 할 일**: App Store Connect 인앱 상품 `com.talkverse.japaneseUniverse.lifetime`·Play 일회성 상품 `lang_ja` 등록. 데모 계정 review@talkverse.uk 는 lang ja 이용권 보유. 방침 페이지 https://talkverse.uk/talkverse/ja/privacy/ (스토어 등록 때 이 URL).

- **2026-11-03 사용자 지시로 Grok 은 M4 Chrome 에서**(`~/talkverse/GROK_M4_LOGIN.md`): M4 프로필 `~/chrome-grok-ja`(쿠키는 M4 안에서 `~/chrome-grok` 것을 복사, M6 로 복사하면 안 풀림)를 M4 에서 포트 9230 으로 띄우고, M6 에서 `ssh -fN -L 9230:127.0.0.1:9230 macmini4` 터널 → 도구는 그대로 `GROK_CDP_PORT=9230`. 첨부는 `scp <파일> macmini4:/tmp/grok_att/ja/` 뒤 `GROK_ATT_DIR=/tmp/grok_att/ja`(장면 컷 도구)나 M4 경로로 `--attach`. M6 의 옛 9230 Chrome 은 끔. 건마다 새 탭을 열면 닫을 것. **Grok 은 사용자 지시가 있을 때만 켜고, 한 번에 한 작업, 끝나면 M4 의 일본어 Chrome 도 끈다**(공통 지시 2026-11-03).

## 3. 사용자 지시·결정(2026-11-02, 바꾸지 말 것)

- **회화 작성 재개(2026-11-03 사용자 "다이얼로그 이제 그록에 요청해서 작성해")**: 방식 = 편 설계(`data/review/write/specs_*.json`) → Grok 이 처음부터 작성(`tools/prompts/write_grok.md`, `tools/grok_write_batch.py`, 방 「일본어 회화 검수」) → `tools/write_to_json.py` → 검사기 `--fix-rd` → 턴 설명 → 리뷰 페이지. R3 문화·일·학업 18편 완료(616e0d7, 리뷰 176편). 남은 것: R4 본편, 강화 재작성 v2·맞춤 회화 워커는 계속 보류.
- **장면 컷(2026-11-03 사용자 "대화 컷그림도 요청해")**: `tools/grok_scene_batch.py <편id...> --push` — UXUI 방에서 **요청마다 새 대화**(긴 대화에선 그림 없이 '완료'만 답함), 인물 시트 `chars_ja_v1.jpg`+톤 `sian_01_clay.jpg` 첨부, A·B 한 쌍 = 1컷·4컷/요청, 1168×784 로 맞춰 그림 저장소 sparse 클론 `~/talkverse/ja-art`(talkverselab/talkversehanja) `talkverse_art/scene/ja/<편id>/cutN.jpg` 푸시(5편마다). 샘플 r1_survival_s1 통과 수준(점토 톤, 글자 없음). 전체 176편 대기열 `data/review/write/scene_queue.txt`, 로그 `scene_batch.log`(밤새 진행). 학습자 A 는 우선 남자 시트(5번) — 여자판은 나중에.
- **Grok UXUI 적용 전 기준 커밋 = 태그 `pre-grok-uxui`**(`57be3aa`, origin 에도 푸시됨). 되돌리기: `git checkout pre-grok-uxui -- lib/` 또는 `git revert`.
- Grok: **글 시안은 한 메시지에 1개, 그림은 최대 4장**(캐릭터 시트 한 번에, 장면 4컷까지 — 사용자 확인 "캐릭터도 한번에 해도 되고 장면도 4장까지"). 지연·실패가 난 방은 복구 안 됨 → 지우고 새로 만든다. 그림은 글 답 뒤에 늦게 오므로 `grok_fetch.py` 가 data: 썸네일을 BUSY 로 보고 기다린다. 다른 세션의 Chrome·탭은 건드리지 않는다.
- 「플루언트」·「섬」 등 특정 학습서 연상어 금지, 도메인은 **「주제」**. 왕초보(R0)는 짧은 편만(턴당 평균 8자 이하).
- 맞춤 회화: 외부 LLM API 안 씀(코드 서버 + Grok), Cloudflare 에 ID 로 저장, 1회 무료, "많이 쓰면 그때 생각".
- 한자: **배우기 먼저** → 문제. 한자 DB 자체는 바꾸지 않는다(한자유니버스 공용). **패밀리 한자 = 앱 자체 발음부 화면 구조**(사용자 "원래 니 구조가 더 좋았어", 2026-11-02 23:40). GIF·글자 형성(회의·형성 구조)·팁·어원·소리 가족은 공용 DB 에서.
- 장면 컷 규칙(한국어앱 경유 사용자 지시): 연애 = 썸·플러팅까지, 클럽 포함, 여성 주도 더 많이, 클리셰 일부만, Grok 「유지」 금지(모든 줄 새로), 그림 = A·B 쌍당 1컷·말풍선 없음, 캐릭터 시트 첨부.
- 강화 재작성 v2(`tools/prompts/rewrite_grok_v2.md`, `data/review/*_grok_enrich*`)는 보류 — Grok 스크립트 변경은 사용자가 요청할 때.
- 아이콘은 talkverse.uk 세션 담당. 메모·문서는 덧붙이지 말고 전체 다시 쓰기.

## 4. 다음 할 일

1. Zealot 은 CI 빌드(7b79bc4) 뒤 `tools/zealot_push.sh --ci` 로 올려 주소 보고(빌드 37 이후 미갱신).
0. 언어앱 공통 프롬프터 `/Users/talkverse/talkverse/LANG_APP_REPLICATE_PROMPT.md` 를 2026-11-02 밤 전체 다시 씀(순서 캐릭터→UX→아이패드 빌드→회화, Grok 은 한자 세션 경유) — uk 세션에 "배포 가능" 전달. 이 문서가 다른 언어앱의 기준.
2. 사용자 결정 대기: 단어 메뉴 시안 01(`data/review/uxui/sian_words_01.*`) 확정 → 적용 · 장면 컷 제작 착수(샘플 1편 = 4컷, `chars_ja_v1.jpg` 첨부) · 인앱 상품 등록(사용자 콘솔) · 다이얼로그 작성 재개 · 맞춤 회화 워커 재개(= `cp tools/launchd/com.talkverse.ja.custom-script.plist ~/Library/LaunchAgents/ && launchctl bootstrap gui/501 ~/Library/LaunchAgents/com.talkverse.ja.custom-script.plist`, 끝까지 2회 성공 확인됨 `ja-4inaalel`·`ja-fao34isa`).
3. 성과 데스크 폰 레이아웃 다듬기, 홈 「오늘의 작은 성과」 카드(선택).
4. 장면 그림 들어오면 턴 `art` 채우기(A 그림은 성별별 `art_m`/`art_f` 허용 예정).

## 4-1. 다른 언어앱 복제(2026-11-02 17:00~20:00)

- 복제 안내 `docs/REPLICATE_FOR_OTHER_LANGS.md`(§0 규칙·포트표·4장 규칙, §1 점토 톤·장면 컷 올리기/읽기, §2 UX 시안 02, §3 콘텐츠·연애 규칙, §4 파이프라인, §5 코드표, §6 빌드, §7 참고 파일). 전달한 것: 한국어앱 `~/talkverse/ko/RELAY_from_ja.md`(우리 회화가 기초, Gemini 없음, K-드라마·K-팝 상황, Chrome 9224 — 한국어앱 쪽 "콘텐츠 생성 금지"와 충돌은 사용자 확인 필요) · 태국어앱 `~/talkverse/th/RELAY_from_ja.md` + `RELAY_rewrite_prompt_from_ja.md`(Gemini 없음, Chrome 9225; 색표·UX 시안 th_01/02·캐릭터 시트 char_th_01/02 는 내 Chrome 으로 대행) · 베트남어앱 `~/talkverse/vi/RELAY_from_ja.md`(UX/UI 프롬프터, Chrome 9226) · 중국어앱 `~/talkverse/zh/RELAY_from_ja.md`(한자 층·패밀리 한자는 공용 DB, Chrome 9227; 방 2개 만들어 줌, sian_zh01/02·chars_zh01 대행) · 인도네시아어앱 `~/talkverse/id/RELAY_from_ja.md`(Chrome 9228). 17:30 사용자 지적("우리 톤은 점토 톤인데 쟤들은 모르네")으로 안내를 전부 다시 쓰고 재전달.

## 5. 공통 절차(맥미니)

```bash
cd ~/talkverse/ja && flutter analyze && flutter test        # 둘 다 통과 상태
git add <바꾼 파일만> && git commit && git push origin master  # CRLF 노이즈·부산물·RELAY_* 제외
bash tools/ios_release.sh                                    # TestFlight(번호 = KST yymmddHHMM)
tools/zealot_push.sh --ci "변경 한 줄"                        # CI 빌드 뒤 Zealot
GROK_CDP_PORT=9230 /usr/bin/python3 tools/grok_send.py <프롬프트> <답> --tab project/<id> --wait 600 [--attach a.jpg,b.jpg]
/usr/bin/python3 tools/grok_fetch.py project/<id> <답>       # 끝난 답 다시 받기(그림이 data: 면 BUSY → 다시)
python3 tools/pane_shots.py ACEBB37E-61E4-44FD-B30A-B3141BD7DE62 <폴더> integration_test/<테스트>.dart   # 아이패드 캡처(끝나면 simctl shutdown)
doppler run -p keys -c prd --no-check-version -- /usr/bin/python3 tools/custom_script_worker.py --once   # 맞춤 회화 1편
```
