// ignore_for_file: curly_braces_in_flow_control_structures
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
import '../services/paywall_gate.dart';
import '../services/tts_service.dart';
import 'jlpt_patterns_screen.dart';
import 'word_unit_flash_screen.dart';

/// 급별 JLPT 과정(사용자 지시 2026-11-28) — N5~N1 을 장으로 나눠 낱말 → 문형 → 읽기 이야기 → 듣기 대화 → 복습 문제.
/// 낱말은 쉬운 한자(자주 쓰는 한자·같은 소리 부품 패밀리) 순의 한자 묶음, 읽기·듣기는 시험 지문이 아니라 이야기·일상 대화(자체 작성).
/// 복습 문제는 이 장과 앞 장의 낱말·문형에서 앱이 만든다(앞 장을 계속 다시 만나게).
/// 데이터 `assets/data/jlpt/course.json`(만들기 `tools/jlpt_course_build.py`):
/// [{lv, chapters:[{n, title?, words:[{k,m,f,w:[[표기,읽기,뜻]]}], patterns:[문형 id], read?, listen?}]}]
const _kAsset = 'assets/data/jlpt/course.json';
const _kDoneKey = 'jlpt_course_done';
const _kSet = 20;

/// 급마다 첫 장은 무료, 나머지는 이용권.
bool courseChapterFree(int n) => n <= 1;

class JlptCourse {
  static List<Map<String, dynamic>>? _cache;
  static Future<List<Map<String, dynamic>>> load() async {
    if (_cache != null) return _cache!;
    final b = await rootBundle.load(assetPath(_kAsset));
    return _cache = (json.decode(utf8.decode(b.buffer.asUint8List(b.offsetInBytes, b.lengthInBytes))) as List).cast<Map<String, dynamic>>();
  }

  static List<Map<String, dynamic>> chapters(List<Map<String, dynamic>> all, int lv) {
    for (final l in all) if (l['lv'] == lv) return (l['chapters'] as List).cast<Map<String, dynamic>>();
    return const [];
  }

  static List<StudyWord> words(Map<String, dynamic> ch) => [
        for (final g in (ch['words'] as List? ?? const []))
          for (final w in (g['w'] as List)) StudyWord(word: '${w[0]}', kana: '${w[1]}', gloss: '${w[2]}'),
      ];

  /// 복습 문제: 이 장 [fresh]개 + 앞 장 [old]개. 낱말 뜻 고르기와 문형 빈칸.
  static List<CourseQ> review(List<Map<String, dynamic>> chs, int n, Map<String, Map<String, dynamic>> pats, {int fresh = 12, int old = 8, Random? rnd}) {
    final r = rnd ?? Random();
    final cur = chs.firstWhere((c) => c['n'] == n);
    final before = [for (final c in chs) if ((c['n'] as int) < n) c];
    final pool = [for (final c in chs) if ((c['n'] as int) <= n) ...words(c)];
    final points = <String>{
      for (final c in chs)
        for (final id in (c['patterns'] as List))
          for (final s in ((pats[id]?['s'] as List?) ?? const [])) ...kPointMark.allMatches('${s['ja']}').map((m) => m.group(1)!),
    }.toList();
    List<CourseQ> from(List<Map<String, dynamic>> src, int count) {
      final ws = [for (final c in src) ...words(c)]..shuffle(r);
      final ss = [
        for (final c in src)
          for (final id in (c['patterns'] as List))
            for (final s in ((pats[id]?['s'] as List?) ?? const []))
              if (kPointMark.allMatches('${s['ja']}').length == 1) (pats[id]!, s as Map<String, dynamic>),
      ]..shuffle(r);
      final out = <CourseQ>[];
      final nw = min(ws.length, (count * 0.6).ceil());
      for (final w in ws.take(nw)) {
        final wrong = ({for (final o in pool) if (o.gloss != w.gloss) o.gloss}.toList()..shuffle(r)).take(3);
        if (wrong.length < 3) continue;
        out.add(CourseQ.shuffled(w.word, [w.gloss, ...wrong], sub: w.kana, why: '${w.word}${w.kana.isEmpty ? '' : '(${w.kana})'} = ${w.gloss}', speak: w.speakText, rnd: r));
      }
      for (final (p, s) in ss.take(count - out.length)) {
        final ans = kPointMark.firstMatch('${s['ja']}')!.group(1)!;
        final wrong = ([for (final o in points) if (o != ans) o]..shuffle(r)).take(3);
        if (wrong.length < 3) continue;
        out.add(CourseQ.shuffled('${s['ja']}'.replaceAll(kPointMark, '＿＿＿'), [ans, ...wrong], sub: plainKo('${s['ko']}'), why: '${p['head']} — ${p['mean']}', speak: plainPoint('${s['ja']}'), rnd: r));
      }
      return out;
    }

    return [...from([cur], fresh), if (before.isNotEmpty) ...from(before, old)];
  }
}

final kPointMark = RegExp(r'\{([^}]*)\}');
String plainKo(String s) => s.replaceAllMapped(kPointMark, (m) => m.group(1)!);

class CourseQ {
  final String q, sub, why, speak;
  final List<String> opts;
  final int a;
  const CourseQ(this.q, this.opts, this.a, {this.sub = '', this.why = '', this.speak = ''});
  factory CourseQ.shuffled(String q, List<String> opts, {String sub = '', String why = '', String speak = '', Random? rnd}) {
    final right = opts.first;
    final o = [...opts]..shuffle(rnd);
    return CourseQ(q, o, o.indexOf(right), sub: sub, why: why, speak: speak);
  }
  factory CourseQ.of(Map<String, dynamic> m, {Random? rnd}) =>
      CourseQ.shuffled('${m['q']}', [(m['opts'] as List)[m['a'] as int] as String, for (var i = 0; i < (m['opts'] as List).length; i++) if (i != m['a']) '${m['opts'][i]}'], why: '${m['why'] ?? ''}', rnd: rnd);
}

class _Done {
  static Set<String> v = {};
  static Future<void> load() async => v = ((await Prefs.getInstance()).getStringList(_kDoneKey) ?? const []).toSet();
  static Future<void> toggle(String k, [bool? on]) async {
    (on ?? !v.contains(k)) ? v.add(k) : v.remove(k);
    await (await Prefs.getInstance()).setStringList(_kDoneKey, v.toList());
  }
}

const _kParts = ['w', 'g', 'r', 'l', 'q'];

/// 급 고르기 + 장 목록.
class JlptCourseScreen extends StatefulWidget {
  const JlptCourseScreen({super.key});
  @override
  State<JlptCourseScreen> createState() => _JlptCourseScreenState();
}

class _JlptCourseScreenState extends State<JlptCourseScreen> {
  List<Map<String, dynamic>>? _all;
  Map<String, Map<String, dynamic>> _pats = {};
  int _lv = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await JlptCourse.load();
    final ps = await JlptPatterns.load();
    await _Done.load();
    if (!mounted) return;
    setState(() {
      _all = all;
      _pats = {for (final p in ps) '${p['id']}': p};
    });
  }

  Future<void> _open(List<Map<String, dynamic>> chs, Map<String, dynamic> ch) async {
    if (!await PaywallGate.passLevel(context, _lv, courseChapterFree(ch['n'] as int)) || !mounted) return;
    await openPane(context, (_) => JlptChapterScreen(level: _lv, chapter: ch, chapters: chs, patterns: _pats));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final all = _all;
    final chs = all == null ? const <Map<String, dynamic>>[] : JlptCourse.chapters(all, _lv);
    return Scaffold(
      backgroundColor: AppColors.washiDeep,
      appBar: AppBar(title: Text(tr('급별 JLPT'))),
      body: all == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
              children: [
                Row(children: [
                  for (final lv in const [5, 4, 3, 2, 1])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: ValueKey('course-lv-$lv'),
                        label: Text('N$lv', style: const TextStyle(fontWeight: FontWeight.w800)),
                        selected: _lv == lv,
                        onSelected: (_) => setState(() => _lv = lv),
                      ),
                    ),
                ]),
                const SizedBox(height: 6),
                Text(tr('한 장 = 낱말 → 문형 → 이야기 읽기 → 대화 듣기 → 복습 문제. 앞 장은 복습 문제에서 계속 다시 나와요.'), style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.45)),
                const SizedBox(height: 10),
                if (chs.isEmpty)
                  Padding(padding: const EdgeInsets.all(28), child: Center(child: Text(trf('N{0} 은 준비 중이에요', [_lv]), style: const TextStyle(color: AppColors.muted)))),
                for (final ch in chs) _chapterTile(chs, ch),
              ],
            ),
    );
  }

  Widget _chapterTile(List<Map<String, dynamic>> chs, Map<String, dynamic> ch) {
    final n = ch['n'] as int;
    final wc = JlptCourse.words(ch).length;
    final done = [for (final p in _kParts) if (_Done.v.contains('$_lv-$n-$p')) p].length;
    final locked = !PaywallGate.openFor(_lv) && !courseChapterFree(n);
    final ready = ch['read'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          key: ValueKey('course-ch-$_lv-$n'),
          onTap: () => _open(chs, ch),
          leading: CircleAvatar(
            backgroundColor: done == _kParts.length ? AppColors.matcha : AppColors.washiDeep,
            foregroundColor: done == _kParts.length ? Colors.white : AppColors.sumi,
            child: done == _kParts.length ? const Icon(Icons.check, size: 20) : Text('$n', style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          title: Text(ch['title'] == null ? trf('{0}장', [n]) : '${trf('{0}장', [n])} · ${ch['title']}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.sumi)),
          subtitle: Text(
            '${trf('낱말 {0}개 · 문형 {1}개', [wc, (ch['patterns'] as List).length])}${ready ? '' : ' · ${tr('이야기·대화 준비 중')}'}\n${trf('{0}/5 마침', [done])}',
            style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5),
          ),
          isThreeLine: true,
          trailing: locked ? const LockBadge() : const Icon(Icons.chevron_right, color: AppColors.muted),
        ),
      ),
    );
  }
}

/// 한 장: 낱말·문형·읽기·듣기·복습 문제를 탭으로.
class JlptChapterScreen extends StatefulWidget {
  final int level;
  final Map<String, dynamic> chapter;
  final List<Map<String, dynamic>> chapters;
  final Map<String, Map<String, dynamic>> patterns;
  const JlptChapterScreen({super.key, required this.level, required this.chapter, required this.chapters, required this.patterns});
  @override
  State<JlptChapterScreen> createState() => _JlptChapterScreenState();
}

class _JlptChapterScreenState extends State<JlptChapterScreen> {
  int get _n => widget.chapter['n'] as int;
  String _key(String part) => '${widget.level}-$_n-$part';
  bool _on(String part) => _Done.v.contains(_key(part));
  Future<void> _mark(String part, [bool? on]) async {
    await _Done.toggle(_key(part), on);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.chapter;
    final tabs = [tr('낱말'), tr('문형'), tr('읽기'), tr('듣기'), tr('복습')];
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.washiDeep,
        appBar: AppBar(
          title: Text('N${widget.level} · ${trf('{0}장', [_n])}'),
          bottom: TabBar(
            isScrollable: false,
            labelPadding: EdgeInsets.zero,
            tabs: [
              for (var i = 0; i < 5; i++)
                Tab(
                  key: ValueKey('course-tab-${_kParts[i]}'),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(tabs[i], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    if (_on(_kParts[i])) const Padding(padding: EdgeInsets.only(left: 2), child: Icon(Icons.check_circle, size: 13, color: AppColors.matcha)),
                  ]),
                ),
            ],
          ),
        ),
        body: TabBarView(children: [
          _words(ch),
          _grammar(ch),
          _story(ch['read'] as Map<String, dynamic>?, 'r'),
          _story(ch['listen'] as Map<String, dynamic>?, 'l'),
          _review(),
        ]),
      ),
    );
  }

  EdgeInsets get _pad => EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context));

  Widget _doneButton(String part, String label) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: FilledButton.icon(
          key: ValueKey('course-done-$part'),
          onPressed: () => _mark(part),
          style: FilledButton.styleFrom(backgroundColor: _on(part) ? AppColors.matcha : AppColors.ai),
          icon: Icon(_on(part) ? Icons.check_circle : Icons.done, size: 18),
          label: Text(_on(part) ? tr('마쳤어요') : label),
        ),
      );

  Widget _box({required Widget child, EdgeInsets padding = const EdgeInsets.all(12)}) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
        child: child,
      );

  Widget _words(Map<String, dynamic> ch) {
    final groups = (ch['words'] as List).cast<Map<String, dynamic>>();
    final all = JlptCourse.words(ch);
    final sets = (all.length / _kSet).ceil();
    return ListView(padding: _pad, children: [
      Text(tr('쉬운 한자부터, 같은 소리 부품을 가진 한자는 붙여서 모았어요. 20개씩 카드로 외워요.'), style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.45)),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (var i = 0; i < sets; i++)
          OutlinedButton(
            key: ValueKey('course-set-${i + 1}'),
            onPressed: () => openFull(context, (_) => WordUnitFlashScreen(title: 'N${widget.level} · ${trf('{0}장', [_n])} · ${i + 1}', words: all.sublist(i * _kSet, min(all.length, (i + 1) * _kSet)))),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.ai, side: const BorderSide(color: AppColors.line), visualDensity: VisualDensity.compact),
            child: Text(trf('카드 {0}', [i + 1]), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
      ]),
      const SizedBox(height: 10),
      for (final g in groups)
        _box(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if ('${g['k']}'.isEmpty)
              Text(tr('가나 낱말'), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.beniDeep))
            else
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${g['k']}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.1)),
                const SizedBox(width: 8),
                Expanded(child: Text('${g['m']}', style: const TextStyle(fontSize: 13, color: AppColors.sumiLight))),
                if ('${g['f'] ?? ''}'.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(8)),
                    child: Text(trf('{0} 패밀리', ['${g['f']}']), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ai)),
                  ),
              ]),
            const SizedBox(height: 4),
            for (final w in (g['w'] as List))
              InkWell(
                onTap: () => TtsService.instance.speak('${w[1]}'.isEmpty ? '${w[0]}'.replaceAll(RegExp('[～〜~]'), '') : '${w[1]}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    SizedBox(width: 96, child: Text('${w[0]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.sumi))),
                    SizedBox(width: 92, child: Text('${w[1]}', style: const TextStyle(fontSize: 12.5, color: AppColors.muted))),
                    Expanded(child: Text('${w[2]}', style: const TextStyle(fontSize: 13.5, color: AppColors.sumi))),
                  ]),
                ),
              ),
          ]),
        ),
      _doneButton('w', tr('낱말을 다 봤어요')),
    ]);
  }

  Widget _grammar(Map<String, dynamic> ch) => ListView(padding: _pad, children: [
        for (final id in (ch['patterns'] as List))
          if (widget.patterns['$id'] != null) PatternCard(pattern: widget.patterns['$id']!),
        _doneButton('g', tr('문형을 다 읽었어요')),
      ]);

  Widget _story(Map<String, dynamic>? s, String part) {
    if (s == null) return Center(child: Text(tr('이 장의 이야기·대화는 준비 중이에요'), style: const TextStyle(color: AppColors.muted)));
    return _StoryView(key: ValueKey('story-$part'), story: s, listen: part == 'l', onAllRight: () => _mark(part, true), done: _on(part));
  }

  Widget _review() => ListView(padding: _pad, children: [
        _box(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tr('복습 문제'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.sumi)),
            const SizedBox(height: 4),
            Text(tr('이 장의 낱말·문형에 앞 장 것이 섞여 나와요. 할 때마다 문제가 바뀌니 여러 번 풀어요.'), style: const TextStyle(fontSize: 13, color: AppColors.sumiLight, height: 1.45)),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const ValueKey('course-review-start'),
              onPressed: () async {
                final qs = JlptCourse.review(widget.chapters, _n, widget.patterns);
                final ok = await openFull<bool>(context, (_) => CourseQuizScreen(title: 'N${widget.level} · ${trf('{0}장', [_n])} · ${tr('복습')}', questions: qs));
                if (ok == true) await _mark('q', true);
              },
              icon: const Icon(Icons.quiz_outlined, size: 18),
              label: Text(_on('q') ? tr('한 번 더 풀기') : tr('문제 풀기')),
            ),
          ]),
        ),
      ]);
}

/// 이야기(읽기)·대화(듣기) + 내용 확인 문제. 듣기는 대본을 가리고 먼저 듣는다.
class _StoryView extends StatefulWidget {
  final Map<String, dynamic> story;
  final bool listen, done;
  final VoidCallback onAllRight;
  const _StoryView({super.key, required this.story, required this.listen, required this.onAllRight, required this.done});
  @override
  State<_StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<_StoryView> with AutomaticKeepAliveClientMixin {
  late bool _script = !widget.listen;
  bool _ko = false;
  int _playing = -1;
  int _token = 0;
  late final List<CourseQ> _qs = [for (final q in (widget.story['q'] as List? ?? const [])) CourseQ.of(q as Map<String, dynamic>)];
  final Map<int, int> _picked = {};

  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> get _lines => (widget.story['lines'] as List).cast<Map<String, dynamic>>();
  String _gender(Map<String, dynamic> l) => '${((widget.story['who'] as Map?)?[l['who']] as List?)?[1] ?? 'female'}';
  String _name(Map<String, dynamic> l) => '${((widget.story['who'] as Map?)?[l['who']] as List?)?[0] ?? ''}';

  Future<void> _say(Map<String, dynamic> l) => widget.listen ? TtsService.instance.speakAs(plainPoint('${l['ja']}'), gender: _gender(l)) : TtsService.instance.speak(plainPoint('${l['ja']}'));

  Future<void> _playAll() async {
    if (_playing >= 0) {
      _token++;
      await TtsService.instance.stop();
      if (mounted) setState(() => _playing = -1);
      return;
    }
    final t = ++_token;
    for (var i = 0; i < _lines.length; i++) {
      if (!mounted || t != _token) return;
      setState(() => _playing = i);
      await _say(_lines[i]);
    }
    if (mounted && t == _token) setState(() => _playing = -1);
  }

  void _pick(int qi, int oi) {
    if (_picked.containsKey(qi)) return;
    setState(() => _picked[qi] = oi);
    if (_picked.length == _qs.length && [for (var i = 0; i < _qs.length; i++) _picked[i] == _qs[i].a].every((e) => e)) widget.onAllRight();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = widget.story;
    const ja = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.sumi, height: 1.5);
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
      children: [
        Text('${s['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.sumi)),
        Text('${s['ko']}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          FilledButton.icon(
            key: const ValueKey('story-play'),
            onPressed: _playAll,
            icon: Icon(_playing >= 0 ? Icons.stop : Icons.play_arrow, size: 18),
            label: Text(_playing >= 0 ? tr('멈춤') : tr('처음부터 듣기')),
          ),
          if (widget.listen)
            OutlinedButton(key: const ValueKey('story-script'), onPressed: () => setState(() => _script = !_script), child: Text(_script ? tr('대본 가리기') : tr('대본 보기'))),
          if (_script) OutlinedButton(key: const ValueKey('story-ko'), onPressed: () => setState(() => _ko = !_ko), child: Text(_ko ? tr('뜻 가리기') : tr('뜻 보기'))),
        ]),
        const SizedBox(height: 10),
        if (!_script)
          Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: Text(tr('먼저 대본 없이 들어 보세요. 아래 문제를 풀고 나서 대본을 확인해요.'), style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5)))
        else
          for (var i = 0; i < _lines.length; i++)
            InkWell(
              onTap: () => _say(_lines[i]),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: _playing == i ? const Color(0xFFEFF3FF) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_name(_lines[i]).isNotEmpty) Text(_name(_lines[i]), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.beniDeep)),
                  Text.rich(TextSpan(children: pointSpans('${_lines[i]['ja']}', ja))),
                  Text('${_lines[i]['kana']}', style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4)),
                  if (_ko) Text.rich(TextSpan(children: pointSpans('${_lines[i]['ko']}', const TextStyle(fontSize: 13.5, color: AppColors.sumi, height: 1.45)))),
                ]),
              ),
            ),
        const SizedBox(height: 8),
        Text(tr('내용 확인'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi)),
        const SizedBox(height: 6),
        for (var i = 0; i < _qs.length; i++) QuestionCard(key: ValueKey('story-q-$i'), q: _qs[i], picked: _picked[i], onPick: (o) => _pick(i, o)),
        if (widget.done) Padding(padding: const EdgeInsets.only(top: 6), child: Text(tr('마쳤어요'), style: const TextStyle(color: AppColors.matcha, fontWeight: FontWeight.w800))),
      ],
    );
  }
}

/// 4지선다 한 문제. 고르면 맞음·틀림과 풀이가 보인다.
class QuestionCard extends StatelessWidget {
  final CourseQ q;
  final int? picked;
  final ValueChanged<int> onPick;
  const QuestionCard({super.key, required this.q, required this.picked, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final answered = picked != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(q.q, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.4)),
        if (q.sub.isNotEmpty) Text(q.sub, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        const SizedBox(height: 8),
        for (var i = 0; i < q.opts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: OutlinedButton(
              key: ValueKey('opt-$i'),
              onPressed: answered ? null : () => onPick(i),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                foregroundColor: AppColors.sumi,
                disabledForegroundColor: i == q.a ? AppColors.matcha : (i == picked ? AppColors.sakuraDeep : AppColors.muted),
                side: BorderSide(color: !answered ? AppColors.line : (i == q.a ? AppColors.matcha : (i == picked ? AppColors.sakuraDeep : AppColors.line)), width: answered && (i == q.a || i == picked) ? 1.6 : 1),
              ),
              child: Text(q.opts[i], style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
            ),
          ),
        if (answered)
          Text('${picked == q.a ? tr('맞았어요') : tr('틀렸어요')}${q.why.isEmpty ? '' : ' · ${q.why}'}', style: TextStyle(fontSize: 12.5, height: 1.45, color: picked == q.a ? AppColors.matcha : AppColors.sakuraDeep, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// 복습 문제 풀기 — 한 문제씩, 틀린 문제는 끝에 다시 나온다. 다 맞히면 true 로 닫힌다.
class CourseQuizScreen extends StatefulWidget {
  final String title;
  final List<CourseQ> questions;
  const CourseQuizScreen({super.key, required this.title, required this.questions});
  @override
  State<CourseQuizScreen> createState() => _CourseQuizScreenState();
}

class _CourseQuizScreenState extends State<CourseQuizScreen> {
  late final List<CourseQ> _queue = [...widget.questions];
  int _pos = 0, _wrong = 0;
  int? _picked;

  void _pick(int i) {
    final q = _queue[_pos];
    setState(() => _picked = i);
    if (q.speak.isNotEmpty) TtsService.instance.speak(q.speak);
    if (i != q.a) {
      _wrong++;
      _queue.add(q);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finished = _pos >= _queue.length;
    return Scaffold(
      backgroundColor: AppColors.washiDeep,
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
        child: finished
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.kinDeep),
                  const SizedBox(height: 8),
                  Text(trf('{0}문제를 모두 맞혔어요', [widget.questions.length]), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                  if (_wrong > 0) Text(trf('다시 푼 문제 {0}개', [_wrong]), style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 14),
                  FilledButton(key: const ValueKey('quiz-close'), onPressed: () => Navigator.of(context).pop(true), child: Text(tr('닫기'))),
                ]),
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                LinearProgressIndicator(value: _pos / _queue.length, minHeight: 5, backgroundColor: AppColors.line, color: AppColors.ai),
                const SizedBox(height: 4),
                Text('${_pos + 1} / ${_queue.length}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 10),
                Expanded(child: SingleChildScrollView(child: QuestionCard(key: ValueKey('quiz-q-$_pos'), q: _queue[_pos], picked: _picked, onPick: _pick))),
                FilledButton(
                  key: const ValueKey('quiz-next'),
                  onPressed: _picked == null ? null : () => setState(() { _pos++; _picked = null; }),
                  child: Text(tr('다음')),
                ),
              ]),
      ),
    );
  }
}
