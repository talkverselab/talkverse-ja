import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/kanji_index.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/manga_panel.dart';
import '../widgets/pressable_scale.dart';

/// 한자 퀴즈 단계 목록 — 뜻이 있는 코어 한자를 빈도순 20자 단위 단계로 나눔.
/// 단계 탭 → 누적 4지선다 퀴즈 (KanjiQuizScreen).
class KanjiStagesScreen extends StatefulWidget {
  const KanjiStagesScreen({super.key});

  static const stageSize = 20;

  /// 뜻 있는 항목만 빈도순 → 20자 단위 단계 분할.
  static List<List<KanjiEntry>> buildStages(List<KanjiEntry> all) {
    final pool = all.where((e) => e.meaning.isNotEmpty).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    final stages = <List<KanjiEntry>>[];
    for (var i = 0; i < pool.length; i += stageSize) {
      stages.add(pool.sublist(i, (i + stageSize).clamp(0, pool.length)));
    }
    return stages;
  }

  @override
  State<KanjiStagesScreen> createState() => _KanjiStagesScreenState();
}

class _KanjiStagesScreenState extends State<KanjiStagesScreen> {
  List<List<KanjiEntry>>? _stages;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await KanjiIndex.load();
    if (!mounted) return;
    setState(() => _stages = KanjiStagesScreen.buildStages(all));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('漢字クイズ', style: TextStyle(fontWeight: FontWeight.w700))),
      body: AppBackground(
        scatterSeed: 31,
        child: _stages == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _headerPanel(),
                  const SizedBox(height: 14),
                  ...List.generate(_stages!.length, (i) => _stageRow(i)),
                ],
              ),
      ),
    );
  }

  Widget _headerPanel() {
    final total = _stages!.fold<int>(0, (n, s) => n + s.length);
    return MangaPanel(
      rotation: -0.3,
      backgroundColor: AppColors.sakuraSoft,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.deckKanji,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inkOutline, width: 1.0),
            ),
            child: const Center(child: Text('漢', style: TextStyle(fontSize: 26, color: AppColors.paper))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('한자 코어 퀴즈',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text('${KanjiStagesScreen.stageSize}자 × ${_stages!.length}단계 · 누적 4지선다 — 총 $total자',
                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageRow(int i) {
    final chars = _stages![i];
    final preview = chars.take(8).map((e) => e.char).join(' ');
    final tilts = [-0.4, 0.3, -0.2, 0.4];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PressableScale(
        onTap: () => context.push('/kanji-quiz/${i + 1}'),
        child: MangaPanel(
          rotation: tilts[i % tilts.length],
          backgroundColor: AppColors.cardFront,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.honey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inkOutline, width: 0.8),
                ),
                child: Text('${i + 1}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('단계 ${i + 1} · ${chars.length}자',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 3),
                    Text('$preview …',
                        style: const TextStyle(fontSize: 15, color: AppColors.inkSoft, height: 1.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.quiz_rounded, color: AppColors.sakuraDeep),
            ],
          ),
        ),
      ),
    );
  }
}
