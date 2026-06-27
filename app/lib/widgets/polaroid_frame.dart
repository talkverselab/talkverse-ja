import 'package:flutter/material.dart';
import '../theme.dart';

/// 폴라로이드 프레임 (soft) — 흰 액자 + 캡션 + 부드러운 그림자.
class PolaroidFrame extends StatelessWidget {
  final Widget photo;
  final String caption;
  final double rotation;
  final Color frameColor;
  final double width;
  final double height;

  const PolaroidFrame({
    super.key,
    required this.photo,
    required this.caption,
    this.rotation = -1.5,
    this.frameColor = AppColors.cardFront,
    this.width = 120,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation * 3.14159 / 180,
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        decoration: BoxDecoration(
          color: frameColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.inkOutline, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.14),
              offset: const Offset(0, 4),
              blurRadius: 10,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width - 16,
              height: height - 50,
              decoration: BoxDecoration(
                color: AppColors.paperDeep,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(child: photo),
            ),
            const SizedBox(height: 6),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
