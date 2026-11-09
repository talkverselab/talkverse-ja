#!/usr/bin/python3
"""맞춤 회화 코드 서버 워커 — 2026-11-02. 계약: docs/CUSTOM_SCRIPT_API.md §1·§5.

Cloudflare 에 쌓인 요청(queued)을 하나 가져와 ① claude-lab -p 로 편(JSON) 작성 → ② 독음·검사 → ③ 결과를 같은 ID 에 올린다.
생성은 Claude 만 쓴다(사용자 지시 2026-11-09 "AI 재생성은 그냥 클로드로만" — Grok 재작성 단계 삭제, 그림 Grok 한도와 겹치지 않게). 외부 LLM API 없음.
  /usr/bin/python3 tools/custom_script_worker.py [--once] [--dry] [--id ja-xxxxxxxx]
환경변수 TALKVERSE_SCRIPT_KEY(필수, launchd 는 `doppler run -p keys -c prd --` 로 감싼다). 한 번 실행에 1편.
로그: ~/logs/custom_script/<id>.log, 작업 파일: data/custom_scripts/<id>.json(초안·결과 보관, 공개 저장소에는 올리지 않음 — .gitignore).
"""
import json, os, re, subprocess, sys, time, urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE = 'https://talkverse.uk/api/script/ja'
KEY = os.environ.get('TALKVERSE_SCRIPT_KEY', '')
WORK = ROOT / 'data/custom_scripts'
LOGD = Path.home() / 'logs/custom_script'
PROMPT = ROOT / 'tools/prompts/custom_script.md'
# apply_rewrite·check_dialogues 는 janome 이 필요 → ~/.venvs/ja (없으면 시스템 python3). 2026-11-02 세션 venv 에만 있던 것을 고정.
PY = str(Path.home() / '.venvs/ja/bin/python3') if (Path.home() / '.venvs/ja/bin/python3').exists() else sys.executable
ISLAND_KO = {'survival': '서바이벌', 'friends': '친구', 'love': '사랑', 'life': '생활', 'travel': '여행', 'culture': '문화', 'work': '일', 'study': '학업'}
LEVEL = {'R0': ('왕초보', '4~6', '2~4'), 'R1': ('초보', '6~8', '3~8'), 'R2': ('중급', '8~12', '5~12'), 'R3': ('고급', '12~16', '8~18')}
a = sys.argv[1:]
DRY, ONCE = '--dry' in a, '--once' in a or True
ONLY = a[a.index('--id') + 1] if '--id' in a else None


def api(method, path, body=None):
    req = urllib.request.Request(BASE + path, method=method, headers={'Content-Type': 'application/json', 'X-Script-Key': KEY, 'User-Agent': 'talkverse-ja-worker/1.0'})
    data = json.dumps(body).encode() if body is not None else None
    def parse(raw):
        try:
            return json.loads(raw or '{}')
        except ValueError:
            return {'raw': raw[:200]}
    try:
        with urllib.request.urlopen(req, data, timeout=30) as r:
            return r.status, parse(r.read().decode())
    except urllib.error.HTTPError as e:
        return e.code, parse(e.read().decode())
    except Exception as e:
        return 0, {'error': str(e)}


def log(f, msg):
    line = time.strftime('%H:%M:%S ') + msg
    print(line, flush=True)
    f.write(line + '\n'); f.flush()


def draft(item, f):
    lv = LEVEL.get(item['level'], LEVEL['R1'])
    tpl = PROMPT.read_text(encoding='utf-8').split('\n---\n', 1)[1]
    name = (item.get('name') or '').strip() or '학습자'
    prompt = (tpl.replace('{{name}}', '\x00NAME\x00').replace('{{country}}', '\x00COUNTRY\x00').replace('{{city}}', '\x00CITY\x00')
              .replace('{id}', item['id']).replace('{domain_ko}', ISLAND_KO.get(item['domain'], item['domain'])).replace('{domain}', item['domain'])
              .replace('{situation}', item['situation'].replace('"', '”')).replace('{level_ko}', lv[0]).replace('{level}', item['level'])
              .replace('{turns}', lv[1]).replace('{words}', lv[2]).replace('{name}', name)
              .replace('\x00NAME\x00', '{name}').replace('\x00COUNTRY\x00', '{country}').replace('\x00CITY\x00', '{city}'))
    log(f, 'claude-lab -p 초안 요청')
    # doppler run 이 넣는 ANTHROPIC_API_KEY 등은 빼야 claude.ai 구독 로그인으로 돈다(2026-11-02 "Invalid API key" 확인). 중첩 세션 표시도 뺀다.
    env = {k: v for k, v in os.environ.items() if not k.startswith('ANTHROPIC') and k not in ('CLAUDECODE', 'CLAUDE_CODE_ENTRYPOINT')}
    r = subprocess.run([str(Path.home() / 'bin/claude-lab'), '-p', prompt, '--output-format', 'text', '--model', 'claude-opus-5-5'],
                       cwd=ROOT, capture_output=True, text=True, timeout=900, env=env)
    out = r.stdout.strip()
    m = re.search(r'\{.*\}', out, re.S)
    if not m:
        raise RuntimeError('초안에 JSON 없음: ' + out[:300] + r.stderr[:300])
    ep = json.loads(m.group(0))
    ep['id'] = item['id']; ep['region'] = item['level']; ep['island'] = item['domain']; ep['kind'] = 'custom'
    ep.setdefault('custom', {})['situation'] = item['situation']; ep['custom']['name'] = item.get('name') or ''
    ep.setdefault('purpose', [item['domain']]); ep.setdefault('domain', [item['domain']]); ep.setdefault('flags', [])  # 검사기 메타
    for i, t in enumerate(ep['turns'], 1):
        t['num'] = i; t.setdefault('rd', ''); t.setdefault('tags', []); t.setdefault('new', []); t.setdefault('note', '')
    return ep


def finish(ep, wd, f):
    jf = wd / 'final.json'
    json.dump(ep, open(jf, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    r = subprocess.run([PY, str(ROOT / 'tools/check_dialogues.py'), '--fix-rd', str(jf)], cwd=ROOT, capture_output=True, text=True)
    log(f, 'check: ' + (' '.join(l for l in r.stdout.splitlines() if 'ERR' in l or '총 오류' in l) or r.stderr.strip()[-200:])[:400])
    ep.clear(); ep.update(json.load(open(jf, encoding='utf-8')))
    ep.pop('review', None)
    return ep


def main():
    if not KEY:
        print('TALKVERSE_SCRIPT_KEY 없음'); return 2
    WORK.mkdir(parents=True, exist_ok=True); LOGD.mkdir(parents=True, exist_ok=True)
    code, j = api('GET', '/pending')
    if code != 200:
        print('pending', code, j); return 1
    items = [i for i in j.get('items', []) if not ONLY or i['id'] == ONLY]
    if not items:
        print('대기 없음'); return 0
    item = items[0]
    wd = WORK / item['id']; wd.mkdir(exist_ok=True)
    f = open(LOGD / f"{item['id']}.log", 'a', encoding='utf-8')
    log(f, f"시작 {item['id']} {item['domain']} {item['level']} 「{item['situation']}」")
    if DRY:
        log(f, 'dry — claim 하지 않음'); return 0
    code, j = api('POST', f"/{item['id']}/claim")
    if code != 200:
        log(f, f'claim 실패 {code} {j}'); return 1
    try:
        ep = draft(item, f)
        log(f, f"초안 {len(ep['turns'])}턴 「{ep.get('title', '')}」")
        ep = finish(ep, wd, f)
        code, j = api('POST', f"/{item['id']}/result", {'status': 'ready', 'dialogue': ep})
        log(f, f'result {code} {j}')
        return 0 if code == 200 else 1
    except Exception as e:
        log(f, f'실패: {e}')
        api('POST', f"/{item['id']}/result", {'status': 'failed', 'error': str(e)[:300]})
        return 1


if __name__ == '__main__':
    sys.exit(main())
