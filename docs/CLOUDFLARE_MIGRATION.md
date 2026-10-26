# Supabase → Cloudflare 이관 — 일본어 유니버스

**Supabase 사용 없음 — 확인 2026-10-26.**

지침: `~/cloudflare-migration/GUIDE.md` · `LANG_APPS_TASK.md`, 공용 설계: 태국어앱 `docs/CLOUDFLARE_MIGRATION.md` §2.

## 1. 조사

저장소 전체(`lib/`·`android/`·`ios/`·`.github/`·`tools/`·`data/`·`pubspec.yaml`)에서 Supabase 주소·키·패키지를 찾았다.

| 항목 | 결과 |
|---|---|
| 표(REST) | 없음 — 회화·단어(8,525어)·한자·문법 데이터는 전부 앱에 번들(`assets/data/`)하고 첫 실행 때 기기 안 SQLite(drift)에 적재 |
| 저장소 버킷 | 없음 |
| RPC·트리거 | 없음 |
| 로그인(Auth) | 없음 — 학습 기록은 기기 안 SQLite·`shared_preferences` 에만 있다 |
| 패키지 | `supabase_flutter` 등 없음 |
| 그 밖의 네트워크 | GitHub 릴리스(`latest.json`·APK) — 앱 안 자체 업데이트용, Supabase 와 무관 |

- 유일한 언급은 `data/notes/rule_dialogue_principles.md`(다른 언어앱에서 복사해 둔 옛 작업 규칙 메모)의 `supabase/seed_*.sql` 업로드 절차다. 이 저장소에는 그 폴더·파일이 없고 앱이 읽지도 않는다.
- Supabase 402 제한의 영향을 받지 않았다. 옮길 데이터도, Supabase 쪽에서 지울 이 앱의 표·파일도 없다.

## 2. 설계 — 옮기는 곳 (지금 만들 것 없음)

언어앱은 자기 DB 를 만들지 않는다(2026-10-26 사용자 결정).

- **계정·로그인·구독** → `talkverse-accounts` + `talkverse-auth`. 이 앱은 아직 로그인이 없으므로 넣을 때 태국어앱 설계 §2-2~2-5 를 따르고, 앱 쪽 바꿀 곳은 §2-8 을 본뜬다.
- **학습 데이터** → 공용 `talkverse-db`(`lang = 'ja'`). 기기 간 동기화를 넣을 때 §2-6 의 표를 쓰고, 새 표가 필요하면 §2-6 형식으로 이 문서에 적어 한자 세션에 알린다.
- **한자 공용 데이터**(형성자 소리 가족·외우는 방법·GIF) → `hanja-db`(한자 세션 담당, 읽기만). 아직 앱에 연동 코드가 없으므로 처음부터 그 주소로 만든다.
  - GIF: `https://gif.talkverse.uk/<파일 이름>`(파일 이름 규칙·`gif`/`gif_jp` 값은 그대로).
  - 읽기 규칙: `jp != kr` 이면 `gif_jp`(ok)만, 같으면 `gif`(ok). 자형이 다른데 일본어 GIF 가 없으면 정자 GIF 로 대신하지 않는다.
  - 앱 쪽은 기기 안 캐시 표(공용 코드 연결·글자별 외우는 방법·소리 가족·동기화 메타)에 받아 두고, 오프라인이면 번들 `assets/data/kanji/phonetic_ja.json` 으로 동작한다.
- **파일(음성·그림)** → 이 앱은 서버 파일이 없다(TTS 는 기기 엔진).

## 3. 대기

- 로그인·학습 기록 동기화: 태국어앱 세션의 `talkverse-auth`·`talkverse-db` 가 생긴 뒤, 사용자 지시가 있을 때.
- 한자 공용 데이터 연동: 한자 세션이 `hanja-db` 읽기 주소를 알린 뒤, 사용자 지시가 있을 때.
- 요금제·402 제한 해제는 이 앱과 무관(옮길 데이터 없음).
