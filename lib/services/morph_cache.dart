import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// 한자유니버스 모핑 그림(그림 → 글자) 기기 캐시 — 한자앱 `lib/data/morph_cache.dart` 복제(한자 세션 지시 2026-11-02).
/// 파일은 `https://gif.talkverse.uk/<이름>`. 앱은 `<stem>_768.webp`(폰) / `_1024.webp`(짧은 변 600pt 이상)를 먼저 쓰고 없으면 .gif.
/// 한 번 받은 파일은 앱 지원 폴더(morph/)에 두고 다시 받지 않는다(이름에 판 번호 _vN 이 있어 바뀌면 새 이름).
class MorphCache {
  static const gifBase = 'https://gif.talkverse.uk';
  static Directory? _dir;
  static final Map<String, Future<File?>> _pending = {};

  static String gifUrl(String name) => '$gifBase/$name';

  /// 짧은 변 600pt 이상(아이패드·태블릿·폴드 펼침)이면 1024 판.
  static bool wantsLarge(BuildContext context) => MediaQuery.sizeOf(context).shortestSide >= 600;

  static Future<Directory> _root() async {
    if (_dir != null) return _dir!;
    final d = Directory('${(await getApplicationSupportDirectory()).path}/morph');
    if (!await d.exists()) await d.create(recursive: true);
    return _dir = d;
  }

  static Future<File?> _get(String name) => _pending[name] ??= () async {
        try {
          final f = File('${(await _root()).path}/$name');
          if (await f.exists() && await f.length() > 0) return f;
          final r = await http.get(Uri.parse(gifUrl(name)), headers: {'User-Agent': 'talkverse-ja/0.1'}).timeout(const Duration(seconds: 30));
          if (r.statusCode != 200 || r.bodyBytes.isEmpty) return null;
          final tmp = File('${f.path}.part');
          await tmp.writeAsBytes(r.bodyBytes, flush: true);
          await tmp.rename(f.path);
          return f;
        } catch (_) {
          return null;
        } finally {
          _pending.remove(name); // 실패한 것은 다음에 다시 시도
        }
      }();

  /// 글자의 모핑 파일(WebP 우선, 없으면 GIF).
  static Future<File?> fileFor(String morphFile, {required bool large}) async {
    if (morphFile.endsWith('.gif')) {
      final stem = morphFile.substring(0, morphFile.length - 4);
      final w = await _get('${stem}_${large ? 1024 : 768}.webp');
      if (w != null) return w;
    }
    return _get(morphFile);
  }

  /// 단계·가족을 열 때 미리 받아 둔다(한 번에 3개씩).
  static Future<void> prefetch(Iterable<String> files, {required bool large}) async {
    final list = files.toList();
    for (var i = 0; i < list.length; i += 3) {
      await Future.wait([for (final f in list.skip(i).take(3)) fileFor(f, large: large)]);
    }
  }
}
