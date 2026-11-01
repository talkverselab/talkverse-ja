# CLAUDE.md — talkverselab/talkverse-ja

이 폴더에서 작업하는 모든 세션이 먼저 읽는 규칙. **빌드·배포를 건드리기 전에 반드시 확인할 것.**

## 1. 서명 (가장 자주 사고 나는 곳)

이 앱은 GitHub 릴리스로 **앱 안에서 스스로 업데이트**한다.
폰에 이미 깔린 앱과 **서명 키가 같아야만** 덮어쓰기 설치가 된다.

### 쓰는 키 — 새로 만들지 말 것

- 폰에 깔린 앱과 같은 키: 로컬 `~/.android/debug.keystore`
  (alias `androiddebugkey`, store/key 비밀번호 `android`)
- SHA-1 `9C:C4:BC:93:26:38:BE:43:A3:98:2D:F2:0B:71:C4:75:02:88:47:6B`
- 같은 키가 리포 시크릿 **`ANDROID_DEBUG_KEYSTORE_BASE64`** 에 base64로 들어 있고, CI가 이걸 복원해 서명한다.
- 로컬에서 릴리스 빌드할 때도 같은 키를 쓴다. `android/key.properties`가 없으면 이렇게 만든다:

```bash
cp ~/.android/debug.keystore android/app/signing-key.jks
printf 'storePassword=android\nkeyPassword=android\nkeyAlias=androiddebugkey\nstoreFile=signing-key.jks\n' > android/key.properties
```

### 절대 하지 말 것

- **새 키스토어를 만들지 말 것.** 서명이 바뀌면 폰에서 앱을 지웠다 다시 깔아야 하고, **학습 기록이 전부 사라진다.**
- CI의 `Restore signing key` 단계를 지우거나, `build.gradle.kts`의 release 서명을
  `signingConfigs.getByName("debug")` 로 되돌리지 말 것.
  GitHub 러너는 빌드할 때마다 debug 키를 **새로 만들어** 서명이 매번 달라진다.
  (2026-09-10에 실제로 겪은 문제 — 17개 앱 설치가 전부 `INSTALL_FAILED_UPDATE_INCOMPATIBLE`로 실패했다.)
- `android/key.properties`, `android/app/signing-key.jks`를 커밋하지 말 것 (`.gitignore`에 있음).

### 설치가 실패하면

```
INSTALL_FAILED_UPDATE_INCOMPATIBLE: signatures do not match
```

→ 앱을 지우지 말고 **서명부터 확인**한다:

```bash
apksigner verify --print-certs <apk> | grep SHA-1   # 9cc4bc932638be43a3982df20b71c4750288476b 여야 한다
```

## 폰에 설치할 때 (PC에서 케이블로)

폰에 **듀얼 메신저 프로필(user 95)** 과 보안 폴더(user 150)가 있다. `adb install` 은 프로필을 지정하지 않으면
**모든 프로필에 설치**해서 앱 아이콘이 두 개(파란 말풍선 배지 달린 복제본)가 생긴다. 반드시 기본 프로필만 지정한다:

```bash
adb -s R3CY20HDN2K install --user 0 -r <apk>
```

(2026-09-11에 24개 앱이 전부 두 개씩 깔려 있던 것을 정리함. 앱 안의 「앱 업데이트」로 설치하면 이 문제는 생기지 않는다.)

## 2. 배포 흐름

- `master`(또는 기본 브랜치) 푸시 → GitHub Actions(`.github/workflows/release.yml`)가
  서명된 APK와 `latest.json`을 `latest` 릴리스에 올린다.
- **빌드 번호 = 워크플로 실행 번호**(`--build-number=${{ github.run_number }}`).
  앱은 자기 빌드 번호와 `latest.json`의 `build`를 견주어 새 빌드를 판단한다.
  로컬 `flutter build apk`로 만든 APK는 pubspec의 작은 번호를 써서 앱이 늘 "새 빌드 있음"으로 보인다 — 정상.
- `**.md`만 고친 푸시는 빌드하지 않는다(`paths-ignore`). 헛된 업데이트 알림 방지.
- **폰 업데이트**: 앱 → 설정(프로필) 화면 → **「앱 업데이트」** → 내려받아 설치. 케이블·adb 불필요.
  첫 설치 때 「출처를 알 수 없는 앱 설치」 허용이 한 번 필요하다(안드로이드 강제).

관련 파일: `lib/services/update_service.dart`, `lib/screens/update_screen.dart`,
`android/app/src/main/kotlin/**/MainActivity.kt`(설치 메서드 채널),
`android/app/src/main/res/xml/file_paths.xml`, `.github/workflows/release.yml`

구현 안내서: https://github.com/talkverselab/talkverse-th/blob/master/docs/in-app-update-via-github.md

## 2-1. Zealot 업로드 (맥미니) — 2026-10-11

- **Zealot 앱이름: 일본어 유니버스** (고정 — 바꾸면 Zealot 에 다른 앱이 새로 생긴다)
- 올리기: `tools/zealot_push.sh ["변경 한 줄"]`(로컬에서 빌드한 release APK) 또는
  `tools/zealot_push.sh --ci ["변경 한 줄"]`(GitHub `latest` 릴리스의 CI 빌드를 받아서). 변경 내용을 안 주면 최근 커밋 제목.
  스크립트는 빌드하지 않는다. 출력된 설치 주소를 사용자에게 알린다.
- 덮어 설치 조건(2026-10-11 확인): **서명** — 맥의 `android/key.properties` + `android/app/signing-key.jks` 가 폰과 같은 키
  (SHA-1 `9C:C4:…:47:6B`)라 로컬 빌드도 CI 빌드도 덮어 설치된다. **버전 코드** — `pubspec.yaml` 은 `0.1.0+1` 고정이고
  CI 가 실행 번호를 넣는다(폰에 깔린 것 = 6). 로컬 빌드를 그냥 올리면 버전 코드 1 이라 **다운그레이드로 설치가 거부된다** —
  로컬에서 빌드할 때는 `--build-number=<폰에 깔린 번호보다 큰 값>` 을 주거나 `--ci` 로 CI 빌드를 올릴 것.

## 2-2. iOS TestFlight (맥미니) — 2026-11-01

- App Store Connect 앱 레코드 **일본어 유니버스**(번들 ID `com.talkverse.japaneseUniverse`, 사용자 생성 2026-11-01) + 내부 테스트 그룹. 첫 업로드 = 빌드 2611012223.
- 올리기: `bash tools/ios_release.sh` — 아카이브(`--no-codesign`, 빌드 번호 = KST `yymmddHHMM`) → 자동 서명 export(팀 QP8QRMA9CC, pbxproj 에 `DEVELOPMENT_TEAM` 6곳) → PC `D:\OneDrive\app project\japanese_universe\ios\` 백업 → 업로드. `--no-build` 는 있는 아카이브로 업로드만.
- 아이콘: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` 은 1024 한 장 + 다크·틴티드(iOS 18+ 정책). **아이콘 생성·배포 안내는 2026-11-02 사용자 지시로 talkverse.uk 세션 담당** — 이 세션은 아이콘을 만지지 않고, 그 세션이 보내는 결과(`~/talkverse/branding/make_icon.py` 재실행 지시)를 따른다. 옛 15장 방식으로 되돌리지 말 것.
- `Info.plist` `ITSAppUsesNonExemptEncryption=false`. 같은 빌드 번호 재업로드 불가(시각 기반이라 새로 빌드하면 자동으로 커짐).
- 공통 절차·정책: `~/talkverse/branding/TONE.md` §2-1·§5.

## 2-3. 화면 톤 · 두 화면 UX — 2026-11-02

- **톤 기준 = https://talkverse.uk/talkverse/lang/ja 의 「일본어」 워드마크**(사용자 지시): 흰 바탕·남색 글자(`#0a2540`)·구리 `#b77548` → 황갈 `#c19e6d` 그라데이션 포인트(`AppColors.wordmark`, `GradText`). 색 이름(beni·ai·kin·sumi·washi)은 옛 和風 것 그대로이고 **값만** `lib/core/theme.dart` 에서 바뀜 — 새 화면도 이 이름을 쓴다. 테두리는 `AppColors.line`, 그림자는 `kCardShadow`. 옛 빨강·먹색 바탕으로 되돌리지 말 것.
- **탭 4개 배우기·복습·탐색·나 + 두 화면(가로 720 이상 레일·왼쪽 목록·오른쪽 칸, 학습은 전체 화면)** = 한자유니버스와 같은 구조. 규칙·확인법은 `docs/TWO_PANE_UX.md`. 새 화면은 목록에서 `openPane`, 학습·퀴즈·카드 세션은 `openFull` 로 연다(`lib/core/pane.dart`).

## 3. 리포

- 이름은 **`talkverselab/talkverse-<언어코드>`** 로 통일(2026-09-10). 옛 이름(`ja-universe` 등)은 리다이렉트되지만
  remote는 새 이름으로 바꿔 둘 것: `git remote set-url origin https://github.com/talkverselab/talkverse-ja.git`
- **공개(PUBLIC) 저장소**다. 앱이 토큰 없이 APK를 받으려면 공개여야 한다.
- 다운로드 허브: https://github.com/talkverselab/talkverse-releases

## 4. 공개 저장소라서 지킬 것

- **출처를 드러내지 말 것.** 자막·말뭉치 제공처 이름(스트리밍 서비스, 공개 자막 데이터셋 등), 책 이름·쪽수,
  드라마·영화 제목을 코드·에셋·문서·파일명·화면 문구 어디에도 남기지 않는다.
- 저작권 있는 원문(자막 대본, 원서 전사)을 리포에 넣지 않는다. 단어·빈도 통계만 쓰고 문장은 자체 제작한다.
- 새 파일을 추가할 때 위 두 가지를 먼저 확인할 것. 한 번 공개 커밋되면 히스토리에 남는다.

## 5. 표시 언어 (한국어 / English / 日本語 / 中文) — 2026-09-12

- 프로필 · 설정 → 「언어 / Language」 를 탭할 때마다 한국어 → English → 日本語 → 中文 순으로 바뀐다.
  `AppLangPrefs`(`lib/core/l10n.dart`)가 값을 들고 있고, 바뀌면 `main.dart` 의 `MaterialApp` key 가 바뀌어
  앱 전체가 새로 그려진다(홈으로 돌아감).
- **UI 문구는 `tr('한국어')` / `trf('{0}개', [n])` 로 감싼다.** 번역은 `lib/core/l10n_dict.dart` 의
  `kDictEn` / `kDictJa` / `kDictZh` 에서 찾고, 없으면 한국어가 그대로 나온다.
  새 문구를 추가하면 세 사전에 한 줄씩 넣을 것. 키는 코드의 한국어 문자열 그대로(보간은 `{0},{1}` 템플릿).
- `tr()` 은 const 가 아니다 — `const Text(tr(...))` 처럼 쓰면 컴파일 오류. 그 위젯의 `const` 를 뺀다.
  enum 생성자·`static const`·`case` 패턴에는 못 쓴다(한국어를 두고 getter 에서 `tr()`).
- **회화·단어·문법 콘텐츠(뜻·번역·설명)는 번역 대상이 아니다** — 화면 문구(메뉴·버튼·안내)만 바뀐다.
- 사전은 이 앱 전용(`_update_kit/l10n/dict_ja_app.dart` 원본).

## 6. 갤럭시·아이폰 공용 인터페이스 — 2026-09-12

- 플랫폼 판단은 `lib/core/platform.dart` 의 `isIOS` / `isAndroid` 만 쓴다(`dart:io` Platform 직접 호출 금지 — 웹·테스트에서 깨짐).
- **화면 아래 고정 버튼·목록 바닥 여백은 `bottomInset(context)` 를 더한다**
  (`EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context))`). 아이폰 홈 인디케이터(34pt)·갤럭시 제스처 바에 가려지지 않게.
  새 화면을 만들 때도 같은 규칙.
- 글자 확대 상한 1.2배(`main.dart` builder) — 아이폰 Dynamic Type 로 타일이 깨지는 것 방지.
- iOS 오디오: `TtsService` 와 `AudioService` 가 iOS 에서 재생 카테고리(playback)를 잡는다 — 무음 스위치에서도 소리가 난다. 지우지 말 것.
- 「앱 업데이트」 타일은 Android 전용(APK 설치 채널). iOS 는 TestFlight 안내 타일이 대신 나온다. `UpdateService.install` 은 Android 에서만 호출.

