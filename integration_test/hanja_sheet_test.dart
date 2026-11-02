// 한자 시트에 공용 DB(hanja-api) 칸이 뜨는지 확인용 캡처. 실행: python3 tools/pane_shots.py <UDID> <폴더> integration_test/hanja_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:japanese_universe/core/l10n.dart';
import 'package:japanese_universe/data/db/app_database.dart';
import 'package:japanese_universe/data/db/seed_loader.dart';
import 'package:japanese_universe/main.dart';
import 'package:japanese_universe/services/ko_reading.dart';

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
    await wait(t, 3500);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 3000);
  }

  testWidgets('hanja sheet', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await t.pumpWidget(const JapaneseUniverseApp());
    await wait(t, 1500);
    await t.tap(find.text('탐색').last);
    await wait(t, 800);
    await t.tap(find.text('한자 사전'));
    await wait(t, 1500);
    await t.tap(find.text('何').first); // 사전 목록 첫 글자 → 시트
    await shot(t, '10_sheet_何');
    await t.drag(find.byType(SingleChildScrollView).last, const Offset(0, -500));
    await shot(t, '11_sheet_何_scrolled');
  });
}
