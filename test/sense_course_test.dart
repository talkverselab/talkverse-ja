import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/sense_course_screen.dart';
import 'package:japanese_universe/services/purchase.dart';
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
      expect(find.text('0/17회 마침'), findsOneWidget);
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
    Purchase.owned.value = {'all_life': 0}; // L2 는 이용권(2급부터) — 이 테스트는 산 사람 기준
    addTearDown(() => Purchase.owned.value = const {});
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 7)));
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
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 8)));
    await settle(t, find.text('닫기'));
    expect(t.takeException(), isNull);
    expect(find.textContaining('て / で'), findsWidgets);
    expect(find.text('닫기'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('sense-finish')));
    await t.pump(const Duration(milliseconds: 300));
    expect(await SenseCourse.done(), isNot(contains('L1-ref')));
  });

  test('빈 스텝 숨김 — 내용 있는 회차가 없는 급은 안 보이고, 내용이 생기면 나타남(서버 파일 그대로 읽음)', () {
    Map<String, dynamic> lv(String id, List<Map<String, dynamic>> ls) => {'id': id, 'title': id, 'lessons': ls};
    final d = {
      'levels': [
        lv('L1', [{'id': 'L1-a', 'sentences': ['x']}, {'id': 'L1-empty', 'sentences': []}]),
        lv('L2', [{'id': 'L2-a', 'sentences': []}]),
        lv('L3', []),
        lv('L4', [{'id': 'L4-ref', 'points': [{}]}]),
        lv('L5', [{'id': 'L5-open', 'open': 'gairaigo'}]),
      ]
    };
    expect(SenseCourse.levels(d).map((l) => l['id']), ['L1', 'L4', 'L5']);
    expect(SenseCourse.flat(d).map((e) => e.$2['id']), ['L1-a', 'L4-ref', 'L5-open']);
    (d['levels']![1]['lessons'] as List)[0]['sentences'] = ['새 문장'];
    expect(SenseCourse.levels(d).map((l) => l['id']), ['L1', 'L2', 'L4', 'L5']);
  });

  test('묶음 원고 — 영상 급 L0 + 스텝 1~10 이 모두 데이터에 있고 모두 내용 있음', () async {
    final raw = File('assets/data/grammar/sense_course.json').readAsStringSync();
    final d = json.decode(raw) as Map<String, dynamic>;
    expect((d['levels'] as List).map((l) => l['id']), [for (var i = 0; i <= 10; i++) 'L$i']);
    expect(SenseCourse.levels(d).length, 11);
    expect(File('tools/script_publish.py').readAsStringSync(), contains('grammar/sense_course.json'));
  });

  testWidgets('영상 회차 — 영상과 안내만, 이용권 없이 열리고 넘침 없음', (t) async {
    t.view.physicalSize = const Size(320, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseLessonScreen(index: 0)));
    await settle(t, find.byKey(const ValueKey('sense-finish')));
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('memorize-video')), findsOneWidget);
    expect(find.textContaining('설명은 영어로 나와요'), findsOneWidget);
  });

  test('영상만 있는 회차도 내용 — 영상 급(free)은 늘 열리고 무료 급 수를 쓰지 않음', () {
    final d = <String, dynamic>{
      'levels': [
        {'id': 'L0', 'title': '영상', 'free': true, 'lessons': [{'id': 'L0-ep0', 'kind': 'memorize', 'video': 'https://x/v.mp4', 'sentences': []}]},
        {'id': 'L1', 'title': 'a', 'lessons': [{'id': 'L1-a', 'sentences': ['x']}]},
        {'id': 'L2', 'title': 'b', 'lessons': [{'id': 'L2-a', 'sentences': ['x']}, {'id': 'L2-v', 'video': '', 'sentences': []}]},
      ]
    };
    expect(SenseCourse.flat(d).map((e) => e.$2['id']), ['L0-ep0', 'L1-a', 'L2-a']);
    expect(SenseCourse.lockIndex(d, 'L0'), -1);
    expect(SenseCourse.lockIndex(d, 'L1'), 0);
    expect(SenseCourse.lockIndex(d, 'L2'), 1);
  });

  test('묶음 원고 — 영상 급 7편 주소는 서버 영상 폴더', () {
    final d = json.decode(File('assets/data/grammar/sense_course.json').readAsStringSync()) as Map<String, dynamic>;
    final l0 = (d['levels'] as List).first as Map<String, dynamic>;
    expect(l0['free'], true);
    final ls = (l0['lessons'] as List).cast<Map<String, dynamic>>();
    expect(ls.length, 7);
    for (final l in ls) {
      expect(l['video'], startsWith('https://auth.talkverse.uk/art/video/ja/sense/MD1-'));
    }
    expect(SenseCourse.lockIndex(d, 'L1'), 0);
    expect(SenseCourse.lockIndex(d, 'L2'), 1);
  });

  testWidgets('언어감각 목록 — 이용권 없으면 2급부터 자물쇠', (t) async {
    t.view.physicalSize = const Size(400, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: SenseCourseScreen()));
    await settle(t, find.text('L1  조사 익히기'));
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
    expect(find.descendant(of: find.byKey(const ValueKey('sense-L1-5')), matching: find.byIcon(Icons.lock_outline)), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('sense-L2-talk')), matching: find.byIcon(Icons.lock_outline)), findsOneWidget);
  });
}
