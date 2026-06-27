"""
Genki L1-12 Grammar Sheet — for native English speakers.
5 pages / 2 column / ~60 grammar points + formation + example with romaji + EN translation.
Includes "English speakers note" tips for concepts foreign to English.

usage:
  python db/scripts/build_grammar_sheet_en.py
  → db/sheets/genki_l1_12_a4_en.html
  Open in Chrome → Ctrl+P → Save as PDF / Print A4
"""
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "sheets" / "genki_l1_12_a4_en.html"
OUT.parent.mkdir(parents=True, exist_ok=True)


# Card schema: (lesson, jlpt, pattern_ja, romaji, en_title, formation, ex_ja, ex_romaji, ex_en, en_note)
# - pattern_ja: Japanese pattern (with placeholders X/Y)
# - romaji: romanization
# - en_title: short English name
# - formation: how to make it (verb stem + something, etc.)
# - example: in 3 forms
# - en_note: tip for English speakers (cultural/grammar gap), or None
CARDS = [
    # === L1 (5 — greetings, copula) ===
    (1, "N5", "X は Y です", "X wa Y desu", "X is Y (identity)",
     "Noun は Noun です. Negative: ~では ありません",
     "私は学生です。", "Watashi wa gakusei desu.", "I am a student.",
     "は is the topic marker (pronounced 'wa', not 'ha'). です = formal copula. No equivalent in English — Japanese marks the subject of discourse rather than 'I/you'."),

    (1, "N5", "~の~", "~no~", "Connecting nouns (possessive / attributive)",
     "Noun の Noun. Owner + の + object.",
     "山田さんの本", "Yamada-san no hon", "Yamada's book",
     "の is far more versatile than English 'of' or '-'s. Also used in compound nouns like 日本の歌 (Japanese songs)."),

    (1, "N5", "~か (question)", "~ka", "Sentence-end question marker",
     "Statement + か. No rising intonation needed in formal speech.",
     "学生ですか？", "Gakusei desu ka?", "Are you a student?",
     "Japanese doesn't invert word order for questions like English. Just add か at the end."),

    (1, "N5", "X も Y", "X mo Y", "X also / X too",
     "Replaces は or を to add 'also'.",
     "私も学生です。", "Watashi mo gakusei desu.", "I am also a student.",
     "Particles like も REPLACE は/を, they don't add to them."),

    (1, "N5", "Numbers 1-10, age, time", "ichi, ni, san...", "Basic counting",
     "Number + counter (e.g., 〜歳 sai for age, 〜時 ji for time).",
     "二十歳です。", "Hatachi desu.", "I'm 20 years old.",
     "20 years old is irregularly read 'hatachi' (not 'nijussai')."),

    # === L2 (6 — demonstratives, location, possessive Q) ===
    (2, "N5", "これ / それ / あれ / どれ", "kore / sore / are / dore", "This / that / that-far / which (pronoun)",
     "Standalone pronouns. これ=near speaker, それ=near listener, あれ=far from both, どれ=which.",
     "これは何ですか？", "Kore wa nan desu ka?", "What is this?",
     "Three-way distance, not two like English ('this/that'). Important to learn the spatial logic."),

    (2, "N5", "この / その / あの + Noun", "kono / sono / ano + N", "This/that + noun (attributive)",
     "Used BEFORE a noun. Cannot stand alone.",
     "この本は私のです。", "Kono hon wa watashi no desu.", "This book is mine.",
     "Different from これ — これ stands alone, この must attach to a noun. Common mistake."),

    (2, "N5", "ここ / そこ / あそこ / どこ", "koko / soko / asoko / doko", "Here / there / over there / where",
     "Location pronouns.",
     "トイレはどこですか？", "Toire wa doko desu ka?", "Where is the toilet?",
     "あそこ (asoko) means 'over there' (far from both speakers). No direct one-word English equivalent."),

    (2, "N5", "~ね / ~よ", "~ne / ~yo", "Sentence-end particles (agreement / new info)",
     "ね = seeking agreement (right?). よ = telling listener something they don't know.",
     "いいですね。 / 行きますよ。", "Ii desu ne. / Ikimasu yo.", "Nice, isn't it? / I'm going (FYI).",
     "Carry social/emotional weight. Overusing よ can sound bossy. ね is friendly."),

    (2, "N5", "~じゃ ありません", "~ja arimasen", "Negation of nouns/な-adjectives",
     "Replace です with じゃありません (casual: じゃない).",
     "学生じゃありません。", "Gakusei ja arimasen.", "I'm not a student.",
     "じゃ is the spoken contraction of では. Formal speech uses では ありません."),

    (2, "N5", "誰の N (whose N)", "dare no N", "Whose ~?",
     "誰 (who) + の + Noun.",
     "誰のかばんですか？", "Dare no kaban desu ka?", "Whose bag is it?",
     "Same の pattern as L1, just with 誰 (who)."),

    # === L3 (5 — verb basics) ===
    (3, "N5", "Verb ます-form (polite present/future)", "~masu", "Polite present tense verb",
     "Group 1 (う-verbs): 書く→書きます. Group 2 (る-verbs): 食べる→食べます. Irregular: する→します, 来る→きます.",
     "本を読みます。", "Hon o yomimasu.", "I read a book.",
     "ます form covers both present and future ('I read' AND 'I will read'). Context decides."),

    (3, "N5", "Object particle を", "~o", "Direct object marker",
     "Direct object + を + transitive verb. Written を but pronounced 'o'.",
     "コーヒーを飲みます。", "Koohii o nomimasu.", "I drink coffee.",
     "Pronounced 'o' identical to お, but written differently. Only used for direct object."),

    (3, "N5", "Location particles で / に / へ", "de / ni / e", "Where action happens / destination",
     "で = where action takes place. に = direction/specific time/destination. へ = direction (written へ, pronounced 'e').",
     "学校で勉強します。", "Gakkou de benkyou shimasu.", "I study at school.",
     "で vs に is a HUGE pitfall: で = activity location (study AT school), に = end-point (go TO school)."),

    (3, "N5", "Frequency adverbs", "yoku / tokidoki / amari / zenzen", "often / sometimes / not much / not at all",
     "Negative frequency (あまり, ぜんぜん) must end with negative verb.",
     "あまり食べません。", "Amari tabemasen.", "I don't eat much.",
     "あまり and ぜんぜん REQUIRE negative verbs. 'I rarely eat' = 'I don't eat much' in Japanese logic."),

    (3, "N5", "Word order — SOV", "Subject-Object-Verb", "Verb goes LAST",
     "Subject は Object を Verb. Particles do the grammatical work, so word order is flexible.",
     "私はパンを食べます。", "Watashi wa pan o tabemasu.", "I eat bread.",
     "BIGGEST mental shift for English speakers. The verb always comes last. Train your brain to wait for the verb."),

    # === L4 (5 — existence, past, time) ===
    (4, "N5", "ある / いる (existence)", "aru / iru", "There is / there are",
     "ある = inanimate (things). いる = animate (people, animals). Use が for subject.",
     "猫がいます。 / 本があります。", "Neko ga imasu. / Hon ga arimasu.", "There is a cat. / There is a book.",
     "Choosing aru/iru by animacy is alien to English. Plants and most insects use ある."),

    (4, "N5", "Past tense (ました / でした)", "~mashita / ~deshita", "Polite past tense",
     "ます → ました (verbs). です → でした (nouns/な-adj). Negative past: ~ませんでした.",
     "昨日学校へ行きました。", "Kinou gakkou e ikimashita.", "I went to school yesterday.",
     "Past tense affixes are very regular — much easier than English irregular verbs."),

    (4, "N5", "Location nouns (上下中前後)", "ue / shita / naka / mae / ushiro", "Above / under / inside / front / back",
     "Noun の + location word + に. Sequence: thing-の-location-に.",
     "机の上にあります。", "Tsukue no ue ni arimasu.", "It's on top of the desk.",
     "Spatial relations expressed as nouns, not prepositions. 'On the desk' = 'at the desk's top'."),

    (4, "N5", "Time particle に / で", "~ni / ~de", "At a specific time / time-window",
     "に for specific clock time, day, year. No に for relative time (今日, 明日).",
     "七時に起きます。", "Shichi-ji ni okimasu.", "I get up at 7 o'clock.",
     "Don't add に to 今日, 明日, 昨日 — they already imply time. Common mistake."),

    (4, "N5", "~と (with someone)", "~to", "Together with",
     "Person/thing + と. Different から と (and so).",
     "友達と映画を見ます。", "Tomodachi to eiga o mimasu.", "I watch a movie with a friend.",
     "Same particle と does both 'with' AND 'and' (for lists). Context distinguishes."),

    # === L5 (5 — adjectives, like/dislike, ましょう) ===
    (5, "N5", "い-adjectives", "i-adjectives", "True adjectives (conjugate)",
     "End in い: 高い, 安い, 大きい. Negative: 高くない. Past: 高かった. Negative past: 高くなかった.",
     "この本は高いです。", "Kono hon wa takai desu.", "This book is expensive.",
     "い-adj. conjugate themselves like verbs (carry tense). NEVER add です to make past — change い→かった instead."),

    (5, "N5", "な-adjectives", "na-adjectives", "Quasi-noun adjectives",
     "Use な before noun: 静かな町. Otherwise treated like nouns: 静かです. Negative: 静かじゃありません.",
     "あの町は静かです。", "Ano machi wa shizuka desu.", "That town is quiet.",
     "な-adj act like nouns until they modify another noun (then add な). Includes loanwords like ハンサム."),

    (5, "N5", "好き / 嫌い (like/dislike — な-adj)", "suki / kirai", "Like / dislike (uses が)",
     "Object liked + が好き. Negative: 好きじゃありません.",
     "犬が好きです。", "Inu ga suki desu.", "I like dogs.",
     "好き is a な-ADJECTIVE, not a verb. Object uses が, NOT を. 'I like X' = 'X is likable (to me).'"),

    (5, "N5", "Counters (~まい ~ぽん ~こ etc.)", "~mai / ~hon / ~ko", "Object-specific counters",
     "Number + counter. 紙 (paper) uses ~まい. 鉛筆 (long thin objects) uses ~ほん. General: ~つ (1-10).",
     "りんごを三つください。", "Ringo o mittsu kudasai.", "Three apples, please.",
     "Hundreds of counters exist. Start with つ (general), 個, 人, 本, 枚. Beginners default to ~つ when unsure."),

    (5, "N5", "~ましょう (let's)", "~mashou", "Let's do ~ (suggestion)",
     "Verb stem (ます removed) + ましょう. Question form ~ましょうか? = 'Shall we?'",
     "一緒に行きましょう。", "Issho ni ikimashou.", "Let's go together.",
     "Very common — used in formal & casual settings. ~ましょうか? is polite for offering to do something for someone."),

    # === L6 (5 — te-form, requests) ===
    (6, "N5", "te-form (て形) ★", "te-form", "Connector form — joins clauses, makes requests, allows...",
     "Rules vary by verb group. Group 1 (う-verbs): 書く→書いて, 飲む→飲んで, 立つ→立って. Group 2: drop る, add て. Irregular: する→して, 来る→きて.",
     "ご飯を食べて、寝ます。", "Gohan o tabete, nemasu.", "I'll eat and then sleep.",
     "★ CRUCIAL FORM. The single biggest hurdle in early Japanese. Required for ~てください, ~ている, requests, permissions, prohibitions, and connecting clauses. Memorize the rules."),

    (6, "N5", "~から (reason)", "~kara", "Because ~",
     "Reason clause + から + result clause. Always end the REASON with から.",
     "寒いから、ジャケットを着ます。", "Samui kara, jaketto o kimasu.", "Because it's cold, I wear a jacket.",
     "Opposite order from English 'X because Y'. Japanese: 'Y kara X'. Reason FIRST, then action."),

    (6, "N5", "~てください (please do)", "~te kudasai", "Please do ~ (polite request)",
     "te-form + ください. Negative request: ~ないでください.",
     "ここに座ってください。", "Koko ni suwatte kudasai.", "Please sit here.",
     "Despite ください meaning 'give', this is a normal polite request, not begging. Use freely with strangers."),

    (6, "N5", "~てもいい / ~てはいけない", "~temo ii / ~te wa ikenai", "May ~ / Must not ~",
     "te-form + も いい です = permission. te-form + は いけません = prohibition.",
     "ここでタバコを吸ってもいいですか？", "Koko de tabako o sutte mo ii desu ka?", "May I smoke here?",
     "Combines te-form with new grammar. ~ても is 'even if'. Critical for navigating Japanese politeness."),

    (6, "N5", "~ましょうか (shall I?)", "~mashou ka", "Shall I do ~ for you?",
     "Verb stem + ましょうか. Offers help.",
     "手伝いましょうか？", "Tetsudaimashou ka?", "Shall I help you?",
     "Polite offer. Different from ~ませんか (would you like to?) which suggests doing together."),

    # === L7 (5 — ~ている, going for purpose) ===
    (7, "N5", "Counting people 一人 二人...", "hitori / futari / sannin", "People counter",
     "1 and 2 irregular (hitori, futari). 3+: number + 人 (nin).",
     "三人います。", "Sannin imasu.", "There are three people.",
     "Memorize: hitori, futari, then sannin (3), yonin (4 — irregular: read 'yo' not 'shi'), gonin (5)..."),

    (7, "N5", "Verb stem + に行く (purpose)", "~ni iku", "Go to do ~",
     "Verb stem (ます removed) + に + 行く/来る/帰る.",
     "買い物に行きます。", "Kaimono ni ikimasu.", "I'm going shopping.",
     "に here is purpose, not location. The verb stem becomes a 'noun of action'."),

    (7, "N5", "~ている (progressive/state) ★", "~te iru", "Be doing ~ / be in state of ~",
     "te-form + いる. Progressive (action ongoing) OR resultant state.",
     "今、本を読んでいます。", "Ima, hon o yonde imasu.", "I am reading a book now.",
     "Has TWO meanings: (1) ongoing action ('eating'), (2) result state ('married' = 結婚しています, 'know' = 知っています). The state meaning catches English speakers off guard."),

    (7, "N5", "te-form connecting sentences", "te-form chaining", "Doing X and then Y",
     "te-form chains actions in sequence. The last verb carries the tense.",
     "朝起きて、ご飯を食べて、出かけます。", "Asa okite, gohan o tabete, dekakemasu.", "I wake up, eat, then go out.",
     "Time/sequence flows from first to last. Compare to from-/from-which in English."),

    (7, "N5", "Family terms (mine vs yours)", "haha / okaasan", "Humble vs respectful family",
     "Own family (humble): 父 (chichi), 母 (haha), 兄 (ani), 姉 (ane). Other's family (respectful): お父さん, お母さん, お兄さん, お姉さん.",
     "母は医者です。", "Haha wa isha desu.", "My mother is a doctor.",
     "Strict in-group/out-group distinction. Calling YOUR mother お母さん to others sounds childish. Calling SOMEONE ELSE'S mother 母 is rude."),

    # === L8 (5 — particle が, short forms) ===
    (8, "N5", "Particle が (subject marker)", "~ga", "Subject marker (new info / answer to questions)",
     "Use が when (1) answering 'who/what?' questions, (2) introducing new info, (3) with existence verbs.",
     "誰が来ましたか？— 田中さんが来ました。", "Dare ga kimashita ka? Tanaka-san ga kimashita.", "Who came? — Tanaka came.",
     "が vs は is THE eternal pitfall. Rule of thumb: は marks WHAT the sentence is about (topic), が marks WHO/WHAT does the verb (subject, new info). With く 形容詞 like 好き, ALWAYS が."),

    (8, "N5", "何か / 何も", "nanika / nanimo", "Something / nothing",
     "何 + か = something (positive). 何 + も + negative verb = nothing.",
     "何か食べますか？— 何も食べません。", "Nanika tabemasu ka? Nanimo tabemasen.", "Will you eat something? I won't eat anything.",
     "Same pattern with 誰 (who): 誰か (someone) / 誰も (no one). The も version REQUIRES negative."),

    (8, "N5", "Short forms (普通体 / dictionary form)", "futsuutai", "Casual / dictionary form verbs",
     "ます → dictionary form (行きます → 行く). Negative: ない (行きません → 行かない).",
     "今日は学校に行く。", "Kyou wa gakkou ni iku.", "I'm going to school today.",
     "Used with friends, family, in writing, and required for many grammar patterns. The 'real' form of the verb (dictionary entries use this)."),

    (8, "N5", "Verb as modifier (~ている人)", "modifying nouns with verbs", "Relative clauses",
     "Plain verb + noun. Verb describes the noun.",
     "あそこにいる人は誰ですか？", "Asoko ni iru hito wa dare desu ka?", "Who is the person over there?",
     "Japanese relative clauses come BEFORE the noun (opposite of English 'who/which/that' clauses). No relative pronoun needed."),

    (8, "N5", "Nominalizing with の / こと", "verb + no / koto", "Verb-ing as noun",
     "Plain verb + の or こと turns verb into 'the act of ~ing'.",
     "本を読むのが好きです。", "Hon o yomu no ga suki desu.", "I like reading books.",
     "の and こと both nominalize verbs. Subtle preference rules — の for concrete actions, こと for abstract/general. Beginners can use の mostly."),

    # === L9 (4 — past short, qualifying nouns) ===
    (9, "N5", "Plain past affirmative (~た)", "~ta", "Plain past tense",
     "Same rules as te-form, but て → た / で → だ. 行く→行った, 食べる→食べた.",
     "昨日、寿司を食べた。", "Kinou, sushi o tabeta.", "I ate sushi yesterday.",
     "Mastering te-form gives you ta-form free. Just swap ending sound."),

    (9, "N5", "Plain past negative (~なかった)", "~nakatta", "Plain past negative",
     "Plain negative ~ない → ~なかった.",
     "昨日、食べなかった。", "Kinou, tabenakatta.", "I didn't eat yesterday.",
     "い-adj. follow same pattern: 高くない → 高くなかった. The ない suffix conjugates like an い-adjective."),

    (9, "N5", "Qualifying nouns with clauses", "relative clauses", "Adjective clauses",
     "Full clause (in plain form) + noun.",
     "私が買った本", "Watashi ga katta hon", "The book I bought",
     "Subject of relative clause uses が (not は). Plain form is required (no です/ます inside)."),

    (9, "N5", "~から (because, plain form)", "~kara", "Because (with plain form)",
     "Plain form clause + から. Common in casual speech.",
     "雨が降ったから、行かなかった。", "Ame ga futta kara, ikanakatta.", "I didn't go because it rained.",
     "Same から as before, but explicitly used with plain forms in casual speech."),

    # === L10 (5 — comparison, indefinite, become, intent) ===
    (10, "N5", "Comparison: より / のほうが", "~yori / ~no hou ga", "X is more ~ than Y",
     "Y より X のほう が ~ (X is more ~ than Y). Order: standard X-で is-more-than-Y.",
     "犬より猫のほうが好きです。", "Inu yori neko no hou ga suki desu.", "I like cats more than dogs.",
     "Word order can flip. Important: のほうが is the 'more' part, より is the 'than' part."),

    (10, "N5", "Superlative: ~の中で一番", "~no naka de ichiban", "The most ~ (within a group)",
     "Group の中で + adjective + のは + thing (or 一番 + adj. directly).",
     "果物の中でりんごが一番好きです。", "Kudamono no naka de ringo ga ichiban suki desu.", "Of all fruits, I like apples best.",
     "一番 literally means 'number one'. Use it as 'most' in superlatives."),

    (10, "N5", "Indefinite: どこかに / どこにも", "dokoka ni / doko nimo", "Somewhere / nowhere",
     "Question word + か (some-) or + も (negative '-no-').",
     "どこかに行きたい。 / どこにも行かない。", "Dokoka ni ikitai. / Doko nimo ikanai.", "I want to go somewhere. / I'm not going anywhere.",
     "Same pattern works with 何 (something/nothing), 誰 (someone/no one), いつ (sometime/never)."),

    (10, "N5", "~になる / ~くなる (become)", "~ni naru / ~ku naru", "Becomes ~",
     "Noun + に + なる. い-adj. drop い + く + なる. な-adj. + に + なる.",
     "暑くなりました。 / 先生になりたい。", "Atsuku narimashita. / Sensei ni naritai.", "It became hot. / I want to become a teacher.",
     "なる expresses change of state. Different から する (do) which suggests deliberate action. なる = natural/inevitable change."),

    (10, "N5", "~つもりです (intention)", "~tsumori desu", "I plan to / intend to ~",
     "Plain dictionary form + つもり + です. Negative: 動かないつもりです.",
     "明日、大阪に行くつもりです。", "Ashita, Oosaka ni iku tsumori desu.", "I plan to go to Osaka tomorrow.",
     "Stronger than just 'will' — implies a personal commitment or plan. Different from もうつもりはない (no intention)."),

    # === L11 (4 — や, ことがある, ~たい, ~たり) ===
    (11, "N5", "~や~ (non-exhaustive 'and')", "~ya ~", "Things like X and Y (among others)",
     "Noun や Noun (など). Implies more items exist beyond what's listed.",
     "本やノートを買った。", "Hon ya nooto o katta.", "I bought books and notebooks (among other things).",
     "と lists EVERYTHING. や lists SOME representative items. Subtle but important distinction in nuance."),

    (11, "N5", "~ことがある (experience)", "~koto ga aru", "Have ~ed before",
     "Plain PAST form + こと が ある. Negative: ~ことがない.",
     "日本に行ったことがあります。", "Nihon ni itta koto ga arimasu.", "I have been to Japan before.",
     "Must use PAST form even though English uses present perfect ('have been'). Common error: using dictionary form."),

    (11, "N5", "~たい (want to do)", "~tai", "I want to ~",
     "Verb stem (ます removed) + たい. Conjugates like い-adjective: ~たくない, ~たかった.",
     "ラーメンが食べたい。", "Raamen ga tabetai.", "I want to eat ramen.",
     "OBJECT particle changes: を often becomes が with ~たい (preference, not action). Only for FIRST person — using ~たい about others sounds presumptuous; use ~たがる instead."),

    (11, "N5", "~たり~たりする", "~tari ~tari suru", "Doing things like ~ and ~",
     "Plain past + り + Plain past + り + する. Non-exhaustive list of activities.",
     "週末は本を読んだり、寝たりします。", "Shuumatsu wa hon o yondari, netari shimasu.", "On weekends I do things like reading and sleeping.",
     "Indicates SAMPLES of activities, not all of them. Compare to て-form chains which list ALL the activities in sequence."),

    # === L12 (6 — でしょう, ほうがいい, んです, ~ので, ~なくちゃ, ~すぎる) ===
    (12, "N5", "~でしょう / ~だろう", "~deshou / ~darou", "Probably ~ / right?",
     "Plain form + でしょう (formal) / だろう (casual). Rising intonation = seeking confirmation.",
     "明日は雨でしょう。", "Ashita wa ame deshou.", "It will probably rain tomorrow.",
     "Used by weather forecasters constantly. Different functions: (1) probability, (2) seeking agreement (rising tone)."),

    (12, "N5", "~ほうがいい (you should)", "~hou ga ii", "It's better to ~",
     "Plain PAST form + ほうがいい. Negative: ~ないほうがいい (better not to).",
     "早く寝たほうがいいです。", "Hayaku neta hou ga ii desu.", "You should sleep early.",
     "Often advice given to others. Past form is required for affirmative advice — strange to English speakers. Negative uses ない form."),

    (12, "N5", "~んです / ~のです (explanatory)", "~n desu / ~no desu", "It's because / the reason is ~",
     "Plain form + ん (or の) + です. Provides context or explanation.",
     "今、忙しいんです。", "Ima, isogashii n desu.", "It's because I'm busy now.",
     "Adds emotional/explanatory weight. Sounds defensive or explanatory. Overuse can sound whiny. Listen to native speakers to learn nuance."),

    (12, "N5", "~ので (because, polite)", "~node", "Because (softer than から)",
     "Plain form + ので. Sounds more polite/objective than から.",
     "疲れているので、休みます。", "Tsukarete iru node, yasumimasu.", "Since I'm tired, I'll rest.",
     "Used in formal/polite contexts (workplace requests). から sounds more assertive. な-adj/noun: use ~なので."),

    (12, "N5", "~なくちゃ いけない / ~なければ ならない", "~nakucha ikenai / ~nakereba naranai", "Must do ~",
     "Drop い from ない, then add ~くちゃいけない (casual) or ~ければならない (formal).",
     "宿題をしなくちゃいけない。", "Shukudai o shinakucha ikenai.", "I have to do homework.",
     "Literally means 'if I don't do it, it won't do' — a double negative. Many shorter casual forms: ~ないと, ~なきゃ. Very common."),

    (12, "N5", "~すぎる (too much)", "~sugiru", "Too ~ / overdo ~",
     "Verb stem + すぎる. い-adj drop い + すぎる. な-adj + すぎる.",
     "食べすぎた。", "Tabesugita.", "I ate too much.",
     "Conjugates as a regular る-verb: 食べすぎる → 食べすぎます → 食べすぎた. Indicates an undesirable excess."),
]


def html_for_card(c) -> str:
    lesson, jlpt, ja, romaji, en_title, formation, ex_ja, ex_romaji, ex_en, en_note = c
    note_html = ''
    if en_note:
        note_html = f'<div class="note"><span class="note-label">EN tip</span> {en_note}</div>'
    return f'''<div class="card">
  <div class="chips">
    <span class="chip lesson">L{lesson}</span>
    <span class="chip jlpt">{jlpt}</span>
  </div>
  <div class="ja">{ja}</div>
  <div class="romaji">{romaji}</div>
  <div class="title">{en_title}</div>
  <div class="formation"><span class="form-label">Form</span> {formation}</div>
  <div class="ex">
    <div class="ex-ja">{ex_ja}</div>
    <div class="ex-romaji">{ex_romaji}</div>
    <div class="ex-en">{ex_en}</div>
  </div>
  {note_html}
</div>'''


def page(idx_start, idx_end, page_num, total_pages, title) -> str:
    cards_html = "\n".join(html_for_card(CARDS[i]) for i in range(idx_start, idx_end))
    return f'''<section class="page">
  <header>
    <h1>{title}</h1>
    <div class="meta">
      <span class="badge">日本語ユニバース · Globi</span>
      <span>Genki L1-12 · For native English speakers</span>
      <span class="pageno">{page_num} / {total_pages}</span>
    </div>
  </header>
  <div class="grid">
    {cards_html}
  </div>
  <footer>
    <span>★ = critical grammar · Particles in <i>italic-romaji</i> · Plain (dictionary) form used for combinations</span>
  </footer>
</section>'''


CSS = '''
@page { size: A4 portrait; margin: 8mm 10mm; }
* { box-sizing: border-box; }
html, body {
  margin: 0; padding: 0;
  font-family: "Noto Sans CJK JP", "Noto Sans JP", "Yu Gothic", "Helvetica Neue", Arial, sans-serif;
  color: #4A4554;
  background: #FBF8F1;
  font-size: 9pt;
  line-height: 1.4;
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
  margin-bottom: 3.5mm;
  padding-bottom: 2.5mm;
  border-bottom: 1.2px solid #8B8294;
}
header h1 {
  margin: 0;
  font-size: 13pt;
  font-weight: 800;
  letter-spacing: -0.3px;
  color: #4A4554;
}
header h1::before { content: "🌸 "; }
.meta {
  display: flex;
  gap: 8px;
  align-items: center;
  font-size: 8pt;
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
  gap: 2.5mm;
  align-content: start;
}
.card {
  border: 0.8px solid #8B8294;
  border-radius: 4px;
  padding: 2mm 2.5mm;
  background: #FFFEFB;
  break-inside: avoid;
}
.chips {
  display: flex;
  gap: 4px;
  margin-bottom: 1mm;
}
.chip {
  display: inline-block;
  font-size: 6.5pt;
  font-weight: 800;
  padding: 0.5px 5px;
  border-radius: 999px;
  letter-spacing: 0.5px;
}
.chip.lesson { background: #C8BFE8; color: #4A4554; border: 0.5px solid #8B8294; }
.chip.jlpt   { background: #EDD27A; color: #4A4554; border: 0.5px solid #8B8294; }
.ja {
  font-size: 11.5pt;
  font-weight: 800;
  color: #4A4554;
  letter-spacing: -0.2px;
}
.romaji {
  font-size: 7.5pt;
  color: #7A7585;
  font-style: italic;
  margin-bottom: 0.5mm;
}
.title {
  font-size: 9pt;
  font-weight: 700;
  color: #4A4554;
  margin-bottom: 1mm;
}
.formation {
  font-size: 8pt;
  color: #5C5C6E;
  line-height: 1.35;
  margin-bottom: 1.5mm;
}
.form-label {
  display: inline-block;
  background: #DDD3F0;
  color: #4A4554;
  padding: 0 4px;
  border-radius: 3px;
  font-size: 6.5pt;
  font-weight: 800;
  letter-spacing: 0.4px;
  margin-right: 3px;
  vertical-align: 1px;
}
.ex {
  background: #FDF6D9;
  border-left: 1.5px solid #EDD27A;
  padding: 1.2mm 2mm;
  margin-bottom: 1mm;
  border-radius: 0 3px 3px 0;
}
.ex-ja { font-size: 9.5pt; font-weight: 700; color: #4A4554; }
.ex-romaji { font-size: 7.5pt; color: #7A7585; font-style: italic; margin-top: 0.2mm; }
.ex-en { font-size: 8pt; color: #4A4554; margin-top: 0.3mm; }
.note {
  font-size: 7.8pt;
  color: #4A4554;
  background: #EAF3E4;
  padding: 1mm 2mm;
  border-radius: 3px;
  border: 0.5px solid #B8D2AE;
  line-height: 1.35;
}
.note-label {
  display: inline-block;
  background: #B8D2AE;
  color: #4A4554;
  padding: 0 4px;
  border-radius: 3px;
  font-size: 6.5pt;
  font-weight: 800;
  letter-spacing: 0.4px;
  margin-right: 3px;
  vertical-align: 1px;
}
footer {
  margin-top: 3mm;
  padding-top: 2mm;
  border-top: 0.6px solid #B0ACB8;
  font-size: 7pt;
  color: #7A7585;
  text-align: center;
  font-weight: 600;
}
@media print {
  body { background: white; }
  .card { background: white; }
}
'''


def main():
    total = len(CARDS)
    # 5 pages distribution
    # L1 (5) + L2 (6) = 11 cards → p1
    # L3 (5) + L4 (5) = 10 → p2
    # L5 (5) + L6 (5) = 10 → p3
    # L7 (5) + L8 (5) = 10 → p4
    # L9 (4) + L10 (5) + L11 (4) + L12 (6) = 19 → p5 (a bit denser)
    # But fits → let me count: 5+6+5+5+5+5+5+5+4+5+4+6 = 60
    pages = []
    boundaries = [
        (0, 11, "L1-2 · Basics: copula, demonstratives, particles"),
        (11, 21, "L3-4 · Verbs, existence, time"),
        (21, 31, "L5-6 · Adjectives, te-form ★"),
        (31, 41, "L7-8 · ~ている, particle が, short forms"),
        (41, total, "L9-12 · Past, comparison, ~たい, ~んです"),
    ]
    for i, (s, e, title) in enumerate(boundaries):
        pages.append(page(s, e, i + 1, len(boundaries), title))

    body = "\n".join(pages)
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Genki L1-12 Grammar — Japanese Universe</title>
<style>{CSS}</style>
</head>
<body>
{body}
</body>
</html>
'''
    OUT.write_text(html, encoding="utf-8")
    counts = [e - s for s, e, _ in boundaries]
    print(f"OK  {OUT.relative_to(OUT.parent.parent.parent)}")
    print(f"    cards: {total}")
    print(f"    pages: {len(boundaries)} ({' / '.join(str(c) for c in counts)} cards)")
    print()
    print(f"Open: start {OUT}    (Windows)")
    print(f"Print: Chrome -> Ctrl+P -> Save as PDF / A4")
    print(f"  Margins: Default ('@page' rule overrides to 8mm/10mm)")
    print(f"  Background graphics: ON (so chips/boxes show color)")


if __name__ == "__main__":
    main()
