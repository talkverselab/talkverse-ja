# -*- coding: utf-8 -*-
"""일본 한자 발음부(音符/声旁) 가족 자동 생성.
IDS 분해(cjkvi-ids, 빌드타임 참조) + 음독 일치 검증(탁음 정규화).
산출: assets/data/kanji/phonetic_ja.json {roots, chars}
"""
import json, re, sys, io
from collections import defaultdict
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

IDS_PATH = sys.argv[1] if len(sys.argv) > 1 else '/tmp/ids.txt'
DB = 'assets/data/kanji/kanji_db.json'
OUT = 'assets/data/kanji/phonetic_ja.json'

def is_cjk(ch):
    o = ord(ch)
    return 0x3400 <= o <= 0x9FFF or 0xF900 <= o <= 0xFAFF or 0x20000 <= o <= 0x2FFFF

# IDS 로드: char -> 직접 구성요소 목록
decomp = {}
idc = set('⿰⿱⿲⿳⿴⿵⿶⿷⿸⿹⿺⿻⿼⿽⿾⿿㇯')
for line in open(IDS_PATH, encoding='utf-8'):
    if line.startswith('#'): continue
    parts = line.rstrip('\n').split('\t')
    if len(parts) < 3: continue
    ch, ids = parts[1], parts[2]
    ids = re.sub(r'\[[A-Z]+\]', '', ids)
    comps = [c for c in ids if is_cjk(c) and c != ch]
    if comps: decomp[ch] = comps

MAX_DEPTH = 1  # 직접 구성요소 + 1단계만 (깊은 우연 일치 방지)
def all_components(ch, depth=0, seen=None):
    if seen is None: seen = set()
    out = []
    if depth > MAX_DEPTH: return out
    for c in decomp.get(ch, []):
        if c in seen: continue
        seen.add(c)
        out.append((c, depth))
        out.extend(all_components(c, depth+1, seen))
    return out

# 의미부(부수)·획 원소 — 발음부가 될 수 없는 것들
RADICAL_BLACKLIST = set(
    '一丨丶丿乙亅二亠人亻儿入八冂冖冫几凵刀刂力勹匕匚匸十卜卩厂厶又'
    '口囗土士夂夊夕大女子宀寸小尢尸屮山巛川工己巾干幺广廴廾弋弓彐彡彳'
    '心忄戈戸手扌支攴攵文斗斤方无日曰月木欠止歹殳毋比毛氏气水氵火灬'
    '爪爫父爻爿片牙牛犬犭玄玉王瓜瓦甘生用田疋疒癶白皮皿目矛矢石示礻'
    '禸禾穴立竹米糸缶网羊羽老而耒耳聿肉臣自至臼舌舛舟艮色艸艹虍虫血'
    '行衣衤襾見角言貝赤走足身車辛辰辵辶邑阝酉釆里金長門隹雨青非'
    '面革韋韭音頁風飛食首香馬骨高髟鬥鬯鬲鬼魚鳥鹵鹿麥麻黃黍黑黹'
    '黽鼎鼓鼠鼻齊齒龍龜龠丷丬丆龴⺌⺍龵个丩丯𠂉'
)
# 단, 실제 발음부로 유명한 부수는 예외 허용 (음독 일치율로 재검증됨)
RADICAL_BLACKLIST -= set('工方白青非己干士古台包及分反半皮里')


# 음독 정규화: 탁음/반탁음 -> 청음
DAKU = str.maketrans('ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ',
                     'カキクケコサシスセソタチツテトハヒフヘホハヒフヘホ')
def norm(r):
    r = r.split('-')[0].strip()
    return r.translate(DAKU)

db = json.load(open(DB, encoding='utf-8'))
entries = db['entries']
onmap = {}   # char -> set of normalized on readings
rawon = {}   # char -> first raw on
komap = {}   # char -> 한국 한자음
jlpt = {}
rank = {}
for e in entries:
    ons = e.get('on') or []
    if not ons: continue
    c = e['char']
    onmap[c] = {norm(r) for r in ons}
    rawon[c] = ons[0]
    jlpt[c] = e.get('jlpt')
    rank[c] = e.get('rank', 9999)
    ms = e.get('meanings_ko') or []
    if ms:
        last = ms[0].strip()[-1:]
        if last and 0xAC00 <= ord(last) <= 0xD7A3: komap[c] = last

# 후보: 각 한자 X 의 구성요소 C 중 음독 일치하는 것
cand = defaultdict(set)   # root -> {members}
comp_depth = {}           # (root,member) -> depth (작을수록 직접 구성요소)
for x in onmap:
    for c, d in all_components(x):
        if c == x: continue
        if c in onmap and (onmap[c] & onmap[x]):
            cand[c].add(x)
            k = (c, x)
            if k not in comp_depth or d < comp_depth[k]: comp_depth[k] = d
        # 루트가 db 밖이어도 허용: 구성요소가 2회 이상 등장하면 뒤에서 멤버끼리 검증
        elif c not in onmap:
            cand[c].add(x)
            k = (c, x)
            if k not in comp_depth or d < comp_depth[k]: comp_depth[k] = d

# 일치율 검증: C 를 포함한 db 한자 중 음독이 일치하는 비율이 높아야 발음부
contain = defaultdict(set)  # C -> C를 포함한 모든 db 한자
for x in onmap:
    for c, d in all_components(x):
        contain[c].add(x)

roots = {}
for c, members in cand.items():
    if c in RADICAL_BLACKLIST: continue
    if c in onmap:
        ms = {m for m in members if onmap[c] & onmap[m]}
    else:
        cnt = defaultdict(set)
        for m in members:
            for r in onmap[m]: cnt[r].add(m)
        if not cnt: continue
        best = max(cnt.values(), key=len)
        ms = best
    if len(ms) < 2: continue
    total = len(contain.get(c, ms))
    ratio = len(ms) / max(total, 1)
    if ratio < 0.4 and not (len(ms) >= 5 and ratio >= 0.3): continue
    # db 밖·희귀 글리프 루트 → 다른 모든 멤버에 포함되는 db 멤버로 승격
    if c not in onmap or ord(c[0]) > 0xFFFF:
        promoted = None
        for m in ms:
            rest = ms - {m}
            if rest and rest <= contain.get(m, set()):
                promoted = m; break
        if promoted:
            ms = ms | {c} if c in onmap else ms
            c = promoted
            ms = ms - {c}
            if len(ms) < 2: continue
        elif ord(c[0]) > 0xFFFF:
            continue  # 표시 불가 글리프는 버린다
    if c in roots: roots[c] |= ms
    else: roots[c] = ms

# 멤버 중복 배정: 더 깊은(작은) 구성요소보다 직접(얕은) 요소·큰 가족 우선
assign = {}
for c, ms in roots.items():
    for m in ms:
        d = comp_depth.get((c, m), 9)
        score = (d, -len(ms))
        if m not in assign or score < assign[m][1]:
            assign[m] = (c, score)

fam = defaultdict(list)
for m, (c, _) in assign.items(): fam[c].append(m)
fam = {c: ms for c, ms in fam.items() if len(ms) >= 2}

out_roots, out_chars = {}, {}
for c, ms in sorted(fam.items(), key=lambda kv: -len(kv[1])):
    on = rawon.get(c)
    if not on:
        cnt = defaultdict(int)
        for m in ms: cnt[rawon[m].translate(DAKU)] += 1
        on = max(cnt, key=cnt.get)
    out_roots[c] = {'on': on, 'ko': komap.get(c), 'count': len(ms),
                    'in_db': c in onmap}
    for m in sorted(ms, key=lambda x: (rank.get(x) or 9999)):
        out_chars[m] = {'phonetic': c, 'jlpt': jlpt.get(m)}

json.dump({'_meta': f'JLPT 한자 발음부(音符) 자동판정 — IDS 분해 + 음독(탁음 정규화) 일치 검증. 가족 2자 이상.',
           'roots': out_roots, 'chars': out_chars},
          open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print('roots:', len(out_roots), 'chars:', len(out_chars))
top = sorted(out_roots.items(), key=lambda kv: -kv[1]['count'])[:15]
for c, v in top: print(c, v['on'], v['ko'], v['count'], sorted(fam[c], key=lambda x: (rank.get(x) or 9999))[:8])
