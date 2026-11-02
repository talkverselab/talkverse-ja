# 심사 메모(App Review Notes) 초안 · 개인정보처리방침 추가 문안 — 2026-11-02

> 일본어 유니버스 = 회화·단어·한자·복습 전부 무료 + 맞춤 회화(첫 1편 무료, 2편째부터 평생 이용권) + Talkverse ID 로그인(선택) + 인앱 구입. 한자앱 `docs/store/review_notes.md` 를 앱 이름·잠금 범위만 바꿔 복사(2026-11-02).

## App Store Connect "심사 정보 → 메모" (한국어로 적어도 되지만 영어 병기 권장)

```
[로그인] 로그인은 선택입니다. 모든 학습 기능은 로그인 없이 사용할 수 있고, 로그인은 구매 복원과 기기 간 이용권 공유에만 쓰입니다.
- 로그인 화면: 나(Me) 탭 → 계정 → 로그인. Apple로 로그인 + 이메일 로그인(심사·테스트용).
- 데모 계정(이메일 로그인): review@talkverse.uk / 비밀번호: <Doppler keys/prd TALKVERSE_REVIEW_ACCOUNT 에서 복사해 여기 입력> — 이 계정에는 평생 이용권(lang ja)이 들어 있어 맞춤 회화를 2편째부터도 만들 수 있습니다.
- 계정 삭제: 나 탭 → 계정 → 계정 삭제(확인 창) → 서버에서 개인정보가 삭제되고 모든 기기에서 로그아웃됩니다.
[인앱 구입] 비소모성 "평생 이용권"(com.talkverse.japaneseUniverse.lifetime) 1개. 배우기 탭 → 맞춤 회화 만들기에서 2편째를 만들려 하면 안내 시트가 뜨고 [평생 이용권 구매 ₩…] 버튼으로 구매, [이전 구매 복원] 으로 복원합니다. 나 탭 → 계정 → 평생 이용권에서도 열립니다. Sandbox 계정으로 시험할 수 있습니다. 로그인 없이도 구매·복원이 됩니다.
[네트워크] 단어 그림·한자 정보·맞춤 회화는 인터넷에서 받아 기기에 저장합니다. 오프라인이면 그림 없이 동작하고 맞춤 회화는 기다렸다가 받습니다.

[Sign-in] Optional. Every learning feature works without an account; sign-in is only for restoring purchases across devices.
- Where: Me tab → Account → Sign in (Sign in with Apple, or email sign-in for review/testing).
- Demo account (email sign-in): review@talkverse.uk / password: <paste from Doppler> — it already owns the Lifetime Pass (lang ja), so custom dialogues beyond the first can be created.
- Account deletion: Me tab → Account → Delete account (confirmation) → personal data is deleted server-side and all sessions are revoked.
[IAP] One non-consumable "Lifetime Pass" (com.talkverse.japaneseUniverse.lifetime). Learn tab → Custom dialogue → creating a second one opens the sheet → [Buy Lifetime Pass ₩…] to buy, [Restore purchases] to restore. Also under Me tab → Account → Lifetime Pass. Works with a Sandbox account; sign-in is not required to buy or restore.
[Network] Word pictures, kanji info and custom dialogues are downloaded and cached; offline the app keeps working without pictures.
```

## App Store "앱 개인정보 보호" 답(변경: 로그인·결제 들어감)
- 데이터 수집: **예**.
- 수집 항목(사용자와 연결됨, 추적 아님):
  - 연락처 정보 → 이메일 주소(계정 로그인·계정 관리) — 로그인한 사용자만
  - 연락처 정보 → 이름(Apple 로그인 때 받는 이름; 선택) — 로그인한 사용자만
  - 식별자 → 사용자 ID(Talkverse 계정 ID) — 로그인한 사용자만
  - 구매 → 구매 내역(이용권 복원) — 구매한 사용자만
- 수집하지 않음: 위치·건강·금융(카드 정보는 Apple/Google 이 처리)·사용 데이터·진단·검색 기록. 추적(ATT) 없음.
- 학습 기록·설정은 기기 안에만(1.0). 1.1 에서 계정 동기화를 넣으면 "사용자 콘텐츠 → 기타(학습 진도)" 추가.

## Google Play 데이터 보안 답(변경)
- 수집: 예 — 이메일 주소·이름(계정 관리, 선택), 사용자 ID, 구매 내역. 전송 암호화 예. **사용자가 삭제 요청 가능: 예** — 앱 안 "계정 삭제" + 웹 계정 삭제 안내 URL(talkverse.uk 세션에 요청: https://talkverse.uk/account/delete 같은 안내 페이지).
- 공유: 없음(결제 처리는 Google Play). 광고 없음.

## 개인정보처리방침 페이지에 추가할 문안(https://talkverse.uk/talkverse/privacy/ (언어앱 방침 — uk 세션에 §계정·결제 추가 요청) — talkverse.uk 세션 반영)
```
3. 계정(선택)
일본어 유니버스는 로그인 없이 쓸 수 있습니다. Talkverse 계정으로 로그인하면 다음을 처리합니다.
- 수집 항목: 이메일 주소, 이름(Apple·Google 등 로그인 제공자가 전달하는 범위), 계정 ID, 로그인 시각·기기 식별 토큰.
- 목적: 로그인 유지, 구매(평생 이용권) 복원과 기기 간 공유, 고객 문의 응대.
- 보관: 계정 삭제 시 즉시 삭제(구매·주문 기록은 관계 법령에 따라 회계 목적으로 사용자 ID 만 남깁니다).
- 삭제 방법: 앱 → 나 → 계정 → 계정 삭제. 또는 talkverse.lab@gmail.com 으로 요청.
- 처리 위탁·국외 이전: 계정 서버는 Cloudflare(미국 등 글로벌 리전)에서 운영됩니다.

4. 결제
평생 이용권 결제는 Apple App Store 또는 Google Play 가 처리하며, 앱은 카드 정보를 받지 않습니다. 앱은 구매 영수증(거래 번호·상품 ID)만 확인해 이용권을 적용합니다.
```

## IAP 상품 심사 스크린샷
- `docs/store/screenshots/iap_paywall.png`(잠금 안내 창) — 상품 등록 화면 "심사 정보 → 스크린샷"에 업로드.
