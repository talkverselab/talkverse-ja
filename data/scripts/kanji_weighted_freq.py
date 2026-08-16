"""
단어 × 빈도수 × 한자 → 한자별 가중 빈도 분석.

방법:
  for each (word, freq) in lang_ja_top2500.csv:
    for each kanji char in word:
      kanji_freq[k] += freq    (가중 누적)

추가 분석:
  - 단어 안 한자 위치별 (첫 음절 vs 그 외)
  - 한자별 사용 단어 list
  - hanja_crossref.json 의 80자 cover 율

output:
  db/corpus/ja_kanji_weighted_freq.csv  — rank, kanji, weighted_freq, cum_pct, word_count
  db/corpus/ja_kanji_words.json         — kanji → words (예시 단어 list)
  db/corpus/ja_kanji_analysis.md        — 분석 결과 요약
"""
import csv
import json
from pathlib import Path
from collections import defaultdict

DB = Path(__file__).resolve().parents[1] / "corpus"
SRC = DB / "lang_ja_top2500.csv"
HANJA = DB / "hanja_crossref.json"

OUT_CSV = DB / "ja_kanji_weighted_freq.csv"
OUT_WORDS = DB / "ja_kanji_words.json"
OUT_MD = DB / "ja_kanji_analysis.md"


def is_kanji(ch: str) -> bool:
    """CJK Unified Ideographs (한자/汉字) 만 — 히라가나·카타카나 제외."""
    if not ch:
        return False
    c = ord(ch)
    # CJK Unified Ideographs + Extension A
    return (0x4E00 <= c <= 0x9FFF) or (0x3400 <= c <= 0x4DBF)


def main():
    print(f"== 단어 × 빈도 × 한자 → 한자 가중 빈도 분석 ==")
    print(f"input: {SRC.name}")

    kanji_freq: dict[str, float] = defaultdict(float)
    kanji_words: dict[str, list[tuple[str, float, int]]] = defaultdict(list)
    word_count: dict[str, int] = defaultdict(int)
    total_words = 0
    words_with_kanji = 0

    with open(SRC, encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            word = row["word"]
            freq = float(row["frequency"])
            rank = int(row["rank"])
            total_words += 1
            kanji_in_word = [ch for ch in word if is_kanji(ch)]
            if not kanji_in_word:
                continue
            words_with_kanji += 1
            # 한 단어 안에 같은 한자가 여러 번 = 중복 count
            for k in kanji_in_word:
                kanji_freq[k] += freq
                word_count[k] += 1
                if len(kanji_words[k]) < 5:  # 예시 5개만 저장
                    kanji_words[k].append([word, round(freq, 6), rank])

    # 정렬
    sorted_kanji = sorted(kanji_freq.items(), key=lambda x: -x[1])
    total_weighted = sum(kanji_freq.values())

    print(f"  · 총 단어:        {total_words}")
    print(f"  · 한자 포함 단어: {words_with_kanji}")
    print(f"  · unique 한자:    {len(sorted_kanji)}")
    print(f"  · top 1 weighted: {sorted_kanji[0][1]:.6f} ({sorted_kanji[0][0]})")

    # CSV 출력
    with open(OUT_CSV, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["rank", "kanji", "weighted_freq", "weighted_freq_pct", "cum_pct", "word_count"])
        cum = 0.0
        for i, (k, freq) in enumerate(sorted_kanji, 1):
            cum += freq
            w.writerow([
                i, k, f"{freq:.6f}",
                f"{freq / total_weighted * 100:.4f}",
                f"{cum / total_weighted * 100:.4f}",
                word_count[k],
            ])
    print(f"  ✓ {OUT_CSV.relative_to(DB.parent.parent)}  ({len(sorted_kanji)} entries)")

    # words 매핑 (한자 → 사용 단어 예시 list)
    with open(OUT_WORDS, "w", encoding="utf-8") as f:
        json.dump({
            "description": "각 한자가 사용된 상위 5개 단어 (word, freq, word_rank)",
            "source": "lang_ja_top2500.csv",
            "entries": {k: kanji_words[k] for k, _ in sorted_kanji},
        }, f, ensure_ascii=False, indent=2)
    print(f"  ✓ {OUT_WORDS.relative_to(DB.parent.parent)}")

    # hanja_crossref 와 비교 — 80자 cover 율
    cross = json.loads(HANJA.read_text(encoding="utf-8"))
    cross_ja = {e["ja_kanji"] for e in cross["entries"]}
    sorted_set = {k for k, _ in sorted_kanji}
    overlap = cross_ja & sorted_set
    cross_in_top80 = [k for k in cross_ja if k in {kk for kk, _ in sorted_kanji[:80]}]
    print(f"  · hanja_crossref 80자 중 빈도 분석 등재: {len(overlap)}/80")
    print(f"  · 우리 top80 가중 한자 ∩ hanja_crossref: {len(cross_in_top80)}/80")

    # 분석 요약 MD
    lines = [
        "# ja 한자 가중 빈도 분석 (단어 × 빈도 → 한자)",
        "",
        f"> 갱신: {Path(__file__).stat().st_mtime}",
        f"> input: `lang_ja_top2500.csv` ({total_words} 단어)",
        "",
        "## 1. 방법",
        "",
        "```",
        "for each word in top2500:",
        "    for each kanji char in word:",
        "        kanji_weighted_freq[kanji] += word_frequency",
        "```",
        "",
        "→ 한자가 자주 나오는 단어에 등장할수록 가중치 ↑.",
        "→ 단순 한자 빈도 (글자 카운트) 보다 실제 회화 노출도 반영.",
        "",
        "## 2. 결과 요약",
        "",
        f"- 총 단어: **{total_words}**",
        f"- 한자 포함 단어: **{words_with_kanji}** ({words_with_kanji / total_words * 100:.1f}%)",
        f"- unique 한자 수: **{len(sorted_kanji)}**",
        f"- 가중 빈도 총합: {total_weighted:.4f}",
        "",
        "## 3. Top 30 한자 (가중 빈도)",
        "",
        "| rank | kanji | weighted % | cum % | word count |",
        "|---:|:---:|---:|---:|---:|",
    ]
    cum = 0.0
    for i, (k, freq) in enumerate(sorted_kanji[:30], 1):
        cum += freq
        lines.append(
            f"| {i} | {k} | {freq / total_weighted * 100:.3f}% | {cum / total_weighted * 100:.2f}% | {word_count[k]} |"
        )

    lines += [
        "",
        f"→ top 30 한자 = 누적 **{cum / total_weighted * 100:.1f}%** 가중 빈도 cover.",
        "",
        "## 4. hanja_crossref 80자 cross-check",
        "",
        f"- hanja_crossref 80자 중 빈도 분석 등재: **{len(overlap)}/80** ({len(overlap) / 80 * 100:.0f}%)",
        f"- 우리 top80 가중 한자 ∩ hanja_crossref: **{len(cross_in_top80)}/80**",
        "",
        "### hanja_crossref 80자 중 빈도 분석에 없는 한자",
        "",
    ]
    missing = sorted(cross_ja - set(sorted_set))
    lines.append("`" + ", ".join(missing[:30]) + "`" if missing else "_(모두 등재)_")

    lines += [
        "",
        "## 5. 응용 후보 (앱 통합)",
        "",
        "- **kanji 덱 확장**: 현재 80 → top 200 가중 한자로 확장",
        "- **카드 메타**: 카드에 `한자_가중_빈도_%` 표시 (학습 가치 가시화)",
        "- **단어 학습 시**: 단어 안 한자 highlight + 가중 빈도 tooltip",
        "- **한자별 예시 단어**: `ja_kanji_words.json` 의 5예시 → 카드 키 추가",
        "",
        "## 6. 산출물",
        "",
        f"- `db/corpus/{OUT_CSV.name}` ({OUT_CSV.stat().st_size if OUT_CSV.exists() else 0} bytes)",
        f"- `db/corpus/{OUT_WORDS.name}` ({OUT_WORDS.stat().st_size if OUT_WORDS.exists() else 0} bytes)",
        f"- `db/corpus/{OUT_MD.name}` (이 파일)",
    ]
    OUT_MD.write_text("\n".join(lines), encoding="utf-8")
    print(f"  ✓ {OUT_MD.relative_to(DB.parent.parent)}")
    print()
    print(f"== Top 20 ==")
    for i, (k, freq) in enumerate(sorted_kanji[:20], 1):
        print(f"  {i:3d}. {k}  {freq / total_weighted * 100:6.3f}%  (used in {word_count[k]} words)")


if __name__ == "__main__":
    main()
