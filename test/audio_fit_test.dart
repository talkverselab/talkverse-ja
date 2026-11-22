import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/services/dialogue_audio.dart';

void main() {
  test('녹음 글과 원고 — 자리 표시·성별판은 맞음, 다시 쓴 대사는 안 맞음', () {
    expect(audioFitsScript('ある！『雨のち恋人』。絶対見て。', 'ある！『{drama}』。絶対見て。'), isTrue);
    expect(audioFitsScript('アレックスはね、強い人って意味。', '{name}はね、{name_meaning}って意味。'), isTrue);
    expect(audioFitsScript('青が私？', '青が僕？'), isTrue);
    expect(audioFitsScript('……。じゃあ、彼氏の誕生日。', '……。じゃあ、彼女の誕生日。'), isTrue);
    expect(audioFitsScript('こわい！マジでこの顔、ヤバい。何これ', 'こわい！マジでこの顔、ヤバい。何だよこれ'), isTrue);
    expect(audioFitsScript('今日、予約してあるんだけど。駅前の、あのイタリアン。', '今日さ、駅前のイタリアン、予約しといたんだけど…'), isFalse);
  });
}
