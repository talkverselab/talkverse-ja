"""
17개 1순위 언어 절벽구간 일괄 분석.

언어 분류 (어족별):
- Indo-European Germanic: en, de
- Indo-European Romance:  es, pt, fr, it
- Indo-European Slavic:   ru
- Indo-European Indo-Iranian: hi, fa
- Sino-Tibetan: zh
- Afro-Asiatic: ar
- Austronesian: id
- Austroasiatic: vi
- Tai-Kadai: th
- Turkic: tr
- Japonic: ja
- Koreanic: ko

각 언어 자체 곡선에서 누적 마일스톤(50/55/60/65/70/75/80%) 도달 지점 산출.
"""
import csv
from pathlib import Path

DATA = Path("D:/OneDrive/BOOKS/_assets/data")

RAW_OPUS = Path(r"D:\OneDrive\DATA_Raw\opus_공개 말뭉치")
RAW_IMDB = Path(r"D:\OneDrive\DATA_Raw\imdb")
RAW_EVB = Path(r"D:\OneDrive\DATA_Raw\evbcorpus")
RAW_LEIPZIG = Path(r"D:\OneDrive\DATA_Raw\leipzig")

LANGS17 = [
    # (코드, 한국어명, 어족, 데이터파일)
    ("en", "영어",     "Indo-Eur Germanic",    "lang_en_top3000.csv"),
    ("de", "독일어",   "Indo-Eur Germanic",    "lang_de_top2500.csv"),
    ("es", "스페인어", "Indo-Eur Romance",     "lang_es_top2500.csv"),
    ("pt", "포르투갈", "Indo-Eur Romance",     "lang_pt_top2500.csv"),
    ("fr", "프랑스어", "Indo-Eur Romance",     "lang_fr_top2500.csv"),
    ("it", "이탈리아", "Indo-Eur Romance",     "lang_it_top2500.csv"),
    ("ru", "러시아어", "Indo-Eur Slavic",      "lang_ru_top2500.csv"),
    ("hi", "힌디어",   "Indo-Eur Indo-Iran",   "lang_hi_top2500.csv"),
    ("fa", "페르시아", "Indo-Eur Indo-Iran",   "lang_fa_top2500.csv"),
    ("zh", "중국어",   "Sino-Tibetan",         "lang_zh_top2500.csv"),
    ("ar", "아랍어",   "Afro-Asiatic",         "lang_ar_top2500.csv"),
    ("id", "인도네시", "Austronesian",         "lang_id_top2500.csv"),
    ("vi", "베트남어", "Austroasiatic",        "lang_vi_top2500.csv"),
    ("th", "태국어",   "Tai-Kadai",            "lang_th_top2500.csv"),
    ("tr", "터키어",   "Turkic",               "lang_tr_top2500.csv"),
    ("ja", "일본어",   "Japonic",              "lang_ja_top2500.csv"),
    ("ko", "한국어",   "Koreanic",             "lang_ko_top2500.csv"),
]

def load(fname):
    rows = []
    p = RAW_OPUS / fname
    if not p.exists():
        return None
    with open(p, encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for r in reader:
            try:
                rows.append({
                    "rank": int(r["rank"]),
                    "word": r["word"],
                    "freq": float(r["frequency"]),
                    "cum": float(r["cum_pct"]),
                })
            except (KeyError, ValueError):
                continue
    return rows


def find_ms(rows, pct):
    for r in rows:
        if r["cum"] >= pct:
            return r["rank"]
    return None


def compute_stats(rows):
    """각 언어의 마일스톤 + 절벽 R1-R4 산출"""
    if not rows:
        return None
    max_cum = rows[-1]["cum"]
    stats = {
        "total": len(rows),
        "top1": rows[0],
        "top10_cum": rows[min(9, len(rows)-1)]["cum"],
        "top100_cum": rows[min(99, len(rows)-1)]["cum"],
        "top500_cum": rows[min(499, len(rows)-1)]["cum"],
        "top1000_cum": rows[min(999, len(rows)-1)]["cum"],
        "top2500_cum": rows[min(2499, len(rows)-1)]["cum"],
        "max_cum": max_cum,
        "milestones": {},
        "r_boundaries": {},
    }
    for pct in [50, 55, 60, 65, 70, 75, 80, 85, 90]:
        stats["milestones"][pct] = find_ms(rows, pct)

    # R1-R4 정의: 각 언어 자체 max를 기준 80%로 매핑 비례 마일스톤
    # 즉 R1=max*55/80, R2=max*60/80, R3=max*70/80, R4=max*80/80
    for r_label, target in [("R1", 55), ("R2", 60), ("R3", 70), ("R4", 80)]:
        scaled = max_cum * target / 80
        rk = find_ms(rows, scaled)
        stats["r_boundaries"][r_label] = (rk, scaled)
    return stats


# ─── 일괄 분석 ──────────────────────────────────────
all_results = {}
for code, name, family, fname in LANGS17:
    rows = load(fname)
    stats = compute_stats(rows) if rows else None
    all_results[code] = {
        "name": name, "family": family, "rows": rows, "stats": stats,
    }
    if stats is None:
        print(f"  [누락] {code} {name}: {fname}")
    else:
        print(f"  ✓ {code} {name}: {stats['total']:,}어, max={stats['max_cum']:.1f}%")

# ─── 표 1: 절대 마일스톤 도달 (자체 곡선) ─────────────
print()
print("=" * 110)
print("  17개 언어 자체 곡선 — 누적 마일스톤 도달 단어수 (각 언어 자체 코퍼스 기준)")
print("=" * 110)
hdr = f"  {'코드':<4}{'언어':<10}{'어족':<22}{'총단어':>7}{'top10':>8}{'top100':>9}{'top500':>9}{'top1k':>8}{'max%':>7}"
print(hdr)
print("  " + "-" * 108)
for code, name, family, fname in LANGS17:
    r = all_results[code]
    if not r["stats"]:
        continue
    s = r["stats"]
    print(f"  {code:<4}{name:<10}{family:<22}{s['total']:>7,}{s['top10_cum']:>7.1f}%{s['top100_cum']:>8.1f}%{s['top500_cum']:>8.1f}%{s['top1000_cum']:>7.1f}%{s['max_cum']:>6.1f}%")

# ─── 표 2: 마일스톤별 도달 단어 수 ────────────────────
print()
print("=" * 110)
print("  17개 언어 — 누적 마일스톤별 도달 단어수")
print("=" * 110)
hdr = f"  {'코드':<4}{'언어':<10}{'50%':>8}{'55%':>8}{'60%':>8}{'65%':>8}{'70%':>8}{'75%':>8}{'80%':>8}"
print(hdr)
print("  " + "-" * 80)
for code, name, family, fname in LANGS17:
    r = all_results[code]
    if not r["stats"]:
        continue
    m = r["stats"]["milestones"]
    cells = []
    for pct in [50, 55, 60, 65, 70, 75, 80]:
        v = m[pct]
        cells.append(f"{v:>7}" if v else f"{'미도달':>7}")
    print(f"  {code:<4}{name:<10}" + "".join(f"{c:>8}" for c in cells))

# ─── 표 3: 비례 R1-R4 절벽 ────────────────────────────
print()
print("=" * 110)
print("  17개 언어 — 비례 R1-R4 절벽구간 (각 언어 max를 80%로 매핑)")
print("=" * 110)
hdr = f"  {'코드':<4}{'언어':<10}{'R1 (~55%)':>14}{'R2 (~60%)':>14}{'R3 (~70%)':>14}{'R4 (~80%)':>14}{'max%':>7}"
print(hdr)
print("  " + "-" * 95)
for code, name, family, fname in LANGS17:
    r = all_results[code]
    if not r["stats"]:
        continue
    rb = r["stats"]["r_boundaries"]
    cells = []
    for label in ["R1", "R2", "R3", "R4"]:
        rk, target = rb[label]
        cells.append(f"{rk if rk else '?':>9} ({target:.0f}%)")
    print(f"  {code:<4}{name:<10}" + "".join(f"  {c:>13}" for c in cells) + f"  {r['stats']['max_cum']:>5.1f}%")

# ─── 표 4: R1 사이즈 비교 ─────────────────────────────
print()
print("=" * 110)
print("  17개 언어 — R1 사이즈 (회화 핵심 어휘) 정렬")
print("=" * 110)
print(f"  {'순위':<4}  {'코드':<4}{'언어':<10}{'어족':<22}{'R1 사이즈':>10}{'전체대비':>10}{'top1단어':<12}")
print("  " + "-" * 90)
sorted_by_r1 = []
for code, name, family, fname in LANGS17:
    r = all_results[code]
    if not r["stats"]:
        continue
    r1_rk = r["stats"]["r_boundaries"]["R1"][0]
    if r1_rk:
        sorted_by_r1.append((code, name, family, r1_rk, r["stats"]["total"],
                             r["rows"][0]["word"]))
sorted_by_r1.sort(key=lambda x: x[3])
for i, (code, name, family, r1, total, top1) in enumerate(sorted_by_r1, start=1):
    print(f"  {i:>3}.  {code:<4}{name:<10}{family:<22}{r1:>10}{r1/total*100:>9.1f}%  {top1:<12}")

# ─── 표 5: Top 10 단어 미리보기 ────────────────────
print()
print("=" * 110)
print("  17개 언어 — Top 10 단어 미리보기")
print("=" * 110)
for code, name, family, fname in LANGS17:
    r = all_results[code]
    if not r["stats"]:
        continue
    rows = r["rows"]
    top10 = ", ".join(f"{rows[i]['word']}({rows[i]['cum']:.1f})" for i in range(min(10, len(rows))))
    print(f"  {code} {name}: {top10}")

# ─── MD 보고서 저장 ────────────────────────────────
out = DATA / "all17_cliff_summary.md"
with open(out, "w", encoding="utf-8") as f:
    f.write("# 17개 언어 절벽구간 일괄 분석\n\n")
    f.write("**기준**: 각 언어 자체 코퍼스의 누적 마일스톤. 데이터 출처는 언어별로 상이함 (SUBTLEX/OPUS/wordfreq).\n\n")

    f.write("## 표 1 — 코퍼스 분포 요약\n\n")
    f.write("| 코드 | 언어 | 어족 | 총단어 | top10 누적 | top100 | top500 | top1000 | max% |\n")
    f.write("|---|---|---|---:|---:|---:|---:|---:|---:|\n")
    for code, name, family, fname in LANGS17:
        r = all_results[code]
        if not r["stats"]:
            f.write(f"| {code} | {name} | {family} | (누락) | | | | | |\n")
            continue
        s = r["stats"]
        f.write(f"| {code} | {name} | {family} | {s['total']:,} | {s['top10_cum']:.1f}% | {s['top100_cum']:.1f}% | {s['top500_cum']:.1f}% | {s['top1000_cum']:.1f}% | {s['max_cum']:.1f}% |\n")

    f.write("\n## 표 2 — 누적 마일스톤별 도달 단어수\n\n")
    f.write("| 코드 | 언어 | 50% | 55% | 60% | 65% | 70% | 75% | 80% |\n")
    f.write("|---|---|---:|---:|---:|---:|---:|---:|---:|\n")
    for code, name, family, fname in LANGS17:
        r = all_results[code]
        if not r["stats"]:
            continue
        m = r["stats"]["milestones"]
        cells = " | ".join(str(m[pct]) if m[pct] else "미도달" for pct in [50, 55, 60, 65, 70, 75, 80])
        f.write(f"| {code} | {name} | {cells} |\n")

    f.write("\n## 표 3 — 비례 R1-R4 절벽 (자체 max를 80%로 매핑)\n\n")
    f.write("| 코드 | 언어 | R1 (≈55%) | R2 (≈60%) | R3 (≈70%) | R4 (≈80%) | max% |\n")
    f.write("|---|---|---:|---:|---:|---:|---:|\n")
    for code, name, family, fname in LANGS17:
        r = all_results[code]
        if not r["stats"]:
            continue
        rb = r["stats"]["r_boundaries"]
        cells = " | ".join(f"{rb[lbl][0] if rb[lbl][0] else '?'}" for lbl in ["R1","R2","R3","R4"])
        f.write(f"| {code} | {name} | {cells} | {r['stats']['max_cum']:.1f}% |\n")

    f.write("\n## 표 4 — R1 사이즈 정렬 (회화 핵심 어휘 적은 순)\n\n")
    f.write("| 순위 | 코드 | 언어 | 어족 | R1 단어수 | 전체대비% | top1 단어 |\n")
    f.write("|---:|---|---|---|---:|---:|---|\n")
    for i, (code, name, family, r1, total, top1) in enumerate(sorted_by_r1, start=1):
        f.write(f"| {i} | {code} | {name} | {family} | {r1} | {r1/total*100:.1f}% | {top1} |\n")

    f.write("\n## 표 5 — 각 언어 Top 10 단어\n\n")
    for code, name, family, fname in LANGS17:
        r = all_results[code]
        if not r["stats"]:
            continue
        rows = r["rows"]
        top10 = ", ".join(f"`{rows[i]['word']}`({rows[i]['cum']:.1f}%)" for i in range(min(10, len(rows))))
        f.write(f"- **{code} {name}**: {top10}\n")

    f.write("\n## 데이터 출처별 분류\n\n")
    f.write("| 출처 종류 | 언어 |\n|---|---|\n")
    f.write("| SUBTLEX (학술 자막 빈도) | en, de, es |\n")
    f.write("| OPUS-공개 말뭉치 직접처리 | ko, ja, hi |\n")
    f.write("| wordfreq 혼합 코퍼스 | fr, it, ru, pt, fa, ar, id, vi, tr, hu, pl |\n")
    f.write("| 자체처리 (분절기 적용) | th (pythainlp), zh (?) |\n")
    f.write("\n**주의**: 데이터 출처가 다르므로 직접 비교는 제한적. 형태소 분리 후 재처리하면 더 공정.\n")

print(f"\n저장: {out}")
