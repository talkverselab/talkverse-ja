// 태블릿·아이패드·폴드 펼침 두 화면(레일 + 왼쪽 목록 | 오른쪽 칸) 확인용 스크린샷 흐름.
// 실행: python3 tools/pane_shots.py <아이패드 UDID> <출력폴더>
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
    await wait(t, 2000);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 3000);
  }

  testWidgets('two pane', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await t.pumpWidget(const JapaneseUniverseApp());
    await wait(t, 1500);
    await shot(t, '01_learn');

    await t.tap(find.text('탐색').last);
    await wait(t, 800);
    await t.tap(find.text('한자 사전'));
    await shot(t, '02_explore_pane_dictionary');
    await t.tap(find.text('배우기').last);
    await wait(t, 800);
    await t.tap(find.text('조사').first);
    await shot(t, '03_learn_pane_particles');

    await t.tap(find.textContaining('EP1').first);
    await wait(t, 1500);
    await shot(t, '05_episode_full_split');
    final bubbles = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key as ValueKey<String>).value.startsWith('bubble-'));
    // 두 번째 버블의 위 여백(글자 밖 — 한자를 누르면 한자 시트가 뜬다)을 눌러 오른쪽 반만 그 카드로
    await t.tapAt(t.getTopLeft(bubbles.at(1)) + Offset(t.getSize(bubbles.at(1)).width / 2, 5));
    await shot(t, '06_episode_card_right');
    await t.pageBack();
    await wait(t, 1500);

    await t.tap(find.text('복습').last);
    await shot(t, '07_review');
    await t.tap(find.text('나').last);
    await shot(t, '08_me');
  });
}
