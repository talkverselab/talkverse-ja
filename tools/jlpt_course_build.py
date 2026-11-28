#!/usr/bin/env python3
"""JLPT 급별 과정(assets/data/jlpt/course.json) 만들기.

한 급을 장으로 나눈다. 장 = 낱말(한자 묶음) + 문형 + 읽기 이야기 + 듣기 대화. 복습 문제는 앱이 자료에서 만든다.
- 낱말: 낱말 DB 의 그 급 낱말을 「쉬운 한자」 순으로 — 자주 쓰는 한자부터, 같은 소리 부품(패밀리) 한자는 붙여서.
  낱말은 그 낱말의 한자 가운데 가장 뒤에 나오는 한자 묶음에 넣는다(앞 한자는 이미 배운 상태).
- 문형: patterns.json 의 그 급 문형을 파일 순서대로 장마다 PER 개.
- 이야기·대화: data/jlpt_course/n<급>.json (자체 작성) 의 장 번호에 맞춰 넣는다. 없으면 그 장은 「준비 중」.
사용: python3 tools/jlpt_course_build.py
"""
import json, math, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = os.path.join(ROOT, 'assets', 'data')
PER = 10  # 장마다 문형 수(대략)
KANJI = re.compile('[一-鿿]')


def load(p):
    with open(p, encoding='utf-8') as f:
        return json.load(f)


def build_level(lv, words, pats, ph, idx, src):
    ws = [w for w in words if w.get('jlpt') == lv and (w.get('ko') or '').strip()]
    seen, uniq = set(), []
    for w in sorted(ws, key=lambda w: (w.get('rank') or 99999, w['id'])):
        if w['surface'] in seen:
            continue
        seen.add(w['surface'])
        uniq.append(w)
    rank = {e['char']: e['rank'] for e in idx['entries']}
    mean = {e['char']: e.get('meaning') or '' for e in idx['entries']}
    chars = sorted({c for w in uniq for c in w['surface'] if KANJI.match(c)})
    fam = lambda c: ph['chars'].get(c, {}).get('phonetic') or (c if c in ph['roots'] else None)
    groups = {}
    for c in chars:
        groups.setdefault(fam(c) or ('_' + c), []).append(c)
    r = lambda c: rank.get(c, 5000)
    order = []
    for g in sorted(groups.values(), key=lambda g: min(r(c) for c in g)):
        order += sorted(g, key=r)
    pos = {c: i for i, c in enumerate(order)}
    by = {c: [] for c in order}
    kana = []
    for w in uniq:
        ks = [c for c in w['surface'] if c in pos]
        if ks:
            by[max(ks, key=lambda c: pos[c])].append(w)
        else:
            kana.append(w)
    lp = [p['id'] for p in pats if p['lv'] == lv]
    n = max(1, math.ceil(len(lp) / PER))
    per_p = math.ceil(len(lp) / n)
    kw = sum(len(v) for v in by.values())
    per_w, per_k = kw / n, math.ceil(len(kana) / n)
    item = lambda w: [w['surface'], '' if w['kana'] == w['surface'] else w['kana'], w['ko']]
    chapters, ci, acc = [], 0, 0
    cur = []
    flat = [(c, by[c]) for c in order if by[c]]
    cut = [[] for _ in range(n)]
    for c, v in flat:
        cut[min(n - 1, int(acc / per_w))].append((c, v))
        acc += len(v)
    for i in range(n):
        g = []
        kk = kana[i * per_k:(i + 1) * per_k]
        if kk:
            g.append({'k': '', 'm': '', 'w': [item(w) for w in kk]})
        for c, v in cut[i]:
            root = fam(c)
            g.append({'k': c, 'm': mean.get(c, ''), 'f': root if root and root != c else '', 'w': [item(w) for w in v]})
        ch = {'n': i + 1, 'words': g, 'patterns': lp[i * per_p:(i + 1) * per_p]}
        s = (src or {}).get(str(i + 1)) or {}
        for k in ('title', 'read', 'listen'):
            if s.get(k):
                ch[k] = s[k]
        chapters.append(ch)
    return {'lv': lv, 'chapters': chapters}


def main():
    words = load(os.path.join(A, 'words', 'words_jlpt.json'))['entries']
    pats = load(os.path.join(A, 'jlpt', 'patterns.json'))
    ph = load(os.path.join(A, 'kanji', 'phonetic_ja.json'))
    idx = load(os.path.join(A, 'kanji', 'kanji_index.json'))
    out = []
    for lv in (5, 4, 3, 2, 1):
        p = os.path.join(ROOT, 'data', 'jlpt_course', f'n{lv}.json')
        if not os.path.exists(p):
            continue
        L = build_level(lv, words, pats, ph, idx, load(p))
        out.append(L)
        print(f"N{lv}: {len(L['chapters'])}장", [(sum(len(g['w']) for g in c['words']), len(c['patterns']), 'read' in c, 'listen' in c) for c in L['chapters']])
    with open(os.path.join(A, 'jlpt', 'course.json'), 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, separators=(',', ':'))


if __name__ == '__main__':
    main()
