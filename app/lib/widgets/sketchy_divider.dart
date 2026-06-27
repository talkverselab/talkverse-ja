import 'package:flutter/material.dart';
import '../theme.dart';

/// 손그림 풍 구분선 — 얇고 부드러움.
class SketchyDivider extends StatelessWidget {
  final double height;
  final double indent;
  final Color color;
  final String? caption;

  const SketchyDivider({
    super.key,
    this.height = 36,
    this.indent = 0,
    this.color = AppColors.inkLight,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        margin: EdgeInsets.symmetric(horizontal: indent),
        color: color,
      ),
    );
    return SizedBox(
      height: height,
      child: Row(
        children: [
          line,
          if (caption != null) ...[
            const SizedBox(width: 10),
            Text(
              caption!,
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.0),
            ),
            const SizedBox(width: 10),
          ],
          line,
        ],
      ),
    );
  }
}
