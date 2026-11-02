# 데이터 안전 / 앱 개인정보 보호 답안 — 일본어 유니버스 (한자앱 문안 복사, 2026-11-02)

근거(1.0 심사판 앱 사실): **Talkverse 계정 로그인은 선택**(Apple 로그인, 이메일(데모) 로그인; 서버 auth.talkverse.uk = Cloudflare). 로그인하면 이메일·이름(제공자가 주는 범위)·계정 ID·세션 토큰을 서버에 저장. **인앱 구입** 1개(비소모성 평생 이용권) — 결제는 App Store/Google Play 가 처리, 앱·서버는 영수증(거래 번호·상품 ID)만 확인. 학습 기록·설정은 기기 안(shared_preferences)에만 저장. 학습 자료(단어 그림·한자 정보·맞춤 회화)는 talkverse.uk·auth.talkverse.uk·hanja-api 에서 받는다(맞춤 회화 요청은 기기 ID·주제·상황·레벨만 서버에 저장). 광고·분석·크래시 SDK 없음. 권한 = INTERNET 만. 추적 없음.

> 맞춤 회화 요청(기기 ID·주제·상황·레벨)은 Cloudflare D1 에 저장된다 — 사용자 콘텐츠(기타)로 답하거나 심사 메모에 명시.

## App Store — 앱 개인정보 보호(App Privacy)

| 질문 | 답 |
|---|---|
| 이 앱에서 데이터를 수집하나요? | **예** |
| 연락처 정보 → 이메일 주소 | 수집 · 용도 **앱 기능**(계정 로그인·구매 복원) · **사용자와 연결됨** · 추적 아님 |
| 연락처 정보 → 이름 | 수집(Apple/Google 로그인이 넘기는 경우만, 선택) · 앱 기능 · 사용자와 연결됨 · 추적 아님 |
| 식별자 → 사용자 ID | 수집(Talkverse 계정 ID) · 앱 기능 · 사용자와 연결됨 · 추적 아님 |
| 구매 → 구매 내역 | 수집(이용권 복원·기기 간 공유) · 앱 기능 · 사용자와 연결됨 · 추적 아님 |
| 사용 데이터·진단·위치·건강·금융·검색·브라우징·기타 | **수집 안 함** |
| 추적(ATT) | **아니요** |
| 개인정보처리방침 URL | https://talkverse.uk/talkverse/ja/privacy/ (§8 계정(선택)·결제 — 2026-11-02 반영됨) |

- "수집"은 로그인한 사용자에게만 해당하지만 App Privacy 는 앱 기준으로 답하므로 위처럼 표시한다. 심사 메모에 "로그인은 선택"을 적는다.
- 1.1 에서 진도 동기화를 넣으면 **사용자 콘텐츠 → 기타 사용자 콘텐츠(학습 진도)** 추가.

### Privacy Manifest(PrivacyInfo.xcprivacy)
- `NSPrivacyTracking` = false. `NSPrivacyCollectedDataTypes`: EmailAddress·Name·UserID·PurchaseHistory(각 linked=true, tracking=false, purposes=AppFunctionality).
- 필수 사유 API: UserDefaults(`CA92.1`, shared_preferences) — 플러그인 매니페스트 포함 여부 확인, 없으면 Runner 에 추가. flutter_secure_storage(키체인)는 필수 사유 API 아님.

## Google Play — 데이터 보안(Data safety)

| 질문 | 답 |
|---|---|
| 앱이 사용자 데이터를 수집하거나 공유하나요? | **예(수집)**, 공유 없음 |
| 수집 항목 | 개인 정보 → **이메일 주소**(선택, 계정 관리) · **이름**(선택, 계정 관리) · **사용자 ID**(계정 관리) / 금융 정보 → **구매 내역**(앱 기능: 이용권 복원) |
| 필수 여부 | 모두 **선택**(로그인·구매를 해야만 수집) |
| 전송 중 암호화 | **예**(HTTPS) |
| 사용자가 데이터 삭제를 요청할 수 있나요? | **예** — 앱 안 "나 → 계정 → 계정 삭제" + 웹 안내 URL **https://talkverse.uk/account/delete** |
| 데이터 처리 방식(임시 처리) | 아니요 |
| 독립 보안 검토(MASA) | 아니요 |
| 개인정보처리방침 URL | https://talkverse.uk/talkverse/ja/privacy/ |

### 그 밖의 Play Console "앱 콘텐츠"
| 항목 | 답 |
|---|---|
| 광고 | 아니요 |
| 앱 액세스 권한 | **모든 기능이 로그인 없이 사용 가능**(로그인은 선택) — 그래도 심사용 데모 계정을 "안내"에 적는다(이메일 로그인 review@talkverse.uk) |
| 대상 연령층 | checklist.md "대상 연령" |
| 뉴스·코로나·정부·금융·건강 | 아니요 |
| 광고 ID | 아니요 |
| 디지털 구매(IARC) | **예** — 인앱 구입 |
