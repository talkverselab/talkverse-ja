# -*- coding: utf-8 -*-
"""한자 사전 인덱스 빌드 — app/assets/data/kanji_index.json 생성.

병합 소스:
  - db/corpus/ja_kanji_weighted_freq.csv   (1078자: rank, weighted_pct, word_count)
  - db/corpus/ja_kanji_words.json          (한자별 상위 5 단어 [word, freq, rank])
  - db/corpus/kanji_meanings_ko.json       (전 한자: 복수 음훈 meanings + 훈독/음독 readings)
  - app/assets/data/deck_kanji.json        (코어 80자: 뜻, 훈독/음독 readings, ko 의역 단어 — 최우선)
  - db/corpus/hanja_crossref.json          (meaning_ko 보강)

출력 스키마 (entries 배열, rank 오름차순):
  { "char", "rank", "pct", "meaning", "meanings":[...],
    "readings":[{reading,kind,gloss}], "words":[{word,freq,rank,ko}] }
meaning 은 meanings[0] (하위 호환). 한 한자에 음훈이 여럿이면 meanings 에 병기.
"""
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CORPUS = ROOT / "db" / "corpus"
OUT = ROOT / "app" / "assets" / "data" / "kanji_index.json"


def main():
    # 1. 빈도 기본 골격
    entries = {}
    order = []
    with open(CORPUS / "ja_kanji_weighted_freq.csv", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            ch = row["kanji"]
            entries[ch] = {
                "char": ch,
                "rank": int(row["rank"]),
                "pct": round(float(row["weighted_freq_pct"]), 4),
                "meanings": [],
                "readings": [],
                "words": [],
            }
            order.append(ch)

    # 2. 한자별 상위 단어
    words_doc = json.loads((CORPUS / "ja_kanji_words.json").read_text(encoding="utf-8"))
    for ch, ws in words_doc["entries"].items():
        if ch in entries:
            entries[ch]["words"] = [
                {"word": w, "freq": fr, "rank": rk, "ko": ""} for w, fr, rk in ws[:5]
            ]

    # 3. 전 한자 음훈(복수)·readings — kanji_meanings_ko.json
    meanings_path = CORPUS / "kanji_meanings_ko.json"
    if meanings_path.exists():
        gen = json.loads(meanings_path.read_text(encoding="utf-8"))
        for ch, d in gen.items():
            if ch in entries:
                entries[ch]["meanings"] = list(d.get("meanings", []))
                entries[ch]["readings"] = list(d.get("readings", []))

    def set_primary(ent, meaning):
        """meaning 을 대표(첫 번째)로 — 이미 있으면 앞으로, 없으면 prepend."""
        ms = ent["meanings"]
        if meaning in ms:
            ms.remove(meaning)
        ms.insert(0, meaning)

    # 4. crossref 뜻 (음훈) — 대표 뜻으로 승격
    crossref = json.loads((CORPUS / "hanja_crossref.json").read_text(encoding="utf-8"))
    for e in crossref["entries"]:
        ch = e.get("ja_kanji")
        if ch in entries and e.get("meaning_ko"):
            set_primary(entries[ch], e["meaning_ko"])

    # 5. 코어 80 덱 — 뜻·readings·ko 의역 단어 (최우선)
    deck = json.loads((ROOT / "app" / "assets" / "data" / "deck_kanji.json").read_text(encoding="utf-8"))
    for card in deck["cards"]:
        ch = card["front"]
        if ch not in entries:
            continue
        ent = entries[ch]
        if card.get("back"):
            set_primary(ent, card["back"])
        if card.get("readings"):  # 핸드큐레이션 readings 우선
            ent["readings"] = card["readings"]
        ko_by_word = {w["word"]: w.get("ko", "") for w in card.get("example_words", [])}
        for w in ent["words"]:
            if ko_by_word.get(w["word"]):
                w["ko"] = ko_by_word[w["word"]]

    # meaning = meanings[0] (하위 호환)
    for ent in entries.values():
        ent["meaning"] = ent["meanings"][0] if ent["meanings"] else ""

    out = {
        "version": "v1",
        "source": "ja_kanji_weighted_freq.csv + ja_kanji_words.json + deck_kanji.json + hanja_crossref.json",
        "total": len(order),
        "entries": [entries[ch] for ch in order],
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    with_meaning = sum(1 for e in entries.values() if e["meanings"])
    multi = sum(1 for e in entries.values() if len(e["meanings"]) > 1)
    with_readings = sum(1 for e in entries.values() if e["readings"])
    print(f"wrote {OUT} - {len(order)} kanji, meanings={with_meaning} (multi={multi}), readings={with_readings}")


if __name__ == "__main__":
    main()
