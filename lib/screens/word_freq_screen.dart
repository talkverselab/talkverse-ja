import '../core/embed_env.dart';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/learner_prefs.dart';
import '../services/tts_service.dart';
import '../widgets/furigana_toggle.dart';
import '../services/word_service.dart' show WordService;
import '../widgets/japanese_decor.dart';
import '../widgets/word_card.dart';

/// 절벽 단어 — 회화 빈도 1~2,000위를 절벽구간(R1~R5)별 **20어 단원**으로, 단어는 **네모 타일**로 보여 준다(사용자 지시 2026-11-07).
/// 위 버튼 「절벽구간 단어만 / 회화 단어 포함」 — 포함이면 215편 회화에 나오지만 2,000위 밖인 단어(assets/data/freq/conv_words_ja.json)가
/// 「회화」 구간으로 뒤에 붙는다. DB 는 그대로 둘(빈도표·회화 레마)이고 화면에서만 합친다.
class WordFreqScreen extends StatefulWidget {
  const WordFreqScreen({super.key});

  @override
  State<WordFreqScreen> createState() => _WordFreqScreenState();
}

/// 절벽 v2 절대 기준(2026-11-03, 누적 55/60/70/80%) · R5 는 2,000위에서 끊음(사용자 지시 2026-11-07, 2,000위 누적 87.4%).
const int kWordCap = 2000;
const int kUnit = 20;

class _WordFreqScreenState extends State<WordFreqScreen> {
  List<WordEntry> _words = [];
  List<WordEntry> _conv = [];
  bool _loading = true;
  bool _withConv = false;
  String _filter = 'ALL';

  static Map<String, _Region> get _regions => {
    'ALL': _Region(tr('전체'), AppColors.sumi, 0, kWordCap),
    'R1': _Region('R1 · 1-62', AppColors.beni, 1, 62),
    'R2': _Region('R2 · 63-96', AppColors.beniLight, 63, 96),
    'R3': _Region('R3 · 97-251', AppColors.kin, 97, 251),
    'R4': _Region('R4 · 252-778', AppColors.matcha, 252, 778),
    'R5': _Region('R5 · 779-2000', AppColors.muted, 779, kWordCap),
    'C': _Region(tr('회화'), AppColors.ai, 0, 0),
  };

  @override
  void initState() {
    super.initState();
    LearnerPrefs.furigana.addListener(_onFuri);
    _load();
  }

  void _onFuri() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    LearnerPrefs.furigana.removeListener(_onFuri);
    super.dispose();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString(assetPath('assets/data/freq/lang_ja_with_regions.csv'));
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    final entries = <WordEntry>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;
      final rank = int.tryParse('${row[0]}') ?? 0;
      if (rank < 1 || rank > kWordCap) continue;
      entries.add(WordEntry(rank: rank, word: '${row[1]}', cumPct: double.tryParse('${row[3]}') ?? 0, region: '${row[4]}'.trim()));
    }
    // 뜻·읽기는 단어 DB 에서(표면형 일치 — 없으면 단어만)
    final found = await WordService.instance.byLemmas(entries.map((e) => e.word));
    for (final e in entries) {
      final w = found[e.word];
      if (w != null) {
        e.kana = w.kana == e.word ? '' : w.kana;
        e.ko = w.gloss;
      }
    }
    final conv = <WordEntry>[];
    try {
      final j = json.decode(await rootBundle.loadString(assetPath('assets/data/freq/conv_words_ja.json'))) as Map<String, dynamic>;
      var n = 0;
      for (final w in (j['words'] as List).cast<Map<String, dynamic>>()) {
        n++;
        final word = w['word'] as String;
        final kana = (w['kana'] as String?) ?? '';
        conv.add(WordEntry(rank: n, word: word, cumPct: 0, region: 'C')
          ..kana = kana == word ? '' : kana
          ..ko = (w['ko'] as String?) ?? '');
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _words = entries;
      _conv = conv;
      _loading = false;
    });
  }

  List<WordEntry> get _pool => _withConv ? [..._words, ..._conv] : _words;

  @override
  Widget build(BuildContext context) {
    final pool = _pool;
    final filtered = _filter == 'ALL' ? pool : pool.where((w) => w.region == _filter).toList();
    final units = <List<WordEntry>>[];
    for (var i = 0; i < filtered.length; i += kUnit) {
      units.add(filtered.sublist(i, (i + kUnit).clamp(0, filtered.length)));
    }
    final chips = _regions.entries.where((e) => e.key != 'C' || _withConv).toList();

    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('절벽 단어'), style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(trf('회화 빈도 {0}위 · {1}어 단원 · 탭하면 발음', ['2,000', kUnit]),
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
        actions: const [FuriganaToggleAction()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Column(
              children: [
                Container(
                  color: AppColors.washiDeep,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _ModeButton(label: tr('절벽구간 단어만'), selected: !_withConv, onTap: () => setState(() { _withConv = false; if (_filter == 'C') _filter = 'ALL'; })),
                          const SizedBox(width: 8),
                          _ModeButton(label: trf('회화 단어 포함 (+{0})', [_conv.length]), selected: _withConv, onTap: () => setState(() => _withConv = true)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: chips.map((e) {
                            final selected = _filter == e.key;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _filter = e.key),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: selected ? e.value.color : AppColors.washi,
                                    border: Border.all(color: e.value.color, width: selected ? 1.5 : 0.8),
                                  ),
                                  child: Text(e.value.label,
                                      style: TextStyle(color: selected ? AppColors.washi : e.value.color, fontWeight: FontWeight.w700, fontSize: 12)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const AsanohaDivider(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 16 + bottomInset(context)),
                    itemCount: units.length,
                    itemBuilder: (context, i) => _UnitBlock(index: i + 1, words: units[i], regions: _regions),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.sumi : AppColors.washi,
              border: Border.all(color: selected ? AppColors.sumi : AppColors.line),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label,
                style: TextStyle(color: selected ? AppColors.washi : AppColors.sumi, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ),
      );
}

/// 한 단원 = 20어. 머리줄(단원 번호·순위 범위·구간) + 네모 타일 격자.
class _UnitBlock extends StatelessWidget {
  final int index;
  final List<WordEntry> words;
  final Map<String, _Region> regions;
  const _UnitBlock({required this.index, required this.words, required this.regions});

  @override
  Widget build(BuildContext context) {
    final first = words.first;
    final last = words.last;
    final region = regions[first.region];
    final range = first.region == 'C'
        ? trf('회화 {0}-{1}', [first.rank, last.rank])
        : '#${first.rank}-${last.rank}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
            child: Row(
              children: [
                Text(trf('{0}단원', [index]), style: const TextStyle(color: AppColors.sumi, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Text(range, style: const TextStyle(color: AppColors.sumiLight, fontSize: 11)),
                const Spacer(),
                if (region != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: region.color, borderRadius: BorderRadius.circular(2)),
                    child: Text(first.region == 'C' ? tr('회화') : first.region,
                        style: const TextStyle(color: AppColors.washi, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: WordCard.grid,
            itemCount: words.length,
            itemBuilder: (context, i) {
              final w = words[i];
              return WordCard(
                word: w.word,
                kana: w.kana,
                gloss: w.ko,
                badge: w.region == 'C' ? '会' : '#${w.rank}',
                badgeColor: region?.color ?? AppColors.sumi,
                artRank: w.region == 'C' ? null : w.rank,
                onSpeak: () => TtsService.instance.speak(w.word),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 네모 타일 — 그림(있으면) · 단어 · 읽기 · 뜻. 탭하면 발음.
class WordEntry {
  final int rank;
  final String word;
  final double cumPct;
  final String region; // R1~R5 · C(회화 단어)
  String kana = '';
  String ko = '';
  WordEntry({required this.rank, required this.word, required this.cumPct, required this.region});
}

class _Region {
  final String label;
  final Color color;
  final int start;
  final int end;
  const _Region(this.label, this.color, this.start, this.end);
}
