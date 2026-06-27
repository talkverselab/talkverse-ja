"""
16개 언어 절벽 구간 자동 탐지 + 차트 일괄 생성

각 언어별로:
- 누적 커버리지 마일스톤 기반 4구간 탐지 (55% / 60% / 70% / 80%)
- 차트 (PNG/SVG)
- 통계 CSV 행 (각 구간 단어 수, 추가 커버리지)

출력:
- _assets/charts/cliff_{code}.png/.svg (16개)
- _assets/data/multilang_cliff_summary.csv
"""
import csv
import sys
import io
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

import matplotlib
import matplotlib.pyplot as plt

for f in ["Pretendard", "Malgun Gothic", "NanumGothic", "Yu Gothic", "Meiryo"]:
    try:
        matplotlib.rcParams["font.family"] = f
        break
    except Exception:
        continue
matplotlib.rcParams["axes.unicode_minus"] = False

DATA = Path(__file__).parent.parent / "data"
CHARTS = Path(__file__).parent

LANGS = [
    ("Korean", "ko"),
    ("English", "en"),
    ("Chinese", "zh"),
    ("Hindi", "hi"),
    ("Spanish", "es"),
    ("Arabic", "ar"),
    ("French", "fr"),
    ("Portuguese", "pt"),
    ("Indonesian", "id"),
    ("Russian", "ru"),
    ("German", "de"),
    ("Japanese", "ja"),
    ("Vietnamese", "vi"),
    ("Turkish", "tr"),
    ("Persian", "fa"),
    ("Italian", "it"),
    # 추가 5개 (Polish/Hungarian는 wordfreq, Mongolian/Burmese는 Leipzig)
    ("Polish", "pl"),
    ("Hungarian", "hu"),
    ("Mongolian", "mn"),
    ("Burmese", "my"),
]


def find_csv(code: str) -> Path | None:
    matches = list(DATA.glob(f"lang_{code}_top*.csv"))
    return matches[0] if matches else None


def find_rank_at(records, target_pct):
    for r in records:
        if r["cum_pct"] >= target_pct:
            return r["rank"]
    return records[-1]["rank"]


summary_rows = []
for name, code in LANGS:
    csv_path = find_csv(code)
    if not csv_path:
        print(f"  [SKIP] {name}: CSV 없음")
        continue

    records = []
    with open(csv_path, encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            records.append({
                "rank": int(row["rank"]),
                "word": row["word"],
                "cum_pct": float(row["cum_pct"]),
            })

    n = len(records)
    full_cov = records[-1]["cum_pct"]

    # 마일스톤 기반 절벽 (55% / 60% / 70% / 80%)
    milestones = [55, 60, 70, 80]
    boundaries = []
    for m in milestones:
        if full_cov >= m:
            boundaries.append(find_rank_at(records, m))
        else:
            boundaries.append(n)

    r1, r2, r3, r4 = boundaries
    summary_rows.append({
        "language": name,
        "code": code,
        "n": n,
        "full_cov": round(full_cov, 1),
        "R1_end": r1,
        "R2_end": r2,
        "R3_end": r3,
        "R4_end": r4,
        "R1_words": r1,
        "R2_words": r2 - r1,
        "R3_words": r3 - r2,
        "R4_words": r4 - r3,
    })

    # 차트
    fig, ax = plt.subplots(figsize=(8, 5))
    xs = [r["rank"] for r in records]
    ys = [r["cum_pct"] for r in records]
    ax.plot(xs, ys, color="#2EA9DF", linewidth=2)

    colors_v = ["#E58E26", "#27AE60", "#9B59B6", "#7F8C8D"]
    for b, col, m in zip(boundaries, colors_v, milestones):
        ax.axvline(b, color=col, linestyle="--", alpha=0.5)
        ax.text(b, 5, f"~{m}%\n({b})", fontsize=8, color=col, ha="center")
        if records[b - 1]["cum_pct"] >= m:
            ax.plot(b, records[b - 1]["cum_pct"], "o", color="#222", markersize=5)

    ax.set_xlabel("Word Rank")
    ax.set_ylabel("Cumulative Coverage (%)")
    ax.set_title(f"{name} ({code}) - Top {n} Cumulative Coverage")
    ax.set_xlim(0, n)
    ax.set_ylim(0, 100)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(CHARTS / f"cliff_{code}.png", dpi=140)
    plt.savefig(CHARTS / f"cliff_{code}.svg")
    plt.close()
    print(f"  [OK]   {name:<12s} ({code}): R1={r1} R2={r2} R3={r3} R4={r4} (전체 {full_cov:.1f}%)")

# 요약 CSV
summary_csv = DATA / "multilang_cliff_summary.csv"
with open(summary_csv, "w", encoding="utf-8-sig", newline="") as f:
    if summary_rows:
        w = csv.DictWriter(f, fieldnames=list(summary_rows[0].keys()))
        w.writeheader()
        w.writerows(summary_rows)
print(f"\n요약: {summary_csv}")
print(f"생성: {len(summary_rows)} 언어")
