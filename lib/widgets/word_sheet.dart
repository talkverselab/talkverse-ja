import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import 'furigana_text.dart';
import 'japanese_decor.dart';
import 'selectable_ja_text.dart';

/// 단어 정보 시트 열기
Future<void> showWordSheet(BuildContext context, WordEntry word) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.washi,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(2))),
    builder: (_) => WordSheet(word: word),
  );
}

/// 단어 1개 — 루비 표기 · 뜻 · 한자 분해 (각 한자 훈음 + 이 단어 안 읽기, 탭 → 한자 시트)
class WordSheet extends StatefulWidget {
  final WordEntry word;
  const WordSheet({super.key, required this.word});

  @override
  State<WordSheet> createState() => _WordSheetState();
}

class _WordSheetState extends State<WordSheet> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    KanjiIndexService.instance.ensureLoaded().then((_) {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.word;
    final kanjiSegs = w.segs.where((s) => s.reading != null && s.text.runes.any((c) => KanjiIndexService.isKanji(String.fromCharCode(c)))).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: FuriganaText(segs: w.segs, fontSize: 34)),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: AppColors.beni, size: 28),
                      onPressed: () => TtsService.instance.speak(w.kana),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(w.kana, style: const TextStyle(fontSize: 14, color: AppColors.ai, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    _chip(w.jlpt == null ? '회화 코퍼스' : 'JLPT N${w.jlpt}', AppColors.ai),
                    if (w.row.rank != null) _chip('회화 #${w.row.rank}', AppColors.beni),
                  ],
                ),
                const SizedBox(height: 12),
                if (w.hasKo)
                  Text(w.row.ko!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1.3)),
                if ((w.row.en ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      w.row.en!,
                      style: TextStyle(
                        fontSize: w.hasKo ? 12 : 16,
                        color: w.hasKo ? AppColors.sumiLight : AppColors.sumi,
                        fontWeight: w.hasKo ? FontWeight.w500 : FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                  ),
                if (kanjiSegs.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const AsanohaDivider(height: 8),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SealStamp(text: '漢', size: 20),
                      const SizedBox(width: 8),
                      const Text('한자 분해',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...kanjiSegs.map((s) => _KanjiSegRow(seg: s, loaded: _loaded)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(border: Border.all(color: c), color: c.withValues(alpha: 0.08)),
        child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: c)),
      );
}

class _KanjiSegRow extends StatelessWidget {
  final FuriSeg seg;
  final bool loaded;
  const _KanjiSegRow({required this.seg, required this.loaded});

  @override
  Widget build(BuildContext context) {
    final chars = seg.text.characters.where((c) => KanjiIndexService.isKanji(c)).toList();
    final multi = chars.length > 1; // 숙자훈 (大人=おとな 등)
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 52),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.washiDeep, border: Border.all(color: AppColors.kin)),
            child: Text(seg.text,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.beni, height: 1)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('= ${seg.reading}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.ai)),
                    if (multi) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        color: AppColors.kin.withValues(alpha: 0.2),
                        child: const Text('숙자훈 (통째 읽기)', style: TextStyle(fontSize: 9, color: AppColors.sumi)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: chars.map((c) {
                    final e = loaded ? KanjiIndexService.instance.lookup(c) : null;
                    return InkWell(
                      onTap: () => showKanjiSheet(context, char: c, entry: e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.washi,
                          border: Border.all(color: AppColors.beni.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          e == null
                              ? c
                              : '$c ${e.meaning.isNotEmpty ? e.meaning : e.meaningsEn}${e.jlpt != null ? ' · N${e.jlpt}' : ''}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.sumi),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
