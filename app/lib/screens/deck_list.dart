import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/flash_card.dart';
import '../services/deck_loader.dart';
import '../services/word_reviews.dart';
import '../theme.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/manga_panel.dart';
import '../widgets/app_background.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  final _reviews = WordReviews();
  List<Deck>? _decks;
  int _learned = 0;
  Map<String, int> _learnedPerDeck = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final decks = await DeckLoader.loadAll();
    final learned = await _reviews.learnedCount();
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
      _decks = decks;
      _learned = learned;
      _learnedPerDeck = perDeck;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('デッキ', style: TextStyle(fontWeight: FontWeight.w700))),
      body: AppBackground(
        scatterSeed: 11,
        child: _decks == null
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: _decks!.length,
                itemBuilder: (c, i) {
                  final d = _decks![i];
                  final unlocked = _learned >= d.unlockThreshold;
                  final lp = _learnedPerDeck[d.id] ?? 0;
                  final pct = d.cards.isEmpty ? 0.0 : lp / d.cards.length;
                  final tilts = [-0.5, 0.3, -0.2, 0.4];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PressableScale(
                      onTap: unlocked ? () => context.push('/session/${d.id}').then((_) => _load()) : null,
                      child: Opacity(
                        opacity: unlocked ? 1.0 : 0.55,
                        child: MangaPanel(
                          rotation: tilts[i % tilts.length],
                          backgroundColor: Color(d.color).withValues(alpha: 0.10),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Color(d.color),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.inkOutline, width: 1.0),
                                    ),
                                    child: Center(child: Text(d.icon, style: const TextStyle(fontSize: 26))),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(d.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                            if (!unlocked) ...[
                                              const SizedBox(width: 8),
                                              const Icon(Icons.lock, size: 16, color: AppColors.inkSoft),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(d.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 8,
                                        backgroundColor: AppColors.paperDeep,
                                        color: Color(d.color),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('$lp / ${d.cards.length}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                ],
                              ),
                              if (!unlocked) ...[
                                const SizedBox(height: 8),
                                Text('🔒  $_learned/${d.unlockThreshold} 학습 시 unlock',
                                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
