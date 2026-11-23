import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/services/curriculum_plan.dart';
import 'package:japanese_universe/services/curriculum_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 커리큘럼 단계·편 목록은 서버 DB → 묶음 JSON → 회화 레벨 순(§12, 사용자 지시 11-23).
Map<String, dynamic> planJson(int rev, List<List<String>> stages, {List<String> n5 = const []}) => {
      'rev': rev,
      'stages': [
        for (var i = 0; i < stages.length; i++) {'n': i + 1, 'title': '${i + 1}단계', 'dialogueIds': stages[i], 'pick': [3, 5], 'pass': 75, 'daily': {'light': 1, 'normal': 2, 'focus': 4}}
      ],
      'prep': [
        if (n5.isNotEmpty) {'id': 'jlpt', 'title': 'JLPT 준비', 'levels': [{'id': 'N5', 'title': 'N5', 'dialogueIds': n5, 'wordSet': 'jlpt_n5', 'pass': 80}]}
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CurriculumPlanStore.instance.reset();
  });

  test('형식 읽기 — 단계 값·준비 급수·단어 급', () {
    final p = CurriculumPlan.fromJson(planJson(3, [['a'], ['b']], n5: ['a']));
    expect(p.rev, 3);
    expect(p.stages.map((s) => s.key), ['1', '2']);
    expect(p.stages.first.pick, [3, 5]);
    expect(p.stages.first.pass, 75);
    expect(p.stages.first.daily['focus'], 4);
    final n5 = p.byKey('jlpt:N5')!;
    expect(n5.jlptLevel, 5);
    expect(n5.pick, [3, 5]); // 없으면 첫 단계 값
  });

  test('앱에 없는 편은 건너뛰고, 편이 0개인 단계는 숨김 — 서버에서 빼면 사라지고 더하면 생김', () {
    final app = {'a', 'b', 'c'};
    var p = CurriculumPlan.fromJson(planJson(1, [['a', 'x'], ['y'], ['b'], [], ['c']]));
    expect(visibleLevels(p.stages, app.contains).map((s) => s.key), ['1', '3', '5']);
    p = CurriculumPlan.fromJson(planJson(2, [['a'], ['c']]));
    expect(visibleLevels(p.stages, app.contains).map((s) => s.key), ['1', '2']);
  });

  test('옛 회화 레벨 진도를 단계로', () {
    expect(migrateLevelKey('R0'), '1');
    expect(migrateLevelKey('R1'), '1');
    expect(migrateLevelKey('R3'), '3');
    expect(migrateLevelKey('jlpt:N5'), 'jlpt:N5');
    expect(CurriculumState.fromJson({'level': 'R2'}).level, '2');
  });

  test('JSON 이 없으면 회화 레벨로 단계(R0+R1 → 1)', () {
    final p = CurriculumPlan.fromRegions({'R0': ['a'], 'R1': ['b'], 'R2': ['c']});
    expect(p.stages.first.dialogueIds, ['a', 'b']);
    expect(p.stages[1].dialogueIds, ['c']);
    expect(p.stages.length, 5);
  });

  test('서버 rev 가 크면 받아서 쓰고, 다음 실행에도 남음 · 작거나 못 받으면 묶음', () async {
    final st = CurriculumPlanStore.instance;
    st.bundled = () async => json.encode(planJson(5, [['a']]));
    st.fetch = (_) async => json.encode(planJson(4, [['z']]));
    expect((await st.load())!.rev, 5);
    expect(await st.refresh(), isFalse);
    st.reset();
    st.fetch = (_) async => null;
    expect((await st.load())!.stages.first.dialogueIds, ['a']);
    expect(await st.refresh(), isFalse);
    st.reset();
    st.fetch = (_) async => json.encode(planJson(6, [['b'], ['c']]));
    await st.load();
    expect(await st.refresh(), isTrue);
    expect(st.plan!.stages.length, 2);
    st.reset(); // 다시 켠 앱
    expect((await st.load())!.rev, 6);
    st.bundled = null;
    st.fetch = null;
  });

  test('묶은 기본 JSON — 단계 4개·JLPT 급수, 편 id 가 모두 앱 편', () {
    final d = json.decode(File('assets/curriculum_ja.json').readAsStringSync()) as Map<String, dynamic>;
    final p = CurriculumPlan.fromJson(d);
    final app = {for (final f in Directory('assets/data/dialogues').listSync(recursive: true)) if (f.path.endsWith('.json')) f.uri.pathSegments.last.replaceAll('.json', '')};
    for (final l in p.all) {
      expect(l.dialogueIds.where((id) => !app.contains(id)), isEmpty, reason: l.key);
    }
    expect(p.prep.single.id, 'jlpt');
    expect(File('pubspec.yaml').readAsStringSync(), contains('assets/curriculum_ja.json'));
  });

  test('JLPT 단어 문제 — 뜻 4지선다', () {
    final ws = [for (var i = 0; i < 8; i++) ('語$i', 'ご$i', '뜻$i')];
    final qs = buildWordQuestions(ws, 3, seed: 1);
    expect(qs.length, 3);
    for (final q in qs) {
      expect(q.kind, 'word');
      expect(q.dialogueId, isEmpty);
      expect(q.choices.toSet().length, 4);
      expect(q.choices[q.answer], '뜻${q.prompt.substring(1)}');
    }
    expect(buildWordQuestions(ws.take(3).toList(), 3), isEmpty);
  });
}
