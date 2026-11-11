import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/embed_env.dart';
import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/prefs.dart';
import '../core/theme.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../widgets/selectable_ja_text.dart';

/// 언어감각 익히기 — 정규과정(2026-11-11 사용자 지시). L1 조사 익히기부터 L 단계 × 4회.
/// 회차 = 문법 짧은 설명(points.tip) → 감 익히는 문장(points.sentences). 데이터 `assets/data/grammar/sense_course.json`.
/// 내용은 간단하게 시작해 차차 늘린다 — 회차를 늘리려면 JSON 에 lessons 만 더하면 된다.
const _kDoneKey = 'sense_course_done';
const _kAsset = 'assets/data/grammar/sense_course.json';

class SenseCourse {
  static Map<String, dynamic>? _cache;
  static Future<Map<String, dynamic>> load() async =>
      _cache ??= json.decode(await rootBundle.loadString(assetPath(_kAsset))) as Map<String, dynamic>;

  static Future<Set<String>> done() async => ((await Prefs.getInstance()).getStringList(_kDoneKey) ?? const []).toSet();

  static Future<void> markDone(String id) async {
    final p = await Prefs.getInstance();
    final s = (p.getStringList(_kDoneKey) ?? <String>[]).toSet()..add(id);
    await p.setStringList(_kDoneKey, s.toList());
  }

  /// 모든 회차를 순서대로 (레벨, 회차) 쌍으로.
  static List<(Map<String, dynamic>, Map<String, dynamic>)> flat(Map<String, dynamic> d) => [
        for (final lv in (d['levels'] as List).cast<Map<String, dynamic>>())
          for (final ls in (lv['lessons'] as List).cast<Map<String, dynamic>>()) (lv, ls),
      ];
}

class SenseCourseScreen extends StatefulWidget {
  const SenseCourseScreen({super.key});

  @override
  State<SenseCourseScreen> createState() => _SenseCourseScreenState();
}

class _SenseCourseScreenState extends State<SenseCourseScreen> {
  Map<String, dynamic>? _data;
  Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await SenseCourse.load();
    final done = await SenseCourse.done();
    if (!mounted) return;
    setState(() {
      _data = d;
      _done = done;
    });
  }

  Future<void> _open(int index) async {
    await openFull(context, (_) => SenseLessonScreen(index: index));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('언어감각 익히기'))),
      body: d == null ? const Center(child: CircularProgressIndicator()) : _body(d),
    );
  }

  Widget _body(Map<String, dynamic> d) {
    final all = SenseCourse.flat(d);
    final next = all.indexWhere((e) => !_done.contains(e.$2['id']));
    final children = <Widget>[
      Text(tr('문법을 짧게 보고, 문장으로 감을 익혀요.'),
          style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
      const SizedBox(height: 4),
      Text(trf('{0}/{1}회 마침', [_done.length, all.length]),
          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ];
    var i = 0;
    for (final lv in (d['levels'] as List).cast<Map<String, dynamic>>()) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
        child: Text('${lv['id']}  ${lv['title']}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi)),
      ));
      var n = 1;
      for (final ls in (lv['lessons'] as List).cast<Map<String, dynamic>>()) {
        final idx = i;
        final isDone = _done.contains(ls['id']);
        final isNext = idx == next;
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: isNext ? AppColors.washiDeep : AppColors.washi,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isNext ? AppColors.ai : AppColors.line, width: isNext ? 1.4 : 1),
            ),
            child: InkWell(
              key: ValueKey('sense-${ls['id']}'),
              borderRadius: BorderRadius.circular(12),
              onTap: () => _open(idx),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(children: [
                  SizedBox(
                    width: 44,
                    child: Text(trf('{0}회', [n]),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ai)),
                  ),
                  Expanded(
                    child: Text(ls['title'] as String,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                  ),
                  if (isDone)
                    const Icon(Icons.check_circle, color: AppColors.matcha, size: 20)
                  else if (isNext)
                    Text(tr('다음'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ai)),
                ]),
              ),
            ),
          ),
        ));
        i++;
        n++;
      }
    }
    return ListView(padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)), children: children);
  }
}

/// 한 회차 — 문법 설명 → 문장. 아래 「마침 · 다음 회」 버튼.
class SenseLessonScreen extends StatefulWidget {
  final int index;
  const SenseLessonScreen({super.key, required this.index});

  @override
  State<SenseLessonScreen> createState() => _SenseLessonScreenState();
}

class _SenseLessonScreenState extends State<SenseLessonScreen> {
  List<(Map<String, dynamic>, Map<String, dynamic>)>? _all;

  @override
  void initState() {
    super.initState();
    SenseCourse.load().then((d) {
      if (mounted) setState(() => _all = SenseCourse.flat(d));
    });
  }

  Future<void> _finish() async {
    final all = _all!;
    await SenseCourse.markDone(all[widget.index].$2['id'] as String);
    if (!mounted) return;
    final nextIdx = widget.index + 1;
    if (nextIdx < all.length) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SenseLessonScreen(index: nextIdx)));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = _all;
    if (all == null) {
      return const Scaffold(backgroundColor: AppColors.washi, body: Center(child: CircularProgressIndicator()));
    }
    final (lv, ls) = all[widget.index];
    final lessons = (lv['lessons'] as List);
    final n = lessons.indexOf(ls) + 1;
    final points = (ls['points'] as List).cast<Map<String, dynamic>>();
    final last = widget.index + 1 >= all.length;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Text('${lv['id']} · ${trf('{0}회', [n])}  ${ls['title']}', overflow: TextOverflow.ellipsis),
        actions: const [KoReadingToggleAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [for (final p in points) _Point(point: p)],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset(context)),
        child: FilledButton(
          key: const ValueKey('sense-finish'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.ai, minimumSize: const Size.fromHeight(48)),
          onPressed: _finish,
          child: Text(last ? tr('마침') : tr('마침 · 다음 회')),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final Map<String, dynamic> point;
  const _Point({required this.point});

  @override
  Widget build(BuildContext context) {
    final sentences = (point['sentences'] as List).cast<Map<String, dynamic>>();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.washi,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
        boxShadow: kCardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(point['head'] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ai)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(8)),
          child: Text('💡 ${point['tip']}', style: const TextStyle(fontSize: 13, color: AppColors.sumi, height: 1.45)),
        ),
        const SizedBox(height: 6),
        for (final s in sentences)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SelectableJaText(
                    text: s['ja'] as String,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.35),
                  ),
                  if (s['kana'] != null && s['kana'] != s['ja'])
                    Text(s['kana'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.sumiLight)),
                  if (s['kana'] != null)
                    KoReadingText(s['kana'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.sumiLight)),
                  Text(s['ko'] as String,
                      style: const TextStyle(fontSize: 13, color: AppColors.ai, fontWeight: FontWeight.w600)),
                ]),
              ),
              IconButton(
                tooltip: tr('듣기'),
                icon: const Icon(Icons.volume_up, color: AppColors.beni, size: 22),
                onPressed: () => TtsService.instance.speak(s['ja'] as String),
              ),
            ]),
          ),
      ]),
    );
  }
}
