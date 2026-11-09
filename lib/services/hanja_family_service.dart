import '../core/embed_env.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

/// 한자유니버스 가족 DB — 한자 세션 지시(2026-11-02) "GIF DB 와 가족 DB 를 일본어앱에 그대로".
/// - 전체 글자표(`hanja_chars` ≈ 4,200행, 5쪽)를 앱 지원 폴더에 7일 캐시 → 소리 가족(`phonetic` 코드가 같은 글자 묶음, 한자앱 `families`).
/// - 책 가족(소리 가족 교재 쌍, 가족별 page) = 번들 `assets/data/hanja/book.json`, 헷갈리는 쌍 = `confuse.json`(한자앱 복제).
/// - 코드는 `U<유니코드>` 공통키. 일본어앱은 jp 자형으로 보여 준다.
class HanjaChar {
  final String code, kr, jp, cn, krHun;
  final List<String> jpOn;
  final String? phonetic; // 발음부 코드
  final String? gif, gifStatus, gifJp, gifJpStatus;
  final int? jlpt;
  const HanjaChar({required this.code, required this.kr, required this.jp, required this.cn, required this.krHun, required this.jpOn, this.phonetic, this.gif, this.gifStatus, this.gifJp, this.gifJpStatus, this.jlpt});

  factory HanjaChar.fromJson(Map<String, dynamic> j) => HanjaChar(
        code: j['code'] as String,
        kr: j['kr'] as String? ?? '',
        jp: (j['jp'] as String?)?.isNotEmpty == true ? j['jp'] as String : (j['kr'] as String? ?? ''),
        cn: j['cn'] as String? ?? '',
        krHun: j['kr_hun'] as String? ?? '',
        jpOn: (j['jp_on'] as List?)?.cast<String>() ?? const [],
        phonetic: j['phonetic'] as String?,
        gif: j['gif'] as String?,
        gifStatus: j['gif_status'] as String?,
        gifJp: j['gif_jp'] as String?,
        gifJpStatus: j['gif_jp_status'] as String?,
        jlpt: j['jlpt'] is int ? j['jlpt'] as int : null,
      );

  /// 일본어앱 모핑 파일: 자형이 다르면 gif_jp, 같으면 gif. 상태 ok·pending 만.
  String? get morphFile {
    if (jp != kr) return (gifJpStatus == 'ok' || gifJpStatus == 'pending') ? gifJp : null;
    return (gifStatus == 'ok' || gifStatus == 'pending') ? gif : null;
  }

  String get morphStatus => jp != kr ? (gifJpStatus ?? 'none') : (gifStatus ?? 'none');

  /// 훈(뜻)만 — "불 화" → "불".
  String get hun {
    final first = krHun.replaceAll(RegExp(r'\[[^\]]*\]'), '').split(',').first.trim();
    final i = first.lastIndexOf(' ');
    return i > 0 ? first.substring(0, i) : first;
  }

  /// 한국 한자음(첫 번째) — "불 화" → "화".
  String get krSound {
    final first = krHun.split(',').first.trim();
    return first.split(' ').last;
  }

  String get on => jpOn.isEmpty ? '' : jpOn.first;
}

class BookFamily {
  final String sound;
  final int page;
  final List<String> codes;
  const BookFamily({required this.sound, required this.page, required this.codes});
}

class ConfusePair {
  final String aCode, bCode, aHun, bHun;
  final int? page;
  const ConfusePair({required this.aCode, required this.bCode, required this.aHun, required this.bHun, this.page});
}

class HanjaFamilyService {
  HanjaFamilyService._();
  static final HanjaFamilyService instance = HanjaFamilyService._();

  static const apiBase = 'https://hanja-api.talkverse-lab.workers.dev/rest/v1';
  static const _cols = 'code,kr,jp,cn,kr_hun,jp_on,phonetic,jlpt,gif,gif_status,gif_jp,gif_jp_status';
  static const _ttl = Duration(days: 7);

  final Map<String, HanjaChar> byCode = {};
  final Map<String, HanjaChar> byGlyph = {}; // jp·kr·cn 자형 → 글자
  final Map<String, List<String>> families = {}; // 발음부 코드 → 가족 코드(발음부 자신 제외) — 공용 DB + 앱 자체 판정(phonetic_ja.json) 합침
  final Set<String> appJudged = {}; // '뿌리코드:구성원코드' — 앱 자체 판정(IDS+음독)으로만 들어온 쌍(사용자 지시 2026-11-02 "니 DB 를 완전 버리지는 마")
  final Set<String> dbJudged = {};
  final List<BookFamily> book = [];
  final List<ConfusePair> confuse = [];
  Future<void>? _loading;
  bool get isLoaded => byCode.isNotEmpty;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    // 번들(책 가족·헷갈리는 쌍)
    try {
      final b = json.decode(await rootBundle.loadString(assetPath('assets/data/hanja/book.json'))) as Map<String, dynamic>;
      for (final f in (b['families'] as List? ?? const [])) {
        final m = f as Map<String, dynamic>;
        book.add(BookFamily(sound: m['sound'] as String? ?? '', page: (m['page'] as num?)?.toInt() ?? 0, codes: (m['chars'] as List? ?? const []).cast<String>()));
      }
      final c = json.decode(await rootBundle.loadString(assetPath('assets/data/hanja/confuse.json'))) as Map<String, dynamic>;
      for (final p in (c['pairs'] as List? ?? const [])) {
        final m = p as Map<String, dynamic>;
        final a = m['a'] as Map<String, dynamic>, bb = m['b'] as Map<String, dynamic>;
        confuse.add(ConfusePair(aCode: a['code'] as String, bCode: bb['code'] as String, aHun: a['hun'] as String? ?? '', bHun: bb['hun'] as String? ?? '', page: (m['page'] as num?)?.toInt()));
      }
    } catch (e) {
      debugPrint('HanjaFamily: 번들 실패 $e');
    }
    // 전체 글자표(캐시 → 없거나 오래되면 서버)
    List<dynamic>? rows;
    File? cache;
    try {
      cache = File('${await dataDir()}/hanja_chars_v1.json');
      if (await cache.exists() && DateTime.now().difference(await cache.lastModified()) < _ttl) {
        rows = json.decode(await cache.readAsString()) as List<dynamic>;
      }
    } catch (_) {}
    if (rows == null) {
      try {
        final all = <dynamic>[];
        for (var offset = 0; offset < 20000; offset += 1000) {
          final page = await _get('/hanja_chars?select=$_cols&order=code&limit=1000&offset=$offset');
          all.addAll(page);
          if (page.length < 1000) break;
        }
        rows = all;
        if (cache != null) unawaitedWrite(cache, json.encode(all));
      } catch (e) {
        debugPrint('HanjaFamily: 서버 실패 $e');
        try {
          if (cache != null && await cache.exists()) rows = json.decode(await cache.readAsString()) as List<dynamic>; // 오래된 캐시라도
        } catch (_) {}
      }
    }
    for (final r in rows ?? const []) {
      final h = HanjaChar.fromJson(r as Map<String, dynamic>);
      byCode[h.code] = h;
      for (final g in {h.jp, h.kr, h.cn}) {
        if (g.isNotEmpty) byGlyph.putIfAbsent(g, () => h);
      }
    }
    for (final h in byCode.values) {
      if (h.phonetic != null && h.phonetic!.isNotEmpty && h.phonetic != h.code) {
        families.putIfAbsent(h.phonetic!, () => []).add(h.code);
        dbJudged.add('${h.phonetic}:${h.code}');
      }
    }
    // 앱 자체 발음부 판정(assets/data/kanji/phonetic_ja.json: chars[글자] = {phonetic: 뿌리 글자}) — 공용 DB 에 없는 쌍을 더한다
    try {
      final pj = json.decode(await rootBundle.loadString(assetPath('assets/data/kanji/phonetic_ja.json'))) as Map<String, dynamic>;
      final chars = pj['chars'] as Map<String, dynamic>? ?? const {};
      chars.forEach((glyph, v) {
        final rootGlyph = (v as Map)['phonetic'] as String?;
        final m = byGlyph[glyph], r = rootGlyph == null ? null : byGlyph[rootGlyph];
        if (m == null || r == null || m.code == r.code) return;
        final list = families.putIfAbsent(r.code, () => []);
        if (!list.contains(m.code)) {
          list.add(m.code);
          appJudged.add('${r.code}:${m.code}');
        }
      });
    } catch (e) {
      debugPrint('HanjaFamily: phonetic_ja 합치기 실패 $e');
    }
  }

  static void unawaitedWrite(File f, String s) {
    f.writeAsString(s, flush: true).catchError((e) {
      debugPrint('HanjaFamily: 캐시 쓰기 실패 $e');
      return f;
    });
  }

  /// 가족 뿌리(발음부) — 가족이 2자 이상이고 표에 있는 글자, 큰 가족부터.
  List<HanjaChar> familyRoots() {
    final roots = [for (final e in families.entries) if (e.value.length >= 2 && byCode.containsKey(e.key)) byCode[e.key]!];
    roots.sort((a, b) => families[b.code]!.length.compareTo(families[a.code]!.length));
    return roots;
  }

  /// 이 쌍이 앱 자체 판정으로만 들어왔는가(공용 DB 에는 없음).
  bool isAppOnly(String rootCode, String memberCode) => appJudged.contains('$rootCode:$memberCode') && !dbJudged.contains('$rootCode:$memberCode');

  List<HanjaChar> familyOf(String rootCode) => [for (final c in families[rootCode] ?? const <String>[]) if (byCode.containsKey(c)) byCode[c]!];

  /// 글자(자형)로 그 글자가 속한 가족 뿌리.
  HanjaChar? rootOfGlyph(String glyph) {
    final h = byGlyph[glyph];
    if (h == null) return null;
    if (families.containsKey(h.code) && families[h.code]!.length >= 2) return h;
    final p = h.phonetic;
    return p != null && byCode.containsKey(p) ? byCode[p] : null;
  }

  Future<List<Map<String, dynamic>>> _get(String path) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
    try {
      final req = await client.getUrl(Uri.parse('$apiBase$path'));
      req.headers.set(HttpHeaders.userAgentHeader, 'talkverse-ja/0.1');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close().timeout(const Duration(seconds: 25));
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) throw HttpException('hanja-api ${res.statusCode}');
      return (json.decode(body) as List).cast<Map<String, dynamic>>();
    } finally {
      client.close(force: true);
    }
  }
}
