import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/db/app_database.dart';
import '../main.dart';

/// 후리가나 분절 1개 — text 위에 reading (null 이면 가나/기호 그대로)
class FuriSeg {
  final String text;
  final String? reading;
  const FuriSeg(this.text, this.reading);
}

/// JLPT 단어 (DB 행 + 분절 파싱)
class WordEntry {
  final JlptWordRow row;
  final List<FuriSeg> segs;
  WordEntry(this.row) : segs = _parse(row);

  static List<FuriSeg> _parse(JlptWordRow r) {
    final raw = r.segsJson;
    if (raw == null) {
      // 분절 정보 없음: 한자 포함이면 통째 루비, 아니면 그대로
      final hasKanji = r.surface.runes.any((c) => c >= 0x4E00 && c <= 0x9FFF);
      return [FuriSeg(r.surface, hasKanji && r.kana != r.surface ? r.kana : null)];
    }
    final list = json.decode(raw) as List;
    return [for (final s in list) FuriSeg((s as List)[0] as String, s[1] as String?)];
  }

  int get id => row.id;
  String get surface => row.surface;
  String get kana => row.kana;
  int? get jlpt => row.jlpt;
  String get gloss => (row.ko?.isNotEmpty ?? false) ? row.ko! : (row.en ?? '');
  bool get hasKo => row.ko?.isNotEmpty ?? false;
  String get jlptLabel => jlpt == null ? '회화' : 'N$jlpt';
}

/// 한자 1자 ↔ 읽기별 단어 묶음
class ReadingGroup {
  final String reading; // 단어 안 실제 읽기 (예: こと)
  final List<WordEntry> words;
  const ReadingGroup(this.reading, this.words);
}

/// JLPT 단어·후리가나 DB 조회 (Drift)
class WordService {
  WordService._();
  static final WordService instance = WordService._();

  static const int perPage = 200;

  Future<List<WordEntry>> byLevel(int? level, {int offset = 0, int limit = perPage}) async {
    final q = appDb.select(appDb.jlptWords)
      ..where((w) => level == null ? w.jlpt.isNull() : w.jlpt.equals(level))
      ..orderBy([(w) => OrderingTerm.asc(w.rank.isNull()), (w) => OrderingTerm.asc(w.rank), (w) => OrderingTerm.asc(w.id)])
      ..limit(limit, offset: offset);
    final rows = await q.get();
    return rows.map(WordEntry.new).toList();
  }

  Future<int> countLevel(int? level) async {
    final q = appDb.selectOnly(appDb.jlptWords)..addColumns([appDb.jlptWords.id.count()]);
    if (level == null) {
      q.where(appDb.jlptWords.jlpt.isNull());
    } else {
      q.where(appDb.jlptWords.jlpt.equals(level));
    }
    final row = await q.getSingle();
    return row.read(appDb.jlptWords.id.count()) ?? 0;
  }

  /// 표기·가나·뜻(ko/en) 검색
  Future<List<WordEntry>> search(String query, {int limit = 100}) async {
    final t = query.trim();
    if (t.isEmpty) return const [];
    final like = '%$t%';
    final q = appDb.select(appDb.jlptWords)
      ..where((w) => w.surface.like(like) | w.kana.like(like) | w.ko.like(like) | w.en.like(like))
      ..orderBy([(w) => OrderingTerm.desc(w.jlpt), (w) => OrderingTerm.asc(w.rank.isNull()), (w) => OrderingTerm.asc(w.rank)])
      ..limit(limit);
    return (await q.get()).map(WordEntry.new).toList();
  }

  /// 한자 1자가 들어간 단어를 "그 단어 안 읽기" 별로 묶어 반환 (읽기 그룹은 단어 수 내림차순).
  Future<List<ReadingGroup>> wordsForKanji(String char, {int maxPerReading = 12}) async {
    final segs = await (appDb.select(appDb.wordSegments)..where((s) => s.char.equals(char))).get();
    if (segs.isEmpty) return const [];
    final byReading = <String, List<int>>{};
    for (final s in segs) {
      byReading.putIfAbsent(s.reading ?? '?', () => []).add(s.wordId);
    }
    final ids = segs.map((s) => s.wordId).toSet().toList();
    final rows = await (appDb.select(appDb.jlptWords)..where((w) => w.id.isIn(ids))).get();
    final byId = {for (final r in rows) r.id: r};
    int score(JlptWordRow r) => -(r.jlpt ?? 0) * 100000 + (r.rank ?? 99999);
    final groups = <ReadingGroup>[];
    for (final e in byReading.entries) {
      final ws = e.value.map((id) => byId[id]).whereType<JlptWordRow>().toList()..sort((a, b) => score(a).compareTo(score(b)));
      final dedup = <String>{};
      final entries = <WordEntry>[];
      for (final r in ws) {
        if (dedup.add('${r.surface}|${r.kana}')) entries.add(WordEntry(r));
        if (entries.length >= maxPerReading) break;
      }
      groups.add(ReadingGroup(e.key, entries));
    }
    groups.sort((a, b) => b.words.length.compareTo(a.words.length));
    return groups;
  }

  Future<List<KanjiReadingRow>> readingsFor(String char) =>
      (appDb.select(appDb.kanjiReadings)..where((r) => r.char.equals(char))).get();

  Future<WordEntry?> byId(int id) async {
    final r = await (appDb.select(appDb.jlptWords)..where((w) => w.id.equals(id))).getSingleOrNull();
    return r == null ? null : WordEntry(r);
  }
}
