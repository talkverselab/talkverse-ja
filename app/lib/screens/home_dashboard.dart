import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/flash_card.dart';
import '../services/deck_loader.dart';
import '../services/user_stats.dart';
import '../services/word_reviews.dart';
import '../theme.dart';
import '../widgets/talky_mascot.dart';
import '../widgets/floating_talky.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/streak_chip.dart';
import '../widgets/manga_panel.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/app_background.dart';
import '../widgets/sketchy_divider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _stats = UserStats();
  final _reviews = WordReviews();
  List<Deck>? _decks;
  int _streak = 0;
  int _today = 0;
  int _goal = 10;
  int _learned = 0;
  int _due = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final decks = await DeckLoader.loadAll();
    final streak = await _stats.getStreak();
    final today = await _stats.getToday();
    final goal = await _stats.getGoal();
    final learned = await _reviews.learnedCount();
    final due = await _reviews.reviewDueCount();
    if (!mounted) return;
    setState(() {
      _decks = decks;
      _streak = streak;
      _today = today;
      _goal = goal;
      _learned = learned;
      _due = due;
    });
  }

  TalkyMood _mood() {
    if (_today >= _goal) return TalkyMood.happy;
    if (_due > 5) return TalkyMood.encouraging;
    if (_streak >= 3) return TalkyMood.wave;
    return TalkyMood.idle;
  }

  String _talkyHook() {
    if (_today == 0 && _streak == 0) return 'よろしくね!오늘 10장으로 시작해볼까?';
    if (_today >= _goal) return 'やったね!오늘 목표 달성, 보너스 5장 어때?';
    if (_due > 5) return '복습 카드 ${_due}장 쌓였어. 먼저 정리하자!';
    if (_streak >= 7) return '$_streak일 연속! 정말 대단해 🔥';
    return '오늘은 ね 종조사 배워볼까? 가볍게 10장.';
  }

  String _recommendDeck() {
    if (_learned < 10) return 'native';
    if (_learned < 30) return 'r1';
    if (_learned < 50) return 'kanji';
    return 'l1_turn';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🌸  ', style: TextStyle(fontSize: 16)),
            Text('일본어 ユニバース', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.4)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: '프로필',
            onPressed: () => context.push('/profile').then((_) => _load()),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
            onPressed: () => context.push('/settings').then((_) => _load()),
          ),
        ],
      ),
      body: AppBackground(
        scatterSeed: _streak + 7,
        child: _decks == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.sakuraDeep,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                      children: [
                        _talkySection(),
                        const SizedBox(height: 18),
                        _statsRow(),
                        const SketchyDivider(caption: '✿'),
                        _recommendedCta(),
                        const SketchyDivider(caption: '4 デッキ', height: 36),
                        ..._decks!.asMap().entries.map((e) => _deckCard(e.value, e.key)),
                        const SizedBox(height: 16),
                        _shortcutsRow(),
                      ],
                    ),
                  ),
                  // 떠다니는 TalkY — 우하단 기본, 드래그로 어디든 이동
                  FloatingTalky(
                    mood: _mood(),
                    size: 86,
                    initialOffset: Offset.zero, // LayoutBuilder 기본값(우하단) 사용
                    onTap: () {
                      final rid = _recommendDeck();
                      context.push('/session/$rid').then((_) => _load());
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _talkySection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TalkyMascot(mood: _mood(), size: 70),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SpeechBubble(
            color: AppColors.cardFront,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('글로비',
                    style: TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text(_talkyHook(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.45, color: AppColors.ink)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statsRow() {
    final pct = _goal == 0 ? 0.0 : (_today / _goal).clamp(0.0, 1.0);
    return MangaPanel(
      backgroundColor: AppColors.paperDeep,
      rotation: -0.3,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          StreakChip(streak: _streak),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('오늘 $_today / $_goal 장',
                        style: const TextStyle(fontSize: 13, color: AppColors.ink, fontWeight: FontWeight.w800)),
                    if (_due > 0)
                      Text('복습 $_due',
                          style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
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

  Widget _recommendedCta() {
    final rid = _recommendDeck();
    final rdeck = _decks!.firstWhere((d) => d.id == rid);
    final color = Color(rdeck.color);
    return MangaPanel(
      backgroundColor: color.withValues(alpha: 0.18),
      rotation: 0.3,
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/session/$rid').then((_) => _load()),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inkOutline, width: 1.0),
            ),
            child: Center(child: Text(rdeck.icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('오늘의 추천',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 2),
                Text(rdeck.name,
                    style: const TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('10장 세션 · ${rdeck.cards.length}장 중',
                    style: const TextStyle(color: AppColors.inkSoft, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: AppColors.paper, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _deckCard(Deck d, int idx) {
    final unlocked = _learned >= d.unlockThreshold;
    final tilts = [-0.4, 0.4, -0.2, 0.2];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: PressableScale(
        onTap: unlocked ? () => context.push('/session/${d.id}').then((_) => _load()) : null,
        child: Opacity(
          opacity: unlocked ? 1.0 : 0.55,
          child: MangaPanel(
            rotation: tilts[idx % tilts.length],
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(d.color).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.inkOutline, width: 1.0),
                  ),
                  child: Center(child: Text(d.icon, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
                          if (!unlocked) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.lock_outline, size: 14, color: AppColors.inkSoft),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unlocked ? d.subtitle : '🔒 $_learned/${d.unlockThreshold} 학습 시 unlock',
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Text('${d.cards.length}',
                    style: const TextStyle(fontSize: 14, color: AppColors.inkLight, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shortcutsRow() {
    return Row(
      children: [
        Expanded(child: _shortcut(Icons.bar_chart_rounded, '진도', '/progress')),
        const SizedBox(width: 10),
        Expanded(child: _shortcut(Icons.translate, 'かな', '/kana')),
        const SizedBox(width: 10),
        Expanded(child: _shortcut(Icons.grid_view_rounded, '전체 덱', '/decks')),
      ],
    );
  }

  Widget _shortcut(IconData icon, String label, String route) {
    return PressableScale(
      onTap: () => context.push(route).then((_) => _load()),
      child: MangaPanel(
        padding: const EdgeInsets.symmetric(vertical: 14),
        rotation: 0,
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.ink),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}
