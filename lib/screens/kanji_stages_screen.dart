import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../main.dart';
import '../services/kanji_index_service.dart';
import '../widgets/japanese_decor.dart';
import 'kanji_quiz_screen.dart';

/// 한자 단계 목록 — JLPT N5→N1 순, 레벨 안 회화 빈도순 20자 × N단계. 단계 탭 → 누적 4지선다 퀴즈.
class KanjiStagesScreen extends StatefulWidget {
  const KanjiStagesScreen({super.key});

  @override
  State<KanjiStagesScreen> createState() => _KanjiStagesScreenState();
}

class _KanjiStagesScreenState extends State<KanjiStagesScreen> {
  List<KanjiStage>? _stages;
  bool _byFreq = true; // 디폴트: 회화 빈도순 (절벽구간 진행)
  Map<int, int> _best = {}; // stage → bestPct
  int? _levelFilter; // null=전체, 5..1, 0=기타

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
      _stages = _byFreq
          ? KanjiIndexService.instance.stagesByFreq()
          : KanjiIndexService.instance.stages();
      _best = {for (final r in results) r.stage: r.bestPct};
      // 빈도순 모드 기록은 +500 오프셋 키에 저장된다
    });
  }

  static Color levelColor(int? level) => switch (level) {
        5 => AppColors.matcha,
        4 => AppColors.ai,
        3 => AppColors.kinDeep,
        2 => AppColors.beniLight,
        1 => AppColors.beniDeep,
        _ => AppColors.sumiLight,
      };

  @override
  Widget build(BuildContext context) {
    final stages = _stages;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('한자 단계 · JLPT',
                style: TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text(
                '${_byFreq ? '회화 빈도순(절벽 R1→R4)' : 'N5→N1'} · ${KanjiIndexService.stageSize}자 × ${stages?.length ?? '-'}단계 · 4지선다 (누적)',
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: stages == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : _body(stages),
    );
  }

  Widget _body(List<KanjiStage> stages) {
    final total = stages.fold<int>(0, (n, s) => n + s.chars.length);
    final done = _best.values.where((p) => p >= 80).length;
    final visible = _levelFilter == null
        ? stages
        : stages.where((s) => _levelFilter == 0 ? s.level == null : s.level == _levelFilter).toList();
    return Column(
      children: [
        Container(
          color: AppColors.washiDeep,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final freq in [true, false])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (_byFreq == freq) return;
                        setState(() {
                          _byFreq = freq;
                          _levelFilter = null;
                        });
                        _load();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _byFreq == freq ? AppColors.beni : AppColors.washi,
                          border: Border.all(color: AppColors.beni, width: _byFreq == freq ? 1.5 : 0.8),
                        ),
                        child: Text(
                          freq ? '빈도순' : 'JLPT순',
                          style: TextStyle(
                            color: _byFreq == freq ? AppColors.washi : AppColors.beni,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!_byFreq)
                  for (final lv in [null, 5, 4, 3, 2, 1, 0])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _levelChip(lv, stages),
                    ),
              ],
            ),
          ),
        ),
        const AsanohaDivider(height: 8),
        Expanded(
          child: ListView(
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
                          const Text('JLPT 한자 + 회화 빈도',
                              style: TextStyle(color: AppColors.kinBright, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 3)),
                          const SizedBox(height: 4),
                          Text('N5 ${KanjiIndexService.instance.forLevel(5).length} · N4 ${KanjiIndexService.instance.forLevel(4).length} · N3 ${KanjiIndexService.instance.forLevel(3).length} · N2 ${KanjiIndexService.instance.forLevel(2).length} · N1 ${KanjiIndexService.instance.forLevel(1).length}',
                              style: const TextStyle(color: AppColors.washi, fontSize: 14, fontWeight: FontWeight.w900, height: 1.2)),
                          const SizedBox(height: 4),
                          Text('누적 4지선다 — 훈음 맞추기 · 80% 이상 통과 $done/${stages.length}',
                              style: TextStyle(color: AppColors.washi.withValues(alpha: 0.9), fontSize: 11, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ..._withHeaders(visible, stages),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _levelChip(int? lv, List<KanjiStage> stages) {
    final selected = _levelFilter == lv;
    final label = lv == null ? '전체' : (lv == 0 ? '기타' : 'N$lv');
    final color = lv == null ? AppColors.sumi : levelColor(lv == 0 ? null : lv);
    return GestureDetector(
      onTap: () => setState(() => _levelFilter = lv),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.washi,
          border: Border.all(color: color, width: selected ? 1.5 : 0.8),
        ),
        child: Text(label,
            style: TextStyle(color: selected ? AppColors.washi : color, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }

  static const _regionNames = {
    'R1': 'R1 · 회화 1-294 절벽',
    'R2': 'R2 · 295-437',
    'R3': 'R3 · 438-998',
    'R4': 'R4 · 999-',
  };
  static const _regionColors = {
    'R1': AppColors.beni,
    'R2': AppColors.beniLight,
    'R3': AppColors.kin,
    'R4': AppColors.matcha,
  };

  int get _keyOffset => _byFreq ? 500 : 0;

  List<Widget> _withHeaders(List<KanjiStage> visible, List<KanjiStage> all) {
    if (_byFreq) return _withFreqHeaders(visible, all);
    final out = <Widget>[];
    int? last = -1;
    for (final s in visible) {
      if (s.level != last) {
        last = s.level;
        final count = all.where((x) => x.level == s.level).length;
        final passed = all.where((x) => x.level == s.level && (_best[x.stage] ?? 0) >= 80).length;
        out.add(Padding(
          padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
          child: Row(
            children: [
              SealStamp(text: s.levelLabel, size: 24, color: levelColor(s.level)),
              const SizedBox(width: 8),
              Text(
                s.level == null ? '기타 (JLPT 밖 회화 한자)' : 'JLPT N${s.level}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1.2),
              ),
              const Spacer(),
              Text('$passed/$count 단계 통과', style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
            ],
          ),
        ));
      }
      out.add(_StageRow(
        stage: s,
        bestPct: _best[s.stage],
        color: levelColor(s.level),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiQuizScreen(stage: s.stage, allStages: all)));
          _load();
        },
      ));
    }
    return out;
  }

  List<Widget> _withFreqHeaders(List<KanjiStage> visible, List<KanjiStage> all) {
    final out = <Widget>[];
    String? last;
    for (final s in visible) {
      final region = s.freqLabel ?? 'R4';
      if (region != last) {
        last = region;
        final count = all.where((x) => x.freqLabel == region).length;
        final passed =
            all.where((x) => x.freqLabel == region && (_best[x.stage + _keyOffset] ?? 0) >= 80).length;
        final color = _regionColors[region] ?? AppColors.sumi;
        out.add(Padding(
          padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
          child: Row(
            children: [
              SealStamp(text: region, size: 24, color: color),
              const SizedBox(width: 8),
              Text(
                _regionNames[region] ?? region,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1.2),
              ),
              const Spacer(),
              Text('$passed/$count 단계 통과',
                  style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
            ],
          ),
        ));
      }
      out.add(_StageRow(
        stage: s,
        bestPct: _best[s.stage + _keyOffset],
        color: _regionColors[s.freqLabel] ?? AppColors.sumiLight,
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => KanjiQuizScreen(
                      stage: s.stage, allStages: all, resultOffset: _keyOffset)));
          _load();
        },
      ));
    }
    return out;
  }
}

class _StageRow extends StatelessWidget {
  final KanjiStage stage;
  final int? bestPct;
  final Color color;
  final VoidCallback onTap;

  const _StageRow({required this.stage, required this.bestPct, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chars = stage.chars;
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
            boxShadow: [BoxShadow(color: AppColors.sumi.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(1, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  color: passed ? AppColors.matcha : color,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${stage.stage}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.washi, height: 1)),
                      Text('${stage.levelLabel}-${stage.indexInLevel}',
                          style: const TextStyle(fontSize: 9, color: AppColors.washi, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('단계 ${stage.stage}',
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
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: passed ? AppColors.matcha : AppColors.beni)),
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
