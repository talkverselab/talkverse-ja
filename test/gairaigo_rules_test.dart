import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/gairaigo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // 큰 에셋은 한 파일에서 한 번만 읽는다(두 번째 testWidgets 에서는 로딩이 끝나지 않음) — 폭만 바꿔 가며 본다.
  testWidgets('외국어 발음 규칙 — 규칙 한눈에 → 줄기, 폭 320·900 넘침 없음', (t) async {
    addTearDown(t.view.reset);
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(320, 2400);
    await t.pumpWidget(const MaterialApp(home: GairaigoScreen(rulesFirst: true)));
    for (var i = 0; i < 100 && find.byKey(const ValueKey('gairaigo-rules')).evaluate().isEmpty; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await t.pump();
    }
    for (final w in const [320.0, 900.0]) {
      t.view.physicalSize = Size(w, 2400);
      await t.tap(find.byKey(const ValueKey('gairaigo-rules')));
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
      expect(find.textContaining('촉음 ッ (작은'), findsOneWidget);
      await t.tap(find.textContaining('모음 삽입').first);
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
      expect(find.textContaining('예)'), findsOneWidget);
    }
  });
}
