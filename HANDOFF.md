# 일본어유니버스 — 세션 인수인계 (2026-10-02 정리)

> 새 Claude Code 세션은 `CLAUDE.md`(규칙 SSOT: 서명·배포·공개리포 수칙·표시언어·듀얼폰)를 먼저 읽고,
> 이 파일로 현재 상태와 남은 일을 파악한 뒤 이어서 작업한다.
> 앱: Flutter · GitHub `talkverselab/talkverse-ja`(master, PUBLIC) · 패키지 `com.talkverse.japanese_universe` · 폰 S25 `R3CY20HDN2K`
> 작업 기계: 2026-09-28부터 **맥미니**(`~/talkverse/ja`)가 주 기계. 노트북 경로는 `C:\Users\Johnjeon\talkverse\ja`.

## 0. 현재 상태

- origin/master = **`2efac0d`** "표시 언어 4종 + 갤럭시·아이폰 공용 인터페이스 + iOS 빌드 초안".
  로컬(맥)은 그 위에 이 HANDOFF 커밋 1개 — **push 대기** (아래 인증 문제).
- 맥에서 `git status`에 ~91개 파일이 M으로 보이면 **CRLF 줄끝 노이즈**다(`git diff --ignore-cr-at-eol --stat`이 비면 실변경 0). 그대로 두고 커밋하지 말 것.
- ⚠ **맥미니에서 talkverselab 리포 push 불가**: 맥 `gh`는 gpyungbusan 계정, SSH 키(`id_ed25519_github`)는 GitHub 미등록, 노트북 `gh` 토큰도 만료 상태(2026-09-30 확인). 해결 전까지는 커밋만 쌓고, 푸시가 필요하면 사용자에게 `gh auth login`(맥, talkverselab) 요청. 임시 우회: `git bundle` → `scp laptop:` → 노트북 대화형 터미널에서 push.

## 1. 규칙 (CLAUDE.md가 원본 — 여기엔 요점만)

- 서명: 새 키스토어 금지, CI `Restore signing key` 유지. 폰 설치는 `adb install --user 0`.
- 공개 리포: 출처명(자막 제공처·책·드라마 제목) 금지, 원문 코퍼스 금지.
- 학습 정렬은 JLPT가 아니라 **회화 빈도 절벽구간 R1 1-294 · R2 295-437 · R3 438-998 · R4 999-** (사용자 확정). JLPT는 배지.
- 발음부 완전공유 = 일본 음독 + 한국 한자음 모두 일치. 한글독음 토글 유지.
- UI 문구는 `tr()`/`trf()`, 플랫폼 판단은 `lib/core/platform.dart`, 바닥 여백 `bottomInset(context)`.

## 2. 반복 절차

```bash
# 분석·빌드 (맥)
flutter analyze && flutter build apk --release
# 폰 설치는 앱 내 「앱 업데이트」가 기본 (케이블 불필요). 케이블이면:
adb -s R3CY20HDN2K install --user 0 -r build/app/outputs/flutter-apk/app-release.apk
```
- master 푸시 → CI가 서명 APK + `latest.json`을 `latest` 릴리스에 올림. `**.md`·`ios/**`만 바꾼 푸시는 안드로이드 빌드 안 함.
- iOS: `ios-build.yml`(무서명, 자동) / `ios-testflight.yml`(변수 `IOS_TESTFLIGHT_ENABLED` 켜기 전까지 skip).

## 3. 최근 변경 (2026-09-08 ~ 09-12, 상세는 CLAUDE_UPDATES.md·git log)

- 50음도와 발음(IPA·모음비교차트), 발음부 198가족(절벽 정렬·4분류), 영어등유래단어(1단계 248/2단계 636), 한자음 매핑 그리드, 한자 단계 빈도순 토글(+500 오프셋 키).
- 앱 내 자동 업데이트(GitHub 릴리스) + CI 서명 고정.
- 표시 언어 4종(한국어→English→日本語→中文), 갤럭시·아이폰 공용 인터페이스, iOS CI 이식(번들 `com.talkverse.japaneseUniverse`, 무서명 빌드 통과).

## 4. 남은 일 (우선순위 없음, 요청 오면 진행)

- **iOS TestFlight** — 사용자 단계 대기: Apple Developer Program 가입 → ASC API 키 발급 → `tools/ios/make_ios_cert.py`로 인증서(팀 공용 1개, th와 공유) → 앱 레코드 생성 → 리포 시크릿 6개 + `IOS_TESTFLIGHT_ENABLED=true`. 절차 전체: `talkverse-th/docs/ios-build-and-testflight.md`.
- 회화 콘텐츠: L1 ep2~5(160턴)·L2·L3 미작성. 회화 버블 후리가나 루비 미적용.
- N2·N1 한국어 뜻 채우기(N5·N4·N3 3,546어 100% — N3 2,135어는 2026-10-03 완료, `data/corpus/ko_gloss/n3_*`; N2 1,744·N1 2,698어는 영어 gloss).
- 합성 TTS 미결(현재 기기 ja-JP), 간사이 변형판, 동사 활용·경어 문법 확장.

## 5. 데이터·생성기 지도

- 절벽: `data/corpus/lang_ja_with_regions.csv`(단어 rank·cum·region) · `ja_kanji_weighted_freq.csv`(한자 1,078) · `ja_cliff_summary.md`.
- 생성기: `tool/gen_phonetic_ja.py`(발음부, IDS 필요) · `tool/gen_gairaigo.py`+`gairaigo_ko_fix.py`(외래어) · `tool/parse_essential_days.py`.
- JLPT 단어 8,586어: `assets/data/words/words_jlpt.json`(surface·kana·jlpt·ko·rank·segs).

## 6. 소개 사이트 연계 (`~/talkverse-uk` → talkverse.uk)

- ja 소개 페이지에 절벽구간 곡선 2종(단어·한자, 빨간 절벽선)·JLPT 교차표·타 자료 검증, 절벽구간별 한자 1,078자 나열 페이지(`/talkverse/lang/ja-kanji`). zh도 동일 구성(`zh-hanzi`, 1,207자).
- 생성기 `tools/build_cliff_kanji.py`(이 리포의 CSV를 읽음 — ja 절벽 데이터가 바뀌면 재실행), 메인 재생성은 `tools/build_home.py`(**맥은 python3.12로** — 3.9는 f-string 문법 오류).
- ⚠ uk 리포 커밋 `a154969`(한자 페이지)가 push 미완(위 0의 인증 문제). 배포 자체는 완료되어 사이트는 최신.
