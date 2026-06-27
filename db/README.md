# db/ — 분석 자료 / 옛 데이터 보존

> 옛 자료의 카피본 + 분석 스크립트. 앱 (`app/`) 에서 직접 참조 X (필요 시 `content/` 로 가공해서 옮김).

## 구조

```
db/
├── corpus/         ← 빈도·라벨 데이터
│   ├── lang_ja_top2500.csv             (chriskempson 자막 정본)
│   ├── lang_ja_native_top80.csv        (회화 톤 핵심)
│   ├── lang_ja_wordfreq_top2500.csv    (wordfreq 백업)
│   ├── lang_ja_with_regions.csv        (R1-R4 라벨)
│   ├── hanja_crossref.json             (한자 80 4-way)
│   └── jp_l1_kanji_70.json             (코어 70)
│
├── scripts/        ← 분석·합성 .py
│   ├── jmultiwoz_freq.py               (JMultiWOZ 다중턴 빈도 추출)
│   ├── realpersonachat_freq.py         (RealPersonaChat persona 풀)
│   ├── kanji_coverage.py               (L1 작성 후 한자 70 등재 검증)
│   └── generate_annotations.py         (빨간펜 자동 추출, 옛 vi 스크립트 ja 포팅)
│
├── notes/          ← 옛 메모 카피본 (read-only reference)
│   ├── overview.md                     (룸 사령탑)
│   ├── content-spec.md                 (L1/L2/L3 schema)
│   ├── grammar-frameworks.md           (조사·종조사·경어 1:1 매핑)
│   ├── cliff-report.md                 (R1-R4 절벽)
│   └── todo.md                         (옛 작업 큐)
│
└── legacy/         ← 옛 ja-lab 코드 핵심 (포팅 reference)
    ├── services_word_reviews.ts        (SRS 0-6 stage, AsyncStorage key)
    ├── services_favorite_words.ts      (즐겨찾기 numbers)
    ├── services_user_stats.ts          (streak/today/goal)
    ├── services_user_memo.ts           (검수 메모)
    └── README.md                       (포팅 매핑표)
```

## 운영 룰

1. **카피본만 둠** — 옛 위치는 read-only.
2. 신규 자료 발견 시 → 여기 추가 → 검토 후 `content/` 로 가공해서 옮김.
3. `.py` 스크립트는 Python 3.10+ 권장 (`venv` 권장, `.gitignore` 됨).
4. 큰 raw 코퍼스 (JMultiWOZ 등) 는 `DATA_Raw/languages/ja/` 에 그대로 둠 (여기 복사 X, path 만 참조).

## 옛 → 신규 매핑

| 신규 (db/) | 옛 (talkverse-lab/, BOOKS/) |
|---|---|
| `corpus/lang_ja_*.csv` | `BOOKS/_assets/data/lang_ja_*.csv` |
| `corpus/hanja_crossref.json` | `talkverse-lab/rules/hanja_crossref.json` |
| `corpus/jp_l1_kanji_70.json` | `talkverse-lab/rules/_shared/jp_l1_kanji_70.json` (또는 rules/) |
| `notes/*.md` | `D:/OneDrive/memo/03-Languages/ja/*.md` |
| `legacy/services_*.ts` | `talkverse-lab/apps/ja-lab/services/*.ts` |
