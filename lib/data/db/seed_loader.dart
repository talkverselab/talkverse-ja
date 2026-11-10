import '../../core/embed_env.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/prefs.dart';

import 'app_database.dart';

class SeedLoader {
  // v2: 한자 DB (JLPT 2,285) + JLPT 어휘·후리가나 분절 (7,900)

  final AppDatabase db;
  SeedLoader(this.db);

  /// 번들 `assets/data/version.json` 의 `db`(업데이트 번호)와 저장된 번호가 다르면 DB 를 맞춘다(사용자 지시 2026-11-04).
  /// 2026-11-10: 전부 다시 채우지 않고 **원본 자료가 바뀐 표만** 다시 채운다(자료 sha1 을 표마다 기억) — 같은 내용을 두 번 넣지 않는다.
  /// 무엇이 바뀌었는지는 변경 기록 `db_log`(번호·앱 빌드·표별 줄 수)에 남는다. 학습 기록(user_progress)은 지우지 않고 편·턴 번호로 다시 잇는다.
  static const _kDbVersion = 'db_version';
  static const _kDbLog = 'db_log';
  Future<void> seedIfNeeded() async {
    final prefs = await Prefs.getInstance();
    final bundled = await bundledVersion();
    if (prefs.getInt(_kDbVersion) == bundled) return;
    final from = prefs.getInt(_kDbVersion);
    final changed = <String, int>{}, same = <String>[];
    Future<void> step(String name, List<String> assets, Future<void> Function() seed, Future<int> Function() count) async {
      final h = sha1.convert(utf8.encode([for (final a in assets) await _asset(a)].join('\u0000'))).toString();
      if (from != null && prefs.getString('seed_sha_$name') == h && await count() > 0) {
        same.add(name);
        return;
      }
      await seed();
      await prefs.setString('seed_sha_$name', h);
      changed[name] = await count();
    }
    await step('kanji', ['assets/data/kanji/kanji_db.json', 'assets/data/hanja/hanja_crossref.json'], _seedKanji, kanjiCount);
    await step('jlpt_words', ['assets/data/words/words_jlpt.json'], _seedJlptWords, jlptWordCount);
    await step('words', ['assets/data/freq/lang_ja_with_regions.csv'], () async {
      await db.delete(db.words).go();
      await _seedWords();
    }, wordCount);
    await step('turns', [for (final l in ['L1', 'L2', 'L3']) 'assets/data/dialogues/$l.json'], _seedTurns, turnCount);
    await prefs.setInt(_kDbVersion, bundled);
    // 변경 기록: 최근 것이 앞, 50줄까지
    int build = 0;
    try {
      build = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
    } catch (_) {}
    final log = dbLog(prefs)
      ..insert(0, {'v': bundled, 'from': from, 'at': DateTime.now().toIso8601String(), 'build': build, 'changed': changed, 'same': same});
    await prefs.setString(_kDbLog, json.encode(log.take(50).toList()));
  }

  /// DB 변경 기록. 한 줄 = {v 새 번호, from 옛 번호, at, build 앱 빌드, changed {표: 줄 수}, same [안 바뀐 표]}.
  static List<Map<String, dynamic>> dbLog(Prefs prefs) {
    try {
      return [for (final e in json.decode(prefs.getString(_kDbLog) ?? '[]') as List) (e as Map).cast<String, dynamic>()];
    } catch (_) {
      return [];
    }
  }

  /// 번들 version.json 의 설명 줄(번호 → 무엇을 바꿨는지).
  static Future<Map<int, String>> bundledNotes() async {
    try {
      final j = json.decode(await rootBundle.loadString(assetPath('assets/data/version.json'))) as Map<String, dynamic>;
      return {for (final e in (j['log'] as List? ?? const [])) ((e as Map)['v'] as num).toInt(): '${e['date'] ?? ''} · ${e['note'] ?? ''}'};
    } catch (_) {
      return {};
    }
  }

  static Future<String> _asset(String path) async {
    try {
      return await rootBundle.loadString(assetPath(path));
    } catch (_) {
      return '';
    }
  }

  static Future<int> bundledVersion() async {
    try {
      final j = json.decode(await rootBundle.loadString(assetPath('assets/data/version.json'))) as Map<String, dynamic>;
      return (j['db'] as num).toInt();
    } catch (_) {
      return 0;
    }
  }

  static String _hira(String s) => String.fromCharCodes(
      s.codeUnits.map((c) => (c >= 0x30A1 && c <= 0x30F6) ? c - 0x60 : c));

  /// 읽기 → 매칭용 base (히라가나, 오쿠리가나·접사 제거): 'い-きる' → 'い', 'ゲン' → 'げん'
  static String readingBase(String r) {
    final cut = r.split('-').first.split('.').first;
    return _hira(cut.replaceAll(RegExp(r'[()（）\s]'), ''));
  }

  Future<void> _seedKanji() async {
    final raw = await rootBundle.loadString(assetPath('assets/data/kanji/kanji_db.json'));
    final data = json.decode(raw) as Map<String, dynamic>;
    final entries = (data['entries'] as List?) ?? [];

    // 한국 한자 crossref (ko_hanja) 병합
    final koMap = <String, String>{};
    try {
      final hraw = await rootBundle.loadString(assetPath('assets/data/hanja/hanja_crossref.json'));
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
    final raw = await rootBundle.loadString(assetPath('assets/data/words/words_jlpt.json'));
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
    final raw = await rootBundle.loadString(assetPath('assets/data/freq/lang_ja_with_regions.csv'));
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
        final raw = await rootBundle.loadString(assetPath('assets/data/dialogues/$level.json'));
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
      // 턴 id 는 다시 매겨지므로 학습 기록을 (단계·편·턴 번호)로 기억했다가 새 id 에 다시 잇는다 — 전에는 DB 번호가 오를 때마다 기록을 지웠다.
      final old = await db.customSelect(
              'SELECT t.level l, t.episode_id e, t.num n, p.learned, p.favorite, p.last_reviewed, p.review_count FROM user_progress p JOIN turns t ON t.id = p.turn_id')
          .get();
      await db.delete(db.userProgress).go();
      await db.delete(db.turns).go();
      await db.batch((b) => b.insertAll(db.turns, batch));
      for (final r in old) {
        await db.customStatement(
            'INSERT OR REPLACE INTO user_progress (turn_id, learned, favorite, last_reviewed, review_count) '
            'SELECT id, ?, ?, ?, ? FROM turns WHERE level = ? AND episode_id IS ? AND num = ? LIMIT 1',
            [r.data['learned'], r.data['favorite'], r.data['last_reviewed'], r.data['review_count'], r.data['l'], r.data['e'], r.data['n']]);
      }
    }
  }

  Future<int> turnCount() => db.turns.count().getSingle();
  Future<int> kanjiCount() => db.kanji.count().getSingle();
  Future<int> wordCount() => db.words.count().getSingle();
  Future<int> jlptWordCount() => db.jlptWords.count().getSingle();
  Future<int> segmentCount() => db.wordSegments.count().getSingle();
}
