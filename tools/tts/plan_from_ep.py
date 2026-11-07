#!/usr/bin/python3
"""편 JSON 의 감정 열(turn.emotion / turn.segs) → 감정 계획 data/tts/plan/<편id>.json 자동 생성.
  python3 tools/tts/plan_from_ep.py <편id>... [--force]     (--force 없으면 이미 있는 계획은 건너뛴다)
  python3 tools/tts/plan_from_ep.py --all [--force]          감정 열이 있는 전편

편 JSON 에 쓰는 열(2026-11-07 사용자 지시 "회화문 만들 때 음성용 감정열을 함께"):
  turn.emotion  "cheerful"                       — 턴 전체 한 감정. 읽기는 kana 에서 지문·w·♪·이모지를 뺀 것.
  turn.segs     [["surprised","えっ、本当？"],["gentle","じゃあ見てみる。","じゃあみてみる。"]]
                                                 — 감정이 바뀌는 턴. [감정, 본문(, 읽기)]. 이어 붙이면 ja 와 같아야 한다.
  turn.m / turn.f  {"ja","kana","rd","ko","emotion"|"segs"} — 그 판만 본문이 다를 때(僕/私, くん/さん …).
  ep.cast       {"B":"woman_y"}                  — 고정 인물(ユカ·サクラ·리쿠…)은 자동, 그 밖의 화자는 여기 적는다.
  ep.fill       {"{drama}":{"ja":"…","ko":"…"}}  — {name}·{country}·{city}·{lang} 밖의 자리 표시 값.
감정 이름·목소리 이름은 data/tts/voices.json, 작성 규칙은 data/tts/PLAN_GUIDE.md."""
import json, os, re, subprocess, sys
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ttslib as L

FIXED = {'ユカ': 'yuka', 'サクラ': 'sakura', 'リク': 'riku', 'ケン': 'ken', 'ミン': 'min', 'ホセ': 'jose', '同僚ミサキ': 'misaki', 'ミサキ': 'misaki', '課長': 'kacho'}
STRIP = re.compile(r'（[^）]*）|\([^)]*\)|(?<![a-zA-Z])w+(?![a-zA-Z])|♪|[\U0001F300-\U0001FAFF☀-➿]')


def reading(x):
    r = STRIP.sub('', x.get('kana') or '').strip()
    return r or None


def segs_of(x, where):
    if x.get('segs'):
        out = []
        for s in x['segs']:
            if not isinstance(s, list) or len(s) not in (2, 3) or not s[0] or not s[1]:
                raise ValueError(f'{where} segs 꼴 오류 {s}')
            out.append([str(v) for v in s])
        return out
    if x.get('emotion'):
        s = [x['emotion'], x['ja']]
        r = reading(x)
        if r:
            s.append(r)
        return [s]
    return None


def build(ep):
    d = json.load(open(L.EP[ep], encoding='utf-8'))
    has = any(t.get('emotion') or t.get('segs') for t in d['turns'])
    if not has:
        return None, '감정 열 없음'
    cast = {}
    for k, name in d['speakers'].items():
        if k == 'A':
            continue
        v = (d.get('cast') or {}).get(k) or FIXED.get(name)
        if v not in L.V['voices']:
            return None, f'cast 없음 {k}={name} (편 JSON 의 cast 에 목소리 이름을 적을 것)'
        cast[k] = v
    P = {'ep': ep, 'cast': cast}
    if d.get('fill'):
        P['fill'] = d['fill']
    P['turns'] = {}
    for t in d['turns']:
        segs = segs_of(t, f"턴 {t['num']}")
        if not segs:
            if L.SIL.sub('', t['ja']):
                return None, f"턴 {t['num']} 감정 없음"
            segs = [['neutral', t['ja']]]
        T = {'segs': segs}
        for g in 'mf':
            X = t.get(g)
            if X:
                gs = segs_of(X, f"턴 {t['num']} {g}")
                if not gs:
                    return None, f"턴 {t['num']} {g} 감정 없음"
                T[g] = {'ja': X['ja'], 'kana': X.get('kana', ''), 'rd': X.get('rd', ''), 'ko': X.get('ko', ''), 'segs': gs}
        P['turns'][str(t['num'])] = T
    return P, None


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    force = '--force' in sys.argv
    if '--all' in sys.argv:
        args = sorted(L.EP)
    done, skip, bad = [], [], []
    for ep in args:
        if ep not in L.EP:
            bad.append((ep, '편 없음')); continue
        f = f'{R}/data/tts/plan/{ep}.json'
        if os.path.exists(f) and not force:
            skip.append(ep); continue
        P, err = build(ep)
        if err:
            if err != '감정 열 없음' or '--all' not in sys.argv:
                bad.append((ep, err))
            continue
        os.makedirs(os.path.dirname(f), exist_ok=True)
        json.dump(P, open(f, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
        done.append(ep)
    if done:
        subprocess.run([sys.executable, f'{R}/tools/tts/check_plan.py', *done])
    print(f'생성 {len(done)} 건너뜀(이미 있음) {len(skip)} 실패 {len(bad)}')
    for ep, e in bad:
        print(' ', ep, e)
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
