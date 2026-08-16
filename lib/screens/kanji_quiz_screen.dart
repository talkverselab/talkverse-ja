import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/db/app_database.dart';
import '../main.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../widgets/selectable_ja_text.dart';

/// 한자 4지선다 퀴즈 — 현재 단계 출제, 누적 단계는 오답 풀.
class KanjiQuizScreen extends StatefulWidget {
  final int stage;
  final List<List<KanjiEntry>> allStages;

  const KanjiQuizScreen({super.key, required this.stage, required this.allStages});

  @override
  State<KanjiQuizScreen> createState() => _KanjiQuizScreenState();
}

class _Q {
  final KanjiEntry entry;
  final List<String> options;
  final int correctIndex;
  _Q({required this.entry, required this.options, required this.correctIndex});
}

class _KanjiQuizScreenState extends State<KanjiQuizScreen> {
  List<_Q> _questions = [];
  int _idx = 0;
  int? _selected;
  bool _revealed = false;
  int _correct = 0;
  int _wrong = 0;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    final pool = <KanjiEntry>[];
    for (var i = 0; i < widget.stage && i < widget.allStages.length; i++) {
      pool.addAll(widget.allStages[i]);
    }
    final current = List<KanjiEntry>.from(widget.allStages[widget.stage - 1])..shuffle(_rand);
    final qs = <_Q>[];
    for (final e in current) {
      final correct = e.meaning;
      final distractors = <String>[];
      final candidates = pool.where((x) => x.char != e.char).toList()..shuffle(_rand);
      for (final d in candidates) {
        final m = d.meaning;
        if (m.isEmpty || m == correct || distractors.contains(m)) continue;
        distractors.add(m);
        if (distractors.length >= 3) break;
      }
      while (distractors.length < 3) {
        distractors.add('(...)');
      }
      final options = [correct, ...distractors]..shuffle(_rand);
      qs.add(_Q(entry: e, options: options, correctIndex: options.indexOf(correct)));
    }
    setState(() => _questions = qs);
  }

  Future<void> _select(int i) async {
    if (_revealed) return;
    final q = _questions[_idx];
    final ok = i == q.correctIndex;
    setState(() {
      _selected = i;
      _revealed = true;
      if (ok) {
        _correct++;
      } else {
        _wrong++;
      }
    });
    // 훈독 우선 읽기
    final kun = q.entry.kun;
    final speakText = kun.isNotEmpty ? kun.first.reading.replaceAll(RegExp(r'[\-\(\)]'), '') : q.entry.char;
    TtsService.instance.speak(speakText);
    // 한자 진행 기록
    final prev = await (appDb.select(appDb.kanjiProgress)..where((k) => k.char.equals(q.entry.char))).getSingleOrNull();
    await appDb.into(appDb.kanjiProgress).insertOnConflictUpdate(
          KanjiProgressCompanion(
            char: Value(q.entry.char),
            known: Value(ok),
            exposureCount: Value((prev?.exposureCount ?? 0) + 1),
            lastReviewed: Value(DateTime.now()),
          ),
        );
  }

  Future<void> _next() async {
    if (_idx < _questions.length - 1) {
      setState(() {
        _idx++;
        _selected = null;
        _revealed = false;
      });
    } else {
      await _saveResult();
      if (mounted) _showResult();
    }
  }

  Future<void> _saveResult() async {
    final pct = (_correct / _questions.length * 100).round();
    final prev = await (appDb.select(appDb.stageResults)..where((s) => s.stage.equals(widget.stage))).getSingleOrNull();
    await appDb.into(appDb.stageResults).insertOnConflictUpdate(
          StageResultsCompanion(
            stage: Value(widget.stage),
            correct: Value(_correct),
            total: Value(_questions.length),
            bestPct: Value(max(pct, prev?.bestPct ?? 0)),
            lastPlayed: Value(DateTime.now()),
          ),
        );
  }

  void _showResult() {
    final pct = (_correct / _questions.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.washi,
        shape: const RoundedRectangleBorder(),
        title: Text(
          pct >= 80 ? '🎉  단계 ${widget.stage} 통과' : '단계 ${widget.stage} 완료',
          style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('정답', _correct, AppColors.matcha),
            _row('오답', _wrong, const Color(0xFFE53935)),
            const Divider(),
            Text('$pct%',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.beni)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('나가기', style: TextStyle(color: AppColors.sumiLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _idx = 0;
                _correct = 0;
                _wrong = 0;
                _selected = null;
                _revealed = false;
              });
              _build();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.beni,
              foregroundColor: AppColors.washi,
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text('다시'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, int n, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.sumi))),
          Text('$n', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('한자 단계 ${widget.stage}',
                style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            const Text('훈음 4지선다 · 누적',
                style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: _questions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : _body(),
    );
  }

  Widget _body() {
    final q = _questions[_idx];
    final total = _questions.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${_idx + 1} / $total',
                      style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, letterSpacing: 1)),
                  const Spacer(),
                  Text('✓ $_correct  ✗ $_wrong', style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.washiDeep,
                      border: Border.all(color: AppColors.kin.withValues(alpha: 0.4)),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (_idx + 1) / total,
                    child: Container(height: 6, color: AppColors.beni),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                InkWell(
                  onTap: _revealed ? () => showKanjiSheet(context, char: q.entry.char, entry: q.entry) : null,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.washi,
                      border: Border.all(color: AppColors.kin, width: 2),
                      boxShadow: [
                        BoxShadow(color: AppColors.sumi.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          q.entry.char,
                          style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w900, color: AppColors.beni, height: 1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _revealed
                              ? [
                                  if (q.entry.on.isNotEmpty) '음 ${q.entry.on.map((r) => r.reading).join('·')}',
                                  if (q.entry.kun.isNotEmpty) '훈 ${q.entry.kun.map((r) => r.reading).join('·')}',
                                ].join('   ')
                              : '훈음은?',
                          style: TextStyle(
                            fontSize: _revealed ? 12 : 11,
                            color: _revealed ? AppColors.ai : AppColors.sumiLight,
                            letterSpacing: _revealed ? 0.5 : 3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_revealed)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text('탭하면 상세', style: TextStyle(fontSize: 9, color: AppColors.sumiLight)),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: q.options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _OptionTile(
                      index: i,
                      text: q.options[i],
                      selected: _selected == i,
                      isCorrect: i == q.correctIndex,
                      revealed: _revealed,
                      onTap: () => _select(i),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _revealed ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beni,
                  foregroundColor: AppColors.washi,
                  disabledBackgroundColor: AppColors.sumiLight.withValues(alpha: 0.3),
                  shape: const RoundedRectangleBorder(),
                  elevation: 0,
                ),
                child: Text(
                  _idx == _questions.length - 1 ? '결과 보기' : '다음 →',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final bool selected;
  final bool isCorrect;
  final bool revealed;
  final VoidCallback onTap;

  const _OptionTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.isCorrect,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.washi;
    Color border = AppColors.kin.withValues(alpha: 0.5);
    Color fg = AppColors.sumi;
    IconData? icon;
    if (revealed) {
      if (isCorrect) {
        bg = AppColors.matcha;
        border = AppColors.matcha;
        fg = AppColors.washi;
        icon = Icons.check_circle;
      } else if (selected) {
        bg = const Color(0xFFE53935);
        border = const Color(0xFFE53935);
        fg = AppColors.washi;
        icon = Icons.cancel;
      }
    }
    const labels = ['A', 'B', 'C', 'D'];

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: revealed && (isCorrect || selected) ? 1.5 : 0.8),
          boxShadow: revealed && isCorrect ? [BoxShadow(color: bg.withValues(alpha: 0.4), blurRadius: 8)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: revealed && (isCorrect || selected) ? AppColors.washi : AppColors.washiDeep,
                border: Border.all(color: fg.withValues(alpha: 0.3)),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: revealed && (isCorrect || selected) ? bg : AppColors.sumi,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
            ),
            if (icon != null) Icon(icon, color: fg),
          ],
        ),
      ),
    );
  }
}
