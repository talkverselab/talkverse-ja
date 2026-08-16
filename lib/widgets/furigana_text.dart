import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/word_service.dart';
import 'selectable_ja_text.dart';

/// 후리가나(루비) 텍스트 — 분절 위에 읽기 표시. 한자 탭 → 한자 정보 시트 (tappable=true).
class FuriganaText extends StatelessWidget {
  final List<FuriSeg> segs;
  final double fontSize;
  final Color color;
  final Color rubyColor;
  final bool tappable;
  final bool showRuby;
  final String? highlightChar; // 이 한자 분절 강조

  const FuriganaText({
    super.key,
    required this.segs,
    this.fontSize = 22,
    this.color = AppColors.sumi,
    this.rubyColor = AppColors.ai,
    this.tappable = true,
    this.showRuby = true,
    this.highlightChar,
  });

  Future<void> _tap(BuildContext context, String text) async {
    await KanjiIndexService.instance.ensureLoaded();
    if (!context.mounted) return;
    final entry = KanjiIndexService.instance.lookup(text);
    await showKanjiSheet(context, char: text, entry: entry);
  }

  @override
  Widget build(BuildContext context) {
    final rubySize = (fontSize * 0.48).clamp(9.0, 14.0);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: segs.map((s) {
        final isKanjiSeg = s.reading != null;
        final single = isKanjiSeg && s.text.runes.length == 1 && KanjiIndexService.isKanji(s.text);
        final highlighted = highlightChar != null && s.text == highlightChar;
        final base = Text(
          s.text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: color, height: 1.15),
        );
        final column = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRuby)
              SizedBox(
                height: rubySize + 2,
                child: isKanjiSeg
                    ? Text(s.reading!, style: TextStyle(fontSize: rubySize, color: rubyColor, fontWeight: FontWeight.w700, height: 1))
                    : null,
              ),
            base,
          ],
        );
        final wrapped = Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          decoration: highlighted
              ? BoxDecoration(color: AppColors.kin.withValues(alpha: 0.3), border: Border(bottom: BorderSide(color: AppColors.beni, width: 2)))
              : null,
          child: column,
        );
        if (tappable && single) {
          return InkWell(onTap: () => _tap(context, s.text), child: wrapped);
        }
        return wrapped;
      }).toList(),
    );
  }
}
