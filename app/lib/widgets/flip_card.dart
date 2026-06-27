import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D rotateY 카드 — vi-lab 의 FlipCard 패턴 (400ms / cubic / backfaceVisibility).
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool flipped;
  final VoidCallback? onTap;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.flipped,
    this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    if (widget.flipped) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipped != oldWidget.flipped) {
      if (widget.flipped) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final angle = _anim.value * math.pi;
          final isBack = angle > math.pi / 2;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: widget.back,
                  )
                : widget.front,
          );
        },
      ),
    );
  }
}
