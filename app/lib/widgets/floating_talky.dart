import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'talky_character.dart';
import 'talky_mascot.dart' show TalkyMood;

/// 드래그 가능 + sine bob 으로 떠다니는 TalkY.
/// home_dashboard 등에서 Stack 오버레이로 띄움.
class FloatingTalky extends StatefulWidget {
  final TalkyMood mood;
  final double size;
  final Offset initialOffset; // Scaffold body 기준 (top-left)
  final VoidCallback? onTap;
  final EdgeInsets boundary; // 드래그 가능 영역 마진 (Stack 부모)

  const FloatingTalky({
    super.key,
    this.mood = TalkyMood.idle,
    this.size = 80,
    this.initialOffset = const Offset(24, 24),
    this.onTap,
    this.boundary = const EdgeInsets.all(8),
  });

  @override
  State<FloatingTalky> createState() => _FloatingTalkyState();
}

class _FloatingTalkyState extends State<FloatingTalky> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  Offset _pos = Offset.zero;
  bool _dragging = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _pos = widget.initialOffset;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Offset _clamp(Offset p, Size parent) {
    final maxX = parent.width - widget.size - widget.boundary.right;
    final maxY = parent.height - widget.size - widget.boundary.bottom;
    final minX = widget.boundary.left;
    final minY = widget.boundary.top;
    return Offset(
      p.dx.clamp(minX, maxX < minX ? minX : maxX),
      p.dy.clamp(minY, maxY < minY ? minY : maxY),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parent = constraints.biggest;
        // 초기 위치 기본값: 우측 하단 — initialOffset 이 (0,0) 이면 우하단으로
        if (!_initialized && parent.width.isFinite && parent.height.isFinite) {
          final desired = widget.initialOffset == Offset.zero
              ? Offset(parent.width - widget.size - 24, parent.height - widget.size - 100)
              : widget.initialOffset;
          _pos = _clamp(desired, parent);
          _initialized = true;
        }

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final t = _ctrl.value * 2 * math.pi;
                final bob = _dragging ? 0.0 : math.sin(t) * 5.0;
                final tilt = _dragging ? 0.0 : math.sin(t * 0.5) * 0.04;
                return Positioned(
                  left: _pos.dx,
                  top: _pos.dy + bob,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTap,
                    onPanStart: (_) => setState(() => _dragging = true),
                    onPanUpdate: (d) {
                      setState(() {
                        _pos = _clamp(_pos + d.delta, parent);
                      });
                    },
                    onPanEnd: (_) => setState(() => _dragging = false),
                    child: Transform.rotate(
                      angle: tilt,
                      child: AnimatedScale(
                        scale: _dragging ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: TalkyCharacter(mood: widget.mood, size: widget.size),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
