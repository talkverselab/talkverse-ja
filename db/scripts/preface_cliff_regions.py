"""
서문 4 - 절벽 구간별 분석

영어 상위 3000단어 실데이터 분석:
- 자동 절벽 구간 탐지 (slope 변화 기반)
- 기능어/내용어 분류
- 누적 커버리지 차트
- 구간별 통계 출력 (실제 단어 수, 커버리지, 기능어 비율)
"""
import csv
from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt

# 한글 폰트 (Pretendard 시스템 설치됨)
for f in ["Pretendard", "Malgun Gothic", "NanumGothic"]:
    try:
        matplotlib.rcParams["font.family"] = f
        break
    except Exception:
        continue
matplotlib.rcParams["axes.unicode_minus"] = False

DATA = Path(__file__).parent.parent / "data" / "en_top3000.csv"
OUT = Path(__file__).parent

# 영어 기능어 (function words) 리스트
# 관사, 대명사, 전치사, 접속사, 조동사, 부정어, 존재사 등
FUNCTION_WORDS = {
    # Articles
    "a", "an", "the",
    # Personal pronouns + possessives + reflexives
    "i", "me", "my", "mine", "myself",
    "we", "us", "our", "ours", "ourselves",
    "you", "your", "yours", "yourself", "yourselves",
    "he", "him", "his", "himself",
    "she", "her", "hers", "herself",
    "it", "its", "itself",
    "they", "them", "their", "theirs", "themselves",
    # Demonstratives + interrogatives + relatives
    "this", "that", "these", "those",
    "who", "whom", "whose", "which", "what",
    "where", "when", "why", "how",
    # Prepositions
    "of", "in", "on", "at", "to", "from", "with", "about",
    "against", "between", "into", "through", "during",
    "before", "after", "above", "below", "up", "down",
    "over", "under", "across", "behind", "beyond",
    "by", "for", "as", "off", "out", "around", "near",
    "without", "within", "upon", "since", "until",
    "via", "per",
    # Conjunctions
    "and", "but", "or", "so", "yet", "nor", "for",
    "because", "although", "though", "if", "unless",
    "while", "whereas", "than", "whether",
    # Auxiliary verbs (forms of be, have, do, modals)
    "be", "am", "is", "are", "was", "were", "been", "being",
    "have", "has", "had", "having",
    "do", "does", "did", "doing", "done",
    "will", "would", "shall", "should",
    "can", "could", "may", "might", "must",
    "ought", "need", "dare",
    # Negations
    "not", "no", "never", "nothing", "nobody", "nowhere", "none",
    # Existential / determiners / quantifiers (often grammatical)
    "there", "here",
    "some", "any", "all", "every", "each", "both",
    "many", "much", "few", "little", "more", "most",
    "less", "least", "several", "other", "another",
    # Common contractions
    "n't", "'s", "'re", "'ve", "'ll", "'d", "'m",
    "don't", "doesn't", "didn't", "won't", "wouldn't",
    "can't", "couldn't", "shouldn't", "isn't", "aren't",
    "wasn't", "weren't", "haven't", "hasn't", "hadn't",
    "i'm", "you're", "he's", "she's", "it's", "we're",
    "they're", "i've", "you've", "we've", "they've",
    "i'll", "you'll", "he'll", "she'll", "we'll", "they'll",
    "i'd", "you'd", "he'd", "she'd", "we'd", "they'd",
    # 1-2 syllable that often play function role
    "yes", "yeah", "ok", "okay",
}


def is_function(word: str) -> bool:
    return word.lower() in FUNCTION_WORDS


# 1. 데이터 로드
records = []
with open(DATA, encoding="utf-8") as f:
    for row in csv.DictReader(f):
        records.append({
            "rank": int(row["rank"]),
            "word": row["word"],
            "frequency": float(row["frequency"]),
            "cum_pct": float(row["cum_pct"]),
            "is_function": is_function(row["word"]),
        })

# 2. 자동 구간 탐지
# 누적 커버리지의 곡선 기울기가 자연스럽게 꺾이는 지점 찾기
# 윈도우 50으로 평균 단어당 기여도(slope) 계산
slopes = []
WIN = 50
for i in range(WIN, len(records)):
    delta = records[i]["cum_pct"] - records[i - WIN]["cum_pct"]
    slopes.append(delta / WIN)  # 단어당 평균 기여 %

# 기능어 밀집 구간 탐지: 기능어 비율이 50% 아래로 떨어지는 첫 지점
function_count = 0
region1_end = 100  # default
for i, r in enumerate(records, start=1):
    if r["is_function"]:
        function_count += 1
    # 기능어 비율 (cumulative)
    fn_ratio = function_count / i
    if i >= 50 and fn_ratio < 0.50:
        region1_end = i - 1
        break

# 다음 절벽: 누적 커버리지 마일스톤 기반
# 60% / 70% / 80% 지점
def find_rank_at(target_pct):
    for r in records:
        if r["cum_pct"] >= target_pct:
            return r["rank"]
    return len(records)

region2_end = find_rank_at(60)
region3_end = find_rank_at(70)
region4_end = find_rank_at(80)
if region4_end > 3000:
    region4_end = 3000

# 3. 구간별 통계
def region_stats(start, end):
    subset = [r for r in records if start <= r["rank"] <= end]
    n = len(subset)
    if n == 0:
        return None
    fn = sum(1 for r in subset if r["is_function"])
    cov_start = records[start - 1]["cum_pct"] if start > 1 else 0
    cov_end = subset[-1]["cum_pct"]
    return {
        "range": f"{start}-{end}",
        "count": n,
        "fn_ratio": fn / n * 100,
        "coverage_added": cov_end - cov_start,
        "cum_at_end": cov_end,
        "samples_function": [r["word"] for r in subset if r["is_function"]][:8],
        "samples_content": [r["word"] for r in subset if not r["is_function"]][:8],
    }

regions = [
    (1, region1_end, "기능어 구간"),
    (region1_end + 1, region2_end, "핵심 내용어 구간"),
    (region2_end + 1, region3_end, "일상 어휘 구간"),
    (region3_end + 1, region4_end, "확장 어휘 구간"),
]

print("=== 자동 탐지된 절벽 구간 (영어 3000 실데이터) ===")
for start, end, name in regions:
    s = region_stats(start, end)
    if s:
        print(f"\n[{name}] rank {s['range']}")
        print(f"  단어 수: {s['count']}")
        print(f"  추가 커버리지: {s['coverage_added']:.1f}% (누적 {s['cum_at_end']:.1f}%)")
        print(f"  기능어 비율: {s['fn_ratio']:.0f}%")
        print(f"  기능어 샘플: {', '.join(s['samples_function'])}")
        print(f"  내용어 샘플: {', '.join(s['samples_content'])}")

# 4. 차트 1: 누적 커버리지 곡선 + 구간 표시
fig, ax = plt.subplots(figsize=(9, 5.5))

ranks = [r["rank"] for r in records]
cums = [r["cum_pct"] for r in records]
ax.plot(ranks, cums, color="#2EA9DF", linewidth=2)

# 구간 경계 수직선
boundaries = [region1_end, region2_end, region3_end, region4_end]
labels = [f"R1\n({region1_end})",
          f"R2\n({region2_end})",
          f"R3\n({region3_end})",
          f"R4\n({region4_end})"]
colors_v = ["#E58E26", "#27AE60", "#9B59B6", "#7F8C8D"]
for b, lbl, col in zip(boundaries, labels, colors_v):
    ax.axvline(b, color=col, linestyle="--", alpha=0.6)
    ax.text(b, 5, lbl, fontsize=9, color=col, ha="center")

# 누적 % 마킹
for b in boundaries:
    pct = records[b - 1]["cum_pct"]
    ax.plot(b, pct, "o", color="#222", markersize=6)
    ax.annotate(f"{pct:.0f}%", (b, pct),
                textcoords="offset points", xytext=(8, 8), fontsize=9)

ax.set_xlabel("Word Rank")
ax.set_ylabel("Cumulative Coverage (%)")
ax.set_title("English Top 3000: Cumulative Coverage with Cliff Regions")
ax.set_xlim(0, 3000)
ax.set_ylim(0, 100)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(OUT / "preface_cliff_cumulative.svg")
plt.savefig(OUT / "preface_cliff_cumulative.png", dpi=150)

# 5. 차트 2: 구간별 100단어당 추가 커버리지 (막대)
fig2, ax2 = plt.subplots(figsize=(9, 5))

bin_size = 100
bins = []
contributions = []
for start in range(1, 3001, bin_size):
    end = min(start + bin_size - 1, 3000)
    cov_start = records[start - 1]["cum_pct"] if start > 1 else 0
    cov_end = records[end - 1]["cum_pct"]
    bins.append(start)
    contributions.append(cov_end - cov_start)

ax2.bar(bins, contributions, width=bin_size * 0.8, color="#2EA9DF", alpha=0.7)
ax2.set_xlabel("Word Rank Bin (100 words each)")
ax2.set_ylabel("Coverage Added (%)")
ax2.set_title("English Top 3000: Coverage Added per 100-Word Bin")
ax2.grid(True, alpha=0.3, axis="y")
ax2.set_xlim(-50, 3050)

plt.tight_layout()
plt.savefig(OUT / "preface_cliff_perbin.svg")
plt.savefig(OUT / "preface_cliff_perbin.png", dpi=150)

print(f"\nSaved charts:")
print(f"  {OUT / 'preface_cliff_cumulative.png'}")
print(f"  {OUT / 'preface_cliff_perbin.png'}")
