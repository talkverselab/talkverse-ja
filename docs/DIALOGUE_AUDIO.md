# 회화 음성(mp4) — DB·앱 구조·만드는 절차

2026-11-06 일본어앱에서 정한 구조, 2026-11-07 215편 완료 뒤 실제 절차·소요 시간·주의점을 더해 전체 다시 씀. 다른 언어앱도 같은 구조로 간다(언어 코드만 바꾼다). 진행 순서는 uk 세션이 관리한다: 한국어 → 중국어 → 태국어 → 베트남어(남부·북부) → 인도네시아어.
원칙은 **가장 단순하게**: 모든 턴에 남성판·여성판 두 줄, 줄마다 본문과 파일 하나. 공용판이나 "비어 있으면 기본값" 같은 예외는 없다. 줄 수가 늘어나는 것은 괜찮다.

## 1. 저장

| 무엇 | 어디 |
|---|---|
| 음성 파일 | R2 `talkverse-art` 의 `audio/<lang>/<편id>/<턴 두 자리>_<m\|f>.mp4` (AAC 모노 44.1kHz 80k, `audio/mp4`, loudnorm I=-18) |
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

일본어 결과(2026-11-07): 215편 · 4,384줄 · 약 207분.

## 2. 이름과 성별판

이름 자리(`{name}`)가 있으면 음성을 만들 수 없으므로 이름을 고정한 두 대본을 만든다.
일본어는 남성판 「アレックス」, 여성판 「エマ」(학습자를 특정 나라 사람으로 고정하지 않는 규칙에 맞춘 이름), `{country}`=カナダ, `{city}`=トロント, `{lang}`=英語.
성별로 말이 달라지는 줄(1인칭, 호칭 くん/さん, 彼女/彼氏 등)만 그 판의 본문을 따로 쓴다. 값은 `data/tts/voices.json` 의 `fill` 과 편별 계획 `data/tts/plan/<편id>.json`. 한국어 뜻은 이름을 넣은 뒤 조사(이/가·은/는·을/를 …)를 다시 맞춘다(`ttslib._josa`).

## 3. 앱

| 파일 | 하는 일 |
|---|---|
| `lib/services/content_sync.dart` | 시작할 때 그림 매니페스트와 함께 음성 매니페스트를 받는다. 학습자 성별 판의 파일을 그림과 같은 목록·버전에 넣어 같은 폴더(`art/<키>`)에 내려받는다. 바뀐 파일만 받는다. 매니페스트가 없거나 실패해도 그림 동기화는 그대로 간다. `audioIndex` = 편 → 턴 → 판 |
| `lib/services/dialogue_audio.dart` | `DialogueAudio.play(편, 턴, rate)` — 기기에 받은 파일이 있으면 파일, 없으면 주소로 재생(`audioplayers`). `speakTurn(d, t)` = 음성 우선, 없으면 기기 음성(TTS) |
| `lib/services/dialogue_service.dart` | `Dialogue.view(turn)` — 음성이 있는 턴은 그 음성의 본문(학습자 성별판)을 보여 준다. 듣는 말과 글이 같아야 하기 때문 |
| 재생 화면 | `episode_play_pane.dart`·`dialogue_screen.dart`·`dialogue_card_screen.dart` 가 `speakTurn`·`view` 를 쓴다. 이름 자리 턴에 음성이 있으면 이름을 묻지 않는다 |

앱 빌드는 한 번만 하면 된다. 그 뒤에는 DB 에 줄이 올라오는 대로 앱이 다음 시작 때 내려받아 쓴다.

## 4. 만드는 순서(도구는 `tools/tts/`)

생성 서버 = PC(ssh `Administrator@100.127.143.37`) WSL `/root/tts`(venv `moss`·`vox`, HF 캐시 `/root/tts/hf`). 참고 음성은 VoxCPM2(`D:\tts_test\vox_batch.py`, 2060), 문장은 MOSS-TTS 8B bf16(`moss_batch.py`, 3090, `MOSS_BF16=1`). 두 스크립트는 작업 스케줄러 'TTS job 2060'(`run_job.sh`) 하나로 돈다 — 작업 파일 `D:\tts_test\job\vox_jobs.json`·`moss_jobs.json`, 결과 `job\out\`, 로그 `job\job.log`(JOB_START/JOB_END). GPU 대기열 규칙(D:\gpu_queue)은 2026-11-07 사용자 지시로 폐지 — 확인 없이 바로 쓴다.

**PC 출력 폴더는 언어별로 나눈다** — 참고 음성 `out/ref_<lang>/<목소리>_<감정>.wav`, 조각 `out/<lang>/<편id>/…`, 재생성 `out/retake_<lang>/…`. 목소리 이름(am·af·man_y…)과 편 id(r0_culture_a1…)가 언어마다 같아서, 한 폴더를 쓰면 생성기가 다른 언어 파일을 "이미 있음"으로 건너뛰어 그 목소리를 그대로 쓴다(한국어 첫 시험에서 27조각 중 18개가 일본어 소리로 나옴, 2026-11-07). 일본어는 처음 만든 것이라 `out/ref/`·`out/<편id>/`가 일본어 몫이다 — 다른 언어는 `make_jobs.py`·`qa.py`·`pack.py`·`run_all.py`의 `out/ref/`·`out/` 접두를 `ref_<lang>/`·`<lang>/`로 바꿔 쓴다(한국어는 `out/ref_ko/`로 분리함).

1. 감정 계획: 편마다 `data/tts/plan/<편id>.json` — **2026-11-07 부터는 회화 편 JSON 의 감정 열(`turn.emotion`/`segs`, 편 `cast`·`fill`)에서 `tools/tts/plan_from_ep.py` 가 자동 생성**하고, `make_jobs.py`·`run_all.py` 도 계획이 없으면 스스로 만든다(`ttslib.plan`). 손으로 쓰는 것은 2026-11-07 이전 215편뿐. 작성법 `data/tts/PLAN_GUIDE.md`, 검사 `check_plan.py`(문제 0 이어야 한다). 다른 언어도 회화 파일에 같은 열을 두고 같은 변환기를 둔다(사용자 지시, 모든 언어 세션).
2. 참고 음성: `make_jobs.py <폴더> --refs` → 인물 기본 목소리 + (목소리, 감정)별 참고 음성 `out/ref/<목소리>_<감정>.wav`. **일본어 22목소리×16감정 약 45분(2060).**
3. 문장 조각 생성: `make_jobs.py <폴더> <편id>...` → MOSS 가 참고 음성을 따라 조각을 읽는다. 조각 = 턴 안의 감정 단위(`<턴>_<조각>_<m|f|c>.wav`, c = 두 판이 같은 조각).
4. 검사: `qa.py <wav폴더> <편id>... [--jobs <재생성 작업 파일>]` — mlx-whisper 받아쓰기(히라가나 비교 유사도 ≥0.72) + 길이 범위 + **최대 음량(-30dB 미만 = 생성 실패)**. 나쁜 조각은 seed 를 바꿔 다시 만들고(세 번까지) 가장 나은 판을 본 파일로 고른다. 결과는 `<wav폴더>/qa.json`.
5. 올리기: `pack.py <wav폴더> <편id>... --upload` — 조각 앞뒤 무음 트림(결과가 1,000바이트 미만이면 트림 전 원본) → 0.22초 간격으로 이어 붙임 → loudnorm → 턴별 mp4 → R2(8병렬) → 그 편의 `audio_lines` 줄을 지우고 다시 넣음 → `data/tts/audio_ja.json` 갱신.
6. 전편: `run_all.py <작업폴더>` 가 묶음(N편)마다 3~5 를 되풀이한다. 끝난 편은 `done.txt` 에 적혀 다시 돌리면 건너뛴다. **중간에 멈췄으면 그냥 다시 실행** — 있는 wav·done.txt 는 건너뛴다.

### 실제 소요(일본어 215편 · 3,627조각, 2026-11-06 23:25 → 11-07 08:19)

- 참고 음성 45분(2060) → 조각 생성+검사+업로드 약 9시간(3090 bf16, 조각당 평균 4~5초 + 재생성 3회 + whisper 검사).
- 재생성이 필요했던 조각 약 10%(길이 이탈·받아쓰기 불일치). 그 뒤 **거의 무음으로 나온 83조각**을 따로 찾아 재생성(약 1시간) — 처음부터 4 의 음량 검사를 켜 두면 이 단계가 없다. 3회 뒤에도 기준 미달 81조각은 가장 나은 판으로 두었다(`qa.json` ok=false).

### 주의점(일본어에서 겪은 것)

- **짧은 조각이 폭주**(117초 횡설수설): `moss_batch.py` 가 글 길이로 max_new_tokens 을 제한하고 seed 를 바꿔 재시도한다(로그 `RUNON`). 다른 언어도 같은 보호가 필요하다.
- **거의 무음 조각**: 특정 목소리(`am`)에 몰렸다. 트림이 빈 파일을 만들어 loudnorm 이 234 로 죽는다 → pack 의 폴백과 qa 의 음량 검사로 막았다.
- **whisper 가 한 파일에서 무한 대기**(mlx eval 에서 7시간 멈춤, 2026-11-07): qa 를 편별 하위 프로세스로 돌리고 **시간 제한(600초)** 을 두어 넘기면 그 편의 재생성본을 버리고 넘어간다(`~/tts_work/ja/finish.py` 참고). run_all 에 같은 제한을 넣는 것이 좋다.
- 소리 낼 글이 없는 턴(SIL 정규식)은 조각이 없다 — 줄도 없다. 리뷰 페이지는 그 턴에 버튼을 안 그린다.
- 같은 주소에 덮어쓰므로 **`?v=sha1` 없이 주소를 쓰면 1년 캐시에 걸린다.**
- D1 열 이름은 `text`·`reading`(처음 `ja`·`kana` 로 만들었다가 언어 공통으로 바꿨다). 워커(`talkverse-uk/workers/auth`)가 mp4 Range 와 매니페스트를 낸다 — 새 언어는 워커 수정 없이 `lang` 만 다르면 된다.
- 검사 환경: 맥 scratch venv(`mlx-whisper` `mlx-community/whisper-large-v3-turbo` + `pykakasi`). 다른 언어는 받아쓰기 비교 함수(`qa.norm`)만 그 언어 표기 정규화로 바꾼다.
- 리뷰 페이지(`tools/review_html.py`)는 `data/tts/audio_ja.json` 을 읽어 편마다 남자/여자 재생 버튼과 전체 듣기를 그린다. 전편 끝나면 다시 만들어 uk 에 "REVIEW_<lang> 갱신" 요청.
