import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ─── Tables ─────────────────────────────────────────────────────────────────

@DataClassName('TurnRow')
class Turns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => text()(); // 'L1' | 'L2' | 'L3'
  TextColumn get dialect => text().withDefault(const Constant('north'))(); // 'north'(도쿄) | 'south'(간사이)
  TextColumn get episodeId => text().nullable()(); // 'ep1' .. 'ep5'
  IntColumn get num => integer()();
  TextColumn get speaker => text()(); // 'A' | 'B'
  TextColumn get ja => text()();
  TextColumn get kana => text().nullable()();
  TextColumn get romaji => text().nullable()();
  TextColumn get ko => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get tagsJson => text().nullable()();
}

@DataClassName('KanjiRow')
class Kanji extends Table {
  TextColumn get char => text()();
  IntColumn get rank => integer().nullable()(); // 회화 가중 빈도 순위 (1,078 안)
  RealColumn get pct => real().nullable()();
  IntColumn get jlpt => integer().nullable()(); // 5..1 (N5..N1)
  IntColumn get grade => integer().nullable()(); // 학년 (1-6, 8=중학)
  IntColumn get strokes => integer().nullable()();
  TextColumn get meaningKo => text().nullable()(); // 대표 훈음 (예: '말씀 언')
  TextColumn get meaningsKoJson => text().nullable()(); // 훈음 목록 JSON
  TextColumn get meaningsEn => text().nullable()();
  TextColumn get onyomi => text().nullable()(); // 음독 (·구분)
  TextColumn get kunyomi => text().nullable()(); // 훈독 (·구분)
  TextColumn get koHanja => text().nullable()();

  @override
  Set<Column> get primaryKey => {char};
}

/// 한자 1자의 읽기 1개 (음독/훈독) — kind: 'on' | 'kun'
@DataClassName('KanjiReadingRow')
class KanjiReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get char => text().references(Kanji, #char)();
  TextColumn get reading => text()(); // 표시용 (음독 가타카나 / 훈독 'い-きる')
  TextColumn get base => text()(); // 매칭용 히라가나 base (い)
  TextColumn get kind => text()();
  TextColumn get gloss => text().nullable()();
}

/// JLPT 어휘 + 회화 top2500 한자어. segsJson = [[text, reading|null], ...]
@DataClassName('JlptWordRow')
class JlptWords extends Table {
  IntColumn get id => integer()();
  TextColumn get surface => text()();
  TextColumn get kana => text()();
  IntColumn get jlpt => integer().nullable()();
  TextColumn get en => text().nullable()();
  TextColumn get ko => text().nullable()();
  IntColumn get rank => integer().nullable()();
  TextColumn get src => text().nullable()();
  TextColumn get segsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 단어 안 후리가나 분절 — 한자 1자 분절이면 char 채움 (한자↔읽기↔단어 링크)
@DataClassName('WordSegmentRow')
class WordSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(JlptWords, #id)();
  IntColumn get idx => integer()();
  TextColumn get segText => text()();
  TextColumn get reading => text().nullable()();
  TextColumn get char => text().nullable()();
}

@DataClassName('WordRow')
class Words extends Table {
  IntColumn get rank => integer()();
  TextColumn get word => text()();
  RealColumn get freq => real().nullable()();
  RealColumn get cumPct => real().nullable()();
  TextColumn get region => text().nullable()(); // R1, R2, R3, R4

  @override
  Set<Column> get primaryKey => {rank};
}

@DataClassName('UserProgressRow')
class UserProgress extends Table {
  IntColumn get turnId => integer().references(Turns, #id)();
  BoolColumn get learned => boolean().withDefault(const Constant(false))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastReviewed => dateTime().nullable()();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {turnId};
}

@DataClassName('KanjiProgressRow')
class KanjiProgress extends Table {
  TextColumn get char => text().references(Kanji, #char)();
  BoolColumn get known => boolean().withDefault(const Constant(false))();
  IntColumn get exposureCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewed => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {char};
}

@DataClassName('StageResultRow')
class StageResults extends Table {
  IntColumn get stage => integer()();
  IntColumn get correct => integer().withDefault(const Constant(0))();
  IntColumn get total => integer().withDefault(const Constant(0))();
  IntColumn get bestPct => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {stage};
}

@DataClassName('UserMemoRow')
class UserMemos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get context => text()(); // screen+turn or 'global'
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Database ───────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Turns,
  Kanji,
  KanjiReadings,
  JlptWords,
  WordSegments,
  Words,
  UserProgress,
  KanjiProgress,
  StageResults,
  UserMemos,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 테스트용 (in-memory 등 임의 executor)
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // 미출시 단계: 스키마 변경 시 전체 재생성 (SeedLoader 키 버전과 함께 올림)
          for (final t in allTables) {
            await m.deleteTable(t.actualTableName);
          }
          await m.createAll();
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'japanese_universe');
  }
}
