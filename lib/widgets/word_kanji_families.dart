import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../screens/hanja_family_screen.dart' show openHanjaFamily;
import '../services/hanja_family_service.dart';
import '../services/kanji_index_service.dart';
import 'selectable_ja_text.dart' show showKanjiSheet;

/// 단어 속 한자를 소리 가족으로 엮는다(사용자 지시 2026-11-11 "단어 안에서도 한자가 있으면 패밀리 한자로 엮이도록").
/// 한자마다 한 줄: 씨앗(소리 부품) + 같은 가족 글자들. 글자를 누르면 한자 팝업, 「가족 지도」는 가족 화면.
/// 가족이 없는 글자(또는 가족 DB 를 아직 못 받은 때)는 줄을 내지 않는다.
class WordKanjiFamilies extends StatelessWidget {
  final String word;
  final int maxMembers;
  const WordKanjiFamilies({super.key, required this.word, this.maxMembers = 8});

  static List<String> kanjiOf(String word) {
    final seen = <String>{};
    return [for (final c in word.characters) if (KanjiIndexService.isKanji(c) && seen.add(c)) c];
  }

  @override
  Widget build(BuildContext context) {
    final chars = kanjiOf(word);
    if (chars.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<void>(
      future: Future.wait([HanjaFamilyService.instance.ensureLoaded(), KanjiIndexService.instance.ensureLoaded()]),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const SizedBox.shrink();
        final svc = HanjaFamilyService.instance;
        final rows = <Widget>[];
        final doneRoots = <String>{};
        for (final c in chars) {
          final root = svc.rootOfGlyph(c);
          if (root == null || !doneRoots.add(root.code)) continue;
          final members = svc.familyOf(root.code);
          if (members.isEmpty) continue;
          rows.add(_FamilyRow(char: c, root: root, members: members, max: maxMembers));
        }
        if (rows.isEmpty) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 14),
          Text(tr('한자 가족'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.sumiLight, letterSpacing: 1)),
          ...rows,
        ]);
      },
    );
  }
}

class _FamilyRow extends StatelessWidget {
  final String char;
  final HanjaChar root;
  final List<HanjaChar> members;
  final int max;
  const _FamilyRow({required this.char, required this.root, required this.members, required this.max});

  bool _jlpt(HanjaChar h) => h.jlpt != null || KanjiIndexService.instance.lookup(h.jp)?.jlpt != null;

  @override
  Widget build(BuildContext context) {
    // 이 단어의 글자 → 씨앗 → JLPT 글자 순으로, 넘치면 「+N」
    final rest = [for (final m in members) if (m.jp != char && m.code != root.code) m]..sort((a, b) => (_jlpt(b) ? 1 : 0) - (_jlpt(a) ? 1 : 0));
    final self = HanjaFamilyService.instance.byGlyph[char];
    final list = <HanjaChar>[?self, if (self?.code != root.code) root, ...rest];
    final shown = list.take(max).toList();
    void open(HanjaChar h) => showKanjiSheet(context, char: h.jp, entry: KanjiIndexService.instance.lookup(h.jp));
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(color: AppColors.washiDeep, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(trf('{0} — 소리 부품 「{1}」({2}) 가족 {3}자', [char, root.jp, root.krSound, members.length]),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.sumi)),
            ),
            InkWell(
              onTap: () => openHanjaFamily(context, root),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text('${tr('가족 지도')} →', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ai)),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final m in shown)
              InkWell(
                onTap: () => open(m),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 44),
                  padding: const EdgeInsets.fromLTRB(7, 4, 7, 4),
                  decoration: BoxDecoration(
                    color: AppColors.washi,
                    border: Border.all(color: m.jp == char ? AppColors.beni : (m.code == root.code ? AppColors.kin : AppColors.line), width: m.jp == char ? 1.4 : 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(m.jp, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.1)),
                    Text('${m.hun} ${m.krSound}', style: const TextStyle(fontSize: 9.5, color: AppColors.sumiLight)),
                    if (m.on.isNotEmpty) Text(m.on, style: const TextStyle(fontSize: 9.5, color: AppColors.ai, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            if (list.length > shown.length)
              InkWell(
                onTap: () => openHanjaFamily(context, root),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  child: Text('+${list.length - shown.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.ai)),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}
