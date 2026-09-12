import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import '../core/l10n.dart';

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

  bool get isOn => kind == tr('음독');
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
  final int rank; // 회화 가중 빈도 순위 (없으면 9999)
  final double pct;
  final int? jlpt; // 5..1
  final int? grade;
  final int? strokes;
  final List<String> meanings; // 한국어 훈음
  final String meaningsEn;
  final List<KanjiReading> readings;
  final List<ExampleWord> words;

  const KanjiEntry({
    required this.char,
    required this.rank,
    required this.pct,
    this.jlpt,
    this.grade,
    this.strokes,
    required this.meanings,
    this.meaningsEn = '',
    required this.readings,
    required this.words,
  });

  /// kanji_db.json 엔트리
  factory KanjiEntry.fromDbJson(Map<String, dynamic> j) {
    final glosses = (j['glosses'] as Map?)?.cast<String, dynamic>() ?? const {};
    String base(String r) => KanjiIndexService.toHiragana(r.split('-').first);
    return KanjiEntry(
      char: j['char'] as String,
      rank: j['rank'] as int? ?? 9999,
      pct: (j['pct'] as num?)?.toDouble() ?? 0,
      jlpt: j['jlpt'] as int?,
      grade: j['grade'] as int?,
      strokes: j['strokes'] as int?,
      meanings: (j['meanings_ko'] as List?)?.cast<String>() ?? const [],
      meaningsEn: ((j['meanings_en'] as List?) ?? []).join(', '),
      readings: [
        for (final r in (j['on'] as List? ?? []).cast<String>())
          KanjiReading(reading: r, kind: tr('음독'), gloss: (glosses[base(r)] as String?) ?? ''),
        for (final r in (j['kun'] as List? ?? []).cast<String>())
          KanjiReading(reading: r, kind: tr('훈독'), gloss: (glosses[base(r)] as String?) ?? ''),
      ],
      words: const [],
    );
  }

  /// (구) kanji_index.json 엔트리
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

  String get jlptLabel => jlpt == null ? '—' : 'N$jlpt';

  String get meaning => meanings.isEmpty ? '' : meanings.first;
  String get meaningJoined => meanings.join(' · ');
  bool get hasDetail => meanings.isNotEmpty || readings.isNotEmpty;
  List<KanjiReading> get on => readings.where((r) => r.isOn).toList();
  List<KanjiReading> get kun => readings.where((r) => !r.isOn).toList();
}

/// 한자 퀴즈 단계 1개
class KanjiStage {
  final int stage; // 전체 통번호 (1..)
  final int? level; // 5..1, null=기타(JLPT 밖 회화 한자)
  final int indexInLevel;
  final String? freqLabel; // 빈도순 모드의 절벽구간 라벨 (R1~R4)
  final List<KanjiEntry> chars;
  const KanjiStage(
      {required this.stage, required this.level, required this.indexInLevel, required this.chars, this.freqLabel});

  String get levelLabel => freqLabel ?? (level == null ? tr('기타') : 'N$level');
}

/// kanji_db.json 로더 (JLPT N5-N1 ∪ 회화 1,078 = 2,285자) + 검색 + JLPT 단계 분할.
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
    final raw = await rootBundle.loadString('assets/data/kanji/kanji_db.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _all = (json['entries'] as List)
        .map((e) => KanjiEntry.fromDbJson(e as Map<String, dynamic>))
        .toList();
    // 예시 단어 (구 kanji_index.json) 병합 — 한국어 뜻 있는 회화 단어
    try {
      final raw2 = await rootBundle.loadString('assets/data/kanji/kanji_index.json');
      final j2 = jsonDecode(raw2) as Map<String, dynamic>;
      final byChar = {for (final e in _all) e.char: e};
      final merged = <String, KanjiEntry>{};
      for (final e in (j2['entries'] as List).cast<Map<String, dynamic>>()) {
        final base = byChar[e['char']];
        if (base == null) continue;
        merged[base.char] = KanjiEntry(
          char: base.char,
          rank: base.rank,
          pct: base.pct,
          jlpt: base.jlpt,
          grade: base.grade,
          strokes: base.strokes,
          meanings: base.meanings,
          meaningsEn: base.meaningsEn,
          readings: base.readings,
          words: (e['words'] as List?)
                  ?.map((w) => ExampleWord.fromJson(w as Map<String, dynamic>))
                  .toList() ??
              const [],
        );
      }
      _all = [for (final e in _all) merged[e.char] ?? e];
    } catch (_) {}
    _byChar = {for (final e in _all) e.char: e};
    _loaded = true;
  }

  KanjiEntry? lookup(String char) => _byChar[char];

  static bool isKanji(String c) {
    if (c.isEmpty) return false;
    final code = c.runes.first;
    return (code >= 0x4E00 && code <= 0x9FFF) || (code >= 0x3400 && code <= 0x4DBF);
  }

  /// JLPT 레벨별 (N5→N1) 한자 — 레벨 안에서는 회화 빈도순. jlpt 없는 회화 한자는 '기타'(0).
  List<KanjiEntry> forLevel(int? level) {
    final list = _all.where((e) => e.meanings.isNotEmpty && (level == null ? e.jlpt == null : e.jlpt == level)).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    return list;
  }

  /// JLPT 순 (N5→N1→기타) 20자 단위 단계. 반환: [(level, chars)]
  List<KanjiStage> stages() {
    final out = <KanjiStage>[];
    var n = 0;
    for (final level in [5, 4, 3, 2, 1, null]) {
      final pool = forLevel(level);
      for (var i = 0; i < pool.length; i += stageSize) {
        n++;
        out.add(KanjiStage(
          stage: n,
          level: level,
          indexInLevel: i ~/ stageSize + 1,
          chars: pool.sublist(i, (i + stageSize).clamp(0, pool.length)),
        ));
      }
    }
    return out;
  }

  /// 회화 빈도순 (레벨 무시) 20자 단위 단계. 절벽구간(R1~R4) 진행.
  /// level 필드에는 그 단계 첫 한자의 JLPT를 참고로 담지 않고 null을 둔다.
  List<KanjiStage> stagesByFreq() {
    final pool = _all.where((e) => e.meanings.isNotEmpty && e.rank < 9999).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    final out = <KanjiStage>[];
    var n = 0;
    String regionOf(int rank) =>
        rank <= 294 ? 'R1' : rank <= 437 ? 'R2' : rank <= 998 ? 'R3' : 'R4';
    for (var i = 0; i < pool.length; i += stageSize) {
      n++;
      final chars = pool.sublist(i, (i + stageSize).clamp(0, pool.length));
      out.add(KanjiStage(
        stage: n,
        level: null,
        indexInLevel: n,
        chars: chars,
        freqLabel: regionOf(chars.first.rank),
      ));
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
