import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_database.dart';

class SeedLoader {
  // v2: 한자 DB (JLPT 2,285) + JLPT 어휘·후리가나 분절 (7,900)
  static const _kSeededKey = 'db_seeded_v3'; // v3: N5·N4 한국어 뜻 1,225

  final AppDatabase db;
  SeedLoader(this.db);

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kSeededKey) == true) return;

    await _seedKanji();
    await _seedJlptWords();
    await _seedWords();
    await _seedTurns();

    await prefs.setBool(_kSeededKey, true);
  }

  static String _hira(String s) => String.fromCharCodes(
      s.codeUnits.map((c) => (c >= 0x30A1 && c <= 0x30F6) ? c - 0x60 : c));

  /// 읽기 → 매칭용 base (히라가나, 오쿠리가나·접사 제거): 'い-きる' → 'い', 'ゲン' → 'げん'
  static String readingBase(String r) {
    final cut = r.split('-').first.split('.').first;
    return _hira(cut.replaceAll(RegExp(r'[()（）\s]'), ''));
  }

  Future<void> _seedKanji() async {
    final raw = await rootBundle.loadString('assets/data/kanji/kanji_db.json');
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
    final readings = <Insertable<KanjiReadingRow>>[];
    for (final e in entries.whereType<Map>()) {
      final char = e['char'] as String;
      final meanings = (e['meanings_ko'] as List?)?.cast<String>() ?? const [];
      final on = (e['on'] as List?)?.cast<String>() ?? const [];
      final kun = (e['kun'] as List?)?.cast<String>() ?? const [];
      final glosses = (e['glosses'] as Map?)?.cast<String, dynamic>() ?? const {};
      batch.add(KanjiCompanion.insert(
        char: char,
        rank: Value(e['rank'] as int?),
        pct: Value((e['pct'] as num?)?.toDouble()),
        jlpt: Value(e['jlpt'] as int?),
        grade: Value(e['grade'] as int?),
        strokes: Value(e['strokes'] as int?),
        meaningKo: Value(meanings.isEmpty ? null : meanings.first),
        meaningsKoJson: Value(json.encode(meanings)),
        meaningsEn: Value(((e['meanings_en'] as List?) ?? []).join(', ')),
        onyomi: Value(on.isEmpty ? null : on.join('·')),
        kunyomi: Value(kun.isEmpty ? null : kun.join('·')),
        koHanja: Value(koMap[char]),
      ));
      for (final r in on) {
        readings.add(KanjiReadingsCompanion.insert(
          char: char,
          reading: r,
          base: readingBase(r),
          kind: 'on',
          gloss: Value(glosses[readingBase(r)] as String?),
        ));
      }
      for (final r in kun) {
        readings.add(KanjiReadingsCompanion.insert(
          char: char,
          reading: r,
          base: readingBase(r),
          kind: 'kun',
          gloss: Value(glosses[readingBase(r)] as String?),
        ));
      }
    }
    await db.delete(db.kanjiReadings).go();
    await db.batch((b) => b.insertAllOnConflictUpdate(db.kanji, batch));
    await db.batch((b) => b.insertAll(db.kanjiReadings, readings));
  }

  /// JLPT 어휘 + 후리가나 분절 시딩
  Future<void> _seedJlptWords() async {
    final raw = await rootBundle.loadString('assets/data/words/words_jlpt.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final entries = (data['entries'] as List?) ?? [];
    final words = <Insertable<JlptWordRow>>[];
    final segs = <Insertable<WordSegmentRow>>[];
    for (final e in entries.whereType<Map>()) {
      final id = e['id'] as int;
      final segList = e['segs'] as List?;
      words.add(JlptWordsCompanion.insert(
        id: Value(id),
        surface: e['surface'] as String,
        kana: e['kana'] as String,
        jlpt: Value(e['jlpt'] as int?),
        en: Value(e['en'] as String?),
        ko: Value(e['ko'] as String?),
        rank: Value(e['rank'] as int?),
        src: Value(e['src'] as String?),
        segsJson: Value(segList == null ? null : json.encode(segList)),
      ));
      if (segList != null) {
        for (var i = 0; i < segList.length; i++) {
          final s = segList[i] as List;
          final text = s[0] as String;
          final reading = s[1] as String?;
          final isSingleKanji = text.runes.length == 1 && _isKanji(text);
          segs.add(WordSegmentsCompanion.insert(
            wordId: id,
            idx: i,
            segText: text,
            reading: Value(reading),
            char: Value(isSingleKanji ? text : null),
          ));
        }
      }
    }
    await db.delete(db.wordSegments).go();
    await db.delete(db.jlptWords).go();
    await db.batch((b) => b.insertAll(db.jlptWords, words));
    await db.batch((b) => b.insertAll(db.wordSegments, segs));
  }

  static bool _isKanji(String c) {
    final code = c.runes.first;
    return (code >= 0x4E00 && code <= 0x9FFF) || (code >= 0x3400 && code <= 0x4DBF);
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
  Future<int> jlptWordCount() => db.jlptWords.count().getSingle();
  Future<int> segmentCount() => db.wordSegments.count().getSingle();
}
