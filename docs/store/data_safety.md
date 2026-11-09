# 데이터 안전 / 앱 개인정보 보호 답안 — 일본어 유니버스 (2026-11-09 전체 다시 씀)

원본은 talkverse-uk `docs/legal/` — 바꾸면 uk 에 알린다. 방침: https://talkverse.uk/talkverse/ja/privacy/ (2026-11-09 uk 가 동기화 없음·회화 음성 파일·삭제 경로·구독을 반영).

## 앱 사실(2026-11-09 빌드 기준)

- **로그인은 선택**(Apple·Google·카카오·네이버, 심사용 이메일; 서버 auth.talkverse.uk = Cloudflare). 로그인하면 이메일·이름(제공자가 주는 범위)·계정 ID·세션 토큰을 서버에 저장. **학습 기록 동기화는 없다** — 학습 기록·설정은 기기 안(shared_preferences·로컬 DB)에만.
- **인앱 구입 6개**: 자동 갱신 구독 `lang_ja_1m`·`_3m`·`_1y`·`all_1y`, 비소모성 `lang_ja_life`·`all_life`. 결제는 App Store/Google Play, 앱·서버는 영수증(거래 번호·상품 ID)만 확인.
- **맞춤 회화(AI 생성)**: 요청 내용(주제·상황·레벨·선택한 이름)과 기기 식별자(앱이 만든 무작위 값)를 talkverse.uk(Cloudflare D1)에 저장, 로그인했으면 이용권 확인용 토큰을 함께 보냄. 화면에 「AI 가 만든 회화」 표시와 신고(메일) 버튼.
- **내려받는 것**: 장면·단어 그림, 회화 음성 파일(mp4, 서버에서 미리 만든 것), 한자 정보 — 기기에 저장. 사용자 음성은 보내지 않는다(마이크 권한 없음).
- 광고·분석·크래시·추적 SDK 없음. 권한 = 인터넷만(2026-11-09 Android 설치 권한·iOS 마이크/음성 인식 설명문 삭제).

## App Store — 앱 개인정보 보호

| 질문 | 답 |
|---|---|
| 데이터를 수집하나요? | **예** |
| 연락처 정보 → 이메일 주소 | 수집 · 앱 기능(계정·구매 공유) · 사용자와 연결 · 추적 아님 |
| 연락처 정보 → 이름 | 수집(로그인 제공자가 넘기는 경우만) · 앱 기능 · 사용자와 연결 · 추적 아님 |
| 식별자 → 사용자 ID | 수집(Talkverse 계정 ID) · 앱 기능 · 사용자와 연결 · 추적 아님 |
| 식별자 → 기기 ID | 수집(맞춤 회화 요청용 무작위 기기 식별자) · 앱 기능 · 사용자와 연결 안 됨(로그인 시 연결될 수 있음) · 추적 아님 |
| 구매 → 구매 내역 | 수집(이용권 복원·기기 간 공유) · 앱 기능 · 사용자와 연결 · 추적 아님 |
| 사용자 콘텐츠 → 기타 | 수집(맞춤 회화 요청 문구) · 앱 기능 · 추적 아님 |
| 위치·건강·금융·사용 데이터·진단·검색·브라우징·오디오 | **수집 안 함** |
| 추적(ATT) | **아니요** |

### Privacy Manifest(PrivacyInfo.xcprivacy) — **아직 없음, 출시 전 추가**
- `NSPrivacyTracking` = false, `NSPrivacyTrackingDomains` = 빈 값.
- `NSPrivacyCollectedDataTypes`: EmailAddress·Name·UserID·DeviceID·PurchaseHistory·OtherUserContent(linked 는 위 표대로, tracking=false, purpose=AppFunctionality).
- 필수 사유 API: UserDefaults `CA92.1`(shared_preferences), 파일 타임스탬프 `C617.1`(path_provider·캐시 확인에 쓰면). 플러그인 자체 매니페스트와 겹쳐도 무방.

## Google Play — 데이터 보안

| 질문 | 답 |
|---|---|
| 사용자 데이터를 수집·공유하나요? | **수집 예**, 공유 없음 |
| 수집 항목 | 개인 정보 → 이메일 주소·이름(선택, 계정 관리) · 사용자 ID(계정 관리) / 기기 또는 기타 ID(맞춤 회화 요청) / 금융 정보 → 구매 내역(이용권) / 앱 활동 → 기타 사용자 생성 콘텐츠(맞춤 회화 요청 문구) |
| 필수 여부 | 모두 선택(로그인·구매·맞춤 회화를 써야만) |
| 전송 중 암호화 | 예(HTTPS) |
| 삭제 요청 | 예 — 앱 「설정 및 프로필 → 계정 → 계정 삭제」 + https://talkverse.uk/account/delete |
| 개인정보처리방침 URL | https://talkverse.uk/talkverse/ja/privacy/ |

### 그 밖의 Play Console 「앱 콘텐츠」
| 항목 | 답 |
|---|---|
| 광고 | 아니요 |
| 앱 액세스 | 모든 학습 기능은 로그인 없이 — 심사용 데모 계정 review@talkverse.uk(맞춤 회화 여러 편 확인용) |
| 대상 연령 | 전체(만 14세 미만 개인정보 미수집 — 방침 §5), IARC 설문: 사용자 간 소통 없음, 디지털 구매 있음, AI 생성 콘텐츠 있음(신고 기능) |
| 광고 ID | 아니요 |
