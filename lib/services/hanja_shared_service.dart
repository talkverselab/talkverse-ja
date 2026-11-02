import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// 한자유니버스 공용 DB(Cloudflare D1 `hanja-db`, Worker `hanja-api`) 읽기 — 그림(GIF)·외우는 팁·어원·구성·소리 가족.
///
/// 규칙(`docs/CLOUDFLARE_MIGRATION.md` §2, 한자 세션 `SHARED_DB.md` §15):
/// - 읽기 주소 `https://hanja-api.talkverse-lab.workers.dev/rest/v1/<표>` (PostgREST 모양), 그림 `https://gif.talkverse.uk/<파일>`.
/// - 그림: 일본 자형(jp) ≠ 한국 정자(kr)면 `gif_jp`(상태 ok)만, 같으면 `gif`(ok). 자형이 다른데 일본어 GIF 가 없으면
///   정자 GIF 로 대신하지 않는다(사용자 지시 2026-10-11). 리뷰 승인(ok) 아닌 그림은 보여 주지 않는다.
/// - 팁·어원은 `hanja_mnemonic`(lang=ko). form 은 kr/cn 뿐이라 jp 자형이 cn 과 같으면 cn, 아니면 kr 을 쓴다.
/// - 기기 캐시: SharedPreferences 에 글자별 JSON(7일). 오프라인·실패면 null → 화면은 번들 데이터만으로 동작.
class HanjaSharedService {
  HanjaSharedService._();
  static final HanjaSharedService instance = HanjaSharedService._();

  static const apiBase = 'https://hanja-api.talkverse-lab.workers.dev/rest/v1';
  static const gifBase = 'https://gif.talkverse.uk';
  static const _ttl = Duration(days: 7);
  static const _cols = 'code,kr,cn,jp,kr_hun,jp_on,jp_kun,liushu,phonetic,explain,components,etym,'
      'gif,gif_status,gif_jp,gif_jp_status,family_status';

  final Map<String, HanjaInfo?> _mem = {};
  final Map<String, Future<HanjaInfo?>> _inflight = {};
  SharedPreferences? _prefs;

  /// 한자 1자(일본 자형 또는 정자)의 공용 데이터. 없거나 네트워크 실패면 null.
  Future<HanjaInfo?> info(String ch) {
    if (_mem.containsKey(ch)) return Future.value(_mem[ch]);
    // whenComplete 콜백이 Future 를 돌려주면 그걸 기다린다 — remove() 가 자기 자신을 돌려줘 교착이 나므로 블록으로
    return _inflight[ch] ??= _load(ch).whenComplete(() {
      _inflight.remove(ch);
    });
  }

  Future<HanjaInfo?> _load(String ch) async {
    _prefs ??= await SharedPreferences.getInstance();
    final key = 'hanja_shared:$ch';
    final cached = _prefs!.getString(key);
    if (cached != null) {
      try {
        final j = json.decode(cached) as Map<String, dynamic>;
        final at = DateTime.tryParse(j['_at'] as String? ?? '');
        if (at != null && DateTime.now().difference(at) < _ttl) {
          final info = j['info'] == null ? null : HanjaInfo.fromJson(j['info'] as Map<String, dynamic>);
          _mem[ch] = info;
          return info;
        }
      } catch (_) {}
    }
    HanjaInfo? info;
    try {
      info = await _fetch(ch);
    } catch (e) {
      debugPrint('hanja-api $ch: $e');
      // 오프라인·서버 오류: 옛 캐시가 있으면 그대로, 없으면 null(번들 데이터만)
      if (cached != null) {
        try {
          final j = json.decode(cached) as Map<String, dynamic>;
          info = j['info'] == null ? null : HanjaInfo.fromJson(j['info'] as Map<String, dynamic>);
        } catch (_) {}
      }
      _mem[ch] = info;
      return info;
    }
    _mem[ch] = info;
    final enc = json.encode({'_at': DateTime.now().toIso8601String(), 'info': info?.toJson()});
    // 캐시 쓰기는 화면을 기다리게 하지 않는다(실패해도 무시)
    unawaited(_prefs!
        .setString(key, enc)
        .catchError((e) {
      debugPrint('hanja-api cache $ch: $e');
      return false;
    }));
    return info;
  }

  Future<HanjaInfo?> _fetch(String ch) async {
    final q = Uri.encodeComponent(ch);
    final rows = await _get('/hanja_chars?select=$_cols&or=(jp.eq.$q,kr.eq.$q,cn.eq.$q)&limit=3');
    if (rows.isEmpty) return null;
    // 일본 자형이 정확히 맞는 행 우선
    final row = rows.firstWhere((r) => r['jp'] == ch, orElse: () => rows.first);
    final code = row['code'] as String;
    final jp = row['jp'] as String? ?? '';
    final kr = row['kr'] as String? ?? '';
    final cn = row['cn'] as String? ?? '';

    // 한자 세션 지시(2026-11-02): ok·pending 둘 다 쓴다(pending = 리뷰 전 임시). 재생은 MorphPlayer(webp 768/1024 → gif, 기기 캐시).
    String? gif;
    String? morphFile;
    String morphStatus = 'none';
    if (jp == kr) {
      if ((row['gif_status'] == 'ok' || row['gif_status'] == 'pending') && row['gif'] != null) { morphFile = row['gif'] as String; morphStatus = row['gif_status'] as String; }
    } else {
      if ((row['gif_jp_status'] == 'ok' || row['gif_jp_status'] == 'pending') && row['gif_jp'] != null) { morphFile = row['gif_jp'] as String; morphStatus = row['gif_jp_status'] as String; }
    }
    if (morphFile != null) gif = '$gifBase/$morphFile';

    final form = (jp != kr && jp == cn) ? 'cn' : 'kr';
    final mn = await _get('/hanja_mnemonic?select=form,tip,origin&code=eq.$code&lang=eq.ko');
    Map<String, dynamic>? pick;
    for (final m in mn) {
      if (m['form'] == form) pick = m;
    }
    pick ??= mn.isEmpty ? null : mn.first;

    final phoneticCode = row['phonetic'] as String?;
    // 소리 부품은 코드(U53EF)로 오므로 글자로 바꾼다 — 구성 부품 목록에 있으면 거기서, 없으면 한 번 더 조회
    String? phonetic;
    if (phoneticCode != null && phoneticCode.isNotEmpty) {
      for (final c in (row['components'] as List? ?? const [])) {
        if (c is Map && c['code'] == phoneticCode && (c['ch'] as String?)?.isNotEmpty == true) phonetic = c['ch'] as String;
      }
      if (phonetic == null) {
        final pr = await _get('/hanja_chars?select=jp,kr&code=eq.$phoneticCode&limit=1');
        if (pr.isNotEmpty) phonetic = (pr.first['jp'] as String?)?.isNotEmpty == true ? pr.first['jp'] as String : pr.first['kr'] as String?;
      }
    }
    var family = const <HanjaFamilyMember>[];
    if (phoneticCode != null && phoneticCode.isNotEmpty) {
      final fam = await _get('/hanja_chars?select=code,jp,kr,kr_hun,jp_on,jlpt&phonetic=eq.$phoneticCode'
          '&jlpt=not.is.null&order=jlpt.desc&limit=40');
      family = [
        for (final f in fam)
          if (f['code'] != code)
            HanjaFamilyMember(
              ch: (f['jp'] as String?)?.isNotEmpty == true ? f['jp'] as String : f['kr'] as String? ?? '',
              hun: f['kr_hun'] as String? ?? '',
              on: ((f['jp_on'] as List?)?.cast<String>() ?? const []).join('·'),
              jlpt: f['jlpt'] as int?,
            ),
      ];
    }
    return HanjaInfo(
      code: code,
      jp: jp,
      kr: kr,
      hun: row['kr_hun'] as String? ?? '',
      liushu: row['liushu'] as String?,
      phonetic: phonetic,
      explain: row['explain'] as String?,
      components: [
        for (final c in (row['components'] as List? ?? const []))
          if (c is Map && (c['ch'] as String?)?.isNotEmpty == true) c['ch'] as String,
      ],
      etym: row['etym'] as String?,
      tip: pick?['tip'] as String?,
      origin: pick?['origin'] as String?,
      gifUrl: gif,
      morphFile: morphFile,
      morphStatus: morphStatus,
      family: family,
    );
  }

  Future<List<Map<String, dynamic>>> _get(String path) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.getUrl(Uri.parse('$apiBase$path'));
      req.headers.set(HttpHeaders.userAgentHeader, 'talkverse-ja/0.1');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close().timeout(const Duration(seconds: 12));
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) throw HttpException('hanja-api ${res.statusCode}');
      final decoded = json.decode(body);
      if (decoded is! List) throw const FormatException('hanja-api: not a list');
      return decoded.cast<Map<String, dynamic>>();
    } finally {
      client.close(force: true);
    }
  }
}

class HanjaFamilyMember {
  final String ch;
  final String hun; // 한국어 훈음
  final String on; // 일본 음독
  final int? jlpt;
  const HanjaFamilyMember({required this.ch, required this.hun, required this.on, this.jlpt});

  Map<String, dynamic> toJson() => {'ch': ch, 'hun': hun, 'on': on, 'jlpt': jlpt};
  factory HanjaFamilyMember.fromJson(Map<String, dynamic> j) =>
      HanjaFamilyMember(ch: j['ch'] as String, hun: j['hun'] as String? ?? '', on: j['on'] as String? ?? '', jlpt: j['jlpt'] as int?);
}

class HanjaInfo {
  final String code; // U5B78
  final String jp; // 일본 자형
  final String kr; // 한국 정자
  final String hun; // 한국어 훈음
  final String? liushu; // 형성·회의·상형…
  final String? phonetic; // 소리 부품(음부)
  final String? explain; // gif | compose | family
  final List<String> components;
  final String? etym;
  final String? tip; // 외우는 팁(한국어)
  final String? origin; // 어원 풀이(한국어)
  final String? gifUrl; // 규칙을 통과한 그림만(.gif 원본 주소)
  final String? morphFile; // 저장소 파일 이름(MorphPlayer 용)
  final String morphStatus; // ok | pending | none
  final List<HanjaFamilyMember> family;

  const HanjaInfo({
    required this.code,
    required this.jp,
    required this.kr,
    required this.hun,
    this.liushu,
    this.phonetic,
    this.explain,
    this.components = const [],
    this.etym,
    this.tip,
    this.origin,
    this.gifUrl,
    this.morphFile,
    this.morphStatus = 'none',
    this.family = const [],
  });

  bool get formDiffers => jp.isNotEmpty && kr.isNotEmpty && jp != kr;
  bool get hasAnything => gifUrl != null || tip != null || origin != null || family.isNotEmpty || components.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'code': code, 'jp': jp, 'kr': kr, 'hun': hun, 'liushu': liushu, 'phonetic': phonetic, 'explain': explain,
        'components': components, 'etym': etym, 'tip': tip, 'origin': origin, 'gifUrl': gifUrl, 'morphFile': morphFile, 'morphStatus': morphStatus,
        'family': family.map((f) => f.toJson()).toList(),
      };

  factory HanjaInfo.fromJson(Map<String, dynamic> j) => HanjaInfo(
        code: j['code'] as String,
        jp: j['jp'] as String? ?? '',
        kr: j['kr'] as String? ?? '',
        hun: j['hun'] as String? ?? '',
        liushu: j['liushu'] as String?,
        phonetic: j['phonetic'] as String?,
        explain: j['explain'] as String?,
        components: (j['components'] as List?)?.cast<String>() ?? const [],
        etym: j['etym'] as String?,
        tip: j['tip'] as String?,
        origin: j['origin'] as String?,
        gifUrl: j['gifUrl'] as String?,
        morphFile: j['morphFile'] as String?,
        morphStatus: j['morphStatus'] as String? ?? (j['gifUrl'] != null ? 'ok' : 'none'),
        family: (j['family'] as List?)?.map((f) => HanjaFamilyMember.fromJson(f as Map<String, dynamic>)).toList() ?? const [],
      );
}
