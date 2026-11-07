import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../services/learner_prefs.dart';

/// 후리가나 표시/미표시 버튼(앱바용) — 전역 `LearnerPrefs.furigana` 하나를 바꾼다. 기본 미표시.
/// 표시로 켤 때는 「힘들어도 후리가나를 보지 않고 익혀보세요」를 한 번 알린다(사용자 지시 2026-11-07).
class FuriganaToggleAction extends StatelessWidget {
  const FuriganaToggleAction({super.key});

  static Future<void> toggle(BuildContext context) async {
    final on = !LearnerPrefs.furigana.value;
    await LearnerPrefs.setFurigana(on);
    if (on && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(tr('힘들어도 후리가나를 보지 않고 익혀보세요')),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.sumi,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return ValueListenableBuilder<bool>(
      valueListenable: LearnerPrefs.furigana,
      builder: (context, on, _) {
        final color = on ? AppColors.ai : base.withValues(alpha: 0.35);
        return IconButton(
          tooltip: on ? tr('후리가나 숨기기') : tr('후리가나 표시'),
          onPressed: () => toggle(context),
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(border: Border.all(color: color, width: 1.2), borderRadius: BorderRadius.circular(6)),
            child: Text('ふ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, decoration: on ? null : TextDecoration.lineThrough)),
          ),
        );
      },
    );
  }
}
