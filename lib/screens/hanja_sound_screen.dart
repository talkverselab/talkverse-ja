import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';

/// 한자음 매핑 — 한국 한자음(훈음의 '음') ↔ 일본 음독(音読み).
/// 받침 규칙: ㄱ→ク/キ · ㄴ→ン · ㄹ→ツ/チ · ㅁ→ン · ㅂ→ウ(장음) · ㅇ→ウ/イ(장음).
class HanjaSoundScreen extends StatefulWidget {
  const HanjaSoundScreen({super.key});

  @override
  State<HanjaSoundScreen> createState() => _HanjaSoundScreenState();
}

class _Group {
  final String eum; // 한국 한자음 (예: '사')
  final List<KanjiEntry> entries;
  _Group(this.eum, this.entries);
}

class _HanjaSoundScreenState extends State<HanjaSoundScreen> {
  List<_Group> _groups = const [];
  bool _loading = true;
  String _filter = 'ALL';

  static const _filters = {
    'ALL': ('전체', ''),
    'NONE': ('받침 없음', ''),
    'ㄱ': ('ㄱ → ク/キ', 'ク·キ'),
    'ㄴ': ('ㄴ → ン', 'ン'),
    'ㄹ': ('ㄹ → ツ/チ', 'ツ·チ'),
    'ㅁ': ('ㅁ → ン', 'ン'),
    'ㅂ': ('ㅂ → ウ (장음)', 'ウ'),
    'ㅇ': ('ㅇ → ウ/イ (장음)', 'ウ·イ'),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 훈음 문자열 → 한국 한자음 (마지막 음절). '말씀 언' → '언'
  static String? _eumOf(String meaning) {
    final t = meaning.trim();
    if (t.isEmpty) return null;
    final last = t.characters.last;
    final code = last.codeUnitAt(0);
    if (code < 0xAC00 || code > 0xD7A3) return null;
    return last;
  }

  /// 한글 음절의 받침 분류
  static String _jong(String syl) {
    final code = syl.codeUnitAt(0) - 0xAC00;
    final j = code % 28;
    switch (j) {
      case 0:
        return 'NONE';
      case 1:
      case 2:
      case 3:
        return 'ㄱ';
      case 4:
      case 5:
      case 6:
        return 'ㄴ';
      case 8:
      case 9:
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
      case 15:
        return 'ㄹ';
      case 16:
        return 'ㅁ';
      case 17:
      case 18:
      case 19:
        return 'ㅂ';
      case 21:
        return 'ㅇ';
      default:
        return 'ETC';
    }
  }

  Future<void> _load() async {
    await KanjiIndexService.instance.ensureLoaded();
    final byEum = <String, List<KanjiEntry>>{};
    for (final e in KanjiIndexService.instance.all) {
      if (e.on.isEmpty) continue;
      final seen = <String>{};
      for (final m in e.meanings) {
        final eum = _eumOf(m);
        if (eum == null || !seen.add(eum)) continue;
        byEum.putIfAbsent(eum, () => []).add(e);
      }
    }
    final groups = byEum.entries.map((kv) => _Group(kv.key, kv.value..sort((a, b) => a.rank.compareTo(b.rank)))).toList()
      ..sort((a, b) {
        final c = b.entries.length.compareTo(a.entries.length);
        return c != 0 ? c : a.eum.compareTo(b.eum);
      });
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _filter == 'ALL' ? _groups : _groups.where((g) => _jong(g.eum) == _filter).toList();
    final kanjiCount = list.fold<int>(0, (n, g) => n + g.entries.length);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('한자음 매핑', style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('한국 한자음 ↔ 일본 음독', style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Column(
              children: [
                Container(
                  color: AppColors.washiDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _filters.entries.map((e) {
                        final selected = _filter == e.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _filter = e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.ai : AppColors.washi,
                                border: Border.all(color: AppColors.ai, width: selected ? 1.5 : 0.8),
                              ),
                              child: Text(
                                e.value.$1,
                                style: TextStyle(
                                  color: selected ? AppColors.washi : AppColors.ai,
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
                const AsanohaDivider(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                    children: [
                      _ruleCard(list.length, kanjiCount),
                      const SizedBox(height: 12),
                      ...list.map((g) => _GroupCard(group: g)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _ruleCard(int groups, int kanji) {
    return JapaneseCard(
      title: '받침 → 음독 규칙',
      sealText: '音',
      accent: AppColors.ai,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '한국 한자음의 받침이 일본 음독의 끝소리를 거의 결정한다. '
            '초성도 대부분 대응 (ㅅ→サ행, ㅎ→カ행, ㅁ→マ/バ행 …). 규칙을 알면 처음 보는 한자도 음독을 추정할 수 있다.',
            style: TextStyle(fontSize: 12, color: AppColors.sumi, height: 1.5),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _rule('ㄱ', 'ク·キ', '学 학→ガク · 力 력→リョク'),
              _rule('ㄴ', 'ン', '新 신→シン · 安 안→アン'),
              _rule('ㄹ', 'ツ·チ', '一 일→イチ · 発 발→ハツ'),
              _rule('ㅁ', 'ン', '心 심→シン · 三 삼→サン'),
              _rule('ㅂ', 'ウ(장음)', '十 십→ジュウ · 業 업→ギョウ'),
              _rule('ㅇ', 'ウ·イ(장음)', '生 생→セイ · 東 동→トウ'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$groups개 한자음 · $kanji자 (회화 빈도순)',
            style: const TextStyle(fontSize: 11, color: AppColors.sumiLight),
          ),
        ],
      ),
    );
  }

  Widget _rule(String jong, String ja, String ex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.washiDeep,
        border: Border.all(color: AppColors.kin.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$jong → $ja', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.ai)),
          Text(ex, style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final _Group group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.washi,
          border: Border.all(color: AppColors.kin.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppColors.washiDeep,
              child: Row(
                children: [
                  SealStamp(text: group.eum, size: 26, color: AppColors.ai),
                  const SizedBox(width: 8),
                  Text('${group.eum} 음',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                  const Spacer(),
                  Text('${group.entries.length}자', style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: group.entries.map((e) {
                  final on = e.on.map((r) => r.reading).join('·');
                  return InkWell(
                    onTap: () => showKanjiSheet(context, char: e.char, entry: e),
                    onLongPress: () => TtsService.instance.speak(e.on.first.reading),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.washi,
                        border: Border.all(color: AppColors.beni.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        children: [
                          Text(e.char,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.beni, height: 1.1)),
                          Text(on, style: const TextStyle(fontSize: 10, color: AppColors.ai, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
