import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import 'furigana_text.dart';
import 'japanese_decor.dart';
import 'word_sheet.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

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

/// 한자 1자 정보 시트 — 훈음·JLPT·음독·훈독·읽기별 단어(DB)·예시 단어.
class KanjiInfoSheet extends StatefulWidget {
  final String char;
  final KanjiEntry? entry;
  const KanjiInfoSheet({super.key, required this.char, this.entry});

  @override
  State<KanjiInfoSheet> createState() => _KanjiInfoSheetState();
}

class _KanjiInfoSheetState extends State<KanjiInfoSheet> {
  List<ReadingGroup>? _groups;

  @override
  void initState() {
    super.initState();
    WordService.instance.wordsForKanji(widget.char).then((g) {
      if (mounted) setState(() => _groups = g);
    }).catchError((_) {
      if (mounted) setState(() => _groups = const []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final char = widget.char;
    final groups = _groups;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottomInset(context)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
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
                            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: AppColors.beni, height: 1),
                          ),
                        ),
                        // 한국 한자 훈음 — 한자 바로 밑
                        if (e != null && e.meanings.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SizedBox(
                              width: 92,
                              child: Text(
                                e.meaningJoined,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.25),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e == null || e.meanings.isEmpty
                                ? (e != null && e.meaningsEn.isNotEmpty ? e.meaningsEn : tr('(뜻 정보 없음)'))
                                : e.meaningJoined,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1.2),
                          ),
                          if (e != null && e.meanings.isNotEmpty && e.meaningsEn.isNotEmpty)
                            Text(e.meaningsEn, style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                          const SizedBox(height: 6),
                          if (e != null)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (e.jlpt != null) _Tag('JLPT N${e.jlpt}', AppColors.ai),
                                if (e.rank < 9999) _Tag(trf('회화 #{0}', [e.rank]), AppColors.beni),
                                if (e.strokes != null) _Tag(trf('{0}획', [e.strokes]), AppColors.kinDeep),
                                if (e.grade != null) _Tag(e.grade! <= 6 ? trf('초{0}', [e.grade]) : tr('중학'), AppColors.matcha),
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
                  if (e.on.isNotEmpty) _ReadingRow(label: tr('음독'), color: AppColors.ai, readings: e.on),
                  if (e.kun.isNotEmpty) _ReadingRow(label: tr('훈독'), color: AppColors.matcha, readings: e.kun),
                ],
                // 대표 단어 — 회화 빈도순 1~2개
                if (e != null && e.words.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.washiDeep,
                      border: Border.all(color: AppColors.beni.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('대표 단어 (빈도순)'),
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.beni, letterSpacing: 1)),
                        const SizedBox(height: 6),
                        ...e.words.take(2).map((w) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(w.word,
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.sumi)),
                                  const SizedBox(width: 8),
                                  if (w.ko.isNotEmpty)
                                    Expanded(
                                        child: Text(w.ko,
                                            style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)))
                                  else
                                    const Spacer(),
                                  Text('#${w.rank}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => TtsService.instance.speak(w.word),
                                    child: const Icon(Icons.volume_up, size: 16, color: AppColors.beni),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SealStamp(text: '語', size: 20),
                    const SizedBox(width: 8),
                    Text(tr('읽기별 단어'),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1.5)),
                    const SizedBox(width: 6),
                    if (groups != null)
                      Text(trf('{0}어 · {1}읽기', [groups.fold<int>(0, (n, g) => n + g.words.length), groups.length]),
                          style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
                  ],
                ),
                const SizedBox(height: 8),
                if (groups == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                        child: SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.beni))),
                  )
                else if (groups.isEmpty)
                  Text(tr('연결된 단어가 아직 없어요.'), style: TextStyle(fontSize: 12, color: AppColors.sumiLight))
                else
                  ...groups.map((g) => _ReadingGroupBlock(char: char, group: g)),
                if (e != null && e.words.isNotEmpty && (groups == null || groups.isEmpty)) ...[
                  const SizedBox(height: 8),
                  ...e.words.take(6).map((w) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(w.word,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.sumi))),
                            if (w.ko.isNotEmpty)
                              Expanded(child: Text(w.ko, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight))),
                            Text('#${w.rank}', style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
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

/// 읽기 1개 그룹 — 헤더(읽기 + 개수) + 단어 칩(루비)
class _ReadingGroupBlock extends StatelessWidget {
  final String char;
  final ReadingGroup group;
  const _ReadingGroupBlock({required this.char, required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.washiDeep, border: Border.all(color: AppColors.kin.withValues(alpha: 0.6))),
                child: Text(
                  '$char = ${group.reading}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.ai),
                ),
              ),
              const SizedBox(width: 6),
              Text(trf('{0}어', [group.words.length]), style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: group.words
                .map((w) => InkWell(
                      onTap: () => showWordSheet(context, w),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        decoration: BoxDecoration(
                          color: AppColors.washi,
                          border: Border.all(color: AppColors.kin.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FuriganaText(segs: w.segs, fontSize: 17, tappable: false, highlightChar: char),
                            if (w.gloss.isNotEmpty)
                              Text(
                                '${w.jlptLabel} · ${w.gloss}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 10, color: w.hasKo ? AppColors.sumi : AppColors.sumiLight),
                              ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
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
