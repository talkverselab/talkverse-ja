// 카드 별 사용자 메모 — shared_preferences 키 schema 유지 (옛 ja-lab TS 와 동일).
//   userMemo:v1:{level}:{turn}
import 'package:shared_preferences/shared_preferences.dart';

class UserMemo {
  static const _kPrefix = 'userMemo:v1:';

  static String _k(String level, int turn) => '$_kPrefix$level:$turn';

  /// turn = 카드 id 의 hash (or 일관된 정수). level = 덱 id.
  static Future<String> get(String level, int turn) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_k(level, turn)) ?? '';
  }

  static Future<void> set(String level, int turn, String memo) async {
    final p = await SharedPreferences.getInstance();
    if (memo.trim().isEmpty) {
      await p.remove(_k(level, turn));
    } else {
      await p.setString(_k(level, turn), memo);
    }
  }

  static Future<bool> has(String level, int turn) async {
    final v = await get(level, turn);
    return v.trim().isNotEmpty;
  }

  /// 한 레벨의 모든 메모 (export 용).
  static Future<List<MapEntry<int, String>>> all(String level) async {
    final p = await SharedPreferences.getInstance();
    final target = '$_kPrefix$level:';
    final result = <MapEntry<int, String>>[];
    for (final k in p.getKeys()) {
      if (!k.startsWith(target)) continue;
      final turn = int.tryParse(k.substring(target.length));
      if (turn == null) continue;
      final memo = p.getString(k);
      if (memo != null && memo.trim().isNotEmpty) {
        result.add(MapEntry(turn, memo));
      }
    }
    result.sort((a, b) => a.key.compareTo(b.key));
    return result;
  }

  /// 전체 메모 카운트.
  static Future<int> count() async {
    final p = await SharedPreferences.getInstance();
    return p
        .getKeys()
        .where((k) => k.startsWith(_kPrefix))
        .where((k) => (p.getString(k) ?? '').trim().isNotEmpty)
        .length;
  }
}
