import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/services/romaji.dart';

void main() {
  test('가나 → 헵번식', () {
    expect(Romaji.fromKana('しんぶん'), 'shinbun');
    expect(Romaji.fromKana('きょう'), 'kyou');
    expect(Romaji.fromKana('ちょっとまって'), 'chottomatte');
    expect(Romaji.fromKana('マッチ'), 'matchi');
    expect(Romaji.fromKana('コーヒー'), 'koohii');
    expect(Romaji.fromKana('しんや'), "shin'ya");
    expect(Romaji.fromKana('じゃあ、いこう。'), 'jaa, ikou.');
    expect(Romaji.fromKana('ファイル'), 'fairu');
  });
}
