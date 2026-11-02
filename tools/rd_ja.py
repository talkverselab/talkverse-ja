"""일본어 문장 → 한글 독음(rd) 결정론 변환기. 규칙 = docs/RD_RULES_JA.md (소리 나는 대로, 2026-11-02).

  python tools/rd_ja.py "ちょっと待って、マジで？"      # → 춋토 맛테, 마지데?
  python tools/rd_ja.py --kana "ちょっとまって"          # 가나(읽기)만 줄 때 (조사 は/へ/を 는 글자대로)

janome(순수 파이썬 형태소 분석)로 읽기를 얻고, 조사 は→와·へ→에·を→오 를 적용한 뒤 가타카나 읽기를 한글로 바꾼다.
검사기(check_dialogues.py)가 턴의 rd 를 이 결과와 비교한다(--fix-rd 로 채움).
"""
import re
import sys

try:
    from janome.tokenizer import Tokenizer
except ImportError:  # 검사기 없이 규칙만 쓸 때
    Tokenizer = None

_tok = None


def _tokenizer():
    global _tok
    if _tok is None:
        if Tokenizer is None:
            raise SystemExit("janome 가 필요합니다: pip install janome")
        _tok = Tokenizer()
    return _tok


# ── 가타카나 → (초성, 중성) ──────────────────────────────────────────────
# 초성 인덱스: ㄱ0 ㄲ1 ㄴ2 ㄷ3 ㄸ4 ㄹ5 ㅁ6 ㅂ7 ㅃ8 ㅅ9 ㅆ10 ㅇ11 ㅈ12 ㅉ13 ㅊ14 ㅋ15 ㅌ16 ㅍ17 ㅎ18
# 중성 인덱스: ㅏ0 ㅐ1 ㅑ2 ㅒ3 ㅓ4 ㅔ5 ㅕ6 ㅖ7 ㅗ8 ㅘ9 ㅙ10 ㅚ11 ㅛ12 ㅜ13 ㅝ14 ㅞ15 ㅟ16 ㅠ17 ㅡ18 ㅢ19 ㅣ20
V = {'a': 0, 'i': 20, 'u': 13, 'e': 5, 'o': 8, 'ya': 2, 'yu': 17, 'yo': 12, 'wa': 9, 'we': 15, 'wi': 16, 'ye': 7, 'eu': 18}
C = {'': 11, 'k': 15, 'g': 0, 's': 9, 'z': 12, 't': 16, 'd': 3, 'n': 2, 'h': 18, 'b': 7, 'p': 17, 'm': 6, 'r': 5,
     'ch': 14, 'j': 12, 'sh': 9, 'ts': 14, 'f': 18, 'w': 11, 'y': 11}
# 가나 1~2자 → (자음, 모음). 특수: 'N' = ん, 'Q' = っ, '-' = 장음
KANA = {
    'ア': ('', 'a'), 'イ': ('', 'i'), 'ウ': ('', 'u'), 'エ': ('', 'e'), 'オ': ('', 'o'),
    'カ': ('k', 'a'), 'キ': ('k', 'i'), 'ク': ('k', 'u'), 'ケ': ('k', 'e'), 'コ': ('k', 'o'),
    'ガ': ('g', 'a'), 'ギ': ('g', 'i'), 'グ': ('g', 'u'), 'ゲ': ('g', 'e'), 'ゴ': ('g', 'o'),
    'サ': ('s', 'a'), 'シ': ('sh', 'i'), 'ス': ('s', 'eu'), 'セ': ('s', 'e'), 'ソ': ('s', 'o'),
    'ザ': ('z', 'a'), 'ジ': ('j', 'i'), 'ズ': ('z', 'eu'), 'ゼ': ('z', 'e'), 'ゾ': ('z', 'o'),
    'タ': ('t', 'a'), 'チ': ('ch', 'i'), 'ツ': ('ts', 'eu'), 'テ': ('t', 'e'), 'ト': ('t', 'o'),
    'ダ': ('d', 'a'), 'ヂ': ('j', 'i'), 'ヅ': ('z', 'eu'), 'デ': ('d', 'e'), 'ド': ('d', 'o'),
    'ナ': ('n', 'a'), 'ニ': ('n', 'i'), 'ヌ': ('n', 'u'), 'ネ': ('n', 'e'), 'ノ': ('n', 'o'),
    'ハ': ('h', 'a'), 'ヒ': ('h', 'i'), 'フ': ('f', 'u'), 'ヘ': ('h', 'e'), 'ホ': ('h', 'o'),
    'バ': ('b', 'a'), 'ビ': ('b', 'i'), 'ブ': ('b', 'u'), 'ベ': ('b', 'e'), 'ボ': ('b', 'o'),
    'パ': ('p', 'a'), 'ピ': ('p', 'i'), 'プ': ('p', 'u'), 'ペ': ('p', 'e'), 'ポ': ('p', 'o'),
    'マ': ('m', 'a'), 'ミ': ('m', 'i'), 'ム': ('m', 'u'), 'メ': ('m', 'e'), 'モ': ('m', 'o'),
    'ヤ': ('y', 'ya'), 'ユ': ('y', 'yu'), 'ヨ': ('y', 'yo'),
    'ラ': ('r', 'a'), 'リ': ('r', 'i'), 'ル': ('r', 'u'), 'レ': ('r', 'e'), 'ロ': ('r', 'o'),
    'ワ': ('w', 'wa'), 'ヲ': ('', 'o'), 'ヴ': ('b', 'u'),
    # 요음
    'キャ': ('k', 'ya'), 'キュ': ('k', 'yu'), 'キョ': ('k', 'yo'), 'ギャ': ('g', 'ya'), 'ギュ': ('g', 'yu'), 'ギョ': ('g', 'yo'),
    'シャ': ('sh', 'ya'), 'シュ': ('sh', 'yu'), 'ショ': ('sh', 'yo'), 'ジャ': ('j', 'a'), 'ジュ': ('j', 'u'), 'ジョ': ('j', 'o'),
    'チャ': ('ch', 'a'), 'チュ': ('ch', 'u'), 'チョ': ('ch', 'o'), 'ヂャ': ('j', 'a'), 'ヂュ': ('j', 'u'), 'ヂョ': ('j', 'o'),
    'ニャ': ('n', 'ya'), 'ニュ': ('n', 'yu'), 'ニョ': ('n', 'yo'), 'ヒャ': ('h', 'ya'), 'ヒュ': ('h', 'yu'), 'ヒョ': ('h', 'yo'),
    'ビャ': ('b', 'ya'), 'ビュ': ('b', 'yu'), 'ビョ': ('b', 'yo'), 'ピャ': ('p', 'ya'), 'ピュ': ('p', 'yu'), 'ピョ': ('p', 'yo'),
    'ミャ': ('m', 'ya'), 'ミュ': ('m', 'yu'), 'ミョ': ('m', 'yo'), 'リャ': ('r', 'ya'), 'リュ': ('r', 'yu'), 'リョ': ('r', 'yo'),
    # 외래어 음
    'ティ': ('t', 'i'), 'ディ': ('d', 'i'), 'トゥ': ('t', 'u'), 'ドゥ': ('d', 'u'), 'デュ': ('d', 'yu'),
    'ファ': ('f', 'a'), 'フィ': ('f', 'i'), 'フェ': ('f', 'e'), 'フォ': ('f', 'o'), 'フュ': ('f', 'yu'),
    'ウィ': ('w', 'wi'), 'ウェ': ('w', 'we'), 'ウォ': ('w', 'o'), 'イェ': ('', 'ye'),
    'シェ': ('sh', 'e'), 'ジェ': ('j', 'e'), 'チェ': ('ch', 'e'), 'ツァ': ('ts', 'a'), 'ツェ': ('ts', 'e'), 'ツォ': ('ts', 'o'),
    'ヴァ': ('b', 'a'), 'ヴィ': ('b', 'i'), 'ヴェ': ('b', 'e'), 'ヴォ': ('b', 'o'),
}
# ㅈ·ㅊ 뒤의 y 모음은 단모음으로(쟈→자, 쵸→초) — 한국어 표기 관행
_YJ = {'ya': 'a', 'yu': 'u', 'yo': 'o'}
# 모음별 장음 중성 (장음 = 모음 한 번 더)
_LONG = {0: 0, 20: 20, 13: 13, 5: 5, 8: 8, 2: 0, 17: 13, 12: 8, 9: 0, 15: 5, 16: 20, 7: 5, 18: 13}
JONG_S, JONG_N, JONG_M, JONG_NG = 19, 4, 16, 21


def _syl(c, v, jong=0):
    ci = C[c]
    if c in ('j', 'ch', 'sh') and v in _YJ and c != 'sh':
        v = _YJ[v]
    elif c == 'sh' and v in ('a', 'u', 'o'):
        v = {'a': 'ya', 'u': 'yu', 'o': 'yo'}[v]  # 샤·슈·쇼
    vi = V[v]
    return chr(0xAC00 + (ci * 21 + vi) * 28 + jong), vi


def kata_to_hangul(k: str) -> str:
    """가타카나 읽기 → 한글. 장음·촉음·ん·요음 처리."""
    out = []  # [char]
    last_v = None
    i = 0
    n = len(k)
    while i < n:
        two = k[i:i + 2]
        one = k[i]
        if one == 'ッ':
            if out and out[-1] and '가' <= out[-1] <= '힣':
                out[-1] = _add_jong(out[-1], JONG_S)
            else:
                out.append('읏')  # 문두의 っ(「、って」) 는 읏
            i += 1
            continue
        if one == 'ン':
            nxt = k[i + 1] if i + 1 < n else ''
            cn = KANA.get(k[i + 1:i + 3], KANA.get(nxt, ('', '')))[0] if nxt else ''
            jong = JONG_M if cn in ('m', 'b', 'p') else JONG_NG if cn in ('k', 'g') else JONG_N
            if out and out[-1]:
                out[-1] = _add_jong(out[-1], jong)
            else:
                out.append('응' if jong == JONG_NG else '음' if jong == JONG_M else '은')
            i += 1
            continue
        if one == 'ー':
            if last_v is not None:
                out.append(chr(0xAC00 + (11 * 21 + _LONG.get(last_v, last_v)) * 28))
            i += 1
            continue
        if one == 'ウ' and last_v in (8, 12) and not (i + 1 < n and k[i + 1] in 'ィェォ'):
            # オ단 + ウ = 장음(おはよう → 오하요오, とうきょう → 토오쿄오)
            out.append(chr(0xAC00 + (11 * 21 + 8) * 28))
            i += 1
            continue
        if two in ('ファ', 'フィ', 'フェ', 'フォ'):  # 표기표 §8: 화·휘·훼·훠
            out.append({'ファ': '화', 'フィ': '휘', 'フェ': '훼', 'フォ': '훠'}[two]); last_v = {'ファ': 0, 'フィ': 20, 'フェ': 5, 'フォ': 8}[two]
            i += 2
            continue
        if two in KANA:
            c, v = KANA[two]
            i += 2
        elif one in KANA:
            c, v = KANA[one]
            i += 1
        else:
            out.append(one)  # 기호·숫자·한글 등은 그대로
            last_v = None
            i += 1
            continue
        s, last_v = _syl(c, v)
        out.append(s)
    return ''.join(out)


def _add_jong(syl: str, jong: int) -> str:
    code = ord(syl)
    if not 0xAC00 <= code <= 0xD7A3:
        return syl
    base = code - 0xAC00
    if base % 28 != 0:  # 이미 받침이 있으면 그대로(촛토 뒤 ん 같은 드문 경우)
        return syl
    return chr(code + jong)


def _hira_to_kata(s: str) -> str:
    return ''.join(chr(ord(ch) + 0x60) if 'ぁ' <= ch <= 'ゖ' else ch for ch in s)


USER_DICT = {'鬱': 'ウツ', '昔々': 'ムカシムカシ', '々': '', 'スマホ': 'スマホ', 'ふふ': 'フフ', 'ふーん': 'フーン', '既読': 'キドク', '既読スルー': 'キドクスルー', '寝落ち': 'ネオチ', 'スタンプ': 'スタンプ', 'ウケる': 'ウケル', 'とりま': 'トリマ', 'りょ': 'リョ', 'おけ': 'オケ', 'おつ': 'オツ', 'てか': 'テカ', '推し': 'オシ', '既読スルーされた': 'キドクスルーサレタ'}
GREETING_WA = {'こんにちは': 'コンニチワ', 'こんばんは': 'コンバンワ', 'では': 'デワ'}
CONTENT_POS = {'名詞', '動詞', '形容詞', '副詞', '感動詞', '接続詞', '連体詞', '接頭詞'}
PUNCT = {'＝': ' = ', '（': ' (', '）': ') ', '『': ' "', '』': '" ', '、': ', ', '。': '.', '！': '!', '？': '?', '…': '…', '「': ' "', '」': '" ', '・': '·', '　': ' ', '〜': '~', '~': '~'}


def to_rd(ja: str) -> str:
    """일본어 문장(한자·가나 혼용) → 한글 독음. 프로필 변수 {name} 류는 그대로 둔다."""
    parts = re.split(r'(\{[a-z_]+\})', ja)
    out = []
    for p in parts:
        if not p:
            continue
        if p.startswith('{') and p.endswith('}'):
            out.append(p)
            continue
        out.append(_rd_text(p))
    rd = ''
    for x in out:
        if not x:
            continue
        if x.startswith('{'):
            rd += (' ' if rd and not rd.endswith((' ', ',', '.', '!', '?', '…')) else '') + x
        else:
            rd += (' ' if rd and not rd.endswith((' ', '{')) and not rd.endswith('}') and not x[0] in ',.!?…' else '') + x
    rd = re.sub(r'\s+([,.!?…])', r'\1', rd)          # 부호 앞 공백 제거
    rd = re.sub(r'([,.!?…])(?=[^\s,.!?…"}])', r'\1 ', rd)  # 부호 뒤 공백
    rd = re.sub(r'[\U0001F000-\U0001FAFF\u2600-\u27BF\uFE0F]', '', rd)  # 이모지·스탬프 기호는 독음에서 제외
    rd = re.sub(r' {2,}', ' ', rd).strip()
    return rd


def _rd_text(text: str) -> str:
    # 사용자 사전의 긴 항목부터 치환(읽기 가타카나로 바꿔 두면 janome 가 그대로 읽는다)
    for k in sorted(USER_DICT, key=len, reverse=True):
        if k in text:  # 가나 낱말은 경계 안에서만(おつ 가 おつけします 를 깨지 않게), 한자 낱말은 그대로 치환(既読ついてる)
            if re.fullmatch(r'[ぁ-んァ-ンー]+', k):
                text = re.sub(r'(?<![ぁ-んァ-ン])' + re.escape(k) + r'(?![ぁ-んァ-ン])', USER_DICT[k], text)
            else:
                text = text.replace(k, USER_DICT[k])
    words = []
    prev_pos = None
    prev_surf = None
    for t in _tokenizer().tokenize(text):
        surf = t.surface
        feats = t.part_of_speech.split(',')
        pos, pos2 = feats[0], feats[1] if len(feats) > 1 else ''
        reading = t.reading if t.reading != '*' else _hira_to_kata(surf)
        if t.reading == '*' and re.search(r'[一-龥]', surf):
            reading = f'〔{surf}〕'  # 읽기 모름 — 검사기가 잡는다(rd 허용 글자 밖)
        if surf in GREETING_WA:
            reading = GREETING_WA[surf]
        if surf == '笑':  # (笑)·!?笑 — 혼자 쓰인 笑 는 わらい
            reading = 'ワライ'
        if pos == '記号':
            words.append(('P', PUNCT.get(surf, surf)))
            prev_pos = pos
            continue
        # 문절 시작(내용어, 비자립·접미 아님, 앞이 접두사 아님)이면 띄어쓰기
        kata_join = (bool(re.fullmatch(r'[ァ-ヶー]+', surf)) and bool(re.fullmatch(r'[ァ-ヶー]+', prev_surf or ''))) or surf[:1] in 'ゃゅょぁぃぅぇぉっャュョァィゥェォッー'  # 가타카나 합성어·작은 가나로 시작하는 토큰은 붙임
        if words and words[-1][0] in ('W', 'K') and pos in CONTENT_POS and pos2 not in ('非自立', '接尾') and prev_pos != '接頭詞' and not kata_join:
            words.append(('P', ' '))
        prev_pos = pos
        prev_surf = surf
        if pos == '助詞' and surf == 'は':
            reading = 'ワ'
        elif pos == '助詞' and surf == 'へ':
            reading = 'エ'
        elif pos == '助詞' and surf == 'を':
            reading = 'オ'
        # 한글·영문·숫자가 섞인 토큰은 그대로
        if re.fullmatch(r'[0-9A-Za-z가-힣]+', surf):
            words.append(('W', surf))
            continue
        # 같은 문절 안의 가타카나 읽기는 이어 붙여 한 번에 변환(ません 의 ん, って 의 っ 가 앞 음절에 붙도록)
        if words and words[-1][0] == 'K':
            words[-1] = ('K', words[-1][1] + reading)
        else:
            words.append(('K', reading))
    s = ''.join(kata_to_hangul(w) if k == 'K' else w for k, w in words)
    return re.sub(r' +', ' ', s).strip()


def from_kana(kana: str) -> str:
    return kata_to_hangul(_hira_to_kata(kana))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a and a[0] == '--kana':
        print(from_kana(a[1]))
    else:
        print(to_rd(' '.join(a)))
