// 포팅 from db/legacy/services_userstats.ts
// streak / today / goal / lastDay.
import 'package:shared_preferences/shared_preferences.dart';

class UserStats {
  static const _kStreak = 'userStats.streak';
  static const _kToday = 'userStats.today';
  static const _kGoal = 'userStats.goal';
  static const _kLastDay = 'userStats.lastDay';

  String _todayKey() {
    final d = DateTime.now();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<int> getStreak() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kStreak) ?? 0;
  }

  Future<int> getToday() async {
    final p = await SharedPreferences.getInstance();
    final last = p.getString(_kLastDay);
    final td = _todayKey();
    if (last != td) {
      // 새 날 — today 0 으로 리셋
      await p.setInt(_kToday, 0);
      await p.setString(_kLastDay, td);
      // streak 끊김 체크 (어제 아니면 0)
      if (last != null) {
        final lastD = DateTime.tryParse(last);
        final yest = DateTime.now().subtract(const Duration(days: 1));
        if (lastD == null ||
            lastD.year != yest.year ||
            lastD.month != yest.month ||
            lastD.day != yest.day) {
          // 어제 학습 X = streak 끊김
          await p.setInt(_kStreak, 0);
        }
      }
      return 0;
    }
    return p.getInt(_kToday) ?? 0;
  }

  Future<int> getGoal() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kGoal) ?? 10;
  }

  Future<void> setGoal(int goal) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kGoal, goal);
  }

  Future<int> incrementToday({int by = 1}) async {
    final p = await SharedPreferences.getInstance();
    final cur = await getToday();
    final next = cur + by;
    await p.setInt(_kToday, next);
    final goal = await getGoal();
    // 처음으로 목표 도달 시 streak +1
    if (cur < goal && next >= goal) {
      final streak = await getStreak();
      await p.setInt(_kStreak, streak + 1);
    }
    return next;
  }
}
