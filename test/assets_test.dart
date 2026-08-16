import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/data/db/app_database.dart';
import 'package:japanese_universe/data/db/seed_loader.dart';
import 'package:japanese_universe/screens/episode_screen.dart';
import 'package:japanese_universe/services/deck_service.dart';
import 'package:japanese_universe/services/kanji_index_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('kanji db loads JLPT + corpus kanji and searches', () async {
    await KanjiIndexService.instance.ensureLoaded();
    expect(KanjiIndexService.instance.all.length, greaterThan(2200));
    expect(KanjiIndexService.instance.lookup('言')?.meaning, '말씀 언');
    expect(KanjiIndexService.instance.lookup('言')?.jlpt, 4);
    expect(KanjiIndexService.instance.lookup('猫')?.meaning, '고양이 묘');
    expect(KanjiIndexService.instance.search('사랑').isNotEmpty, true);
    final stages = KanjiIndexService.instance.stages();
    expect(stages.first.level, 5);
    expect(stages.length, greaterThan(100));
    expect(KanjiIndexService.instance.forLevel(5).length, 79);
  });

  test('decks load', () async {
    await DeckService.instance.ensureLoaded();
    expect(DeckService.instance.decks.length, 5);
    expect(DeckService.instance.decks.first.cards.isNotEmpty, true);
  });

  test('episode catalog: L1 planned 5, ready 1', () async {
    await EpisodeCatalog.instance.ensureLoaded();
    expect(EpisodeCatalog.instance.plannedForLevel('L1').length, 5);
    expect(EpisodeCatalog.instance.forLevel('L1').length, 1);
  });

  test('seed loader fills turns/kanji/words', () async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final seed = SeedLoader(db);
    await seed.seedIfNeeded();
    expect(await seed.turnCount(), 40);
    expect(await seed.kanjiCount(), greaterThan(2200));
    expect(await seed.wordCount(), 2500);
    expect(await seed.jlptWordCount(), greaterThan(7500));
    expect(await seed.segmentCount(), greaterThan(14000));
    // 言 ↔ こと ↔ 言葉 링크
    final segs = await (db.select(db.wordSegments)..where((s) => s.char.equals('言'))).get();
    expect(segs.any((s) => s.reading == 'こと'), true);
    final readings = await (db.select(db.kanjiReadings)..where((r) => r.char.equals('生'))).get();
    expect(readings.map((r) => r.base).toSet().containsAll({'せい', 'い', 'う', 'なま'}), true);
    await db.close();
  });
}
