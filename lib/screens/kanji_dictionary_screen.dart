import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';

/// 한자 사전 — 검색(한자·뜻·읽기·단어) + 빈도순 브라우저 (1,078자).
class KanjiDictionaryScreen extends StatefulWidget {
  const KanjiDictionaryScreen({super.key});

  @override
  State<KanjiDictionaryScreen> createState() => _KanjiDictionaryScreenState();
}

class _KanjiDictionaryScreenState extends State<KanjiDictionaryScreen> {
  final _ctrl = TextEditingController();
  List<KanjiEntry> _all = const [];
  List<KanjiEntry> _results = const [];
  bool _loading = true;
  String _filter = 'ALL'; // ALL | N5..N1 | TOP (회화 300)

  static const _ranges = {
    'ALL': ('전체', null),
    'N5': ('N5', 5),
    'N4': ('N4', 4),
    'N3': ('N3', 3),
    'N2': ('N2', 2),
    'N1': ('N1', 1),
    'TOP': ('회화 Top300', -1),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await KanjiIndexService.instance.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _all = KanjiIndexService.instance.all;
      _loading = false;
    });
  }

  void _search(String q) {
    setState(() => _results = KanjiIndexService.instance.search(q));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searching = _ctrl.text.trim().isNotEmpty;
    final range = _ranges[_filter]!;
    final lv = range.$2;
    final list = searching
        ? _results
        : lv == null
            ? _all
            : lv == -1
                ? (_all.where((e) => e.rank <= 300).toList()..sort((a, b) => a.rank.compareTo(b.rank)))
                : (_all.where((e) => e.jlpt == lv).toList()..sort((a, b) => a.rank.compareTo(b.rank)));
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('한자 사전', style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('${_all.length}자 · JLPT N5-N1 + 회화 빈도',
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: TextField(
                    controller: _ctrl,
                    onChanged: _search,
                    style: const TextStyle(color: AppColors.sumi, fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '한자 · 뜻(사랑) · 읽기(あい) · 단어',
                      hintStyle: const TextStyle(color: AppColors.sumiLight, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.beni),
                      suffixIcon: searching
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18, color: AppColors.sumiLight),
                              onPressed: () {
                                _ctrl.clear();
                                _search('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.washiDeep,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(color: AppColors.kin),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(color: AppColors.kin.withValues(alpha: 0.6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: const BorderSide(color: AppColors.beni, width: 1.4),
                      ),
                    ),
                  ),
                ),
                if (!searching)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      children: _ranges.entries.map((e) {
                        final selected = _filter == e.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.beni : AppColors.washi,
                                border: Border.all(color: AppColors.beni, width: selected ? 1.5 : 0.8),
                              ),
                              child: Text(
                                e.value.$1,
                                style: TextStyle(
                                  color: selected ? AppColors.washi : AppColors.beni,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const AsanohaDivider(height: 8),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('결과 없음', style: TextStyle(color: AppColors.sumiLight)))
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => Container(height: 0.5, color: AppColors.kin.withValues(alpha: 0.3)),
                          itemBuilder: (context, i) => _KanjiRow(entry: list[i]),
                        ),
                ),
              ],
            ),
    );
  }
}

class _KanjiRow extends StatelessWidget {
  final KanjiEntry entry;
  const _KanjiRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final e = entry;
    return InkWell(
      onTap: () => showKanjiSheet(context, char: e.char, entry: e),
      child: Container(
        color: AppColors.washi,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(e.rank < 9999 ? '#${e.rank}' : '—',
                  style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, fontWeight: FontWeight.w700)),
            ),
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.washiDeep,
                border: Border.all(color: AppColors.kin.withValues(alpha: 0.6)),
              ),
              child: Text(e.char,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.beni, height: 1)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.meanings.isEmpty ? '—' : e.meaningJoined,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.sumi),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (e.on.isNotEmpty) '음 ${e.on.map((r) => r.reading).join('·')}',
                      if (e.kun.isNotEmpty) '훈 ${e.kun.map((r) => r.reading).join('·')}',
                    ].join('  '),
                    style: const TextStyle(fontSize: 11, color: AppColors.ai),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (e.jlpt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    color: AppColors.ai,
                    child: Text('N${e.jlpt}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.washi)),
                  ),
                if (e.rank < 9999)
                  Text('${e.pct.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
