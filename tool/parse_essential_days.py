# -*- coding: utf-8 -*-
"""Day별 필수 단어 원본 raw.md → 주제별 단어 JSON.
'단어 익히기' 구간만 파싱: `□ 단어` / (후리가나) / `품사 뜻` 패턴.
테마 = Day 5개 묶음. 아이콘 = 한국어 뜻 키워드.
"""
import json, re, sys, os

SRC = sys.argv[1]
OUT = sys.argv[2]

POS = re.compile(r'^(명|동[12３]?|い형|な형|부|조|감|접|연체|외|외래)\s+(.+)$')
KANA_ONLY = re.compile(r'^[ぁ-ゖー]+$')          # 후리가나(히라가나)
TX_KANA = re.compile(r'^[ぁ-ゖァ-ヺー]+$')       # 가나 전용 표제어(가타카나 포함)
NOISE = re.compile(r'저작권자|\w+\.\w+\.com|^\d+$|단어 익히기\.mp3|<!-- PAGE|^Day별|^\[|^정답')
DAY_HDR = re.compile(r'^Day (\d+)')
QUIZ = re.compile(r'^2\s+단어\s+퀴즈')
LEARN = re.compile(r'^1\s+단어 익히기')

ICONS = [
 ('커피','☕'),('차','🍵'),('맥주','🍺'),('물','💧'),('우유','🥛'),('음료','🥤'),
 ('빵','🥖'),('고기','🥩'),('생선','🐟'),('달걀','🥚'),('밥','🍚'),('요리','🍳'),('음식','🍽️'),('식사','🍽️'),
 ('과일','🍎'),('야채','🥬'),('디저트','🍰'),('과자','🍪'),
 ('돈','💴'),('카드','💳'),('지갑','👛'),('가격','🏷️'),('쇼핑','🛍️'),
 ('옷','👕'),('신발','👟'),('가방','👜'),('모자','🧢'),('안경','👓'),('시계','⌚'),
 ('호텔','🏨'),('방','🛏️'),('집','🏠'),('학교','🏫'),('회사','🏢'),('병원','🏥'),('약','💊'),
 ('공항','✈️'),('전철','🚃'),('기차','🚆'),('버스','🚌'),('택시','🚕'),('자동차','🚗'),('자전거','🚲'),('역','🚉'),
 ('표','🎫'),('여권','🛂'),('짐','🧳'),('지도','🗺️'),('여행','🧳'),
 ('전화','📞'),('편지','✉️'),('메일','📧'),('은행','🏦'),('사진','📷'),('컴퓨터','💻'),('텔레비전','📺'),
 ('책','📖'),('신문','📰'),('음악','🎵'),('영화','🎬'),('운동','⚽'),('시합','🏆'),('선수','🏃'),
 ('꽃','💐'),('선물','🎁'),('개','🐕'),('고양이','🐈'),('새','🐦'),('바다','🌊'),('산','⛰️'),('비','🌧️'),('눈','❄️'),('날씨','🌤️'),
 ('아침','🌅'),('점심','🌞'),('저녁','🌆'),('밤','🌙'),('오늘','📅'),('내일','📅'),('어제','📅'),('시간','⏰'),('휴일','🏖️'),('휴무','🏖️'),
 ('친구','🧑‍🤝‍🧑'),('가족','👨‍👩‍👧'),('아이','🧒'),('선생','🧑‍🏫'),('학생','🎓'),('일 ','💼'),('회의','🗣️'),('보고서','📄'),
]
POOL = {'📅':['📅','🗓️','📆'],'🍽️':['🍽️','🍱','🥘']}

lines = open(SRC, encoding='utf-8').read().split('\n')

days = {}  # day -> [ {tx, rd, pos, ko} ]
day = 0
in_learn = False
pending = None  # {tx, rd}
for raw in lines:
    ln = raw.strip()
    if not ln:
        continue
    if DAY_HDR.match(ln):
        continue  # Day 헤더는 페이지 꼬리에 섞여 신뢰 불가 — 학습 헤더로 센다
    if LEARN.match(ln):
        day += 1  # '1 단어 익히기'가 Day당 1회 등장 → 순번이 Day
        in_learn = True
        pending = None
        continue
    if QUIZ.match(ln):
        in_learn = False
        pending = None
        continue
    if not in_learn or day == 0:
        continue
    if NOISE.search(ln):
        continue
    if ln.startswith('□'):
        tx = ln.lstrip('□').strip()
        pending = {'tx': tx, 'rd': ''}
        continue
    if pending is None:
        continue
    pm = POS.match(ln)
    if pm:
        pos, ko = pm.group(1), pm.group(2).strip()
        w = pending
        rd = w['rd'] or (w['tx'] if TX_KANA.match(w['tx']) else '')
        days.setdefault(day, []).append(
            {'ko': ko, 'tx': w['tx'], 'rd': rd, 'pos': pos})
        pending = None
    elif KANA_ONLY.match(ln):
        pending['rd'] = ln
    # 그 외 줄은 무시

def icon_for(ko, used):
    ic = None
    for kw, em in ICONS:
        if kw in ko:
            ic = em
            break
    if ic and ic in used:
        for alt in POOL.get(ic, [ic]):
            if alt not in used:
                ic = alt
                break
    return ic

GROUP = 5
themes = []
day_list = sorted(days)
for g0 in range(0, len(day_list), GROUP):
    grp = day_list[g0:g0 + GROUP]
    tid = f'days{grp[0]:02d}'
    sections = []
    for d in grp:
        used = set()
        words = []
        for w in days[d]:
            ic = icon_for(w['ko'], used)
            item = {'ko': f"[{w['pos']}] {w['ko']}", 'tx': w['tx'], 'rd': w['rd']}
            if ic:
                item['ic'] = ic
                used.add(ic)
            words.append(item)
        sections.append({'title': f'Day {d}', 'words': words})
    n = sum(len(s['words']) for s in sections)
    themes.append({'id': tid, 'title': f'Day {grp[0]}–{grp[-1]}',
                   'emoji': '📘', 'sections': sections})

os.makedirs(os.path.dirname(OUT), exist_ok=True)
json.dump({'_meta': 'Day별 필수 단어', 'themes': themes},
          open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
tot = sum(len(s['words']) for t in themes for s in t['sections'])
print('themes:', len(themes), 'words:', tot)
for t in themes:
    print(' ', t['title'], sum(len(s['words']) for s in t['sections']))
