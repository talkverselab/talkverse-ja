"""
[작업 A] 17개 언어 단어 데이터 준비 (나중 차트/표용 raw data).
각 언어 CSV에 region 컬럼 추가 + 17개 합산 region count 테이블.
"""
import csv
from pathlib import Path

DATA = Path("D:/OneDrive/BOOKS/_assets/data")
RAW_OPUS = Path(r"D:\OneDrive\DATA_Raw\opus_opensubtitles")
RAW_IMDB = Path(r"D:\OneDrive\DATA_Raw\imdb")
RAW_EVB = Path(r"D:\OneDrive\DATA_Raw\evbcorpus")
RAW_LEIPZIG = Path(r"D:\OneDrive\DATA_Raw\leipzig")

OUT = DATA / "cliff_region_data"
OUT.mkdir(exist_ok=True)

LANGS17 = [
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


def find_ms(rows, pct):
    for r in rows:
        if r["cum"] >= pct:
            return r["rank"]
    return None


def assign_region(rk, b):
    if b["R1"] and rk <= b["R1"]: return "R1"
    if b["R2"] and rk <= b["R2"]: return "R2"
    if b["R3"] and rk <= b["R3"]: return "R3"
    if b["R4"] and rk <= b["R4"]: return "R4"
    return "R5"


# 각 언어 별 enrich + region count
summary_rows = []
for code, name, family, fname in LANGS17:
    p = RAW_OPUS / fname
    rows = []
    with open(p, encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            try:
                rows.append({
                    "rank": int(r["rank"]),
                    "word": r["word"],
                    "freq": float(r["frequency"]),
                    "cum": float(r["cum_pct"]),
                })
            except (KeyError, ValueError):
                continue

    max_cum = rows[-1]["cum"]
    # 각 언어 자체 max를 80%로 매핑
    boundaries = {}
    for label, target in [("R1", 55), ("R2", 60), ("R3", 70), ("R4", 80)]:
        scaled = max_cum * target / 80
        boundaries[label] = find_ms(rows, scaled)

    # enriched CSV 저장
    out_csv = OUT / f"lang_{code}_with_regions.csv"
    with open(out_csv, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f)
        w.writerow(["rank", "word", "frequency", "cum_pct", "region"])
        region_count = {"R1": 0, "R2": 0, "R3": 0, "R4": 0, "R5": 0}
        for r in rows:
            reg = assign_region(r["rank"], boundaries)
            region_count[reg] += 1
            w.writerow([r["rank"], r["word"],
                        f"{r['freq']:.8f}", f"{r['cum']:.4f}", reg])

    summary_rows.append({
        "code": code, "name": name, "family": family,
        "total": len(rows), "max_cum": max_cum,
        **{f"r{i}_size": region_count[f"R{i}"] for i in range(1, 6)},
        "r1_boundary": boundaries["R1"], "r2_boundary": boundaries["R2"],
        "r3_boundary": boundaries["R3"], "r4_boundary": boundaries["R4"],
    })
    print(f"  ✓ {code} {name}: R1={region_count['R1']}, R2={region_count['R2']}, R3={region_count['R3']}, R4={region_count['R4']}, R5={region_count['R5']}")

# 합산 CSV
sum_csv = OUT / "all17_region_counts.csv"
with open(sum_csv, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.DictWriter(f, fieldnames=list(summary_rows[0].keys()))
    w.writeheader()
    w.writerows(summary_rows)

print(f"\n저장: {OUT}")
print(f"  - lang_*_with_regions.csv (17개)")
print(f"  - all17_region_counts.csv (합산 테이블)")

# Mongolian (1순위 17 언어 외) 도 하나 추가
mn_rows = []
with open(DATA / "lang_mn_top1851.csv", encoding="utf-8-sig") as f:
    for r in csv.DictReader(f):
        try:
            mn_rows.append({"rank": int(r["rank"]), "word": r["word"],
                            "freq": float(r["frequency"]), "cum": float(r["cum_pct"])})
        except (KeyError, ValueError):
            continue
mn_max = mn_rows[-1]["cum"]
mn_b = {}
for label, target in [("R1", 55), ("R2", 60), ("R3", 70), ("R4", 80)]:
    mn_b[label] = find_ms(mn_rows, mn_max * target / 80)

out_mn = OUT / "lang_mn_with_regions.csv"
with open(out_mn, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f)
    w.writerow(["rank", "word", "frequency", "cum_pct", "region"])
    for r in mn_rows:
        reg = assign_region(r["rank"], mn_b)
        w.writerow([r["rank"], r["word"], f"{r['freq']:.8f}", f"{r['cum']:.4f}", reg])
print(f"  + lang_mn_with_regions.csv (보너스 — 절벽 데이터)")
