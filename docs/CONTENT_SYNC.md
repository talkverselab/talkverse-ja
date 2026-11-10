# 콘텐츠 내려받기 — 점검 결과와 변경분 동기화 규격 (2026-11-10)

사용자 지시(2026-11-10): Cloudflare·DB 구조 점검 / 받을 급·단계를 설정하고 기억 / DB 변경 로그를 깃처럼 변경분만 기록하고 빌드 번호를 붙여, 앱 사용자의 DB 가 중복되지 않게 바뀐 부분만 받게.

앱 쪽은 이 문서대로 구현돼 있다(`lib/services/content_sync.dart`, `lib/data/db/seed_loader.dart`, `lib/screens/download_settings_screen.dart`).
서버 쪽(§3)은 **아직 배포 전** — 공용 Worker `talkverse-auth`(로그인·결제도 처리, 저장소 `talkverse-uk/workers/auth`, uk 세션 담당)에 넣어야 한다. 서버가 없으면 앱은 전처럼 매니페스트 전체를 받는다.

## 1. 지금 구조

| 자료 | 어디에 | 앱이 받는 법 |
|---|---|---|
| 단어·한자·회화 본문 | 앱 번들 `assets/data/**` → 기기 SQLite(drift) | `version.json` 의 `db` 번호가 바뀌면 다시 채움 |
| 단어 그림 | R2 `talkverse-art` + D1 `talkverse-db` `art_images`(그림)·`art_words`(언어별 낱말 → 개념) | `GET auth.talkverse.uk/art/ja/manifest` |
| 장면 컷 | R2 + D1 `art_scenes`(lang, episode, cut, sha1) | `GET …/art/ja/scene/manifest` |
| 회화 음성 | R2 + D1 `audio_lines`(lang, episode, turn, voice, sha1, 본문 넷) | `GET …/art/ja/audio/manifest` |
| 학습 기록·맞춤 회화 | D1 `user_state`·`course_*`·`custom_scripts`, 로그인은 별도 DB `talkverse-auth` | `/v1/ja/…` |

파일 주소 끝의 `?v=<sha1 앞 8자리>` 로 "같은 파일인지"를 가린다 — 앱은 `art/index.json`(키 → v)에 받은 것을 적어 두고 v 가 다른 것만 받는다. 이 부분은 원래부터 변경분만 받았다.

## 2. 점검에서 나온 문제

1. **앱을 켤 때마다 매니페스트 셋을 통째로 받는다** — 2.5MB(압축 0.43MB), 측정 응답 7초 + 4초 + 16초. GET 응답에 `max-age=300` 은 붙어 있지만 Worker 응답이라 엣지 캐시를 타지 않는다(uk 확인 2026-11-10 — HEAD 로 재면 404·no-store 로 보인다).
2. **D1 읽기량이 크다** — 단어 매니페스트 한 번에 29,286줄(낱말마다 그림을 고르는 하위 질의), 장면 2,232줄, 음성 4,384줄 → **앱 실행 한 번에 약 3만 6천 줄**. 계정은 2026-10-26 부터 Workers Paid(월 250억 줄)라 한도는 급하지 않다 — 실제 문제는 응답 시간과 전송량이다.
3. **변경 기록이 서버에 없다** — 무엇이 언제 바뀌었는지 알 길이 없어 앱이 전체 목록을 받아 비교할 수밖에 없다. `created_at` 은 있지만 `INSERT OR REPLACE` 로 덮어쓴다.
4. 앱이 매니페스트 1.7MB 를 설정 저장소(SharedPreferences)에 넣고 있었다 → 파일로 옮김(고침).
5. 장면 컷을 남·여 두 판 다 받고 있었다(태블릿 기준 약 130MB 낭비) → 학습자 성별 판만(고침).
6. DB 번호가 오르면 표 넷을 전부 지우고 다시 채웠고, 옛 에피소드 학습 기록(`user_progress`)을 그때마다 지웠다 → 바뀐 표만 다시 채우고 기록은 다시 이음(고침).
7. `art_images.level` 에 빈 값(zh 810장)·`R4+`·`food` 가 섞여 있다 — 급을 고르는 기준으로 쓰기 어렵다. 일본어 앱은 기기 단어 DB 의 JLPT 급으로 나눈다.

## 3. 서버에 넣을 것(uk 세션) — 변경 기록 + 변경분 응답

### 3-1. D1 `talkverse-db` 이전 파일(`workers/auth/migrations_db/0006_content_log.sql`)

올리는 도구(`scene_upload.py`·음성 진행기·uk 그림 등록)는 고칠 필요가 없다 — 표에 방아쇠를 걸어 자동으로 적는다.

```sql
-- 콘텐츠 변경 기록: 한 줄 = 무엇이(kind·id) 어떻게(op) 바뀌었나. seq 가 곧 콘텐츠 번호(빌드 번호처럼 늘기만 한다).
CREATE TABLE content_log (
  seq  INTEGER PRIMARY KEY AUTOINCREMENT,
  lang TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('words','scene','audio')),
  id   TEXT NOT NULL,              -- words: '<lang>/<낱말>' · scene: '<편>#<컷>' · audio: '<편>#<턴>#<판>'
  op   TEXT NOT NULL CHECK (op IN ('put','del')),
  at   TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE INDEX content_log_lang ON content_log (lang, seq);

CREATE TRIGGER art_scenes_ai AFTER INSERT ON art_scenes BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (NEW.lang, 'scene', NEW.episode || '#' || NEW.cut, 'put'); END;
CREATE TRIGGER art_scenes_au AFTER UPDATE ON art_scenes WHEN OLD.sha1 IS NOT NEW.sha1 OR OLD.key_1168 IS NOT NEW.key_1168 BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (NEW.lang, 'scene', NEW.episode || '#' || NEW.cut, 'put'); END;
CREATE TRIGGER art_scenes_ad AFTER DELETE ON art_scenes BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (OLD.lang, 'scene', OLD.episode || '#' || OLD.cut, 'del'); END;

CREATE TRIGGER audio_lines_ai AFTER INSERT ON audio_lines BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (NEW.lang, 'audio', NEW.episode || '#' || NEW.turn || '#' || NEW.voice, 'put'); END;
CREATE TRIGGER audio_lines_au AFTER UPDATE ON audio_lines BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (NEW.lang, 'audio', NEW.episode || '#' || NEW.turn || '#' || NEW.voice, 'put'); END;
CREATE TRIGGER audio_lines_ad AFTER DELETE ON audio_lines BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (OLD.lang, 'audio', OLD.episode || '#' || OLD.turn || '#' || OLD.voice, 'del'); END;

CREATE TRIGGER art_words_ai AFTER INSERT ON art_words BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (NEW.lang, 'words', NEW.lang || '/' || NEW.word, 'put'); END;
CREATE TRIGGER art_words_au AFTER UPDATE ON art_words BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (NEW.lang, 'words', NEW.lang || '/' || NEW.word, 'put'); END;
CREATE TRIGGER art_words_ad AFTER DELETE ON art_words BEGIN
  INSERT INTO content_log (lang, kind, id, op) VALUES (OLD.lang, 'words', OLD.lang || '/' || OLD.word, 'del'); END;
-- 그림이 바뀌면 그 개념을 쓰는 모든 언어의 낱말이 바뀐 것
CREATE TRIGGER art_images_ai AFTER INSERT ON art_images BEGIN
  INSERT INTO content_log (lang, kind, id, op) SELECT w.lang, 'words', w.lang || '/' || w.word, 'put' FROM art_words w WHERE w.concept = NEW.concept; END;
CREATE TRIGGER art_images_au AFTER UPDATE ON art_images BEGIN
  INSERT INTO content_log (lang, kind, id, op) SELECT w.lang, 'words', w.lang || '/' || w.word, 'put' FROM art_words w WHERE w.concept IN (OLD.concept, NEW.concept); END;
CREATE TRIGGER art_images_ad AFTER DELETE ON art_images BEGIN
  INSERT INTO content_log (lang, kind, id, op) SELECT w.lang, 'words', w.lang || '/' || w.word, 'put' FROM art_words w WHERE w.concept = OLD.concept; END;
```

주의: `INSERT OR REPLACE` 는 SQLite 에서 삭제 방아쇠를 부르지 않으므로(재귀 방아쇠 꺼짐) `put` 한 줄만 남는다. 낱말 그림이 사라져 매니페스트에서 빠지는 경우(`put` 인데 고를 그림이 없음)는 응답에서 `del` 로 바꿔 준다(§3-2).

### 3-2. Worker 경로 둘

```
GET /art/<lang>/head              → {"lang":"ja","head":1234}
GET /art/<lang>/changes?since=N   → {"lang":"ja","head":1250,"items":[{"kind":"scene","op":"put","id":"r1_life_a1#2","item":{…매니페스트 한 줄과 같은 모양…}}, {"kind":"audio","op":"del","id":"r0_x#3#f"}]}
                                    변경이 1,000줄을 넘거나 N 이 head 보다 크면 {"head":…,"reset":true} — 앱이 전체를 다시 받는다
```

- `head` = `SELECT seq FROM content_log WHERE lang = ? ORDER BY seq DESC LIMIT 1`(없으면 0) — **한 줄 읽기**.
- `changes` = `since` 뒤의 줄을 (kind, id)별 마지막 것만 남기고, `put` 은 지금 표의 그 줄을 기존 매니페스트 질의와 같은 열로 붙인다(지금 표에 없으면 `del`).
- 매니페스트 셋은 그대로 둔다(첫 설치·reset·옛 앱). 여력이 되면 `caches.default` 에 `head` 를 키로 넣어 D1 을 다시 읽지 않게 한다.

효과: 바뀐 게 없는 날은 실행 한 번에 D1 **1줄**(지금 약 36,000줄), 전송 수십 바이트(지금 2.5MB), 응답 대기 7~16초 → 한 번의 짧은 요청.

## 4. 앱 동작(구현됨)

- **내려받기 선택**(설정 및 프로필 → 내려받기 설정): 회화 단계 R0~R4 · 단어 급 N5~N1·그 밖 · 음성 여부. `ja_sync_dialogue_levels`·`ja_sync_word_levels`·`ja_sync_audio` 에 저장. 고르지 않은 자료는 기기에서 지우고 화면에서는 네트워크로 보인다.
- **변경분만**: 저장된 콘텐츠 번호(`ja_content_seq`)가 있으면 `changes?since=` 만 받아 저장본(`art/manifest_{words,scene,audio}.json`)에 덧입힌다 — 같은 변경을 두 번 받아도 결과가 같다(`ContentSync.patchManifest`, 시험 `test/content_sync_patch_test.dart`). 번호가 없거나 서버가 404·reset 이면 전체.
- **변경 기록**: `art/sync_log.json` — `{at, build(앱 빌드), seq(콘텐츠 번호), ver, reason(first·server·manifest·choice), add·chg·del {word·scene·audio: 수}}`. 설정 화면 아래에 보인다.
- **단어·회화 DB**: `version.json` 의 `db` 번호가 바뀌면 원본 자료의 sha1 이 바뀐 표만 다시 채운다(`ja_seed_sha_<표>`). 기록은 `ja_db_log` — `{v, from, at, build, changed {표: 줄 수}, same [그대로인 표]}`. 번호별 설명은 `version.json` 의 `log`.

## 5. 남은 일

- §3 서버 배포(uk 세션·사용자 승인) → 배포 뒤 앱에서 콘텐츠 번호가 「—」에서 숫자로 바뀌는지 확인.
- 다른 언어 앱은 공통 프롬프터로 같은 구조를 따라간다(uk 관리).
- 단어·회화 본문 자체를 급별로 서버에서 받게 하려면(지금은 3.5MB 가 번들에 통째로) 본문을 D1/R2 로 옮기는 별도 작업이 필요 — 사용자 결정.
