// 한자 팝업 「글자 형성」(회의·형성 구조) 확인용 스크린샷 — 2026-11-03.
// 실행: python3 tools/pane_shots.py <아이패드 UDID> <출력폴더> integration_test/kanji_formation_test.dart
import 'package:flutter/material.dart' show Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:japanese_universe/core/l10n.dart';
import 'package:japanese_universe/data/db/app_database.dart';
import 'package:japanese_universe/data/db/seed_loader.dart';
import 'package:japanese_universe/main.dart';
import 'package:japanese_universe/review/review_service.dart';
import 'package:japanese_universe/services/kanji_index_service.dart';
import 'package:japanese_universe/services/ko_reading.dart';
import 'package:japanese_universe/widgets/selectable_ja_text.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    await wait(t, 2000);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 3000);
  }

  testWidgets('kanji formation', timeout: const Timeout(Duration(minutes: 8)), (t) async {
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await ReviewService.instance.load();
    await KanjiIndexService.instance.ensureLoaded();
    await t.pumpWidget(const JapaneseUniverseApp());
    await wait(t, 1500);
    // 한자 배우기 화면을 거치지 않고 팝업만 직접 띄운다
    final ctx = t.element(find.byType(Text).first);
    for (final (ch, name) in [('語', '30_formation_keisei_go'), ('休', '31_formation_kaii_kyu'), ('江', '32_formation_keisei_kou')]) {
      // ignore: unawaited_futures
      showKanjiSheet(ctx, char: ch, entry: KanjiIndexService.instance.lookup(ch));
      await wait(t, 4500);
      await shot(t, name);
      await t.tapAt(const Offset(40, 120));
      await wait(t, 1000);
    }
  });
}
