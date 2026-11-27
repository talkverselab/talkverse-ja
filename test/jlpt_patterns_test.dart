import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/jlpt_patterns_screen.dart';
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

  test('포인트 표시 — 중괄호는 글자에서 빠지고 파란 밑줄 조각이 됨', () {
    expect(plainPoint('迷った{あげく}、帰った。'), '迷ったあげく、帰った。');
    final spans = pointSpans('迷った{あげく}、帰った。', const TextStyle());
    expect(spans.length, 3);
    expect((spans[1] as TextSpan).style!.decoration, TextDecoration.underline);
  });

  test('누적 읽기 순서 — 새 단원 먼저, 그다음 1단원부터', () {
    expect(JlptPatterns.session(95, newFrom: 3, upTo: 4), [3, 4, 1, 2]);
    expect(JlptPatterns.session(95, newFrom: 1, upTo: 2), [1, 2]);
    expect(JlptPatterns.session(95, newFrom: 9, upTo: 12), [9, 10, 1, 2, 3, 4, 5, 6, 7, 8]);
    expect(JlptPatterns.session(25).length, 3);
  });

  test('문형 원고 — 번호가 겹치지 않고, 문장마다 포인트·읽기·뜻이 있으며 읽기에 한자가 없음', () {
    final d = (json.decode(File('assets/data/jlpt/patterns.json').readAsStringSync()) as List).cast<Map<String, dynamic>>();
    expect(d.length, greaterThan(450));
    expect(d.map((e) => e['id']).toSet().length, d.length);
    expect(d.any((e) => e.containsKey('n')), false); // 교재 번호를 싣지 않는다
    final kanji = RegExp(r'[一-鿿]');
    for (final p in d) {
      expect((p['lv'] as int) >= 1 && (p['lv'] as int) <= 5, true, reason: '${p['id']}');
      expect('${p['head']}'.isNotEmpty && '${p['mean']}'.isNotEmpty && '${p['tip']}'.isNotEmpty, true, reason: '${p['id']}');
      final ss = (p['s'] as List).cast<Map<String, dynamic>>();
      expect(ss.isNotEmpty && ss.length <= 4, true, reason: '${p['id']}');
      for (final s in ss) {
        expect('${s['ja']}'.contains('{'), true, reason: '${p['id']}');
        expect(RegExp(r'\{').allMatches('${s['ja']}').length, RegExp(r'\}').allMatches('${s['ja']}').length, reason: '${p['id']}');
        expect(kanji.hasMatch('${s['kana']}'), false, reason: '${p['id']} ${s['kana']}');
        expect('${s['ko']}'.isNotEmpty, true, reason: '${p['id']}');
      }
    }
  });

  testWidgets('날짜 목록 → 그날 누적 읽기: 새 단원 먼저, 읽었어요 누르면 횟수가 오름, 넘침 없음', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: JlptPatternDaysScreen(now: DateTime(2026, 11, 28))));
    await settle(t, find.byKey(const ValueKey('pat-day-1')));
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('pat-day-2')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('pat-day-3')), matching: find.byIcon(Icons.lock_outline)), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('pat-day-4')), matching: find.byIcon(Icons.lock_outline)), findsOneWidget);
    expect(patternUnitFree(6), true);
    expect(patternUnitFree(7), false);

    await t.pumpWidget(const MaterialApp(home: JlptPatternsScreen(newFrom: 3, upTo: 4)));
    await settle(t, find.byKey(const ValueKey('pat-unit-3')));
    expect(t.takeException(), isNull);
    expect(find.text('오늘 새로'), findsWidgets);
    expect(find.text('0번 읽음'), findsWidgets);
    await t.scrollUntilVisible(find.byKey(const ValueKey('pat-read-3')), 600);
    await t.ensureVisible(find.byKey(const ValueKey('pat-read-3')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('pat-read-3')));
    await t.pump();
    await t.scrollUntilVisible(find.byKey(const ValueKey('pat-reads-3')), -600);
    expect((t.widget(find.byKey(const ValueKey('pat-reads-3'))) as Text).data, '1번 읽음');
    expect(t.takeException(), isNull);
  });
}
