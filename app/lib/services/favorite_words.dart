// 포팅 from db/legacy/services_favoritewords.ts
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteWords {
  static const _k = 'favoriteWords.ids';
  Set<String>? _cache;

  Future<Set<String>> _load() async {
    if (_cache != null) return _cache!;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null || raw.isEmpty) {
      _cache = <String>{};
      return _cache!;
    }
    try {
      final arr = jsonDecode(raw) as List;
      _cache = arr.cast<String>().toSet();
    } catch (_) {
      _cache = <String>{};
    }
    return _cache!;
  }

  Future<bool> toggle(String id) async {
    final s = await _load();
    if (s.contains(id)) {
      s.remove(id);
    } else {
      s.add(id);
    }
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(s.toList()));
    return s.contains(id);
  }

  Future<bool> has(String id) async {
    final s = await _load();
    return s.contains(id);
  }

  Future<int> count() async {
    final s = await _load();
    return s.length;
  }

  Future<List<String>> all() async {
    final s = await _load();
    return s.toList()..sort();
  }
}
