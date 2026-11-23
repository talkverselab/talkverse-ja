import 'package:flutter/material.dart';

import '../screens/paywall_screen.dart';
import 'account.dart';
import 'curriculum_plan.dart';
import 'dialogue_service.dart';
import 'entitlement.dart';
import 'purchase.dart';

/// 이용권 잠금 — 무료/유료 범위는 서버 커리큘럼 JSON(단계·급수 free, freeSenseLevels)이 정한다(PAYWALL_SPEC, 2026-11-23).
/// 잠긴 곳은 숨기지 않고 자물쇠를 보이고, 누르면 결제 화면.
class PaywallGate {
  PaywallGate._();

  /// 이용권·계정이 바뀌면 다시 그릴 것.
  static final Listenable changes = Listenable.merge([Purchase.owned, Account.user]);
  static bool get premium => Entitlement.premium;

  static CurriculumPlan? get _plan => CurriculumPlanStore.instance.plan;
  static Future<void> ensure() async => CurriculumPlanStore.instance.load();

  static bool dialogueFree(Dialogue d) => isDialogueFree(d.id, d.region, _plan);
  static bool dialogueOpen(Dialogue d) => premium || dialogueFree(d);

  /// 언어감각 급(0부터) 이 무료인가.
  static bool senseLevelFree(int levelIndex) => levelIndex < (_plan?.freeSenseLevels ?? 1);

  /// 열 수 있으면 true. 잠겨 있으면 결제 화면을 띄우고, 산 뒤 열리면 true.
  static Future<bool> pass(BuildContext context, bool free) async {
    if (free || premium) return true;
    await PaywallScreen.show(context);
    return premium;
  }
}

/// 잠금 표시(자물쇠).
class LockBadge extends StatelessWidget {
  final double size;
  const LockBadge({super.key, this.size = 18});
  @override
  Widget build(BuildContext context) => Icon(Icons.lock_outline, size: size, color: const Color(0xFF9A5F38));
}
