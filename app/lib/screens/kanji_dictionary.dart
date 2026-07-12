import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/kanji_index.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/kanji_detail_sheet.dart';
import '../widgets/manga_panel.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/sketchy_divider.dart';

/// 한자 사전 — 검색 + 빈도순 브라우저.
/// 검색어 없으면 가중 빈도 100자 단위 구간 그리드, 입력 시 결과 리스트.
/// 탭하면 KanjiDetailSheet (카드 세션과 동일한 상세 시트).
class KanjiDictionaryScreen extends StatefulWidget {
  const KanjiDictionaryScreen({super.key});

  @override
  State<KanjiDictionaryScreen> createState() => _KanjiDictionaryScreenState();
}

class _KanjiDictionaryScreenState extends State<KanjiDictionaryScreen> {
  final _controller = TextEditingController();
  List<KanjiEntry>? _all;
  List<KanjiEntry> _results = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await KanjiIndex.load();
    if (!mounted) return;
    setState(() => _all = all);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    if (_all == null) return;
    setState(() => _results = KanjiIndex.search(_all!, q));
  }

  bool get _searching => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('漢字', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_rounded),
            tooltip: '한자 퀴즈',
            onPressed: () => context.push('/kanji-quiz'),
          ),
        ],
      ),
      body: AppBackground(
        scatterSeed: 23,
        child: _all == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                    child: _searchField(),
                  ),
                  Expanded(child: _searching ? _resultList() : _browseList()),
                ],
              ),
      ),
    );
  }

  Widget _searchField() {
    return MangaPanel(
      rotation: 0,
      backgroundColor: AppColors.cardFront,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppColors.inkSoft),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onQuery,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
              decoration: const InputDecoration(
                hintText: '한자 · 뜻 · 읽기 · 단어 검색',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.inkLight, fontWeight: FontWeight.w600),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (_searching)
            PressableScale(
              onTap: () {
                _controller.clear();
                _onQuery('');
              },
              child: const Icon(Icons.close_rounded, size: 18, color: AppColors.inkSoft),
            ),
        ],
      ),
    );
  }

  // ── 검색 결과 리스트 ──────────────────────────────────────────

  Widget _resultList() {
    if (_results.isEmpty) {
      return const Center(
        child: Text(
          '一致なし — 검색 결과가 없어요',
          style: TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      itemCount: _results.length,
      itemBuilder: (c, i) => _resultRow(_results[i], i),
    );
  }

  Widget _resultRow(KanjiEntry e, int i) {
    final tilts = [-0.3, 0.25, -0.15, 0.35];
    // 부제: 읽기 있으면 읽기, 없으면 대표 단어
    final sub = e.readings.isNotEmpty
        ? e.readings.map((r) => r.reading).take(4).join(' · ')
        : e.words.map((w) => w.word).take(3).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: () => KanjiDetailSheet.show(context, e.toCard()),
        child: MangaPanel(
          rotation: tilts[i % tilts.length],
          backgroundColor: e.hasDetail ? AppColors.sakuraSoft : AppColors.cardFront,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(
                e.char,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.ink, height: 1.1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e.meanings.isNotEmpty)
                      Text(
                        e.meaningJoined,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (sub.isNotEmpty)
                      Text(
                        sub,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _rankChip(e.rank),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rankChip(int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.honey,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.inkOutline, width: 0.8),
      ),
      child: Text(
        '#$rank',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ink),
      ),
    );
  }

  // ── 빈도 구간 브라우저 ────────────────────────────────────────

  Widget _browseList() {
    final total = _all!.length;
    final bandCount = (total / 100).ceil();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      itemCount: bandCount,
      itemBuilder: (c, band) {
        final start = band * 100;
        final end = (start + 100).clamp(0, total);
        final chunk = _all!.sublist(start, end);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SketchyDivider(caption: '빈도 ${start + 1}–$end'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: chunk.map(_kanjiChip).toList(),
            ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }

  Widget _kanjiChip(KanjiEntry e) {
    return PressableScale(
      onTap: () => KanjiDetailSheet.show(context, e.toCard()),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: e.hasDetail ? AppColors.sakuraSoft : AppColors.cardFront,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inkOutline, width: 0.8),
        ),
        child: Center(
          child: Text(
            e.char,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}
