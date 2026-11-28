// ignore_for_file: curly_braces_in_flow_control_structures
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
import '../services/paywall_gate.dart';
import '../services/tts_service.dart';

/// JLPT 문형 누적 읽기 — 문형마다 읽을 문장 1~3개, 포인트는 파란 밑줄, 아래에 짧은 설명(사용자 지시 2026-11-28: 암기가 아니라 누적 읽기).
/// 날마다 새 단원을 읽고 앞 단원을 처음부터 다시 읽는다. 단원마다 읽은 횟수를 센다.
/// 데이터 `assets/data/jlpt/patterns.json`: [{id, head, yomi, lv(1~5 = N1~N5), cat(쓰임 분류), mean, conn, tip, s:[{ja, kana, ko}]}] — 문장의 `{…}` 가 포인트.
/// 문형 고르기·분류·뜻풀이·설명·예문은 모두 자체 작성(특정 교재의 목록·번호·해설을 따르지 않는다).
/// 누적 읽기 묶음 — 같은 화면으로 문형과 「헷갈리는 말」을 읽는다(자료·저장 키·하루 분량만 다름).
class PatternSet {
  final String asset, readKey, startKey, title, intro;
  final int perDay;
  const PatternSet({required this.asset, required this.readKey, required this.startKey, required this.title, required this.intro, this.perDay = 2});
  static const jlpt = PatternSet(
    asset: 'assets/data/jlpt/patterns.json',
    readKey: 'jlpt_pattern_reads',
    startKey: 'jlpt_pattern_start',
    title: 'JLPT 문형 누적 읽기',
    intro: '한 달 동안 날마다 2단원씩 새로 읽고, 앞 단원을 처음부터 다시 읽어요. 외우지 않아도 돼요.',
  );
  /// 한국어 한 낱말에 일본어가 둘 이상인 말(있다 = いる / ある …) — 말마다 짧은 문장 하나씩(자체 작성).
  static const confuse = PatternSet(
    asset: 'assets/data/jlpt/confusables.json',
    readKey: 'jlpt_confuse_reads',
    startKey: 'jlpt_confuse_start',
    title: '헷갈리는 말 누적 읽기',
    intro: '날마다 1단원씩 새로 읽고, 앞 단원을 처음부터 다시 읽어요. 짧은 문장으로 차이를 느껴요.',
    perDay: 1,
  );
  bool unitFree(int unit) => unit <= kPatternFreeDays * perDay;

  /// 단원에 든 가장 어려운 급 — N1·N2 가 든 단원은 시험 권한으로 연다(자료는 N5→N1 순, 급 안에서는 쉬운 한자 순).
  static int unitLevel(List<Map<String, dynamic>> all, int unit) {
    var lv = 5;
    for (var i = (unit - 1) * kPatternUnit; i < unit * kPatternUnit && i < all.length; i++) {
      final v = (all[i]['lv'] as num?)?.toInt() ?? 5;
      if (v < lv) lv = v;
    }
    return lv;
  }
}

const kPatternUnit = 10;
const _kPoint = Color(0xFF2F6FDB);
final _kMark = RegExp(r'\{([^}]*)\}');

/// 표시를 없앤 본문(듣기용).
String plainPoint(String s) => s.replaceAllMapped(_kMark, (m) => m.group(1)!);

/// `{…}` 자리를 파란 글자 + 밑줄로.
List<InlineSpan> pointSpans(String s, TextStyle base) {
  final out = <InlineSpan>[];
  var i = 0;
  for (final m in _kMark.allMatches(s)) {
    if (m.start > i)
      out.add(TextSpan(text: s.substring(i, m.start), style: base));
    out.add(
      TextSpan(
        text: m.group(1),
        style: base.copyWith(
          color: _kPoint,
          decoration: TextDecoration.underline,
          decorationColor: _kPoint,
          decorationThickness: 2,
        ),
      ),
    );
    i = m.end;
  }
  if (i < s.length) out.add(TextSpan(text: s.substring(i), style: base));
  return out;
}

class JlptPatterns {
  static final Map<String, List<Map<String, dynamic>>> _cache = {};

  /// 읽는 순서 = 원고 파일 순서 그대로 — 급별 N5→N1, 급 안에서는 쉬운 한자(패밀리가 큰·자주 쓰는 한자)로 된 문형부터(사용자 지시 2026-11-28 「급별로 다시 묶기」, 정렬은 원고를 만들 때 함).
  static Future<List<Map<String, dynamic>>> load([PatternSet set = PatternSet.jlpt]) async {
    if (_cache[set.asset] != null) return _cache[set.asset]!;
    final b = await rootBundle.load(assetPath(set.asset));
    return _cache[set.asset] = (json.decode(utf8.decode(b.buffer.asUint8List(b.offsetInBytes, b.lengthInBytes))) as List).cast<Map<String, dynamic>>();
  }

  static int unitCount(int n) => (n / kPatternUnit).ceil();

  /// 누적 읽기 순서: 오늘 새 단원([newFrom]~[upTo]) 먼저, 그다음 앞 단원을 1단원부터. 범위가 없으면 전부 순서대로.
  static List<int> session(int total, {int? newFrom, int? upTo}) {
    final last = unitCount(total);
    if (upTo == null) return [for (var u = 1; u <= last; u++) u];
    final to = upTo.clamp(1, last == 0 ? 1 : last);
    final from = (newFrom ?? 1).clamp(1, to);
    return [
      for (var u = from; u <= to; u++) u,
      for (var u = 1; u < from; u++) u,
    ];
  }
}

/// 한 달 일정(사용자 지시 2026-11-28 「한달에 거쳐서」): 하루 [kPatternPerDay]단원씩 새로 읽고 앞 단원을 누적으로 다시 읽는다.
/// 첫날 = 이 화면을 처음 연 날(Prefs). 날을 누르면 그날의 누적 읽기가 열린다.
const kPatternPerDay = 2;

/// 이용권 없이 읽는 날 수(사용자 11-28 「일부풀고 이용권」) — 처음 3일(1~6단원, 문형 60개). 그 뒤는 이용권.
const kPatternFreeDays = 3;
bool patternUnitFree(int unit) => unit <= kPatternFreeDays * kPatternPerDay;

class JlptPatternDaysScreen extends StatefulWidget {
  /// 시험용 — 오늘 날짜를 바꿔 끼운다.
  final DateTime? now;
  final PatternSet set;
  const JlptPatternDaysScreen({super.key, this.now, this.set = PatternSet.jlpt});

  @override
  State<JlptPatternDaysScreen> createState() => _JlptPatternDaysScreenState();
}

class _JlptPatternDaysScreenState extends State<JlptPatternDaysScreen> {
  int? _total;
  List<Map<String, dynamic>> _all = const [];
  int _today = 1;
  Map<String, int> _reads = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await JlptPatterns.load(widget.set);
    final p = await Prefs.getInstance();
    final now = widget.now ?? DateTime.now();
    final day0 = DateTime(now.year, now.month, now.day);
    var start = DateTime.tryParse(p.getString(widget.set.startKey) ?? '');
    if (start == null) {
      start = day0;
      await p.setString(widget.set.startKey, day0.toIso8601String());
    }
    final reads = <String, int>{};
    try {
      (json.decode(p.getString(widget.set.readKey) ?? '{}') as Map).forEach(
        (k, v) => reads['$k'] = (v as num).toInt(),
      );
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _total = all.length;
      _all = all;
      _today = day0.difference(start!).inDays + 1;
      _reads = reads;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final units = total == null ? 0 : JlptPatterns.unitCount(total);
    final days = (units / widget.set.perDay).ceil();
    return ListenableBuilder(
      listenable: PaywallGate.changes,
      builder: (context, _) => _scaffold(context, total, units, days),
    );
  }

  Widget _scaffold(BuildContext context, int? total, int units, int days) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Text(
          tr(widget.set.title),
          style: const TextStyle(
            color: AppColors.sumi,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (!await PaywallGate.passLevel(context, _all.any((p) => PaywallGate.examLevel((p['lv'] as num?)?.toInt() ?? 5)) ? 1 : 3, false) || !context.mounted)
                return;
              openPane(context, (_) => JlptPatternsScreen(set: widget.set));
            },
            child: Text(
              tr('전체 보기'),
              style: const TextStyle(color: AppColors.ai, fontSize: 13),
            ),
          ),
        ],
      ),
      body: total == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                24 + bottomInset(context),
              ),
              children: [
                Text(
                  tr(widget.set.intro),
                  style: const TextStyle(
                    color: AppColors.sumiLight,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                for (var d = 1; d <= days; d++) _row(context, d, units),
              ],
            ),
    );
  }

  Widget _row(BuildContext context, int d, int units) {
    final a = (d - 1) * widget.set.perDay + 1;
    final b = (a + widget.set.perDay - 1).clamp(1, units);
    final isToday = d == _today;
    final read = [
      for (var u = a; u <= b; u++) _reads['$u'] ?? 0,
    ].every((n) => n > 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isToday ? AppColors.kin : AppColors.line,
            width: isToday ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('pat-day-$d'),
          onTap: () async {
            if (!await PaywallGate.passLevel(context, PatternSet.unitLevel(_all, b), widget.set.unitFree(b)) ||
                !context.mounted)
              return;
            await openPane(
              context,
              (_) => JlptPatternsScreen(newFrom: a, upTo: b, set: widget.set),
            );
            _load();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 58,
                  child: Text(
                    trf('{0}일차', [d]),
                    style: TextStyle(
                      color: isToday ? AppColors.kinDeep : AppColors.ai,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${widget.set == PatternSet.jlpt ? 'N${PatternSet.unitLevel(_all, b)} · ' : ''}${a == b ? trf('{0}단원', [a]) : '${trf('새로 {0}~{1}단원', [a, b])}${a > 1 ? ' · ${trf('누적 1~{0}단원', [a - 1])}' : ''}'}',
                    style: const TextStyle(
                      color: AppColors.sumi,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
                if (isToday)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      tr('오늘'),
                      style: const TextStyle(
                        color: AppColors.kinDeep,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (!PaywallGate.openFor(PatternSet.unitLevel(_all, b)) && !widget.set.unitFree(b))
                  const LockBadge()
                else
                  Icon(
                    read ? Icons.check_circle : Icons.chevron_right,
                    size: 20,
                    color: read ? AppColors.matcha : AppColors.sumiLight,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 문형 누적 읽기 — [upTo] 가 있으면 그날의 누적 읽기(새 단원 → 앞 단원 다시), 없으면 전체.
class JlptPatternsScreen extends StatefulWidget {
  final int? newFrom, upTo;
  final PatternSet set;
  const JlptPatternsScreen({super.key, this.newFrom, this.upTo, this.set = PatternSet.jlpt});

  @override
  State<JlptPatternsScreen> createState() => _JlptPatternsScreenState();
}

class _JlptPatternsScreenState extends State<JlptPatternsScreen> {
  List<Map<String, dynamic>>? _all;
  Map<String, int> _reads = {}; // 단원 번호 → 읽은 횟수

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await JlptPatterns.load(widget.set);
    final raw = (await Prefs.getInstance()).getString(widget.set.readKey);
    final reads = <String, int>{};
    if (raw != null) {
      try {
        (json.decode(raw) as Map).forEach(
          (k, v) => reads['$k'] = (v as num).toInt(),
        );
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _all = all;
      _reads = reads;
    });
  }

  Future<void> _read(int unit) async {
    setState(() => _reads['$unit'] = (_reads['$unit'] ?? 0) + 1);
    await (await Prefs.getInstance()).setString(widget.set.readKey, json.encode(_reads));
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = _all;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Text(
          tr(widget.set.title),
          style: const TextStyle(
            color: AppColors.sumi,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: all == null
          ? const Center(child: CircularProgressIndicator())
          : _body(context, all),
    );
  }

  Widget _body(BuildContext context, List<Map<String, dynamic>> all) {
    final units = JlptPatterns.session(
      all.length,
      newFrom: widget.newFrom,
      upTo: widget.upTo,
    );
    final from = widget.upTo == null ? null : (widget.newFrom ?? 1);
    // 단원 머리줄 + 그 단원의 문형들을 한 줄 목록으로 편다.
    final rows = <(int unit, Map<String, dynamic>? p)>[];
    for (final u in units) {
      rows.add((u, null));
      for (
        var i = (u - 1) * kPatternUnit;
        i < u * kPatternUnit && i < all.length;
        i++
      ) {
        rows.add((u, all[i]));
      }
      rows.add((-u, null)); // 단원 끝 「읽음」 버튼
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(
            from == null
                ? trf('문형 {0}개 · {1}단원 · 외우지 말고 여러 번 읽어요. 파란 밑줄이 포인트예요', [
                    all.length,
                    JlptPatterns.unitCount(all.length),
                  ])
                : tr(
                    '새 단원을 먼저 읽고, 앞 단원을 처음부터 다시 읽어요. 외우지 말고 읽기만 — 파란 밑줄이 포인트예요',
                  ),
            key: const ValueKey('pat-progress'),
            style: const TextStyle(
              color: AppColors.sumiLight,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 24 + bottomInset(context)),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final (u, p) = rows[i];
              if (p != null) return PatternCard(pattern: p);
              if (u > 0) {
                final isNew = from != null && u >= from;
                final n = _reads['$u'] ?? 0;
                return Padding(
                  key: ValueKey('pat-unit-$u'),
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                  child: Row(
                    children: [
                      Text(
                        trf('{0}단원', [u]),
                        style: const TextStyle(
                          color: AppColors.sumi,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (from != null)
                        Text(
                          isNew ? tr('오늘 새로') : tr('누적 복습'),
                          style: TextStyle(
                            color: isNew ? AppColors.kinDeep : AppColors.ai,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        trf('{0}번 읽음', [n]),
                        key: ValueKey('pat-reads-$u'),
                        style: const TextStyle(
                          color: AppColors.sumiLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton.icon(
                    key: ValueKey('pat-read-${-u}'),
                    onPressed: () => _read(-u),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ai,
                      side: const BorderSide(color: AppColors.line),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.done, size: 16),
                    label: Text(
                      trf('{0}단원 읽었어요', [-u]),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PatternCard extends StatelessWidget {
  final Map<String, dynamic> pattern;
  const PatternCard({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    final p = pattern;
    final ss = ((p['s'] as List?) ?? const []).cast<Map<String, dynamic>>();
    const ja = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: AppColors.sumi,
      height: 1.45,
    );
    const ko = TextStyle(fontSize: 13.5, color: AppColors.sumi, height: 1.45);
    return Container(
      key: ValueKey('pat-${p['id']}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          '${p['head']}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: _kPoint,
                          ),
                        ),
                        if ('${p['yomi'] ?? ''}'.isNotEmpty && p['yomi'] != p['head'])
                          Text('${p['yomi']}', style: const TextStyle(fontSize: 11.5, color: AppColors.sumiLight)),
                        Text(
                          'N${p['lv']}${'${p['cat'] ?? ''}'.isEmpty ? '' : ' · ${p['cat']}'}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.sumiLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p['mean'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sumi,
                      ),
                    ),
                    if ('${p['conn'] ?? ''}'.isNotEmpty)
                      Text(
                        '${p['conn']}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.sumiLight,
                          height: 1.4,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          for (final s in ss)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(children: pointSpans('${s['ja']}', ja)),
                        ),
                        if (s['kana'] != null)
                          Text(
                            '${s['kana']}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.sumiLight,
                              height: 1.4,
                            ),
                          ),
                        if (s['kana'] != null)
                          KoReadingText(
                            '${s['kana']}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.sumiLight,
                            ),
                          ),
                        Text.rich(
                          TextSpan(children: pointSpans('${s['ko']}', ko)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: tr('듣기'),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.volume_up,
                      color: AppColors.beni,
                      size: 20,
                    ),
                    onPressed: () =>
                        TtsService.instance.speak(plainPoint('${s['ja']}')),
                  ),
                ],
              ),
            ),
          if ('${p['tip'] ?? ''}'.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 10, right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.washiDeep,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${p['tip']}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.sumi,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
