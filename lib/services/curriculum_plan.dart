import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/embed_env.dart';
import '../core/prefs.dart';

/// 토크버스 커리큘럼의 단계·편 목록 — 내용은 서버 DB 에서(사용자 지시 2026-11-23, CURRICULUM_SPEC.md §12).
///
/// 앱에 묶은 `assets/curriculum_ja.json` 이 기본값, 시작 때 `GET https://talkverse.uk/api/curriculum/ja` 의 rev 가 더 크면 받아 기기에 두고 그걸 쓴다.
/// 단계 = 1~5(서버가 몇 개든 그대로), 편이 0개인 단계는 숨김. ja 는 단계 아래 「JLPT 준비」(prep).
/// JSON 을 못 읽으면 회화 레벨(R0+R1 → 1단계, R2 → 2 …)로 만든 목록으로 돌아간다.
class CurLevel {
  final String key; // 진도 저장용: 단계 = '1'..'5', 준비 = 'jlpt:N5'
  final String title;
  final String desc;
  final List<String> dialogueIds;
  final List<int> pick;
  final int pass;
  final Map<String, int> daily; // light·normal·focus → 하루 새 편 수
  final String? wordSet; // 준비 급수의 단어 묶음(jlpt_n5 …)
  const CurLevel({
    required this.key,
    required this.title,
    this.desc = '',
    required this.dialogueIds,
    this.pick = const [3, 5, 10],
    this.pass = 80,
    this.daily = const {'light': 1, 'normal': 2, 'focus': 3},
    this.wordSet,
  });

  /// JLPT 단어 급수(jlpt_n5 → 5). 없으면 null.
  int? get jlptLevel {
    final m = RegExp(r'jlpt_n(\d)').firstMatch(wordSet ?? '');
    return m == null ? null : int.parse(m.group(1)!);
  }

  static CurLevel _parse(Map j, String key, {CurLevel? defaults}) {
    final daily = <String, int>{};
    final dj = j['daily'];
    if (dj is Map) {
      for (final e in dj.entries) {
        if (e.value is num) daily['${e.key}'] = (e.value as num).toInt();
      }
    }
    final pick = [for (final x in (j['pick'] as List? ?? const [])) if (x is num && x > 0) x.toInt()];
    return CurLevel(
      key: key,
      title: '${j['title'] ?? key}',
      desc: '${j['desc'] ?? ''}',
      dialogueIds: [for (final x in (j['dialogueIds'] as List? ?? const [])) '$x'],
      pick: pick.isEmpty ? (defaults?.pick ?? const [3, 5, 10]) : pick,
      pass: (j['pass'] as num?)?.toInt() ?? defaults?.pass ?? 80,
      daily: daily.isEmpty ? (defaults?.daily ?? const {'light': 1, 'normal': 2, 'focus': 3}) : daily,
      wordSet: j['wordSet'] as String?,
    );
  }
}

class CurPrep {
  final String id, title;
  final List<CurLevel> levels;
  const CurPrep(this.id, this.title, this.levels);
}

class CurriculumPlan {
  final int rev;
  final List<CurLevel> stages;
  final List<CurPrep> prep;
  const CurriculumPlan(this.rev, this.stages, this.prep);

  factory CurriculumPlan.fromJson(Map j) {
    final stages = <CurLevel>[
      for (final s in (j['stages'] as List? ?? const []))
        if (s is Map && s['n'] != null) CurLevel._parse(s, '${s['n']}'),
    ];
    final prep = <CurPrep>[
      for (final p in (j['prep'] as List? ?? const []))
        if (p is Map && p['id'] != null)
          CurPrep('${p['id']}', '${p['title'] ?? p['id']}', [
            for (final l in (p['levels'] as List? ?? const []))
              if (l is Map && l['id'] != null) CurLevel._parse(l, '${p['id']}:${l['id']}', defaults: stages.isEmpty ? null : stages.first),
          ]),
    ];
    if (stages.isEmpty) throw const FormatException('stages 없음');
    return CurriculumPlan((j['rev'] as num?)?.toInt() ?? 0, stages, prep);
  }

  /// JSON 이 없을 때: 회화 레벨로 단계를 만든다(R0+R1 → 1, R2 → 2 …).
  factory CurriculumPlan.fromRegions(Map<String, List<String>> idsByRegion) {
    final stages = <CurLevel>[];
    for (var n = 1; n <= 5; n++) {
      final ids = n == 1 ? [...?idsByRegion['R0'], ...?idsByRegion['R1']] : [...?idsByRegion['R$n']];
      stages.add(CurLevel(key: '$n', title: '$n단계', dialogueIds: ids));
    }
    return CurriculumPlan(0, stages, const []);
  }

  /// 모든 단계·준비 급수.
  Iterable<CurLevel> get all sync* {
    yield* stages;
    for (final p in prep) {
      yield* p.levels;
    }
  }

  CurLevel? byKey(String? key) {
    for (final l in all) {
      if (l.key == key) return l;
    }
    return null;
  }
}

/// 앱에 있는 편이 하나라도 있는 단계(급수)만 — 서버에서 빼면 사라지고 더하면 생긴다.
List<CurLevel> visibleLevels(Iterable<CurLevel> ls, bool Function(String id) has) => [for (final l in ls) if (l.dialogueIds.any(has)) l];

/// 옛 진도의 회화 레벨 값을 단계로(R0·R1 → '1', R2 → '2' …). 이미 단계·준비 키면 그대로.
String? migrateLevelKey(String? v) {
  if (v == null) return null;
  final m = RegExp(r'^R(\d)$').firstMatch(v);
  if (m == null) return v;
  final n = int.parse(m.group(1)!);
  return '${n <= 1 ? 1 : n}';
}

class CurriculumPlanStore {
  CurriculumPlanStore._();
  static final CurriculumPlanStore instance = CurriculumPlanStore._();
  static const lang = 'ja';
  static const url = 'https://talkverse.uk/api/curriculum/$lang';
  static const _asset = 'assets/curriculum_$lang.json';
  static const _prefKey = 'curriculum_plan';

  CurriculumPlan? plan;
  bool _checked = false;

  /// 시험용 — 서버 요청을 바꿔 끼운다.
  @visibleForTesting
  Future<String?> Function(String url)? fetch;
  @visibleForTesting
  Future<String?> Function()? bundled;

  /// 기본값(묶음) 과 기기에 받아 둔 서버 판 중 rev 가 큰 것.
  Future<CurriculumPlan?> load() async {
    if (plan != null) return plan;
    CurriculumPlan? best;
    try {
      final raw = bundled != null ? await bundled!() : await rootBundle.loadString(assetPath(_asset));
      if (raw != null) best = CurriculumPlan.fromJson(json.decode(raw) as Map);
    } catch (e) {
      debugPrint('Curriculum: 묶음 JSON 실패 $e');
    }
    try {
      final saved = (await Prefs.getInstance()).getString(_prefKey);
      if (saved != null) {
        final s = CurriculumPlan.fromJson(json.decode(saved) as Map);
        if (best == null || s.rev > best.rev) best = s;
      }
    } catch (_) {}
    return plan = best;
  }

  /// 서버 판을 확인하고 rev 가 더 크면 받아 둔다. 바뀌었으면 true. 실행마다 한 번.
  Future<bool> refresh() async {
    if (_checked) return false;
    _checked = true;
    try {
      final body = await (fetch ?? _get)(url);
      if (body == null) return false;
      final s = CurriculumPlan.fromJson(json.decode(body) as Map);
      if (plan != null && s.rev <= plan!.rev) return false;
      await (await Prefs.getInstance()).setString(_prefKey, body);
      plan = s;
      return true;
    } catch (e) {
      debugPrint('Curriculum: 서버 판 실패 $e');
      return false;
    }
  }

  @visibleForTesting
  void reset() {
    plan = null;
    _checked = false;
  }

  Future<String?> _get(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.userAgentHeader, 'talkverse-$lang/0.1');
      final res = await req.close().timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }
}
