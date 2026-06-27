"""
단어·한자 절벽 구간별 분석 — 종합 리포트.

R1 (1-294)  : 회화 골격, 55% 누적 — 조사·종조사·기초어휘
R2 (295-437): 일상 핵심어, 60% 누적
R3 (438-998): 자주 쓰는 어휘, 70% 누적
R4 (999-2436): 폭넓은 어휘, 80% 누적
R5 (2437+)  : 확장 (분석 데이터에서는 R5 표기 안 됨, with_regions.csv R1-R4 만)

출력:
  db/corpus/ja_cliff_summary.md
"""
import csv
from collections import defaultdict
from pathlib import Path

DB = Path(__file__).resolve().parents[1] / "corpus"
OUT_MD = DB / "ja_cliff_summary.md"


def is_kanji(c: str) -> bool:
    o = ord(c)
    return (0x4E00 <= o <= 0x9FFF) or (0x3400 <= o <= 0x4DBF)


def main():
    # 1. 단어 region 별
    words_by_region: dict[str, list] = defaultdict(list)
    with open(DB / "lang_ja_with_regions.csv", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            words_by_region[r["region"]].append(
                (int(r["rank"]), r["word"], float(r["frequency"]))
            )

    regions = sorted(words_by_region.keys())
    total_freq_all = sum(w[2] for ws in words_by_region.values() for w in ws)

    lines = []
    lines.append("# ja 절벽 구간별 단어·한자 분석")
    lines.append("")
    lines.append(f"> 갱신: 자동 생성 (db/scripts/cliff_analysis.py)")
    lines.append(f"> 입력: lang_ja_with_regions.csv (chriskempson 자막 12,277편)")
    lines.append("")
    lines.append("## 1. 단어 — 절벽 구간별")
    lines.append("")
    lines.append("| region | 단어 수 | rank 범위 | 합계 빈도% | 누적 % |")
    lines.append("|---|---:|:---:|---:|---:|")

    cum = 0.0
    for reg in regions:
        ws = words_by_region[reg]
        if not ws:
            continue
        n = len(ws)
        ranks = [w[0] for w in ws]
        freq_sum = sum(w[2] for w in ws)
        cum += freq_sum
        lines.append(
            f"| **{reg}** | {n} | {min(ranks)}-{max(ranks)} | "
            f"{freq_sum * 100:.2f}% | **{cum * 100:.2f}%** |"
        )

    lines.append(f"| **합** | {sum(len(v) for v in words_by_region.values())} | 1-2,500 | "
                 f"{total_freq_all * 100:.2f}% | — |")
    lines.append("")

    # 2. 한자 region 별 — 단어 안 한자 추출
    kanji_by_region: dict[str, set] = defaultdict(set)
    kanji_freq_by_region: dict[str, dict] = defaultdict(lambda: defaultdict(float))
    word_count_kanji: dict[str, dict] = defaultdict(lambda: defaultdict(int))

    for reg, ws in words_by_region.items():
        for rank, word, freq in ws:
            for ch in word:
                if is_kanji(ch):
                    kanji_by_region[reg].add(ch)
                    kanji_freq_by_region[reg][ch] += freq
                    word_count_kanji[reg][ch] += 1

    lines.append("## 2. 한자 — 절벽 구간별 (단어 안에서 추출)")
    lines.append("")
    lines.append("| region | unique 한자 | 누적 unique | 신규 한자 |")
    lines.append("|---|---:|---:|---:|")

    cumulative = set()
    first_region: dict[str, str] = {}
    for reg in regions:
        new_k = kanji_by_region[reg] - cumulative
        cumulative |= kanji_by_region[reg]
        for k in new_k:
            first_region[k] = reg
        lines.append(
            f"| **{reg}** | {len(kanji_by_region[reg])} | {len(cumulative)} | {len(new_k)} |"
        )
    lines.append("")

    # 3. 각 region 신규 한자 TOP 20
    lines.append("## 3. 각 region 의 '신규' 한자 (이전 region 에 없던 한자)")
    lines.append("")
    for reg in regions:
        new_k_list = [k for k in kanji_by_region[reg] if first_region.get(k) == reg]
        # 가중 빈도 순
        new_k_sorted = sorted(
            new_k_list, key=lambda k: -kanji_freq_by_region[reg][k]
        )
        if not new_k_sorted:
            continue
        lines.append(f"### {reg} — 신규 {len(new_k_sorted)} 자")
        lines.append("")
        lines.append("| rank | 한자 | weighted % (이 region 안) | 사용 단어 수 |")
        lines.append("|---:|:---:|---:|---:|")
        for i, k in enumerate(new_k_sorted[:20], 1):
            lines.append(
                f"| {i} | {k} | "
                f"{kanji_freq_by_region[reg][k] * 100:.3f}% | "
                f"{word_count_kanji[reg][k]} |"
            )
        if len(new_k_sorted) > 20:
            lines.append(f"_…외 {len(new_k_sorted) - 20} 자_")
        lines.append("")

    # 4. R1 안 한자 가중 TOP 30
    lines.append("## 4. R1 한자 가중 빈도 TOP 30 (학습 우선순위)")
    lines.append("")
    lines.append("R1 (1-294 단어) 안에서 등장하는 한자 = 가장 자주 노출.")
    lines.append("")
    lines.append("| # | 한자 | weighted % | 사용 단어 수 |")
    lines.append("|---:|:---:|---:|---:|")
    r1_top = sorted(kanji_freq_by_region["R1"].items(), key=lambda x: -x[1])[:30]
    for i, (k, f) in enumerate(r1_top, 1):
        lines.append(f"| {i} | {k} | {f * 100:.3f}% | {word_count_kanji['R1'][k]} |")
    lines.append("")

    # 5. hanja_crossref 80자 cross-check (region 별)
    import json
    cross = json.loads((DB / "hanja_crossref.json").read_text(encoding="utf-8"))
    cross_ja = {e["ja_kanji"] for e in cross["entries"]}

    lines.append("## 5. hanja_crossref 80자 ↔ 절벽 region cross-check")
    lines.append("")
    lines.append("우리가 가지고 있는 80자 4-way cross-ref 한자가 어느 region 에 분포하는지.")
    lines.append("")
    lines.append("| region | hanja_crossref 80 중 포함 | 비율 |")
    lines.append("|---|---:|---:|")
    for reg in regions:
        overlap = cross_ja & kanji_by_region[reg]
        lines.append(f"| **{reg}** | {len(overlap)} / 80 | {len(overlap)/80*100:.0f}% |")
    not_in_any = cross_ja - set().union(*kanji_by_region.values())
    lines.append(f"| _빈도 분석 외_ | {len(not_in_any)} / 80 | {len(not_in_any)/80*100:.0f}% |")
    if not_in_any:
        lines.append("")
        lines.append(f"_분석 외 한자_: `{', '.join(sorted(not_in_any))}`")
    lines.append("")

    # 6. 학습 우선순위 권고
    lines.append("## 6. 학습 우선순위 권고 (한자 덱 확장)")
    lines.append("")
    lines.append("현재 한자 덱 = `hanja_crossref.json` 의 80자 (수동 큐레이션).")
    lines.append("DB 분석 결과 R1 안에만 unique 한자가 많으니 80자 → 130~200자 확장 고려.")
    lines.append("")
    r1_total = len(kanji_by_region["R1"])
    lines.append(f"- **R1 unique 한자 = {r1_total}자** (회화 골격 ~294 단어 안 한자)")
    lines.append(f"- R1+R2 누적 = {len(kanji_by_region['R1'] | kanji_by_region['R2'])}자 (일상 어휘)")
    cum_all = kanji_by_region['R1'] | kanji_by_region['R2'] | kanji_by_region['R3']
    lines.append(f"- R1+R2+R3 누적 = {len(cum_all)}자 (자주 쓰는 어휘 70% 누적)")
    lines.append("")
    lines.append("→ 단계적 확장: 80자 (현재) → R1 전체 → R1+R2 → R1+R2+R3 (≈800-1000자).")

    OUT_MD.write_text("\n".join(lines), encoding="utf-8")
    print(f"  ✓ {OUT_MD.relative_to(DB.parent.parent)}")
    print()
    # Console preview
    print("\n".join(lines[:50]))


if __name__ == "__main__":
    main()
