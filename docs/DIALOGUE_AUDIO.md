# 회화 음성(mp4) — DB·앱 구조

2026-11-06 일본어앱에서 정한 구조. 다른 언어앱도 같은 구조로 간다(언어 코드만 바꾼다).
원칙은 **가장 단순하게**: 모든 턴에 남성판·여성판 두 줄, 줄마다 본문과 파일 하나. 공용판이나 "비어 있으면 기본값" 같은 예외는 없다. 줄 수가 늘어나는 것은 괜찮다.

## 1. 저장

| 무엇 | 어디 |
|---|---|
| 음성 파일 | R2 `talkverse-art` 의 `audio/<lang>/<편id>/<턴 두 자리>_<m\|f>.mp4` (AAC 모노 44.1kHz 80k, `audio/mp4`) |
| 목록 | D1 `talkverse-db` 의 `audio_lines` |
| 내려주기 | `https://auth.talkverse.uk/art/audio/<lang>/<편id>/<파일>.mp4` (Range 지원, 캐시 1년) |
| 매니페스트 | `GET https://auth.talkverse.uk/art/<lang>/audio/manifest[?episode=<편id>]` (캐시 5분) |

`audio_lines` 열: `lang, episode, turn, voice, speaker, emotion, key, ms, sha1, text, reading, rd, ko, created_at` — 기본 키 `(lang, episode, turn, voice)`.

- `voice` = `m`(남성 학습자판) 또는 `f`(여성 학습자판). 모든 턴에 두 줄이 다 있다. 학습자가 아닌 인물의 턴은 두 판의 소리가 같아도 파일·줄을 따로 둔다.
- `text` = 그 음성이 읽는 본문(이름 자리에 이름이 들어간 글), `reading` = 그 언어의 읽기 표기(일본어 가나·중국어 병음 등, 없으면 빈 값), `rd` = 한글 독음, `ko` = 한국어 뜻. 네 칸은 항상 채운다.
- `speaker` = 목소리 이름, `emotion` = 조각별 감정을 `+` 로 이은 것, `ms` = 길이.
- 소리 낼 글이 없는 턴(지문·스탬프·「……」)만 줄이 없다.
- 파일을 다시 만들면 같은 주소에 덮어쓴다. 캐시가 1년이므로 주소에는 항상 `?v=<sha1 앞 8자리>` 를 붙인다(매니페스트의 `key` 에 이미 붙어 나온다).

매니페스트 응답: `{lang, count, base, items:[{episode, turn, voice, key, ms, text, reading, rd, ko}]}` — 파일 주소 = `base + key`.

## 2. 이름과 성별판

이름 자리(`{name}`)가 있으면 음성을 만들 수 없으므로 이름을 고정한 두 대본을 만든다.
일본어는 남성판 「アレックス」, 여성판 「エマ」(학습자를 특정 나라 사람으로 고정하지 않는 규칙에 맞춘 이름), `{country}`=カナダ, `{city}`=トロント, `{lang}`=英語.
성별로 말이 달라지는 줄(1인칭, 호칭 くん/さん, 彼女/彼氏 등)만 그 판의 본문을 따로 쓴다. 값은 `data/tts/voices.json` 의 `fill` 과 편별 계획 `data/tts/plan/<편id>.json`.

## 3. 앱

| 파일 | 하는 일 |
|---|---|
| `lib/services/content_sync.dart` | 시작할 때 그림 매니페스트와 함께 음성 매니페스트를 받는다. 학습자 성별 판의 파일을 그림과 같은 목록·버전에 넣어 같은 폴더(`art/<키>`)에 내려받는다. 바뀐 파일만 받는다. 매니페스트가 없거나 실패해도 그림 동기화는 그대로 간다. `audioIndex` = 편 → 턴 → 판 |
| `lib/services/dialogue_audio.dart` | `DialogueAudio.play(편, 턴, rate)` — 기기에 받은 파일이 있으면 파일, 없으면 주소로 재생(`audioplayers`). `speakTurn(d, t)` = 음성 우선, 없으면 기기 음성(TTS) |
| `lib/services/dialogue_service.dart` | `Dialogue.view(turn)` — 음성이 있는 턴은 그 음성의 본문(학습자 성별판)을 보여 준다. 듣는 말과 글이 같아야 하기 때문 |
| 재생 화면 | `episode_play_pane.dart`·`dialogue_screen.dart`·`dialogue_card_screen.dart` 가 `speakTurn`·`view` 를 쓴다. 이름 자리 턴에 음성이 있으면 이름을 묻지 않는다 |

앱 빌드는 한 번만 하면 된다. 그 뒤에는 DB 에 줄이 올라오는 대로 앱이 다음 시작 때 내려받아 쓴다.

## 4. 만드는 순서(도구는 `tools/tts/`)

1. 감정 계획: 편마다 `data/tts/plan/<편id>.json` — 작성법 `data/tts/PLAN_GUIDE.md`, 검사 `check_plan.py`.
2. 참고 음성: `make_jobs.py <폴더> --refs` → 인물 기본 목소리 + (목소리, 감정)별 참고 음성.
3. 문장 조각 생성: `make_jobs.py <폴더> <편id>...` → 생성 서버가 참고 음성을 따라 조각을 읽는다.
4. 검사: `qa.py` — 받아쓰기와 길이로 나쁜 조각을 찾아 다시 만든다(세 번까지, 가장 나은 판을 쓴다).
5. 올리기: `pack.py <wav폴더> <편id>... --upload` — 턴별 mp4 → R2, 그 편의 `audio_lines` 줄을 지우고 다시 넣는다.
6. 전편은 `run_all.py <작업폴더>` 가 묶음마다 3~5 를 되풀이한다. 끝난 편은 `done.txt` 에 적혀 다시 돌리면 건너뛴다.
