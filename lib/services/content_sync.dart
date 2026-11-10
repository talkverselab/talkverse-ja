import '../core/embed_env.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/prefs.dart';

/// 그림(장면 컷·단어 그림) 기기 내려받기 + 버전 관리 — 사용자 지시 2026-11-04
/// "앱 시작할 때 로딩하면서 다운로드 받고, 업데이트 번호가 다르면 갱신".
///
/// - 시작 때 매니페스트 둘(단어 그림 `/art/ja/manifest`, 장면 컷 `/art/ja/scene/manifest`)을 받아
///   기기에 맞는 크기(폰 584·512, 태블릿 1168·512)의 파일 목록을 만들고, 그 목록의 `?v=` 해시로 **그림 버전**을 계산한다.
/// - 저장된 버전과 다르면(처음 설치 포함) 로딩 화면(`SyncScreen`)에서 바뀐 파일만 내려받는다(같은 `?v=` 는 건너뜀).
///   「나중에」를 누르면 앱을 먼저 열고 뒤에서 계속 받는다 — 아직 없는 그림은 네트워크로 바로 보인다.
/// - 파일은 앱 지원 폴더 `art/<키>` 에 두고, 색인 `art/index.json`(키 → v) 으로 관리한다.
/// - 회화 음성(mp4, `/art/ja/audio/manifest`)도 같은 목록·버전에 들어가 같은 폴더에 받는다(2026-11-06). 재생은 `DialogueAudio`.
/// - 그림을 그리는 쪽은 `artProvider(url)` 로 — 기기에 있으면 파일, 없으면 네트워크.
/// - **내려받기 선택(2026-11-10)**: 회화 단계(R0~R4)·단어 급(N5~N1·그 밖)·음성 여부를 고르면 그 몫만 받는다(`SyncChoice`, 저장됨).
///   고르지 않은 자료는 기기에서 지우고, 화면에서는 네트워크로 바로 보인다. 장면 컷은 학습자 성별 판만 받는다.
/// - **변경분만(2026-11-10)**: 서버가 콘텐츠 번호(`/art/ja/head`)와 변경 목록(`/art/ja/changes?since=N`)을 주면 매니페스트 전체 대신
///   바뀐 줄만 받아 저장본에 덧입힌다. 서버가 아직 없으면(404) 전처럼 전체를 받는다. 규격 = `docs/CONTENT_SYNC.md`.
/// - **변경 기록**: 목록이 바뀔 때마다 `art/sync_log.json` 에 한 줄(앱 빌드·콘텐츠 번호·종류별 추가/변경/삭제 수).
/// - 회화·단어 DB 버전은 번들 `assets/data/version.json` 의 `db` 번호(SeedLoader 가 비교).
class SyncProgress {
  final String phase; // idle | manifest | download | done | offline
  final int done, total;
  final bool running;
  const SyncProgress(this.phase, this.done, this.total, this.running);
  double get ratio => total == 0 ? 0 : done / total;
}

/// 회화 음성 한 줄 = 편·턴·판(m 남성판 / f 여성판). 모든 턴에 두 판이 다 있고, 그 음성이 읽는 본문 넷도 항상 들어 있다.
/// key 는 `?v=` 포함. text = 일본어 본문, reading = 가나, rd = 한글 독음, ko = 한국어 뜻.
class AudioLine {
  final String key;
  final int ms;
  final String text, reading, rd, ko;
  const AudioLine(this.key, this.ms, this.text, this.reading, this.rd, this.ko);
}

/// 내려받기 선택 — 회화 단계·단어 급·음성. 비어 있지 않은 한 그대로 저장되고 다음 실행에도 쓴다.
class SyncChoice {
  static const dialogueLevels = ['R0', 'R1', 'R2', 'R3', 'R4'];
  static const wordLevels = ['N5', 'N4', 'N3', 'N2', 'N1', 'etc']; // etc = JLPT 급이 없는 단어(절벽·회화 단어)
  final Set<String> dialogue, words;
  final bool audio;
  const SyncChoice({required this.dialogue, required this.words, required this.audio});
  static SyncChoice get all => SyncChoice(dialogue: dialogueLevels.toSet(), words: wordLevels.toSet(), audio: true);
  SyncChoice copyWith({Set<String>? dialogue, Set<String>? words, bool? audio}) =>
      SyncChoice(dialogue: dialogue ?? this.dialogue, words: words ?? this.words, audio: audio ?? this.audio);
}

/// 받을 수 있는 파일 한 개(매니페스트에서 뽑음). cat = 'D:R1'(장면 컷)·'A:R1'(음성)·'W:N5'(단어 그림).
class _Item {
  final String key, v;
  final Set<String> cats;
  _Item(this.key, this.v, this.cats);
}

class ContentSync {
  ContentSync._();
  static final ContentSync instance = ContentSync._();

  static const _root = 'https://auth.talkverse.uk/art/ja';
  static const wordsManifestUrl = '$_root/manifest';
  static const sceneManifestUrl = '$_root/scene/manifest';
  /// 회화 음성(2026-11-06): `GET …/art/ja/audio/manifest` → items[{episode,turn,voice(m·f),key,ms,text,reading,rd,ko}], 파일 = base+key(mp4).
  /// 아직 없거나 실패해도 그림 동기화는 그대로 간다.
  static const audioManifestUrl = '$_root/audio/manifest';
  static const _prefVersion = 'art_version_v1';
  static const _prefSeq = 'content_seq'; // 서버 콘텐츠 번호(변경 기록의 마지막 줄 번호)
  static const _prefDialogue = 'sync_dialogue_levels', _prefWords = 'sync_word_levels', _prefAudioOn = 'sync_audio';
  static const _oldPrefs = ['art_scene_manifest_v1', 'art_audio_manifest_v1']; // 옛 저장 자리(1.7MB 를 설정 저장소에 두던 것) — 파일로 옮김
  static const _prefLastAt = 'sync_last_at'; // 마지막으로 다 받은 시각(ms)
  static const _concurrency = 6;

  final ValueNotifier<SyncProgress> progress = ValueNotifier(const SyncProgress('idle', 0, 0, false));
  Directory? _dir;
  final Map<String, String> _index = {}; // 키(?v 뺀 것) → v
  final Map<String, String> _wanted = {}; // 키 → v (이번 버전 목록 중 고른 몫)
  final Map<String, _Item> _items = {}; // 키 → 받을 수 있는 전부
  final Map<String, String> _bodies = {}; // words·scene·audio → 매니페스트 본문
  Map<String, int> _jlpt = const {}; // 표기 → JLPT 급
  String _base = 'https://auth.talkverse.uk/art';
  String? _wantedVersion;
  bool _large = false;
  bool _female = false;
  bool _cancel = false;
  int appBuild = 0;
  int? seq; // 서버 콘텐츠 번호(서버가 주지 않으면 null)
  DateTime? lastAt; // 마지막으로 고른 몫을 다 받은 시각
  SyncChoice choice = SyncChoice.all;
  Map<String, Map<int, String>> sceneIndex = {}; // 편id → {컷 → 키(?v 포함)} — ArtService 가 네트워크 전에 본다
  Map<String, Map<int, Map<String, AudioLine>>> audioIndex = {}; // 편id → {턴 → {m|f → 음성}}
  String get base => _base;

  /// 시작 때 한 번. 색인을 읽고 매니페스트를 받아 "받을 게 있는지"를 돌려준다(오프라인이면 false).
  /// [jlpt] = 표기 → JLPT 급(단어 그림을 급별로 나누는 데 쓴다).
  Future<bool> init({bool large = false, bool female = false, Map<String, int> jlpt = const {}}) async {
    _large = large;
    _female = female;
    _jlpt = jlpt;
    final prefs = await Prefs.getInstance();
    try {
      appBuild = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
    } catch (_) {}
    try {
      _dir = Directory('${await dataDir()}/art');
      if (!await _dir!.exists()) await _dir!.create(recursive: true);
      final f = File('${_dir!.path}/index.json');
      if (await f.exists()) _index.addAll((json.decode(await f.readAsString()) as Map).cast<String, String>());
      // 저장된 매니페스트(오프라인 대비). 옛 빌드가 설정 저장소에 둔 것은 파일로 옮긴다.
      for (final k in const ['words', 'scene', 'audio']) {
        final mf = File('${_dir!.path}/manifest_$k.json');
        if (await mf.exists()) _bodies[k] = await mf.readAsString();
      }
      for (final (i, k) in const ['scene', 'audio'].indexed) {
        final old = prefs.getString(_oldPrefs[i]);
        if (old == null) continue;
        if (_bodies[k] == null) await _saveBody(k, old);
        await prefs.remove(_oldPrefs[i]);
      }
    } catch (e) {
      debugPrint('ContentSync: 색인 읽기 실패 $e');
    }
    choice = SyncChoice(
      dialogue: (prefs.getStringList(_prefDialogue) ?? SyncChoice.dialogueLevels).toSet(),
      words: (prefs.getStringList(_prefWords) ?? SyncChoice.wordLevels).toSet(),
      audio: prefs.getBool(_prefAudioOn) ?? true,
    );
    seq = prefs.getInt(_prefSeq);
    final at = prefs.getInt(_prefLastAt);
    lastAt = at == null ? null : DateTime.fromMillisecondsSinceEpoch(at);
    _rebuild();
    progress.value = const SyncProgress('manifest', 0, 0, true);
    final ok = await _refresh(prefs);
    if (!ok) {
      progress.value = const SyncProgress('offline', 0, 0, false);
      return false;
    }
    await _prune();
    await _logDiff(seq == null ? 'manifest' : 'server');
    return _settle(prefs);
  }

  /// 받을 것이 남았는지 계산하고 진행 표시를 맞춘다.
  Future<bool> _settle(Prefs prefs) async {
    final missing = _wanted.entries.where((e) => _index[e.key] != e.value).length;
    final stored = prefs.getString(_prefVersion);
    final need = missing > 0 && stored != _wantedVersion;
    progress.value = SyncProgress(need ? 'download' : 'done', _wanted.length - missing, _wanted.length, false);
    if (!need && stored != _wantedVersion && _wantedVersion != null) await prefs.setString(_prefVersion, _wantedVersion!);
    if (missing == 0 && _wanted.isNotEmpty) await _markDone(prefs);
    return need;
  }

  /// 내려받기 선택을 바꾸고 저장한다. 고르지 않은 자료는 기기에서 지운다. 돌려주는 값 = 새로 받을 것이 있는지.
  Future<bool> setChoice(SyncChoice c) async {
    choice = c;
    final prefs = await Prefs.getInstance();
    await prefs.setStringList(_prefDialogue, c.dialogue.toList());
    await prefs.setStringList(_prefWords, c.words.toList());
    await prefs.setBool(_prefAudioOn, c.audio);
    if (_items.isEmpty) return false; // 목록을 아직 못 받았다(오프라인) — 선택만 저장
    _applyChoice();
    await _prune();
    await _logDiff('choice');
    await prefs.remove(_prefVersion);
    return _settle(prefs);
  }

  /// 종류·급별 파일 수와 대략 크기(KB) — 설정 화면용. 키 = 'D:R1'(장면 컷)·'A:R1'(음성)·'W:N5'(단어 그림).
  Map<String, (int, int)> get stats {
    final out = <String, (int, int)>{};
    for (final it in _items.values) {
      final kb = _kb(it.key);
      for (final c in it.cats) {
        final o = out[c] ?? (0, 0);
        out[c] = (o.$1 + 1, o.$2 + kb);
      }
    }
    return out;
  }

  /// [c] 를 골랐을 때 받게 되는 파일 수·크기(MB).
  (int, int) estimateFor(SyncChoice c) {
    var n = 0, kb = 0;
    for (final it in _items.values) {
      if (!_picked(it, c)) continue;
      n++;
      kb += _kb(it.key);
    }
    return (n, kb ~/ 1024);
  }

  int _kb(String key) => key.startsWith('scene/') ? (_large ? 120 : 44) : (key.startsWith('audio/') ? 42 : 27);

  static bool _picked(_Item it, SyncChoice c) => it.cats.any((cat) {
        final lv = cat.substring(2);
        return switch (cat[0]) {
          'D' => c.dialogue.contains(lv),
          'A' => c.audio && c.dialogue.contains(lv),
          _ => c.words.contains(lv),
        };
      });

  void _applyChoice() {
    _wanted
      ..clear()
      ..addEntries([for (final it in _items.values) if (_picked(it, choice)) MapEntry(it.key, it.v)]);
    final keys = _wanted.entries.map((e) => '${e.key}@${e.value}').toList()..sort();
    _wantedVersion = sha1.convert(utf8.encode(keys.join('\n'))).toString().substring(0, 16);
  }

  /// 서버에서 목록을 새로 맞춘다. 콘텐츠 번호가 있으면 변경분만, 없으면 매니페스트 전체.
  Future<bool> _refresh(Prefs prefs, {bool force = false}) async {
    // force = 「다시 받기」: 변경분 건너뛰고 전체를, 서버 캐시(max-age=300)를 피하게 ?t=시각 을 붙여 받는다
    final bust = force ? '?t=${DateTime.now().millisecondsSinceEpoch}' : '';
    try {
      // 1) 변경분만: 저장본 셋이 다 있고 콘텐츠 번호를 알 때
      if (!force && seq != null && _bodies.length == 3) {
        final c = await _get('$_root/changes?since=$seq');
        final j = c == null ? null : json.decode(c);
        if (j is Map && j['head'] is int && j['reset'] != true) {
          final items = (j['items'] as List? ?? const []);
          if (items.isNotEmpty) {
            for (final k in const ['words', 'scene', 'audio']) {
              final mine = [for (final x in items) if (x is Map && x['kind'] == k) x];
              if (mine.isNotEmpty) await _saveBody(k, patchManifest(_bodies[k]!, k, mine));
            }
          }
          seq = j['head'] as int;
          await prefs.setInt(_prefSeq, seq!);
          _rebuild();
          return true;
        }
      }
      // 2) 전체: 번호를 먼저 받아 둔다(그 뒤에 생긴 변경은 다음에 다시 덧입혀도 결과가 같다)
      int? head;
      try {
        final h = await _get('$_root/head$bust');
        final hj = h == null ? null : json.decode(h);
        if (hj is Map && hj['head'] is int) head = hj['head'] as int;
      } catch (_) {}
      final w = await _get('$wordsManifestUrl$bust');
      final s = await _get('$sceneManifestUrl$bust');
      if (w == null || s == null) return false;
      await _saveBody('words', w);
      await _saveBody('scene', s);
      try {
        final a = await _get('$audioManifestUrl$bust');
        if (a != null) await _saveBody('audio', a);
      } catch (e) {
        debugPrint('ContentSync: 음성 매니페스트 없음 $e');
      }
      seq = head;
      if (head != null) {
        await prefs.setInt(_prefSeq, head);
      } else {
        await prefs.remove(_prefSeq);
      }
      _rebuild();
      return true;
    } catch (e) {
      debugPrint('ContentSync: 매니페스트 실패 $e');
      return false;
    }
  }

  Future<void> _saveBody(String kind, String body) async {
    _bodies[kind] = body;
    try {
      await File('${_dir!.path}/manifest_$kind.json').writeAsString(body, flush: true);
    } catch (_) {}
  }

  /// 매니페스트 한 줄의 고유 이름(변경 기록이 가리키는 이름과 같다).
  static String itemId(String kind, Map m) => switch (kind) {
        'words' => '${m['id']}',
        'scene' => '${m['episode']}#${m['cut']}',
        _ => '${m['episode']}#${m['turn']}#${m['voice']}',
      };

  /// 저장된 매니페스트 본문에 변경 목록을 덧입힌다(같은 줄을 두 번 넣어도 결과가 같다 — 중복되지 않음).
  /// [changes] 한 줄 = {kind, op: put|del, id, item}.
  static String patchManifest(String body, String kind, List changes) {
    final j = json.decode(body) as Map<String, dynamic>;
    final byId = <String, dynamic>{for (final it in (j['items'] as List? ?? const [])) itemId(kind, it as Map): it};
    for (final c in changes) {
      final m = c as Map;
      final item = m['item'];
      final id = '${m['id'] ?? (item is Map ? itemId(kind, item) : '')}';
      if (m['op'] == 'del') {
        byId.remove(id);
      } else if (item is Map) {
        byId[id] = item;
      }
    }
    j['items'] = byId.values.toList();
    j['count'] = byId.length;
    return json.encode(j);
  }

  /// 저장본 셋 → 색인(sceneIndex·audioIndex) + 받을 수 있는 전부(_items) + 고른 몫(_wanted).
  void _rebuild() {
    _items.clear();
    void add(String keyWithV, String cat) {
      final i = keyWithV.indexOf('?v=');
      final key = i < 0 ? keyWithV : keyWithV.substring(0, i);
      final it = _items[key];
      if (it != null) {
        it.cats.add(cat);
      } else {
        _items[key] = _Item(key, i < 0 ? '0' : keyWithV.substring(i + 3), {cat});
      }
    }
    String lv(String ep) => ep.length >= 2 ? ep.substring(0, 2).toUpperCase() : 'R1';
    try {
      final w = _bodies['words'];
      if (w != null) {
        final wj = json.decode(w) as Map<String, dynamic>;
        _base = (wj['base'] as String? ?? _base).replaceAll(RegExp(r'/$'), '');
        for (final it in (wj['items'] as List? ?? const [])) {
          final m = it as Map;
          final k = m['key_512'] as String?;
          if (k == null) continue;
          final j = _jlpt['${m['word']}'];
          add(k, 'W:${j == null ? 'etc' : 'N$j'}');
        }
      }
    } catch (e) {
      debugPrint('ContentSync: 단어 매니페스트 해석 실패 $e');
    }
    try {
      final s = _bodies['scene'];
      if (s != null) {
        final sj = json.decode(s) as Map<String, dynamic>;
        _base = (sj['base'] as String? ?? _base).replaceAll(RegExp(r'/$'), '');
        final idx = <String, Map<int, String>>{};
        for (final it in (sj['items'] as List? ?? const [])) {
          final m = it as Map<String, dynamic>;
          final k = (_large ? m['key_1168'] : m['key_584']) as String? ?? m['key_1168'] as String?;
          final ep = m['episode'] as String?;
          final cut = m['cut'];
          if (k == null || ep == null || cut is! int) continue;
          idx.putIfAbsent(ep, () => {})[cut] = k;
        }
        sceneIndex = idx;
        // 받는 것은 학습자 성별 판만: 여자 = `<편>_f`(없는 컷만 기본판), 남자 = 기본판. 다른 판은 필요할 때 네트워크로.
        idx.forEach((ep, cuts) {
          final isF = ep.endsWith('_f');
          cuts.forEach((cut, k) {
            final take = _female ? (isF || idx['${ep}_f']?[cut] == null) : !isF;
            if (take) add(k, 'D:${lv(ep)}');
          });
        });
      }
    } catch (e) {
      debugPrint('ContentSync: 장면 매니페스트 해석 실패 $e');
    }
    try {
      final a = _bodies['audio'];
      if (a != null) {
        final aj = json.decode(a) as Map<String, dynamic>;
        final mine = _female ? 'f' : 'm';
        final idx = <String, Map<int, Map<String, AudioLine>>>{};
        for (final it in (aj['items'] as List? ?? const [])) {
          final m = it as Map<String, dynamic>;
          final ep = m['episode'] as String?, k = m['key'] as String?, voice = m['voice'] as String?;
          final turn = m['turn'];
          if (ep == null || k == null || voice == null || turn is! int) continue;
          String s(String f) => m[f] is String ? m[f] as String : '';
          idx.putIfAbsent(ep, () => {}).putIfAbsent(turn, () => {})[voice] =
              AudioLine(k, (m['ms'] as num?)?.toInt() ?? 0, s('text'), s('reading'), s('rd'), s('ko'));
          if (voice == mine) add(k, 'A:${lv(ep)}'); // 학습자 성별 판만 받는다 — 다른 판은 주소로 바로 재생
        }
        audioIndex = idx;
      }
    } catch (e) {
      debugPrint('ContentSync: 음성 매니페스트 해석 실패 $e');
    }
    _applyChoice();
  }

  /// 고른 몫에 없는 기기 파일을 지운다(선택 해제·서버에서 빠진 것·옛 빌드가 받은 다른 성별 판).
  Future<int> _prune() async {
    if (_dir == null || _items.isEmpty) return 0;
    // 목록을 받지 못한 종류(예: 음성 매니페스트 실패)는 건드리지 않는다 — 일시 오류로 받은 파일을 지우지 않게
    bool known(String k) => _bodies.containsKey(switch (_kindOf(k)) { 'word' => 'words', final x => x });
    final gone = [for (final k in _index.keys) if (!_wanted.containsKey(k) && known(k)) k];
    for (final k in gone) {
      _index.remove(k);
      try {
        final f = File('${_dir!.path}/$k');
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    if (gone.isNotEmpty) await _saveIndex();
    return gone.length;
  }

  static String _kindOf(String key) => key.startsWith('scene/') ? 'scene' : (key.startsWith('audio/') ? 'audio' : 'word');

  /// 지난번 목록과 견주어 바뀐 것만 세어 변경 기록에 한 줄 남긴다(바뀐 게 없으면 남기지 않는다).
  Future<void> _logDiff(String reason) async {
    if (_dir == null) return;
    try {
      final snap = File('${_dir!.path}/wanted.json');
      final prev = await snap.exists() ? (json.decode(await snap.readAsString()) as Map).cast<String, String>() : <String, String>{};
      final add = <String, int>{}, chg = <String, int>{}, del = <String, int>{};
      void inc(Map<String, int> m, String key) => m[_kindOf(key)] = (m[_kindOf(key)] ?? 0) + 1;
      _wanted.forEach((k, v) {
        final o = prev[k];
        if (o == null) {
          inc(add, k);
        } else if (o != v) {
          inc(chg, k);
        }
      });
      for (final k in prev.keys) {
        if (!_wanted.containsKey(k)) inc(del, k);
      }
      if (add.isEmpty && chg.isEmpty && del.isEmpty) return;
      await snap.writeAsString(json.encode(_wanted), flush: true);
      final list = await log();
      list.insert(0, {
        'at': DateTime.now().toIso8601String(),
        'build': appBuild,
        'seq': seq,
        'ver': _wantedVersion,
        'reason': prev.isEmpty ? 'first' : reason,
        'add': add,
        'chg': chg,
        'del': del,
      });
      await File('${_dir!.path}/sync_log.json').writeAsString(json.encode(list.take(200).toList()), flush: true);
    } catch (e) {
      debugPrint('ContentSync: 변경 기록 실패 $e');
    }
  }

  /// 변경 기록(최근 것이 앞). 한 줄 = {at, build, seq, ver, reason(first·server·manifest·choice), add·chg·del {word·scene·audio: 수}}.
  Future<List<Map<String, dynamic>>> log() async {
    try {
      final f = File('${_dir!.path}/sync_log.json');
      if (!await f.exists()) return [];
      return [for (final e in json.decode(await f.readAsString()) as List) (e as Map).cast<String, dynamic>()];
    } catch (_) {
      return [];
    }
  }

  /// 모자란 파일을 내려받는다(여러 번 불러도 한 번만 돈다). 끝나면 버전을 저장.
  Future<void>? _running;
  Future<void> download() => _running ??= _download().whenComplete(() => _running = null);

  Future<void> _download() async {
    _cancel = false;
    final todo = _wanted.entries.where((e) => _index[e.key] != e.value).toList();
    var done = _wanted.length - todo.length;
    progress.value = SyncProgress('download', done, _wanted.length, true);
    final q = List.of(todo);
    var since = 0;
    Future<void> worker() async {
      while (q.isNotEmpty && !_cancel) {
        final e = q.removeAt(0);
        if (await _fetchFile(e.key, e.value)) {
          _index[e.key] = e.value;
          since++;
        }
        done++;
        progress.value = SyncProgress('download', done, _wanted.length, true);
        if (since >= 20) {
          since = 0;
          await _saveIndex();
        }
      }
    }
    await Future.wait([for (var i = 0; i < _concurrency; i++) worker()]);
    await _saveIndex();
    final left = _wanted.entries.where((e) => _index[e.key] != e.value).length;
    if (left == 0 && _wantedVersion != null) {
      final prefs = await Prefs.getInstance();
      await prefs.setString(_prefVersion, _wantedVersion!);
      await _markDone(prefs);
    }
    progress.value = SyncProgress(left == 0 ? 'done' : 'download', _wanted.length - left, _wanted.length, false);
  }

  void cancel() => _cancel = true;

  Future<void> _markDone(Prefs prefs) async {
    lastAt = DateTime.now();
    await prefs.setInt(_prefLastAt, lastAt!.millisecondsSinceEpoch);
  }

  /// 종류별 진행 — word·scene·audio → (기기에 받은 수, 고른 몫 전체).
  Map<String, (int, int)> get kindProgress {
    final out = {'word': (0, 0), 'scene': (0, 0), 'audio': (0, 0)};
    _wanted.forEach((k, v) {
      final kind = _kindOf(k);
      final (d, t) = out[kind]!;
      out[kind] = (d + (_index[k] == v ? 1 : 0), t + 1);
    });
    return out;
  }

  /// 「다시 받기」(사용자 지시 2026-11-11): 돌던 내려받기를 멈추고, 매니페스트를 캐시 무시로 새로 받아
  /// 동기화를 처음부터 다시 돌린다. 기기에서 사라진 파일은 색인에서 빼 다시 받게 한다. 돌려주는 값 = 서버에 닿았는지.
  bool restarting = false;
  Future<bool> restart() async {
    if (restarting) return false;
    restarting = true;
    try {
      _cancel = true;
      try {
        await _running;
      } catch (_) {}
      final prefs = await Prefs.getInstance();
      progress.value = const SyncProgress('manifest', 0, 0, true);
      final ok = await _refresh(prefs, force: true);
      if (!ok) {
        final missing = _wanted.entries.where((e) => _index[e.key] != e.value).length;
        progress.value = SyncProgress('offline', _wanted.length - missing, _wanted.length, false);
        return false;
      }
      // 색인에는 있는데 파일이 없는 것 → 다시 받는다
      if (_dir != null) {
        var lost = 0;
        for (final k in _index.keys.toList()) {
          if (!await File('${_dir!.path}/$k').exists()) {
            _index.remove(k);
            lost++;
          }
        }
        if (lost > 0) await _saveIndex();
      }
      await _prune();
      await _logDiff('restart');
      await prefs.remove(_prefVersion);
      await _settle(prefs);
    } finally {
      restarting = false;
    }
    unawaited(download());
    return true;
  }

  Future<bool> _fetchFile(String key, String v) async {
    try {
      final f = File('${_dir!.path}/$key');
      await f.parent.create(recursive: true);
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
      try {
        final req = await client.getUrl(Uri.parse('$_base/$key${v == '0' ? '' : '?v=$v'}'));
        req.headers.set(HttpHeaders.userAgentHeader, 'talkverse-ja/0.1');
        final res = await req.close().timeout(const Duration(seconds: 40));
        if (res.statusCode != 200) return false;
        final tmp = File('${f.path}.part');
        final sink = tmp.openWrite();
        await res.pipe(sink);
        await tmp.rename(f.path);
        return true;
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      debugPrint('ContentSync: 받기 실패 $key $e');
      return false;
    }
  }

  Future<void> _saveIndex() async {
    try {
      await File('${_dir!.path}/index.json').writeAsString(json.encode(_index), flush: true);
    } catch (_) {}
  }

  /// 그림 주소(또는 키) → 기기 파일이 있으면 FileImage, 없으면 NetworkImage.
  ImageProvider provider(String url) {
    final f = localFile(url);
    return f != null ? FileImage(f) : NetworkImage(url);
  }

  File? localFile(String url) {
    if (_dir == null) return null;
    var key = url;
    if (key.startsWith(_base)) key = key.substring(_base.length);
    final i = key.indexOf('?v=');
    final v = i < 0 ? '0' : key.substring(i + 3);
    if (i >= 0) key = key.substring(0, i);
    key = key.replaceFirst(RegExp(r'^/'), '');
    if (_index[key] != v) return null;
    final f = File('${_dir!.path}/$key');
    return f.existsSync() ? f : null;
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

  /// 이번 버전(고른 몫) 파일 수·대략 크기(MB) — 로딩 화면 안내용.
  (int, int) get estimate => (_wanted.length, _wanted.keys.fold<int>(0, (a, k) => a + _kb(k)) ~/ 1024);
}

/// 그림 주소 → 기기 파일 우선 ImageProvider(모든 Image.network 자리에서 쓴다).
ImageProvider artProvider(String url) => ContentSync.instance.provider(url);
