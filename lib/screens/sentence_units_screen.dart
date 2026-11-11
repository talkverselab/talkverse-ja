import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/dialogue_audio.dart';
import '../services/dialogue_service.dart';
import '../services/learner_prefs.dart';
import '../services/mastery.dart';
import 'dialogue_screen.dart' show openDialogueAt;
import 'word_unit_flash_screen.dart';

/// 문장 10 단원(사용자 지시 2026-11-11 uk 경유 「단어는 20개 문장은 10개」).
/// 그 급(R0~R4) 회화에 실제 나온 줄을 편 순서대로 10줄씩 묶는다. 말이 아닌 줄(「……。」·괄호 지문·♡)과 같은 문장은 뺀다.
/// 기록 id = `s:<편 id>:<턴 번호>`([Mastery]).
const int kSentenceUnit = 10;

class SentenceCard extends FlashItem {
  final Dialogue d;
  final int index;
  SentenceCard(this.d, this.index);
  DialogueTurn get t => d.view(d.turns[index]);
  @override
  String get id => 's:${d.id}:${d.turns[index].num}';
  @override
  Future<void> speak() => speakTurn(d, d.turns[index]);

  @override
  Widget front(BuildContext context) => Padding(
        key: ValueKey('sf:$id'),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
        child: Column(children: [
          Text('${d.region} · ${d.emoji} ${d.title}', style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
          Expanded(
            child: Center(
              child: Text(LearnerPrefs.fill(t.ko, ko: true),
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.4)),
            ),
          ),
          Text(tr('일본어로 말해 보고 탭해서 뒤집기'), style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
        ]),
      );

  @override
  Widget back(BuildContext context) => SingleChildScrollView(
        key: ValueKey('sb:$id'),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(LearnerPrefs.fill(t.shown), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1.35)),
          const SizedBox(height: 4),
          if (t.kana.isNotEmpty && t.kana != t.ja) Text(LearnerPrefs.fill(t.kana), style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
          Text(LearnerPrefs.readingLine(t.rd, t.kana), style: const TextStyle(fontSize: 13, color: AppColors.sumiLight)),
          const SizedBox(height: 10),
          Text(LearnerPrefs.fill(t.ko, ko: true), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ai, height: 1.4)),
          if (t.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('💡 ${t.note}', style: const TextStyle(fontSize: 12.5, color: AppColors.sumi, height: 1.4)),
          ],
          const SizedBox(height: 14),
          Row(children: [
            IconButton(tooltip: tr('듣기'), icon: const Icon(Icons.volume_up, color: AppColors.beni), onPressed: speak),
            const Spacer(),
            TextButton(onPressed: () => openDialogueAt(context, d, index), child: Text(tr('이 회화로 →'))),
          ]),
        ]),
      );
}

/// 말이 아닌 줄인지 — 괄호 지문·말줄임표·기호만인 줄.
bool _isSpeech(String ja) {
  final s = ja.replaceAll(RegExp(r'[（(][^)）]*[)）]'), '').replaceAll(RegExp(r'[\s　、。…・？！?!♡♪〜ー「」『』wｗ]'), '');
  return RegExp(r'[ぁ-んァ-ヶ一-龯]').hasMatch(s);
}

/// 그 급의 문장 단원들.
List<List<SentenceCard>> sentenceUnits(String region) {
  final svc = DialogueService.instance;
  final ds = [for (final isl in svc.islandsOf(region)) ...svc.list(region: region, island: isl)];
  final seen = <String>{};
  final cards = <SentenceCard>[];
  for (final d in ds) {
    for (var i = 0; i < d.turns.length; i++) {
      final ja = d.turns[i].ja;
      if (!_isSpeech(ja) || !seen.add(ja)) continue;
      cards.add(SentenceCard(d, i));
    }
  }
  return [for (var i = 0; i < cards.length; i += kSentenceUnit) cards.sublist(i, (i + kSentenceUnit).clamp(0, cards.length))];
}

class SentenceUnitsScreen extends StatefulWidget {
  const SentenceUnitsScreen({super.key});
  @override
  State<SentenceUnitsScreen> createState() => _SentenceUnitsScreenState();
}

class _SentenceUnitsScreenState extends State<SentenceUnitsScreen> {
  bool _loading = true;
  String _region = 'R1';
  final Map<String, List<List<SentenceCard>>> _units = {};

  @override
  void initState() {
    super.initState();
    Future.wait([DialogueService.instance.ensureLoaded(), Mastery.load()]).then((_) {
      if (!mounted) return;
      setState(() {
        for (final r in DialogueService.levels) {
          final u = sentenceUnits(r);
          if (u.isNotEmpty) _units[r] = u;
        }
        if (!_units.containsKey(_region) && _units.isNotEmpty) _region = _units.keys.first;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.washi,
        appBar: AppBar(
          title: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(tr('문장 단원'), style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            Text(trf('회화에 나온 줄 · {0}문장 단원', [kSentenceUnit]), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1)),
          ]),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder<int>(
                valueListenable: Mastery.version,
                builder: (context, _, _) => _body(),
              ),
      );

  Widget _body() {
    final units = _units[_region] ?? const [];
    return Column(children: [
      Container(
        color: AppColors.washiDeep,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: SizedBox(
          height: 34,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final r in _units.keys)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: ValueKey('sunit-region-$r'),
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(r, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    MasteryPill(Mastery.average(_units[r]!.expand((u) => u).map((c) => c.id)), fontSize: 9),
                  ]),
                  selected: r == _region,
                  onSelected: (_) => setState(() => _region = r),
                ),
              ),
          ]),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 16 + bottomInset(context)),
          itemCount: units.length,
          itemBuilder: (context, i) => _UnitTile(region: _region, index: i + 1, cards: units[i]),
        ),
      ),
    ]);
  }
}

class _UnitTile extends StatelessWidget {
  final String region;
  final int index;
  final List<SentenceCard> cards;
  const _UnitTile({required this.region, required this.index, required this.cards});

  @override
  Widget build(BuildContext context) {
    final avg = Mastery.average(cards.map((c) => c.id));
    final title = '$region · ${trf('{0}단원', [index])}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.washi,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: masteryColor(avg).withValues(alpha: 0.6))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('sunit-$region-$index'),
          onTap: () => openFull(context, (_) => UnitFlashScreen(title: title, items: cards)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(children: [
              SizedBox(width: 56, child: Text(trf('{0}단원', [index]), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi))),
              Expanded(
                child: Text(
                  cards.map((c) => LearnerPrefs.fill(c.t.ja)).take(3).join('  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.sumiLight),
                ),
              ),
              const SizedBox(width: 8),
              MasteryPill(avg),
              const Icon(Icons.chevron_right, color: AppColors.sumiLight),
            ]),
          ),
        ),
      ),
    );
  }
}
