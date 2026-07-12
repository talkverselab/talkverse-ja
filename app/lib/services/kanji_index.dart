import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/flash_card.dart';

/// 한자 사전 항목 — kanji_index.json 1개 엔트리.
/// 한 한자에 음훈이 여럿일 수 있음 (行: 다닐 행·항렬 항, 楽: 즐길 락·노래 악).
class KanjiEntry {
  final String char;
  final int rank;
  final double pct;
  final List<String> meanings; // 음훈 목록 — 대표가 첫 번째
  final List<KanjiReading> readings;
  final List<ExampleWord> words;

  const KanjiEntry({
    required this.char,
    required this.rank,
    required this.pct,
    required this.meanings,
    required this.readings,
    required this.words,
  });

  factory KanjiEntry.fromJson(Map<String, dynamic> j) {
    final meanings = (j['meanings'] as List?)?.cast<String>() ??
        [if ((j['meaning'] as String?)?.isNotEmpty ?? false) j['meaning'] as String];
    return KanjiEntry(
      char: j['char'] as String,
      rank: j['rank'] as int,
      pct: (j['pct'] as num?)?.toDouble() ?? 0,
      meanings: meanings,
      readings: (j['readings'] as List?)
              ?.map((r) => KanjiReading.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
      words: (j['words'] as List?)
              ?.map((w) => ExampleWord.fromJson(w as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  String get meaning => meanings.isEmpty ? '' : meanings.first;
  String get meaningJoined => meanings.join(' · ');

  bool get hasDetail => meanings.isNotEmpty || readings.isNotEmpty;

  /// KanjiDetailSheet 재사용을 위한 FlashCard 변환 — 복수 음훈은 · 로 병기.
  FlashCard toCard() => FlashCard(
        id: 'kanji_index_$rank',
        front: char,
        kana: '',
        back: meaningJoined,
        key: '',
        readings: readings,
        exampleWords: words,
        weightedRank: rank,
        weightedPct: pct,
      );
}

/// kanji_index.json 로더 + 검색. DeckLoader 와 동일한 rootBundle 패턴.
class KanjiIndex {
  static List<KanjiEntry>? _cache;

  static Future<List<KanjiEntry>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/kanji_index.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['entries'] as List)
        .map((e) => KanjiEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  /// 검색 — 한자 자체 / 뜻(한국어) / 읽기(가나) / 대표 단어 매칭.
  /// 가타카나·히라가나는 동일시.
  static List<KanjiEntry> search(List<KanjiEntry> all, String query) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final qKana = _toHiragana(q);
    return all.where((e) {
      if (q.contains(e.char)) return true;
      if (e.meanings.any((m) => m.contains(q))) return true;
      for (final r in e.readings) {
        final pure = r.reading.replaceAll(RegExp(r'[\-\(\)、]'), '');
        if (_toHiragana(pure).contains(qKana)) return true;
        if (r.gloss.contains(q)) return true;
      }
      for (final w in e.words) {
        if (w.word.contains(q)) return true;
        if (w.ko.isNotEmpty && w.ko.contains(q)) return true;
      }
      return false;
    }).toList();
  }

  /// 가타카나 → 히라가나 (U+30A1..U+30F6 → -0x60).
  static String _toHiragana(String s) {
    final codes = s.codeUnits.map((c) {
      if (c >= 0x30A1 && c <= 0x30F6) return c - 0x60;
      return c;
    }).toList();
    return String.fromCharCodes(codes);
  }
}
