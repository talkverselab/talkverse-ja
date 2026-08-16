import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../main.dart';
import '../services/kanji_index_service.dart';
import '../widgets/japanese_decor.dart';

/// 학습 진행 — Turns/UserProgress 실데이터 기반.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _LevelStat {
  final String level;
  final int learned;
  final int total;
  _LevelStat(this.level, this.learned, this.total);
  double get pct => total == 0 ? 0 : learned / total;
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _loading = true;
  int _learnedTotal = 0;
  int _turnsTotal = 0;
  int _doneEpisodes = 0;
  int _streakDays = 0;
  List<bool> _weekActive = List.filled(7, false);
  List<_LevelStat> _levels = [];
  int _stagesPassed = 0;
  int _stagesTotal = 0;
  int _kanjiKnown = 0;
  int _kanjiSeen = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final turns = await appDb.select(appDb.turns).get();
    final progress = await appDb.select(appDb.userProgress).get();
    final learnedIds =
        progress.where((p) => p.learned).map((p) => p.turnId).toSet();

    // 레벨별 통계
    final levels = <_LevelStat>[];
    for (final lv in ['L1', 'L2', 'L3']) {
      final lvTurns = turns.where((t) => t.level == lv).toList();
      final learned =
          lvTurns.where((t) => learnedIds.contains(t.id)).length;
      levels.add(_LevelStat(lv, learned, lvTurns.length));
    }

    // 완료 에피소드 수 (레벨 무관, episodeId 기준 전부 학습되면 완료)
    final byEp = <String, List<int>>{};
    for (final t in turns) {
      byEp.putIfAbsent('${t.level}/${t.episodeId}', () => []).add(t.id);
    }
    final doneEps = byEp.values
        .where((ids) => ids.isNotEmpty && ids.every(learnedIds.contains))
        .length;

    // 활동 날짜 (lastReviewed 기준) → 연속 학습·주간
    final activeDates = progress
        .where((p) => p.lastReviewed != null)
        .map((p) {
          final d = p.lastReviewed!;
          return DateTime(d.year, d.month, d.day);
        })
        .toSet();
    final earlyStages = await appDb.select(appDb.stageResults).get();
    for (final r in earlyStages) {
      final d = r.lastPlayed;
      if (d != null) activeDates.add(DateTime(d.year, d.month, d.day));
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var streak = 0;
    var cursor = todayDate;
    while (activeDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    // 이번 주 (월요일 시작)
    final monday = todayDate.subtract(Duration(days: todayDate.weekday - 1));
    final week = List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return activeDates.contains(d);
    });

    // 한자 단계·진행
    await KanjiIndexService.instance.ensureLoaded();
    final stageRows = await appDb.select(appDb.stageResults).get();
    final kanjiRows = await appDb.select(appDb.kanjiProgress).get();

    if (!mounted) return;
    setState(() {
      _stagesTotal = KanjiIndexService.instance.stages().length;
      _stagesPassed = stageRows.where((r) => r.bestPct >= 80).length;
      _kanjiSeen = kanjiRows.length;
      _kanjiKnown = kanjiRows.where((k) => k.known).length;
      _turnsTotal = turns.length;
      _learnedTotal = turns.where((t) => learnedIds.contains(t.id)).length;
      _doneEpisodes = doneEps;
      _streakDays = streak;
      _weekActive = week;
      _levels = levels;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        backgroundColor: AppColors.washi,
        foregroundColor: AppColors.sumi,
        elevation: 0,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('학습 진행', style: TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 16)),
            SizedBox(height: 2),
            Text('Progress', style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.sumi),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OverallCard(
                  percent: _turnsTotal == 0 ? 0 : _learnedTotal / _turnsTotal,
                  learned: _learnedTotal,
                  total: _turnsTotal,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _StatBox(
                            label: '완료 에피소드',
                            value: '$_doneEpisodes',
                            seal: '完')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatBox(
                            label: '학습한 문장',
                            value: '$_learnedTotal',
                            seal: '句')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _StatBox(
                            label: '연속 학습',
                            value: '$_streakDays일',
                            seal: '日')),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const SealStamp(text: '周', size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '이번 주 학습',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sumi,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _WeeklyRow(active: _weekActive),
                const SizedBox(height: 18),
                const BrushDivider(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const SealStamp(text: '册', size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '레벨별 회화 진행',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sumi,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._levels.map((s) => _CategoryBar(
                      label:
                          '${s.level} 스토리 (${s.learned}/${s.total})',
                      percent: s.pct,
                      color: switch (s.level) {
                        'L1' => AppColors.beni,
                        'L2' => AppColors.ai,
                        _ => AppColors.kinDeep,
                      },
                    )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SealStamp(text: '漢', size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '한자 단계 퀴즈',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sumi,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _CategoryBar(
                  label: '통과 단계 (80%↑) $_stagesPassed/$_stagesTotal',
                  percent: _stagesTotal == 0 ? 0 : _stagesPassed / _stagesTotal,
                  color: AppColors.ai,
                ),
                _CategoryBar(
                  label: '맞힌 한자 $_kanjiKnown/$_kanjiSeen (노출 기준)',
                  percent: _kanjiSeen == 0 ? 0 : _kanjiKnown / _kanjiSeen,
                  color: AppColors.matcha,
                ),
              ],
            ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  final double percent;
  final int learned;
  final int total;
  const _OverallCard(
      {required this.percent, required this.learned, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.beniDeep, AppColors.beni],
        ),
        border: Border.all(color: AppColors.kin, width: 1.5),
      ),
      child: Stack(
        children: [
          const Positioned(top: -4, right: -4, child: SealStamp(text: '頑張', size: 50, color: AppColors.sumi)),
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '회화 전체 진행률 · $learned/$total문장',
                  style: TextStyle(
                    color: AppColors.kinBright,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(percent * 100).round()}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.washi,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.washi.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.washi.withValues(alpha: 0.25),
                        border: Border.all(color: AppColors.kin.withValues(alpha: 0.4)),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percent.clamp(0.0, 1.0),
                      child: Container(height: 8, color: AppColors.kinBright),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String seal;
  const _StatBox({required this.label, required this.value, required this.seal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.washi,
        border: Border.all(color: AppColors.kin.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          SealStamp(text: seal, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.beni,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.sumiLight,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeeklyRow extends StatelessWidget {
  final List<bool> active;
  const _WeeklyRow({required this.active});

  static const _days = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.washiDeep,
        border: Border.all(color: AppColors.kin.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: List.generate(7, (i) {
          final done = active[i];
          return Expanded(
            child: Column(
              children: [
                Text(
                  _days[i],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.sumiLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: done ? AppColors.beni : AppColors.washi,
                    border: Border.all(
                      color: done ? AppColors.beniDeep : AppColors.kin.withValues(alpha: 0.5),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    done ? Icons.check : Icons.circle_outlined,
                    size: done ? 18 : 12,
                    color: done ? AppColors.washi : AppColors.sumiLight.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _CategoryBar({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sumi,
                  ),
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.washiDeep,
                  border: Border.all(color: AppColors.kin.withValues(alpha: 0.3)),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(height: 7, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
