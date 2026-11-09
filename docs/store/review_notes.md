# 심사 메모(App Review Notes) — 일본어 유니버스 (2026-11-09 전체 다시 씀)

일본어 유니버스 = 회화·단어·한자·복습 전부 무료 + 맞춤 회화(AI 생성, 첫 1편 무료, 그다음은 이용권 — 한 달 5편·하루 1편, 종합 이용권 한 달 10편) + Talkverse ID 로그인(선택) + 인앱 구입 6개(`docs/STORE_PRODUCTS.md`). 원본은 talkverse-uk `docs/legal/` — 바꾸면 uk 에 알린다. 4.3 차별화 근거는 `docs/store/listing.md`.

> 출시 때 잠금을 풀지(전부 무료) 여부는 uk 공지를 따른다(PRICING.md: 최초 출시 빌드 = 한자앱, 출시 때 잠금 없이 전부 무료). 잠금을 풀고 내면 아래 [인앱 구입] 문단은 IAP 등록 여부에 맞게 줄인다.

## App Store Connect "심사 정보 → 메모"

```
[Language-specific app — Guideline 4.3]
This app is one of a family of language-specific apps by Universal Talking Lab (Talkverse). Each app is built from scratch for one target language for Korean speakers and is NOT a re-skin: the Japanese app has its own script & pronunciation module (104 hiragana/katakana with IPA and articulation, Korean hanja reading → Japanese on'yomi rules, a 2,285-kanji dictionary), its own grammar tools (20 core particles mapped one-to-one to Korean particles, sentence-final ね・よ・か, furigana toggle with per-kanji lookup), 215 original conversation episodes with 4,384 recorded audio lines written for this language, and a vocabulary list measured from a Japanese conversation corpus (62 words = 55% and 778 words = 80% of dialogue; 532 kanji = 80%). Content, curriculum and UI flows differ between apps; we keep them separate because learners search for and buy one language at a time.

[Sign-in] Optional. Every learning feature works without an account; sign-in is only for sharing purchases across devices.
- Where: Settings & Profile tab → Account → Sign in (Sign in with Apple, or email sign-in for review).
- Demo account (email sign-in): review@talkverse.uk / password: <paste from Doppler keys/prd TALKVERSE_REVIEW_ACCOUNT> — it owns a pass, so more than one custom dialogue can be created.
- Account deletion: Settings & Profile → Account → Delete account (confirmation) → personal data is deleted on the server and all sessions are revoked.

[In-app purchases] Auto-renewable subscriptions lang_ja_1m / lang_ja_3m / lang_ja_1y and all_1y (all Talkverse language apps), non-consumables lang_ja_life and all_life ("for as long as the service runs"). Learn tab → Custom dialogue → creating a second one opens the purchase sheet; also Settings & Profile → Pass. The sheet shows price, period, auto-renewal and how to cancel next to the Buy button, nothing is preselected, and it has Restore purchases, Terms of Use and Privacy Policy links. Sign-in is not required to buy or restore.

[AI-generated content] Custom dialogues are written by AI on our server from the topic/situation/level the user picks. They are labelled "AI 가 만든 회화" at the top with a Report button (opens an email with the dialogue ID). Limits: 1 free, then 5 per month and 1 per day with a pass (10 per month with the all-languages pass).

[Network] Scene pictures, word pictures, recorded dialogue audio and custom dialogues are downloaded and cached; offline the app keeps working with what is cached.
```

한국어 요약(메모에 같이 적어도 됨): 언어별로 따로 만든 앱(4.3) · 로그인 선택(설정 및 프로필 → 계정) · 데모 계정 review@talkverse.uk · 계정 삭제 경로 · 인앱 구입 6개와 결제 시트 표기 · 맞춤 회화 = AI 생성, 표시·신고 버튼, 한도 · 그림·음성은 내려받아 저장.

## IAP 상품 심사 스크린샷

- 결제 시트(상품 고르기 전·고른 뒤 각 1장) — 상품 등록 화면 "심사 정보 → 스크린샷".

## 확인할 것(출시 전)

- `ios/Runner/PrivacyInfo.xcprivacy` 가 없다 — 수집 데이터 종류(이메일·이름·사용자 ID·구매 내역, 추적 없음)와 UserDefaults 사유(CA92.1)를 담은 매니페스트를 Runner 에 추가하고 Xcode 프로젝트 리소스에 넣는다(`docs/store/data_safety.md`).
- 데모 계정 비밀번호는 Doppler 에서 복사해 메모 칸에만 넣는다(이 파일에 쓰지 않는다).
