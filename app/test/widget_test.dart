import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/app.dart';

void main() {
  testWidgets('App boots without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const JapaneseUniverseApp());
    await tester.pump();
  });
}
