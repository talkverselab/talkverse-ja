import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/services/content_sync.dart';
import 'package:japanese_universe/widgets/sync_status_card.dart';

void main() {
  for (final w in const [320.0, 390.0, 700.0]) {
    testWidgets('내려받기 현황 카드 폭 $w', (t) async {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: w, child: const SyncStatusCard())))));
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
      expect(find.text('다시 받기'), findsOneWidget);
      expect(find.text('내려받기 현황'), findsOneWidget);
    });
  }

  test('종류별 진행 — 비어 있을 때', () {
    expect(ContentSync.instance.kindProgress.keys, ['word', 'scene', 'audio']);
  });
}
