# 일본어유니버스 — 세션 인수인계 (2026-11-02 오후, 전체 다시 씀)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`.

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC) · origin = 로컬 `7d1e3bb`(한자 배우기·맞춤 회화·워커). 미커밋 = CRLF 노이즈 + 도구 부산물 + `data/review/*_grok_enrich*`(보류 작업) + `data/review/wire/`(와이어프레임) — 의도적으로만 커밋 |
| iOS TestFlight | 2611021502(새 회화 뷰어·단어 섹션·라이트너·한자 DB) → **2611021514**(한자 배우기·맞춤 회화) 업로드 완료 — `tools/ios_release.sh`, 번들 `com.talkverse.japaneseUniverse`, 유니버설(아이폰+아이패드) |
| Android | CI 빌드 = 푸시마다 자동, Zealot 「일본어 유니버스」 빌드 14 https://apps.talkverse.uk/Ultzu/174 (`tools/zealot_push.sh --ci`) |
| 회화 콘텐츠 | R0 77(옛 R1 짧은 편 스냅숏) · R1 83 · R2 56 · R3 24(친구·사랑·생활·여행 각 6) · R4 1 = 241편, `assets/data/dialogues/<R>/<섬>/*.json`, 검사기 0 오류. 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ (157편, 턴·편 저장칸, API `https://talkverse.uk/api/review/ja`) |
| 단어 DB | 8,525어 한국어 뜻 100%, 시드 키 `db_seeded_v7`(데이터 바꾸면 v8) |
| 그림 | 단어 그림 = `ArtService`(`GET https://auth.talkverse.uk/art/ja/manifest`, 512 webp). 장면 그림(만화 1컷)은 아직 없음 → 턴 `art` 필드 비어 있음 |
| Grok 프로젝트 | 「일본어 회화 검수」 `project/84ed846e`(재작성) · 「talkverse UXUI」 `f159291c-8899-4adf-806c-b8e79e709694`(2026-11-02 재생성, 비어 있음) · 전용 Chrome CDP 127.0.0.1:9222 |

## 2. 2026-11-02 에 만든 것(전부 푸시됨)

- **새 회화 뷰어**: `lib/screens/dialogue_screen.dart`(섬 → 편 → 편 화면, 왕초보/초보 전환), `lib/services/dialogue_service.dart`(R0~R4 로더, `speakerName()` = `{name}` → 「나」), `lib/widgets/episode_play_pane.dart`(「모든 문장 듣기」 순차 TTS·배속·자막 단계·그림 칸, 컨트롤 줄 가로 스크롤), `lib/screens/dialogue_card_screen.dart`(그림만 앞면 카드).
- **배우기 탭**: 「회화 (새)」(섬별 회화 + 맞춤 회화) · 「단어」(절벽·필수·JLPT) · 기초에 **「한자 배우기」** 추가.
- **한자 배우기** `lib/screens/kanji_learn_screen.dart`: 단계(20자)를 한 글자씩 `KanjiInfoBody`(한자 팝업과 같은 내용 — 훈음·읽기·한자유니버스 공용 DB 글자 형성·팁·어원·소리 가족·그림·대표 단어·읽기별 단어)로 먼저 보고 → 「이 단계 문제 풀기」(기존 4지선다). 아이패드 = 왼쪽 20자 격자 + 오른쪽 정보. `KanjiStagesScreen(learn: true)`. 「한자 단계」(바로 문제)는 그대로.
- **맞춤 회화(유료 메뉴, 첫 1편 무료)**: 계약 `docs/CUSTOM_SCRIPT_API.md`. 앱 `lib/services/custom_script_service.dart`(기기 ID, POST/GET `https://talkverse.uk/api/script/ja`, ready 편 로컬 보관) + `lib/screens/custom_script_screen.dart`(섬 8 칩 → 상황 입력+추천 칩 → 레벨 4 → 만들기, 「내 맞춤 회화」 서랍 1분 폴링). Worker·D1(`custom_scripts`·`paid_devices`)은 talkverse.uk 세션이 배포, 시크릿 `SCRIPT_KEY` 는 사용자가 넣음(완료). 코드 서버 워커 `tools/custom_script_worker.py`(pending → claim → `claude-lab -p` 초안(`tools/prompts/custom_script.md`) → Grok 재작성(`rewrite_grok.md`) → `check_dialogues --fix-rd` → result). 키는 `doppler run -p keys -c prd --`(`TALKVERSE_SCRIPT_KEY`), Claude 호출 때는 `ANTHROPIC_*` 환경변수를 뺀다(안 빼면 "Invalid API key"). launchd plist `tools/launchd/com.talkverse.ja.custom-script.plist`(5분) — **아직 올리지 않음, 사용자 확인 뒤**. 작업 파일 `data/custom_scripts/`(gitignore).
- **라이트너** `lib/review`(uk 공용 엔진, 테스트 7개), 복습 탭 「오늘의 복습」, 카드 앞면 단어 그림.
- **Grok UXUI 요청 2회**(`data/review/uxui_ipad_request_01/02.md`, 답 `answer_01/02.md`): 시안 3개(①만화 읽기형 ②채팅형 ③학습 데스크형, 1순위 ③) + 성과 표시 원칙(세는 것: 편 완주·라이트너 단계·핵심 표현·한자·빈도 커버율 / 안 세는 것: 앱 오픈·스트릭·포인트·순위) + 맞춤 회화 메뉴 배치. **이미지는 6장 전부 실패** → Claude 가 SVG 로 그림: `data/review/wire/wire_01_desk.png`(홈→편→재생) · `wire_02_achievement.png`(「나」 탭 성과) · `wire_03_custom.png`(맞춤 회화). 생성기 `tools/wireframes.py`(SVG → `data/review/wire/*.svg`, PNG 는 CDP Chrome 캡처).

## 3. 사용자 지시·결정(2026-11-02, 바꾸지 말 것)

- Grok **그림 요청은 한 메시지에 1장**. 지연·실패가 난 Grok 방은 복구 안 됨 → 지우고 새로 만든다(UXUI 방 재생성 사유). UXUI 큰 변경은 다음 요청 때 한꺼번에 Grok 에.
- 맞춤 회화: 외부 LLM API 안 씀(코드 서버 + Grok), Cloudflare 에 ID 로 저장, 1회 무료, "많이 쓰면 그때 생각".
- 한자: 바로 문제가 아니라 **배우기 먼저** → 문제. 한자 DB 자체는 바꾸지 않는다(한자유니버스 공용).
- 강화 재작성 v2(`tools/prompts/rewrite_grok_v2.md`, `data/review/*_grok_enrich*`)는 보류 — Grok 스크립트 변경은 사용자가 요청할 때.
- 아이콘은 talkverse.uk 세션 담당. 메모·문서는 덧붙이지 말고 전체 다시 쓰기.

## 4. 다음 할 일

1. TestFlight 빌드(한자 배우기·맞춤 회화) 번호 확인 → 사용자에게. 사용자 피드백 대기 항목: "다이얼로그 한번에 보기"·"단어장 안 보임"(둘 다 2611021424 에 없던 기능, 1502 이후 포함 — 다른 뜻이면 확인).
2. 맞춤 회화 워커 **끝까지 1회 성공**(시험 `ja-4inaalel` 「늦은 밤의 주먹밥」 8턴: 초안 32초 → Grok 재작성 4/8턴 반영 → 독음·검사 0 오류 → ready). 사용자 확인 뒤 launchd 가동(`cp tools/launchd/com.talkverse.ja.custom-script.plist ~/Library/LaunchAgents/ && launchctl bootstrap gui/501 ~/Library/LaunchAgents/com.talkverse.ja.custom-script.plist`). 앱에서 실제로 1편 만들어 서랍에 뜨는지 확인. janome 은 `~/.venvs/ja`.
3. 성과 표시(「나」 탭 AchievementDesk · 편 끝 ProgressSummaryCard · 빈도 커버율) 구현 — 설계는 `uxui_ipad_answer_02.md` B + `wire_02`.
4. 시안 ③ 학습 데스크형으로 아이패드 재배치(사용자 승인 뒤) → 그다음 폰 최적화.
5. 장면 그림(만화 1컷) 들어오면 턴 `art` 채우기. R3 문화·일·학업, R4 본편 작성 재개.

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
