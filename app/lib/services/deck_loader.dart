import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/flash_card.dart';

class DeckLoader {
  static const deckFiles = {
    'native': 'assets/data/deck_native.json',
    'r1': 'assets/data/deck_r1.json',
    'kanji': 'assets/data/deck_kanji.json',
    'vocab_edu': 'assets/data/deck_vocab_edu.json',
    'l1_turn': 'assets/data/deck_l1_turn.json',
  };

  // unlock 순서 = 학습 권장 순서 (native 회화 → R1 → 교육 어휘 → 한자 → L1 narrative)
  static const deckOrder = ['native', 'r1', 'vocab_edu', 'kanji', 'l1_turn'];

  static final Map<String, Deck> _cache = {};

  static Future<Deck> load(String deckId) async {
    if (_cache.containsKey(deckId)) return _cache[deckId]!;
    final path = deckFiles[deckId];
    if (path == null) throw ArgumentError('Unknown deck: $deckId');
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final deck = Deck.fromJson(json);
    _cache[deckId] = deck;
    return deck;
  }

  static Future<List<Deck>> loadAll() async {
    final decks = <Deck>[];
    for (final id in deckOrder) {
      decks.add(await load(id));
    }
    return decks;
  }
}
