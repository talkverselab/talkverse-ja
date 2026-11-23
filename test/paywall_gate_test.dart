import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/services/curriculum_plan.dart';
import 'package:japanese_universe/services/entitlement.dart';
import 'package:japanese_universe/services/paywall_gate.dart';
import 'package:japanese_universe/services/purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 이용권 잠금 경계 — 1단계 열림 · 2단계 잠김 · 이용권 있으면 열림(PAYWALL_SPEC §5).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CurriculumPlan plan;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    plan = CurriculumPlan.fromJson(json.decode(File('assets/curriculum_ja.json').readAsStringSync()) as Map);
    Purchase.owned.value = const {};
  });

  test('묶은 JSON rev 2 — 1단계만 무료, JLPT 준비는 유료, 언어감각 무료 1급', () {
    expect(plan.rev, greaterThanOrEqualTo(2));
    expect(plan.stages.first.free, isTrue);
    expect(plan.stages.skip(1).every((s) => !s.free), isTrue);
    expect(plan.prep.expand((p) => p.levels).every((l) => !l.free), isTrue);
    expect(plan.freeSenseLevels, 1);
  });

  test('free 값이 없으면 1단계만 무료', () {
    final p = CurriculumPlan.fromJson({
      'stages': [
        {'n': 1, 'dialogueIds': []},
        {'n': 2, 'dialogueIds': []},
      ],
      'prep': [
        {'id': 'jlpt', 'levels': [{'id': 'N5', 'dialogueIds': []}]}
      ],
    });
    expect(p.stages.map((s) => s.free), [true, false]);
    expect(p.byKey('jlpt:N5')!.free, isFalse);
  });

  test('회화 편 — R0·R1 과 무료 단계 편은 열림, R2 이상은 잠김', () {
    expect(isDialogueFree('r0_x', 'R0', plan), isTrue);
    expect(isDialogueFree('r1_x', 'R1', null), isTrue);
    final r2 = plan.stages[1].dialogueIds.first;
    expect(isDialogueFree(r2, 'R2', plan), isFalse);
    expect(isDialogueFree(r2, 'R2', null), isFalse);
  });

  test('이용권 — 그 언어 상품이나 종합이 유효하면 열림, 다른 언어·끝난 구독은 아님', () async {
    await Entitlement.set(false);
    expect(PaywallGate.premium, isFalse);
    final later = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
    final past = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    Purchase.owned.value = {'lang_zh_1y': later};
    expect(PaywallGate.premium, isFalse);
    Purchase.owned.value = {'lang_ja_1m': past};
    expect(PaywallGate.premium, isFalse);
    Purchase.owned.value = {'lang_ja_1m': later};
    expect(PaywallGate.premium, isTrue);
    Purchase.owned.value = {'all_life': 0};
    expect(PaywallGate.premium, isTrue);
  });

  test('언어감각 — 1급 무료, 2급부터 잠김', () {
    expect(PaywallGate.senseLevelFree(0), isTrue);
    expect(PaywallGate.senseLevelFree(1), isFalse);
  });
}
