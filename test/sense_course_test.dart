import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/sense_course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final w in const [320.0, 900.0]) {
    testWidgets('언어감각 목록 폭 $w — L1 은 암기 1회 + 참고 한 줄, 넘침 없음', (t) async {
      t.view.physicalSize = Size(w, 6000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: SenseCourseScreen()));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.text('L1  조사 익히기'), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-5')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-ref')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-1')), findsNothing);
      expect(find.text('참고'), findsOneWidget);
      expect(find.text('0/21회 마침'), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L6-4')), findsOneWidget);
    });
  }

  testWidgets('암기 회차 — 영상 자리·안내·색 표시가 글자에 안 남음, 마침 → 참고를 건너뛰고 L2 1회', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 0)));
    await t.pump(const Duration(milliseconds: 300));
    await t.pump(const Duration(milliseconds: 300));
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('memorize-video')), findsOneWidget);
    expect(find.textContaining('일부러 조사를 설명하지 않았어요'), findsOneWidget);
    expect(find.textContaining('{', findRichText: true), findsNothing);
    expect(plainMarked('雨{の|1}日'), '雨の日');
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 500));
    expect(await SenseCourse.done(), contains('L1-5'));
    expect(find.textContaining('AはBです'), findsWidgets);
  });

  testWidgets('참고 — 조사 전부, 닫기는 기록 안 함', (t) async {
    t.view.physicalSize = const Size(320, 12000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 1)));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.textContaining('て / で'), findsWidgets);
    expect(find.text('닫기'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pump(const Duration(milliseconds: 300));
    expect(await SenseCourse.done(), isNot(contains('L1-ref')));
  });
}
