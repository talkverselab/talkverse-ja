# -*- coding: utf-8 -*-
"""한자 사전 인덱스 빌드 — app/assets/data/kanji_index.json 생성.

병합 소스:
  - db/corpus/ja_kanji_weighted_freq.csv   (1078자: rank, weighted_pct, word_count)
  - db/corpus/ja_kanji_words.json          (한자별 상위 5 단어 [word, freq, rank])
  - app/assets/data/deck_kanji.json        (코어 80자: 뜻, 훈독/음독 readings, ko 의역 단어)
  - db/corpus/hanja_crossref.json          (meaning_ko 보강 — 덱에 없는 항목 대비)

출력 스키마 (entries 배열, rank 오름차순):
  { "char", "rank", "pct", "meaning", "readings":[{reading,kind,gloss}],
    "words":[{word,freq,rank,ko}] }
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
                "meaning": "",
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

    # 3. crossref 뜻 (음훈)
    crossref = json.loads((CORPUS / "hanja_crossref.json").read_text(encoding="utf-8"))
    for e in crossref["entries"]:
        ch = e.get("ja_kanji")
        if ch in entries and e.get("meaning_ko"):
            entries[ch]["meaning"] = e["meaning_ko"]

    # 4. 코어 80 덱 — 뜻·readings·ko 의역 단어 (최우선)
    deck = json.loads((ROOT / "app" / "assets" / "data" / "deck_kanji.json").read_text(encoding="utf-8"))
    for card in deck["cards"]:
        ch = card["front"]
        if ch not in entries:
            continue
        ent = entries[ch]
        ent["meaning"] = card.get("back", ent["meaning"])
        ent["readings"] = card.get("readings", [])
        ko_by_word = {w["word"]: w.get("ko", "") for w in card.get("example_words", [])}
        for w in ent["words"]:
            if ko_by_word.get(w["word"]):
                w["ko"] = ko_by_word[w["word"]]

    out = {
        "version": "v1",
        "source": "ja_kanji_weighted_freq.csv + ja_kanji_words.json + deck_kanji.json + hanja_crossref.json",
        "total": len(order),
        "entries": [entries[ch] for ch in order],
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    with_meaning = sum(1 for e in entries.values() if e["meaning"])
    with_readings = sum(1 for e in entries.values() if e["readings"])
    print(f"wrote {OUT} - {len(order)} kanji, meaning={with_meaning}, readings={with_readings}")


if __name__ == "__main__":
    main()
