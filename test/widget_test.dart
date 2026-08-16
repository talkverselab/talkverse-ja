import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/core/theme.dart';

void main() {
  test('kana row color cycles', () {
    expect(kanaRowColor(0), AppColors.kanaVowel);
    expect(kanaRowColor(10), AppColors.kanaVowel);
  });
}
