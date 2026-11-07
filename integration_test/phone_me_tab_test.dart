// 폰(아이폰) 「나」 탭 성과 데스크 레이아웃 확인용 스크린샷 — 2026-11-04.
// 실행: python3 tools/pane_shots.py <아이폰 UDID> <출력폴더> integration_test/phone_me_tab_test.dart
import 'package:flutter/material.dart' show Scrollable;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:japanese_universe/core/l10n.dart';
import 'package:japanese_universe/data/db/app_database.dart';
import 'package:japanese_universe/data/db/seed_loader.dart';
import 'package:japanese_universe/main.dart';
import 'package:japanese_universe/review/review_service.dart';
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
    await wait(t, 1500);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 2500);
  }

  testWidgets('phone me tab', timeout: const Timeout(Duration(minutes: 6)), (t) async {
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await ReviewService.instance.load();
    await t.pumpWidget(const JapaneseUniverseApp());
    await wait(t, 2500);
    final later = find.text('나중에');
    if (later.evaluate().isNotEmpty) {
      await t.tap(later.first);
      await wait(t, 1200);
    }
    await t.tap(find.text('프로필').last);
    await wait(t, 2500);
    await shot(t, '30_me_top');
    final s = find.byType(Scrollable).first;
    for (var i = 1; i <= 4; i++) {
      await t.drag(s, const Offset(0, -600));
      await wait(t, 800);
      await shot(t, '3${i}_me_scroll$i');
    }
  });
}
