import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/art_service.dart';
import '../services/content_sync.dart';
import '../services/ko_reading.dart';
import '../services/mastery.dart';
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

/// 플래시카드 한 장 — 단어·회화 줄 공용. [id] 는 숙련도 기록 키([Mastery]).
abstract class FlashItem {
  String get id;
  Widget front(BuildContext context);
  Widget back(BuildContext context);
  Future<void> speak();
}

/// 단어 카드 — 앞 = 그림·표기, 뒤 = 읽기·뜻 + 회화에서 그 단어가 쓰인 짧은 덩어리 1~2개 + 회화 문장.
class WordFlashItem extends FlashItem {
  final StudyWord w;
  WordFlashItem(this.w);
  @override
  String get id => 'w:${w.word}';
  @override
  Future<void> speak() => TtsService.instance.speak(w.speakText);

  @override
  Widget front(BuildContext context) => FutureBuilder<String?>(
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

  @override
  Widget back(BuildContext context) {
    final chunks = wordChunks(w.word);
    return SingleChildScrollView(
      key: ValueKey('b:${w.word}'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(child: Text(w.word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.sumi))),
          const SizedBox(width: 10),
          if (w.grammar) _Chip(posLabel(w.pos), AppColors.ai),
          const Spacer(),
          IconButton(tooltip: tr('듣기'), icon: const Icon(Icons.volume_up, color: AppColors.beni), onPressed: speak),
        ]),
        if (w.kana.isNotEmpty) KoReadingText(w.kana, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
        const SizedBox(height: 4),
        Text(w.gloss.isEmpty ? '—' : w.gloss, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.sumi, height: 1.4)),
        if (chunks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(tr('덩어리로'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.sumiLight, letterSpacing: 1)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in chunks)
              ActionChip(
                key: ValueKey('chunk:$c'),
                label: Text(c, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                avatar: const Icon(Icons.volume_up, size: 16, color: AppColors.beni),
                backgroundColor: AppColors.washiDeep,
                side: const BorderSide(color: AppColors.line),
                onPressed: () => TtsService.instance.speak(c),
              ),
          ]),
        ],
        const SizedBox(height: 12),
        Text(tr('회화 문장'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.sumiLight, letterSpacing: 1)),
        WordExampleList(word: w, max: 2),
        WordKanjiFamilies(word: w.word, maxMembers: 6),
      ]),
    );
  }
}

/// 회화에서 그 단어가 쓰인 짧은 덩어리(「本当？」「本当に？」 식) — 문장을 、。？！… 에서 끊어 그 단어가 든 조각만, 짧은 것부터 [max] 개.
/// 활용형(行く→行った)은 끝 가나를 뗀 어간으로 찾는다. [WordExamples.ensureLoaded] 뒤에 부른다.
List<String> wordChunks(String word, {int max = 2}) {
  final w = word.replaceAll(RegExp('[～〜~]'), '');
  if (w.isEmpty || RegExp(r'^[ぁ-んー]$').hasMatch(w)) return const []; // 한 글자 가나(の·は…)는 엉뚱한 말에 걸려서 뺀다
  final stem = w.replaceAll(RegExp(r'[ぁ-ん]+$'), '');
  final stemRe = stem.isNotEmpty && stem != w ? RegExp('${RegExp.escape(stem)}[ぁ-ん]') : null; // 활용형은 어간 + 가나만
  bool has(String s) => s.contains(w) || (stemRe?.hasMatch(s) ?? false);
  final out = <String>[];
  final norm = <String>{};
  for (final e in WordExamples.instance.find(w, max: 12)) {
    final text = e.turn.ja.replaceAll(RegExp(r'[（(][^)）]*[)）]'), '').replaceAll(RegExp(r'[wｗ]+$'), '');
    for (final seg in text.split(RegExp(r'(?<=[、。？！?!…])|[\s　]+'))) {
      var s = seg.trim().replaceAll(RegExp(r'^[「『]|[」』]$'), '').replaceAll(RegExp(r'[、。]+$'), '');
      if (s.isEmpty || s.length > 12 || s.contains('{') || !has(s)) continue;
      final k = s.replaceAll(RegExp(r'[、。？！?!…]'), '');
      if (k == w || !norm.add(k)) continue; // 단어 그대로(부호만 붙은 것)·같은 덩어리는 뺀다
      out.add(s);
    }
  }
  out.sort((a, b) => a.length.compareTo(b.length));
  return out.take(max).toList();
}

/// 단원 플래시카드(단어 20 · 문장 10). 들어올 때마다 순서를 섞고, 탭 → 뒤집기 → 「다시」/「알았음」.
/// 「다시」 고른 카드는 단원 끝에 다시 나온다. 끝나면 알았음·다시 개수와 평균 숙련도.
/// 숙련도는 카드마다 0~100%(알았음 +20 · 다시 −20, [Mastery]), 색은 파랑 → 빨강.
class UnitFlashScreen extends StatefulWidget {
  final String title;
  final List<FlashItem> items;
  final String? tip;
  const UnitFlashScreen({super.key, required this.title, required this.items, this.tip});

  @override
  State<UnitFlashScreen> createState() => _UnitFlashScreenState();
}

/// 단어 20어 단원 — 옛 호출 자리 그대로.
class WordUnitFlashScreen extends StatelessWidget {
  final String title;
  final List<StudyWord> words;
  const WordUnitFlashScreen({super.key, required this.title, required this.words});
  @override
  Widget build(BuildContext context) =>
      UnitFlashScreen(title: title, items: [for (final w in words) WordFlashItem(w)], tip: tr('카드를 뒤집으면 회화에서 쓰인 덩어리와 문장이 보여요'));
}

class _UnitFlashScreenState extends State<UnitFlashScreen> {
  late List<int> _queue;
  int _pos = 0;
  bool _flipped = false;
  bool _done = false;
  final Set<int> _again = {}; // 한 번이라도 「다시」
  final Set<int> _gotIt = {}; // 마지막에 「알았음」

  @override
  void initState() {
    super.initState();
    _queue = [for (var i = 0; i < widget.items.length; i++) i]..shuffle();
    Mastery.load().then((_) {
      if (mounted) setState(() {});
    });
    WordExamples.instance.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _mark(bool known) async {
    final i = _queue[_pos];
    await Mastery.mark(widget.items[i].id, known: known);
    if (!mounted) return;
    setState(() {
      if (known) {
        _gotIt.add(i);
      } else {
        _again.add(i);
        _gotIt.remove(i);
        _queue.add(i); // 「다시」 는 끝에 다시
      }
      if (_pos < _queue.length - 1) {
        _pos++;
        _flipped = false;
      } else {
        _done = true;
      }
    });
  }

  void _restart() => setState(() {
        _queue = [for (var i = 0; i < widget.items.length; i++) i]..shuffle();
        _pos = 0;
        _flipped = false;
        _done = false;
        _again.clear();
        _gotIt.clear();
      });

  @override
  Widget build(BuildContext context) {
    final n = widget.items.length;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.title, style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text(trf('{0} / {1} · 알았음 {2} · 다시 {3}', [_done ? _queue.length : _pos + 1, _queue.length, _gotIt.length, _again.length]),
              style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1)),
        ]),
        actions: const [KoReadingToggleAction()],
      ),
      body: n == 0
          ? Center(child: Text(tr('카드가 없어요'), style: const TextStyle(color: AppColors.sumiLight)))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset(context)),
                  child: Column(children: [
                    if (widget.tip != null) ...[SentenceTip(sub: widget.tip), const SizedBox(height: 10)],
                    Expanded(child: _done ? _summary() : _card(_queue[_pos])),
                    const SizedBox(height: 12),
                    if (!_done)
                      Row(children: [
                        Expanded(child: _btn(tr('다시'), const Color(0xFF2F6FDB), () => _mark(false), 'flash-again')),
                        const SizedBox(width: 10),
                        Expanded(child: _btn(tr('알았음'), const Color(0xFFD83A3A), () => _mark(true), 'flash-known')),
                      ]),
                  ]),
                ),
              ),
            ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap, String key) => FilledButton(
        key: ValueKey(key),
        onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      );

  Widget _summary() {
    final avg = Mastery.average(widget.items.map((e) => e.id));
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🎉', style: TextStyle(fontSize: 44)),
      const SizedBox(height: 10),
      Text(trf('알았음 {0} · 다시 {1}', [_gotIt.length, _again.length]), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(tr('단원 숙련도'), style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
        const SizedBox(width: 8),
        MasteryPill(avg, fontSize: 14),
      ]),
      const SizedBox(height: 18),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        OutlinedButton(onPressed: _restart, child: Text(tr('한 번 더'))),
        const SizedBox(width: 10),
        FilledButton(onPressed: () => Navigator.of(context).maybePop(), style: FilledButton.styleFrom(backgroundColor: AppColors.sumi), child: Text(tr('나가기'))),
      ]),
    ]);
  }

  Widget _card(int i) {
    final item = widget.items[i];
    final p = Mastery.pct(item.id);
    return GestureDetector(
      key: const ValueKey('flash-card'),
      onTap: () {
        setState(() => _flipped = !_flipped);
        if (_flipped) item.speak();
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: AppColors.washi, border: Border.all(color: masteryColor(p), width: 1.6), borderRadius: BorderRadius.circular(18), boxShadow: kCardShadow),
        child: Stack(children: [
          Positioned.fill(child: _flipped ? item.back(context) : item.front(context)),
          Positioned(top: 10, right: 10, child: MasteryPill(p)),
        ]),
      ),
    );
  }
}

/// 단원 머리줄의 「플래시카드」 버튼 — 옆에 단원 평균 숙련도.
class UnitFlashButton extends StatelessWidget {
  final String title;
  final List<StudyWord> Function() words;
  const UnitFlashButton({super.key, required this.title, required this.words});
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: Mastery.load(),
        builder: (context, _) => ValueListenableBuilder<int>(
          valueListenable: Mastery.version,
          builder: (context, _, _) {
            final avg = Mastery.average(words().map((w) => 'w:${w.word}'));
            return Row(mainAxisSize: MainAxisSize.min, children: [
              MasteryPill(avg, fontSize: 10),
              TextButton.icon(
                onPressed: () => openFull(context, (_) => WordUnitFlashScreen(title: title, words: words())),
                style: TextButton.styleFrom(foregroundColor: AppColors.ai, visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8)),
                icon: const Icon(Icons.style_outlined, size: 16),
                label: Text(tr('플래시카드'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ]);
          },
        ),
      );
}
