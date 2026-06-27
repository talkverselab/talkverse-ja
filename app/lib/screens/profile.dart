import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/flash_card.dart';
import '../services/deck_loader.dart';
import '../services/user_profile.dart';
import '../services/user_stats.dart';
import '../services/word_reviews.dart';
import '../services/favorite_words.dart';
import '../theme.dart';
import '../widgets/talky_mascot.dart';
import '../widgets/streak_chip.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/manga_panel.dart';
import '../widgets/polaroid_frame.dart';
import '../widgets/app_background.dart';
import '../widgets/sketchy_divider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profile = UserProfile();
  final _stats = UserStats();
  final _reviews = WordReviews();
  final _favs = FavoriteWords();

  String _name = '익명 학습자';
  DateTime? _startDate;
  int _daysSince = 1;
  int _streak = 0;
  int _today = 0;
  int _goal = 10;
  int _learned = 0;
  int _due = 0;
  int _favCount = 0;
  List<Deck>? _decks;
  Map<String, int> _perDeck = {};
  Map<int, int> _stageDist = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _profile.getName();
    final start = await _profile.getStartDate();
    final days = await _profile.daysSinceStart();
    final streak = await _stats.getStreak();
    final today = await _stats.getToday();
    final goal = await _stats.getGoal();
    final learned = await _reviews.learnedCount();
    final due = await _reviews.reviewDueCount();
    final favCount = await _favs.count();
    final decks = await DeckLoader.loadAll();
    final perDeck = <String, int>{};
    for (final deck in decks) {
      int cnt = 0;
      for (final c in deck.cards) {
        final s = await _reviews.getStage(c.id);
        if (s > 0) cnt++;
      }
      perDeck[deck.id] = cnt;
    }
    final stageDist = await _reviews.stageDistribution();
    if (!mounted) return;
    setState(() {
      _name = name;
      _startDate = start;
      _daysSince = days;
      _streak = streak;
      _today = today;
      _goal = goal;
      _learned = learned;
      _due = due;
      _favCount = favCount;
      _decks = decks;
      _perDeck = perDeck;
      _stageDist = stageDist;
    });
  }

  TalkyMood _mood() {
    if (_streak >= 7) return TalkyMood.happy;
    if (_today >= _goal) return TalkyMood.encouraging;
    if (_learned >= 50) return TalkyMood.wave;
    if (_learned == 0) return TalkyMood.sleep;
    return TalkyMood.idle;
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name);
    final newName = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.ink, width: 2.5),
        ),
        title: const Text('이름 변경', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(hintText: '예: 민준 / さくら'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('취소', style: TextStyle(color: AppColors.inkSoft))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            onPressed: () => Navigator.pop(c, controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await _profile.setName(newName);
      _load();
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  int _mastered() => (_stageDist[5] ?? 0) + (_stageDist[6] ?? 0);

  int _totalCards() => _decks?.fold(0, (sum, d) => sum! + d.cards.length) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '앱 소개',
            onPressed: () => context.push('/about'),
          ),
        ],
      ),
      body: AppBackground(
        scatterSeed: _daysSince + 3,
        child: _decks == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.sakuraDeep,
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    _header(),
                    const SketchyDivider(caption: '今日'),
                    _todayCard(),
                    const SizedBox(height: 18),
                    _polaroidStats(),
                    const SketchyDivider(caption: '4 デッキ'),
                    ..._decks!.asMap().entries.map((e) => _deckProgress(e.value, e.key)),
                    const SketchyDivider(caption: '設定'),
                    _settingPanel(),
                    const SizedBox(height: 16),
                    _navRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _header() {
    return MangaPanel(
      backgroundColor: AppColors.sakuraSoft,
      rotation: -0.5,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          TalkyMascot(mood: _mood(), size: 80, showHalo: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    PressableScale(
                      onTap: _editName,
                      child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.inkSoft),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.honey,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.inkOutline, width: 0.8),
                  ),
                  child: Text('学習 $_daysSince 日目',
                      style: const TextStyle(fontSize: 12, color: AppColors.ink, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                if (_startDate != null)
                  Text('${_fmtDate(_startDate!)} から',
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayCard() {
    final pct = _goal == 0 ? 0.0 : (_today / _goal).clamp(0.0, 1.0);
    return MangaPanel(
      rotation: 0.4,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('今日',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.inkSoft, letterSpacing: 1.2)),
              StreakChip(streak: _streak),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$_today',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.sakuraDeep, height: 1)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('/ $_goal 장',
                    style: const TextStyle(fontSize: 14, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              if (_due > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.honeySoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.inkOutline, width: 0.8),
                  ),
                  child: Text('復習 $_due',
                      style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 9,
              backgroundColor: AppColors.paperDeep,
              color: AppColors.sakuraDeep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _polaroidStats() {
    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PolaroidFrame(
            rotation: -1.8,
            caption: '학습 $_learned/${_totalCards()}',
            photo: const Text('📚', style: TextStyle(fontSize: 52)),
          ),
          PolaroidFrame(
            rotation: 1.2,
            caption: '즐겨찾기 $_favCount',
            photo: const Text('⭐', style: TextStyle(fontSize: 52)),
          ),
          PolaroidFrame(
            rotation: -0.4,
            caption: '숙달 ${_mastered()}',
            photo: const Text('🌸', style: TextStyle(fontSize: 52)),
          ),
        ],
      ),
    );
  }

  Widget _deckProgress(Deck d, int idx) {
    final lp = _perDeck[d.id] ?? 0;
    final pct = d.cards.isEmpty ? 0.0 : lp / d.cards.length;
    final tilts = [-0.8, 0.5, -0.4, 0.7];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MangaPanel(
        rotation: tilts[idx % tilts.length],
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Color(d.color).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.ink, width: 1.8),
              ),
              child: Center(child: Text(d.icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(d.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink))),
                      Text('$lp / ${d.cards.length}',
                          style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      backgroundColor: AppColors.paperDeep,
                      color: Color(d.color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingPanel() {
    return MangaPanel(
      padding: const EdgeInsets.all(14),
      rotation: -0.3,
      child: Column(
        children: [
          _settingRow('하루 목표', '$_goal 장 / 일', Icons.flag_outlined),
          const Divider(color: AppColors.inkLight, thickness: 0.8, height: 16),
          _settingRow('시작일', _startDate != null ? _fmtDate(_startDate!) : '-', Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _settingRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.inkSoft),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
      ],
    );
  }

  Widget _navRow() {
    return Row(
      children: [
        Expanded(
          child: PressableScale(
            onTap: () => context.push('/settings').then((_) => _load()),
            child: MangaPanel(
              rotation: -0.4,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Column(
                children: [
                  Icon(Icons.settings_outlined, size: 22, color: AppColors.ink),
                  SizedBox(height: 4),
                  Text('설정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PressableScale(
            onTap: () => context.push('/about'),
            child: MangaPanel(
              rotation: 0.4,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, size: 22, color: AppColors.ink),
                  SizedBox(height: 4),
                  Text('앱 소개', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ink)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
