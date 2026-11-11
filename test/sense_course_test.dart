import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/sense_course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final w in const [320.0, 900.0]) {
    testWidgets('언어감각 목록 폭 $w — L1 조사부터, 넘침 없음', (t) async {
      t.view.physicalSize = Size(w, 6000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: SenseCourseScreen()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text('L1  조사 익히기'), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L6-4')), findsOneWidget);
    });
  }

  testWidgets('1회 열고 마침 → 2회로, 기록 저장', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 0)));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.textContaining('は'), findsWidgets);
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pumpAndSettle();
    expect(await SenseCourse.done(), contains('L1-1'));
    expect(find.textContaining('L1-2'), findsNothing);
    expect(find.textContaining('を · に'), findsWidgets);
  });

  testWidgets('L1 5회 암기 — 영상 자리·안내·5문장, 조사 색 표시가 글자에 안 남음', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 4)));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('memorize-video')), findsOneWidget);
    expect(find.textContaining('일부러 조사를 설명하지 않았어요'), findsOneWidget);
    expect(find.textContaining('{', findRichText: true), findsNothing);
    expect(plainMarked('雨{の|1}日'), '雨の日');
  });
}
