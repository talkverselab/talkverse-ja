import '../core/embed_env.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/word_card.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/theme.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

/// 영어등유래단어 — 외래어가 일본어로 음차되는 규칙(영어) + 유래 언어별 줄기.
/// 예외는 [예외] 배지.
class GairaigoScreen extends StatefulWidget {
  /// 배우기 「외국어 발음 규칙」에서 열면 「규칙 한눈에」 표부터.
  final bool rulesFirst;
  const GairaigoScreen({super.key, this.rulesFirst = false});

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
  final int st; // 1=핵심 큐레이션, 2=JLPT 전체
  final int? jlpt;
  const _Word(
    this.ja,
    this.en,
    this.ko,
    this.note,
    this.ex,
    this.st,
    this.jlpt,
  );
}

class _GairaigoScreenState extends State<GairaigoScreen> {
  List<_Branch> _branches = [];
  bool _loading = true;
  late int _tab = widget.rulesFirst ? -1 : 0; // -1 = 규칙 한눈에
  String _intro = '';
  List<List<String>> _table = [];
  int _stage = 1; // 1단계(핵심) 디폴트 · 2단계(JLPT 전체)

  List<_Word> _visible(_Branch b) =>
      b.words.where((w) => w.st <= _stage).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString(
      assetPath('assets/data/vocab/gairaigo.json'),
    );
    final j = json.decode(raw) as Map<String, dynamic>;
    final branches = <_Branch>[];
    for (final b in (j['branches'] as List).cast<Map<String, dynamic>>()) {
      branches.add(
        _Branch(
          b['id'] as String,
          b['title'] as String,
          (b['emoji'] as String?) ?? '',
          b['rule'] as String,
          [
            for (final w in (b['words'] as List).cast<Map<String, dynamic>>())
              _Word(
                w['ja'] as String,
                w['en'] as String,
                w['ko'] as String,
                w['note'] as String?,
                w['ex'] == true,
                (w['st'] as int?) ?? 1,
                w['jlpt'] as int?,
              ),
          ],
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _intro = (j['intro'] as String?) ?? '';
      _table = [
        for (final r in (j['rules_table'] as List? ?? const []))
          (r as List).cast<String>(),
      ];
      _branches = branches;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _branches.fold(0, (s, b) => s + _visible(b).length);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('영어등유래단어'),
              style: TextStyle(
                color: AppColors.sumi,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              trf('外来語 · {0}단계 · {1}줄기 · {2}어', [
                _stage,
                _branches.length,
                total,
              ]),
              style: const TextStyle(
                color: AppColors.sumiLight,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: const [KoReadingToggleAction()],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.beni),
            )
          : Column(
              children: [
                // 단계 선택
                Container(
                  color: AppColors.washiDeep,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [1, 2].map((st) {
                        final selected = _stage == st;
                        final n = _branches.fold(
                          0,
                          (s, b) => s + b.words.where((w) => w.st <= st).length,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _stage = st),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.ai
                                    : AppColors.washi,
                                border: Border.all(
                                  color: AppColors.ai,
                                  width: selected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Text(
                                st == 1
                                    ? trf('1단계 핵심 {0}', [n])
                                    : trf('2단계 JLPT 전체 {0}', [n]),
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.washi
                                      : AppColors.ai,
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
                ),
                // 줄기 선택 칩
                Container(
                  color: AppColors.washiDeep,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _branches.length + 1,
                      itemBuilder: (context, k) {
                        final i = k - 1;
                        if (i < 0) {
                          final selected = _tab == -1;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              key: const ValueKey('gairaigo-rules'),
                              onTap: () => setState(() => _tab = -1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.ai
                                      : AppColors.washi,
                                  border: Border.all(
                                    color: AppColors.ai,
                                    width: selected ? 1.5 : 0.8,
                                  ),
                                ),
                                child: Text(
                                  tr('📏 규칙 한눈에'),
                                  style: TextStyle(
                                    color: selected
                                        ? AppColors.washi
                                        : AppColors.ai,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        final b = _branches[i];
                        final selected = _tab == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _tab = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.beni
                                    : AppColors.washi,
                                border: Border.all(
                                  color: AppColors.beni,
                                  width: selected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Text(
                                '${b.emoji} ${b.title} ${_visible(b).length}',
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.washi
                                      : AppColors.beni,
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
                Expanded(
                  child: _tab < 0 ? _rulesView() : _branchView(_branches[_tab]),
                ),
              ],
            ),
    );
  }

  Widget _branchView(_Branch b) {
    return ListView(
      key: PageStorageKey(b.id),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 80 + bottomInset(context)),
      children: [
        // 규칙 설명 카드
        JapaneseCard(
          title: '${b.emoji} ${b.title}',
          sealText: '規則',
          accent: AppColors.ai,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                b.rule,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.sumi,
                  height: 1.55,
                ),
              ),
              if (_visible(b).isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  trf('예) {0}', [
                    _visible(b)
                        .where((w) => !w.ex && w.en.isNotEmpty)
                        .take(3)
                        .map((w) => '${w.en} → ${w.ja}')
                        .join(' · '),
                  ]),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.ai,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        WordCardGrid(cards: _visible(b).map(_wordCard).toList()),
      ],
    );
  }

  /// 규칙 한눈에 — 안내 + 영어 소리 → 가타카나 대응표(태국어 앱 「영어 유래 단어」 구성 참고).
  Widget _rulesView() => ListView(
    key: const PageStorageKey('rules'),
    padding: EdgeInsets.fromLTRB(16, 12, 16, 80 + bottomInset(context)),
    children: [
      if (_intro.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.washiDeep,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _intro,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.sumi,
              height: 1.5,
            ),
          ),
        ),
      const SizedBox(height: 12),
      for (final r in _table)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.washi,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line),
            boxShadow: kCardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      r[0],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sumi,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '→',
                      style: TextStyle(color: AppColors.sumiLight),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      r[1],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.beni,
                      ),
                    ),
                  ),
                ],
              ),
              if (r.length > 2) ...[
                const SizedBox(height: 4),
                Text(
                  r[2],
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.ai,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
    ],
  );

  WordCard _wordCard(_Word w) => WordCard(
    word: w.ja,
    kana: w.ja,
    gloss: w.en.isEmpty ? w.ko : '${w.en} · ${w.ko}',
    note: w.note ?? (w.ex ? tr('예외') : null),
    badge: w.ex ? tr('예외') : (w.jlpt != null ? 'N${w.jlpt}' : null),
    badgeColor: w.ex ? const Color(0xFFB26A00) : AppColors.matcha,
    borderColor: w.ex ? const Color(0xFFB26A00) : null,
    onSpeak: () => TtsService.instance.speak(w.ja),
  );
}
