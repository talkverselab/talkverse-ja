import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/jlpt_course_screen.dart';
import 'package:japanese_universe/screens/jlpt_patterns_screen.dart';
import 'package:japanese_universe/services/paywall_gate.dart';
import 'package:japanese_universe/services/usage_pages.dart';

/// 화면 목록(tool/usage_catalog.json)이 앱의 화면 ID·잠금 판단과 같은지 — 다르면 `python3 tool/usage_catalog.py` 를 다시 돌린다.
void main() {
  final cat = {
    for (final p in (jsonDecode(File('tool/usage_catalog.json').readAsStringSync())['pages'] as List)) p['page'] as String: p['tier'] as String,
  };
  String tier(int lv, bool free) => free ? 'free' : (PaywallGate.examLevel(lv) ? 'exam' : 'pro');
  List<Map<String, dynamic>> read(String p) => (jsonDecode(File(p).readAsStringSync()) as List).cast<Map<String, dynamic>>();

  test('화면 ID 는 규격 글자만', () {
    final re = RegExp(r'^[\w./:#-]{1,120}$');
    expect(cat.keys.where((k) => !re.hasMatch(k)), isEmpty);
    expect(cat.length, greaterThan(300));
  });

  test('급별 JLPT 장', () {
    var n = 0;
    for (final l in read('assets/data/jlpt/course.json')) {
      for (final ch in (l['chapters'] as List)) {
        n++;
        expect(cat[UsagePages.course(l['lv'] as int, ch['n'] as int)], tier(l['lv'] as int, courseChapterFree(ch['n'] as int)), reason: 'N${l['lv']} ${ch['n']}');
      }
    }
    expect(cat.keys.where((k) => k.startsWith('course/')).length, n);
  });

  test('누적 읽기 단원', () {
    for (final (set, confuse) in [(PatternSet.jlpt, false), (PatternSet.confuse, true)]) {
      final all = read(set.asset);
      final units = JlptPatterns.unitCount(all.length);
      for (var u = 1; u <= units; u++) {
        final b = ((u / set.perDay).ceil() * set.perDay).clamp(1, units); // 그날 묶음의 끝 단원
        expect(cat[UsagePages.pattern(u, confuse: confuse)], tier(PatternSet.unitLevel(all, b), set.unitFree(b)), reason: '${set.asset} $u');
      }
      expect(cat.keys.where((k) => k.startsWith(confuse ? 'conf/' : 'pat/')).length, units);
    }
  });

  test('회화·낱말', () {
    expect(cat[UsagePages.conv('r0_culture_a1')], 'free');
    expect(cat.entries.where((e) => e.key.startsWith('conv/r2_')).every((e) => e.value == 'pro'), isTrue);
    expect([for (final lv in [5, 4, 3, 2, 1]) cat[UsagePages.words(lv)]], ['free', 'free', 'free', 'exam', 'exam']);
  });

  test('열람률 요약', () {
    final j = {
      'tiers': [
        {'tier': 'free', 'total': 100, 'viewed': 50},
        {'tier': 'pro', 'total': 200, 'viewed': 20},
        {'tier': 'exam', 'total': 100, 'viewed': 10},
      ],
    };
    final a = UsageSummary.parse(j, exam: false), b = UsageSummary.parse(j, exam: true);
    expect([a.viewed, a.total, a.pct, a.blockPct], [20, 200, 10, RefundRule.blockPct]);
    expect([b.viewed, b.total, b.pct], [30, 300, 10]);
    expect(UsageSummary.parse({...j, 'rule': {'none_from': 0.25}}, exam: false).blockPct, 25);
  });
}
