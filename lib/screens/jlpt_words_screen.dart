import 'dart:async';

import 'package:flutter/material.dart';

import '../core/platform.dart';
import '../widgets/word_card.dart';

import '../core/theme.dart';
import '../services/learner_prefs.dart';
import '../widgets/furigana_toggle.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/word_sheet.dart';
import '../core/l10n.dart';
import 'word_unit_flash_screen.dart';

/// JLPT 단어 — 레벨 탭(N5→N1·회화) · 검색 · 단어 카드 격자(그림·후리가나·읽기·뜻) → 단어 시트.
class JlptWordsScreen extends StatefulWidget {
  final int? initialLevel;
  const JlptWordsScreen({super.key, this.initialLevel = 5});

  @override
  State<JlptWordsScreen> createState() => _JlptWordsScreenState();
}

class _JlptWordsScreenState extends State<JlptWordsScreen> {
  static const _levels = <int?>[5, 4, 3, 2, 1, null];
  static const _unit = 20;

  List<WordEntry> _slice(int u) => _words.sublist(u * _unit, ((u + 1) * _unit).clamp(0, _words.length));

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
                    // 카드 격자(사용자 지시 2026-11-10) · 급별 화면은 20어 단원 + 단원 플래시카드(2026-11-11), 검색 결과는 한 격자.
                    : CustomScrollView(
                        controller: _scroll,
                        slivers: [
                          if (!searching)
                            const SliverPadding(
                              padding: EdgeInsets.fromLTRB(12, 6, 12, 0),
                              sliver: SliverToBoxAdapter(child: SentenceTip()),
                            ),
                          for (var u = 0; u < (searching ? 1 : (_words.length / _unit).ceil()); u++) ...[
                            if (!searching)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
                                  child: Row(children: [
                                    Text(trf('{0}단원', [u + 1]), style: const TextStyle(color: AppColors.sumi, fontSize: 14, fontWeight: FontWeight.w800)),
                                    const SizedBox(width: 8),
                                    Text('${u * _unit + 1}-${((u + 1) * _unit).clamp(0, _words.length)}', style: const TextStyle(color: AppColors.sumiLight, fontSize: 11)),
                                    const Spacer(),
                                    UnitFlashButton(
                                      title: '${_level == null ? tr('회화') : 'N$_level'} · ${trf('{0}단원', [u + 1])}',
                                      words: () => [for (final w in _slice(u)) StudyWord(word: w.surface, kana: w.kana == w.surface ? '' : w.kana, gloss: w.gloss)],
                                    ),
                                  ]),
                                ),
                              ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                              sliver: SliverToBoxAdapter(
                                child: WordCardGrid(cards: [
                                  for (final w in searching ? _words : _slice(u))
                                    WordCard(
                                      word: w.surface,
                                      segs: w.segs,
                                      kana: w.kana,
                                      gloss: w.gloss,
                                      dimGloss: !w.hasKo,
                                      badge: w.jlpt == null ? '会' : 'N${w.jlpt}',
                                      badgeColor: levelColor(w.jlpt),
                                      showRuby: showRuby,
                                      onTap: () => showWordSheet(context, w),
                                      onSpeak: () => TtsService.instance.speak(w.kana),
                                    ),
                                ]),
                              ),
                            ),
                          ],
                          SliverToBoxAdapter(child: SizedBox(height: 24 + bottomInset(context))),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
