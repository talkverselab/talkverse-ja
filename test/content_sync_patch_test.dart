import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/services/content_sync.dart';

/// 변경분 덧입히기: 바뀐 줄만 바뀌고, 같은 변경을 두 번 넣어도 줄이 늘지 않는다(중복 없음).
void main() {
  final body = json.encode({
    'lang': 'ja',
    'count': 2,
    'base': 'https://x/art/',
    'items': [
      {'episode': 'r1_life_a1', 'cut': 1, 'key_1168': 'scene/ja/r1_life_a1/cut1.webp?v=aaaa1111', 'key_584': 's1'},
      {'episode': 'r1_life_a1', 'cut': 2, 'key_1168': 'scene/ja/r1_life_a1/cut2.webp?v=bbbb2222', 'key_584': 's2'},
    ],
  });
  final changes = [
    {'kind': 'scene', 'op': 'put', 'id': 'r1_life_a1#2', 'item': {'episode': 'r1_life_a1', 'cut': 2, 'key_1168': 'scene/ja/r1_life_a1/cut2.webp?v=cccc3333', 'key_584': 's2b'}},
    {'kind': 'scene', 'op': 'put', 'id': 'r2_work_b1#1', 'item': {'episode': 'r2_work_b1', 'cut': 1, 'key_1168': 'k', 'key_584': 'k2'}},
    {'kind': 'scene', 'op': 'del', 'id': 'r1_life_a1#1'},
  ];

  test('put replaces, adds; del removes', () {
    final j = json.decode(ContentSync.patchManifest(body, 'scene', changes)) as Map;
    final items = j['items'] as List;
    expect(j['count'], 2);
    expect(items.map((e) => ContentSync.itemId('scene', e as Map)).toSet(), {'r1_life_a1#2', 'r2_work_b1#1'});
    expect((items.firstWhere((e) => e['cut'] == 2 && e['episode'] == 'r1_life_a1') as Map)['key_1168'], endsWith('cccc3333'));
    expect(j['base'], 'https://x/art/');
  });

  test('applying the same changes twice gives the same result', () {
    final once = ContentSync.patchManifest(body, 'scene', changes);
    expect(ContentSync.patchManifest(once, 'scene', changes), once);
  });

  test('ids per kind', () {
    expect(ContentSync.itemId('words', {'id': 'ja/犬'}), 'ja/犬');
    expect(ContentSync.itemId('audio', {'episode': 'r0_a', 'turn': 3, 'voice': 'f'}), 'r0_a#3#f');
  });
}
