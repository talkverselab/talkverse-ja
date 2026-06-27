// 사용자 프로필 — 이름·학습 시작일 (shared_preferences).
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  static const _kName = 'profile.name';
  static const _kStartDate = 'profile.startDate'; // ISO date string

  /// 사용자 이름 (기본: 익명 학습자).
  Future<String> getName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kName) ?? '익명 학습자';
  }

  Future<void> setName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, name.trim());
  }

  /// 학습 시작일 (앱 첫 진입 시 자동 기록).
  Future<DateTime> getStartDate() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_kStartDate);
    if (v != null) {
      final d = DateTime.tryParse(v);
      if (d != null) return d;
    }
    final now = DateTime.now();
    await p.setString(_kStartDate, now.toIso8601String());
    return now;
  }

  /// 학습 시작 후 며칠 째.
  Future<int> daysSinceStart() async {
    final start = await getStartDate();
    final diff = DateTime.now().difference(start).inDays;
    return diff + 1; // 1일째 부터
  }
}
