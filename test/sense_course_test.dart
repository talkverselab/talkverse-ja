import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/sense_course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 과정 데이터가 커서(50KB 넘음) 에셋 읽기가 실제 비동기로 돈다 — pumpAndSettle 대신 실제 시간으로 기다린다.
Future<void> settle(WidgetTester t, Finder until) async {
  for (var i = 0; i < 100 && until.evaluate().isEmpty; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump();
  }
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final w in const [320.0, 900.0]) {
    testWidgets('언어감각 목록 폭 $w — L1 은 암기 1회 + 참고 한 줄, 넘침 없음', (t) async {
      t.view.physicalSize = Size(w, 6000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: SenseCourseScreen()));
      await settle(t, find.text('L1  조사 익히기'));
      expect(t.takeException(), isNull);
      expect(find.text('L1  조사 익히기'), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-5')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-ref')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L1-1')), findsNothing);
      expect(find.text('참고'), findsNWidgets(6));
      expect(find.text('0/10회 마침'), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L6-talk')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L6-4')), findsNothing);
      expect(find.byKey(const ValueKey('sense-L10-talk')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L10-ref')), findsOneWidget);
      expect(find.byKey(const ValueKey('sense-L3-ref')), findsOneWidget);
      expect(find.text('외국어 단어 익히기 메뉴 열기'), findsOneWidget);
    });
  }

  testWidgets('암기 회차 — 영상 자리·안내·색 표시가 글자에 안 남음, 마침 → 참고를 건너뛰고 L2 1회(서술어 대화)', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 0)));
    await settle(t, find.byKey(const ValueKey('sense-finish')));
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('memorize-video')), findsOneWidget);
    expect(find.textContaining('일부러 조사를 설명하지 않았어요'), findsOneWidget);
    expect(find.textContaining('{', findRichText: true), findsNothing);
    expect(plainMarked('雨{の|1}日'), '雨の日');
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 500));
    expect(await SenseCourse.done(), contains('L1-5'));
    expect(find.textContaining('アニメ', findRichText: true), findsWidgets);
  });

  testWidgets('참고 — 조사 전부, 닫기는 기록 안 함', (t) async {
    t.view.physicalSize = const Size(320, 12000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 1)));
    await settle(t, find.text('닫기'));
    expect(t.takeException(), isNull);
    expect(find.textContaining('て / で'), findsWidgets);
    expect(find.text('닫기'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pump(const Duration(milliseconds: 300));
    expect(await SenseCourse.done(), isNot(contains('L1-ref')));
  });
}
