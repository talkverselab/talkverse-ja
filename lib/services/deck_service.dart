import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// 플래시카드 1장 (decks/*.json)
class DeckCard {
  final String id;
  final String front; // 일본어
  final String kana;
  final String back; // 한국어 뜻
  final String key; // 메모·힌트
  const DeckCard({
    required this.id,
    required this.front,
    required this.kana,
    required this.back,
    required this.key,
  });

  factory DeckCard.fromJson(Map<String, dynamic> j) => DeckCard(
        id: j['id'] as String? ?? '',
        front: j['front'] as String? ?? '',
        kana: j['kana'] as String? ?? '',
        back: j['back'] as String? ?? '',
        key: j['key'] as String? ?? '',
      );
}

class Deck {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final int colorValue;
  final List<DeckCard> cards;
  const Deck({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.colorValue,
    required this.cards,
  });

  factory Deck.fromJson(Map<String, dynamic> j) => Deck(
        id: j['deck_id'] as String,
        name: j['deck_name'] as String? ?? j['deck_id'] as String,
        subtitle: j['deck_subtitle'] as String? ?? '',
        icon: j['icon'] as String? ?? '📘',
        colorValue: int.tryParse(j['color'] as String? ?? '') ?? 0xFFC9A227,
        cards: ((j['cards'] as List?) ?? [])
            .map((c) => DeckCard.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

/// assets/data/decks/*.json 로더
class DeckService {
  DeckService._();
  static final DeckService instance = DeckService._();

  static const _files = [
    'deck_l1_turn.json',
    'deck_native.json',
    'deck_r1.json',
    'deck_kanji.json',
    'deck_vocab_edu.json',
  ];

  List<Deck> _decks = const [];
  bool _loaded = false;

  List<Deck> get decks => _decks;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final out = <Deck>[];
    for (final f in _files) {
      try {
        final raw = await rootBundle.loadString('assets/data/decks/$f');
        out.add(Deck.fromJson(json.decode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    _decks = out;
    _loaded = true;
  }
}
