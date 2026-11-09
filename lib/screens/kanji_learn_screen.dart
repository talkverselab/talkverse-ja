import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';
import 'kanji_quiz_screen.dart';

/// 「한자 배우기」 — 단계(20자)를 한 글자씩 **먼저 배우고**(한자유니버스 공용 DB: 글자 형성·팁·어원·소리 가족·그림 + 읽기·단어),
/// 다 보면 그 단계 4지선다로 간다(사용자 지시 2026-11-02 "바로 문제로 나와… 배우기가 나와야").
/// 폰: 한 글자 한 페이지(좌우 넘김). 아이패드(가로 720 이상): 왼쪽 20자 격자 · 오른쪽 글자 정보.
class KanjiLearnStageScreen extends StatefulWidget {
  final int stage;
  final List<KanjiStage> allStages;
  final int resultOffset;
  const KanjiLearnStageScreen({super.key, required this.stage, required this.allStages, this.resultOffset = 0});

  @override
  State<KanjiLearnStageScreen> createState() => _KanjiLearnStageScreenState();
}

class _KanjiLearnStageScreenState extends State<KanjiLearnStageScreen> {
  late final KanjiStage _st = widget.allStages[widget.stage - 1];
  late final PageController _page = PageController();
  final Set<int> _seen = {0};
  int _idx = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _go(int i, {bool animate = true}) {
    if (i < 0 || i >= _st.chars.length) return;
    setState(() {
      _idx = i;
      _seen.add(i);
    });
    if (!isWide(context) && _page.hasClients) {
      if (animate) {
        _page.animateToPage(i, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      } else {
        _page.jumpToPage(i);
      }
    }
  }

  void _speak(KanjiEntry e) {
    final kun = e.kun;
    TtsService.instance.speak(kun.isNotEmpty ? kun.first.reading.replaceAll(RegExp(r'[\-\(\)]'), '') : e.char);
  }

  Future<void> _quiz() async {
    await openFull(context, (_) => KanjiQuizScreen(stage: widget.stage, allStages: widget.allStages, resultOffset: widget.resultOffset));
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final chars = _st.chars;
    final e = chars[_idx];
    final allSeen = _seen.length >= chars.length;
    final label = _st.freqLabel ?? _st.levelLabel;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(trf('한자 배우기 · 단계 {0}', [widget.stage]), style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text('$label · ${_idx + 1} / ${chars.length}', style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 2)),
        ]),
        actions: [
          TextButton.icon(
            onPressed: _quiz,
            icon: const Icon(Icons.quiz_outlined, size: 18),
            label: Text(tr('문제 풀기'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: allSeen ? AppColors.beni : AppColors.muted),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 300, child: _Grid(chars: chars, idx: _idx, seen: _seen, onTap: (i) => _go(i))),
                  const VerticalDivider(width: 1, color: AppColors.line),
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(e.char),
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset(context)),
                      child: KanjiInfoBody(char: e.char, entry: e),
                    ),
                  ),
                ])
              : PageView.builder(
                  controller: _page,
                  itemCount: chars.length,
                  onPageChanged: (i) => setState(() {
                    _idx = i;
                    _seen.add(i);
                  }),
                  itemBuilder: (context, i) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: KanjiInfoBody(char: chars[i].char, entry: chars[i]),
                  ),
                ),
        ),
        _Bottom(
          idx: _idx,
          total: chars.length,
          allSeen: allSeen,
          onPrev: () => _go(_idx - 1),
          onNext: () => _go(_idx + 1),
          onSpeak: () => _speak(e),
          onQuiz: _quiz,
        ),
      ]),
    );
  }
}

class _Grid extends StatelessWidget {
  final List<KanjiEntry> chars;
  final int idx;
  final Set<int> seen;
  final ValueChanged<int> onTap;
  const _Grid({required this.chars, required this.idx, required this.seen, required this.onTap});

  @override
  Widget build(BuildContext context) => GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.9),
        itemCount: chars.length,
        itemBuilder: (context, i) {
          final on = i == idx;
          final done = seen.contains(i);
          final e = chars[i];
          return InkWell(
            onTap: () => onTap(i),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: on ? AppColors.beni.withValues(alpha: 0.12) : AppColors.washiDeep,
                border: Border.all(color: on ? AppColors.beni : (done ? AppColors.matcha : AppColors.line), width: on ? 1.6 : 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(e.char, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: on ? AppColors.beni : AppColors.sumi, height: 1.1)),
                const SizedBox(height: 2),
                Text(e.meanings.isNotEmpty ? e.meanings.first : '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: AppColors.muted, fontWeight: FontWeight.w700)),
              ]),
            ),
          );
        },
      );
}

class _Bottom extends StatelessWidget {
  final int idx, total;
  final bool allSeen;
  final VoidCallback onPrev, onNext, onSpeak, onQuiz;
  const _Bottom({required this.idx, required this.total, required this.allSeen, required this.onPrev, required this.onNext, required this.onSpeak, required this.onQuiz});

  @override
  Widget build(BuildContext context) {
    final last = idx >= total - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomInset(context)),
      decoration: const BoxDecoration(color: AppColors.washi, border: Border(top: BorderSide(color: AppColors.line))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          IconButton(tooltip: tr('이전'), onPressed: idx > 0 ? onPrev : null, icon: const Icon(Icons.chevron_left), color: AppColors.sumi),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: BrushDivider(height: 4, color: AppColors.kin.withValues(alpha: 0.4)),
            ),
          ),
          IconButton(tooltip: tr('듣기'), onPressed: onSpeak, icon: const Icon(Icons.volume_up), color: AppColors.beni),
          IconButton(tooltip: tr('다음'), onPressed: !last ? onNext : null, icon: const Icon(Icons.chevron_right), color: AppColors.sumi),
        ]),
        if (last || allSeen)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onQuiz,
              style: FilledButton.styleFrom(backgroundColor: AppColors.beni, foregroundColor: Colors.white, shape: const StadiumBorder()),
              icon: const Icon(Icons.quiz),
              label: Text(allSeen ? tr('다 봤어요 — 이 단계 문제 풀기') : tr('이 단계 문제 풀기'), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          )
        else
          Text(trf('{0}자 더 보면 문제 풀기', [total - idx - 1]), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
      ]),
    );
  }
}
