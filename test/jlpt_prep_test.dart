import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/jlpt_prep_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> settle(WidgetTester t, Finder until) async {
  for (var i = 0; i < 100 && until.evaluate().isEmpty; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump();
  }
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('남은 날 — 시험 날 0, 전날 1, 지나면 음수', () {
    expect(JlptPrep.daysLeft('2026-12-06', DateTime(2026, 11, 28, 23)), 8);
    expect(JlptPrep.daysLeft('2026-12-06', DateTime(2026, 12, 6, 9)), 0);
    expect(JlptPrep.dLabel(8), 'D-8');
    expect(JlptPrep.dLabel(0), 'D-DAY');
    expect(JlptPrep.dLabel(-2), 'D+2');
  });

  test('계획 원고 — 날짜가 이어지고 할 일 id 가 겹치지 않으며 책 이름·쪽수가 없음', () {
    final raw = File('assets/data/jlpt/prep_n1.json').readAsStringSync();
    final d = json.decode(raw) as Map<String, dynamic>;
    final days = (d['days'] as List).cast<Map<String, dynamic>>();
    expect(days.first['date'], '2026-11-28');
    expect(days.last['date'], d['exam']['date']);
    for (var i = 1; i < days.length; i++) {
      expect(DateTime.parse(days[i]['date'] as String).difference(DateTime.parse(days[i - 1]['date'] as String)).inDays, 1);
    }
    final ids = [for (final x in days) for (final t in x['tasks'] as List) t['id']];
    expect(ids.toSet().length, ids.length);
    expect(RegExp(r'\d+쪽|p\.\s?\d').hasMatch(raw), false);
  });

  testWidgets('화면 — D-day·오늘 카드가 펼쳐지고 할 일을 누르면 마침 수가 오름, 넘침 없음', (t) async {
    t.view.physicalSize = const Size(320, 4000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: JlptPrepScreen(now: DateTime(2026, 11, 29, 10))));
    await settle(t, find.byKey(const ValueKey('jlpt-dday')));
    expect(t.takeException(), isNull);
    expect(find.text('D-7'), findsWidgets);
    expect(find.byKey(const ValueKey('jlpt-task-2026-11-29-book1')), findsOneWidget);
    expect(find.byKey(const ValueKey('jlpt-task-2026-11-28-book1')), findsNothing);
    expect(find.byKey(const ValueKey('jlpt-unit-6')), findsOneWidget);
    final before = (t.widget(find.byKey(const ValueKey('jlpt-progress'))) as Text).data!;
    expect(before.startsWith('0/'), true);
    await t.tap(find.byKey(const ValueKey('jlpt-task-2026-11-29-book1')));
    await t.pump();
    expect((t.widget(find.byKey(const ValueKey('jlpt-progress'))) as Text).data!.startsWith('1/'), true);
    expect(t.takeException(), isNull);
  });
}
