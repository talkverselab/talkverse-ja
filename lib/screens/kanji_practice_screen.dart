import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/embed_env.dart';
import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/prefs.dart';
import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../widgets/selectable_ja_text.dart' show showKanjiSheet;

/// 한자 연습(사용자 지시 2026-11-11 「패밀리가 많은 한자부터 가르치게」).
/// 소리 부품이 같은 글자가 3자 이상인 패밀리 94개를 큰 가족부터, 하루 3패밀리씩(3달·주 3일 기준 ≈ 32일·11주).
/// 하루 = 패밀리 보기(가족 글자는 회화 빈도순) → 「이 글자의 패밀리는?」 문제 → 마침 기록(Prefs `kanji_practice_done`).
const int kFamiliesPerDay = 3;
const int kMinMembers = 3;
const _kDone = 'kanji_practice_done';

class KFamily {
  final String root;
  final String on;
  final String ko;
  final List<String> members; // 소리 부품 글자 제외, 회화 빈도순
  const KFamily(this.root, this.on, this.ko, this.members);
}

class KanjiPractice {
  static List<List<KFamily>>? _days;

  static Future<List<List<KFamily>>> days() async {
    if (_days != null) return _days!;
    await KanjiIndexService.instance.ensureLoaded();
    final j = json.decode(await rootBundle.loadString(assetPath('assets/data/kanji/phonetic_ja.json'))) as Map<String, dynamic>;
    final roots = (j['roots'] as Map).cast<String, dynamic>();
    final by = <String, List<String>>{};
    ((j['chars'] as Map).cast<String, dynamic>()).forEach((c, v) => (by[(v as Map)['phonetic'] as String] ??= []).add(c));
    int rank(String c) => KanjiIndexService.instance.lookup(c)?.rank ?? 9999;
    final fams = <KFamily>[];
    roots.forEach((r, v) {
      final m = [...?by[r]]..sort((a, b) => rank(a).compareTo(rank(b)));
      if (m.length < kMinMembers) return;
      fams.add(KFamily(r, (v as Map)['on'] as String? ?? '', v['ko'] as String? ?? '', m));
    });
    // 큰 가족부터, 같으면 회화에서 많이 쓰는 글자가 있는 가족부터
    fams.sort((a, b) {
      final c = b.members.length.compareTo(a.members.length);
      return c != 0 ? c : rank(a.members.first).compareTo(rank(b.members.first));
    });
    return _days = [for (var i = 0; i < fams.length; i += kFamiliesPerDay) fams.sublist(i, min(i + kFamiliesPerDay, fams.length))];
  }

  static Future<Set<String>> done() async => ((await Prefs.getInstance()).getStringList(_kDone) ?? const []).toSet();
  static Future<void> markDone(int day) async {
    final p = await Prefs.getInstance();
    await p.setStringList(_kDone, {...?p.getStringList(_kDone), '$day'}.toList());
  }
}

String _readingOf(String c) {
  final e = KanjiIndexService.instance.lookup(c);
  if (e == null) return '';
  final on = e.readings.where((r) => r.kind == '음독').map((r) => r.reading);
  return (on.isNotEmpty ? on.first : (e.readings.isNotEmpty ? e.readings.first.reading : ''));
}

String _meaningOf(String c) {
  final e = KanjiIndexService.instance.lookup(c);
  return e == null || e.meanings.isEmpty ? '' : e.meanings.first;
}

class KanjiPracticeScreen extends StatefulWidget {
  const KanjiPracticeScreen({super.key});
  @override
  State<KanjiPracticeScreen> createState() => _KanjiPracticeScreenState();
}

class _KanjiPracticeScreenState extends State<KanjiPracticeScreen> {
  List<List<KFamily>>? _days;
  Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await KanjiPractice.days();
    final done = await KanjiPractice.done();
    if (mounted) {
      setState(() {
        _days = d;
        _done = done;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('한자 연습'))),
      body: days == null ? const Center(child: CircularProgressIndicator()) : _body(days),
    );
  }

  Widget _body(List<List<KFamily>> days) {
    final fams = days.fold<int>(0, (a, d) => a + d.length);
    final chars = days.expand((d) => d).fold<int>(0, (a, f) => a + f.members.length + 1);
    final next = List.generate(days.length, (i) => i + 1).firstWhere((n) => !_done.contains('$n'), orElse: () => -1);
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
      children: [
        Text(tr('패밀리가 큰 한자부터 — 소리 부품 하나로 여러 글자를 한 번에'), style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
        const SizedBox(height: 4),
        Text(trf('{0}패밀리 · {1}자 · 하루 {2}패밀리 · {3}일 (주 3일이면 약 {4}주)', [fams, chars, kFamiliesPerDay, days.length, (days.length / 3).ceil()]),
            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        Text(trf('{0}/{1}일 마침', [_done.length, days.length]), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 10),
        for (var i = 0; i < days.length; i++) _dayRow(i + 1, days[i], next == i + 1),
      ],
    );
  }

  Widget _dayRow(int n, List<KFamily> fams, bool isNext) {
    final isDone = _done.contains('$n');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isNext ? AppColors.washiDeep : AppColors.washi,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isNext ? AppColors.ai : AppColors.line, width: isNext ? 1.4 : 1)),
        child: InkWell(
          key: ValueKey('kp-day-$n'),
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await openFull(context, (_) => KanjiPracticeDayScreen(day: n, families: fams));
            _load();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(children: [
              SizedBox(width: 56, child: Text(trf('{0}일차', [n]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ai))),
              Expanded(
                child: Text(fams.map((f) => f.root).join(' · '), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.sumi)),
              ),
              Text(trf('{0}자', [fams.fold<int>(0, (a, f) => a + f.members.length + 1)]), style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
              const SizedBox(width: 8),
              if (isDone)
                const Icon(Icons.check_circle, color: AppColors.matcha, size: 20)
              else if (isNext)
                Text(tr('다음'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ai)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// 하루 — 패밀리 보기 → 문제.
class KanjiPracticeDayScreen extends StatefulWidget {
  final int day;
  final List<KFamily> families;
  const KanjiPracticeDayScreen({super.key, required this.day, required this.families});
  @override
  State<KanjiPracticeDayScreen> createState() => _KanjiPracticeDayScreenState();
}

class _KanjiPracticeDayScreenState extends State<KanjiPracticeDayScreen> {
  bool _quiz = false;
  late List<(String, KFamily)> _qs;
  int _i = 0;
  String? _picked;
  int _right = 0;

  void _startQuiz() {
    _qs = [for (final f in widget.families) for (final m in f.members) (m, f)]..shuffle();
    setState(() {
      _quiz = true;
      _i = 0;
      _picked = null;
      _right = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final finished = _quiz && _i >= _qs.length;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text('${trf('{0}일차', [widget.day])}  ${widget.families.map((f) => f.root).join(' · ')}')),
      body: !_quiz
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [for (final f in widget.families) _FamilyCard(f)],
            )
          : finished
              ? _summary()
              : _question(),
      bottomNavigationBar: _quiz && !finished
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset(context)),
              child: FilledButton(
                key: const ValueKey('kp-action'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.ai, minimumSize: const Size.fromHeight(48)),
                onPressed: finished
                    ? () async {
                        await KanjiPractice.markDone(widget.day);
                        if (context.mounted) Navigator.of(context).maybePop();
                      }
                    : _startQuiz,
                child: Text(finished ? tr('마침') : tr('문제 풀기')),
              ),
            ),
    );
  }

  Widget _summary() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎉', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(trf('{0}문제 중 {1}개 맞힘', [_qs.length, _right]), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _startQuiz, child: Text(tr('한 번 더'))),
        ]),
      );

  Widget _question() {
    final (c, fam) = _qs[_i];
    final options = widget.families.map((f) => f.root).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset(context)),
      child: Column(children: [
        Text('${_i + 1} / ${_qs.length}', style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
        const SizedBox(height: 16),
        Text(c, style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w900, color: AppColors.sumi)),
        if (_picked != null) Text('${_readingOf(c)}  ${_meaningOf(c)}', style: const TextStyle(fontSize: 15, color: AppColors.ai, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(tr('이 글자의 패밀리(소리 부품)는?'), style: const TextStyle(fontSize: 14, color: AppColors.sumi)),
        const SizedBox(height: 14),
        Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
          for (final o in options)
            SizedBox(
              width: 88,
              height: 72,
              child: OutlinedButton(
                key: ValueKey('kp-opt-$o'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _picked == null ? null : (o == fam.root ? const Color(0x3336A35B) : (o == _picked ? const Color(0x33D83A3A) : null)),
                  side: BorderSide(color: _picked != null && o == fam.root ? AppColors.matcha : AppColors.line, width: 1.4),
                ),
                onPressed: _picked != null
                    ? null
                    : () {
                        TtsService.instance.speak(_readingOf(c));
                        setState(() {
                          _picked = o;
                          if (o == fam.root) _right++;
                        });
                      },
                child: Text(o, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.sumi)),
              ),
            ),
        ]),
        const Spacer(),
        if (_picked != null)
          FilledButton(
            key: const ValueKey('kp-next'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.sumi, minimumSize: const Size.fromHeight(48)),
            onPressed: () => setState(() {
              _i++;
              _picked = null;
            }),
            child: Text(tr('다음 →')),
          ),
      ]),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final KFamily f;
  const _FamilyCard(this.f);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.washi, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line), boxShadow: kCardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _Tile(f.root, big: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trf('「{0}」 패밀리 · {1}자', [f.root, f.members.length + 1]), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.sumi)),
                Text(trf('소리 {0} · 한국음 {1}', [f.on, f.ko]), style: const TextStyle(fontSize: 12.5, color: AppColors.ai, fontWeight: FontWeight.w700)),
                Text(tr('이 부품이 들어간 글자는 소리가 비슷해요'), style: const TextStyle(fontSize: 11.5, color: AppColors.sumiLight)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final m in f.members) _Tile(m)]),
        ]),
      );
}

class _Tile extends StatelessWidget {
  final String c;
  final bool big;
  const _Tile(this.c, {this.big = false});
  @override
  Widget build(BuildContext context) {
    final r = _readingOf(c), mean = _meaningOf(c);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => showKanjiSheet(context, char: c, entry: KanjiIndexService.instance.lookup(c)),
      child: Container(
        width: big ? 64 : 76,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
            color: big ? AppColors.washiDeep : AppColors.washi, borderRadius: BorderRadius.circular(10), border: Border.all(color: big ? AppColors.kin : AppColors.line, width: big ? 1.4 : 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(c, style: TextStyle(fontSize: big ? 34 : 28, fontWeight: FontWeight.w900, color: AppColors.sumi)),
          if (!big && r.isNotEmpty) Text(r, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.ai, fontWeight: FontWeight.w700)),
          if (!big && mean.isNotEmpty) Text(mean, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
        ]),
      ),
    );
  }
}
