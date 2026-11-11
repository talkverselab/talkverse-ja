import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/profile_screen.dart';
import 'package:japanese_universe/services/learner_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final w in const [320.0, 390.0, 900.0]) {
    testWidgets('설정 및 프로필 폭 $w — 넘침 없음·순서', (t) async {
      t.view.physicalSize = Size(w, 8000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await t.pump(const Duration(milliseconds: 200));
      expect(t.takeException(), isNull);
      // 초기화는 정보 아래(맨 끝), 학습 설정은 내려받기 위
      double dy(String s) => t.getTopLeft(find.text(s).first).dy;
      expect(dy('학습 설정') < dy('내려받기'), isTrue);
      expect(dy('내려받기') < dy('앱 설정'), isTrue);
      expect(dy('정보') < dy('학습 기록 초기화'), isTrue);
    });
  }

  testWidgets('성별 칩·후리가나 스위치·언어 목록', (t) async {
    t.view.physicalSize = const Size(390, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await LearnerPrefs.setGender('male');
    await LearnerPrefs.setFurigana(false);
    await t.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await t.pump(const Duration(milliseconds: 200));
    await t.tap(find.byKey(const ValueKey('gender-female')));
    await t.pump(const Duration(milliseconds: 100));
    expect(LearnerPrefs.isFemale, isTrue);
    await t.tap(find.byKey(const ValueKey('furigana-switch')));
    await t.pump(const Duration(milliseconds: 100));
    expect(LearnerPrefs.furigana.value, isTrue);
    await t.tap(find.text('언어 / Language'));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('lang-en')), findsOneWidget);
    expect(find.byKey(const ValueKey('lang-ko')), findsOneWidget);
    await LearnerPrefs.setGender('male');
    await LearnerPrefs.setFurigana(false);
  });
}
