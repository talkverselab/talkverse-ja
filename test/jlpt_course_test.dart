// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/jlpt_course_screen.dart';
import 'package:japanese_universe/screens/jlpt_patterns_screen.dart';

void main() {
  sets();
  final all = (json.decode(File('assets/data/jlpt/course.json').readAsStringSync()) as List).cast<Map<String, dynamic>>();
  final pats = {for (final p in (json.decode(File('assets/data/jlpt/patterns.json').readAsStringSync()) as List).cast<Map<String, dynamic>>()) '${p['id']}': p};
  final kanji = RegExp('[一-鿿]');

  test('장 자료: 낱말이 겹치지 않고 문형 id 가 있다', () {
    for (final l in all) {
      final seen = <String>{};
      final ps = <String>{};
      for (final ch in JlptCourse.chapters(all, l['lv'] as int)) {
        for (final w in JlptCourse.words(ch)) {
          expect(seen.add(w.word), isTrue, reason: w.word);
          expect(w.gloss, isNotEmpty);
        }
        for (final id in ch['patterns'] as List) {
          expect(pats.containsKey(id), isTrue);
          expect(pats[id]!['lv'], l['lv']);
          expect(ps.add('$id'), isTrue);
        }
      }
    }
  });

  test('이야기·대화: 읽기에 한자 없음, 정답 번호가 범위 안, 화자 정의', () {
    for (final l in all) {
      for (final ch in JlptCourse.chapters(all, l['lv'] as int)) {
        for (final k in ['read', 'listen']) {
          final s = ch[k] as Map<String, dynamic>?;
          if (s == null) continue;
          for (final line in s['lines'] as List) {
            expect(kanji.hasMatch('${line['kana']}'), isFalse, reason: '${line['kana']}');
            expect('${line['kana']}'.contains('{'), isFalse);
            expect(plainKo('${line['ja']}').length <= 40, isTrue, reason: '${line['ja']}');
            if (k == 'listen') expect((s['who'] as Map).containsKey(line['who']), isTrue);
          }
          for (final q in s['q'] as List) {
            expect((q['opts'] as List).length, 4);
            expect(q['a'], inInclusiveRange(0, 3));
            expect(CourseQ.of(q as Map<String, dynamic>).opts.toSet().length, 4);
          }
        }
      }
    }
  });

  test('복습 문제: 1장은 이 장만, 2장부터 앞 장이 섞이고 보기가 겹치지 않는다', () {
    final chs = JlptCourse.chapters(all, 5);
    final q1 = JlptCourse.review(chs, 1, pats, rnd: Random(1));
    expect(q1.length, 12);
    final q2 = JlptCourse.review(chs, 2, pats, rnd: Random(1));
    expect(q2.length, 20);
    for (final q in [...q1, ...q2]) {
      expect(q.opts.length, 4);
      expect(q.opts.toSet().length, 4);
      expect(q.opts[q.a], isNotEmpty);
    }
    expect(q2.any((q) => q.q.contains('＿')), isTrue);
  });

  test('첫 장만 무료', () {
    expect(courseChapterFree(1), isTrue);
    expect(courseChapterFree(2), isFalse);
  });

  testWidgets('문제 화면: 틀리면 다시 나오고 다 맞히면 끝', (t) async {
    const qs = [CourseQ('犬', ['개', '고양이', '새', '말'], 0), CourseQ('ねこ', ['개', '고양이', '새', '말'], 1)];
    await t.pumpWidget(const MaterialApp(home: CourseQuizScreen(title: 't', questions: qs)));
    await t.tap(find.byKey(const ValueKey('opt-1')));
    await t.pump();
    expect(find.textContaining('틀렸어요'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('quiz-next')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('opt-1')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('quiz-next')));
    await t.pump();
    expect(find.text('3 / 3'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('opt-0')));
    await t.pump();
    await t.tap(find.byKey(const ValueKey('quiz-next')));
    await t.pump();
    expect(find.byKey(const ValueKey('quiz-close')), findsOneWidget);
  });
}

// 누적 읽기 자료 두 벌(문형·헷갈리는 말)의 꼴과 급별 묶음.
void sets() {
  final kanji = RegExp('[一-鿿]');
  List<Map<String, dynamic>> read(String p) => (json.decode(File(p).readAsStringSync()) as List).cast<Map<String, dynamic>>();

  test('문형은 급별 N5→N1 순, N3 까지가 29단원에서 끝난다', () {
    final d = read('assets/data/jlpt/patterns.json');
    for (var i = 1; i < d.length; i++) expect((d[i]['lv'] as int) <= (d[i - 1]['lv'] as int), isTrue);
    expect(PatternSet.unitLevel(d, 29), 3);
    expect(PatternSet.unitLevel(d, 30), 2);
    expect(PatternSet.unitLevel(d, 1), 5);
  });

  test('헷갈리는 말: 말 하나에 문장 하나, 짧은 문장, 읽기에 한자 없음', () {
    final d = read('assets/data/jlpt/confusables.json');
    expect(d.length, greaterThan(100));
    expect(d.map((e) => e['id']).toSet().length, d.length);
    for (final x in d) {
      final ss = x['s'] as List;
      expect(ss.length, '${x['head']}'.split('/').length, reason: '${x['head']}');
      for (final s in ss) {
        expect('${s['ja']}'.contains('{'), isTrue);
        expect(plainPoint('${s['ja']}').length <= 25, isTrue, reason: '${s['ja']}');
        expect(kanji.hasMatch('${s['kana']}'), isFalse);
      }
    }
    expect(PatternSet.confuse.unitFree(3), isTrue);
    expect(PatternSet.confuse.unitFree(4), isFalse);
  });
}
