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

  test('kanji index loads 1078 entries and searches', () async {
    await KanjiIndexService.instance.ensureLoaded();
    expect(KanjiIndexService.instance.all.length, 1078);
    expect(KanjiIndexService.instance.lookup('言')?.meaning, '말씀 언');
    expect(KanjiIndexService.instance.search('사랑').isNotEmpty, true);
    expect(KanjiIndexService.instance.stages().length, greaterThan(40));
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
    expect(await seed.kanjiCount(), 1078);
    expect(await seed.wordCount(), 2500);
    await db.close();
  });
}
