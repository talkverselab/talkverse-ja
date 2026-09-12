import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

/// 한자음 매핑 — 한국 한자음(훈음의 '음') ↔ 일본 음독(音読み).
/// zh 발음부(声旁) 화면 스타일: 카드 그리드 → 탭하면 한자 가족 시트.
/// 받침 규칙: ㄱ→ク/キ · ㄴ→ン · ㄹ→ツ/チ · ㅁ→ン · ㅂ→ウ(장음) · ㅇ→ウ/イ(장음).
class HanjaSoundScreen extends StatefulWidget {
  const HanjaSoundScreen({super.key});

  @override
  State<HanjaSoundScreen> createState() => _HanjaSoundScreenState();
}

class _Group {
  final String eum; // 한국 한자음 (예: '마')
  final List<KanjiEntry> entries; // rank 오름차순 (첫 항목 = 대표 한자)
  _Group(this.eum, this.entries);

  KanjiEntry get rep => entries.first;
  String get repOn => rep.on.isEmpty ? '' : rep.on.map((r) => r.reading).take(2).join('·');
}

class _HanjaSoundScreenState extends State<HanjaSoundScreen> {
  List<_Group> _groups = const [];
  bool _loading = true;
  String _filter = 'ALL';
  String _query = '';

  static Map<String, String> get _filters => {
    'ALL': tr('전체'),
    'NONE': tr('받침 없음'),
    'ㄱ': 'ㄱ → ク/キ',
    'ㄴ': 'ㄴ → ン',
    'ㄹ': 'ㄹ → ツ/チ',
    'ㅁ': 'ㅁ → ン',
    'ㅂ': tr('ㅂ → ウ장음'),
    'ㅇ': tr('ㅇ → ウ/イ장음'),
  };

  static Map<String, String> get _ruleOf => {
    'NONE': tr('받침 없음 → 음독도 1음절인 경우가 많다'),
    'ㄱ': tr('ㄱ 받침 → ク·キ (学 학→ガク · 力 력→リョク)'),
    'ㄴ': tr('ㄴ 받침 → ン (新 신→シン · 安 안→アン)'),
    'ㄹ': tr('ㄹ 받침 → ツ·チ (一 일→イチ · 発 발→ハツ)'),
    'ㅁ': tr('ㅁ 받침 → ン (心 심→シン · 三 삼→サン)'),
    'ㅂ': tr('ㅂ 받침 → ウ장음 (十 십→ジュウ · 業 업→ギョウ)'),
    'ㅇ': tr('ㅇ 받침 → ウ·イ장음 (生 생→セイ · 東 동→トウ)'),
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
      case 17:
        return 'ㅁ';
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
    final groups = byEum.entries
        .map((kv) => _Group(kv.key, kv.value..sort((a, b) => a.rank.compareTo(b.rank))))
        .toList()
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

  List<_Group> get _filtered {
    var list = _filter == 'ALL' ? _groups : _groups.where((g) => _jong(g.eum) == _filter).toList();
    final q = _query.trim();
    if (q.isEmpty) return list;
    final lower = q.toLowerCase();
    return list.where((g) {
      if (g.eum.contains(q)) return true;
      return g.entries.any((e) =>
          e.char == q ||
          e.meanings.any((m) => m.contains(q)) ||
          e.on.any((r) => r.reading.contains(q) || KanjiIndexService.toHiragana(r.reading).contains(lower)));
    }).toList();
  }

  Future<void> _openFamily(_Group g) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.washi,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          child: _FamilySheet(group: g, rule: _ruleOf[_jong(g.eum)]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final kanjiCount = _groups.fold<int>(0, (n, g) => n + g.entries.length);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('한자음 매핑'), style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text(tr('한국 한자음 ↔ 일본 음독'), style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.sumi),
                    decoration: InputDecoration(
                      hintText: tr('馬 · バ · 마'),
                      hintStyle: const TextStyle(color: AppColors.sumiLight, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppColors.beni),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.washiDeep,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.kin),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.beni, width: 1.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      const SealStamp(text: '音', size: 22),
                      const SizedBox(width: 8),
                      Text(
                        trf('한자음 {0}개 · 한자 {1}자 커버', [_groups.length, kanjiCount]),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1),
                      ),
                      const Spacer(),
                      Text(tr('탭 → 한자 가족'), style: TextStyle(fontSize: 10, color: AppColors.sumiLight)),
                    ],
                  ),
                ),
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
                                e.value,
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
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 24 + bottomInset(context)),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.9,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final g = list[i];
                      return _GroupCard(group: g, onTap: () => _openFamily(g));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// 그리드 카드 — 대표 한자 도장 + 음독 + 마(馬) + 가족 N자
class _GroupCard extends StatelessWidget {
  final _Group group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.washi,
        border: Border.all(color: AppColors.kin.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SealStamp(text: group.rep.char, size: 48, color: AppColors.beni),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      group.repOn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.ai,
                      ),
                    ),
                    Text(
                      '${group.eum}(${group.rep.char})',
                      style: const TextStyle(fontSize: 11, color: AppColors.sumiLight),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kin.withValues(alpha: 0.2),
                        border: Border.all(color: AppColors.kin),
                      ),
                      child: Text(
                        trf('가족 {0}자', [group.entries.length]),
                        style: const TextStyle(fontSize: 9, color: AppColors.sumi, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.sumiLight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// 한자 가족 시트 — 같은 한국 한자음을 공유하는 한자들.
/// 한자 탭 → 한자 상세 시트(훈음·음독·훈독·대표단어·후리가나 단어 전부).
class _FamilySheet extends StatelessWidget {
  final _Group group;
  final String? rule;
  const _FamilySheet({required this.group, this.rule});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 24 + bottomInset(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.kin.withValues(alpha: 0.25),
                    border: Border.all(color: AppColors.kin, width: 2),
                  ),
                  child: Text(
                    group.eum,
                    style: const TextStyle(
                        fontSize: 44, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.repOn,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ai),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('한국 한자음 family'),
                        style: TextStyle(
                            fontSize: 11, color: AppColors.sumiLight, letterSpacing: 1.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trf('{0}자', [group.entries.length]),
                        style: const TextStyle(fontSize: 11, color: AppColors.beni, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: AppColors.beni),
                  onPressed: () {
                    final on = group.rep.on;
                    if (on.isNotEmpty) TtsService.instance.speak(on.first.reading);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.sumi),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (rule != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.washiDeep,
                  border: Border.all(color: AppColors.ai.withValues(alpha: 0.4)),
                ),
                child: Text('💡 $rule',
                    style: const TextStyle(fontSize: 11, color: AppColors.sumi, height: 1.4)),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: group.entries.map((e) {
                final on = e.on.map((r) => r.reading).take(2).join('·');
                final hun = e.meanings.isEmpty ? '' : e.meanings.first;
                return InkWell(
                  onTap: () => showKanjiSheet(context, char: e.char, entry: e),
                  onLongPress: () {
                    if (e.on.isNotEmpty) TtsService.instance.speak(e.on.first.reading);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.washi,
                      border: Border.all(color: AppColors.beni.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        Text(e.char,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.beni, height: 1.15)),
                        Text(on,
                            style:
                                const TextStyle(fontSize: 10, color: AppColors.ai, fontWeight: FontWeight.w700)),
                        if (hun.isNotEmpty)
                          Text(hun, style: const TextStyle(fontSize: 9, color: AppColors.sumiLight)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text(
              tr('💡 같은 한국 한자음 = 일본 음독도 비슷한 경향. 한자를 탭하면 훈음·읽기·단어 상세.'),
              style: TextStyle(fontSize: 11, color: AppColors.sumiLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
