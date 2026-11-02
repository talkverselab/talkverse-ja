import 'dart:math';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../services/hanja_family_service.dart';
import '../services/morph_cache.dart';
import 'morph_player.dart';

/// 소리 가족 마인드맵 — 한자앱 `lib/widgets/family_map.dart` 복제(한자 세션 지시 2026-11-02).
/// 가운데 씨앗(소리 부품)에서 가지가 뻗고, 가지 색은 한국 한자음이 씨앗과 얼마나 같은지(동일/거의 비슷/조금 다름/다름).
/// 선이 글자·훈을 지나가지 않게: 바깥 줄 선은 안쪽 줄 너머에서 시작, 훈은 늘 바깥쪽. 일본어앱은 글자를 jp 자형, 원 아래 음독을 함께 보여 준다.
class FamilyMap extends StatelessWidget {
  final HanjaChar root;
  final List<HanjaChar> members;
  final void Function(HanjaChar)? onTap;
  final Set<String> highlight;
  const FamilyMap({super.key, required this.root, required this.members, this.onTap, this.highlight = const {}});

  static const colors = [Color(0xFF1E8A4C), Color(0xFF2F6FD6), Color(0xFFE07A10), Color(0xFF9A9288)];
  static const fills = [Color(0xFFDDF3E4), Color(0xFFDDE8FB), Color(0xFFFCEBD6), Color(0xFFEEEBE5)];
  static List<String> get labels => [tr('동일'), tr('거의 비슷'), tr('조금 다름'), tr('다름')];

  /// 0 동일 · 1 거의 비슷(받침만 또는 첫소리만 다름) · 2 조금 다름 · 3 다름 — 한글 한 음절 비교.
  static int rel(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 3;
    if (a == b) return 0;
    final x = a.runes.first - 0xAC00, y = b.runes.first - 0xAC00;
    if (x < 0 || y < 0 || x > 11171 || y > 11171) return 3;
    final c1 = x ~/ 588, c2 = y ~/ 588, v1 = (x % 588) ~/ 28, v2 = (y % 588) ~/ 28, f1 = x % 28, f2 = y % 28;
    if (v1 == v2 && (c1 == c2 || f1 == f2)) return 1;
    if (v1 == v2 || (c1 == c2 && f1 == f2)) return 2;
    return 3;
  }

  /// 독음이 여럿인 글자는 씨앗과 가장 가까운 소리로.
  static (int, String) best(String ref, HanjaChar h) {
    final sounds = h.krHun.split(',').map((x) => x.trim().split(' ').last).where((x) => x.isNotEmpty).toList();
    if (sounds.isEmpty) return (3, '');
    var r = 4, s = sounds.first;
    for (final x in sounds) {
      final k = rel(ref, x);
      if (k < r) {
        r = k;
        s = x;
      }
    }
    return (r, s);
  }

  /// 가운데 씨앗을 누르면 모핑 그림 + 훈음.
  static void showCenter(BuildContext context, HanjaChar h) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.washi,
      builder: (c) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${h.jp}  ${h.krHun}${h.on.isNotEmpty ? '  ·  ${h.on}' : ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
          const SizedBox(height: 12),
          MorphPlayer(morphFile: h.morphFile, status: h.morphStatus, glyph: h.jp, size: min(MediaQuery.sizeOf(c).width - 32, 360)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sound = root.krSound;
    final items = [for (final m in members.take(28)) (m, best(sound, m))]..sort((a, b) => a.$2.$1.compareTo(b.$2.$1));
    final counts = [for (var i = 0; i < colors.length; i++) items.where((e) => e.$2.$1 == i).length];
    return Column(mainAxisSize: MainAxisSize.min, children: [
      LayoutBuilder(builder: (context, c) {
        final w = min(c.maxWidth, 420.0);
        final n = items.length;
        final two = n > 10;
        final node = two ? 42.0 : 52.0;
        const hunH = 16.0;
        final cx = w / 2, cy = w / 2;
        final rOut = w / 2 - node / 2 - hunH - 4;
        final rIn = rOut * 0.56;
        final pos = <Offset>[];
        final starts = <double>[];
        for (var i = 0; i < n; i++) {
          final a = -pi / 2 + 2 * pi * i / max(n, 1);
          final outer = !two || i.isEven;
          final r = outer ? rOut : rIn;
          pos.add(Offset(cx + cos(a) * r, cy + sin(a) * r));
          starts.add(two && outer ? rIn + node / 2 + hunH + 6 : 38);
        }
        return SizedBox(
          width: w,
          height: w,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _Lines(Offset(cx, cy), pos, [for (final e in items) colors[e.$2.$1]], starts, node / 2, bend: two ? 0 : 0.06))),
            for (var i = 0; i < n; i++)
              Positioned(
                left: pos[i].dx - node / 2 - 14,
                top: pos[i].dy < cy - 1 ? pos[i].dy - node / 2 - hunH : pos[i].dy - node / 2,
                width: node + 28,
                height: node + hunH,
                child: GestureDetector(
                  onTap: onTap == null ? null : () => onTap!(items[i].$1),
                  behavior: HitTestBehavior.opaque,
                  child: Column(mainAxisSize: MainAxisSize.min, verticalDirection: pos[i].dy < cy - 1 ? VerticalDirection.up : VerticalDirection.down, children: [
                    Container(
                      width: node,
                      height: node,
                      decoration: BoxDecoration(
                        color: fills[items[i].$2.$1],
                        shape: BoxShape.circle,
                        border: Border.all(color: colors[items[i].$2.$1], width: highlight.contains(items[i].$1.code) ? 3.2 : 1.2),
                      ),
                      alignment: Alignment.center,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(items[i].$1.jp, style: TextStyle(fontSize: node * 0.42, height: 1.05, color: AppColors.sumi)),
                        Text(items[i].$1.on.isNotEmpty ? items[i].$1.on : items[i].$2.$2, style: TextStyle(fontSize: node * 0.18, height: 1, fontWeight: FontWeight.w800, color: colors[items[i].$2.$1])),
                      ]),
                    ),
                    Container(
                      height: hunH,
                      alignment: pos[i].dy < cy - 1 ? Alignment.bottomCenter : Alignment.topCenter,
                      child: Text(items[i].$1.hun, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, height: 1.2, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                    ),
                  ]),
                ),
              ),
            Positioned(
              left: cx - 38,
              top: cy - 38,
              width: 76,
              height: 76,
              child: GestureDetector(
                onTap: () => showCenter(context, root),
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.sumi, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(root.jp, style: const TextStyle(fontSize: 32, height: 1.05, color: Colors.white)),
                    Text('${root.hun} $sound${root.on.isNotEmpty ? ' · ${root.on}' : ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, height: 1.1, fontWeight: FontWeight.w800, color: AppColors.kinBright)),
                  ]),
                ),
              ),
            ),
          ]),
        );
      }),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 4, alignment: WrapAlignment.center, children: [
        for (var i = 0; i < colors.length; i++)
          if (counts[i] > 0)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('${labels[i]} ${counts[i]}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colors[i])),
            ]),
      ]),
      if (members.length > 28) Padding(padding: const EdgeInsets.only(top: 4), child: Text('+${members.length - 28}', style: const TextStyle(fontSize: 12, color: AppColors.muted))),
    ]);
  }
}

class _Lines extends CustomPainter {
  final Offset c;
  final List<Offset> pts;
  final List<Color> cols;
  final List<double> r0;
  final double r1;
  final double bend;
  _Lines(this.c, this.pts, this.cols, this.r0, this.r1, {this.bend = 0.06});
  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < pts.length; i++) {
      final p = Paint()
        ..color = cols[i].withValues(alpha: 0.75)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final d = pts[i] - c;
      final len = d.distance;
      if (len <= r0[i] + r1 + 4) continue;
      final u = d / len;
      final a = c + u * (r0[i] + 2), b = pts[i] - u * (r1 + 2);
      final mid = Offset.lerp(a, b, 0.5)!;
      final ctrl = mid + Offset(-u.dy, u.dx) * (len * bend);
      canvas.drawPath(Path()..moveTo(a.dx, a.dy)..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy), p);
    }
  }

  @override
  bool shouldRepaint(_Lines o) => o.pts != pts;
}

/// 모핑 캐시 미리 받기용(가족을 열 때).
Future<void> prefetchFamilyMorphs(BuildContext context, Iterable<HanjaChar> chars) =>
    MorphCache.prefetch([for (final h in chars) if (h.morphFile != null) h.morphFile!], large: MorphCache.wantsLarge(context));
