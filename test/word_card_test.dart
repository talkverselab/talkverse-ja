import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/widgets/word_card.dart';

/// 단어 카드가 좁은 칸(폰 2열·아이패드 칸)에서도 넘치지 않는다.
void main() {
  for (final w in const [150.0, 180.0, 210.0]) {
    testWidgets('word card fits width $w', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: w,
              height: w / 0.78,
              child: WordCard(word: 'コミュニケーション', kana: 'コミュニケーション', gloss: 'communication · 커뮤니케이션 · 의사소통', note: '예외: 길게 늘어지는 메모 한 줄', badge: 'N1', onSpeak: () {}),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('N1'), findsOneWidget);
    });
  }
}
