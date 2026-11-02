// 새 회화 뷰어(아이패드 두 화면) 확인용 스크린샷 흐름 — 2026-11-03.
// 실행: python3 tools/pane_shots.py <아이패드 UDID> <출력폴더> integration_test/dialogue_pane_test.dart
import 'package:flutter/material.dart' show ListTile;
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
    await wait(t, 2000);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 3000);
  }

  testWidgets('dialogue pane', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await ReviewService.instance.load();
    await t.pumpWidget(const JapaneseUniverseApp());
    await wait(t, 1500);
    await shot(t, '10_learn_with_dialogue_section');

    await t.tap(find.text('주제별 회화 R0~R4'));
    await wait(t, 2500);
    await shot(t, '11_dialogue_home_right');

    await t.tap(find.text('친구').first);
    await wait(t, 1200);
    await shot(t, '12_island_list');

    await t.tap(find.textContaining('사진이랑').first);
    await wait(t, 1500);
    await shot(t, '13_dialogue_bubbles');

    await t.tap(find.text('재생').first); // 시안 02: 편 화면이 곧 리더, ▶ 재생
    await wait(t, 2500);
    await shot(t, '14_play_pane_right');
    await wait(t, 4000);
    await shot(t, '15_play_pane_progress');

    // 그림만 카드
    await t.tap(find.byTooltip('그림 카드(글자 없이)'));
    await wait(t, 1500);
    await shot(t, '16_picture_card_front');
    await t.tap(find.text('탭해서 확인'));
    await wait(t, 800);
    await shot(t, '17_picture_card_back');
    await t.pageBack();
    await wait(t, 1200);

    // 스크립트 3번(写真)을 눌러 현재 턴으로 만든 뒤, 캡션의 한자 팝업(글자 형성·그림)
    await t.tap(find.textContaining('写真').first);
    await wait(t, 1200);
    final kanji = find.text('写');
    if (kanji.evaluate().isNotEmpty) await t.tap(kanji.first);
    await wait(t, 3500);
    await shot(t, '18_kanji_sheet_formation');
    await t.tapAt(const Offset(40, 120));
    await wait(t, 800);

    await t.tap(find.text('복습').last);
    await wait(t, 1500);
    await shot(t, '19_review_today_leitner');

    // 「나」 탭 성과 데스크
    await t.tap(find.text('나').last);
    await wait(t, 2500);
    await shot(t, '20_me_achievement_desk');

    // 패밀리 한자(공용 가족 DB) — 목록 → 가족 지도 → 씨앗 모핑
    await t.tap(find.text('배우기').last);
    await wait(t, 1200);
    await t.tap(find.text('패밀리 한자').first);
    await wait(t, 6000);
    await shot(t, '21_family_list');
    final fam = find.textContaining('자').first;
    if (find.byType(ListTile).evaluate().isNotEmpty) {
      await t.tap(find.byType(ListTile).first);
      await wait(t, 3500);
      await shot(t, '22_family_map');
    } else {
      // ignore: avoid_print
      print('no family rows: $fam');
    }
  });
}
