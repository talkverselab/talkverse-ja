import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/kanji_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('3자 이상 패밀리 94개, 큰 가족부터, 하루 3자', () async {
    final days = await KanjiPractice.days();
    expect(KanjiPractice.roots.length, 94);
    expect(days.expand((d) => d).map((f) => f.root).toSet().length, 94);
    final per = [for (final d in days) d.fold<int>(0, (a, f) => a + f.members.length)];
    expect(per.sublist(0, per.length - 1).every((n) => n == 3), isTrue);
    expect(days.first.first.root, KanjiPractice.roots.first);
  });

  for (final w in const [320.0, 900.0]) {
    testWidgets('목록·하루 화면 폭 $w 넘침 없음, 문제 끝까지', (t) async {
      t.view.physicalSize = Size(w, 2400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: KanjiPracticeScreen()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('kp-day-1')));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.tap(find.byKey(const ValueKey('kp-action')));
      await t.pumpAndSettle();
      for (var i = 0; i < 40 && find.byKey(const ValueKey('kp-next')).evaluate().isEmpty && find.textContaining('맞힘').evaluate().isEmpty; i++) {
        await t.tap(find.byType(OutlinedButton).first);
        await t.pumpAndSettle();
        await t.tap(find.byKey(const ValueKey('kp-next')));
        await t.pumpAndSettle();
      }
      expect(t.takeException(), isNull);
      expect(find.textContaining('맞힘'), findsOneWidget);
    });
  }

  testWidgets('누적 복습: 1일차 마친 뒤 열림, 틀린 글자 기록', (t) async {
    for (var d = 1; d <= 7; d++) {
      await KanjiPractice.markDone(d);
    }
    t.view.physicalSize = const Size(390, 2400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: KanjiPracticeScreen()));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('kp-review')));
    await t.pumpAndSettle();
    for (var i = 0; i < 30 && find.textContaining('맞힘').evaluate().isEmpty; i++) {
      await t.tap(find.byType(OutlinedButton).first);
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('kr-next')));
      await t.pumpAndSettle();
    }
    expect(t.takeException(), isNull);
    expect(find.textContaining('20문제 중'), findsOneWidget);
  });
}
