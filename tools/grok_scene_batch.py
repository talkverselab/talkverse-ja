#!/usr/bin/python3
"""회화 장면 컷(만화 1컷, A·B 한 쌍 = 1컷, 글자·말풍선 없음)을 Grok UXUI 방에 편마다 4장씩 요청하고,
받은 그림을 1168×784 로 맞춰 그림 저장소 sparse 클론(~/talkverse/ja-art)의 talkverse_art/scene/ja/<편id>/cut<N>.jpg 에 둔다.
  /usr/bin/python3 tools/grok_scene_batch.py <편id|편.json> ... [--push] [--tab project/832d5dbe]
16턴 편은 8컷 = 요청 2번. 이미 컷 파일이 있으면 건너뛴다. 사용자 지시 2026-11-03 "대화 컷그림도 요청해"."""
import base64, glob, json, os, re, subprocess, sys, time
sys.path.insert(0, '/Users/talkverse/Hanja/tools'); import grok_cdp as g
g.BASE = 'http://127.0.0.1:' + os.environ.get('GROK_CDP_PORT', '9230')
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ART = os.path.expanduser('~/talkverse/ja-art')
SHEET = os.path.join(ROOT, 'data/review/art/chars_ja_v1.jpg')
TONE = os.path.join(ROOT, 'data/review/uxui/sian_01_clay.jpg')
# Grok 은 M4 Chrome(2026-11-03 사용자 지시, ~/talkverse/GROK_M4_LOGIN.md) — 첨부는 브라우저가 있는 M4 경로여야 한다(scp macmini4:/tmp/grok_att/)
if os.environ.get('GROK_ATT_DIR'):
    SHEET = os.path.join(os.environ['GROK_ATT_DIR'], 'chars_ja_v1.jpg'); TONE = os.path.join(os.environ['GROK_ATT_DIR'], 'sian_01_clay.jpg')
a = sys.argv[1:]
tab = a[a.index('--tab') + 1] if '--tab' in a else 'project/832d5dbe'
push = '--push' in a
fetch_only = '--fetch-only' in a  # 이미 보낸 요청의 그림만 현재 대화에서 받는다(보내지 않음)
ids = [x for x in a if not x.startswith('--') and x != tab]
CAST = {'ユカ': '시트 1번 유카(노란 카디건)', 'サクラ': '시트 2번 사쿠라(연분홍 니트, 검은 긴 생머리)', 'ケン': '시트 3번 켄(체크 플란넬)',
        'リク': '시트 4번 리쿠(흰 셔츠, 애쉬브라운 머리)', '{name}': '시트 5번 학습자(구리색 후드티, 갈색 백팩)'}

def who(name):
    if name in CAST: return CAST[name]
    return f'{name}(시트에 없는 조연 — 이름·직업에 맞는 차림의 일본인, 같은 점토 톤, 실존 인물 닮지 않게)'

def find(eid):
    if eid.endswith('.json'): return eid
    fs = glob.glob(os.path.join(ROOT, f'assets/data/dialogues/R*/*/{eid}.json'))
    return fs[0] if fs else None

def prompt(ep, cuts, part):
    sp = ep['speakers']
    lines = []
    for n, pair in cuts:
        ds = ' / '.join(f"{t['speaker']}「{t['ja']}」({t['ko']})" for t in pair)
        lines.append(f'컷{n}: {ds}')
    cast = ', '.join(f'{k} = {who(v)}' for k, v in sp.items())
    return (f"[SC-{ep['id']}-{part}] **이미지 {len(cuts)}장을 생성해 주세요**(글 설명 없이 그림만, 컷마다 한 장씩 따로 {len(cuts)}장). 일본어 학습 앱 회화의 장면 컷입니다.\n"
            f"첨부 1 = 우리 앱 인물 기준 그림(이 인물들의 얼굴·머리·옷을 그대로), 첨부 2 = 그림 톤 참고.\n"
            f"톤: 부드러운 펠트·점토 인형, 파스텔·크림 배경, 둥근 얼굴, 따뜻한 조명, 일본의 실제 장소 느낌. 3:2 가로. "
            f"**그림 안에 글자·말풍선·간판 글씨·로고 없음**(말풍선은 앱이 얹습니다). 실존 인물·브랜드 금지.\n"
            f"장면: {ep['scene']}\n등장: {cast}\n"
            f"각 컷은 아래 두 대사가 오가는 순간의 표정·동작·장소를 한 장으로(대사는 그리지 말고 상황만):\n" + '\n'.join(lines) +
            f"\n지금 바로 이미지 {len(cuts)}장을 생성하세요.")

def imgs_ready(c, want):
    srcs = c.ev("(()=>{const r=[...document.querySelectorAll('.response-content-markdown')];const e=r[r.length-1];if(!e)return [];return [...e.closest('[class*=message],[class*=response]')?.querySelectorAll('img')||e.querySelectorAll('img')].map(i=>i.src)})()") or []
    busy = c.ev("!![...document.querySelectorAll('button')].find(e=>(e.getAttribute('aria-label')||'')==='응답 중지')")
    real = [s for s in srcs if s.startswith('http') and 'assets.grok.com' in s]
    data = [s for s in srcs if s.startswith('data:')]
    return real, (busy or data)

def last_imgs(c):
    # 마지막 답 근처의 생성 그림(assets.grok.com) — 답 요소 밖 갤러리에 붙는 경우가 있어 문서 전체에서 마지막 것들을 본다
    # 첨부 썸네일(64px 안팎)은 빼고, 생성 그림(가로 300px 이상)만
    return c.ev("[...document.querySelectorAll('img')].filter(i=>i.src.includes('assets.grok.com')&&i.naturalWidth>=300).map(i=>i.src)") or []

def fetch_b64(c, url):
    js = ("fetch(%s,{credentials:'include'}).then(r=>r.blob()).then(b=>new Promise(ok=>{const f=new FileReader();f.onload=()=>ok(f.result);f.readAsDataURL(b)}))" % json.dumps(url))
    d = c.ev(js)
    return base64.b64decode(d.split(',', 1)[1]) if isinstance(d, str) and d.startswith('data:') else None

def fit(src, dst):
    # 3:2 로 가운데 자르고 1168×784
    w = int(subprocess.run(['sips', '-g', 'pixelWidth', src], capture_output=True, text=True).stdout.split()[-1])
    h = int(subprocess.run(['sips', '-g', 'pixelHeight', src], capture_output=True, text=True).stdout.split()[-1])
    if w / h > 1.5: cw, ch = int(h * 1.5), h
    else: cw, ch = w, int(w / 1.5)
    subprocess.run(['sips', '-s', 'format', 'jpeg', '-s', 'formatOptions', '88', '--cropToHeightWidth', str(ch), str(cw), src, '--out', dst], capture_output=True)
    subprocess.run(['sips', '-z', '784', '1168', dst], capture_output=True)

def do(eid):
    path = find(eid)
    if not path: print('편 없음', eid); return False
    ep = json.load(open(path, encoding='utf-8'))
    turns = ep['turns']
    cuts = [((i // 2) + 1, turns[i:i + 2]) for i in range(0, len(turns), 2)]
    out = os.path.join(ART, 'talkverse_art/scene/ja', ep['id'])
    os.makedirs(out, exist_ok=True)
    for part, k in enumerate(range(0, len(cuts), 4), 1):
        chunk = cuts[k:k + 4]
        if all(os.path.exists(os.path.join(out, f'cut{n}.jpg')) for n, _ in chunk):
            print('SKIP', ep['id'], part, flush=True); continue
        pf = os.path.join(ROOT, 'data/review/write', f"{ep['id']}_scene{part}_prompt.md")
        open(pf, 'w', encoding='utf-8').write(prompt(ep, chunk, part))
        c = g.CDP(g.tab(tab)); c.call('Page.bringToFront')
        before = set() if fetch_only else set(last_imgs(c))
        if fetch_only:
            last = 'OK'
        else:
          # 그림은 새 대화에서만 안정적으로 나온다(2026-11-03: 긴 대화에서 그림 없이 "완료"만 답함) → 요청마다 프로젝트 첫 화면으로
          c.call('Page.navigate', url='https://grok.com/' + tab.split('?')[0] if tab.startswith('project/') and len(tab) > 20 else 'https://grok.com/project/832d5dbe-6d57-4114-b17d-d4a52e41bf45'); time.sleep(8)
          r = subprocess.run(['/usr/bin/python3', os.path.join(ROOT, 'tools/grok_send.py'), pf, pf.replace('_prompt.md', '_answer.md'),
                            '--tab', tab, '--wait', '90', '--attach', f'{SHEET},{TONE}'], capture_output=True, text=True)
          last = (r.stdout.strip().splitlines() or [''])[-1]
        if last.startswith('LIMIT'):
            print('LIMIT', ep['id'], last, flush=True); return False
        new = []
        for _ in range(80):  # 그림은 글보다 늦게 온다 — 새 assets 그림이 컷 수만큼 될 때까지(최대 20분)
            c = g.CDP(g.tab(tab))
            cur = [s for s in last_imgs(c) if s not in before]
            seen = []
            for s in cur:
                if s not in seen: seen.append(s)
            busy = c.ev("!![...document.querySelectorAll('button')].find(e=>(e.getAttribute('aria-label')||'')==='응답 중지')") or \
                   c.ev("[...document.querySelectorAll('img')].some(i=>i.src.startsWith('data:image')&&i.naturalWidth>200)")
            new = seen
            if len(new) >= len(chunk) and not busy: break
            time.sleep(15)
        print(ep['id'], part, 'imgs', len(new), flush=True)
        if len(new) < len(chunk):
            print('FAIL', ep['id'], part, '그림 수 부족', len(new), flush=True); return False
        for (n, _), url in zip(chunk, new[:len(chunk)]):
            b = fetch_b64(c, url)
            if not b: print('FAIL 받기', url[:80]); return False
            tmp = os.path.join(out, f'.raw{n}')
            open(tmp, 'wb').write(b)
            fit(tmp, os.path.join(out, f'cut{n}.jpg')); os.remove(tmp)
        print('OK', ep['id'], part, [n for n, _ in chunk], flush=True)
    return True

def git_push(msg):
    subprocess.run(['git', '-C', ART, 'add', 'talkverse_art/scene/ja'], check=True)
    if subprocess.run(['git', '-C', ART, 'diff', '--cached', '--quiet']).returncode == 0: return
    subprocess.run(['git', '-C', ART, 'commit', '-q', '-m', msg], check=True)
    for _ in range(4):  # 다른 세션이 같은 저장소에 자주 푸시한다 — 밀리면 다시 받고 재시도
        subprocess.run(['git', '-C', ART, 'pull', '-q', '--rebase'])
        if subprocess.run(['git', '-C', ART, 'push', '-q']).returncode == 0: break
        time.sleep(5)
    print('PUSHED', msg, flush=True)

done = []
for eid in ids:
    ok = do(eid)
    if ok: done.append(eid)
    else: break
    if push and len(done) % 5 == 0: git_push(f'scene/ja: {", ".join(done[-5:])}')
if push and done: git_push(f'scene/ja: {", ".join(done[-(len(done) % 5 or 5):])}')
print('DONE', len(done), flush=True)
