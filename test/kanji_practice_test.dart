import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/kanji_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('3자 이상 패밀리 94개, 큰 가족부터, 하루 3패밀리', () async {
    final days = await KanjiPractice.days();
    final fams = days.expand((d) => d).toList();
    expect(fams.length, 94);
    expect(days.length, 32);
    expect(fams.first.members.length >= fams.last.members.length, isTrue);
    expect(fams.every((f) => f.members.length >= 3), isTrue);
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
}
