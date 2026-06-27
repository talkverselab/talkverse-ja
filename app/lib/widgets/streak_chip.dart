import 'package:flutter/material.dart';
import '../theme.dart';

class StreakChip extends StatelessWidget {
  final int streak;
  const StreakChip({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.honey,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.inkOutline, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.10),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$streak 日',
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
