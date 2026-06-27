import 'package:flutter/material.dart';
import '../theme.dart';
import 'sakura_scatter.dart';

/// 종이 배경 + 사쿠라 데코 — 모든 Scaffold 의 body 를 감쌈.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool scatter;
  final int scatterSeed;
  const AppBackground({super.key, required this.child, this.scatter = true, this.scatterSeed = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.paper),
      child: scatter ? SakuraScatter(seed: scatterSeed, count: 14, child: child) : child,
    );
  }
}
