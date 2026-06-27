import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// 배경에 사쿠라/클로버/별 데코를 흩뿌리기 (soft — 더 옅게).
class SakuraScatter extends StatelessWidget {
  final Widget child;
  final int seed;
  final int count;
  final double minSize;
  final double maxSize;

  const SakuraScatter({
    super.key,
    required this.child,
    this.seed = 7,
    this.count = 14,
    this.minSize = 10,
    this.maxSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScatterPainter(seed, count, minSize, maxSize),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScatterPainter extends CustomPainter {
  final int seed;
  final int count;
  final double minSize;
  final double maxSize;

  _ScatterPainter(this.seed, this.count, this.minSize, this.maxSize);

  static const _glyphs = ['❀', '✿', '♡', '◌', '・'];
  static const _colors = [
    AppColors.sakura,
    AppColors.honey,
    AppColors.clover,
    AppColors.violet,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = minSize + rng.nextDouble() * (maxSize - minSize);
      final glyph = _glyphs[rng.nextInt(_glyphs.length)];
      final color = _colors[rng.nextInt(_colors.length)].withValues(alpha: 0.18);
      final angle = (rng.nextDouble() - 0.5) * 0.6;
      final tp = TextPainter(
        text: TextSpan(text: glyph, style: TextStyle(fontSize: s, color: color)),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScatterPainter old) => false;
}
