import 'package:flutter/material.dart';
import '../models/flash_card.dart';
import '../services/deck_loader.dart';
import '../services/word_reviews.dart';
import '../services/favorite_words.dart';
import '../services/user_stats.dart';
import '../theme.dart';
import '../widgets/manga_panel.dart';
import '../widgets/app_background.dart';
import '../widgets/sketchy_divider.dart';

class SrsProgressScreen extends StatefulWidget {
  const SrsProgressScreen({super.key});

  @override
  State<SrsProgressScreen> createState() => _SrsProgressScreenState();
}

class _SrsProgressScreenState extends State<SrsProgressScreen> {
  final _reviews = WordReviews();
  final _favs = FavoriteWords();
  final _stats = UserStats();
  Map<int, int> _dist = {};
  int _learned = 0;
  int _favCount = 0;
  int _streak = 0;
  List<Deck>? _decks;
  Map<String, int> _perDeck = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dist = await _reviews.stageDistribution();
    final learned = await _reviews.learnedCount();
    final fc = await _favs.count();
    final streak = await _stats.getStreak();
    final decks = await DeckLoader.loadAll();
    final perDeck = <String, int>{};
    for (final d in decks) {
      int cnt = 0;
      for (final c in d.cards) {
        final s = await _reviews.getStage(c.id);
        if (s > 0) cnt++;
      }
      perDeck[d.id] = cnt;
    }
    if (!mounted) return;
    setState(() {
      _dist = dist;
      _learned = learned;
      _favCount = fc;
      _streak = streak;
      _decks = decks;
      _perDeck = perDeck;
    });
  }

  int get _totalCards =>
      _decks?.fold(0, (sum, d) => sum! + d.cards.length) ?? 0;
  int get _mastered =>
      (_dist[5] ?? 0) + (_dist[6] ?? 0);
  double get _overallPct =>
      _totalCards == 0 ? 0 : _learned / _totalCards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('학습 進度', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            SizedBox(height: 1),
            Text('Progress', style: TextStyle(color: AppColors.inkSoft, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: AppBackground(
        scatterSeed: _learned + 5,
        child: _decks == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.sakuraDeep,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _overallCard(),
                    const SizedBox(height: 14),
                    _statBoxRow(),
                    const SketchyDivider(caption: '今週'),
                    _weeklyRow(),
                    const SketchyDivider(caption: 'デッキ別'),
                    ..._decks!.map(_categoryBar),
                    const SketchyDivider(caption: 'SRS stage'),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text('0 = 신규 · 6 = 숙달',
                          style: TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
                    ),
                    MangaPanel(
                      padding: const EdgeInsets.all(12),
                      rotation: 0.2,
                      child: _stageBars(),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _overallCard() {
    final pctText = (_overallPct * 100).round();
    return MangaPanel(
      rotation: -0.3,
      backgroundColor: AppColors.sakuraSoft,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          Positioned(
            top: -4,
            right: -4,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.honey,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.inkOutline, width: 1),
                ),
                child: const Text('頑張れ!',
                    style: TextStyle(color: AppColors.ink, fontSize: 11, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('전체 진행률',
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    )),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$pctText',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: AppColors.sakuraDeep,
                          height: 0.9,
                        )),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text('%',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.sakuraDeep)),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('$_learned / $_totalCards 장',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _overallPct,
                    minHeight: 9,
                    backgroundColor: AppColors.paperDeep,
                    color: AppColors.sakuraDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBoxRow() {
    return Row(
      children: [
        Expanded(child: _statBox('완료', '$_mastered', '장 숙달', AppColors.cloverDeep, '完', -1)),
        const SizedBox(width: 8),
        Expanded(child: _statBox('연속', '$_streak', '일', AppColors.streak, '日', 0.5)),
        const SizedBox(width: 8),
        Expanded(child: _statBox('★', '$_favCount', '즐겨찾기', AppColors.honeyDeep, '愛', -0.5)),
      ],
    );
  }

  Widget _statBox(String label, String value, String unit, Color color, String seal, double rot) {
    return MangaPanel(
      rotation: rot,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
            ),
            child: Center(
              child: Text(seal,
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(unit,
              style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _weeklyRow() {
    // streak 기반 — 마지막 N일 채워짐 (단순 표시)
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    final filled = _streak.clamp(0, 7);
    return MangaPanel(
      rotation: -0.2,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final done = i < filled;
          return Column(
            children: [
              Text(days[i],
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
              const SizedBox(height: 6),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: done ? AppColors.sakuraDeep : AppColors.paperDeep,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done ? AppColors.sakuraDeep : AppColors.inkLight,
                    width: 1,
                  ),
                ),
                child: Icon(
                  done ? Icons.check : Icons.circle_outlined,
                  size: done ? 16 : 10,
                  color: done ? Colors.white : AppColors.inkLight,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _categoryBar(Deck d) {
    final cnt = _perDeck[d.id] ?? 0;
    final pct = d.cards.isEmpty ? 0.0 : cnt / d.cards.length;
    final color = Color(d.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(d.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(d.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ),
              Text('${(pct * 100).round()}%',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(width: 6),
              Text('$cnt / ${d.cards.length}',
                  style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: AppColors.paperDeep,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageBars() {
    final maxCount = _dist.values.isEmpty
        ? 1
        : _dist.values.fold(0, (m, v) => v > m ? v : m).clamp(1, 1 << 30);
    return Column(
      children: List.generate(7, (s) {
        final cnt = _dist[s] ?? 0;
        final width = cnt / maxCount;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                  width: 56,
                  child: Text('stage $s',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink))),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.paperDeep,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: width,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.sakuraDeep
                            .withValues(alpha: 0.35 + s * 0.09),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                  width: 32,
                  child: Text('$cnt',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink))),
            ],
          ),
        );
      }),
    );
  }
}
