import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/embed_env.dart';
import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/prefs.dart';
import '../core/theme.dart';
import '../services/word_service.dart';
import '../widgets/japanese_decor.dart';
import 'sense_course_screen.dart';
import 'jlpt_words_screen.dart';
import 'kanji_stages_screen.dart';
import 'word_unit_flash_screen.dart';

/// JLPT 대비 — 시험 날까지 날짜별 계획(사용자 지시 2026-11-28). 데이터 `assets/data/jlpt/prep_n1.json`.
/// 날마다 할 일을 체크하고, 단어 단원·한자 퀴즈는 앱 안 화면으로 바로 연다. 교재는 「교재 N장」으로만 적는다(책 이름·쪽수는 싣지 않음).
const _kDoneKey = 'jlpt_prep_done';
const _kAsset = 'assets/data/jlpt/prep_n1.json';
const _kUnit = 20;

class JlptPrep {
  static Future<Map<String, dynamic>> load() async {
    final b = await rootBundle.load(assetPath(_kAsset));
    return json.decode(
          utf8.decode(b.buffer.asUint8List(b.offsetInBytes, b.lengthInBytes)),
        )
        as Map<String, dynamic>;
  }

  /// 시험까지 남은 날(오늘이 시험 날이면 0, 지났으면 음수).
  static int daysLeft(String examDate, DateTime now) => DateTime.parse(
    examDate,
  ).difference(DateTime(now.year, now.month, now.day)).inDays;

  static String dLabel(int left) =>
      left > 0 ? 'D-$left' : (left == 0 ? 'D-DAY' : 'D+${-left}');

  static String ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class JlptPrepScreen extends StatefulWidget {
  /// 시험용 — 오늘 날짜를 바꿔 끼운다.
  final DateTime? now;
  const JlptPrepScreen({super.key, this.now});

  @override
  State<JlptPrepScreen> createState() => _JlptPrepScreenState();
}

class _JlptPrepScreenState extends State<JlptPrepScreen> {
  Map<String, dynamic>? _plan;
  Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await JlptPrep.load();
    final done =
        ((await Prefs.getInstance()).getStringList(_kDoneKey) ?? const [])
            .toSet();
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _done = done;
    });
  }

  Future<void> _toggle(String id) async {
    setState(() => _done.contains(id) ? _done.remove(id) : _done.add(id));
    await (await Prefs.getInstance()).setStringList(_kDoneKey, _done.toList());
  }

  Future<void> _openUnit(int level, int unit) async {
    final ws = await WordService.instance.byLevel(
      level,
      offset: (unit - 1) * _kUnit,
      limit: _kUnit,
    );
    if (!mounted || ws.isEmpty) return;
    await openFull(
      context,
      (_) => WordUnitFlashScreen(
        title: 'N$level · ${trf('{0}단원', [unit])}',
        words: [
          for (final w in ws)
            StudyWord(
              word: w.surface,
              kana: w.kana == w.surface ? '' : w.kana,
              gloss: w.gloss,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Text(
          tr('JLPT 대비'),
          style: const TextStyle(
            color: AppColors.sumi,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : _body(context, plan),
    );
  }

  Widget _body(BuildContext context, Map<String, dynamic> plan) {
    final exam = plan['exam'] as Map<String, dynamic>;
    final level = int.parse('${exam['level']}'.substring(1));
    final now = widget.now ?? DateTime.now();
    final today = JlptPrep.ymd(now);
    final left = JlptPrep.daysLeft(exam['date'] as String, now);
    final days = (plan['days'] as List).cast<Map<String, dynamic>>();
    final all = [
      for (final d in days)
        ...(d['tasks'] as List).cast<Map<String, dynamic>>(),
    ];
    final doneN = all.where((t) => _done.contains(t['id'])).length;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GradText(
                    JlptPrep.dLabel(left),
                    key: const ValueKey('jlpt-dday'),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'JLPT ${exam['level']} · ${exam['date']}',
                        style: const TextStyle(
                          color: AppColors.sumi,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: all.isEmpty ? 0 : doneN / all.length,
                  minHeight: 6,
                  backgroundColor: AppColors.washiDeep,
                  color: AppColors.kin,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                trf('{0}/{1} 마침', [doneN, all.length]),
                key: const ValueKey('jlpt-progress'),
                style: const TextStyle(
                  color: AppColors.sumiLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              for (final f in (plan['facts'] as List? ?? const []))
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '· $f',
                    style: const TextStyle(
                      color: AppColors.sumi,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              if ((plan['note'] as String?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 6),
                Text(
                  plan['note'] as String,
                  style: const TextStyle(
                    color: AppColors.sumiLight,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final d in days)
          _DayCard(
            day: d,
            isToday: d['date'] == today,
            past: (d['date'] as String).compareTo(today) < 0,
            level: level,
            done: _done,
            onToggle: _toggle,
            onUnit: (u) => _openUnit(level, u),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final Map<String, dynamic> day;
  final bool isToday, past;
  final int level;
  final Set<String> done;
  final ValueChanged<String> onToggle;
  final ValueChanged<int> onUnit;
  const _DayCard({
    required this.day,
    required this.isToday,
    required this.past,
    required this.level,
    required this.done,
    required this.onToggle,
    required this.onUnit,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = (day['tasks'] as List).cast<Map<String, dynamic>>();
    final n = tasks.where((t) => done.contains(t['id'])).length;
    final date = (day['date'] as String).substring(5).replaceAll('-', '/');
    return Container(
      key: ValueKey('jlpt-day-${day['date']}'),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? AppColors.kin : AppColors.line,
          width: isToday ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isToday,
            tilePadding: const EdgeInsets.symmetric(horizontal: 14),
            childrenPadding: const EdgeInsets.fromLTRB(6, 0, 10, 10),
            title: Row(
              children: [
                Text(
                  '${day['label']}',
                  style: TextStyle(
                    color: isToday ? AppColors.kinDeep : AppColors.ai,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.sumiLight,
                    fontSize: 12,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Text(
                    tr('오늘'),
                    style: const TextStyle(
                      color: AppColors.kinDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '$n/${tasks.length}',
                  style: TextStyle(
                    color: n == tasks.length
                        ? AppColors.matcha
                        : (past ? AppColors.beniDeep : AppColors.sumiLight),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${day['title']}',
              style: const TextStyle(
                color: AppColors.sumi,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            children: [
              for (final t in tasks) ...[
                InkWell(
                  key: ValueKey('jlpt-task-${t['id']}'),
                  onTap: () => onToggle(t['id'] as String),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 6,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          done.contains(t['id'])
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20,
                          color: done.contains(t['id'])
                              ? AppColors.matcha
                              : AppColors.sumiLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${t['text']}',
                            style: const TextStyle(
                              color: AppColors.sumi,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (t['units'] is List)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(34, 0, 0, 6),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (
                          var u = (t['units'] as List)[0] as int;
                          u <= ((t['units'] as List)[1] as int);
                          u++
                        )
                          OutlinedButton(
                            key: ValueKey('jlpt-unit-$u'),
                            onPressed: () => onUnit(u),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.ai,
                              side: const BorderSide(color: AppColors.line),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: const Size(0, 32),
                            ),
                            child: Text(
                              trf('{0}단원', [u]),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (t['open'] != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(34, 0, 0, 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () => openPane(
                          context,
                          (_) => switch (t['open']) {
                            'kanji' => const KanjiStagesScreen(),
                            'sense' => const SenseCourseScreen(),
                            _ => JlptWordsScreen(initialLevel: level),
                          },
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ai,
                          side: const BorderSide(color: AppColors.line),
                          visualDensity: VisualDensity.compact,
                          minimumSize: const Size(0, 32),
                        ),
                        child: Text(
                          switch (t['open']) {
                            'kanji' => tr('한자 퀴즈 열기'),
                            'sense' => tr('언어감각 익히기 열기'),
                            _ => tr('JLPT 단어 열기'),
                          },
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
