"""
Genki L1-12 Grammar A4 요약 → HTML 생성 (Chrome 인쇄 → PDF).
3 페이지 / 2 column / ~17 cards per page.
H&C 톤 유지 (paper/sakura/honey/clover/ink).

usage:
  python db/scripts/build_grammar_sheet.py
  # → db/sheets/genki_l1_12_a4.html
  # Chrome 으로 열어서 Ctrl+P → 'PDF로 저장' / 인쇄.
"""
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "sheets" / "genki_l1_12_a4.html"
OUT.parent.mkdir(parents=True, exist_ok=True)


# 카드 = (lesson, jlpt, title_ja, brief_en, example_ja, example_ko, ko_hint)
CARDS = [
    # === L1 (4) ===
    (1, "N5", "X は Y です", "Identity / topic-comment sentence",
     "私は学生です。", "저는 학생입니다.",
     "~은/는 = は (주제). です = 입니다"),
    (1, "N5", "~の~", "Connecting nouns / possessive",
     "山田さんの本", "야마다 씨의 책",
     "~의 = の (1:1 매핑)"),
    (1, "N5", "~か (의문)", "Question marker (sentence-end)",
     "学生ですか？", "학생이에요?",
     "~까? = か (정중 의문)"),
    (1, "N5", "X も Y", "X also / too",
     "私も学生です。", "저도 학생입니다.",
     "~도 = も"),
    # === L2 (5) ===
    (2, "N5", "これ / それ / あれ / どれ", "this / that / that-far / which",
     "これは何ですか？", "이건 뭐예요?",
     "근/중/원/의 = 한국어와 동일 패턴"),
    (2, "N5", "この / その / あの N", "this/that N (noun-modifying)",
     "この本は私のです。", "이 책은 제 거예요.",
     "이 / 그 / 저 + 명사 (한국어 동일)"),
    (2, "N5", "ね / よ", "Sentence-final particles (agreement / info)",
     "いいですね。 / 行きますよ。", "좋네요. / 갑니다.",
     "ね = ~네 / よ = ~요 (알림). 한국어 종조사 1:1"),
    (2, "N5", "~じゃありません", "Negation of nouns (~ is not)",
     "学生じゃありません。", "학생이 아닙니다.",
     "~이 아니다 = じゃない / じゃありません"),
    (2, "N5", "誰の N (소유 의문)", "Whose N",
     "誰のかばんですか？", "누구 가방이에요?",
     "누구의 = 誰の"),
    # === L3 (4) ===
    (3, "N5", "Verb conjugation (ます polite)", "Polite present (will / does)",
     "私は本を読みます。", "저는 책을 읽습니다.",
     "~습니다/입니다 = ます (정중체)"),
    (3, "N5", "~を / ~で / ~に / ~へ", "Object / location / target particles",
     "学校で勉強する", "학교에서 공부함",
     "を=을/를, で=에서(장소), に=에/에게, へ=로"),
    (3, "N5", "Frequency adverbs", "Often / sometimes / never",
     "よく勉強します。", "자주 공부합니다.",
     "よく=자주, 時々=가끔, あまり~ない=별로 안~"),
    (3, "N5", "Word order (SOV)", "Subject - Object - Verb",
     "私はパンを食べる。", "저는 빵을 먹어요.",
     "한국어와 동일 — 영어화자 큰 부담"),
    # === L4 (5) ===
    (4, "N5", "ある / いる", "Existence (inanimate / animate)",
     "猫がいる。 / 本がある。", "고양이가 있어요. / 책이 있어요.",
     "있다 = ある(사물) / いる(생물)"),
    (4, "N5", "Past tense (~ました)", "Polite past",
     "昨日来ました。", "어제 왔어요.",
     "~았/었습니다 = ました"),
    (4, "N5", "Location 上下中", "Location nouns",
     "机の上にある。", "책상 위에 있어요.",
     "위/아래/안 = 上/下/中 (한국어 동일)"),
    (4, "N5", "Time duration", "How long",
     "一時間勉強しました。", "한 시간 공부했어요.",
     "시간 길이 단위 — 한국어와 동일"),
    (4, "N5", "~と~ (along with)", "Doing together with",
     "友達と行きます。", "친구랑 갑니다.",
     "~와/과 함께 = ~と"),
    # === L5 (4) ===
    (5, "N5", "い-adjective / な-adjective", "Two adjective types",
     "おいしい / きれいな", "맛있는 / 예쁜",
     "い형용사 활용 / な형용사 = 명사형. ~한 매핑"),
    (5, "N5", "Counting (一つ, 一個…)", "Number + counter",
     "りんごを三つください。", "사과 세 개 주세요.",
     "~개 = 個/つ. 단위 다양 (영어 화자 큰 부담)"),
    (5, "N5", "好き / 嫌い", "Like / dislike (uses が)",
     "猫が好きです。", "고양이를 좋아합니다.",
     "좋아함 = 好き. 조사 が (목적격 아님) 주의"),
    (5, "N5", "~ましょう", "Let's ~ (suggestion)",
     "一緒に行きましょう。", "같이 갑시다.",
     "~합시다 = ましょう (한국어 청유 동등)"),
    # === L6 (4) ===
    (6, "N5", "~から (이유)", "Because ~ (reason)",
     "寒いから着る。", "추우니까 입어요.",
     "~니까 = から (이유). 같은 から = ~부터 도 있음"),
    (6, "N5", "te-form (て形)", "Connective form ★ CORE",
     "本を読んで寝た。", "책을 읽고 잤다.",
     "~고/해서 = て (활용형 신규. 영어화자 최대 난관)"),
    (6, "N5", "~てください", "Please do ~ (polite request)",
     "ここに座ってください。", "여기 앉으세요.",
     "~해주세요 = てください"),
    (6, "N5", "~てもいい / ~てはいけない", "Permission / prohibition",
     "食べてもいいです。", "먹어도 돼요.",
     "~해도 된다 / ~하면 안 된다 (한국어 매핑)"),
    # === L7 (4) ===
    (7, "N5", "Counting people (一人 二人…)", "People counter",
     "三人います。", "세 명 있어요.",
     "~명 = 人. 1·2·3 발음 불규칙 (ひとり·ふたり·さんにん)"),
    (7, "N5", "~に行く (목적)", "Go to (purpose)",
     "買い物に行く。", "쇼핑하러 가요.",
     "~하러 가다 = ~に行く. 동사 ます어간 + に"),
    (7, "N5", "~ている", "Progressive / state ★",
     "今、本を読んでいる。", "지금 책 읽고 있어요.",
     "~고 있다 = ている (진행) / ~어 있다 (상태)"),
    (7, "N5", "te-form 문장 연결", "Joining sentences (and)",
     "起きて、朝ご飯を食べる。", "일어나서 아침 먹어요.",
     "~고 = て (순서). 한국어 직관 매핑"),
    # === L8 (4) ===
    (8, "N5", "Particle が (주격)", "Subject marker (new info)",
     "誰がいますか？ — 田中がいます。", "누가 있어요? — 다나카가.",
     "이/가 = が (새 정보·의문 답). は와 미묘 차이"),
    (8, "N5", "何か / 何も", "Something / nothing",
     "何か食べる？ / 何もない。", "뭐 좀 먹어? / 아무것도 없어.",
     "뭔가 = 何か / 아무것도 ~없다 = 何も~ない"),
    (8, "N5", "Short forms (普通体)", "Casual/dictionary form",
     "行く / 食べる / 来る", "가, 먹어, 와",
     "반말 어미. 친구·가족 대화"),
    (8, "N5", "Verb as noun (の·こと)", "Nominalizing verb",
     "勉強するのが好き。", "공부하는 게 좋아.",
     "~는 것 = の·こと. ~ 매핑 거의 동일"),
    # === L9 (4) ===
    (9, "N5", "~から (설명·because)", "Because (explanation in answer)",
     "なんで？ — 疲れているから。", "왜? — 피곤하니까.",
     "이유 답 = から. (이유 강조)"),
    (9, "N5", "Qualifying nouns (관계절)", "Adjective clause → noun",
     "私が買った本", "내가 산 책",
     "한국어 관계절과 동등 — 어순도 같음"),
    (9, "N5", "まだ ~ていません", "Not yet ~",
     "まだ食べていません。", "아직 안 먹었어요.",
     "아직 안 ~ = まだ~ていない (한국어 직관)"),
    (9, "N5", "Short form past", "Casual past",
     "行った / 食べた / 来た", "갔어, 먹었어, 왔어",
     "보통체 과거. 반말"),
    # === L10 (5) ===
    (10, "N5", "Comparison (~より~のほうが)", "X is more ~ than Y",
     "犬より猫のほうが好き。", "개보다 고양이가 좋아.",
     "~보다 = より. ~의 쪽 = ほう"),
    (10, "N5", "どこかに / どこにも", "Somewhere / nowhere",
     "どこかに行こう。 / どこにも行かない。", "어디론가 가자 / 아무 데도 안 가.",
     "어디론가/아무 데도 — 한국어 직관"),
    (10, "N5", "なる (to become)", "Becomes ~",
     "暑くなる。 / 先生になる。", "더워져요. / 선생님이 돼요.",
     "~이/가 되다 = になる (한국어 동일)"),
    (10, "N5", "~つもりだ", "Intend to ~",
     "明日行くつもりです。", "내일 갈 생각이에요.",
     "~할 생각/작정 = つもり"),
    (10, "N5", "~で (수단·도구)", "By means of / with",
     "バスで行く。 / 鉛筆で書く。", "버스로 가요. / 연필로 써요.",
     "~로 (수단) = で. 같은 で = 장소도 있음"),
    # === L11 (4) ===
    (11, "N5", "~や~", "X and Y (non-exhaustive)",
     "本やノートを買う。", "책이랑 노트를 사요.",
     "~랑/이나 = や (대표 나열). と 와 차이"),
    (11, "N5", "~ことがある (경험)", "Have done ~ before",
     "日本に行ったことがある。", "일본 간 적 있어요.",
     "~한 적 있다 = ことがある (한국어 동등)"),
    (11, "N5", "~たい (희망)", "Want to ~",
     "ラーメンが食べたい。", "라멘 먹고 싶어.",
     "~고 싶다 = たい. を→が 변환 주의"),
    (11, "N5", "~たり~たりする", "Things like ~ing and ~ing",
     "本を読んだり、寝たりする。", "책 읽기도 하고 자기도 해요.",
     "~기도 하고 ~기도 = たり (열거)"),
    # === L12 (6) ===
    (12, "N5", "~でしょう", "Probably / right?",
     "明日は雨でしょう。", "내일은 비 오겠죠.",
     "~겠죠 = でしょう. 추측 + 확인"),
    (12, "N5", "~ほうがいい", "Should do / had better",
     "早く寝たほうがいい。", "빨리 자는 게 좋아.",
     "~는 게 낫다 = ほうがいい (한국어 동등)"),
    (12, "N5", "~んです (설명)", "Explanation / context",
     "今、勉強しているんです。", "지금 공부하고 있는 거예요.",
     "~인 거예요 / ~거든 = んです (정중)"),
    (12, "N5", "~ので (because, polite)", "Because (softer than から)",
     "疲れているので休む。", "피곤해서 쉽니다.",
     "~서/때문에 = ので. から 보다 부드러움"),
    (12, "N5", "~なくちゃいけない", "Must / have to ~",
     "勉強しなくちゃいけない。", "공부해야 해.",
     "~해야 한다 = なくちゃいけない / なければならない"),
    (12, "N5", "~すぎる", "Too much / excessively",
     "食べすぎた。", "너무 많이 먹었어.",
     "너무 ~하다 = すぎる. 동사 ます어간 + すぎる"),
]


def html_for_card(c) -> str:
    lesson, jlpt, ja, brief, ex_ja, ex_ko, hint = c
    return f'''<div class="card">
  <div class="chips">
    <span class="chip lesson">L{lesson}</span>
    <span class="chip jlpt">{jlpt}</span>
  </div>
  <div class="ja">{ja}</div>
  <div class="brief">{brief}</div>
  <div class="ex">
    <span class="ex-ja">{ex_ja}</span>
    <span class="ex-ko">{ex_ko}</span>
  </div>
  <div class="hint">🇰🇷 {hint}</div>
</div>'''


def page(idx_start, idx_end, page_num, total_pages, title) -> str:
    cards_html = "\n".join(html_for_card(CARDS[i]) for i in range(idx_start, idx_end))
    return f'''<section class="page">
  <header>
    <h1>{title}</h1>
    <div class="meta">
      <span class="badge">日本語ユニバース</span>
      <span>Genki L1-12 · 영어화자 baseline 커리큘럼</span>
      <span class="pageno">{page_num} / {total_pages}</span>
    </div>
  </header>
  <div class="grid">
    {cards_html}
  </div>
  <footer>
    <span>🌸 한국화자 = 🇰🇷 hint 라인 활용해 소거법 진행 · 영어화자 = 본문 위주</span>
  </footer>
</section>'''


CSS = '''
@page { size: A4 portrait; margin: 8mm 10mm 8mm 10mm; }
* { box-sizing: border-box; }
html, body {
  margin: 0;
  padding: 0;
  font-family: "Noto Sans CJK JP", "Noto Sans JP", "Yu Gothic", "Pretendard", "Apple SD Gothic Neo", sans-serif;
  color: #4A4554;
  background: #FBF8F1;
  font-size: 10pt;
  line-height: 1.45;
}
.page {
  width: 100%;
  min-height: calc(297mm - 16mm);
  page-break-after: always;
  display: flex;
  flex-direction: column;
}
.page:last-of-type { page-break-after: auto; }
header {
  display: flex;
  flex-direction: column;
  gap: 2mm;
  margin-bottom: 4mm;
  padding-bottom: 3mm;
  border-bottom: 1.2px solid #8B8294;
}
header h1 {
  margin: 0;
  font-size: 14pt;
  font-weight: 800;
  letter-spacing: -0.3px;
  color: #4A4554;
}
header h1::before {
  content: "🌸 ";
}
.meta {
  display: flex;
  gap: 8px;
  align-items: center;
  font-size: 8.5pt;
  color: #7A7585;
  font-weight: 600;
}
.badge {
  background: #F8C8D8;
  color: #4A4554;
  padding: 1px 6px;
  border-radius: 999px;
  border: 0.6px solid #8B8294;
  font-weight: 700;
}
.pageno {
  margin-left: auto;
  font-variant-numeric: tabular-nums;
  font-weight: 700;
}
.grid {
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3mm;
  align-content: start;
}
.card {
  border: 0.8px solid #8B8294;
  border-radius: 4px;
  padding: 2.5mm 3mm;
  background: #FFFEFB;
  break-inside: avoid;
}
.chips {
  display: flex;
  gap: 4px;
  margin-bottom: 1.5mm;
}
.chip {
  display: inline-block;
  font-size: 7pt;
  font-weight: 800;
  padding: 0.5px 5px;
  border-radius: 999px;
  letter-spacing: 0.5px;
}
.chip.lesson {
  background: #C8BFE8;
  color: #4A4554;
  border: 0.5px solid #8B8294;
}
.chip.jlpt {
  background: #EDD27A;
  color: #4A4554;
  border: 0.5px solid #8B8294;
}
.ja {
  font-size: 12pt;
  font-weight: 800;
  color: #4A4554;
  letter-spacing: -0.2px;
  margin-bottom: 0.8mm;
}
.brief {
  font-size: 8.5pt;
  color: #7A7585;
  font-style: italic;
  font-weight: 500;
  margin-bottom: 1.5mm;
}
.ex {
  background: #FDF6D9;
  border-left: 1.5px solid #EDD27A;
  padding: 1.5mm 2mm;
  margin-bottom: 1.5mm;
  border-radius: 0 3px 3px 0;
}
.ex-ja {
  display: block;
  font-size: 10pt;
  font-weight: 700;
  color: #4A4554;
}
.ex-ko {
  display: block;
  font-size: 8.5pt;
  color: #7A7585;
  margin-top: 0.5mm;
}
.hint {
  font-size: 8pt;
  color: #4A4554;
  background: #EAF3E4;
  padding: 1mm 2mm;
  border-radius: 3px;
  border: 0.5px solid #B8D2AE;
}
footer {
  margin-top: 3mm;
  padding-top: 2mm;
  border-top: 0.6px solid #B0ACB8;
  font-size: 7.5pt;
  color: #7A7585;
  text-align: center;
  font-weight: 600;
}
@media print {
  body { background: white; }
  .card { background: white; box-shadow: none; }
}
'''


def main():
    total = len(CARDS)
    # 3-page split: L1-4, L5-8, L9-12 (대략)
    pages = []
    # page 1: L1-L4 (4+5+4+5 = 18 cards)
    pages.append(page(0, 18, 1, 3, "L1-4 · 명사문 · 지시사 · 동사·조사 · 존재"))
    # page 2: L5-L8 (4+4+4+4 = 16 cards)
    pages.append(page(18, 34, 2, 3, "L5-8 · 형용사 · te-form · ~ている · 주격 が"))
    # page 3: L9-L12 (4+5+4+6 = 19 cards)
    pages.append(page(34, total, 3, 3, "L9-12 · ~から 설명 · 비교 · ~たい · ~んです"))

    body = "\n".join(pages)
    html = f'''<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Genki L1-12 Grammar — 日本語ユニバース</title>
<style>{CSS}</style>
</head>
<body>
{body}
</body>
</html>
'''
    OUT.write_text(html, encoding="utf-8")
    print(f"✓ {OUT.relative_to(OUT.parent.parent.parent)}")
    print(f"  cards: {total}")
    print(f"  pages: 3 (18 / 16 / 19 cards)")
    print()
    print(f"열기:")
    print(f"  start {OUT}    (Windows)")
    print(f"  open {OUT}     (Mac)")
    print(f"인쇄: Chrome 에서 Ctrl+P → 'PDF로 저장' / 인쇄")


if __name__ == "__main__":
    main()
