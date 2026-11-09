import 'package:flutter/material.dart';
import '../core/prefs.dart';

import '../screens/paywall_screen.dart';
import 'account.dart';
import 'purchase.dart';

/// 무료/유료 구분(한자앱 `lib/data/entitlement.dart` 방식, 2026-11-02 APP_GUIDE).
/// `premium` = 기기 제작용 스위치 OR Talkverse 계정 이용권(lang 'ja', auth.talkverse.uk) OR 이 기기에서 산·복원한 평생 이용권(스토어).
/// 지금 유료로 잠긴 것: 맞춤 회화 2편째부터(첫 1편 무료). 회화·단어·한자·복습은 전부 무료.
class Entitlement {
  Entitlement._();
  static const lang = 'ja';
  static bool _local = false;
  static bool get premium => _local || Account.has(lang) || Purchase.owns(lang);

  static Future<void> load() async => _local = (await Prefs.getInstance()).getBool('premium') ?? false;
  static Future<void> set(bool v) async {
    _local = v;
    (await Prefs.getInstance()).setBool('premium', v);
  }

  /// 잠금 안내 + 평생 이용권 구매·복원 시트.
  static Future<void> showPaywall(BuildContext context) => PaywallScreen.show(context);
}
