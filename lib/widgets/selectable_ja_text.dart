import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import 'japanese_decor.dart';

/// 문장 내 한자를 탭하면 한자 정보 시트를 띄움. 가나·기호는 일반 텍스트.
class SelectableJaText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final String? highlightText;

  const SelectableJaText({
    super.key,
    required this.text,
    this.style,
    this.highlightText,
  });

  @override
  State<SelectableJaText> createState() => _SelectableJaTextState();
}

class _SelectableJaTextState extends State<SelectableJaText> {
  int? _focused;

  Future<void> _openChar(String char) async {
    await KanjiIndexService.instance.ensureLoaded();
    if (!mounted) return;
    final entry = KanjiIndexService.instance.lookup(char);
    await showKanjiSheet(context, char: char, entry: entry);
    if (mounted) setState(() => _focused = null);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.sumi,
          height: 1.3,
        );
    final chars = widget.text.characters.toList();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(chars.length, (i) {
        final c = chars[i];
        if (!KanjiIndexService.isKanji(c)) {
          return Text(c, style: style);
        }
        final focused = _focused == i;
        final highlighted = widget.highlightText != null && widget.highlightText!.contains(c);
        return Material(
          color: focused
              ? AppColors.beni.withValues(alpha: 0.18)
              : (highlighted ? AppColors.kin.withValues(alpha: 0.3) : Colors.transparent),
          child: InkWell(
            onTap: () {
              setState(() => _focused = i);
              _openChar(c);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: (style.color ?? AppColors.sumi).withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
              ),
              child: Text(c, style: style),
            ),
          ),
        );
      }),
    );
  }
}

/// 한자 정보 바텀시트 열기
Future<void> showKanjiSheet(BuildContext context, {required String char, KanjiEntry? entry}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.washi,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
    ),
    builder: (_) => KanjiInfoSheet(char: char, entry: entry),
  );
}

/// 한자 1자 정보 시트 — 훈음·음독·훈독·예시 단어·빈도.
class KanjiInfoSheet extends StatelessWidget {
  final String char;
  final KanjiEntry? entry;
  const KanjiInfoSheet({super.key, required this.char, this.entry});

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.washiDeep,
                        border: Border.all(color: AppColors.kin, width: 1.5),
                      ),
                      child: Text(
                        char,
                        style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: AppColors.beni,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e == null || e.meanings.isEmpty ? '(뜻 정보 없음)' : e.meaningJoined,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.sumi,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (e != null)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _Tag('빈도 #${e.rank}', AppColors.beni),
                                _Tag('${e.pct.toStringAsFixed(2)}%', AppColors.kinDeep),
                              ],
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: AppColors.beni),
                      onPressed: () {
                        final kun = e?.kun;
                        final text = (kun != null && kun.isNotEmpty)
                            ? kun.first.reading.replaceAll(RegExp(r'[\-\(\)]'), '')
                            : char;
                        TtsService.instance.speak(text);
                      },
                    ),
                  ],
                ),
                if (e != null && e.readings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const AsanohaDivider(height: 8),
                  const SizedBox(height: 10),
                  if (e.on.isNotEmpty) _ReadingRow(label: '음독', color: AppColors.ai, readings: e.on),
                  if (e.kun.isNotEmpty) _ReadingRow(label: '훈독', color: AppColors.matcha, readings: e.kun),
                ],
                if (e != null && e.words.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const SealStamp(text: '語', size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '예시 단어',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...e.words.take(6).map((w) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                w.word,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.sumi),
                              ),
                            ),
                            if (w.ko.isNotEmpty)
                              Expanded(
                                child: Text(
                                  w.ko,
                                  style: const TextStyle(fontSize: 13, color: AppColors.sumiLight),
                                ),
                              ),
                            Text(
                              '#${w.rank}',
                              style: const TextStyle(fontSize: 11, color: AppColors.sumiLight),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => TtsService.instance.speak(w.word),
                              child: const Icon(Icons.volume_up, size: 16, color: AppColors.beni),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  final String label;
  final Color color;
  final List<KanjiReading> readings;
  const _ReadingRow({required this.label, required this.color, required this.readings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            child: Text(
              label,
              style: const TextStyle(color: AppColors.washi, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: readings
                  .map((r) => InkWell(
                        onTap: () => TtsService.instance.speak(r.reading.replaceAll(RegExp(r'[\-\(\)]'), '')),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppColors.sumi, fontSize: 14),
                            children: [
                              TextSpan(
                                text: r.reading,
                                style: TextStyle(fontWeight: FontWeight.w800, color: color),
                              ),
                              if (r.gloss.isNotEmpty)
                                TextSpan(
                                  text: '  ${r.gloss}',
                                  style: const TextStyle(color: AppColors.sumiLight, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
