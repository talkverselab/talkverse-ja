import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/gairaigo_quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('틀린 표기 보기 — 실제 단어와 겹치지 않고 셋 이상', () {
    final m = gairaigoMisspellings('ベッド', {'ベッド', 'ベド'});
    expect(m, isNot(contains('ベッド')));
    expect(m, isNot(contains('ベド')));
    expect(m, contains('ベット'));
    expect(m.length, greaterThanOrEqualTo(3));
    expect(gairaigoMisspellings('バス', {'バス'}).length, greaterThanOrEqualTo(3));
  });

  testWidgets('퀴즈 복습 — 보기 4개, 10문제 뒤 결과, 폭 320 넘침 없음', (t) async {
    t.view.physicalSize = const Size(320, 700);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final words = [
      for (final w in const [
        ('バス', 'bus', '버스'), ('ベッド', 'bed', '침대'), ('テスト', 'test', '시험'), ('ゲーム', 'game', '게임'),
        ('コーヒー', 'coffee', '커피'), ('カップ', 'cup', '컵'), ('ドア', 'door', '문'), ('ホテル', 'hotel', '호텔'),
        ('パン', '', '빵'), ('アルバイト', '', '아르바이트'), ('ステーション', 'station', '역'), ('テレビ', 'television', '텔레비전'),
      ])
        GQWord(w.$1, w.$2, w.$3),
    ];
    await t.pumpWidget(MaterialApp(home: GairaigoQuizScreen(words: words, seed: 7)));
    await t.pumpAndSettle();
    for (var i = 0; i < kGairaigoQuizSize; i++) {
      expect(t.takeException(), isNull);
      expect(find.byKey(const ValueKey('gq-opt-3')), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('gq-opt-0')));
      await t.pump();
      await t.ensureVisible(find.byKey(const ValueKey('gq-next')));
      await t.tap(find.byKey(const ValueKey('gq-next')));
      await t.pump();
    }
    expect(t.takeException(), isNull);
    expect(find.byKey(const ValueKey('gq-again')), findsOneWidget);
  });
}
