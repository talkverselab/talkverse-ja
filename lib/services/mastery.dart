import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/prefs.dart';

/// 카드 숙련도 0~100%(사용자 지시 2026-11-11 uk 경유 「%로 하고 파랑에서 빨강으로」).
/// 알았음 +20 · 다시 −20(0 밑으로 안 감) · 오래 안 보면 7일마다 −5.
/// id 규칙 — 출시 뒤 회화 구성을 바꿔도 기록이 남게 내용 기준으로 둔다:
///   단어 `w:<표기>` · 회화 줄 `s:<편 id>:<턴 번호>`.
class Mastery {
  Mastery._();
  static const _key = 'mastery_v1';
  static const step = 20;
  static const decayPerWeek = 5;
  static final Map<String, (int, String)> _m = {}; // id → (%, 마지막 본 날 yyyy-mm-dd)
  static final ValueNotifier<int> version = ValueNotifier(0);
  static bool _loaded = false;
  static DateTime Function() clock = DateTime.now;

  static String _ymd(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<void> load() async {
    if (_loaded) return;
    final p = await Prefs.getInstance();
    final raw = p.getString(_key);
    if (raw != null) {
      final j = json.decode(raw) as Map<String, dynamic>;
      j.forEach((k, v) {
        final l = v as List;
        _m[k] = ((l[0] as num).toInt(), l[1] as String);
      });
    } else {
      // 옛 20어 단원 기록(wcard:<낱말> 2 = 알아요) → 40%
      final today = _ymd(clock());
      for (final k in p.getKeys()) {
        if (k.startsWith('wcard:') && p.getInt(k) == 2) _m['w:${k.substring(6)}'] = (40, today);
      }
      if (_m.isNotEmpty) await _save();
    }
    _loaded = true;
    version.value++;
  }

  static Future<void> _save() async {
    final p = await Prefs.getInstance();
    await p.setString(_key, json.encode({for (final e in _m.entries) e.key: [e.value.$1, e.value.$2]}));
  }

  /// 지금 숙련도(오래 안 본 만큼 깎은 값). 기록 없으면 0.
  static int pct(String id) {
    final e = _m[id];
    if (e == null) return 0;
    final last = DateTime.tryParse(e.$2);
    if (last == null) return e.$1;
    final days = clock().difference(last).inDays;
    return (e.$1 - (days ~/ 7) * decayPerWeek).clamp(0, 100);
  }

  static bool seen(String id) => _m.containsKey(id);

  static int average(Iterable<String> ids) {
    final l = ids.toList();
    if (l.isEmpty) return 0;
    return (l.map(pct).fold<int>(0, (a, b) => a + b) / l.length).round();
  }

  static Future<int> mark(String id, {required bool known}) async {
    final v = (pct(id) + (known ? step : -step)).clamp(0, 100);
    _m[id] = (v, _ymd(clock()));
    version.value++;
    await _save();
    return v;
  }

  /// 시험용 — 메모리만 비운다.
  static void resetForTest() {
    _m.clear();
    _loaded = false;
  }
}

/// 0% 파랑 → 100% 빨강 연속 색.
Color masteryColor(int pct) => Color.lerp(const Color(0xFF2F6FDB), const Color(0xFFD83A3A), pct.clamp(0, 100) / 100)!;

/// 「40%」 알약 — 숙련도 색 바탕.
class MasteryPill extends StatelessWidget {
  final int pct;
  final double fontSize;
  const MasteryPill(this.pct, {super.key, this.fontSize = 11});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: fontSize * 0.6, vertical: 2),
        decoration: BoxDecoration(color: masteryColor(pct), borderRadius: BorderRadius.circular(20)),
        child: Text('$pct%', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: Colors.white)),
      );
}
