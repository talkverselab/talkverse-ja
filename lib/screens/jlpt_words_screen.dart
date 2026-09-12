import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../widgets/furigana_text.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/word_sheet.dart';
import '../core/l10n.dart';

/// JLPT 단어 — 레벨 탭(N5→N1·회화) · 후리가나 루비 · 검색 · 한자 탭 → 한자 시트.
class JlptWordsScreen extends StatefulWidget {
  final int? initialLevel;
  const JlptWordsScreen({super.key, this.initialLevel = 5});

  @override
  State<JlptWordsScreen> createState() => _JlptWordsScreenState();
}

class _JlptWordsScreenState extends State<JlptWordsScreen> {
  static const _levels = <int?>[5, 4, 3, 2, 1, null];

  int? _level;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<WordEntry> _words = [];
  Map<int?, int> _counts = {};
  bool _loading = true;
  bool _loadingMore = false;
  bool _showRuby = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
    _scroll.addListener(_onScroll);
    _init();
  }

  Future<void> _init() async {
    final counts = <int?, int>{};
    for (final lv in _levels) {
      counts[lv] = await WordService.instance.countLevel(lv);
    }
    if (!mounted) return;
    setState(() => _counts = counts);
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final q = _ctrl.text.trim();
    final list = q.isNotEmpty ? await WordService.instance.search(q) : await WordService.instance.byLevel(_level);
    if (!mounted) return;
    setState(() {
      _words = list;
      _loading = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _onScroll() async {
    if (_ctrl.text.trim().isNotEmpty || _loadingMore) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 400) return;
    final total = _counts[_level] ?? 0;
    if (_words.length >= total) return;
    _loadingMore = true;
    final more = await WordService.instance.byLevel(_level, offset: _words.length);
    if (mounted) setState(() => _words = [..._words, ...more]);
    _loadingMore = false;
  }

  void _onQuery(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _reload);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  static Color levelColor(int? level) => switch (level) {
        5 => AppColors.matcha,
        4 => AppColors.ai,
        3 => AppColors.kinDeep,
        2 => AppColors.beniLight,
        1 => AppColors.beniDeep,
        _ => AppColors.sumiLight,
      };

  @override
  Widget build(BuildContext context) {
    final searching = _ctrl.text.trim().isNotEmpty;
    final total = _counts.values.fold<int>(0, (a, b) => a + b);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('JLPT 단어'), style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(trf('{0}어 · 후리가나 · 한자 탭', [total]), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
        actions: [
          const KoReadingToggleAction(),
          IconButton(
            tooltip: tr('후리가나'),
            icon: Text('ふ',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _showRuby ? AppColors.beni : AppColors.sumiLight)),
            onPressed: () => setState(() => _showRuby = !_showRuby),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _ctrl,
              onChanged: _onQuery,
              style: const TextStyle(color: AppColors.sumi, fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                hintText: tr('표기(言葉) · 읽기(ことば) · 뜻(말, language)'),
                hintStyle: const TextStyle(color: AppColors.sumiLight, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.beni),
                suffixIcon: searching
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.sumiLight),
                        onPressed: () {
                          _ctrl.clear();
                          _reload();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.washiDeep,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.kin)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: AppColors.kin.withValues(alpha: 0.6))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: AppColors.beni, width: 1.4)),
              ),
            ),
          ),
          if (!searching)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: _levels.map((lv) {
                  final selected = _level == lv;
                  final color = levelColor(lv);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _level = lv);
                        _reload();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? color : AppColors.washi,
                          border: Border.all(color: color, width: selected ? 1.5 : 0.8),
                        ),
                        child: Text(
                          '${lv == null ? '회화' : 'N$lv'} · ${_counts[lv] ?? '-'}',
                          style: TextStyle(color: selected ? AppColors.washi : color, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const AsanohaDivider(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
                : _words.isEmpty
                    ? Center(child: Text(tr('결과 없음'), style: TextStyle(color: AppColors.sumiLight)))
                    : ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _words.length,
                        separatorBuilder: (_, _) => Container(height: 0.5, color: AppColors.kin.withValues(alpha: 0.3)),
                        itemBuilder: (context, i) => _WordRow(word: _words[i], showRuby: _showRuby),
                      ),
          ),
        ],
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  final WordEntry word;
  final bool showRuby;
  const _WordRow({required this.word, required this.showRuby});

  @override
  Widget build(BuildContext context) {
    final w = word;
    return InkWell(
      onTap: () => showWordSheet(context, w),
      child: Container(
        color: AppColors.washi,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2),
              color: _JlptWordsScreenState.levelColor(w.jlpt),
              child: Text(w.jlpt == null ? '会' : 'N${w.jlpt}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.washi)),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FuriganaText(segs: w.segs, fontSize: 20, showRuby: showRuby),
                  KoReadingText(
                    w.kana,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.sumiLight),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Text(
                w.gloss,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: w.hasKo ? 13 : 11, color: w.hasKo ? AppColors.sumi : AppColors.sumiLight, height: 1.3),
              ),
            ),
            InkWell(
              onTap: () => TtsService.instance.speak(w.kana),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.volume_up, size: 18, color: AppColors.beni),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
