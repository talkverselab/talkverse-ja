#!/usr/bin/env python3
"""Grok 재작성 답(번호 화자: 일본어 / 한국어)을 편 JSON 에 반영. kana 는 janome 읽기로 다시 만들고 rd 는 비운다(검사기 --fix-rd 로 채움).
python tools/apply_rewrite.py <편.json> <답.md> [--note "..."]"""
import json, re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent)); import rd_ja
def to_hira(text):
    out = []
    for t in rd_ja._tokenizer().tokenize(text):
        r = t.reading if t.reading != '*' else t.surface
        if re.search(r'[一-龥]', t.surface) and t.reading == '*':
            r = t.surface
        out.append(''.join(chr(ord(c) - 0x60) if 'ァ' <= c <= 'ヶ' else c for c in r))
    return ''.join(out)
def main():
    jp, mp = Path(sys.argv[1]), Path(sys.argv[2])
    note = sys.argv[sys.argv.index('--note') + 1] if '--note' in sys.argv else ''
    ep = json.load(open(jp, encoding='utf-8'))
    kick = ''
    got = {}
    for line in open(mp, encoding='utf-8'):
        line = line.strip()
        m = re.match(r'^(\d+)\s+([A-D])\s*[:：]\s*(.+?)\s*/\s*(.+?)(?:\s*/\s*(.*))?$', line)
        if m:
            got[int(m.group(1))] = (m.group(2), m.group(3).strip(), m.group(4).strip())
        elif line.startswith('킥'):
            kick = line.split(':', 1)[-1].split('：', 1)[-1].strip()
    if len(got) < len(ep['turns']) * 0.8:
        print(f'SKIP {ep["id"]}: 답 줄 {len(got)}/{len(ep["turns"])}'); return 2
    changed = 0
    for t in ep['turns']:
        g = got.get(t['num'])
        if not g: continue
        sp, ja, ko = g
        if sp != t['speaker']:
            print(f'  화자 불일치 턴 {t["num"]}: {t["speaker"]}→{sp} (유지)')
        if ja != t['ja']:
            t['ja'] = ja; t['kana'] = to_hira(re.sub(r'\{[a-z_]+\}', lambda m: m.group(0), ja)); t['rd'] = ''; changed += 1
        if ko != t['ko']:
            t['ko'] = ko
    ep.setdefault('review', {})['enrich'] = f'{mp.name}: {changed}턴 교체' + (f' · 킥: {kick}' if kick else '') + (f' · {note}' if note else '')
    json.dump(ep, open(jp, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(f'OK {ep["id"]}: {changed}/{len(ep["turns"])}턴 교체')
    return 0
if __name__ == '__main__':
    sys.exit(main())
