import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/sense_course_screen.dart';
import 'package:japanese_universe/services/script_sync.dart';

/// 문법(언어감각) 스텝은 서버 원고 목록 그대로 — 빠지면 안 보이고, 더해지면 보이고, 서버를 못 받으면 묶음 목록(사용자 지시 11-23).
String sha(String s) => sha1.convert(utf8.encode(s)).toString().substring(0, 12);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const rel = 'grammar/sense_course.json';
  late Directory dir;
  late Map<String, dynamic> bundled;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('sense_server');
    bundled = json.decode(File('assets/data/$rel').readAsStringSync()) as Map<String, dynamic>;
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Map<String, dynamic> base() => {
        'rev': 10,
        'files': {rel: 'bundled-sha'},
      };

  Future<List<String>> stepsFrom(String? serverBody) async {
    final s = ScriptSync.forTest(
      dir: dir,
      baseline: base(),
      fetch: (url) async {
        if (serverBody == null) return null; // 서버 못 받음
        if (url.endsWith('/index.json')) return json.encode({'rev': 11, 'files': {rel: sha(serverBody)}});
        if (url.contains(rel)) return serverBody;
        return null;
      },
    );
    await s.refresh();
    final d = json.decode(await s.load(rel)) as Map<String, dynamic>;
    return [for (final lv in SenseCourse.levels(d)) lv['id'] as String];
  }

  test('서버 목록에서 스텝이 빠지면 안 보임', () async {
    final server = Map<String, dynamic>.from(bundled)..['levels'] = (bundled['levels'] as List).where((l) => l['id'] != 'L4').toList();
    final steps = await stepsFrom(json.encode(server));
    expect(steps, isNot(contains('L4')));
    expect(steps.length, 10);
  });

  test('서버 목록에 스텝이 더해지면 보임(15 넘어도 코드 수정 없이), 내용 없는 스텝은 숨김', () async {
    final extra = [
      for (var i = 11; i <= 16; i++)
        {
          'id': 'L$i',
          'title': '스텝 $i',
          'lessons': [
            {'id': 'L$i-talk', 'kind': 'talk', 'title': 't', 'sentences': i == 13 ? [] : ['文']}
          ]
        }
    ];
    final server = Map<String, dynamic>.from(bundled)..['levels'] = [...bundled['levels'] as List, ...extra];
    final steps = await stepsFrom(json.encode(server));
    expect(steps.length, 16);
    expect(steps.last, 'L16');
    expect(steps, isNot(contains('L13')));
  });

  test('서버를 못 받으면 묶음 목록', () async {
    final steps = await stepsFrom(null);
    expect(steps, [for (var i = 0; i <= 10; i++) 'L$i']);
  });
}
