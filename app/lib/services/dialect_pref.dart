// dialect (north 도쿄·표준 / south 간사이) 토글 — 설정에서 변경.
import 'package:shared_preferences/shared_preferences.dart';

enum Dialect { north, south }

class DialectPref {
  static const _k = 'pref.dialect';

  Future<Dialect> get() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_k) ?? 'north';
    return v == 'south' ? Dialect.south : Dialect.north;
  }

  Future<void> set(Dialect d) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, d == Dialect.south ? 'south' : 'north');
  }
}
