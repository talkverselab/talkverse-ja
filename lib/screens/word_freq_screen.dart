import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/theme.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../core/l10n.dart';

class WordFreqScreen extends StatefulWidget {
  const WordFreqScreen({super.key});

  @override
  State<WordFreqScreen> createState() => _WordFreqScreenState();
}

class _WordFreqScreenState extends State<WordFreqScreen> {
  List<WordEntry> _words = [];
  bool _loading = true;
  String _filter = 'ALL';

  static Map<String, _Region> get _regions => {
    'ALL': _Region(tr('전체'), AppColors.sumi, 0, 2500),
    'R1': _Region('R1 · 1-294', AppColors.beni, 1, 294),
    'R2': _Region('R2 · 295-437', AppColors.beniLight, 295, 437),
    'R3': _Region('R3 · 438-998', AppColors.kin, 438, 998),
    'R4': _Region('R4 · 999-2500', AppColors.matcha, 999, 2500),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/freq/lang_ja_with_regions.csv');
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    final entries = <WordEntry>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;
      entries.add(WordEntry(
        rank: int.tryParse('${row[0]}') ?? 0,
        word: '${row[1]}',
        freq: double.tryParse('${row[2]}') ?? 0,
        cumPct: double.tryParse('${row[3]}') ?? 0,
        region: '${row[4]}'.trim(),
      ));
    }
    setState(() {
      _words = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'ALL'
        ? _words
        : _words.where((w) => w.region == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('단어 빈도 2500'), style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text(tr('회화 자막 코퍼스 · 탭하면 발음'), style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Column(
              children: [
                Container(
                  color: AppColors.washiDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _regions.entries.map((e) {
                        final selected = _filter == e.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? e.value.color : AppColors.washi,
                                border: Border.all(
                                  color: e.value.color,
                                  width: selected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Text(
                                e.value.label,
                                style: TextStyle(
                                  color: selected ? AppColors.washi : e.value.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const AsanohaDivider(),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        Container(height: 0.5, color: AppColors.kin.withValues(alpha: 0.3)),
                    itemBuilder: (context, i) {
                      final w = filtered[i];
                      final region = _regions[w.region];
                      return InkWell(
                        onTap: () => TtsService.instance.speak(w.word),
                        child: Container(
                        color: AppColors.washi,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                '#${w.rank}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.sumiLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.word,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.sumi,
                                    ),
                                  ),
                                  Text(
                                    trf('누적 {0}%', [w.cumPct.toStringAsFixed(2)]),
                                    style: const TextStyle(fontSize: 10, color: AppColors.sumiLight),
                                  ),
                                ],
                              ),
                            ),
                            if (region != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: region.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  w.region,
                                  style: const TextStyle(
                                    color: AppColors.washi,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class WordEntry {
  final int rank;
  final String word;
  final double freq;
  final double cumPct;
  final String region;
  WordEntry({
    required this.rank,
    required this.word,
    required this.freq,
    required this.cumPct,
    required this.region,
  });
}

class _Region {
  final String label;
  final Color color;
  final int start;
  final int end;
  const _Region(this.label, this.color, this.start, this.end);
}
