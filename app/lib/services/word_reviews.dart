// 포팅 from db/legacy/services_wordreviews.ts (AsyncStorage → shared_preferences)
// SRS stage 0-6, AsyncStorage 동일 키 형식 유지.
//
// key 형식:
//   wordReviews.{id}.stage  — 0-6
//   wordReviews.{id}.due    — ISO date (다음 복습일)
import 'package:shared_preferences/shared_preferences.dart';

class WordReviews {
  // dart: _intervals — SRS 간격 (일)
  static const List<int> intervals = [1, 1, 2, 4, 7, 14, 30];

  String _stageKey(String id) => 'wordReviews.$id.stage';
  String _dueKey(String id) => 'wordReviews.$id.due';

  Future<int> getStage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_stageKey(id)) ?? 0;
  }

  Future<int> recordKnown(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final cur = prefs.getInt(_stageKey(id)) ?? 0;
    final next = (cur + 1).clamp(0, 6);
    final days = intervals[next];
    final due = DateTime.now().add(Duration(days: days));
    await prefs.setInt(_stageKey(id), next);
    await prefs.setString(_dueKey(id), due.toIso8601String());
    return next;
  }

  Future<void> recordUnknown(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final due = DateTime.now().add(const Duration(days: 1));
    await prefs.setInt(_stageKey(id), 0);
    await prefs.setString(_dueKey(id), due.toIso8601String());
  }

  /// "보통" — stage 유지 (+/-X), 복습 간격은 현재 stage 의 절반.
  Future<int> recordSoso(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final cur = prefs.getInt(_stageKey(id)) ?? 0;
    final days = (intervals[cur] / 2).ceil().clamp(1, 30);
    final due = DateTime.now().add(Duration(days: days));
    await prefs.setString(_dueKey(id), due.toIso8601String());
    return cur;
  }

  /// 오늘 복습 due 인 카드 수.
  Future<int> reviewDueCount() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('wordReviews.') && k.endsWith('.due'));
    final now = DateTime.now();
    int cnt = 0;
    for (final k in keys) {
      final v = prefs.getString(k);
      if (v == null) continue;
      final t = DateTime.tryParse(v);
      if (t != null && !t.isAfter(now)) cnt++;
    }
    return cnt;
  }

  /// stage 분포 (0~6 별 카운트).
  Future<Map<int, int>> stageDistribution() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('wordReviews.') && k.endsWith('.stage'));
    final dist = <int, int>{for (var i = 0; i <= 6; i++) i: 0};
    for (final k in keys) {
      final s = prefs.getInt(k) ?? 0;
      dist[s] = (dist[s] ?? 0) + 1;
    }
    return dist;
  }

  /// 학습된 (stage > 0) 카드 총 수 = unlock tree 의 기준.
  Future<int> learnedCount() async {
    final dist = await stageDistribution();
    int sum = 0;
    for (final e in dist.entries) {
      if (e.key > 0) sum += e.value;
    }
    return sum;
  }
}
