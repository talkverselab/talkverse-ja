"""회화 단어 목록 — 215편 회화의 레마 중 절벽 단어표 2,000위 밖이면서 단어 DB(words_jlpt.json)에 있는 것.
절벽 단어 화면의 「회화 단어 포함」이 읽는다(사용자 지시 2026-11-07). 등장 인물 이름·연출 지시어는 뺀다.
  python3 tools/freq/conv_words.py   → assets/data/freq/conv_words_ja.json"""
import json, glob, csv, collections, re
R = 'assets/data'
SKIP = {'ユカ', 'サクラ', 'ケン', 'リク', 'ホセ', 'ミン', 'アレックス', 'エマ', '小声', '爆笑', '笑', 'てか', 'わっ', 'ウォー'}
rows = csv.DictReader(open(f'{R}/freq/lang_ja_with_regions.csv', encoding='utf-8-sig'))
top = {r['word'] for r in rows if int(r['rank']) <= 2000}
J = json.load(open(f'{R}/words/words_jlpt.json'))['entries']
surf = collections.defaultdict(list); kana = collections.defaultdict(list)
for e in J:
    surf[e['surface']].append(e); kana[e['kana']].append(e)
lem = collections.Counter(); rd = {}
for f in glob.glob(f'{R}/dialogues/R*/**/*.json', recursive=True):
    for t in json.load(open(f)).get('turns', []):
        for l in t.get('lemmas', []):
            if len(l) >= 2 and l[1] not in top and l[1] not in SKIP:
                lem[l[1]] += 1; rd.setdefault(l[1], l[2] if len(l) > 2 else '')
out = []
for w, c in lem.most_common():
    if w in surf: e = surf[w][0]
    elif rd.get(w) and rd[w] in kana and not re.search(r'[一-龥]', w): e = kana[rd[w]][0]
    else: continue
    out.append({'word': w, 'kana': e['kana'], 'ko': e.get('ko') or '', 'n': c})
json.dump({'_meta': '회화 215편 레마 중 절벽 단어표(2,000위) 밖이면서 단어 DB에 있는 것 · tools/freq/conv_words.py', 'words': out},
          open(f'{R}/freq/conv_words_ja.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
print(len(lem), '→', len(out))
