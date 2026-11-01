# 로그인 준비 — Google · Naver · Apple · Kakao (사용자 지시 2026-11-01)

**담당: talkverse.uk 세션**(사용자 지시 2026-11-02 "로그인 관련은 talkverse.uk 세션이 맡게 해"). 현행 문서 = talkverse-uk repo `docs/talkverse-id/README.md`. 계정 D1 이름은 **`talkverse-auth`**(사용자 지시 — 옛 woojoo DB 는 `woojoo-auth` 로 이동). `clients` 에 `ja`(`talkverse.ja://auth`) 포함. Worker(`auth.talkverse.uk`) 배포 뒤 주소·API 확정본을 받으면 §4 대로 앱 쪽을 붙인다.

사용자 지시: "gmail 네이버 애플 카카오 로그인 준비하자 → talkverse.uk DB 로 작성해야 해."
= 언어앱이 자기 계정 DB 를 만들지 않고 **공용 계정(talkverse.uk 와 같은 ID)** 을 쓴다.
설계 원본: 태국어앱 `~/talkverse/th/docs/CLOUDFLARE_MIGRATION.md` §2(2026-10-26, 사용자 결정 "ID 는 하나") — 이 문서는 그 설계에 **Naver·Apple 을 더하고 일본어앱 쪽 할 일**을 적는다.

## 0. 현황 (2026-11-01 확인)

| 것 | 상태 |
|---|---|
| D1 계정 DB | 2026-11-02 talkverse.uk 세션이 `talkverse-auth` 로 새로 생성(옛 같은 이름 woojoo DB 는 `woojoo-auth` 로 이동) |
| Worker `talkverse-auth` (`auth.talkverse.uk`) | **없음** |
| 태국어앱 | 설계만. `lib/services/auth_service.dart` 는 아직 Supabase |
| 일본어앱 | 로그인 없음. 딥링크·`http`·`flutter_secure_storage` 없음 |

## 1. 구조 (설계 §2 그대로)

- **계정 DB** = D1 `talkverse-accounts`(users · identities · sessions · auth_flows · clients · products · plans · orders · subscriptions). `identities.provider` 에 `google kakao naver apple email` 이미 포함.
- **인증 Worker** = `talkverse-auth`, 커스텀 도메인 `auth.talkverse.uk`. OAuth 는 Worker 가 서버에서 처리(Authorization Code + PKCE), 앱은 브라우저만 연다. 제공자 콘솔의 콜백 주소는 **한 곳**: `https://auth.talkverse.uk/callback/<provider>`.
- **앱** = `GET /oauth/<provider>/start?client_id=ja&redirect_uri=talkverse.ja://auth&code_challenge=…` → 로그인 뒤 `talkverse.ja://auth?code=…` → `POST /token` → access(1h, ES256 JWT) + refresh(60일, rotation). 저장은 `flutter_secure_storage`.
- **다른 Worker/앱 API** 는 JWKS 로 서명만 확인. 학습 기록 동기화는 공용 `talkverse-db`(`lang='ja'`), 다음 단계.

## 2. 제공자별 — 사용자가 콘솔에서 할 일 + 특이점

| 제공자 | 콘솔 | 만들 것 | 콜백/설정 | 특이점 |
|---|---|---|---|---|
| **Google** | Google Cloud Console → API 및 서비스 → 사용자 인증 정보 | OAuth 클라이언트 ID **웹 애플리케이션** 1개(앱용 Android/iOS 클라이언트는 불필요 — Worker 가 처리) | 승인된 리디렉션 URI `https://auth.talkverse.uk/callback/google`; OAuth 동의 화면(앱 이름 Talkverse, 범위 `openid email profile`) 게시 | `email_verified` 를 주므로 같은 이메일 계정 합치기 가능 |
| **Kakao** | developers.kakao.com → 내 애플리케이션 | 앱 1개(Talkverse) | 카카오 로그인 활성화, Redirect URI `https://auth.talkverse.uk/callback/kakao`, 동의 항목: 닉네임(필수)·카카오계정 이메일(선택 — 비즈 앱 전환 전엔 선택만 가능) | `client_secret` 은 보안 탭에서 생성해 "사용함"으로. 이메일은 사용자가 거부할 수 있으니 `email` null 허용(설계 그대로) |
| **Naver** | developers.naver.com → 애플리케이션 등록 | 앱 1개(Talkverse), 사용 API: 네이버 로그인 | 서비스 URL `https://talkverse.uk`, Callback URL `https://auth.talkverse.uk/callback/naver`; 제공 정보: 이메일·별명(필수) | PKCE 미지원 → Worker 가 `state` 로만 CSRF 방어(앱↔Worker 사이는 PKCE 유지). `response.id` 가 provider_uid. 이메일은 "확인됨" 플래그가 없어 **합치기 2단계에서 제외**(새 계정 또는 provider_uid 로만 찾기) |
| **Apple** | developer.apple.com → Certificates, Identifiers & Profiles | ① App ID `com.talkverse.japaneseUniverse` 에 **Sign in with Apple** capability ② **Services ID**(예 `uk.talkverse.auth`, 웹/Android 용) — Return URL `https://auth.talkverse.uk/callback/apple`, 도메인 `auth.talkverse.uk` ③ **Key**(Sign in with Apple) → `.p8` + Key ID | iOS 는 심사 지침 4.8 때문에 **네이티브 Sign in with Apple 필수**(`sign_in_with_apple` 패키지) → 앱이 받은 `identityToken`(JWT) 을 `POST /token {grant_type:"apple_native"}` 로 Worker 에 보내 검증(Apple JWKS, `aud`=번들 ID). Android·웹은 Services ID 로 웹 플로우(`response_mode=form_post` → 콜백은 POST). 이메일은 **첫 로그인 때만** 오고 "hide my email" 중계 주소일 수 있음 → 첫 응답에서 저장. client_secret 은 `.p8` 로 Worker 가 ES256 JWT 를 매번 만든다(6개월 유효) |

**Apple 번들 ID 주의**: 언어앱 20개가 각각 Sign in with Apple capability 를 켜야 하고, Services ID 하나를 공유하려면 각 App ID 를 그 Services ID 의 "primary" 그룹으로 묶는다(Apple 은 한 primary App ID 아래 여러 Services ID/App ID 그룹을 허용). 심사 전 확인.

## 3. 비밀값 (값은 어디에도 적지 않음 — Doppler `keys/prd` 에 넣고 `wrangler secret put` 은 사용자가)

| wrangler secret 이름 | Doppler 이름(제안) | 출처 |
|---|---|---|
| `GOOGLE_CLIENT_ID` · `GOOGLE_CLIENT_SECRET` | `TV_AUTH_GOOGLE_ID` · `TV_AUTH_GOOGLE_SECRET` | Google Cloud |
| `KAKAO_CLIENT_ID`(REST API 키) · `KAKAO_CLIENT_SECRET` | `TV_AUTH_KAKAO_ID` · `TV_AUTH_KAKAO_SECRET` | Kakao |
| `NAVER_CLIENT_ID` · `NAVER_CLIENT_SECRET` | `TV_AUTH_NAVER_ID` · `TV_AUTH_NAVER_SECRET` | Naver |
| `APPLE_TEAM_ID`(QP8QRMA9CC) · `APPLE_SERVICES_ID` · `APPLE_KEY_ID` · `APPLE_PRIVATE_KEY`(.p8 내용) | `TV_AUTH_APPLE_SERVICES_ID` · `TV_AUTH_APPLE_KEY_ID` · `TV_AUTH_APPLE_P8_B64` | Apple |
| `JWT_PRIVATE_KEY`(P-256 PKCS8) | `TV_AUTH_JWT_PRIVATE_B64` | Worker 세션이 생성(`openssl ecparam -genkey -name prime256v1`) |
| `ADMIN_KEY` | `TV_AUTH_ADMIN_KEY` | 무작위 |

## 4. 일본어앱 쪽 할 일 (Worker 가 뜨면)

1. `pubspec.yaml`: `http` · `flutter_secure_storage` · `app_links`(딥링크 수신) · `url_launcher`(브라우저 열기) · `sign_in_with_apple`(iOS 네이티브) · `crypto`(PKCE S256).
2. 딥링크 `talkverse.ja://auth` — `AndroidManifest.xml` intent-filter(scheme `talkverse.ja`, host `auth`) + `Info.plist` `CFBundleURLSchemes`. `clients` 표에 `ja` 행(`["talkverse.ja://auth"]`).
3. `lib/services/auth_service.dart`(새): `signIn(provider)` · `refreshAccess()` · `signOut()` · `user` ValueNotifier · `deleteAccount()`. 401 이면 refresh 한 번, 실패하면 로그아웃 상태. 태국어앱이 먼저 만들면 공개 메서드 이름을 맞춰 복사.
4. 프로필 화면: 로그인 전 = 버튼 4개(Google · Apple(iOS 는 네이티브) · Kakao · Naver), 로그인 후 = 이름·이메일·로그인 수단·기기 목록·로그아웃·탈퇴(스토어 심사 요구). UI 문구는 `tr()` 4개 언어 사전에.
5. 학습 기록 동기화(공용 `talkverse-db`)는 로그인이 된 뒤 별도 단계.

## 5. 순서 · 담당

1. **사용자**: §2 콘솔 4곳 등록 → §3 비밀값을 Doppler 에 → `auth.talkverse.uk` 커스텀 도메인(Worker 배포 때 wrangler 가 붙임, DNS 는 Cloudflare 가 관리하므로 자동).
2. **Worker 세션**(제안: 이 세션이 `~/talkverse-uk/workers/auth/` 로 작성, 또는 태국어앱 세션 — 사용자 결정): D1 `talkverse-accounts` 생성 + 설계 §2-2 스키마(`identities.provider` 에 naver·apple 이미 있음) + `clients` 초기값 21개 → `talkverse-auth` Worker(§2-5 API + naver·apple 경로 + `apple_native` grant) → `wrangler deploy`(사용자가 secret 넣은 뒤).
3. 일본어앱 §4 → 빌드 → Zealot(안드로이드)·TestFlight(iOS) 확인.
4. 태국어·다른 언어앱·talkverse.uk(`/auth/done` 페이지, 서비스 바인딩 `AUTH`)가 같은 Worker 에 붙는다.
