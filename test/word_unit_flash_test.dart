import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/screens/word_unit_flash_screen.dart';

void main() {
  test('품사 꼬리표', () {
    expect(posLabel('sentence-final particle'), '조사');
    expect(posLabel('copula'), '조동사');
    expect(posLabel('noun suffix'), '접미사');
    expect(posLabel(''), '문법');
  });

  test('StudyWord 읽을 말', () {
    expect(const StudyWord(word: '～さん').speakText, 'さん');
    expect(const StudyWord(word: '食べる', kana: 'たべる').speakText, 'たべる');
  });

  testWidgets('안내 문구', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: SentenceTip(sub: '부제'))));
    expect(find.text('문장으로 외우는 게 더 좋아요'), findsOneWidget);
    expect(find.text('부제'), findsOneWidget);
  });
}
