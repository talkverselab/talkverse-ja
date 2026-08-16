import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_database.dart';

class SeedLoader {
  // v1: 초기 시딩 (L1 ep1 40턴 · 한자 1,078 · 단어 2,500)
  static const _kSeededKey = 'db_seeded_v1';

  final AppDatabase db;
  SeedLoader(this.db);

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeededKey) == true) return;

    await _seedKanji();
    await _seedWords();
    await _seedTurns();

    await prefs.setBool(_kSeededKey, true);
  }

  Future<void> _seedKanji() async {
    final raw = await rootBundle.loadString('assets/data/kanji/kanji_index.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final entries = (data['entries'] as List?) ?? [];

    // 한국 한자 crossref (ko_hanja) 병합
    final koMap = <String, String>{};
    try {
      final hraw = await rootBundle.loadString('assets/data/hanja/hanja_crossref.json');
      final hdata = json.decode(hraw) as Map<String, dynamic>;
      for (final e in (hdata['entries'] as List? ?? []).whereType<Map>()) {
        final ja = e['ja_kanji'] as String?;
        final ko = e['ko_hanja'] as String?;
        if (ja != null && ko != null) koMap[ja] = ko;
      }
    } catch (_) {}

    final batch = <Insertable<KanjiRow>>[];
    for (final e in entries.whereType<Map>()) {
      final char = e['char'] as String;
      final meanings = (e['meanings'] as List?)?.cast<String>() ?? const [];
      final readings = (e['readings'] as List?)?.whereType<Map>() ?? const [];
      final on = readings.where((r) => r['kind'] == '음독').map((r) => r['reading']).join('·');
      final kun = readings.where((r) => r['kind'] == '훈독').map((r) => r['reading']).join('·');
      batch.add(KanjiCompanion.insert(
        char: char,
        rank: Value(e['rank'] as int?),
        pct: Value((e['pct'] as num?)?.toDouble()),
        meaningKo: Value(meanings.isEmpty ? null : meanings.first),
        onyomi: Value(on.isEmpty ? null : on),
        kunyomi: Value(kun.isEmpty ? null : kun),
        koHanja: Value(koMap[char]),
      ));
    }
    await db.batch((b) => b.insertAllOnConflictUpdate(db.kanji, batch));
  }

  Future<void> _seedWords() async {
    final raw = await rootBundle.loadString('assets/data/freq/lang_ja_with_regions.csv');
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    final batch = <Insertable<WordRow>>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;
      batch.add(WordsCompanion.insert(
        rank: Value(int.tryParse('${row[0]}') ?? 0),
        word: '${row[1]}',
        freq: Value(double.tryParse('${row[2]}')),
        cumPct: Value(double.tryParse('${row[3]}')),
        region: Value('${row[4]}'.trim()),
      ));
    }
    await db.batch((b) => b.insertAllOnConflictUpdate(db.words, batch));
  }

  /// L1~L3 전체 턴 시딩. 'episodes' 또는 'dialogues' 키 사용.
  Future<void> _seedTurns() async {
    final batch = <Insertable<TurnRow>>[];
    for (final level in ['L1', 'L2', 'L3']) {
      final Map<String, dynamic> data;
      try {
        final raw = await rootBundle.loadString('assets/data/dialogues/$level.json');
        data = json.decode(raw) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final units = (data['episodes'] as List?) ?? (data['dialogues'] as List?) ?? [];
      for (final ep in units) {
        final epMap = ep as Map<String, dynamic>;
        final epId = epMap['id'] as String?;
        final turns = (epMap['turns'] as List?) ?? [];
        for (final t in turns) {
          final m = t as Map<String, dynamic>;
          batch.add(TurnsCompanion.insert(
            level: level,
            dialect: const Value('north'),
            episodeId: Value(epId),
            num: m['num'] as int,
            speaker: m['speaker'] as String,
            ja: m['ja'] as String,
            kana: Value(m['kana'] as String?),
            romaji: Value(m['romaji'] as String?),
            ko: Value(m['ko'] as String?),
            note: Value(m['note'] as String?),
            tagsJson: Value(m['tags'] != null ? json.encode(m['tags']) : null),
          ));
        }
      }
    }
    if (batch.isNotEmpty) {
      await db.delete(db.userProgress).go();
      await db.delete(db.turns).go();
      await db.batch((b) => b.insertAll(db.turns, batch));
    }
  }

  Future<int> turnCount() => db.turns.count().getSingle();
  Future<int> kanjiCount() => db.kanji.count().getSingle();
  Future<int> wordCount() => db.words.count().getSingle();
}
