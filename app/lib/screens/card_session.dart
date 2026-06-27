import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/flash_card.dart';
import '../services/deck_loader.dart';
import '../services/user_stats.dart';
import '../services/word_reviews.dart';
import '../services/favorite_words.dart';
import '../services/tts.dart';
import '../theme.dart';
import '../widgets/flip_card.dart';
import '../widgets/talky_mascot.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/manga_panel.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/app_background.dart';
import '../widgets/kanji_detail_sheet.dart';
import '../widgets/memo_toggle.dart';

const int kSessionSize = 10;

enum _Srs { known, soso, unknown }

class CardSessionScreen extends StatefulWidget {
  final String deckId;
  const CardSessionScreen({super.key, required this.deckId});

  @override
  State<CardSessionScreen> createState() => _CardSessionScreenState();
}

class _CardSessionScreenState extends State<CardSessionScreen> {
  final _reviews = WordReviews();
  final _stats = UserStats();
  final _favs = FavoriteWords();

  Deck? _deck;
  List<FlashCard> _queue = [];
  int _idx = 0;
  bool _flipped = false;
  int _knownCount = 0;
  int _sosoCount = 0;
  int _unknownCount = 0;
  bool _favorited = false;
  bool _sessionDone = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final deck = await DeckLoader.load(widget.deckId);
    final cards = [...deck.cards];
    final scored = <MapEntry<FlashCard, int>>[];
    for (final c in cards) {
      final stage = await _reviews.getStage(c.id);
      scored.add(MapEntry(c, stage == 0 ? 0 : 1));
    }
    scored.shuffle(Random());
    scored.sort((a, b) => a.value.compareTo(b.value));
    final selected = scored.take(kSessionSize).map((e) => e.key).toList();
    if (!mounted) return;
    setState(() {
      _deck = deck;
      _queue = selected;
      _idx = 0;
      _flipped = false;
    });
    _loadFavorite();
    // 첫 카드 자동 발음
    if (selected.isNotEmpty) {
      _speakFront(selected[0]);
    }
  }

  void _speakFront(FlashCard c) {
    final text = c.kana.isNotEmpty && c.kana != c.front ? c.kana : c.front;
    Tts.instance.speakJa(text);
  }

  @override
  void dispose() {
    Tts.instance.stop();
    super.dispose();
  }

  Future<void> _loadFavorite() async {
    if (_queue.isEmpty) return;
    final c = _queue[_idx];
    final f = await _favs.has(c.id);
    if (!mounted) return;
    setState(() => _favorited = f);
  }

  void _flip() {
    HapticFeedback.lightImpact();
    setState(() => _flipped = !_flipped);
  }

  Future<void> _answer(_Srs answer) async {
    final c = _queue[_idx];
    switch (answer) {
      case _Srs.known:
        await _reviews.recordKnown(c.id);
        HapticFeedback.mediumImpact();
        _knownCount++;
        break;
      case _Srs.soso:
        await _reviews.recordSoso(c.id);
        HapticFeedback.lightImpact();
        _sosoCount++;
        break;
      case _Srs.unknown:
        await _reviews.recordUnknown(c.id);
        HapticFeedback.heavyImpact();
        _unknownCount++;
        break;
    }
    await _stats.incrementToday();
    if (_idx + 1 >= _queue.length) {
      setState(() => _sessionDone = true);
    } else {
      setState(() {
        _idx++;
        _flipped = false;
      });
      _loadFavorite();
      _speakFront(_queue[_idx]);
    }
  }

  Future<void> _toggleFav() async {
    final c = _queue[_idx];
    final v = await _favs.toggle(c.id);
    setState(() => _favorited = v);
  }

  @override
  Widget build(BuildContext context) {
    if (_deck == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const AppBackground(child: Center(child: Text('카드가 없어요.'))),
      );
    }
    if (_sessionDone) return _doneScreen();

    final c = _queue[_idx];
    final progress = (_idx + 1) / _queue.length;
    final deckColor = Color(_deck!.color);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_deck!.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(_deck!.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink)),
          ],
        ),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.ink),
            tooltip: '다시 듣기',
            onPressed: () => _speakFront(_queue[_idx]),
          ),
          IconButton(
            icon: Icon(_favorited ? Icons.star_rounded : Icons.star_outline,
                color: _favorited ? AppColors.streak : AppColors.ink),
            onPressed: _toggleFav,
          ),
        ],
      ),
      body: AppBackground(
        scatter: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.paperDeep,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${_idx + 1} / ${_queue.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.paperDeep,
                        color: deckColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Center(
                  child: FlipCard(
                    flipped: _flipped,
                    onTap: _flip,
                    front: _cardFace(c, deckColor, isFront: true),
                    back: _cardFace(c, deckColor, isFront: false),
                  ),
                ),
              ),
            ),
            // 이전 / 다음 네비게이션 (항상 표시)
            _navButtons(),
            // 답변 버튼 (앞면일 땐 힌트, 뒷면일 땐 SRS)
            if (!_flipped)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.touch_app_outlined, size: 14, color: AppColors.inkSoft),
                    SizedBox(width: 4),
                    Text('카드 탭해서 뒤집기', style: TextStyle(color: AppColors.inkSoft, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            else
              _answerButtons(),
          ],
        ),
      ),
    );
  }

  Widget _navButtons() {
    final atFirst = _idx == 0;
    final atLast = _idx == _queue.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: PressableScale(
              onTap: atFirst ? null : _prev,
              child: Opacity(
                opacity: atFirst ? 0.35 : 1.0,
                child: MangaPanel(
                  rotation: 0,
                  backgroundColor: AppColors.paperDeep,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_back_ios_rounded, size: 14, color: AppColors.ink),
                      SizedBox(width: 4),
                      Text('이전', style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PressableScale(
              onTap: atLast ? null : _next,
              child: Opacity(
                opacity: atLast ? 0.35 : 1.0,
                child: MangaPanel(
                  rotation: 0,
                  backgroundColor: AppColors.paperDeep,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('다음', style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w800)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.ink),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _prev() {
    if (_idx == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _idx--;
      _flipped = false;
    });
    _loadFavorite();
    _speakFront(_queue[_idx]);
  }

  void _next() {
    if (_idx >= _queue.length - 1) return;
    HapticFeedback.selectionClick();
    setState(() {
      _idx++;
      _flipped = false;
    });
    _loadFavorite();
    _speakFront(_queue[_idx]);
  }

  Widget _cardFace(FlashCard c, Color color, {required bool isFront}) {
    return MangaPanel(
      backgroundColor: isFront ? AppColors.cardFront : color.withValues(alpha: 0.10),
      borderWidth: 1.2,
      radius: 18,
      shadow: BoxShadow(
        color: AppColors.ink.withValues(alpha: 0.14),
        offset: const Offset(0, 8),
        blurRadius: 22,
        spreadRadius: -2,
      ),
      padding: const EdgeInsets.all(26),
      child: SizedBox(
        width: double.infinity,
        height: 360,
        child: isFront
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: c.hasKanjiDetail
                        ? () => KanjiDetailSheet.show(context, c)
                        : null,
                    child: Text(c.front,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: c.front.length > 8 ? 28 : 52,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: AppColors.ink,
                          letterSpacing: -0.5,
                        )),
                  ),
                  if (c.hasKanjiDetail) ...[
                    const SizedBox(height: 4),
                    Text(
                      '한자 탭하면 후리가나 + 대표 단어 ▾',
                      style: TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (c.kana.isNotEmpty && c.kana != c.front) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.honeySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(c.kana,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 17, color: AppColors.ink, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c.kana.isNotEmpty && c.kana != c.front)
                      Row(
                        children: [
                          Expanded(
                            child: Text(c.kana,
                                style: const TextStyle(fontSize: 15, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                          ),
                          PressableScale(
                            onTap: () => Tts.instance.speakJa(c.kana),
                            child: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.inkSoft),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(c.back,
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.ink, letterSpacing: -0.3)),
                        ),
                        const SizedBox(width: 6),
                        PressableScale(
                          onTap: () => Tts.instance.speakKo(c.back),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.honeySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                    if (c.key.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SpeechBubble(
                        color: AppColors.honeySoft,
                        tailSide: TailSide.right,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        child: Text(c.key,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.55, fontWeight: FontWeight.w500)),
                      ),
                    ],
                    const SizedBox(height: 12),
                    MemoToggle(
                      level: widget.deckId,
                      turn: c.id.hashCode,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _answerButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      child: Row(
        children: [
          _srsBtn('몰라요', 'もう一度', AppColors.warning, AppColors.honeySoft, () => _answer(_Srs.unknown), -0.4),
          const SizedBox(width: 8),
          _srsBtn('연습중', '普通', AppColors.honeyDeep, AppColors.cardFront, () => _answer(_Srs.soso), 0),
          const SizedBox(width: 8),
          _srsBtn('알아요', 'わかった!', AppColors.cloverDeep, AppColors.cloverSoft, () => _answer(_Srs.known), 0.4),
        ],
      ),
    );
  }

  Widget _srsBtn(String main, String sub, Color fg, Color bg, VoidCallback onTap, double rot) {
    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: MangaPanel(
          rotation: rot,
          backgroundColor: bg,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(main, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _doneScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: AppBackground(
        scatterSeed: _knownCount * 3 + 1,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TalkyMascot(mood: TalkyMood.happy, size: 120, showHalo: true),
              const SizedBox(height: 24),
              SpeechBubble(
                color: AppColors.honey,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text('やったね!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ),
              ),
              const SizedBox(height: 8),
              Text('${_queue.length} 장 完了',
                  style: const TextStyle(fontSize: 14, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCol('わかった', _knownCount, AppColors.cloverDeep),
                  _statCol('普通', _sosoCount, AppColors.honeyDeep),
                  _statCol('もう一度', _unknownCount, AppColors.warning),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: PressableScale(
                  onTap: () => context.pop(),
                  child: MangaPanel(
                    backgroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: Text('홈으로',
                          style: TextStyle(color: AppColors.paper, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sessionDone = false;
                    _idx = 0;
                    _flipped = false;
                    _knownCount = 0;
                    _sosoCount = 0;
                    _unknownCount = 0;
                  });
                  _bootstrap();
                },
                child: const Text('もう一回!',
                    style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCol(String label, int count, Color color) {
    return Column(
      children: [
        MangaPanel(
          rotation: count > 0 ? -0.6 : 0,
          backgroundColor: color.withValues(alpha: 0.18),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text('$count',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
