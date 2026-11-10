import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/services/dialogue_service.dart';
import 'package:japanese_universe/widgets/episode_play_pane.dart';

/// 회화 재생 칸이 어떤 칸 크기에서도 넘치지 않는지(아이패드 가로 오른쪽 칸·전체 화면·세로 칸·폰).
void main() {
  final f = Directory('assets/data/dialogues/R1').listSync(recursive: true).whereType<File>().firstWhere((f) => f.path.endsWith('.json'));
  final j = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  for (final t in j['turns'] as List) {
    (t as Map).remove('lemmas'); // 단어 DB 없이 배치만 본다
  }
  final d = Dialogue.fromJson(j);
  for (final size in const [Size(760, 600), Size(1194, 760), Size(640, 560), Size(520, 1000), Size(390, 760), Size(800, 340)]) {
    testWidgets('play pane fits ${size.width.round()}x${size.height.round()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: EpisodePlayPane(dialogue: d, autoPlay: false))));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      // 같은 대사가 장면 칸과 스크립트에 두 번 나오지 않는다
      expect(find.text('대화 스크립트'), findsOneWidget);
    });
  }
}
