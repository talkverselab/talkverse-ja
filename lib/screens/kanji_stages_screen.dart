import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../main.dart';
import '../services/kanji_index_service.dart';
import '../widgets/japanese_decor.dart';
import 'kanji_quiz_screen.dart';

/// 한자 단계 목록 — 빈도순 20자 × N단계. 단계 탭 → 누적 4지선다 퀴즈.
class KanjiStagesScreen extends StatefulWidget {
  const KanjiStagesScreen({super.key});

  @override
  State<KanjiStagesScreen> createState() => _KanjiStagesScreenState();
}

class _KanjiStagesScreenState extends State<KanjiStagesScreen> {
  List<List<KanjiEntry>>? _stages;
  Map<int, int> _best = {}; // stage → bestPct

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await KanjiIndexService.instance.ensureLoaded();
    final results = await appDb.select(appDb.stageResults).get();
    if (!mounted) return;
    setState(() {
      _stages = KanjiIndexService.instance.stages();
      _best = {for (final r in results) r.stage: r.bestPct};
    });
  }

  @override
  Widget build(BuildContext context) {
    final stages = _stages;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('회화 한자 코어',
                style: TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${KanjiIndexService.stageSize}자 × ${stages?.length ?? '-'}단계 · 4지선다 (누적)',
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: stages == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : _body(stages),
    );
  }

  Widget _body(List<List<KanjiEntry>> stages) {
    final total = stages.fold<int>(0, (n, s) => n + s.length);
    final done = _best.values.where((p) => p >= 80).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.beniDeep, AppColors.beni]),
            border: Border.all(color: AppColors.kin, width: 1.2),
          ),
          child: Row(
            children: [
              SealStamp(text: '$total', size: 56, color: AppColors.sumi),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '회화 자막 가중 빈도순',
                      style: TextStyle(color: AppColors.kinBright, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${KanjiIndexService.stageSize}자 × ${stages.length}단계',
                      style: const TextStyle(color: AppColors.washi, fontSize: 22, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '누적 4지선다 — 훈음 맞추기 · 80% 이상 통과 $done/${stages.length}',
                      style: TextStyle(color: AppColors.washi.withValues(alpha: 0.9), fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(stages.length, (i) => _StageRow(
              stage: i + 1,
              chars: stages[i],
              bestPct: _best[i + 1],
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KanjiQuizScreen(stage: i + 1, allStages: stages)),
                );
                _load();
              },
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  final int stage;
  final List<KanjiEntry> chars;
  final int? bestPct;
  final VoidCallback onTap;

  const _StageRow({required this.stage, required this.chars, required this.bestPct, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final preview = chars.take(8).map((c) => c.char).join(' ');
    final passed = (bestPct ?? 0) >= 80;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.washi,
            border: Border.all(color: passed ? AppColors.matcha : AppColors.kin.withValues(alpha: 0.5), width: passed ? 1.4 : 0.8),
            boxShadow: [
              BoxShadow(color: AppColors.sumi.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(1, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  color: passed ? AppColors.matcha : AppColors.beni,
                  child: Text('$stage',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.washi)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('단계 $stage',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            color: AppColors.kin.withValues(alpha: 0.2),
                            child: Text('${chars.length}자',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                          ),
                          if (bestPct != null) ...[
                            const SizedBox(width: 6),
                            Text('최고 $bestPct%',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: passed ? AppColors.matcha : AppColors.beni)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('$preview …',
                          style: const TextStyle(fontSize: 16, color: AppColors.sumi, height: 1.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(passed ? Icons.check_circle : Icons.quiz, color: passed ? AppColors.matcha : AppColors.beni),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
