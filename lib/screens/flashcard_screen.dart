import 'package:flutter/material.dart';
import '../services/content_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/pane.dart';
import '../core/theme.dart';
import '../services/deck_service.dart';
import '../services/ko_reading.dart';
import '../services/art_service.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

/// 복습 덱 목록 — decks/*.json (L1 회화 · native 회화체 · R1 골격 · 한자 80 · 교육부 어휘).
class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Deck> _decks = const [];
  Map<String, int> _known = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DeckService.instance.ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    final known = <String, int>{};
    for (final d in DeckService.instance.decks) {
      known[d.id] = d.cards.where((c) => prefs.getInt('card:${c.id}') == 2).length;
    }
    if (!mounted) return;
    setState(() {
      _decks = DeckService.instance.decks;
      _known = known;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('복습 카드'), style: TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 16)),
            SizedBox(height: 2),
            Text('Flashcards', style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._decks.map((d) => _DeckRow(
                      deck: d,
                      known: _known[d.id] ?? 0,
                      onTap: () async {
                        await openFull(context, (_) => DeckSessionScreen(deck: d));
                        _load();
                      },
                    )),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  final Deck deck;
  final int known;
  final VoidCallback onTap;
  const _DeckRow({required this.deck, required this.known, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(deck.colorValue);
    final pct = deck.cards.isEmpty ? 0.0 : known / deck.cards.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.washi,
            border: Border.all(color: AppColors.kin.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: AppColors.sumi.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(1, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, border: Border.all(color: AppColors.kinDeep, width: 0.6)),
                child: Text(deck.icon, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.washi)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                    const SizedBox(height: 2),
                    Text(deck.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.washiDeep,
                            border: Border.all(color: AppColors.kin.withValues(alpha: 0.3)),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: pct.clamp(0.0, 1.0),
                          child: Container(height: 5, color: AppColors.matcha),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text('$known/${deck.cards.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.beni)),
                  Text(tr('알아요'), style: TextStyle(fontSize: 9, color: AppColors.sumiLight)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 덱 카드 세션 — 앞면 일본어(가나) → 뒤집으면 뜻. 3단계 평가는 SharedPreferences('card:{id}') 저장.
class DeckSessionScreen extends StatefulWidget {
  final Deck deck;
  const DeckSessionScreen({super.key, required this.deck});

  @override
  State<DeckSessionScreen> createState() => _DeckSessionScreenState();
}

class _DeckSessionScreenState extends State<DeckSessionScreen> {
  int _index = 0;
  bool _flipped = false;
  bool _reverse = false; // false = 앞면 한국어(뜻·그림) → 일본어 맞히기(기본), true = 일본어 앞면
  final List<int> _retry = []; // 틀린 카드는 세션 끝에 다시
  SharedPreferences? _prefs;
  final Map<String, int> _states = {}; // 0 몰라요 1 보통 2 알아요

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final c in widget.deck.cards) {
        final v = _prefs!.getInt('card:${c.id}');
        if (v != null) _states[c.id] = v;
      }
    });
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.deck.cards.length) return;
    setState(() {
      _index = next;
      _flipped = false;
    });
  }

  Future<void> _mark(int state) async {
    final card = widget.deck.cards[_index];
    setState(() => _states[card.id] = state);
    await _prefs?.setInt('card:${card.id}', state);
    if (!mounted) return;
    if (state == 0 && !_retry.contains(_index)) _retry.add(_index); // 틀린 카드는 끝에 다시
    if (_index < widget.deck.cards.length - 1) {
      _go(1);
    } else if (_retry.isNotEmpty) {
      final next = _retry.removeAt(0);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(trf('틀린 카드 다시: 남은 {0}장', [_retry.length + 1])),
        backgroundColor: AppColors.beni,
        duration: const Duration(seconds: 1),
      ));
      setState(() {
        _index = next;
        _flipped = false;
      });
    } else {
      final known = _states.values.where((s) => s == 2).length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(trf('🎉 마지막 카드! {0}장 중 알아요 {1}장', [widget.deck.cards.length, known])),
          backgroundColor: AppColors.matcha,
        ),
      );
    }
  }

  /// 덱 카드 id 가 `r1_012` 처럼 끝 숫자가 빈도 순위인 경우만 순위로 쓴다(그림 조회용).
  int? _rankOf(DeckCard card) {
    final m = RegExp(r'_(\d+)$').firstMatch(card.id);
    if (m == null || !card.id.startsWith('r1_')) return null;
    return int.tryParse(m.group(1)!);
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.deck.cards;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.deck.name,
                style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${_index + 1} / ${cards.length}',
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _reverse ? tr('앞면: 일본어 → 한국어로 바꾸기') : tr('앞면: 한국어 → 일본어로 바꾸기'),
            icon: Icon(_reverse ? Icons.swap_horiz : Icons.swap_horizontal_circle_outlined, color: AppColors.ai),
            onPressed: () => setState(() {
              _reverse = !_reverse;
              _flipped = false;
            }),
          ),
          const KoReadingToggleAction(),
        ],
      ),
      body: cards.isEmpty
          ? Center(child: Text(tr('카드가 없어요'), style: TextStyle(color: AppColors.sumiLight)))
          : _body(cards),
    );
  }

  Widget _body(List<DeckCard> cards) {
    final card = cards[_index];
    final state = _states[card.id];
    final borderColor = switch (state) {
      2 => AppColors.matcha,
      1 => AppColors.kinDeep,
      0 => AppColors.beni,
      _ => AppColors.kin,
    };
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.washiDeep,
                  border: Border.all(color: AppColors.kin.withValues(alpha: 0.4)),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (_index + 1) / cards.length,
                child: Container(height: 6, color: AppColors.beni),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: GestureDetector(
              onTap: () => setState(() => _flipped = !_flipped),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _flipped ? AppColors.washiDeep : AppColors.washi,
                  border: Border.all(color: borderColor, width: 1.8),
                  boxShadow: [
                    BoxShadow(color: AppColors.sumi.withValues(alpha: 0.1), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: AppColors.beni),
                            onPressed: () => TtsService.instance.speak(card.kana.isNotEmpty ? card.kana : card.front),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _CardArt(word: card.front, rank: _rankOf(card)),
                      const SizedBox(height: 10),
                      if (_reverse || _flipped) ...[
                        SelectableJaText(
                          text: card.front,
                          style: TextStyle(
                            fontSize: card.front.characters.length <= 2 ? 72 : 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.beni,
                            height: 1.3,
                          ),
                        ),
                        if (card.kana.isNotEmpty && card.kana != card.front) ...[
                          const SizedBox(height: 8),
                          Text(card.kana,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, color: AppColors.ai, fontWeight: FontWeight.w700)),
                        ],
                        if (card.kana.isNotEmpty)
                          KoReadingText(card.kana,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
                      ],
                      if (!_reverse || _flipped) ...[
                        if (_flipped) ...[
                          const SizedBox(height: 16),
                          const BrushDivider(height: 2),
                          const SizedBox(height: 14),
                        ],
                        Text(card.back,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: _reverse ? 22 : 26, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1.4)),
                      ],
                      if (_flipped && card.key.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.kin.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.kin),
                          ),
                          child: Text('💡 ${card.key}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.sumi, height: 1.4)),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text(_flipped ? tr('탭해서 앞면 보기') : (_reverse ? tr('탭해서 뜻 보기') : tr('일본어로 말해 보고, 탭해서 확인')),
                          style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _index > 0 ? () => _go(-1) : null,
                style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder(), side: const BorderSide(color: AppColors.kin)),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(tr('이전')),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _index < cards.length - 1 ? () => _go(1) : null,
                style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder(), side: const BorderSide(color: AppColors.kin)),
                icon: Text(tr('다음')),
                label: const Icon(Icons.arrow_forward, size: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 20 + bottomInset(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SrsButton(icon: Icons.close, label: tr('틀렸어요'), color: AppColors.beni, onTap: () => _mark(0)),
              _SrsButton(icon: Icons.check, label: tr('맞았어요'), color: AppColors.matcha, onTap: () => _mark(2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SrsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SrsButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: AppColors.washi, size: 30),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.sumi)),
      ],
    );
  }
}


/// 단어 그림(talkverse.uk 공용 그림, `ArtService`). 그림이 없으면 아무것도 그리지 않는다.
class _CardArt extends StatelessWidget {
  final String word;
  final int? rank;
  const _CardArt({required this.word, this.rank});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ArtService.instance.urlFor(word, rank: rank),
      builder: (context, snap) {
        final url = snap.data;
        if (url == null) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image(
            image: artProvider(url),
            height: 140,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
            loadingBuilder: (c, child, p) => p == null ? child : const SizedBox(height: 140),
          ),
        );
      },
    );
  }
}
