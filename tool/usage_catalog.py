#!/usr/bin/env python3
"""화면 열람 기록의 화면 목록 → tool/usage_catalog.json

앱이 보내는 화면 ID(lib/services/usage_pages.dart)와 잠금 판단(PaywallGate)을 그대로 옮긴 것.
잠금 범위·내용이 바뀌면 다시 돌린다:  python3 tool/usage_catalog.py [빌드 번호]
tier: free = 이용권 없이 열림, pro = 이용권, exam = 프로+JLPT(N1·N2).
회화·언어감각은 앱에 묶인 판 기준 — 서버에서 편·무료 범위를 바꾸면 그때도 다시 내보낸다.
"""
import glob, json, math, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = os.path.join(ROOT, 'assets')
PATTERN_UNIT, FREE_DAYS = 10, 3          # kPatternUnit, kPatternFreeDays
SETS = (('pat', 'patterns.json', 2, 'JLPT 문형'), ('conf', 'confusables.json', 1, '헷갈리는 말'))  # (ID 접두, 자료, perDay, 이름)


def load(p):
    with open(os.path.join(A, p), encoding='utf-8') as f:
        return json.load(f)


def lv_tier(lv, free):
    return 'free' if free else ('exam' if lv <= 2 else 'pro')


def pages():
    out = []
    # 회화 — R0·R1 과 무료 단계에 든 편은 무료(isDialogueFree)
    plan = load('curriculum_ja.json')
    free_ids = {i for s in plan['stages'] if s.get('free') for i in s.get('dialogueIds', [])}
    for f in sorted(glob.glob(os.path.join(A, 'data/dialogues/R[0-4]/*/*.json'))):
        d = json.load(open(f, encoding='utf-8'))
        if not d.get('turns'):
            continue
        free = d.get('region') in ('R0', 'R1') or d['id'] in free_ids
        out.append((f"conv/{d['id']}", 'free' if free else 'pro', f"회화 {d.get('region', '')} · {d.get('title', '')}"))
    # 언어감각 — free 급은 늘 열림, 나머지 급은 앞에서 freeSenseLevels 개만 무료(SenseCourse.lockIndex)
    i = 0
    for lv in load('data/grammar/sense_course.json')['levels']:
        free = lv.get('free') is True or i < plan.get('freeSenseLevels', 1)
        if lv.get('free') is not True:
            i += 1
        for ls in lv['lessons']:
            out.append((f"sense/{ls['id']}", 'free' if free else 'pro', f"언어감각 · {lv.get('title', '')} · {ls.get('title', ls['id'])}"))
    # 급별 JLPT — 급마다 1장 무료(courseChapterFree)
    for l in load('data/jlpt/course.json'):
        for ch in l['chapters']:
            out.append((f"course/n{l['lv']}/{ch['n']}", lv_tier(l['lv'], ch['n'] <= 1), f"급별 JLPT N{l['lv']} {ch['n']}장"))
    # 누적 읽기 — 하루 묶음의 끝 단원으로 잠금을 가른다(PatternSet.unitFree·unitLevel)
    for pre, asset, per_day, name in SETS:
        items = load('data/jlpt/' + asset)
        units = math.ceil(len(items) / PATTERN_UNIT)
        for u in range(1, units + 1):
            b = min(math.ceil(u / per_day) * per_day, units)
            lv = min(int(x.get('lv') or 5) for x in items[(b - 1) * PATTERN_UNIT:b * PATTERN_UNIT])
            out.append((f"{pre}/u{u}", lv_tier(lv, b <= FREE_DAYS * per_day), f"{name} {u}단원"))
    # JLPT 낱말 — N1·N2 만 시험 권한
    for lv in (5, 4, 3, 2, 1):
        out.append((f"words/n{lv}", lv_tier(lv, lv > 2), f"JLPT 낱말 N{lv}"))
    return out


if __name__ == '__main__':
    ps = pages()
    assert len({p for p, _, _ in ps}) == len(ps), '화면 ID 중복'
    doc = {'pages': [{'page': p, 'tier': t, 'title': ti} for p, t, ti in ps]}
    if len(sys.argv) > 1:
        doc = {'build': int(sys.argv[1]), **doc}
    with open(os.path.join(ROOT, 'tool/usage_catalog.json'), 'w', encoding='utf-8') as f:
        json.dump(doc, f, ensure_ascii=False, indent=0)
        f.write('\n')
    n = {t: sum(1 for _, x, _ in ps if x == t) for t in ('free', 'pro', 'exam')}
    print(len(ps), n)
