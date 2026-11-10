import 'dart:async';

import 'package:flutter/material.dart';

import '../core/platform.dart';
import '../services/art_service.dart';
import '../services/content_sync.dart';

import '../core/theme.dart';
import '../services/learner_prefs.dart';
import '../widgets/furigana_toggle.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../widgets/furigana_text.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/word_sheet.dart';
import '../core/l10n.dart';

/// JLPT 단어 — 레벨 탭(N5→N1·회화) · 검색 · 단어 카드 격자(그림·후리가나·읽기·뜻) → 단어 시트.
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    LearnerPrefs.furigana.addListener(_onFuri);
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

  void _onFuri() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    LearnerPrefs.furigana.removeListener(_onFuri);
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
    final showRuby = LearnerPrefs.furigana.value;
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
          const FuriganaToggleAction(),
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
                    ? IconButton(tooltip: tr('닫기'), 
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
                    // 목록이 아니라 카드 격자(사용자 지시 2026-11-10 "목록을 카드로") — 폰 2열, 넓을수록 열이 는다.
                    : GridView.builder(
                        controller: _scroll,
                        padding: EdgeInsets.fromLTRB(12, 6, 12, 24 + bottomInset(context)),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 210, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.78),
                        itemCount: _words.length,
                        itemBuilder: (context, i) => _WordCard(word: _words[i], showRuby: showRuby),
                      ),
          ),
        ],
      ),
    );
  }
}

/// 단어 카드 — 위: 단어 그림(없으면 단어를 크게), 아래: 표기(후리가나)·읽기·뜻. 누르면 단어 시트.
class _WordCard extends StatelessWidget {
  final WordEntry word;
  final bool showRuby;
  const _WordCard({required this.word, required this.showRuby});

  @override
  Widget build(BuildContext context) {
    final w = word;
    final color = _JlptWordsScreenState.levelColor(w.jlpt);
    return FutureBuilder<String?>(
      future: ArtService.instance.urlFor(w.surface),
      builder: (context, snap) {
        final url = snap.data;
        Widget bigWord() => Container(
              color: AppColors.washiDeep,
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(10, 22, 10, 8),
              child: FittedBox(fit: BoxFit.scaleDown, child: FuriganaText(segs: w.segs, fontSize: 34, showRuby: showRuby)),
            );
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showWordSheet(context, w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  child: Stack(fit: StackFit.expand, children: [
                    if (url == null) bigWord() else Image(image: artProvider(url), fit: BoxFit.cover, errorBuilder: (_, _, _) => bigWord()),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                        child: Text(w.jlpt == null ? '会' : 'N${w.jlpt}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: IconButton(
                        tooltip: tr('듣기'),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => TtsService.instance.speak(w.kana),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.washi.withValues(alpha: 0.9), shape: BoxShape.circle),
                          child: const Icon(Icons.volume_up, size: 16, color: AppColors.beni),
                        ),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    if (url != null) FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: FuriganaText(segs: w.segs, fontSize: 19, showRuby: showRuby)),
                    KoReadingText(w.kana, style: const TextStyle(fontSize: 10.5, color: AppColors.sumiLight)),
                    const SizedBox(height: 2),
                    Text(w.gloss, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: w.hasKo ? 13 : 11, fontWeight: FontWeight.w700, color: w.hasKo ? AppColors.sumi : AppColors.sumiLight, height: 1.3)),
                  ]),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
