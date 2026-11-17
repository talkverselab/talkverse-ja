import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/embed_env.dart';

/// 원고 덮어쓰기(사용자 지시 2026-11-17 「정식 출시 뒤에도 심사 없이 원고를 고치게」).
///
/// 앱 안 원고(`assets/data/…`)가 바탕이고, 서버에 그보다 새 판이 있으면 바뀐 파일만 받아 기기에 두고 그것을 먼저 읽는다.
/// - 서버: `GET <root>/index.json` → `{"rev": 7, "files": {"dialogues/R0/friends/r0_friends_a2.json": "<sha1 앞 12자리>", …}}`,
///   파일은 `GET <root>/<경로>?v=<sha>`. 경로는 `assets/data/` 아래 상대 경로.
/// - 앱 안 기준표 `assets/data/script_rev.json` — 이 빌드를 만들 때의 `rev`·파일별 sha(올리는 도구 `tools/script_publish.py` 가 쓴다).
/// - 서버 rev 가 앱 안 rev 보다 **클 때만** 받는다. 새 빌드(rev 가 같거나 큼)를 깔면 기기의 덮어쓴 파일은 지운다 — 앱 안 원고가 더 새것.
/// - 전부 받아 확인(sha·JSON)한 뒤에만 바꾼다. 실패하면 지금 것 그대로. 서버가 없어도(404·오프라인) 앱 안 원고로 돈다.
/// - 회화: 서버 목록에 없는 편은 숨기고(`removed`), 앱에 없는 새 편은 더한다(`added`).
/// 규격 = `docs/CONTENT_SYNC.md` §6.
class ScriptSync {
  ScriptSync._();
  static ScriptSync instance = ScriptSync._();

  /// 시험용 — 폴더·요청·기준표를 바꿔 끼운다.
  @visibleForTesting
  ScriptSync.forTest({required Directory dir, required Future<String?> Function(String url) fetch, required Map<String, dynamic> baseline})
      : _testDir = dir,
        _fetch = fetch,
        _testBaseline = baseline;

  static const root = 'https://auth.talkverse.uk/art/script/ja';
  static const _kBaseline = 'assets/data/script_rev.json';

  Directory? _testDir;
  Map<String, dynamic>? _testBaseline;
  Future<String?> Function(String url)? _fetch;

  Directory? _dir;
  bool _ready = false;
  int baseRev = 0;
  Map<String, String> _base = {};

  /// 기기에 적용된 서버 판(없으면 0)과 덮어쓴 파일(경로 → sha).
  int rev = 0;
  Map<String, String> _over = {};
  Set<String> _removed = {};

  /// 지금 쓰는 원고 번호(화면 표시용).
  int get shownRev => rev > baseRev ? rev : baseRev;
  int get overlayCount => _over.length;

  /// 서버 판에서 빠진 앱 안 파일(회화 편을 숨길 때).
  Set<String> get removed => _removed;

  /// 앱 안에 없는 새 파일(새 회화 편).
  Iterable<String> get added => _over.keys.where((p) => !_base.containsKey(p));

  /// 기기 상태만 읽는다(네트워크 없음). 여러 번 불러도 한 번만.
  Future<void> init() async {
    if (_ready) return;
    _ready = true;
    try {
      final b = _testBaseline ?? json.decode(utf8.decode((await rootBundle.load(assetPath(_kBaseline))).buffer.asUint8List())) as Map<String, dynamic>;
      baseRev = (b['rev'] as int?) ?? 0;
      _base = ((b['files'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', '$v'));
    } catch (_) {}
    try {
      _dir = _testDir ?? Directory('${await dataDir()}/script');
      final f = File('${_dir!.path}/state.json');
      if (!await f.exists()) return;
      final s = json.decode(await f.readAsString()) as Map<String, dynamic>;
      final r = (s['rev'] as int?) ?? 0;
      if (r <= baseRev) {
        // 새 빌드가 더 새 원고를 싣고 왔다 — 받아 둔 것은 버린다
        await _dir!.delete(recursive: true);
        return;
      }
      rev = r;
      _over = ((s['files'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', '$v'));
      _removed = {...((s['removed'] as List?) ?? const []).map((e) => '$e')};
    } catch (e) {
      debugPrint('ScriptSync: 상태 읽기 실패 $e');
      rev = 0;
      _over = {};
      _removed = {};
    }
  }

  /// 원고 한 파일 — 덮어쓴 것이 있으면 그것, 없으면 앱 안 것. [rel] = `assets/data/` 아래 경로.
  Future<String> load(String rel) async {
    await init();
    if (_over.containsKey(rel) && _dir != null) {
      try {
        return await File('${_dir!.path}/files/$rel').readAsString();
      } catch (_) {}
    }
    return utf8.decode((await rootBundle.load(assetPath('assets/data/$rel'))).buffer.asUint8List());
  }

  /// 서버 판을 확인하고 바뀐 파일을 받는다. 무엇이든 바뀌었으면 true(읽어 둔 원고를 다시 읽을 것).
  Future<bool> refresh() async {
    await init();
    if (_dir == null) return false;
    try {
      final body = await (_fetch ?? _get)('$root/index.json');
      if (body == null) return false;
      final j = json.decode(body) as Map<String, dynamic>;
      final r = (j['rev'] as int?) ?? 0;
      if (r <= baseRev || r == rev) return false;
      final files = ((j['files'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', '$v'));
      if (files.keys.any((p) => !RegExp(r'^[\w./-]+\.json$').hasMatch(p) || p.contains('..'))) return false;
      final over = <String, String>{};
      for (final e in files.entries) {
        if (_base[e.key] == e.value) continue; // 앱 안 것과 같다
        final f = File('${_dir!.path}/files/${e.key}');
        if (_over[e.key] == e.value && await f.exists()) {
          over[e.key] = e.value; // 이미 받은 판
          continue;
        }
        final text = await (_fetch ?? _get)('$root/${e.key}?v=${e.value}');
        if (text == null) return false;
        if (!sha1.convert(utf8.encode(text)).toString().startsWith(e.value)) return false;
        json.decode(text);
        await f.parent.create(recursive: true);
        final tmp = File('${f.path}.tmp');
        await tmp.writeAsString(text, flush: true);
        await tmp.rename(f.path);
        over[e.key] = e.value;
      }
      final removed = {for (final p in _base.keys) if (!files.containsKey(p)) p};
      await File('${_dir!.path}/state.json').writeAsString(json.encode({'rev': r, 'files': over, 'removed': removed.toList()}), flush: true);
      for (final p in _over.keys.where((p) => !over.containsKey(p))) {
        try {
          await File('${_dir!.path}/files/$p').delete();
        } catch (_) {}
      }
      rev = r;
      _over = over;
      _removed = removed;
      return true;
    } catch (e) {
      debugPrint('ScriptSync: 받기 실패 $e');
      return false;
    }
  }

  Future<String?> _get(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.userAgentHeader, 'talkverse-ja/0.1');
      final res = await req.close().timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      return await res.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }
}
