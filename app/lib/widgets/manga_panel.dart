import 'package:flutter/material.dart';
import '../theme.dart';

/// 만화 패널 (soft edition) — 부드러운 회보라 테두리 + 워터컬러 그림자 + 살짝 기울어짐.
class MangaPanel extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double rotation; // degree
  final double borderWidth;
  final double radius;
  final EdgeInsets padding;
  final BoxShadow? shadow;
  final VoidCallback? onTap;

  const MangaPanel({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.rotation = 0,
    this.borderWidth = 1.2,
    this.radius = 14,
    this.padding = const EdgeInsets.all(16),
    this.shadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardFront,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.inkOutline, width: borderWidth),
        boxShadow: [
          shadow ??
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.10),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: -2,
              ),
        ],
      ),
      child: child,
    );
    final rotated = rotation == 0
        ? body
        : Transform.rotate(angle: rotation * 3.14159 / 180, child: body);
    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: rotated,
      );
    }
    return rotated;
  }
}
