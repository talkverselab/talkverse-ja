# 일본어유니버스 — 세션 인수인계 (2026-10-06 갱신)

## 2026-11-02 상태 (이 줄이 아래 옛 서술보다 우선)

- 화면 톤 = talkverse.uk 일본어 워드마크(흰 바탕·남색 글자·구리→황갈), 탭 4개 배우기·복습·탐색·나 + 두 화면(태블릿·아이패드·폴드) UX — `docs/TWO_PANE_UX.md`, `CLAUDE.md` §2-3. 아이패드 캡처 `tools/pane_shots.py`.
- iOS TestFlight 첫 업로드 2611012223, 두 번째(새 톤·UX) 2611020012 — `tools/ios_release.sh`, `CLAUDE.md` §2-2. 아이콘은 talkverse.uk 세션 담당(커밋 b57f527).
- 로그인(Google·Naver·Apple·Kakao)은 talkverse.uk 세션 담당 — `docs/AUTH_LOGIN.md`. 학습목적×도메인(회화 생성 축) — `docs/LEARNER_PROFILE.md`.
- Zealot 안드로이드 빌드 9(로컬, 새 톤·UX) https://apps.talkverse.uk/Ultzu/157. 이 커밋 push 로 CI 빌드가 다시 나간다.

## Zealot 설정 — 확인 필요 (2026-10-11)

앱이름 `일본어 유니버스`(사용자 지정), 스크립트 `tools/zealot_push.sh`, 규칙은 CLAUDE.md §2-1. 첫 업로드 완료 — CI 빌드 6, 설치 페이지 https://apps.talkverse.uk/Ultzu/33 . 커밋·푸시는 안 함.

- **남은 결정: Zealot 에 무엇을 올릴지** — 폰에 깔린 것은 CI 빌드(버전 코드 = CI 실행 번호)이고 로컬 빌드는 버전 코드 1 이라 그대로는 설치가 거부된다.
  - (지금 방식) CI 빌드를 그대로 올림: `tools/zealot_push.sh --ci`. 번호 체계가 앱 안 「앱 업데이트」와 같아 서로 꼬이지 않는다. 단, 푸시해서 CI 가 돈 뒤에만 올릴 수 있다.
  - 로컬 빌드를 올림: 푸시 전 시험판을 폰에서 볼 수 있지만 번호를 CI 보다 크게 줘야 하고, 그러면 다음 CI 빌드가 「앱 업데이트」에서 새 빌드로 안 보인다. 쓰려면 번호 규칙을 정해야 한다.

## 다음에 할 내용 (2026-10-11)

**이번 세션(2026-10-06~11)에 한 일**: HANDOFF·CLAUDE.md 를 읽고 상태를 요약한 것뿐이다. 코드·데이터·커밋·푸시·빌드 변경 없음. 아래 본문(§1~§5, 2026-10-06 기준)이 그대로 유효하다.

**현재 상태 (2026-10-11 확인)**
- 맥미니 `~/talkverse/ja` master = origin/master = `9054920`(앞선·뒤진 커밋 없음).
- 릴리스 `latest` = 빌드 6(`09cf2b7`). 단어 DB 8,525어·한국어 뜻 100%, 시드 키 `db_seeded_v7`. 회화는 L1 ep1 40턴만.
- 미커밋 변경은 CRLF 노이즈 + 맥 도구 부산물 4개(`analysis_options.yaml`, `ios/Flutter/Debug.xcconfig`·`Release.xcconfig`, `pubspec.lock`) + `?? ios/Podfile` 뿐 — 커밋하지 말 것(§1).
- 백그라운드 작업 없음.

**남은 일 (순서대로)** — 상세는 §3
1. 폰 확인(사용자) — 빌드 6 실제 동작.
2. 회화 L1 ep2~5 (160턴) → `_meta.json` 갱신 → L2·L3 각 300턴.
3. 회화 버블 후리가나 루비(`segs` 적용).
4. 문법 확장(동사 활용·경어).

**주의할 점**
- 푸시: 맥 `gh` 활성 계정은 gpyungbusan 유지, talkverselab 은 푸시 때만 전환 후 복귀(§2).
- 서명: 맥의 `~/.android/debug.keystore` 는 폰 키와 다르다 — 이미 있는 `android/app/signing-key.jks`·`key.properties` 를 덮어쓰지 말 것(§2).
- 단어 데이터를 바꾸면 시드 키를 v8 로.
- 전역 규칙이 바뀜(`~/.claude/CLAUDE.md`, 이 세션에서는 아직 적용한 적 없음):
  - 앱을 빌드하면 묻지 말고 `~/bin/zealot-upload <파일> "<앱이름>" -c "<변경 한 줄>"` 로 올리고 설치 주소를 알린다. 이 앱의 Zealot 앱이름은 `일본어 유니버스`(CLAUDE.md §2-1, 스크립트 `tools/zealot_push.sh`).
  - Apple Developer Program 가입 완료(2026-10-10) — §2 의 "iOS TestFlight 막힘" 원인 중 가입은 풀렸다. 경로는 맥미니에서 아카이브·업로드(표준 스크립트 `~/interval-camera/tools/ios_release.sh` 복사), 이 앱의 App Store Connect 앱 레코드는 사용자가 만들어야 한다. 미착수.
  - 맥 `~/OneDrive` 는 사용자 로그인 전까지 읽기 실패 — OneDrive 경로에 의존하는 작업은 먼저 확인.

**대기 중인 사용자 확인 사항**
- S25 에서 「앱 업데이트」로 빌드 6 설치 후: JLPT 단어 화면 N3·N1 한국어 뜻, 한자 화면(鋳·流 등)에 엉뚱한 단어가 없는지.
- 합성 TTS 도입 여부(현재 기기 ja-JP), 간사이 변형판 여부.
- iOS 를 진행할지(진행하면 App Store Connect 앱 레코드 생성 + TestFlight 내부 테스트 그룹 추가).

---

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 대화 기록은 없어도 된다.
> 규칙 배경은 CLAUDE.md 절 이름만 가리킨다: §1 서명 · 「폰에 설치할 때」 · §2 배포 흐름 · §3 리포 · §4 공개 저장소 · §5 표시 언어 · §6 갤럭시·아이폰 공용.
> 전역 배경(기기 IP·SSH·계정)은 `~/.claude/CLAUDE.md` 「기기」·「앱 · repo」 절.

## 1. 지금 상태

| 항목 | 값 | 비고 |
|---|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC) | 패키지 `com.talkverse.japanese_universe`, iOS 번들 `com.talkverse.japaneseUniverse` |
| origin/master | **`09cf2b7`** "자동 한자 변환 오류 표기 61어 삭제 + 시드 v7" | 이 HANDOFF 커밋이 그 위에 1개 더 올라감 |
| 맥미니 로컬 | origin/master 와 동일 (앞선 커밋 없음) | 아래 「커밋 안 한 로컬 변경」 참고 |
| 최신 릴리스 | `latest` = **빌드 6**, sha `09cf2b7`, 2026-10-03T12:19Z, APK 61.6MB | `latest.json` 의 `build` = CI 실행 번호 |
| CI | Release APK #6 성공 · iOS Build(unsigned) 성공 · iOS TestFlight skip(변수 미설정) | |
| pubspec | `version: 0.1.0+1` | 빌드 번호는 CI 가 덮어씀(CLAUDE.md §2) |
| 단어 DB | `assets/data/words/words_jlpt.json` **8,525어**, 한국어 뜻 **100%** | N5 735 · N4 676 · N3 2,135 · N2 1,744 · N1 2,698 · 급수없음 537 |
| 시드 키 | `db_seeded_v7` (`lib/data/db/seed_loader.dart:12`) | 단어 데이터를 바꾸면 반드시 v8 로 올릴 것 — 안 올리면 기존 설치 폰에 반영 안 됨 |
| 회화 | L1 ep1 40턴만 완성 (목표 L1 200 · L2 300 · L3 300) | `assets/data/dialogues/_meta.json` |
| talkverse-uk | `a154969`(ja·zh 한자 페이지) 푸시 완료 · 사이트 배포 완료 | 맥 `~/talkverse-uk` 에 `tools/th_cliff3.py` 미커밋 변경 = **다른 세션 것, 손대지 말 것** |
| 폰(S25) 실제 동작 | **미확인** — 빌드 6 을 「앱 업데이트」로 받아 한국어 뜻·한자 화면 확인 안 함 | |
| iOS TestFlight | **첫 업로드 완료 2026-11-01 빌드 2611012223**(맥미니 `tools/ios_release.sh`, 앱 레코드·내부 테스트 그룹 생성됨) | 리포 시크릿은 `ANDROID_DEBUG_KEYSTORE_BASE64` 1개뿐, Actions 변수 없음 |

**커밋 안 한 로컬 변경 (맥미니) — 커밋하지 말 것**
- ~86개 ` M` 파일 = CRLF 줄끝 노이즈(`git diff --ignore-cr-at-eol --stat` 으로 확인하면 아래 4개만 실변경).
- `analysis_options.yaml`(flutter analyze 가 analyzer exclude 자동 추가), `ios/Flutter/Debug.xcconfig`·`Release.xcconfig`(Pods include 1줄), `pubspec.lock`(패키지 소버전 상향), `?? ios/Podfile` — 맥 도구가 만든 부산물. 의도적으로 올릴 때만 따로 커밋.

**최근 작업 (2026-10-03)** — 커밋 `1404e12`·`21d723c`·`0dabf75`·`09cf2b7`
- N3 2,078 · N2·N1 4,410 · 급수없음 545어 한국어 뜻 작성(서브에이전트, 가나 기준). 작업 파일 `data/corpus/ko_gloss/{n3,n12,nx}_{todo,done}_*.json`.
- 급수없음 중 자동 한자 변환 오류 표기 61어(鋳る いる·パソ婚 등)는 **사용자 결정으로 삭제**. 목록 `data/corpus/ko_gloss/nx_badsurface_{1,2}.json`. 단어 학습 기록은 이 테이블을 참조하지 않아 영향 없음.

## 2. 막혀 있는 것

| 무엇 | 원인 | 푸는 법 |
|---|---|---|
| 맥에서 talkverselab 푸시 | 맥 `gh` 활성 계정이 **gpyungbusan**(다른 세션·interval-camera 용, 바꿔두지 말 것). talkverselab 은 2026-10-03 디바이스 코드로 추가 로그인됨 | `gh auth switch --user talkverselab && git push origin master; gh auth switch --user gpyungbusan`. 읽기만이면 `GH_TOKEN=$(gh auth token --user talkverselab) gh run list -R talkverselab/talkverse-ja` |
| uk 리포 SSH 푸시 | remote 가 `git@github.com:` 인데 맥 SSH 키(`id_ed25519_github`) GitHub 미등록 | `git push https://github.com/talkverselab/talkverse-uk.git main` (위처럼 계정 전환 후) |
| 노트북 `gh` | talkverselab·smalltaxoffice 토큰 둘 다 **invalid**(2026-10-03 확인) | 노트북 대화형 터미널에서 `gh auth login`. 원격이면 맥에서처럼 `gh auth login --hostname github.com --web` 를 백그라운드로 띄워 코드를 사용자에게 전달 |
| 원격 제어에서 `! 명령` | 모바일/원격 제어로 입력한 `! gh auth login` 은 **실행되지 않고 텍스트로 전달됨** | 대화형 로그인은 Claude 가 백그라운드로 띄우고 디바이스 코드(github.com/login/device)를 알려준다 |
| 맥의 `~/.android/debug.keystore` | **폰 키와 다른 키**(SHA-1 `BE:B3:8C…`). CLAUDE.md §1 의 `cp ~/.android/debug.keystore …` 를 맥에서 하면 서명이 바뀜 | 맥에는 이미 올바른 `android/app/signing-key.jks`(SHA-1 `9C:C4:BC…`) + `android/key.properties` 가 있음 — **덮어쓰지 말 것**. 새 기계는 리포 시크릿과 같은 키(노트북 `%USERPROFILE%\.android\debug.keystore`)를 복사 |
| 맥 adb | 맥에 adb 없음, 폰 케이블은 노트북에 연결 | 폰 설치는 앱 내 「앱 업데이트」(기본). 케이블이면 노트북 `%LOCALAPPDATA%\Android\platform-tools\adb.exe -s R3CY20HDN2K install --user 0 -r <apk>` |
| iOS TestFlight | Apple Developer 가입·ASC API 키·인증서·앱 레코드 = 사용자 작업 | 절차 `talkverse-th/docs/ios-build-and-testflight.md`, 인증서 `tools/ios/make_ios_cert.py`(th 와 공용 1개). 시크릿 6개 + 변수 `IOS_TESTFLIGHT_ENABLED=true` |

## 3. 다음 할 일 (순서대로)

1. **폰 확인(사용자)** — S25 앱 → 설정 → 「앱 업데이트」로 빌드 6 설치 → 첫 실행 후 JLPT 단어 화면에서 N3·N1 단어 한국어 뜻, 한자 화면(예: 鋳·流)에 엉뚱한 단어가 없는지 확인. 결과를 이 표 「폰 실제 동작」에 기록.
2. **회화 L1 ep2~5 (160턴)** — `assets/data/dialogues/L1.json`(ep1 40턴이 형식 견본), 끝나면 `_meta.json` 의 `current_turns`·`status` 갱신. CLAUDE.md §4: 대본은 자체 제작, 출처·작품명 금지. 이어서 L2·L3(각 300턴, schema `23dial`).
3. **회화 버블 후리가나 루비** — 단어 DB `segs`(후리가나 분절)를 회화 화면에 적용. 미착수.
4. **문법 확장** — 동사 활용·경어. `assets/data/grammar/`(현재 `particles.json`).
5. 미결(사용자 결정 필요): 합성 TTS(현재 기기 ja-JP), 간사이 변형판.

공통 절차 (맥미니):
```bash
cd ~/talkverse/ja
flutter analyze                      # 통과 확인 (No issues found)
# 단어 데이터 변경 시 seed_loader.dart 의 _kSeededKey 버전 +1
git add <바꾼 파일만>; git commit    # CRLF 노이즈·위 4개 부산물 제외
gh auth switch --user talkverselab && git push origin master; gh auth switch --user gpyungbusan
GH_TOKEN=$(gh auth token --user talkverselab) gh run list -R talkverselab/talkverse-ja -L 3   # ~5분 후 Release APK success 확인
```
`**.md` 만 바꾼 푸시는 안드로이드 빌드 안 함(CLAUDE.md §2).

## 4. 기계별 준비 상태

| | 맥미니 (주 작업기) | 노트북 | PC |
|---|---|---|---|
| repo 경로 | `~/talkverse/ja` — `09cf2b7`(최신) | `C:\Users\Johnjeon\talkverse\ja` — **`2efac0d`(5커밋 뒤, `git pull` 필요)** | 미확인(ja 클론 여부 모름) |
| 접속 | 로컬 | 맥에서 `ssh laptop`(셸 PowerShell — `&&` 불가, `;` 사용) | 맥에서 `ssh pc` |
| Flutter | 3.47.6 stable | `C:\flutter\bin\flutter.bat` | `C:\dev\tools\flutter\bin\flutter.bat` |
| Python | `python3` = 3.14(Homebrew), `~/.local/bin/python3.12`(uk `build_home.py` 용), 시스템 3.9 는 f-string 오류 | 미확인 | — |
| 서명 키 | `android/app/signing-key.jks` + `android/key.properties` ✅ 올바른 키 | `key.properties`·`signing-key.jks` 있음 ✅ | — |
| gh | talkverselab ✅(전환해서 사용), 활성 gpyungbusan | ❌ 토큰 만료 | — |
| adb / 폰 | ❌ 없음 | ✅ `%LOCALAPPDATA%\Android\platform-tools\adb.exe`(PATH 미등록) | PATH 에 없음 |
| iOS 빌드 | Xcode 26.6 있음(로컬 iOS 빌드는 미시도), CI 무서명 빌드는 통과 | ❌ | ❌ |

## 5. 결정 사항 (바꾸지 말 것)

- 서명: 새 키스토어 금지, CI `Restore signing key` 유지 (CLAUDE.md §1). 폰 설치는 `--user 0` (「폰에 설치할 때」).
- 학습 정렬은 JLPT 가 아니라 **회화 빈도 절벽구간 R1 1-294 · R2 295-437 · R3 438-998 · R4 999-**. JLPT 는 배지.
- 발음부 완전공유 = 일본 음독 + 한국 한자음 모두 일치. 한글독음 토글 유지.
- 한국어 뜻 형식: 뜻 1~3개 ` · ` 구분, 용언은 `~다`, 동음이의 구분할 때만 한자 괄호(`이상 (異常)`), 가나·로마자 금지. 말뭉치 단어는 **가나(실제 발음) 기준**.
- 자동 한자 변환 오류 표기 단어는 고치지 않고 **삭제**(2026-10-03 사용자 결정).
- 맥 `gh` 활성 계정은 gpyungbusan 유지, talkverselab 은 푸시 때만 전환.
- 화면 문구 `tr()`/`trf()` + 세 사전 동시 추가(§5), 회화·단어 콘텐츠는 번역 안 함. 플랫폼 판단 `lib/core/platform.dart`, 바닥 여백 `bottomInset(context)`(§6).
- 공개 리포: 출처명·작품명·원문 금지(§4).

## 부록 — 데이터·생성기 지도

- 절벽: `data/corpus/lang_ja_with_regions.csv`(단어 rank·cum·region) · `ja_kanji_weighted_freq.csv`(한자 1,078) · `ja_cliff_summary.md`.
- 생성기: `tool/gen_phonetic_ja.py`(발음부, IDS 필요) · `tool/gen_gairaigo.py`+`gairaigo_ko_fix.py`(외래어) · `tool/parse_essential_days.py`.
- 단어 DB 필드: surface·kana·jlpt·en·ko·rank·src(`jlpt`/`corpus`)·id·segs. 파일은 한 줄 압축 JSON(`separators=(',',':')`, `ensure_ascii=False`) — 같은 형식으로 다시 쓸 것.
- 소개 사이트(`~/talkverse-uk` → talkverse.uk): ja 절벽 곡선·JLPT 교차표·`/talkverse/lang/ja-kanji`(1,078자). 생성기 `tools/build_cliff_kanji.py`(이 리포 CSV 를 읽음 — 절벽 데이터 바뀌면 재실행), 메인 `tools/build_home.py`(**python3.12**). 배포 `npx wrangler deploy`.
- 최근 변경 이력 상세: `CLAUDE_UPDATES.md`, `git log`.

## 진행 중 백그라운드 작업

없음 (2026-10-06 기준 — N3·N2·N1·급수없음 뜻 작업과 CI 빌드 6 모두 완료).

## 2026-11-03 새벽 — 새 회화 양산 중 (사용자 취침, 리뷰는 https://talkverse.uk/talkverse/review/ja/ )
- 규칙 한 벌: `docs/DIALOGUE_WORKFLOW_JA.md`(톤·파이프라인·Grok 조작·리뷰 게시·참고 책). 파이프라인 = 초안 JSON → `tools/check_dialogues.py --fix-rd` → Grok 재작성(`tools/grok_send.py`, 프로젝트 「일본어 회화 검수」) → 최소 수정 → `tools/review_html.py` → uk 세션에 "REVIEW_ja.html 갱신".
- **2026-11-03 오전 사용자 지시로 중단("지금하던거까지만 하고 멈춰")**: R1 83 + R2 56 + R3 연애 6·친구 6 = 151편 작성·Grok 반영·검사기 0 오류. R3 생활·여행 b1~b6 도 Grok 반영 완료(사용자 지시 "그록 미전송은 마저 해"). 남은 것: R3 문화·일·학업(각 6), R4 전부. 리뷰 페이지 157편(R3 연애·친구·생활·여행 각 6 포함) 게시 요청. 페이지에 턴·편 리뷰 입력칸+저장 버튼 추가(`tools/review_html.py`, 저장 API `https://talkverse.uk/api/review/ja` POST {key,text,at}/GET — uk 세션이 개설, 미개설 시 localStorage). 사용자 리뷰는 GET 으로 읽어 반영.
- **R1 완성(2026-11-03 06시경)**: 서바이벌 3 + 친구·연애·생활·여행·문화 각 16 = 83편, 전부 Grok 재작성 반영·검사기 0 오류·리뷰 페이지 게시(79편 + R2·R3 샘플). 통과 표시는 S1·S2·연애 a1 만. R2 연애 b2~b8 초안 완료·Grok 대기(chain12). 다음: R2 친구·생활·여행·문화·일·학업(각 8편, 8~12턴), R3·R4. 표현 풀 162개(`data/expressions/top_expressions.csv`).
- 커밋은 사용자 지시 뒤에만(지금 전부 미커밋). 검사기 규칙 완화 이력은 docs/DIALOGUE_WORKFLOW_JA.md §2.
- 그림 단어 목록 `docs/grok_ja_words_all.csv`(1,172) · `docs/grok_ja_food50.csv` 는 uk 세션이 받아 D1 적재 완료. 그림 API: GET https://auth.talkverse.uk/art/ja/manifest?level=R1 (13시 라이트너 작업 때 카드 앞면에 붙일 것).
