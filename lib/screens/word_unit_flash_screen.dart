import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/prefs.dart';
import '../core/theme.dart';
import '../services/art_service.dart';
import '../services/content_sync.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../services/word_examples.dart';
import '../widgets/word_kanji_families.dart';
import 'dialogue_screen.dart' show openDialogueAt;

/// 단원 플래시카드·단어 시트에 넘기는 단어 한 개(절벽·JLPT 공용).
class StudyWord {
  final String word;
  final String kana; // 표기와 같으면 ''
  final String gloss;
  final String pos; // 문법 낱말의 품사(영문 꼬리표) — 화면에는 [posLabel]
  final bool grammar;
  final int? artRank;
  const StudyWord({required this.word, this.kana = '', this.gloss = '', this.pos = '', this.grammar = false, this.artRank});

  String get speakText => kana.isNotEmpty ? kana : word.replaceAll(RegExp('[～〜~]'), '');
  String get prefKey => 'wcard:$word';
}

/// 품사 꼬리표 → 화면 말.
String posLabel(String pos) {
  final p = pos.toLowerCase();
  if (p.contains('particle')) return tr('조사');
  if (p.contains('copula') || p.contains('auxiliary')) return tr('조동사');
  if (p.contains('suffix')) return tr('접미사');
  if (p.contains('prefix')) return tr('접두사');
  if (p.contains('counter')) return tr('수량사');
  if (p.contains('adverb')) return tr('부사');
  if (p.contains('conjunction')) return tr('접속사');
  if (p.contains('interjection') || p.contains('filler')) return tr('감탄사');
  if (p.contains('adnominal')) return tr('연체사');
  if (p.contains('pronoun')) return tr('대명사');
  if (p.contains('noun')) return tr('명사');
  return tr('문법');
}

/// 「문장으로 외우는 게 더 좋아요」 한 줄 안내(사용자 지시 2026-11-11).
class SentenceTip extends StatelessWidget {
  final String? sub;
  const SentenceTip({super.key, this.sub});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
        child: Row(children: [
          const Text('💡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(tr('문장으로 외우는 게 더 좋아요'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi)),
              if (sub != null) Text(sub!, style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, height: 1.3)),
            ]),
          ),
        ]),
      );
}

/// 그 단어가 나온 회화 문장들 — 탭하면 그 문장부터 회화 재생.
class WordExampleList extends StatelessWidget {
  final StudyWord word;
  final int max;
  const WordExampleList({super.key, required this.word, this.max = 3});

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: WordExamples.instance.ensureLoaded(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const SizedBox(height: 40);
          final ex = WordExamples.instance.find(word.word, max: max);
          if (ex.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(tr('이 단어가 나온 회화 문장이 아직 없어요'), style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
            );
          }
          return Column(mainAxisSize: MainAxisSize.min, children: [
            for (final e in ex)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Material(
                  color: AppColors.washi,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.line)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => openDialogueAt(context, e.dialogue, e.index),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 9, 6, 9),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.turn.ja, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.sumi, height: 1.35)),
                            if (e.turn.kana.isNotEmpty && e.turn.kana != e.turn.ja) KoReadingText(e.turn.kana, style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                            Text(e.turn.ko, style: const TextStyle(fontSize: 12.5, color: AppColors.sumiLight, height: 1.35)),
                            const SizedBox(height: 2),
                            Text('${e.dialogue.region} · ${e.dialogue.emoji} ${e.dialogue.title} →', style: const TextStyle(fontSize: 10.5, color: AppColors.ai, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                        IconButton(
                          tooltip: tr('듣기'),
                          icon: const Icon(Icons.volume_up, size: 18, color: AppColors.beni),
                          onPressed: () => TtsService.instance.speak(e.turn.kana.isNotEmpty ? e.turn.kana : e.turn.ja),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
          ]);
        },
      );
}

/// 단어·문법 카드 시트 — 표기·읽기·뜻(문법은 기능 설명) + 회화 예문.
Future<void> showStudyWordSheet(BuildContext context, StudyWord w) => showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.washi,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 24 + bottomInset(context)),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Flexible(child: Text(w.word, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.sumi))),
                const SizedBox(width: 10),
                if (w.grammar || w.pos.isNotEmpty) _Chip(posLabel(w.pos), AppColors.ai),
                const Spacer(),
                IconButton(tooltip: tr('듣기'), icon: const Icon(Icons.volume_up, color: AppColors.beni), onPressed: () => TtsService.instance.speak(w.speakText)),
              ]),
              if (w.kana.isNotEmpty) KoReadingText(w.kana, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
              const SizedBox(height: 6),
              if (w.gloss.isNotEmpty) Text(w.gloss, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.sumi, height: 1.4)),
              const SizedBox(height: 14),
              const SentenceTip(),
              WordExampleList(word: w),
              WordKanjiFamilies(word: w.word),
            ]),
          ),
        ),
      ),
    );

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
      );
}

/// 20어 단원 플래시카드(사용자 지시 2026-11-11 "단어도 20개씩 묶어서 플래시카드").
/// 앞면 = 그림(있으면)·표기 → 뒤집으면 읽기·뜻 + 이 단어가 나온 회화 문장(탭하면 그 회화로).
/// 몰라요 는 끝에 다시. 상태는 Prefs('wcard:<낱말>') 0 몰라요 · 2 알아요.
class WordUnitFlashScreen extends StatefulWidget {
  final String title;
  final List<StudyWord> words;
  const WordUnitFlashScreen({super.key, required this.title, required this.words});

  @override
  State<WordUnitFlashScreen> createState() => _WordUnitFlashScreenState();
}

class _WordUnitFlashScreenState extends State<WordUnitFlashScreen> {
  late List<int> _queue = [for (var i = 0; i < widget.words.length; i++) i];
  int _pos = 0;
  bool _flipped = false;
  bool _done = false;
  Prefs? _prefs;
  final Map<int, int> _states = {};

  @override
  void initState() {
    super.initState();
    Prefs.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        _prefs = p;
        for (var i = 0; i < widget.words.length; i++) {
          final v = p.getInt(widget.words[i].prefKey);
          if (v != null) _states[i] = v;
        }
      });
    });
    WordExamples.instance.ensureLoaded();
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  int get _known => _states.values.where((s) => s == 2).length;

  Future<void> _mark(int state) async {
    final i = _queue[_pos];
    _states[i] = state;
    await _prefs?.setInt(widget.words[i].prefKey, state);
    if (!mounted) return;
    setState(() {
      if (state == 0) _queue.add(i); // 몰라요 는 끝에 다시
      if (_pos < _queue.length - 1) {
        _pos++;
        _flipped = false;
      } else {
        _done = true;
      }
    });
  }

  void _restart() => setState(() {
        _queue = [for (var i = 0; i < widget.words.length; i++) i];
        _pos = 0;
        _flipped = false;
        _done = false;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.title, style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text(trf('{0} / {1} · 알아요 {2}', [_done ? _queue.length : _pos + 1, _queue.length, _known]), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1)),
        ]),
        actions: const [KoReadingToggleAction()],
      ),
      body: widget.words.isEmpty
          ? Center(child: Text(tr('카드가 없어요'), style: const TextStyle(color: AppColors.sumiLight)))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset(context)),
                  child: Column(children: [
                    SentenceTip(sub: tr('카드를 뒤집으면 이 단어가 나온 회화 문장이 보여요')),
                    const SizedBox(height: 10),
                    Expanded(child: _done ? _summary() : _card(widget.words[_queue[_pos]])),
                    const SizedBox(height: 12),
                    if (!_done)
                      Row(children: [
                        Expanded(child: _btn(tr('몰라요'), AppColors.beni, () => _mark(0))),
                        const SizedBox(width: 10),
                        Expanded(child: _btn(tr('알아요'), AppColors.matcha, () => _mark(2))),
                      ]),
                  ]),
                ),
              ),
            ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap) => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      );

  Widget _summary() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎉', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 10),
        Text(trf('{0}어 중 알아요 {1}어', [widget.words.length, _known]), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          OutlinedButton(onPressed: _restart, child: Text(tr('다시'))),
          const SizedBox(width: 10),
          FilledButton(onPressed: () => Navigator.of(context).maybePop(), style: FilledButton.styleFrom(backgroundColor: AppColors.sumi), child: Text(tr('나가기'))),
        ]),
      ]);

  Widget _card(StudyWord w) {
    final state = _states[_queue[_pos]];
    final border = switch (state) { 2 => AppColors.matcha, 0 => AppColors.beni, _ => AppColors.line };
    return GestureDetector(
      onTap: () {
        setState(() => _flipped = !_flipped);
        if (_flipped) TtsService.instance.speak(w.speakText);
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: border, width: 1.4), borderRadius: BorderRadius.circular(18), boxShadow: kCardShadow),
        child: _flipped ? _back(w) : _front(w),
      ),
    );
  }

  Widget _front(StudyWord w) => FutureBuilder<String?>(
        key: ValueKey('f:${w.word}'),
        future: ArtService.instance.urlFor(w.word, rank: w.artRank),
        builder: (context, snap) {
          final url = snap.data;
          Widget word(double size) => Padding(
                padding: const EdgeInsets.all(14),
                child: FittedBox(fit: BoxFit.scaleDown, child: Text(w.word, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: AppColors.sumi))),
              );
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (url != null) Expanded(child: Image(image: artProvider(url), fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox())),
            if (url != null) word(40) else Expanded(child: Container(color: AppColors.washiDeep, alignment: Alignment.center, child: word(72))),
            if (w.grammar) Padding(padding: const EdgeInsets.only(bottom: 6), child: Center(child: _Chip(posLabel(w.pos), AppColors.ai))),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(tr('탭해서 뒤집기'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
            ),
          ]);
        },
      );

  Widget _back(StudyWord w) => SingleChildScrollView(
        key: ValueKey('b:${w.word}'),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(w.word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.sumi))),
            const SizedBox(width: 10),
            if (w.grammar) _Chip(posLabel(w.pos), AppColors.ai),
            const Spacer(),
            IconButton(tooltip: tr('듣기'), icon: const Icon(Icons.volume_up, color: AppColors.beni), onPressed: () => TtsService.instance.speak(w.speakText)),
          ]),
          if (w.kana.isNotEmpty) KoReadingText(w.kana, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
          const SizedBox(height: 4),
          Text(w.gloss.isEmpty ? '—' : w.gloss, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.sumi, height: 1.4)),
          const SizedBox(height: 12),
          Text(tr('회화 문장'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.sumiLight, letterSpacing: 1)),
          WordExampleList(word: w, max: 2),
          WordKanjiFamilies(word: w.word, maxMembers: 6),
        ]),
      );
}

/// 단원 머리줄의 「플래시카드」 버튼.
class UnitFlashButton extends StatelessWidget {
  final String title;
  final List<StudyWord> Function() words;
  const UnitFlashButton({super.key, required this.title, required this.words});
  @override
  Widget build(BuildContext context) => TextButton.icon(
        onPressed: () => openFull(context, (_) => WordUnitFlashScreen(title: title, words: words())),
        style: TextButton.styleFrom(foregroundColor: AppColors.ai, visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
        icon: const Icon(Icons.style_outlined, size: 16),
        label: Text(tr('플래시카드'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      );
}
