# 맞춤 회화(고유 스크립트) — 앱 · Cloudflare · 코드 서버 계약 (2026-11-02)

사용자 지시(2026-11-02): "유료 버전에는 도메인·상황·레벨(왕초보·초보·중급·고급)을 선택하면 고유 스크립트를 만들어 주는 메뉴.
고유 스크립트는 ID 와 함께 Cloudflare 에 저장. 생성은 API 를 쓰지 않고 **우리 코드 서버(맥미니 Claude Code)** 만 쓴다 — 2026-11-09 사용자 지시 "AI 재생성은 그냥 클로드로만"으로 Grok 재작성 단계 삭제(그림 Grok 한도와 겹치지 않게). 한도: 무료 평생 1편 / 이용권 한 달 5편·하루 1편 / 종합 이용권 한 달 10편(한국 시간), 넘으면 402 paid_required · 429 monthly_limit(limit·used) · 429 daily_limit. 앱은 맞춤 회화 화면 위에 「AI 가 만든 회화」 표시와 신고(메일) 버튼을 둔다.
**1회는 무료.** 많이 쓰면 그때 생각한다(과금·큐 최적화는 지금 하지 않음)."

## 1. 흐름

```
앱(폰·패드)                Cloudflare Worker(talkverse.uk, D1)            맥미니 코드 서버(일본어앱 세션 폴더)
─────────────              ───────────────────────────────                ────────────────────────────────
① 도메인·상황·레벨 입력 → POST /api/script/ja  ──→ custom_scripts 행(queued, id)
② 「내 맞춤 회화」 서랍에 id 보관, GET /api/script/ja/<id> 로 상태 확인(열 때·1분마다)
                                                   ③ GET /api/script/ja/pending (키) ←── tools/custom_script_worker.py(launchd 5분)
                                                   ④ POST …/<id>/claim → writing
                                                                                        ⑤ claude-lab -p (초안 JSON, tools/prompts/custom_script.md)
                                                                                        (⑥ Grok 재작성 — 2026-11-09 삭제)
                                                                                        ⑦ tools/check_dialogues.py 검사 → 통과 못 하면 초안으로
                                                   ⑧ POST …/<id>/result {status:'ready', dialogue} ←──
⑨ 앱이 ready 를 받으면 dialogue 를 로컬에 저장하고 기존 편과 같은 화면(재생 패널·그림 카드·라이트너)으로 연다
```

## 2. Worker API (talkverse.uk 세션 구현, D1 `custom_scripts`)

공통: JSON, CORS 열림(앱은 네이티브라 무관), 인증 없음(앱 쪽) / 코드 서버 쪽은 헤더 `X-Script-Key`(Doppler `keys/prd` `TALKVERSE_SCRIPT_KEY`, Worker 시크릿 `SCRIPT_KEY`).

| 메서드·경로 | 누가 | 본문 → 응답 |
|---|---|---|
| `POST /api/script/ja` | 앱 | `{device, domain, situation, level, name?}` → `201 {id, status:'queued', free_used:true}` / `402 {error:'paid_required', used:n}` (device 의 2번째부터, 유료 플래그 없으면) / `400 {error}` |
| `GET /api/script/ja/<id>` | 앱 | `{id, status, domain, situation, level, created_at, updated_at, dialogue?}` — status = `queued·writing·ready·failed`, `dialogue` 는 ready 일 때만 |
| `GET /api/script/ja?device=<device>` | 앱 | `{items:[{id,status,domain,situation,level,title?,created_at}]}` 최신순 50 |
| `GET /api/script/ja/pending` | 코드 서버(키) | `{items:[{id,device,domain,situation,level,created_at}]}` queued 오래된 순 10 + writing 30분 넘은 것(재시도) |
| `POST /api/script/ja/<id>/claim` | 코드 서버(키) | → `{ok:true}` (queued/writing → writing, updated_at 갱신) |
| `POST /api/script/ja/<id>/result` | 코드 서버(키) | `{status:'ready', dialogue:{…}}` 또는 `{status:'failed', error}` → `{ok:true}` |

검증: `domain ∈ survival friends love life travel culture work study`, `level ∈ R0 R1 R2 R3`, `situation` 1~120자, `device` 8~64자 `[A-Za-z0-9_-]`, `name` 0~20자.
ID: `ja-` + 8자 소문자·숫자(충돌 시 재생성). 1회 무료: `SELECT count(*) FROM custom_scripts WHERE device=? AND status<>'failed'` ≥ 1 이면 402 — 유료는 `paid_devices(device)` 표에 있으면 통과(지금은 비워 둠, 사용자 수동 등록).

```sql
CREATE TABLE IF NOT EXISTS custom_scripts (
  id         TEXT PRIMARY KEY,
  lang       TEXT NOT NULL DEFAULT 'ja',
  device     TEXT NOT NULL,
  domain     TEXT NOT NULL,
  situation  TEXT NOT NULL CHECK (length(situation) <= 120),
  level      TEXT NOT NULL CHECK (level IN ('R0','R1','R2','R3')),
  name       TEXT,
  status     TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued','writing','ready','failed')),
  dialogue   TEXT,            -- ready 일 때 편 JSON(assets/data/dialogues/README.md 구조)
  error      TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
);
CREATE INDEX IF NOT EXISTS custom_scripts_device_idx ON custom_scripts (device, created_at DESC);
CREATE INDEX IF NOT EXISTS custom_scripts_status_idx ON custom_scripts (status, created_at);
CREATE TABLE IF NOT EXISTS paid_devices (device TEXT PRIMARY KEY, note TEXT, created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')));
```

## 3. 편 JSON(결과물)

`assets/data/dialogues/README.md` 와 같은 구조. 다른 점:
- `id` = Worker 가 준 `ja-xxxxxxxx`, `region` = 고른 레벨, `island` = 고른 도메인, `kind` = `custom`.
- `custom: {situation, name, created_at}` 를 덧붙인다(앱은 무시해도 됨).
- 턴 수: R0 4~6 · R1 6~8 · R2 8~12 · R3 12~16. 등장인물은 고정 인물표(유카·사쿠라·켄·리쿠…)에서, 학습자 자리는 `{name}`(앱이 「나」 또는 입력한 이름으로 보임).
- 공개 저장소 규칙 그대로(출처·브랜드 없음, 자체 문장).

## 4. 앱(이 저장소)

- `lib/services/custom_script_service.dart` — 기기 ID(SharedPreferences `device_id`, 처음에 생성), 만들기·상태 확인·목록, ready 편은 `custom_scripts_v1` 에 JSON 으로 보관(오프라인에서도 열림), `Dialogue.fromJson` 으로 변환.
- `lib/screens/custom_script_screen.dart` — 입력 3단계(도메인 칩 8 → 상황 자유 입력 + 추천 칩 → 레벨 4) → 「만들기」 → 서랍(「내 맞춤 회화」: 만드는 중·완성·실패) → 완성 편은 `DialogueScreen` 으로.
- 진입: 배우기 탭 「회화 (새)」 섹션의 「맞춤 회화 만들기」 타일 + 주제별 회화 홈 상단 카드. 1회 무료 안내는 만들기 버튼 아래 한 줄, 402 이면 "첫 1편은 무료, 다음 편부터는 유료(준비 중)" 안내만(결제 흐름 없음).
- Worker 가 아직 없을 때: 네트워크 오류를 "지금은 만들 수 없어요" 로 보이고 입력은 로컬에 남긴다(다시 시도 버튼).

## 5. 코드 서버(맥미니, 이 폴더)

- `tools/custom_script_worker.py` — launchd `com.talkverse.ja.custom-script`(5분, `~/Library/LaunchAgents`, 아직 올리지 않음 — Worker 끝나고 사용자 확인 뒤). 흐름은 §1 ③~⑧. 키는 환경변수 `TALKVERSE_SCRIPT_KEY`(launchd 는 `doppler run -p keys -c prd --` 로 감싼다).
- 초안: `~/bin/claude-lab -p` 에 `tools/prompts/custom_script.md`(도메인·상황·레벨·인물표·톤 규칙 `docs/DIALOGUE_WORKFLOW_JA.md` §5 요약)를 넣어 JSON 만 받는다. (재작성 단계 없음 — Claude 초안이 최종.) 독음은 `tools/rd_ja.py`, 검사는 `tools/check_dialogues.py --file`.
- 한 번에 1편, 편당 5~15분. 실패 3회면 failed.
