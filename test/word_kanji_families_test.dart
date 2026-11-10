import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/widgets/word_kanji_families.dart';

void main() {
  test('단어 속 한자만, 겹치지 않게', () {
    expect(WordKanjiFamilies.kanjiOf('食べ物'), ['食', '物']);
    expect(WordKanjiFamilies.kanjiOf('人々と人'), ['人']);
    expect(WordKanjiFamilies.kanjiOf('ぜひ'), isEmpty);
  });
}
