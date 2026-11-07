#!/usr/bin/python3
"""문장 끝 어조사(ね·よ·な·かな·じゃん·ねん…)로 감정을 드러내는 턴에 감정과 어울리는 이모지를 `emoji` 열로 넣는다.
  python3 tools/particle_emoji.py [편id...]   (없으면 전편)  --dry 는 통계만
사용자 지시 2026-11-07(한국어·중국어·일본어·태국어·베트남어 공통): 어조사가 있는 턴만, 감정 열과 어울리게. 이모지는 화면에만 보이고
음성·읽기(ja·kana·segs)에는 들어가지 않는다 — 그래서 본문을 고치지 않고 `emoji` 열을 따로 둔다(앱 `DialogueTurn.shown`).
감정은 감정 계획(data/tts/plan)의 마지막 조각, 없으면 편 JSON 의 emotion/segs. 본문에 이미 이모지가 있는 턴은 건너뛴다."""
import glob, json, os, re, sys
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EP = {os.path.basename(p)[:-5]: p for p in glob.glob(f'{R}/assets/data/dialogues/*/*/*.json')}
EMOJI = {'neutral': '🙂', 'polite': '😌', 'stiff': '😐', 'cheerful': '😄', 'amused': '😆', 'teasing': '😏', 'excited': '🤩', 'surprised': '😳',
         'shout': '😤', 'tsukkomi': '😑', 'annoyed': '😒', 'sad': '😢', 'worried': '😟', 'flustered': '😅', 'shy': '☺️', 'gentle': '🥰'}
STRONG = re.compile(r'(ねえ|ねー|ね|よね|よな|よ|なあ|なー|な|わよ|わね|わ|ぞ|ぜ|かなあ|かな|かしら|っけ|じゃん|でしょう|でしょ|だろう|だろ|もん|のに|ねん|やんか|やん|がな)$')
WEAK = re.compile(r'(かい|か|の)$')          # 물음 어조사 — 감정이 뚜렷한 턴에만
FLAT = {'neutral', 'polite', 'stiff'}
HAS_EMOJI = re.compile(r'[\U0001F300-\U0001FAFF☀-➿]')
TAIL = re.compile(r'（[^）]*）|\([^)]*\)|(?<![a-zA-Z])w+$|[\s　。、！？!?…〜~♪ー「」『』]+$')


def sentences(ja):
    s = re.sub(r'（[^）]*）|\([^)]*\)', '', ja)
    return [x for x in re.split(r'[。！？!?…]+', s) if x.strip()]


def particle(ja, emo):
    """턴에 어조사로 끝나는 문장이 있으면 그 어조사, 없으면 None."""
    for x in sentences(ja):
        t = x
        for _ in range(3):
            t = TAIL.sub('', t.strip())
        if not t or re.search(r'んな$|^(あの|この|その|どの)$|[^ぁ-ん](あの|この|その|どの)$', t):
            continue
        m = STRONG.search(t)
        if m:
            return m.group(1)
        m = WEAK.search(t)
        if m and emo not in FLAT:
            return m.group(1)
    return None


def emotion_of(ep, t):
    f = f'{R}/data/tts/plan/{ep}.json'
    if os.path.exists(f):
        T = json.load(open(f, encoding='utf-8')).get('turns', {}).get(str(t['num']))
        if T and T.get('segs'):
            return T['segs'][-1][0]
    if t.get('segs'):
        return t['segs'][-1][0]
    return t.get('emotion')


def main():
    dry = '--dry' in sys.argv
    ids = [a for a in sys.argv[1:] if not a.startswith('--')] or sorted(EP)
    stat = {'turns': 0, 'set': 0, 'kept': 0, 'skip_emoji': 0, 'no_emotion': 0}
    by = {}
    for ep in ids:
        d = json.load(open(EP[ep], encoding='utf-8')); changed = False
        for t in d['turns']:
            stat['turns'] += 1
            if HAS_EMOJI.search(t['ja']):
                stat['skip_emoji'] += 1; continue
            emo = emotion_of(ep, t)
            p = particle(t['ja'], emo)
            if not p:
                continue
            if not emo:
                stat['no_emotion'] += 1; continue
            e = EMOJI[emo]
            by[p] = by.get(p, 0) + 1
            if t.get('emoji') == e:
                stat['kept'] += 1; continue
            t['emoji'] = e; changed = True; stat['set'] += 1
        if changed and not dry:
            with open(EP[ep], 'w', encoding='utf-8') as fo:
                json.dump(d, fo, ensure_ascii=False, indent=1); fo.write('\n')
    print(stat, dict(sorted(by.items(), key=lambda x: -x[1])))


if __name__ == '__main__':
    main()
