import 'dialogue_service.dart';

/// 단어가 나온 회화 문장 하나 — [index] 는 그 편의 턴 위치(재생 시작점).
class WordExample {
  final Dialogue dialogue;
  final int index;
  final DialogueTurn turn; // 이름 치환이 끝난 보기용 턴
  const WordExample(this.dialogue, this.index, this.turn);
}

/// 단어 → 회화 문장 찾기(「문장으로 외우는 게 더 좋아요」, 사용자 지시 2026-11-11).
/// 내용어는 턴의 lemmas(기본형·표면형)로, 조사·조동사처럼 lemmas 에 없는 말은 문장에 그 글자가 들어 있는지로 찾는다.
/// 쉬운 단계·짧은 문장부터.
class WordExamples {
  WordExamples._();
  static final WordExamples instance = WordExamples._();

  Map<String, List<(Dialogue, int)>>? _byLemma;
  List<(Dialogue, int)> _all = const [];

  Future<void> ensureLoaded() async {
    if (_byLemma != null) return;
    await DialogueService.instance.ensureLoaded();
    final all = <(Dialogue, int)>[];
    for (final d in DialogueService.instance.all) {
      for (var i = 0; i < d.turns.length; i++) {
        all.add((d, i));
      }
    }
    int key((Dialogue, int) e) => DialogueService.levels.indexOf(e.$1.region) * 1000 + e.$1.turns[e.$2].ja.length;
    all.sort((a, b) => key(a).compareTo(key(b)));
    final m = <String, List<(Dialogue, int)>>{};
    for (final e in all) {
      for (final l in e.$1.turns[e.$2].lemmas) {
        for (final k in {l.base, l.surface}) {
          if (k.isNotEmpty) (m[k] ??= []).add(e);
        }
      }
    }
    _all = all;
    _byLemma = m;
  }

  /// [ensureLoaded] 뒤에 부른다. 편이 겹치지 않게 [max] 개까지.
  List<WordExample> find(String word, {int max = 3}) {
    final w = word.replaceAll(RegExp('[～〜~]'), '');
    if (w.isEmpty || _byLemma == null) return const [];
    Iterable<(Dialogue, int)> hits = _byLemma![w] ?? const [];
    if (hits.isEmpty) hits = _all.where((e) => e.$1.turns[e.$2].ja.contains(w));
    final out = <WordExample>[];
    final seen = <String>{};
    for (final e in hits) {
      if (!seen.add(e.$1.id)) continue;
      out.add(WordExample(e.$1, e.$2, e.$1.view(e.$1.turns[e.$2])));
      if (out.length >= max) break;
    }
    return out;
  }
}
