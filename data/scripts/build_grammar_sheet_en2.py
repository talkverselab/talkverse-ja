"""
Genki L1-12 Grammar Sheet v2 — for native English speakers (in-depth, NOT just memorize).
Each card: WHEN to use, HOW to form (all verb groups), 2-3 examples, COMPARE with similar,
common MISTAKES. ~60 cards / ~8 pages, single-column dense layout.

usage:
  python db/scripts/build_grammar_sheet_en2.py
  → db/sheets/genki_l1_12_a4_en2.html
"""
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "sheets" / "genki_l1_12_a4_en2.html"
OUT.parent.mkdir(parents=True, exist_ok=True)

# Card = dict with rich fields. (No tuple — too rigid)
CARDS = [
    # ─────────────── L1 ───────────────
    {
        "lesson": 1, "jlpt": "N5",
        "ja": "X は Y です", "romaji": "X wa Y desu",
        "title": "Identity / topic-comment sentence",
        "usage": (
            "The most fundamental Japanese sentence pattern. は (pronounced 'wa') marks the TOPIC — "
            "what the sentence is about. です is a polite copula equivalent to 'is/am/are', but it carries "
            "POLITENESS, not just identity. The sentence does NOT explicitly state who or what 'I'/'you' refers to — "
            "Japanese drops the subject when context makes it clear."
        ),
        "form": (
            "Topic + は + Predicate noun + です. "
            "NEGATIVE: です → では ありません (formal) or じゃ ありません (spoken). "
            "PAST: です → でした. PAST NEG: では ありませんでした."
        ),
        "ex": [
            ("私は学生です。", "Watashi wa gakusei desu.", "I am a student."),
            ("田中さんは医者ではありません。", "Tanaka-san wa isha de wa arimasen.", "Mr. Tanaka is not a doctor."),
            ("これは本でした。", "Kore wa hon deshita.", "This was a book."),
        ],
        "compare": "は marks TOPIC (what the sentence is ABOUT); が marks SUBJECT (often new info). See L8.",
        "mistakes": "(1) Writing は as 'ha' in romaji — always pronounced 'wa' as a particle. "
                    "(2) Overusing 私は — Japanese drops the topic when obvious from context.",
    },
    {
        "lesson": 1, "jlpt": "N5",
        "ja": "~の~", "romaji": "~no~",
        "title": "Connecting nouns: possessive, attributive, compositional",
        "usage": (
            "の glues two nouns together. The first noun describes/owns/specifies the second. "
            "Much more versatile than English '-s' or 'of' — covers possession, origin, category, role, "
            "and even quantity expressions."
        ),
        "form": "Noun₁ + の + Noun₂. Read RIGHT-TO-LEFT: 'Noun₂ that is of Noun₁'.",
        "ex": [
            ("山田さんの本", "Yamada-san no hon", "Yamada's book (possession)"),
            ("日本の歌", "Nihon no uta", "Japanese songs (origin/type)"),
            ("数学の先生", "Suugaku no sensei", "Math teacher (role)"),
        ],
        "compare": "Can chain: 私の友達の家 = my friend's house. Each の adds one layer.",
        "mistakes": "DO NOT use between an adjective and noun. 大きい本 (not 大きいの本). の only links NOUNS.",
    },
    {
        "lesson": 1, "jlpt": "N5",
        "ja": "~か (question)", "romaji": "~ka",
        "title": "Sentence-ending question marker",
        "usage": (
            "Add か to the end of a statement to make a yes/no question. NO word-order change like English. "
            "Intonation does NOT need to rise (the か already signals a question), though it often does in speech. "
            "Question mark '?' is optional after か."
        ),
        "form": "Full statement + か (then ? in writing, optional).",
        "ex": [
            ("学生ですか。", "Gakusei desu ka.", "Are you a student?"),
            ("行きますか？", "Ikimasu ka?", "Will you go?"),
            ("何時ですか？", "Nan-ji desu ka?", "What time is it?"),
        ],
        "compare": "In casual speech, just rising intonation is enough (no か): 学生？ Ikuno?",
        "mistakes": "Don't double up: '行きますか？' is fine, '行く？か' is wrong.",
    },
    {
        "lesson": 1, "jlpt": "N5",
        "ja": "X も Y", "romaji": "X mo Y",
        "title": "X also / X too (additive particle)",
        "usage": (
            "も replaces は or を to mean 'also/too'. It indicates the noun joins others that share the same predicate."
        ),
        "form": "Noun + も (replaces は or を). Sentence structure otherwise unchanged.",
        "ex": [
            ("私も学生です。", "Watashi mo gakusei desu.", "I am also a student."),
            ("コーヒーも飲みます。", "Koohii mo nomimasu.", "I drink coffee too."),
            ("田中さんも来ました。", "Tanaka-san mo kimashita.", "Mr. Tanaka also came."),
        ],
        "compare": "は + も becomes も alone (も replaces は). Same for を + も = も.",
        "mistakes": "Don't say 私はも — it should be just 私も.",
    },
    {
        "lesson": 1, "jlpt": "N5",
        "ja": "Numbers & age", "romaji": "ichi, ni, san...",
        "title": "Basic counting and age",
        "usage": (
            "Numbers 1-10 are foundational. Age uses ~歳 (sai). Time uses ~時 (ji). "
            "Several numbers have alternate readings depending on counter."
        ),
        "form": "Number + counter. 1=ichi, 2=ni, 3=san, 4=yon/shi, 5=go, 6=roku, 7=nana/shichi, 8=hachi, 9=kyuu/ku, 10=juu.",
        "ex": [
            ("二十歳です。", "Hatachi desu.", "I am 20 years old."),
            ("三時です。", "San-ji desu.", "It's 3 o'clock."),
            ("四人います。", "Yo-nin imasu.", "There are 4 people."),
        ],
        "compare": "Age 20 is irregular: hatachi (not nijus-sai). 4 with people is yo-nin (not yon-nin).",
        "mistakes": "4 and 7 have two readings (yon/shi, nana/shichi). 4-o'clock = yo-ji (not shi-ji which sounds like 'death').",
    },

    # ─────────────── L2 ───────────────
    {
        "lesson": 2, "jlpt": "N5",
        "ja": "これ / それ / あれ / どれ", "romaji": "kore / sore / are / dore",
        "title": "Demonstrative pronouns (this/that/that-far/which)",
        "usage": (
            "Stand-alone pronouns referring to physical objects. Three-way spatial system based on PROXIMITY: "
            "これ = near speaker, それ = near listener (or just mentioned), あれ = far from BOTH, どれ = which (of multiple options)."
        ),
        "form": "Use directly as nouns. Often the topic: これは / それは / あれは. Question: どれですか？",
        "ex": [
            ("これは何ですか。", "Kore wa nan desu ka.", "What is this?"),
            ("それは私の本です。", "Sore wa watashi no hon desu.", "That (near you) is my book."),
            ("どれがいいですか？", "Dore ga ii desu ka?", "Which one is good?"),
        ],
        "compare": "Distinct from この/その/あの (which MODIFY a noun). これは works alone, この alone is incomplete.",
        "mistakes": "あの with no noun = filler 'um/well'. あれ = 'that thing over there'. Don't confuse.",
    },
    {
        "lesson": 2, "jlpt": "N5",
        "ja": "この / その / あの / どの + N", "romaji": "kono / sono / ano / dono + Noun",
        "title": "Demonstrative adjectives (this/that + noun)",
        "usage": (
            "Used BEFORE a noun to specify which one. Cannot stand alone. Same proximity logic as これ/それ/あれ."
        ),
        "form": "[kono/sono/ano/dono] + Noun. Always attached.",
        "ex": [
            ("この本は私のです。", "Kono hon wa watashi no desu.", "This book is mine."),
            ("その人は誰ですか？", "Sono hito wa dare desu ka?", "Who is that person (near you)?"),
            ("あの店", "ano mise", "that shop over there"),
        ],
        "compare": "これ = 'this' (alone); この = 'this Noun'. Forgetting to attach the noun is the #1 beginner error.",
        "mistakes": "Saying 'kono wa' is wrong — must be 'kore wa' (alone) or 'kono N wa' (with noun).",
    },
    {
        "lesson": 2, "jlpt": "N5",
        "ja": "ここ / そこ / あそこ / どこ", "romaji": "koko / soko / asoko / doko",
        "title": "Location pronouns (here / there / over there / where)",
        "usage": (
            "Stand-alone PLACE references. Same three-way spatial system. あそこ is 'over there' "
            "(distant from both speaker and listener) — Japanese is more spatially precise than English 'there'."
        ),
        "form": "Use as a noun (subject, object, location). Often with particles: ここに (here-at), ここで (here-at/in)…",
        "ex": [
            ("トイレはどこですか？", "Toire wa doko desu ka?", "Where is the toilet?"),
            ("ここで待ってください。", "Koko de matte kudasai.", "Please wait here."),
            ("あそこに猫がいます。", "Asoko ni neko ga imasu.", "There's a cat over there."),
        ],
        "compare": "に = location of existence (with ある/いる). で = location of activity (動作).",
        "mistakes": "Confusing そこ ('there, near you') with あそこ ('there, far from both').",
    },
    {
        "lesson": 2, "jlpt": "N5",
        "ja": "~ね / ~よ", "romaji": "~ne / ~yo",
        "title": "Sentence-final particles (agreement / new info)",
        "usage": (
            "Soft sentence endings that add SOCIAL/EMOTIONAL nuance, not new information. "
            "ね = seeking agreement (English 'right?' or 'isn't it?'). よ = telling the listener something they don't know "
            "(English 'you know' or 'FYI'). Mastering these makes Japanese sound natural; ignoring them sounds robotic."
        ),
        "form": "Statement + ね / よ. Can combine: ~よね = 'right? (I think you'd agree)'.",
        "ex": [
            ("今日は寒いですね。", "Kyou wa samui desu ne.", "It's cold today, isn't it?"),
            ("もう行きますよ。", "Mou ikimasu yo.", "I'm leaving now (FYI)."),
            ("これ、おいしいですよね。", "Kore, oishii desu yo ne.", "This is delicious, right?"),
        ],
        "compare": "ね pulls listener IN (shared experience). よ pushes information OUT.",
        "mistakes": "Overusing よ can sound bossy or preachy. Use sparingly. ね overuse sounds clingy.",
    },
    {
        "lesson": 2, "jlpt": "N5",
        "ja": "~じゃ ありません", "romaji": "~ja arimasen",
        "title": "Negation of nouns and な-adjectives",
        "usage": (
            "The negative form of です. Used after nouns and な-adjectives. じゃ is the spoken contraction of では. "
            "Casual form drops です: ~じゃない."
        ),
        "form": "Noun/な-adj + じゃ ありません (formal spoken) / では ありません (very formal) / じゃ ない (casual).",
        "ex": [
            ("学生じゃありません。", "Gakusei ja arimasen.", "I'm not a student."),
            ("これは私の本ではありません。", "Kore wa watashi no hon de wa arimasen.", "This is not my book."),
            ("ハンサムじゃない。", "Hansamu ja nai.", "(He's) not handsome. (casual)"),
        ],
        "compare": "い-adjectives use a DIFFERENT pattern: 高い → 高くない (drop い, add くない). See L5.",
        "mistakes": "Don't say 学生 ありません alone. Always need じゃ/では before ありません.",
    },
    {
        "lesson": 2, "jlpt": "N5",
        "ja": "誰の N (whose N)", "romaji": "dare no N",
        "title": "Whose ~? (interrogative possessive)",
        "usage": "Same の possessive pattern, with 誰 ('who') as the owner.",
        "form": "誰 + の + Noun. Often as topic: 誰の N ですか？",
        "ex": [
            ("誰のかばんですか？", "Dare no kaban desu ka?", "Whose bag is it?"),
            ("これは誰のですか？", "Kore wa dare no desu ka?", "Whose is this?"),
        ],
        "compare": "誰 alone = 'who'. 誰の + N = 'whose N'. The の is REQUIRED for possessive.",
        "mistakes": "誰 でしょう ('Who is it?') vs. 誰の本 ('whose book') — don't drop の when asking about possession.",
    },

    # ─────────────── L3 ───────────────
    {
        "lesson": 3, "jlpt": "N5",
        "ja": "Verb ます-form (polite)", "romaji": "~masu",
        "title": "Polite present/future verb form",
        "usage": (
            "Default form for polite speech (with strangers, at work, in school). Covers BOTH present and future "
            "('I read' AND 'I will read'). Context disambiguates."
        ),
        "form": (
            "Group 1 (う-verbs / 五段): replace last う-sound with い-sound + ます. 書く→書きます. 飲む→飲みます. "
            "Group 2 (る-verbs / 一段): drop る + ます. 食べる→食べます. 見る→見ます. "
            "Irregular: する→します, 来る→きます. "
            "NEGATIVE: ~ます → ~ません. PAST: ~ました. PAST NEG: ~ませんでした."
        ),
        "ex": [
            ("本を読みます。", "Hon o yomimasu.", "I read a book / I will read a book."),
            ("毎日水を飲みます。", "Mainichi mizu o nomimasu.", "I drink water every day."),
            ("テレビを見ません。", "Terebi o mimasen.", "I don't watch TV."),
        ],
        "compare": "Plain/dictionary form (行く, 食べる, etc.) is used in casual speech. Same meaning, less polite.",
        "mistakes": "Confusing Group 1 vs Group 2. 帰る (kaeru = return) LOOKS like Group 2 but is Group 1 → 帰ります.",
    },
    {
        "lesson": 3, "jlpt": "N5",
        "ja": "Object particle を", "romaji": "~o",
        "title": "Direct object marker",
        "usage": "Marks the direct object of a transitive verb. Written を but pronounced 'o' (identical to お).",
        "form": "Object + を + Transitive verb.",
        "ex": [
            ("コーヒーを飲みます。", "Koohii o nomimasu.", "I drink coffee."),
            ("本を読みます。", "Hon o yomimasu.", "I read a book."),
            ("音楽を聞きます。", "Ongaku o kikimasu.", "I listen to music."),
        ],
        "compare": "を is used ONLY for direct objects. Compare に (direction/recipient) and で (means/location).",
        "mistakes": "With ~たい (want to), を often shifts to が: 水が飲みたい (vs 水を飲みます). See L11.",
    },
    {
        "lesson": 3, "jlpt": "N5",
        "ja": "Particles で / に / へ", "romaji": "de / ni / e",
        "title": "Location and direction particles",
        "usage": (
            "These three are massive English-speaker pitfalls. "
            "で = WHERE an action TAKES PLACE (activity location). "
            "に = (1) destination of motion, (2) target of action (recipient), (3) specific time, (4) existence location. "
            "へ = direction/general toward (less specific than に). Written へ, pronounced 'e'."
        ),
        "form": "Location/time + で OR に OR へ + Verb.",
        "ex": [
            ("学校で勉強します。", "Gakkou de benkyou shimasu.", "I study AT school. (で = activity)"),
            ("学校に行きます。", "Gakkou ni ikimasu.", "I go TO school. (に = destination)"),
            ("七時に起きます。", "Shichi-ji ni okimasu.", "I get up AT 7. (に = specific time)"),
        ],
        "compare": "に vs へ for destination: nearly interchangeable; に is more specific, へ feels more general/poetic. に vs で is the bigger trap — see usage.",
        "mistakes": "Saying '学校で行きます' (wrong) for 'go to school'. School is the DESTINATION (に), not the activity location.",
    },
    {
        "lesson": 3, "jlpt": "N5",
        "ja": "Frequency adverbs", "romaji": "yoku / tokidoki / amari / zenzen",
        "title": "How often something happens",
        "usage": (
            "Adverbs of frequency placed BEFORE the verb. NEGATIVE-frequency adverbs (あまり, ぜんぜん) MUST end "
            "with a negative verb form."
        ),
        "form": "Subject は frequency-adverb (Object を) Verb. あまり/ぜんぜん require negative verb at the end.",
        "ex": [
            ("よく映画を見ます。", "Yoku eiga o mimasu.", "I often watch movies."),
            ("時々日本に行きます。", "Tokidoki Nihon ni ikimasu.", "Sometimes I go to Japan."),
            ("あまり食べません。", "Amari tabemasen.", "I don't eat much."),
        ],
        "compare": "Frequency scale: いつも (always) > よく (often) > 時々 (sometimes) > あまり (not much, NEG) > ぜんぜん (never, NEG).",
        "mistakes": "Saying 'あまり食べます' is wrong — must be the negative 'あまり食べません'.",
    },
    {
        "lesson": 3, "jlpt": "N5",
        "ja": "Word order — SOV", "romaji": "Subject-Object-Verb",
        "title": "Japanese sentence structure",
        "usage": (
            "Japanese is SOV (verb at the end). Particles do the grammatical work, so element order is somewhat "
            "flexible EXCEPT the verb stays at the end. This is THE biggest mental shift for English speakers — "
            "you must 'hold' the subject/object in mind until the verb arrives."
        ),
        "form": (
            "[Topic は] [Time に] [Place で] [Object を] [Verb]. "
            "All elements before the verb can be reordered (with particles preserving role)."
        ),
        "ex": [
            ("私はパンを食べます。", "Watashi wa pan o tabemasu.", "I eat bread. (S-O-V)"),
            ("毎日学校で勉強します。", "Mainichi gakkou de benkyou shimasu.", "I study at school every day."),
            ("田中さんに本を貸しました。", "Tanaka-san ni hon o kashimashita.", "I lent a book to Mr. Tanaka."),
        ],
        "compare": "English SVO vs Japanese SOV: 'I eat pan' becomes 'I-wa pan-o eat'.",
        "mistakes": "Forgetting to wait for the verb when listening. Train yourself to mentally collect info until the verb hits.",
    },

    # ─────────────── L4 ───────────────
    {
        "lesson": 4, "jlpt": "N5",
        "ja": "ある / いる (existence)", "romaji": "aru / iru",
        "title": "There is / there are",
        "usage": (
            "Existence verbs split by ANIMACY. ある = inanimate (objects, plants, ideas, events). "
            "いる = animate (people, animals, insects sometimes). Subject takes が."
        ),
        "form": "Subject + が + ある/いる (or polite: あります / います). Location: 〇〇に Noun が ある/いる.",
        "ex": [
            ("猫がいます。", "Neko ga imasu.", "There is a cat. (animate)"),
            ("本があります。", "Hon ga arimasu.", "There is a book. (inanimate)"),
            ("公園に子供がたくさんいます。", "Kouen ni kodomo ga takusan imasu.", "There are many children in the park."),
        ],
        "compare": "ある is also used for events: パーティーがあります (there's a party). 持つ vs ある: 持つ = actively hold; ある = passively exist with the owner.",
        "mistakes": "Calling plants/cars animate (use ある). Robots and dolls — use ある (treated as objects).",
    },
    {
        "lesson": 4, "jlpt": "N5",
        "ja": "Past tense (~ました / でした)", "romaji": "~mashita / ~deshita",
        "title": "Polite past tense",
        "usage": "Forms past tense by replacing the polite ending. Same for verbs and copula.",
        "form": "Verb ます → ました. Negative past: ません → ませんでした. Noun/な-adj です → でした. い-adj see L5.",
        "ex": [
            ("昨日学校へ行きました。", "Kinou gakkou e ikimashita.", "I went to school yesterday."),
            ("昨日は雨でした。", "Kinou wa ame deshita.", "It was rainy yesterday."),
            ("食べませんでした。", "Tabemasen deshita.", "I didn't eat."),
        ],
        "compare": "い-adjectives form past differently: 高い → 高かった (NOT 高いでした). See L5.",
        "mistakes": "Treating い-adj past like noun past (incorrect: 高いでした). The correct form is 高かったです.",
    },
    {
        "lesson": 4, "jlpt": "N5",
        "ja": "Location nouns (上下中前後)", "romaji": "ue / shita / naka / mae / ushiro",
        "title": "Spatial relations as nouns",
        "usage": (
            "Japanese describes spatial relations as NOUNS (the top of, the inside of), not prepositions. "
            "Sequence: [reference object] の [location noun] に [thing] が ある/いる."
        ),
        "form": "Noun + の + (上/下/中/前/後ろ/となり/間) + に + Subject + が + ある/いる.",
        "ex": [
            ("机の上に本があります。", "Tsukue no ue ni hon ga arimasu.", "There is a book on the desk."),
            ("家の前に車があります。", "Ie no mae ni kuruma ga arimasu.", "There is a car in front of the house."),
            ("私の隣に田中さんがいます。", "Watashi no tonari ni Tanaka-san ga imasu.", "Mr. Tanaka is next to me."),
        ],
        "compare": "となり = next to (same kind, e.g., person to person). よこ = beside (anything). そば = nearby.",
        "mistakes": "Forgetting の between reference noun and location noun. 'On the desk' is 'tsukue no ue ni', NOT 'tsukue ue ni'.",
    },
    {
        "lesson": 4, "jlpt": "N5",
        "ja": "Time に / で", "romaji": "~ni / ~de",
        "title": "Time particles",
        "usage": (
            "に for SPECIFIC times (clock times, dates, days of the week). NO に for relative time words "
            "(今日, 明日, 昨日, 毎日). で also marks duration limits."
        ),
        "form": "[Specific-time] に + Verb. [Relative-time] (no particle) + Verb.",
        "ex": [
            ("七時に起きます。", "Shichi-ji ni okimasu.", "I get up at 7."),
            ("月曜日に会いましょう。", "Getsuyoubi ni aimashou.", "Let's meet on Monday."),
            ("今日は忙しいです。", "Kyou wa isogashii desu.", "I'm busy today. (no に on 今日)"),
        ],
        "compare": "Time に = pinned point. で can mark duration: 一週間で終わる (finish IN a week).",
        "mistakes": "Adding に to 今日/明日 (wrong). Use them bare or with は.",
    },
    {
        "lesson": 4, "jlpt": "N5",
        "ja": "~と (with someone)", "romaji": "~to",
        "title": "Together with",
        "usage": (
            "Marks accompaniment. Person/thing you're doing the action WITH. Same particle と is also used for "
            "exhaustive listing of nouns ('A と B') — context distinguishes."
        ),
        "form": "Person + と + (Verb). For 'together': と + 一緒に + Verb (more emphatic).",
        "ex": [
            ("友達と映画を見ます。", "Tomodachi to eiga o mimasu.", "I watch a movie with a friend."),
            ("家族と日本へ行きました。", "Kazoku to Nihon e ikimashita.", "I went to Japan with my family."),
            ("田中さんと一緒に食べました。", "Tanaka-san to issho ni tabemashita.", "I ate together with Tanaka."),
        ],
        "compare": "と (with) and と (and) look identical. Listing: 本とノート (book and notebook). Accompaniment: 友達と (with friend).",
        "mistakes": "Don't combine と with や (these list things differently — see L11).",
    },

    # ─────────────── L5 ───────────────
    {
        "lesson": 5, "jlpt": "N5",
        "ja": "い-adjectives", "romaji": "i-adjectives",
        "title": "True (conjugating) adjectives",
        "usage": (
            "い-adjectives carry tense and negation themselves — they are NOT just nouns. Always end in い in "
            "dictionary form (high: 高い, cheap: 安い). One major exception: いい/良い (good) is irregular — "
            "use よい as the root for most conjugations."
        ),
        "form": (
            "Affirmative present: 高い. Negative present: drop い + くない → 高くない. "
            "Past affirmative: drop い + かった → 高かった. Past negative: drop い + くなかった → 高くなかった. "
            "Add です for politeness (高いです, 高くないです). NEVER 高いでした."
        ),
        "ex": [
            ("この本は高いです。", "Kono hon wa takai desu.", "This book is expensive."),
            ("昨日は寒かった。", "Kinou wa samukatta.", "Yesterday was cold."),
            ("おいしくなかったです。", "Oishikunakatta desu.", "It wasn't tasty."),
        ],
        "compare": "い-adj. conjugate themselves. な-adj. need です/だ to express tense.",
        "mistakes": "(1) Saying 高いでした (wrong) instead of 高かったです. (2) Forgetting いい → よ- in conjugation: いい → よくない (not いくない).",
    },
    {
        "lesson": 5, "jlpt": "N5",
        "ja": "な-adjectives", "romaji": "na-adjectives",
        "title": "Quasi-noun adjectives",
        "usage": (
            "な-adjectives behave like NOUNS for conjugation. To modify another noun, add な (静かな町 = a quiet town). "
            "In predicate position, treat like a noun: 静かです (it is quiet). Includes loanwords like ハンサム, きれい."
        ),
        "form": (
            "Modifying noun: な-adj + な + Noun (静かな町). "
            "Predicate: な-adj + です / じゃ ありません. "
            "Past: + でした / じゃ ありませんでした. "
            "NO な before です."
        ),
        "ex": [
            ("あの町は静かです。", "Ano machi wa shizuka desu.", "That town is quiet."),
            ("ハンサムな人", "Hansamu na hito", "a handsome person"),
            ("きれいじゃありませんでした。", "Kirei ja arimasen deshita.", "It wasn't pretty."),
        ],
        "compare": "Some adjectives LOOK like い-adj but are な-adj: きれい (pretty), 嫌い (dislike). きれいくない is WRONG → きれいじゃない.",
        "mistakes": "Treating きれい / 嫌い as い-adjectives. They are な-adj despite ending in い.",
    },
    {
        "lesson": 5, "jlpt": "N5",
        "ja": "好き / 嫌い (like/dislike — な-adj)", "romaji": "suki / kirai",
        "title": "Like and dislike (with が)",
        "usage": (
            "好き ('liked') and 嫌い ('disliked') are na-adjectives, NOT verbs. The thing liked takes が, not を. "
            "The English construction 'I like X' becomes Japanese '(X) is likable (to me)' — passive in logic."
        ),
        "form": "Person は Thing が 好き/嫌い (です). Degrees: 大好き (love), 大嫌い (hate).",
        "ex": [
            ("犬が好きです。", "Inu ga suki desu.", "I like dogs."),
            ("ピアノが大好きです。", "Piano ga daisuki desu.", "I love piano."),
            ("私は朝が嫌いです。", "Watashi wa asa ga kirai desu.", "I dislike mornings."),
        ],
        "compare": "好き with を is a common error. Verbs like 食べる use を. 好きだ is na-adj using が.",
        "mistakes": "Saying 犬を好きです (wrong) — must be 犬が好きです.",
    },
    {
        "lesson": 5, "jlpt": "N5",
        "ja": "Counters (~まい ~ほん ~こ etc.)", "romaji": "~mai / ~hon / ~ko",
        "title": "Object-specific counters",
        "usage": (
            "Japanese requires a 'counter' suffix on numbers based on the shape/category of the counted item. "
            "Hundreds exist; start with the most common: ~つ (general 1-10), ~人 (people), ~枚 (flat: paper, sheet), "
            "~本 (long/cylindrical: bottles, pencils), ~個 (small things), ~冊 (books/notebooks)."
        ),
        "form": "Number + counter. Often placed before the verb: Object を [number-counter] Verb.",
        "ex": [
            ("りんごを三つください。", "Ringo o mittsu kudasai.", "Three apples, please. (general counter)"),
            ("ビールを二本飲みました。", "Biiru o ni-hon nomimashita.", "I drank two bottles of beer."),
            ("紙を五枚ください。", "Kami o go-mai kudasai.", "Five sheets of paper, please."),
        ],
        "compare": "~つ works as a fallback for most things up to 10. When unsure, native speakers often default to ~つ or ~個.",
        "mistakes": "~本 sound changes: 一本=ippon, 三本=sanbon, 六本=roppon, 八本=happon. Many counters have sound shifts.",
    },
    {
        "lesson": 5, "jlpt": "N5",
        "ja": "~ましょう / ~ましょうか", "romaji": "~mashou / ~mashou ka",
        "title": "Let's ~ / Shall we ~?",
        "usage": (
            "~ましょう makes a suggestion to do something TOGETHER with the listener. "
            "~ましょうか makes the same a question (more polite, gives the listener choice). "
            "Used for proposals, plans, friendly suggestions."
        ),
        "form": "Verb stem (drop ます) + ましょう / ましょうか.",
        "ex": [
            ("一緒に行きましょう。", "Issho ni ikimashou.", "Let's go together."),
            ("コーヒーを飲みましょうか？", "Koohii o nomimashou ka?", "Shall we drink coffee?"),
            ("そろそろ帰りましょう。", "Sorosoro kaerimashou.", "Let's head home now."),
        ],
        "compare": "~ましょうか offers help to someone else (Shall I do X for you?). ~ませんか invites them (Would you like to do X with me?).",
        "mistakes": "Using ~ましょう when speaking only about yourself. It implies the listener is included.",
    },

    # ─────────────── L6 (te-form heavy) ───────────────
    {
        "lesson": 6, "jlpt": "N5",
        "ja": "te-form (て形) ★", "romaji": "te-form",
        "title": "★ The connective form — connects clauses, makes requests, allows actions",
        "usage": (
            "★ THE most crucial grammatical form in early Japanese. te-form is used for: (1) joining sentences "
            "(do X and then Y), (2) polite requests (~てください), (3) permission/prohibition (~てもいい / ~てはいけない), "
            "(4) ongoing action / state (~ている). Mastering te-form unlocks dozens of grammar patterns."
        ),
        "form": (
            "Group 1 (う-verbs): depends on last syllable. "
            "う/つ/る → って. 買う→買って, 待つ→待って, 帰る→帰って. "
            "む/ぶ/ぬ → んで. 飲む→飲んで, 遊ぶ→遊んで, 死ぬ→死んで. "
            "く → いて (exception: 行く→行って). 書く→書いて. "
            "ぐ → いで. 泳ぐ→泳いで. "
            "す → して. 話す→話して. "
            "Group 2 (る-verbs): drop る + て. 食べる→食べて, 見る→見て. "
            "Irregular: する→して, 来る→きて."
        ),
        "ex": [
            ("本を読んで、寝ました。", "Hon o yonde, nemashita.", "I read a book and (then) slept."),
            ("ここに座ってください。", "Koko ni suwatte kudasai.", "Please sit here."),
            ("今、勉強しています。", "Ima, benkyou shite imasu.", "I am studying now."),
        ],
        "compare": "te-form is morphologically identical to past plain form's stem (~た becomes ~て). Memorize via ~んで/~いて/~って patterns.",
        "mistakes": "(1) 行く is the exception: 行って (not 行いて). (2) Group 1 vs Group 2 confusion — verbs ending in eru/iru COULD be either; you must learn group per verb.",
    },
    {
        "lesson": 6, "jlpt": "N5",
        "ja": "~から (reason)", "romaji": "~kara",
        "title": "Because ~",
        "usage": (
            "Subordinate conjunction meaning 'because'. The REASON clause comes FIRST, ending in から, followed by the "
            "main clause (the result/consequence)."
        ),
        "form": "[Reason clause] から、[Main clause]. Used with です/plain forms.",
        "ex": [
            ("寒いから、ジャケットを着ます。", "Samui kara, jaketto o kimasu.", "Because it's cold, I'll wear a jacket."),
            ("お金がないから、行きません。", "Okane ga nai kara, ikimasen.", "I won't go because I have no money."),
            ("好きだから、買いました。", "Suki da kara, kaimashita.", "I bought it because I like it."),
        ],
        "compare": "Same から also means 'from' (starting point): 朝から (from morning). Context distinguishes.",
        "mistakes": "Putting the reason SECOND (English-style). 'X because Y' in Japanese is 'Y kara X'.",
    },
    {
        "lesson": 6, "jlpt": "N5",
        "ja": "~てください (please do)", "romaji": "~te kudasai",
        "title": "Polite request",
        "usage": (
            "Polite imperative — asking someone to do something. ください literally means 'give', but here it's a fixed "
            "polite request marker. Used freely with strangers, not begging."
        ),
        "form": "Verb te-form + ください. NEGATIVE: ~ないで ください ('please do not ~').",
        "ex": [
            ("ここに座ってください。", "Koko ni suwatte kudasai.", "Please sit here."),
            ("ゆっくり話してください。", "Yukkuri hanashite kudasai.", "Please speak slowly."),
            ("写真を撮らないでください。", "Shashin o toranaide kudasai.", "Please don't take photos."),
        ],
        "compare": "Even more polite request: ~ていただけませんか (could you possibly ~?). Casual: ~て (just te-form alone).",
        "mistakes": "Treating ください as begging — it's a NORMAL polite request, used in shops, schools, etc.",
    },
    {
        "lesson": 6, "jlpt": "N5",
        "ja": "~てもいい / ~てはいけない", "romaji": "~temo ii / ~te wa ikenai",
        "title": "May ~ / Must not ~ (permission / prohibition)",
        "usage": (
            "Combines te-form with も いい (it's OK even if ~) for permission, or with は いけません (it won't do if ~) "
            "for prohibition. Common in school/workplace settings."
        ),
        "form": (
            "Permission: Verb-te + も いい (です). Question form: ~てもいいですか？ "
            "Prohibition: Verb-te + は いけません / だめ. Casual: ~ちゃ だめ (contracted)."
        ),
        "ex": [
            ("ここでタバコを吸ってもいいですか？", "Koko de tabako o sutte mo ii desu ka?", "May I smoke here?"),
            ("はい、いいですよ。", "Hai, ii desu yo.", "Yes, it's fine."),
            ("ここで写真を撮ってはいけません。", "Koko de shashin o totte wa ikemasen.", "You may not take photos here."),
        ],
        "compare": "~ても = 'even if'. The base concept: 'Even if you do X, it's OK' = permission.",
        "mistakes": "Using で (instead of ても) in permission. The fixed pattern is ~てもいい, not ~でもいい (unless で is from a noun: 鉛筆でもいい = a pencil is also fine).",
    },
    {
        "lesson": 6, "jlpt": "N5",
        "ja": "~ましょうか (shall I?)", "romaji": "~mashou ka",
        "title": "Shall I do ~ for you? (offer)",
        "usage": (
            "Polite offer to do something for someone. Distinct from ~ましょう (let's, together). "
            "~ましょうか can also mean 'shall we' in some contexts, but its main use is offering help."
        ),
        "form": "Verb stem (drop ます) + ましょうか.",
        "ex": [
            ("手伝いましょうか？", "Tetsudaimashou ka?", "Shall I help you?"),
            ("窓を開けましょうか？", "Mado o akemashou ka?", "Shall I open the window?"),
            ("コーヒーを入れましょうか？", "Koohii o iremashou ka?", "Shall I make coffee?"),
        ],
        "compare": "~ませんか? = inviting LISTENER to do something with you. ~ましょう = let's, together. ~ましょうか? = I'll do it for you (or shall we?).",
        "mistakes": "Confusing with ~ませんか. ~ませんか is an invitation; ~ましょうか is an offer of service.",
    },

    # ─────────────── L7 ───────────────
    {
        "lesson": 7, "jlpt": "N5",
        "ja": "Counting people (一人 二人...)", "romaji": "hitori / futari / sannin",
        "title": "People counter (~人)",
        "usage": "Counter for people. Numbers 1 and 2 are irregular. From 3 onwards: number + 人 (nin).",
        "form": "Number + 人. 1=hitori (一人), 2=futari (二人), 3=sannin (三人), 4=yonin (四人, NOT shinin), 5=gonin...",
        "ex": [
            ("三人います。", "Sannin imasu.", "There are three people."),
            ("家族は五人です。", "Kazoku wa go-nin desu.", "My family has 5 people."),
            ("一人で行きました。", "Hitori de ikimashita.", "I went alone."),
        ],
        "compare": "一人で = 'alone' / 二人で = 'as a pair'. Generally used adverbially with で.",
        "mistakes": "Reading 四人 as 'shinin' — that sounds like 死人 (dead person). Always 'yonin'.",
    },
    {
        "lesson": 7, "jlpt": "N5",
        "ja": "Verb stem + に行く (purpose)", "romaji": "~ni iku",
        "title": "Go (in order) to do ~",
        "usage": (
            "Expresses going somewhere for a purpose. The verb stem (without ます) acts as a 'noun of action'. "
            "Pairs with 行く (go), 来る (come), 帰る (return)."
        ),
        "form": "Verb stem + に + 行く/来る/帰る. With noun: Noun に 行く (e.g., 買い物に行く).",
        "ex": [
            ("買い物に行きます。", "Kaimono ni ikimasu.", "I'm going shopping."),
            ("映画を見に行きました。", "Eiga o mi ni ikimashita.", "I went to see a movie."),
            ("日本に勉強に来ました。", "Nihon ni benkyou ni kimashita.", "I came to Japan to study."),
        ],
        "compare": "に (here) marks PURPOSE, not destination. The destination is also に in the same sentence (Place に Purpose に Verb).",
        "mistakes": "Using full verb instead of stem: 食べるに行く (wrong) vs 食べに行く (correct).",
    },
    {
        "lesson": 7, "jlpt": "N5",
        "ja": "~ている (state/progressive) ★", "romaji": "~te iru",
        "title": "★ Be doing ~ OR be in the state of ~",
        "usage": (
            "★ Critical pattern with TWO meanings: (1) PROGRESSIVE — ongoing action ('is doing now'); "
            "(2) RESULTANT STATE — past action's result is ongoing ('is in a married state' = is married). "
            "Some verbs default to state meaning: 結婚している (am married), 知っている (know), 住んでいる (live)."
        ),
        "form": "Verb te-form + いる (polite: ~ています). Negative: ~ていない / ~ていません.",
        "ex": [
            ("今、本を読んでいます。", "Ima, hon o yonde imasu.", "I am reading a book now. (progressive)"),
            ("私は結婚しています。", "Watashi wa kekkon shite imasu.", "I am married. (resultant state)"),
            ("田中さんを知っていますか？", "Tanaka-san o shitte imasu ka?", "Do you know Mr. Tanaka? (state)"),
        ],
        "compare": "知る (find out) vs 知っている (know). Affirmative answer is 知っています (NOT 知ります). But negative: 知りません (NOT 知っていません).",
        "mistakes": "Using 知ります for 'I know' (wrong — that means 'I will find out'). The state of knowing is 知っています.",
    },
    {
        "lesson": 7, "jlpt": "N5",
        "ja": "te-form connecting sentences", "romaji": "te-form chaining",
        "title": "And then ~ / While ~ing (clause connector)",
        "usage": (
            "Connects two or more actions in sequence. The final verb carries the tense — everything before is "
            "neutral. Used heavily in narrative description."
        ),
        "form": "Clause1-te, Clause2-te, ..., Final Clause [tense].",
        "ex": [
            ("朝起きて、ご飯を食べて、出かけます。", "Asa okite, gohan o tabete, dekakemasu.", "I wake up, eat breakfast, and go out."),
            ("コーヒーを買って、公園に行きました。", "Koohii o katte, kouen ni ikimashita.", "I bought coffee and went to the park."),
            ("音楽を聞いて、勉強しています。", "Ongaku o kiite, benkyou shite imasu.", "I'm listening to music and studying."),
        ],
        "compare": "te-form chains imply sequence/simultaneity, neutral tone. から chain implies reason. と implies inevitable/causal.",
        "mistakes": "Using ました multiple times: 食べました、行きました (acceptable but stilted). te-form is smoother: 食べて、行きました.",
    },
    {
        "lesson": 7, "jlpt": "N5",
        "ja": "Family terms (mine vs yours)", "romaji": "haha / okaasan",
        "title": "In-group vs out-group family terms",
        "usage": (
            "Japanese strictly distinguishes terms for YOUR OWN family (humble) vs OTHER PEOPLE'S family (respectful). "
            "Saying お母さん about your own mother to outsiders sounds childish. Saying 母 about someone else's mother is rude."
        ),
        "form": (
            "OWN (humble): 父 chichi (father), 母 haha (mother), 兄 ani (older brother), "
            "姉 ane (older sister), 弟 otouto (younger brother), 妹 imouto (younger sister). "
            "OTHER (respectful): お父さん, お母さん, お兄さん, お姉さん, 弟さん, 妹さん."
        ),
        "ex": [
            ("母は医者です。", "Haha wa isha desu.", "My mother is a doctor."),
            ("お母さんは元気ですか？", "Okaasan wa genki desu ka?", "Is your mother well?"),
            ("私の兄は大学生です。", "Watashi no ani wa daigakusei desu.", "My older brother is a college student."),
        ],
        "compare": "Direct address (calling your own mom): always お母さん regardless of audience. Only descriptions to outsiders use 母.",
        "mistakes": "Calling someone else's mother just 母 (rude). Calling your own mother お母さん to outsiders (childish).",
    },

    # ─────────────── L8 ───────────────
    {
        "lesson": 8, "jlpt": "N5",
        "ja": "Particle が (subject marker)", "romaji": "~ga",
        "title": "★ Subject marker — the eternal が vs は puzzle",
        "usage": (
            "★ THE thorniest distinction in Japanese. Use が when: (1) the SUBJECT is new info or unknown — answering or "
            "asking 'who/what?'; (2) introducing existence (~がいる/ある); (3) with stative adjectives like 好き/嫌い/分かる; "
            "(4) in subordinate clauses where the subject is different from the main clause."
        ),
        "form": "Noun + が + Verb/Adjective. Subject takes が; topic (already known) takes は.",
        "ex": [
            ("誰が来ましたか？— 田中さんが来ました。", "Dare ga kimashita ka? Tanaka-san ga kimashita.", "Who came? Mr. Tanaka came."),
            ("空が青いです。", "Sora ga aoi desu.", "The sky is blue. (descriptive observation)"),
            ("日本語が分かります。", "Nihongo ga wakarimasu.", "I understand Japanese."),
        ],
        "compare": "は = 'as for X, it's Y' (X is topic, Y is new). が = 'X is the one that does/is Y' (X is new/the answer).",
        "mistakes": "Defaulting to は for everything. With 好き/嫌い/分かる/上手/下手, always use が for the object.",
    },
    {
        "lesson": 8, "jlpt": "N5",
        "ja": "何か / 何も", "romaji": "nanika / nanimo",
        "title": "Something / nothing (indefinite + interrogative)",
        "usage": (
            "Question word + か = 'some-' (something, someone, somewhere). Question word + も + NEGATIVE verb = "
            "'no-' (nothing, no one, nowhere). The も pattern REQUIRES a negative verb."
        ),
        "form": (
            "何 + か = 何か (something). 誰 + か = 誰か (someone). どこ + か = どこか (somewhere). いつ + か = いつか (sometime). "
            "何 + も + ない/V-ません = nothing. 誰も = no one. どこ(に)も = nowhere. いつも = always (exception!)."
        ),
        "ex": [
            ("何か食べますか？— 何も食べません。", "Nanika tabemasu ka? Nani mo tabemasen.", "Will you eat anything? — I won't eat anything."),
            ("誰か来ましたか？", "Dareka kimashita ka?", "Did someone come?"),
            ("どこにも行きませんでした。", "Doko ni mo ikimasen deshita.", "I didn't go anywhere."),
        ],
        "compare": "Exception: いつも means 'always' (positive!), NOT 'never'. Use いつも for routines.",
        "mistakes": "Forgetting to use NEGATIVE verb with も. 何も食べます (wrong) vs 何も食べません (correct).",
    },
    {
        "lesson": 8, "jlpt": "N5",
        "ja": "Short forms (普通体 / dictionary form)", "romaji": "futsuutai",
        "title": "Casual / plain verb forms",
        "usage": (
            "Plain forms (dictionary form, plain past, plain negative) are used: (1) with friends/family, "
            "(2) in writing, (3) before many grammar patterns (relative clauses, plain quotation, etc.). "
            "ます-forms cannot precede most grammar patterns — you NEED plain forms for advanced grammar."
        ),
        "form": (
            "Verbs: ます → dictionary (行きます → 行く). Negative: ません → ない (行きません → 行かない). "
            "Past: ました → た (行きました → 行った). Past neg: ませんでした → なかった (行きませんでした → 行かなかった). "
            "Copula: です → だ. でした → だった. じゃありません → じゃない."
        ),
        "ex": [
            ("今日は学校に行く。", "Kyou wa gakkou ni iku.", "I'm going to school today. (casual)"),
            ("昨日、寿司を食べた。", "Kinou, sushi o tabeta.", "I ate sushi yesterday."),
            ("行かないと思う。", "Ikanai to omou.", "I think I won't go. (plain form needed before と思う)"),
        ],
        "compare": "Politeness scale: plain (~ない) < polite (~ません) < humble (~ません おりません). Match register to social distance.",
        "mistakes": "Using polite forms with close friends (sounds distant). Using plain forms with strangers (rude).",
    },
    {
        "lesson": 8, "jlpt": "N5",
        "ja": "Qualifying nouns (relative clauses)", "romaji": "relative clauses",
        "title": "★ Adjective clauses — describing nouns with full sentences",
        "usage": (
            "★ Japanese relative clauses come BEFORE the noun (opposite of English 'who/which/that' clauses). "
            "No relative pronoun needed. The clause uses PLAIN form. Subject within clause uses が (not は)."
        ),
        "form": "[Plain-form clause] + Noun. Verb tense matches the meaning ('the book I read' = 私が読んだ本).",
        "ex": [
            ("あそこにいる人は誰ですか？", "Asoko ni iru hito wa dare desu ka?", "Who is the person over there?"),
            ("私が買った本", "Watashi ga katta hon", "The book I bought"),
            ("田中さんが作ったケーキ", "Tanaka-san ga tsukutta keeki", "The cake Tanaka made"),
        ],
        "compare": "English: 'The book THAT I bought'. Japanese: '[I-が bought] book'. No 'that/which/who'.",
        "mistakes": "(1) Using ます-form inside the clause (must be plain). (2) Using は inside the clause for subject (use が).",
    },
    {
        "lesson": 8, "jlpt": "N5",
        "ja": "Nominalizing with の / こと", "romaji": "verb + no / koto",
        "title": "Turning verbs into nouns",
        "usage": (
            "Plain form + の or こと turns a verb into a noun ('the act of ~ing', '~ing'). Used in many patterns. "
            "の and こと are mostly interchangeable; subtle preference: の for concrete/perceptual, こと for abstract."
        ),
        "form": "Plain-form verb + の / こと. Used as a noun (subject, object).",
        "ex": [
            ("本を読むのが好きです。", "Hon o yomu no ga suki desu.", "I like reading books."),
            ("日本に行くことができます。", "Nihon ni iku koto ga dekimasu.", "I can go to Japan."),
            ("彼が来るのを見ました。", "Kare ga kuru no o mimashita.", "I saw him coming."),
        ],
        "compare": "After 好き/嫌い: の preferred. After できる: こと standard. With 見る/聞く (perceptual): の.",
        "mistakes": "Mixing up which to use. When in doubt, の is generally safer in early speech.",
    },

    # ─────────────── L9 ───────────────
    {
        "lesson": 9, "jlpt": "N5",
        "ja": "Plain past affirmative (~た)", "romaji": "~ta",
        "title": "Casual past tense",
        "usage": (
            "Plain (casual) past form. Same conjugation rules as te-form, but swap て → た / で → だ. "
            "Mastering te-form gives you ta-form for free."
        ),
        "form": (
            "Apply te-form rules then swap. 行く → 行って → 行った. 食べる → 食べて → 食べた. "
            "Irregular: する → した, 来る → きた."
        ),
        "ex": [
            ("昨日、寿司を食べた。", "Kinou, sushi o tabeta.", "I ate sushi yesterday."),
            ("今、来た。", "Ima, kita.", "I just came."),
            ("もう読んだ。", "Mou yonda.", "I've already read it."),
        ],
        "compare": "た-form is the BASE for ~たことがある (experience), ~たほうがいい (advice), ~たり (listing actions), etc.",
        "mistakes": "Confusing past plain with te-form. 食べた = past. 食べて = connector/te-form.",
    },
    {
        "lesson": 9, "jlpt": "N5",
        "ja": "Plain past negative (~なかった)", "romaji": "~nakatta",
        "title": "Casual past negative",
        "usage": "Negative past plain form. Built from ~ない (negative) following い-adjective conjugation rules.",
        "form": "Plain neg ~ない → drop い + かった → ~なかった. 食べない → 食べなかった. 行かない → 行かなかった.",
        "ex": [
            ("昨日、食べなかった。", "Kinou, tabenakatta.", "I didn't eat yesterday."),
            ("分からなかった。", "Wakaranakatta.", "I didn't understand."),
            ("お金がなかった。", "Okane ga nakatta.", "I had no money."),
        ],
        "compare": "ない conjugates exactly like an い-adjective. Same pattern in past, past negative, etc.",
        "mistakes": "Saying 食べないでした (wrong) or 食べないかった (wrong). Correct: 食べなかった.",
    },
    {
        "lesson": 9, "jlpt": "N5",
        "ja": "~から (because, plain form)", "romaji": "~kara",
        "title": "Because (in casual speech)",
        "usage": "Same から (because) introduced in L6, now usable with plain forms in casual contexts.",
        "form": "[Plain form clause] から、[main clause].",
        "ex": [
            ("雨が降ったから、行かなかった。", "Ame ga futta kara, ikanakatta.", "I didn't go because it rained."),
            ("忙しいから、後で電話する。", "Isogashii kara, ato de denwa suru.", "I'm busy, so I'll call later."),
            ("好きだから、いつも食べる。", "Suki da kara, itsumo taberu.", "I always eat it because I like it."),
        ],
        "compare": "Polite ~ので (L12) sounds softer in formal/polite situations.",
        "mistakes": "Forgetting だ after な-adj/noun: 静かだから (yes) vs 静かから (no).",
    },
    {
        "lesson": 9, "jlpt": "N5",
        "ja": "まだ ~ていません", "romaji": "mada ~te imasen",
        "title": "Have not yet ~",
        "usage": "Expresses an action that has not happened YET (but is expected to). Uses ~ていません, NOT past negative.",
        "form": "まだ + Verb te-form + いません.",
        "ex": [
            ("まだ食べていません。", "Mada tabete imasen.", "I haven't eaten yet."),
            ("まだ宿題をしていません。", "Mada shukudai o shite imasen.", "I haven't done homework yet."),
            ("まだ起きていない。", "Mada okite inai.", "(He) hasn't woken up yet."),
        ],
        "compare": "もう食べました (already ate) vs まだ食べていません (haven't eaten yet) — opposite pair.",
        "mistakes": "Saying まだ食べませんでした (incorrect — that's 'didn't eat'). The 'not yet' nuance requires ~ていません.",
    },

    # ─────────────── L10 ───────────────
    {
        "lesson": 10, "jlpt": "N5",
        "ja": "Comparison: より / のほうが", "romaji": "~yori / ~no hou ga",
        "title": "X is more ~ than Y",
        "usage": (
            "Standard comparison. より = 'than', のほうが = 'is more'. Word order can flip. Often question form: "
            "'Which is more X — A or B?'"
        ),
        "form": (
            "X の ほう が ~ (より Y より). Or: Y より X の ほう が ~. "
            "Question: A と B と、どちら の ほう が ~ ですか？"
        ),
        "ex": [
            ("犬より猫のほうが好きです。", "Inu yori neko no hou ga suki desu.", "I like cats more than dogs."),
            ("コーヒーと紅茶と、どちらのほうが好きですか？", "Koohii to koucha to, dochira no hou ga suki desu ka?", "Which do you like more — coffee or tea?"),
            ("バスより電車のほうが速い。", "Basu yori densha no hou ga hayai.", "Trains are faster than buses."),
        ],
        "compare": "より = the standard (English 'than'). のほうが = the winner (English 'more').",
        "mistakes": "Forgetting のほうが and just using より: 猫より好きです is incomplete — needs のほうが.",
    },
    {
        "lesson": 10, "jlpt": "N5",
        "ja": "Superlative: 一番 / 中で", "romaji": "ichiban / naka de",
        "title": "Most ~ (the best)",
        "usage": "一番 (literally 'number one') means 'most'. Use の中で to define the group of comparison.",
        "form": "[Group] の中で X が 一番 ~ です. Question: ~の中で何が一番 ~ ですか？",
        "ex": [
            ("果物の中でりんごが一番好きです。", "Kudamono no naka de ringo ga ichiban suki desu.", "Of all fruits, I like apples the most."),
            ("家族の中で姉が一番背が高いです。", "Kazoku no naka de ane ga ichiban se ga takai desu.", "My older sister is the tallest in my family."),
            ("世界で何が一番大切ですか？", "Sekai de nani ga ichiban taisetsu desu ka?", "What is most important in the world?"),
        ],
        "compare": "When comparing 2 items: のほうが. When comparing 3+ items: 一番.",
        "mistakes": "Using 一番 for comparison of just 2 — that's より/のほうが.",
    },
    {
        "lesson": 10, "jlpt": "N5",
        "ja": "~になる / ~くなる (become)", "romaji": "~ni naru / ~ku naru",
        "title": "Becomes ~ (change of state)",
        "usage": (
            "Expresses change. Noun/な-adj take に + なる. い-adj drops final い + く + なる. "
            "なる focuses on NATURAL/INEVITABLE change, contrasted with する (deliberate action)."
        ),
        "form": (
            "Noun + に + なる. な-adj + に + なる. い-adj (drop い) + く + なる. "
            "Negative: ~に/くならない. Past: ~に/くなった."
        ),
        "ex": [
            ("暑くなりました。", "Atsuku narimashita.", "It became hot."),
            ("先生になりたい。", "Sensei ni naritai.", "I want to become a teacher."),
            ("元気になりましたか？", "Genki ni narimashita ka?", "Have you gotten better?"),
        ],
        "compare": "する = make X (deliberate): 部屋をきれいにする (clean the room). なる = X becomes (natural): 部屋がきれいになる (the room became clean).",
        "mistakes": "Forgetting to drop い in い-adj: 高いになる (wrong) → 高くなる.",
    },
    {
        "lesson": 10, "jlpt": "N5",
        "ja": "~つもりです", "romaji": "~tsumori desu",
        "title": "Plan to / intend to ~",
        "usage": "Expresses a personal plan or strong intention. Stronger than just ~ます (will) — implies premeditation.",
        "form": (
            "Plain DICTIONARY form + つもり + です. Negative intention: ~ないつもりです / ~つもりはありません."
        ),
        "ex": [
            ("明日、大阪に行くつもりです。", "Ashita, Oosaka ni iku tsumori desu.", "I plan to go to Osaka tomorrow."),
            ("もう食べないつもりです。", "Mou tabenai tsumori desu.", "I don't plan to eat anymore."),
            ("そんなつもりはなかった。", "Sonna tsumori wa nakatta.", "I didn't have such an intention.")
        ],
        "compare": "Past form つもりだった = 'I had planned to (but didn't)'. Implies the plan didn't pan out.",
        "mistakes": "Using ます-form before つもり (wrong): 行きますつもり. Must be dictionary form: 行くつもり.",
    },
    {
        "lesson": 10, "jlpt": "N5",
        "ja": "~で (means / instrument)", "romaji": "~de",
        "title": "By means of / using",
        "usage": "Same particle で also marks the MEANS/INSTRUMENT used to do something (vehicle, tool, language).",
        "form": "Tool/Means + で + Verb.",
        "ex": [
            ("バスで行きます。", "Basu de ikimasu.", "I go by bus."),
            ("鉛筆で書きます。", "Enpitsu de kakimasu.", "I write with a pencil."),
            ("日本語で話しましょう。", "Nihongo de hanashimashou.", "Let's talk in Japanese."),
        ],
        "compare": "で has multiple uses: (1) activity location (L3), (2) means/tool (here), (3) cause (病気で = due to illness). Context distinguishes.",
        "mistakes": "Using に for transport: 'go to school' uses に for destination, で for means of transport. 学校にバスで行く.",
    },

    # ─────────────── L11 ───────────────
    {
        "lesson": 11, "jlpt": "N5",
        "ja": "~や~ (non-exhaustive 'and')", "romaji": "~ya ~",
        "title": "Things like X and Y (representative listing)",
        "usage": (
            "Lists SOME representative items, implying more exist. Often paired with など (etc.) for emphasis. "
            "Contrasts with と which lists ALL items exhaustively."
        ),
        "form": "Noun や Noun (や Noun ...) (など).",
        "ex": [
            ("本やノートを買った。", "Hon ya nooto o katta.", "I bought books and notebooks (among other things)."),
            ("りんごやみかんなどが好きです。", "Ringo ya mikan nado ga suki desu.", "I like fruits like apples and oranges."),
            ("週末は映画やカラオケに行く。", "Shuumatsu wa eiga ya karaoke ni iku.", "On weekends I go to movies and karaoke (etc.)."),
        ],
        "compare": "と = exhaustive list (just these). や = representative list (these and probably more).",
        "mistakes": "Using や when you really mean only those items. Native speakers feel a clear difference.",
    },
    {
        "lesson": 11, "jlpt": "N5",
        "ja": "~ことがある (experience)", "romaji": "~koto ga aru",
        "title": "Have ~ed (experience)",
        "usage": (
            "Expresses 'have done X before' — past experience. MUST use PAST plain form before ことがある (not dictionary)."
        ),
        "form": "Verb PAST plain + こと が ある. Negative: ~たことがない. Question: ~たことがありますか？",
        "ex": [
            ("日本に行ったことがあります。", "Nihon ni itta koto ga arimasu.", "I have been to Japan before."),
            ("寿司を食べたことがない。", "Sushi o tabeta koto ga nai.", "I have never eaten sushi."),
            ("その本を読んだことがあります。", "Sono hon o yonda koto ga arimasu.", "I have read that book."),
        ],
        "compare": "Different from 行きました (simple past). 行ったことがある emphasizes LIFETIME experience.",
        "mistakes": "Using dictionary form: 行くことがある (wrong for experience — actually means 'I sometimes go'). Must be past.",
    },
    {
        "lesson": 11, "jlpt": "N5",
        "ja": "~たい (want to do)", "romaji": "~tai",
        "title": "I want to ~",
        "usage": (
            "Expresses desire to do an action. Object particle を often shifts to が (subject of desire). "
            "ONLY used for FIRST PERSON in plain form — using ~たい for others sounds presumptuous; use ~たがる (L23+)."
        ),
        "form": (
            "Verb stem (drop ます) + たい. Conjugates like い-adjective: ~たくない, ~たかった, ~たくなかった."
        ),
        "ex": [
            ("ラーメンが食べたい。", "Raamen ga tabetai.", "I want to eat ramen."),
            ("日本に行きたいです。", "Nihon ni ikitai desu.", "I want to go to Japan."),
            ("もう寝たくない。", "Mou netakunai.", "I don't want to sleep anymore."),
        ],
        "compare": "を vs が with ~たい: both grammatical, but が is more common for emotion (preference, not action).",
        "mistakes": "Using ~たい for someone else: 田中さんは行きたい (sounds odd). Use 田中さんは行きたがっている for third person.",
    },
    {
        "lesson": 11, "jlpt": "N5",
        "ja": "~たり~たりする", "romaji": "~tari ~tari suru",
        "title": "Doing things like ~ and ~",
        "usage": (
            "Lists SAMPLE activities (not exhaustive). Contrasts with te-form chains which list all activities in sequence."
        ),
        "form": (
            "Verb PAST + り + Verb PAST + り + する. Tense/politeness shown on final する. "
            "Negative: ~ないかったり~たり (rare) — usually just adjust the final する: しない/しなかった."
        ),
        "ex": [
            ("週末は本を読んだり、寝たりします。", "Shuumatsu wa hon o yondari, netari shimasu.", "On weekends I do things like read and sleep."),
            ("テレビを見たり、料理したりしました。", "Terebi o mitari, ryouri shitari shimashita.", "I watched TV, cooked, and so on."),
            ("一人なので、笑ったり、泣いたりした。", "Hitori na node, warattari, naitari shita.", "Being alone, I laughed and cried (etc.).")
        ],
        "compare": "te-form chains = all in sequence. ~たり~たり = sample activities, order unimportant.",
        "mistakes": "Forgetting する at the end. 'I read and slept' should NOT end with just ~たり.",
    },

    # ─────────────── L12 ───────────────
    {
        "lesson": 12, "jlpt": "N5",
        "ja": "~でしょう / ~だろう", "romaji": "~deshou / ~darou",
        "title": "Probably ~ / Right?",
        "usage": (
            "Two functions: (1) probability/conjecture ('probably is'); (2) seeking confirmation ('right?' — "
            "with rising intonation). Common in weather forecasts and predictions."
        ),
        "form": "Plain form + でしょう (formal) / だろう (casual). Noun/な-adj: just + でしょう (no だ).",
        "ex": [
            ("明日は雨でしょう。", "Ashita wa ame deshou.", "It will probably rain tomorrow."),
            ("分かったでしょう？", "Wakatta deshou?", "You understood, right?"),
            ("彼も来るだろう。", "Kare mo kuru darou.", "He'll probably come too. (casual)"),
        ],
        "compare": "~でしょう (probability) vs ~かもしれません (might — less certain).",
        "mistakes": "Adding だ before でしょう for nouns: 雨だでしょう (wrong) → 雨でしょう.",
    },
    {
        "lesson": 12, "jlpt": "N5",
        "ja": "~ほうがいい", "romaji": "~hou ga ii",
        "title": "It's better to ~ / You should ~",
        "usage": (
            "Gives advice. Affirmative advice uses PAST plain form (strange to English speakers). "
            "Negative advice uses ない form."
        ),
        "form": (
            "AFFIRMATIVE: Verb PAST plain + ほうがいい (です). 'You should do X.' "
            "NEGATIVE: Verb ~ない + ほうがいい (です). 'You should not do X.'"
        ),
        "ex": [
            ("早く寝たほうがいいです。", "Hayaku neta hou ga ii desu.", "You should sleep early."),
            ("あまり食べないほうがいいですよ。", "Amari tabenai hou ga ii desu yo.", "You shouldn't eat too much."),
            ("病院に行ったほうがいい。", "Byouin ni itta hou ga ii.", "You'd better go to the hospital."),
        ],
        "compare": "Stronger than ~たほうがいい: ~なくてはいけない (you must). Softer: ~たらどうですか (how about ~ing).",
        "mistakes": "Using DICTIONARY form: 寝るほうがいい — TECHNICALLY correct but feels like 'sleeping is better than not'. PAST form 寝たほうがいい sounds more like sincere advice.",
    },
    {
        "lesson": 12, "jlpt": "N5",
        "ja": "~んです / ~のです (explanation)", "romaji": "~n desu / ~no desu",
        "title": "It's because ~ / The reason is ~ / Just so you know ~",
        "usage": (
            "Adds explanatory or emotional weight. Indicates the speaker is providing CONTEXT or REASON. "
            "Often used in conversations after questions like 'why?'. Overuse sounds whiny or defensive."
        ),
        "form": (
            "Plain form + ん (or の) + です. Noun/な-adj: + な + ん/の + です. "
            "Question: ~んですか？ asks for explanation."
        ),
        "ex": [
            ("どうしたんですか？— 今、忙しいんです。", "Doushita n desu ka? Ima, isogashii n desu.", "What's wrong? — It's because I'm busy now."),
            ("日本に行きたいんです。", "Nihon ni ikitai n desu.", "(The thing is,) I want to go to Japan."),
            ("学生なんです。", "Gakusei na n desu.", "It's because I'm a student."),
        ],
        "compare": "~んです adds context. Without it, 行きます = 'I will go'. With it: 行くんです = 'It's so I can/the reason is I will go'.",
        "mistakes": "Forgetting な before ん for nouns: 学生んです (wrong) → 学生なんです.",
    },
    {
        "lesson": 12, "jlpt": "N5",
        "ja": "~ので (because, polite)", "romaji": "~node",
        "title": "Because ~ (softer than から)",
        "usage": (
            "Softer, more objective reason than から. Sounds less assertive — preferred in formal/polite contexts "
            "(workplace, requesting favors, explaining circumstances)."
        ),
        "form": "Plain form + ので、main clause. Noun/な-adj + な + ので.",
        "ex": [
            ("疲れているので、休みます。", "Tsukarete iru node, yasumimasu.", "Since I'm tired, I'll rest."),
            ("雨なので、行きません。", "Ame na node, ikimasen.", "Since it's raining, I won't go."),
            ("時間がないので、急ぎましょう。", "Jikan ga nai node, isogimashou.", "Since we have no time, let's hurry."),
        ],
        "compare": "から = direct/assertive reason ('because!'). ので = softer/objective ('since'). In requests, ので sounds more polite.",
        "mistakes": "Forgetting な with noun/な-adj: 雨ので (wrong) → 雨なので.",
    },
    {
        "lesson": 12, "jlpt": "N5",
        "ja": "~なくちゃ いけない / ~なければ ならない", "romaji": "~nakucha ikenai / ~nakereba naranai",
        "title": "Must do ~ / Have to ~",
        "usage": (
            "Expresses obligation. Literally a DOUBLE NEGATIVE: 'if I don't do it, it won't do' = 'I must do it'. "
            "Many shorter casual forms exist (~ないと, ~なきゃ, ~なくちゃ)."
        ),
        "form": (
            "Verb plain neg ~ない → drop い + ければ ならない (formal) / くては いけない (semi-formal) / "
            "くちゃ いけない (casual) / きゃ (very casual). "
            "勉強する → 勉強しない → 勉強しなければなりません."
        ),
        "ex": [
            ("宿題をしなくちゃ いけない。", "Shukudai o shinakucha ikenai.", "I have to do homework."),
            ("早く起きなければならない。", "Hayaku okinakereba naranai.", "I must wake up early. (formal)"),
            ("行かなきゃ！", "Ikanakya!", "Gotta go!"),
        ],
        "compare": "All variants mean the same. Formal → casual: ~なければならない > ~なくては いけない > ~なくちゃ > ~なきゃ.",
        "mistakes": "Saying ~なくてはいいです (wrong) — that mixes prohibition with permission and is nonsensical. ~なくても いい means 'don't have to'.",
    },
    {
        "lesson": 12, "jlpt": "N5",
        "ja": "~すぎる (too much)", "romaji": "~sugiru",
        "title": "Too ~ / Overdoing ~",
        "usage": (
            "Attaches to verb stems and adjective stems to indicate excess. Conjugates as a regular る-verb. "
            "Always implies an undesirable amount."
        ),
        "form": (
            "Verb stem + すぎる (食べる → 食べすぎる). "
            "い-adj drop い + すぎる (高い → 高すぎる). "
            "な-adj + すぎる (静か → 静かすぎる)."
        ),
        "ex": [
            ("食べすぎた。", "Tabesugita.", "I ate too much."),
            ("この服は高すぎます。", "Kono fuku wa takasugimasu.", "These clothes are too expensive."),
            ("勉強しすぎてはいけません。", "Benkyou shisugite wa ikemasen.", "Don't study too much."),
        ],
        "compare": "とても (very) = neutral. すぎる = negatively excessive.",
        "mistakes": "Forgetting to drop い for い-adj: 高いすぎる (wrong) → 高すぎる.",
    },
]


def html_for_card(c) -> str:
    examples_html = "\n".join(
        f'<div class="ex-row"><span class="ex-ja">{ja}</span> <span class="ex-romaji">{ro}</span> <span class="ex-en">{en}</span></div>'
        for ja, ro, en in c["ex"]
    )
    compare_html = f'<div class="aside compare"><span class="badge cmp">vs</span> {c["compare"]}</div>' if c.get("compare") else ''
    mistakes_html = f'<div class="aside mistakes"><span class="badge mst">⚠</span> {c["mistakes"]}</div>' if c.get("mistakes") else ''
    return f'''<div class="card">
  <div class="chips">
    <span class="chip lesson">L{c["lesson"]}</span>
    <span class="chip jlpt">{c["jlpt"]}</span>
  </div>
  <div class="ja">{c["ja"]}</div>
  <div class="romaji">{c["romaji"]}</div>
  <div class="title">{c["title"]}</div>
  <div class="block"><span class="badge usg">USE</span> {c["usage"]}</div>
  <div class="block form"><span class="badge frm">FORM</span> {c["form"]}</div>
  <div class="examples">{examples_html}</div>
  {compare_html}
  {mistakes_html}
</div>'''


def page(idx_start, idx_end, page_num, total_pages, title) -> str:
    cards_html = "\n".join(html_for_card(CARDS[i]) for i in range(idx_start, idx_end))
    return f'''<section class="page">
  <header>
    <h1>{title}</h1>
    <div class="meta">
      <span class="badge tag">日本語ユニバース · Globi</span>
      <span>Genki L1-12 · For native English speakers — in-depth</span>
      <span class="pageno">{page_num} / {total_pages}</span>
    </div>
  </header>
  <div class="grid">
    {cards_html}
  </div>
</section>'''


CSS = '''
@page { size: A4 portrait; margin: 7mm 8mm; }
* { box-sizing: border-box; }
html, body {
  margin: 0; padding: 0;
  font-family: "Noto Sans CJK JP", "Noto Sans JP", "Yu Gothic", "Helvetica Neue", Arial, sans-serif;
  color: #4A4554; background: #FBF8F1;
  font-size: 8.5pt; line-height: 1.42;
}
.page {
  width: 100%; min-height: calc(297mm - 14mm);
  page-break-after: always;
  display: flex; flex-direction: column;
}
.page:last-of-type { page-break-after: auto; }
header {
  display: flex; flex-direction: column; gap: 1.5mm;
  margin-bottom: 2.5mm; padding-bottom: 2mm;
  border-bottom: 1px solid #8B8294;
}
header h1 { margin: 0; font-size: 12pt; font-weight: 800; color: #4A4554; }
header h1::before { content: "🌸 "; }
.meta {
  display: flex; gap: 8px; align-items: center;
  font-size: 7.5pt; color: #7A7585; font-weight: 600;
}
.badge.tag { background: #F8C8D8; color: #4A4554; padding: 1px 6px; border-radius: 999px; border: 0.5px solid #8B8294; font-weight: 700; }
.pageno { margin-left: auto; font-variant-numeric: tabular-nums; font-weight: 700; }
.grid {
  flex: 1;
  display: grid;
  grid-template-columns: 1fr;
  gap: 2.5mm;
  align-content: start;
}
.card {
  border: 0.8px solid #8B8294;
  border-radius: 4px;
  padding: 2.5mm 3mm;
  background: #FFFEFB;
  break-inside: avoid;
}
.chips { display: flex; gap: 4px; margin-bottom: 1mm; }
.chip { display: inline-block; font-size: 6.5pt; font-weight: 800; padding: 0.5px 5px; border-radius: 999px; letter-spacing: 0.5px; }
.chip.lesson { background: #C8BFE8; color: #4A4554; border: 0.5px solid #8B8294; }
.chip.jlpt   { background: #EDD27A; color: #4A4554; border: 0.5px solid #8B8294; }
.ja { font-size: 11.5pt; font-weight: 800; color: #4A4554; letter-spacing: -0.2px; display: inline; }
.romaji { font-size: 7.5pt; color: #7A7585; font-style: italic; margin-left: 6px; display: inline; }
.title { font-size: 9pt; font-weight: 700; color: #4A4554; margin: 0.5mm 0 1.5mm; }
.block { font-size: 8.5pt; line-height: 1.5; margin-bottom: 1.5mm; }
.block.form { background: #F3EFFB; padding: 1.5mm 2mm; border-radius: 3px; border-left: 1.8px solid #A89DDA; }
.badge {
  display: inline-block;
  padding: 0 4px;
  border-radius: 3px;
  font-size: 6.5pt;
  font-weight: 800;
  letter-spacing: 0.4px;
  margin-right: 4px;
  vertical-align: 1px;
}
.badge.usg { background: #DDD3F0; color: #4A4554; }
.badge.frm { background: #A89DDA; color: white; }
.badge.cmp { background: #B8D2AE; color: #4A4554; }
.badge.mst { background: #E0936C; color: white; }
.examples { background: #FDF6D9; border-left: 1.8px solid #EDD27A; padding: 1.5mm 2mm; margin: 1mm 0 1.5mm; border-radius: 0 3px 3px 0; }
.ex-row { font-size: 8.3pt; line-height: 1.5; margin-bottom: 0.5mm; }
.ex-ja { font-weight: 700; color: #4A4554; }
.ex-romaji { color: #7A7585; font-style: italic; margin-left: 4px; font-size: 7.7pt; }
.ex-en { color: #4A4554; margin-left: 4px; }
.aside { font-size: 7.8pt; line-height: 1.45; padding: 1.2mm 2mm; margin-top: 1mm; border-radius: 3px; }
.aside.compare { background: #EAF3E4; border: 0.5px solid #B8D2AE; }
.aside.mistakes { background: #FAE6DC; border: 0.5px solid #E0936C; }
@media print { body { background: white; } .card { background: white; } }
'''


def main():
    total = len(CARDS)
    # Compute page boundaries — aim ~8 cards per page (single column, dense)
    cards_per_page = 8
    boundaries = []
    titles = [
        "L1-2 · Basics: copula, demonstratives, particles",
        "L2-3 · Particles, verbs",
        "L3-4 · Verbs, existence, time",
        "L4-5 · Time, adjectives",
        "L5-6 · Adjectives, te-form ★",
        "L6-7 · te-form usage, ~ている ★",
        "L7-8 · State, particle が, short forms",
        "L8-9 · Relative clauses, past plain",
        "L9-10 · Past, comparison",
        "L10-11 · Comparison, intent, listing",
        "L11-12 · Want, advice, explanation",
        "L12 · Must, too-much",
    ]
    idx = 0
    pages = []
    title_idx = 0
    while idx < total:
        end = min(idx + cards_per_page, total)
        boundaries.append((idx, end))
        idx = end
    n_pages = len(boundaries)
    for i, (s, e) in enumerate(boundaries):
        # Compute title from chapter range
        ls = sorted(set(CARDS[j]["lesson"] for j in range(s, e)))
        if len(ls) == 1:
            t = f"L{ls[0]} · {CARDS[s]['title'].split('—')[0].strip()[:40]}..."
        else:
            t = f"L{ls[0]}-{ls[-1]} · in-depth grammar"
        pages.append(page(s, e, i + 1, n_pages, t))

    body = "\n".join(pages)
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Genki L1-12 — In-Depth Grammar — Japanese Universe</title>
<style>{CSS}</style>
</head>
<body>
{body}
</body>
</html>
'''
    OUT.write_text(html, encoding="utf-8")
    print(f"OK  {OUT.relative_to(OUT.parent.parent.parent)}")
    print(f"    cards: {total}, pages: {n_pages} (~{cards_per_page}/page, single column)")
    print(f"Open: start {OUT}")


if __name__ == "__main__":
    main()
