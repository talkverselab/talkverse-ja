import 'package:flutter/material.dart';
import '../theme.dart';

/// 만화 말풍선 (soft edition) — 둥근 사각형 + 부드러운 회보라 테두리 + 작은 꼬리.
class SpeechBubble extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets padding;
  final TailSide tailSide;
  final double radius;

  const SpeechBubble({
    super.key,
    required this.child,
    this.color = const Color(0xFFFFFEFB),
    this.borderColor = AppColors.inkOutline,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 14),
    this.tailSide = TailSide.left,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
        tailSide: tailSide,
        radius: radius,
      ),
      child: Padding(
        padding: padding.copyWith(bottom: padding.bottom + 8),
        child: child,
      ),
    );
  }
}

enum TailSide { left, right }

class _BubblePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final TailSide tailSide;
  final double radius;

  _BubblePainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.tailSide,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 8);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // soft drop shadow
    final shadowPath = Path()..addRRect(rrect.shift(const Offset(0, 3)));
    final shadowPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(shadowPath, shadowPaint);

    // body fill
    final fill = Paint()..color = color;
    final path = Path()..addRRect(rrect);
    final tailX = tailSide == TailSide.left ? 24.0 : size.width - 36.0;
    path.moveTo(tailX, size.height - 8);
    path.lineTo(tailX + 5, size.height);
    path.lineTo(tailX + 13, size.height - 8);
    path.close();
    canvas.drawPath(path, fill);

    // border — 얇은 회보라
    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.color != color ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.tailSide != tailSide ||
      old.radius != radius;
}
