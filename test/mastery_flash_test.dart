import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/word_unit_flash_screen.dart';
import 'package:japanese_universe/services/mastery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Fake extends FlashItem {
  final String k;
  _Fake(this.k);
  @override
  String get id => 'w:$k';
  @override
  Widget front(BuildContext context) => Center(child: Text('앞$k'));
  @override
  Widget back(BuildContext context) => Center(child: Text('뒤$k'));
  @override
  Future<void> speak() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'ja_wcard:本当': 2});
    Mastery.resetForTest();
    Mastery.clock = DateTime.now;
  });

  test('숙련도 ±20, 0~100, 옛 알아요 40%, 오래 안 보면 깎임', () async {
    await Mastery.load();
    expect(Mastery.pct('w:本当'), 40);
    expect(await Mastery.mark('w:x', known: false), 0);
    for (var i = 0; i < 7; i++) {
      await Mastery.mark('w:x', known: true);
    }
    expect(Mastery.pct('w:x'), 100);
    final now = DateTime.now();
    Mastery.clock = () => now.add(const Duration(days: 15));
    expect(Mastery.pct('w:x'), 90);
    expect(Mastery.average(['w:x', 'w:none']), 45);
  });

  test('색: 0% 파랑 → 100% 빨강', () {
    expect(masteryColor(0), const Color(0xFF2F6FDB));
    expect(masteryColor(100), const Color(0xFFD83A3A));
  });

  testWidgets('단원: 다시 고른 카드는 끝에 다시, 끝나면 개수', (t) async {
    t.view.physicalSize = const Size(390, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: UnitFlashScreen(title: '시험', items: [_Fake('a'), _Fake('b')])));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('flash-again')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('flash-known')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('flash-known')));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('알았음 2 · 다시 1'), findsOneWidget);
  });
}
