import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// 한자 읽기 (음독/훈독)
class KanjiReading {
  final String reading;
  final String kind; // '음독' | '훈독'
  final String gloss;
  const KanjiReading({required this.reading, required this.kind, required this.gloss});

  factory KanjiReading.fromJson(Map<String, dynamic> j) => KanjiReading(
        reading: j['reading'] as String? ?? '',
        kind: j['kind'] as String? ?? '',
        gloss: j['gloss'] as String? ?? '',
      );

  bool get isOn => kind == '음독';
}

/// 한자 예시 단어
class ExampleWord {
  final String word;
  final double freq;
  final int rank;
  final String ko;
  const ExampleWord({required this.word, required this.freq, required this.rank, required this.ko});

  factory ExampleWord.fromJson(Map<String, dynamic> j) => ExampleWord(
        word: j['word'] as String? ?? '',
        freq: (j['freq'] as num?)?.toDouble() ?? 0,
        rank: j['rank'] as int? ?? 0,
        ko: j['ko'] as String? ?? '',
      );
}

/// 한자 사전 항목 — kanji_index.json 1개 엔트리.
/// 한 한자에 음훈이 여럿일 수 있음 (行: 다닐 행·항렬 항, 楽: 즐길 락·노래 악).
class KanjiEntry {
  final String char;
  final int rank;
  final double pct;
  final List<String> meanings;
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
  List<KanjiReading> get on => readings.where((r) => r.isOn).toList();
  List<KanjiReading> get kun => readings.where((r) => !r.isOn).toList();
}

/// kanji_index.json 로더 + 검색 + 단계 분할.
class KanjiIndexService {
  KanjiIndexService._();
  static final KanjiIndexService instance = KanjiIndexService._();

  static const stageSize = 20;

  List<KanjiEntry> _all = const [];
  Map<String, KanjiEntry> _byChar = const {};
  bool _loaded = false;

  List<KanjiEntry> get all => _all;
  bool get isLoaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/kanji/kanji_index.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _all = (json['entries'] as List)
        .map((e) => KanjiEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    _byChar = {for (final e in _all) e.char: e};
    _loaded = true;
  }

  KanjiEntry? lookup(String char) => _byChar[char];

  static bool isKanji(String c) {
    if (c.isEmpty) return false;
    final code = c.runes.first;
    return (code >= 0x4E00 && code <= 0x9FFF) || (code >= 0x3400 && code <= 0x4DBF);
  }

  /// 뜻 있는 항목만 빈도순 → 20자 단위 단계 분할.
  List<List<KanjiEntry>> stages() {
    final pool = _all.where((e) => e.meanings.isNotEmpty).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    final out = <List<KanjiEntry>>[];
    for (var i = 0; i < pool.length; i += stageSize) {
      out.add(pool.sublist(i, (i + stageSize).clamp(0, pool.length)));
    }
    return out;
  }

  /// 검색 — 한자 자체 / 뜻(한국어) / 읽기(가나) / 대표 단어 매칭. 가타카나·히라가나 동일시.
  List<KanjiEntry> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final qKana = toHiragana(q);
    return _all.where((e) {
      if (q.contains(e.char)) return true;
      if (e.meanings.any((m) => m.contains(q))) return true;
      for (final r in e.readings) {
        final pure = r.reading.replaceAll(RegExp(r'[\-\(\)、]'), '');
        if (toHiragana(pure).contains(qKana)) return true;
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
  static String toHiragana(String s) {
    final codes = s.codeUnits.map((c) {
      if (c >= 0x30A1 && c <= 0x30F6) return c - 0x60;
      return c;
    }).toList();
    return String.fromCharCodes(codes);
  }
}
