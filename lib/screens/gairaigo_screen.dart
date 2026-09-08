import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/theme.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';

/// 영어유래단어 — 영어가 일본어로 음차되는 규칙을 큰 줄기별로 분석.
/// 줄기 9개 × 최다 사용 200어. 예외는 [예외] 배지.
class GairaigoScreen extends StatefulWidget {
  const GairaigoScreen({super.key});

  @override
  State<GairaigoScreen> createState() => _GairaigoScreenState();
}

class _Branch {
  final String id, title, emoji, rule;
  final List<_Word> words;
  const _Branch(this.id, this.title, this.emoji, this.rule, this.words);
}

class _Word {
  final String ja, en, ko;
  final String? note;
  final bool ex;
  const _Word(this.ja, this.en, this.ko, this.note, this.ex);
}

class _GairaigoScreenState extends State<GairaigoScreen> {
  List<_Branch> _branches = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/vocab/gairaigo.json');
    final j = json.decode(raw) as Map<String, dynamic>;
    final branches = <_Branch>[];
    for (final b in (j['branches'] as List).cast<Map<String, dynamic>>()) {
      branches.add(_Branch(
        b['id'] as String,
        b['title'] as String,
        (b['emoji'] as String?) ?? '',
        b['rule'] as String,
        [
          for (final w in (b['words'] as List).cast<Map<String, dynamic>>())
            _Word(w['ja'] as String, w['en'] as String, w['ko'] as String,
                w['note'] as String?, w['ex'] == true),
        ],
      ));
    }
    if (!mounted) return;
    setState(() {
      _branches = branches;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _branches.fold(0, (s, b) => s + b.words.length);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('영어유래단어',
                style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('外来語 · 음차 규칙 ${_branches.length}줄기 · $total어',
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
        actions: const [KoReadingToggleAction()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Column(
              children: [
                // 줄기 선택 칩
                Container(
                  color: AppColors.washiDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _branches.length,
                      itemBuilder: (context, i) {
                        final b = _branches[i];
                        final selected = _tab == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _tab = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.beni : AppColors.washi,
                                border:
                                    Border.all(color: AppColors.beni, width: selected ? 1.5 : 0.8),
                              ),
                              child: Text(
                                '${b.emoji} ${b.title} ${b.words.length}',
                                style: TextStyle(
                                  color: selected ? AppColors.washi : AppColors.beni,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const AsanohaDivider(height: 8),
                Expanded(child: _branchView(_branches[_tab])),
              ],
            ),
    );
  }

  Widget _branchView(_Branch b) {
    return ListView(
      key: PageStorageKey(b.id),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        // 규칙 설명 카드
        JapaneseCard(
          title: '${b.emoji} ${b.title}',
          sealText: '規則',
          accent: AppColors.ai,
          child: Text(
            b.rule,
            style: const TextStyle(fontSize: 12.5, color: AppColors.sumi, height: 1.55),
          ),
        ),
        const SizedBox(height: 12),
        ...b.words.map(_wordRow),
      ],
    );
  }

  Widget _wordRow(_Word w) {
    final borderColor = w.ex ? const Color(0xFFB26A00) : AppColors.kin.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.washi,
          border: Border.all(color: borderColor, width: w.ex ? 1.2 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(w.ja,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.sumi)),
                        ),
                        const SizedBox(width: 8),
                        if (w.ex)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB26A00).withValues(alpha: 0.12),
                              border: Border.all(color: const Color(0xFFB26A00)),
                            ),
                            child: const Text('예외',
                                style: TextStyle(
                                    fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFB26A00))),
                          ),
                      ],
                    ),
                    KoReadingText(w.ja,
                        style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                    const SizedBox(height: 2),
                    Text('${w.en} · ${w.ko}',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.ai, fontWeight: FontWeight.w700)),
                    if (w.note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(w.note!,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.sumiLight, height: 1.4)),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_circle_fill, color: AppColors.beni, size: 32),
                tooltip: '재생',
                onPressed: () => TtsService.instance.speak(w.ja),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
