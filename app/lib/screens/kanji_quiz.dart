import 'dart:math';
import 'package:flutter/material.dart';
import '../services/kanji_index.dart';
import '../services/tts.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/manga_panel.dart';
import '../widgets/pressable_scale.dart';
import 'kanji_stages.dart';

/// 한자 4지선다 퀴즈 — 현재 단계 한자 출제, 1..현재 단계 누적 풀에서 오답 선택지.
class KanjiQuizScreen extends StatefulWidget {
  final int stage; // 1-based
  const KanjiQuizScreen({super.key, required this.stage});

  @override
  State<KanjiQuizScreen> createState() => _KanjiQuizScreenState();
}

class _Q {
  final KanjiEntry entry;
  final List<String> options;
  final int correctIndex;
  const _Q({required this.entry, required this.options, required this.correctIndex});
}

class _KanjiQuizScreenState extends State<KanjiQuizScreen> {
  List<_Q>? _questions;
  int _idx = 0;
  int? _selected;
  bool _revealed = false;
  int _correct = 0;
  int _wrong = 0;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    Tts.instance.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await KanjiIndex.load();
    final stages = KanjiStagesScreen.buildStages(all);
    final si = (widget.stage - 1).clamp(0, stages.length - 1);
    // 누적 pool (오답 후보) = 단계 1..현재, 출제 = 현재 단계만
    final pool = [for (var i = 0; i <= si; i++) ...stages[i]];
    final current = List<KanjiEntry>.from(stages[si])..shuffle(_rand);

    final qs = <_Q>[];
    for (final e in current) {
      final distractors = <String>[];
      final candidates = pool.where((x) => x.char != e.char).toList()..shuffle(_rand);
      for (final d in candidates) {
        if (d.meaning == e.meaning || distractors.contains(d.meaning)) continue;
        distractors.add(d.meaning);
        if (distractors.length >= 3) break;
      }
      final options = [e.meaning, ...distractors]..shuffle(_rand);
      qs.add(_Q(entry: e, options: options, correctIndex: options.indexOf(e.meaning)));
    }
    if (!mounted) return;
    setState(() => _questions = qs);
  }

  void _select(int i) {
    if (_revealed) return;
    final q = _questions![_idx];
    setState(() {
      _selected = i;
      _revealed = true;
      if (i == q.correctIndex) {
        _correct++;
      } else {
        _wrong++;
      }
    });
    // 정답 공개 시 일본어 읽기 재생 (읽기 없으면 한자 자체)
    final e = q.entry;
    final speak = e.readings.isNotEmpty
        ? e.readings.first.reading.replaceAll(RegExp(r'[\-\(\)、]'), '')
        : e.char;
    Tts.instance.speakJa(speak);
  }

  void _next() {
    if (_idx < _questions!.length - 1) {
      setState(() {
        _idx++;
        _selected = null;
        _revealed = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final pct = (_correct / _questions!.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.inkOutline, width: 1.2),
        ),
        title: Text('🎉 단계 ${widget.stage} 완료',
            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _resultRow('정답', _correct, AppColors.success),
            _resultRow('오답', _wrong, AppColors.streak),
            const Divider(color: AppColors.inkLight),
            Text('$pct%',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.sakuraDeep)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('나가기', style: TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
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
                _questions = null;
              });
              _load();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sakuraDeep,
              foregroundColor: AppColors.paper,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('다시', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, int n, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600))),
          Text('$n', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('한자 단계 ${widget.stage}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: AppBackground(
        scatterSeed: 37,
        child: _questions == null
            ? const Center(child: CircularProgressIndicator())
            : _body(),
      ),
    );
  }

  Widget _body() {
    final q = _questions![_idx];
    final total = _questions!.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Text('${_idx + 1} / $total',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('✓ $_correct  ✗ $_wrong',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (_idx + 1) / total,
                  minHeight: 8,
                  backgroundColor: AppColors.paperDeep,
                  color: AppColors.sakuraDeep,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            children: [
              MangaPanel(
                rotation: -0.3,
                backgroundColor: AppColors.cardFront,
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Column(
                  children: [
                    Text(q.entry.char,
                        style: const TextStyle(
                            fontSize: 88, fontWeight: FontWeight.w900, color: AppColors.ink, height: 1)),
                    const SizedBox(height: 6),
                    const Text('뜻은?',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.inkLight,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(q.options.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _OptionTile(
                    index: i,
                    text: q.options[i],
                    selected: _selected == i,
                    isCorrect: i == q.correctIndex,
                    revealed: _revealed,
                    onTap: () => _select(i),
                  ),
                );
              }),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
            child: SizedBox(
              width: double.infinity,
              child: PressableScale(
                onTap: _revealed ? _next : null,
                child: MangaPanel(
                  backgroundColor: _revealed ? AppColors.ink : AppColors.inkLight,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Center(
                    child: Text(
                      _idx == total - 1 ? '결과 보기' : '다음 →',
                      style: const TextStyle(color: AppColors.paper, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
    Color bg = AppColors.cardFront;
    Color fg = AppColors.ink;
    IconData? icon;
    if (revealed) {
      if (isCorrect) {
        bg = AppColors.cloverSoft;
        icon = Icons.check_circle_rounded;
      } else if (selected) {
        bg = AppColors.sakuraSoft;
        icon = Icons.cancel_rounded;
      }
    }
    const labels = ['A', 'B', 'C', 'D'];
    return PressableScale(
      onTap: onTap,
      child: MangaPanel(
        rotation: 0,
        backgroundColor: bg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.paperDeep,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.inkOutline, width: 0.8),
              ),
              child: Text(labels[index],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.ink)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
            ),
            if (icon != null)
              Icon(icon, color: isCorrect ? AppColors.success : AppColors.streak, size: 22),
          ],
        ),
      ),
    );
  }
}
