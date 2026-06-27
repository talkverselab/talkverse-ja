class KanjiReading {
  final String reading;
  final String kind; // 훈독 / 음독 / 혼합
  final String gloss; // 짧은 설명·예시 단어

  const KanjiReading({required this.reading, required this.kind, required this.gloss});

  factory KanjiReading.fromJson(Map<String, dynamic> j) => KanjiReading(
        reading: j['reading'] as String? ?? '',
        kind: j['kind'] as String? ?? '',
        gloss: j['gloss'] as String? ?? '',
      );
}

class ExampleWord {
  final String word;
  final double freq;
  final int rank;
  final String ko;  // 한국어 의역 (없으면 빈 문자열)

  const ExampleWord({required this.word, required this.freq, required this.rank, this.ko = ''});

  factory ExampleWord.fromJson(Map<String, dynamic> j) => ExampleWord(
        word: j['word'] as String? ?? '',
        freq: (j['freq'] as num?)?.toDouble() ?? 0,
        rank: j['rank'] as int? ?? 0,
        ko: j['ko'] as String? ?? '',
      );
}

class FlashCard {
  final String id;
  final String front;     // ja (한자+가나)
  final String kana;      // 히라가나 표기 / 발음
  final String back;      // 한국어 의역
  final String key;       // 어휘·문법 메모
  // kanji 덱 전용 (없으면 빈 list)
  final List<KanjiReading> readings;
  final List<ExampleWord> exampleWords;
  final int? weightedRank;
  final double? weightedPct;

  const FlashCard({
    required this.id,
    required this.front,
    required this.kana,
    required this.back,
    required this.key,
    this.readings = const [],
    this.exampleWords = const [],
    this.weightedRank,
    this.weightedPct,
  });

  factory FlashCard.fromJson(Map<String, dynamic> j) => FlashCard(
        id: j['id'] as String,
        front: j['front'] as String,
        kana: j['kana'] as String? ?? '',
        back: j['back'] as String,
        key: j['key'] as String? ?? '',
        readings: (j['readings'] as List?)
                ?.map((r) => KanjiReading.fromJson(r as Map<String, dynamic>))
                .toList() ??
            const [],
        exampleWords: (j['example_words'] as List?)
                ?.map((e) => ExampleWord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        weightedRank: j['weighted_rank'] as int?,
        weightedPct: (j['weighted_pct'] as num?)?.toDouble(),
      );

  bool get hasKanjiDetail => readings.isNotEmpty || exampleWords.isNotEmpty;
}

class Deck {
  final String id;
  final String name;
  final String subtitle;
  final int color;
  final String icon;
  final int unlockThreshold;
  final String source;
  final List<FlashCard> cards;

  const Deck({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.unlockThreshold,
    required this.source,
    required this.cards,
  });

  factory Deck.fromJson(Map<String, dynamic> j) => Deck(
        id: j['deck_id'] as String,
        name: j['deck_name'] as String,
        subtitle: j['deck_subtitle'] as String,
        color: int.parse((j['color'] as String).replaceFirst('0x', ''), radix: 16),
        icon: j['icon'] as String,
        unlockThreshold: j['unlock_threshold'] as int? ?? 0,
        source: j['source'] as String? ?? '',
        cards: (j['cards'] as List)
            .map((c) => FlashCard.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
