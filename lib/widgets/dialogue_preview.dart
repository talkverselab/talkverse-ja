import 'package:flutter/material.dart';

import 'word_card.dart';
import '../core/prefs.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/dialogue_service.dart';
import '../services/learner_prefs.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../services/kanji_index_service.dart';
import 'japanese_decor.dart';
import 'selectable_ja_text.dart';
import 'word_sheet.dart';

/// 회화 시작 전 「새 단어·문법」 미리보기(사용자 지시 2026-11-08: "회화 초반에 그 회화에 나오는 한자 단어 등을 보여줘야…
/// '이번 회화에 나오는 새 단어·문법입니다. 읽고 암기는 문장으로 하세요'").
/// 재료: 턴 note 의 「표현 = 뜻」 쌍(〜 로 시작하면 문법) + 턴 new 단어(note 에 없으면 단어 DB 뜻). 읽기는 레마 → 단어 DB 순.
/// 편마다 처음 열 때 한 번 자동으로 뜨고, 앱바 버튼으로 언제든 다시 연다.
class PreviewItem {
  final String term, reading, meaning;
  final bool grammar;
  final WordEntry? entry;
  const PreviewItem(this.term, this.reading, this.meaning, this.grammar, this.entry);
}

final _kanji = RegExp(r'[一-龥々〆]');

Future<List<PreviewItem>> buildPreview(Dialogue d) async {
  final pairs = <String, String>{}; // term → meaning (등장 순)
  for (final t in d.turns) {
    for (final part in LearnerPrefs.fill(t.note).split(RegExp(r'\s*·\s*'))) {
      final m = RegExp(r'^(.+?)\s*=\s*(.+)$').firstMatch(part.trim());
      if (m == null) continue;
      final term = m.group(1)!.trim();
      final mean = m.group(2)!.split(RegExp(r'\s+—\s+')).first.trim(); // 「— 반전」 같은 연출 메모는 뗀다
      if (term.isEmpty || term.length > 16 || pairs.containsKey(term)) continue;
      pairs[term] = mean;
    }
  }
  final news = <String>[for (final t in d.turns) ...t.newWords];
  final lemmaRd = <String, String>{};
  for (final t in d.turns) {
    for (final l in t.lemmas) {
      if (l.reading.isEmpty) continue;
      lemmaRd.putIfAbsent(l.surface, () => l.reading);
      lemmaRd.putIfAbsent(l.base, () => l.reading);
    }
  }
  final terms = <String>{...pairs.keys, ...news};
  final db = await WordService.instance.byLemmas(terms.where((x) => !x.startsWith('〜')), readings: lemmaRd);
  final words = <PreviewItem>[], grammar = <PreviewItem>[];
  for (final term in terms) {
    // 〜 문형·물음/감탄이 붙은 말·긴 구절 = 「문법·표현」, 나머지(낱말) = 「단어」. new 단어는 항상 단어.
    final g = !news.contains(term) && (term.startsWith('〜') || term.startsWith('~') || RegExp(r'[?？!！、。 ]').hasMatch(term) || term.length > 6);
    final e = db[term];
    final mean = pairs[term] ?? e?.gloss ?? '';
    if (mean.isEmpty) continue;
    var rd = lemmaRd[term] ?? e?.kana ?? '';
    if (!_kanji.hasMatch(term) || rd == term) rd = '';
    (g ? grammar : words).add(PreviewItem(term, rd, mean, g, e));
  }
  // 새 단어(new)를 앞으로, 그다음 note 순서
  words.sort((a, b) => (news.contains(b.term) ? 1 : 0).compareTo(news.contains(a.term) ? 1 : 0));
  return [...words, ...grammar];
}

/// 편을 처음 열면 한 번 띄운다.
Future<void> maybeShowDialoguePreview(BuildContext context, Dialogue d) async {
  final p = await Prefs.getInstance();
  final key = 'preview_seen_${d.id}';
  if (p.getBool(key) ?? false) return;
  await p.setBool(key, true);
  if (context.mounted) await showDialoguePreview(context, d);
}

Future<void> showDialoguePreview(BuildContext context, Dialogue d) async {
  final items = await buildPreview(d);
  if (!context.mounted || items.isEmpty) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.washi,
    constraints: const BoxConstraints(maxWidth: 720),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (ctx) => _PreviewSheet(d: d, items: items),
  );
}

class _PreviewSheet extends StatelessWidget {
  final Dialogue d;
  final List<PreviewItem> items;
  const _PreviewSheet({required this.d, required this.items});

  @override
  Widget build(BuildContext context) {
    final words = items.where((x) => !x.grammar).toList();
    final grammar = items.where((x) => x.grammar).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (ctx, sc) => ListView(
        controller: sc,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bottomInset(context)),
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Text('${d.emoji} ${d.title}', style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          GradText(tr('새 단어 · 문법'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.line)),
            child: Text(tr('이번 회화에 나오는 새 단어·문법입니다. 읽어 보고, 암기는 문장으로 하세요.'),
                style: const TextStyle(fontSize: 13.5, color: AppColors.sumi, height: 1.5, fontWeight: FontWeight.w600)),
          ),
          if (words.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(trf('단어 {0}', [words.length]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumiLight)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: WordCard.grid,
              itemCount: words.length,
              itemBuilder: (context, i) {
                final w = words[i];
                void speak() => TtsService.instance.speak(w.term.replaceAll(RegExp(r'^[〜~]'), ''));
                return WordCard(
                  word: w.term,
                  segs: w.entry?.segs,
                  kana: w.reading,
                  gloss: w.meaning,
                  showRuby: LearnerPrefs.furigana.value,
                  onTap: w.entry == null ? speak : () => showWordSheet(context, w.entry!),
                  onSpeak: speak,
                );
              },
            ),
          ],
          if (grammar.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(trf('문법 · 표현 {0}', [grammar.length]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumiLight)),
            const SizedBox(height: 8),
            for (final g in grammar) _Row(item: g),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: AppColors.beni, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: const StadiumBorder()),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(tr('회화 시작'), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final PreviewItem item;
  const _Row({required this.item});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: item.grammar ? AppColors.ai.withValues(alpha: 0.35) : AppColors.line)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => TtsService.instance.speak(item.term.replaceAll(RegExp(r'^[〜~]'), '')),
          onLongPress: item.entry == null ? null : () => showWordSheet(context, item.entry!),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Expanded(
                flex: 5,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  if (item.reading.isNotEmpty) Text(item.reading, style: const TextStyle(fontSize: 11, color: AppColors.ai, fontWeight: FontWeight.w600)),
                  Wrap(children: [
                    for (final ch in item.term.characters)
                      if (KanjiIndexService.isKanji(ch))
                        InkWell(
                          onTap: () async {
                            await KanjiIndexService.instance.ensureLoaded();
                            if (context.mounted) showKanjiSheet(context, char: ch, entry: KanjiIndexService.instance.lookup(ch));
                          },
                          child: Container(
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.sumi.withValues(alpha: 0.4)))),
                            child: Text(ch, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                          ),
                        )
                      else
                        Text(ch, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                  ]),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(flex: 6, child: Text(item.meaning, style: const TextStyle(fontSize: 13.5, color: AppColors.sumi, height: 1.35))),
              const Icon(Icons.volume_up_outlined, size: 18, color: AppColors.muted),
            ]),
          ),
        ),
      );
}
