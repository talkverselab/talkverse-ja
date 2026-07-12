# -*- coding: utf-8 -*-
"""scratchpad 의 meanings_part*.json 을 병합·검증해 db/corpus/kanji_meanings_ko.json 생성."""
import csv
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CORPUS = ROOT / "db" / "corpus"
OUT = CORPUS / "kanji_meanings_ko.json"


def main(parts_dir):
    parts_dir = Path(parts_dir)
    merged = {}
    for i in range(1, 7):
        p = parts_dir / f"meanings_part{i}.json"
        d = json.loads(p.read_text(encoding="utf-8"))
        overlap = set(d) & set(merged)
        if overlap:
            print(f"part{i}: overlapping keys ignored: {sorted(overlap)[:5]}")
        merged.update(d)
        print(f"part{i}: {len(d)} entries")

    # 전체 커버리지 검증
    with open(CORPUS / "ja_kanji_weighted_freq.csv", encoding="utf-8") as f:
        expected = [r["kanji"] for r in csv.DictReader(f)]
    missing = [c for c in expected if c not in merged]
    extra = [c for c in merged if c not in expected]

    # 스키마 검증
    bad = []
    for ch, d in merged.items():
        ms = d.get("meanings")
        rs = d.get("readings", [])
        if not isinstance(ms, list) or not ms or not all(isinstance(m, str) and m for m in ms):
            bad.append((ch, "meanings"))
            continue
        for r in rs:
            if not isinstance(r, dict) or r.get("kind") not in ("훈독", "음독") \
                    or not r.get("reading") or "gloss" not in r:
                bad.append((ch, f"readings:{r}"))
                break

    print(f"total={len(merged)} expected={len(expected)} missing={len(missing)} extra={len(extra)} bad={len(bad)}")
    if missing:
        print("missing:", "".join(missing))
    if extra:
        print("extra:", "".join(extra))
    for ch, why in bad[:20]:
        print("bad:", ch, why)
    if missing or bad:
        sys.exit(1)
    for c in extra:
        del merged[c]

    OUT.write_text(json.dumps(merged, ensure_ascii=False, indent=1), encoding="utf-8")
    multi = sum(1 for d in merged.values() if len(d["meanings"]) > 1)
    with_r = sum(1 for d in merged.values() if d.get("readings"))
    print(f"wrote {OUT} multi-meaning={multi} with-readings={with_r}")


if __name__ == "__main__":
    main(sys.argv[1])
