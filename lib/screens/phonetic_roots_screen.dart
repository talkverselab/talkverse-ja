import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/theme.dart';
import '../services/kanji_index_service.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';

/// 발음부(音符) 탐색 — IDS 분해 + 음독 일치 자동판정 (JLPT 한자 기반).
/// 카드를 탭하면 그 발음부를 공유하는 한자 가족 시트가 열린다. zh 声旁 화면 포팅.
class PhoneticRootsScreen extends StatefulWidget {
  const PhoneticRootsScreen({super.key});

  @override
  State<PhoneticRootsScreen> createState() => _PhoneticRootsScreenState();
}

class _Root {
  final String root;
  final String on; // 대표 음독
  final String? ko; // 한국 한자음
  final List<String> members; // 빈도순
  const _Root({required this.root, required this.on, this.ko, required this.members});
}

class _PhoneticRootsScreenState extends State<PhoneticRootsScreen> {
  bool _loading = true;
  List<_Root> _roots = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await KanjiIndexService.instance.ensureLoaded();
    final raw = await rootBundle.loadString('assets/data/kanji/phonetic_ja.json');
    final j = json.decode(raw) as Map<String, dynamic>;
    final rootsJson = (j['roots'] as Map).cast<String, dynamic>();
    final charsJson = (j['chars'] as Map).cast<String, dynamic>();

    final byRoot = <String, List<String>>{};
    for (final e in charsJson.entries) {
      final r = (e.value as Map)['phonetic'] as String;
      byRoot.putIfAbsent(r, () => []).add(e.key);
    }
    int rankOf(String c) => KanjiIndexService.instance.lookup(c)?.rank ?? 9999;
    final roots = <_Root>[];
    for (final e in rootsJson.entries) {
      final members = byRoot[e.key] ?? const <String>[];
      if (members.isEmpty) continue;
      members.sort((a, b) => rankOf(a).compareTo(rankOf(b)));
      final m = e.value as Map;
      roots.add(_Root(
        root: e.key,
        on: (m['on'] as String?) ?? '',
        ko: m['ko'] as String?,
        members: members,
      ));
    }
    roots.sort((a, b) => b.members.length.compareTo(a.members.length));
    if (!mounted) return;
    setState(() {
      _roots = roots;
      _loading = false;
    });
  }

  List<_Root> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return _roots;
    return _roots.where((r) {
      if (r.root == q || r.on.contains(q)) return true;
      if (r.ko != null && r.ko!.contains(q)) return true;
      if (KanjiIndexService.toHiragana(r.on).contains(q)) return true;
      return r.members.contains(q);
    }).toList();
  }

  Future<void> _openFamily(_Root r) async {
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
          child: _FamilySheet(root: r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _roots.fold(0, (s, r) => s + r.members.length);
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('발음부 + 한국 한자음',
                style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('音符 · JLPT 한자',
                style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
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
                      hintText: '寺 · ジ · 사',
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
                      const SealStamp(text: '音符', size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '발음부 ${_roots.length}개 · 한자 $total자 커버',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1),
                      ),
                      const Spacer(),
                      const Text('탭 → 한자 가족', style: TextStyle(fontSize: 10, color: AppColors.sumiLight)),
                    ],
                  ),
                ),
                const AsanohaDivider(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.9,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final r = list[i];
                      return _RootCard(root: r, onTap: () => _openFamily(r));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _RootCard extends StatelessWidget {
  final _Root root;
  final VoidCallback onTap;
  const _RootCard({required this.root, required this.onTap});

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
              SealStamp(text: root.root, size: 48, color: AppColors.beni),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      root.on,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ai),
                    ),
                    if (root.ko != null)
                      Text(
                        '${root.ko}(${root.root})',
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
                        '가족 ${root.members.length}자',
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

/// 발음부 가족 시트 — 완전 일치 / 탁음 변형 / 음 변화 그룹.
class _FamilySheet extends StatelessWidget {
  final _Root root;
  const _FamilySheet({required this.root});

  static const _daku = {
    'ガ': 'カ', 'ギ': 'キ', 'グ': 'ク', 'ゲ': 'ケ', 'ゴ': 'コ',
    'ザ': 'サ', 'ジ': 'シ', 'ズ': 'ス', 'ゼ': 'セ', 'ゾ': 'ソ',
    'ダ': 'タ', 'ヂ': 'チ', 'ヅ': 'ツ', 'デ': 'テ', 'ド': 'ト',
    'バ': 'ハ', 'ビ': 'ヒ', 'ブ': 'フ', 'ベ': 'ヘ', 'ボ': 'ホ',
    'パ': 'ハ', 'ピ': 'ヒ', 'プ': 'フ', 'ペ': 'ヘ', 'ポ': 'ホ',
  };

  static String _norm(String r) =>
      r.split('-').first.split('').map((c) => _daku[c] ?? c).join();

  @override
  Widget build(BuildContext context) {
    final rootNorm = _norm(root.on);
    final exact = <KanjiEntry>[];
    final variant = <KanjiEntry>[];
    final shifted = <KanjiEntry>[];
    final unknown = <String>[];
    for (final c in root.members) {
      final e = KanjiIndexService.instance.lookup(c);
      if (e == null || e.on.isEmpty) {
        unknown.add(c);
        continue;
      }
      final ons = e.on.map((r) => r.reading).toList();
      if (ons.contains(root.on)) {
        exact.add(e);
      } else if (ons.map(_norm).contains(rootNorm)) {
        variant.add(e);
      } else {
        shifted.add(e);
      }
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
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
                    root.root,
                    style: const TextStyle(
                        fontSize: 44, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(root.on,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ai)),
                      const SizedBox(height: 4),
                      Text(
                        root.ko != null ? '발음부 (音符) · ${root.ko}(${root.root})' : '발음부 (音符) family',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.sumiLight, letterSpacing: 1.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text('${root.members.length}자',
                          style: const TextStyle(fontSize: 11, color: AppColors.beni, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: AppColors.beni),
                  onPressed: () => TtsService.instance.speak(root.on),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.sumi),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (exact.isNotEmpty) _group(context, '완전 공유 — ${root.on} 그대로', AppColors.matcha, exact),
            if (variant.isNotEmpty) _group(context, '탁음 변형 — 첫소리만 흐려짐', AppColors.ai, variant),
            if (shifted.isNotEmpty) _group(context, '음 변화 — 진화하며 달라짐', AppColors.beni, shifted),
            const SizedBox(height: 10),
            const Text(
              '💡 같은 발음부 = 음독이 비슷한 경향. 한자를 탭하면 훈음·읽기·단어 상세.',
              style: TextStyle(fontSize: 11, color: AppColors.sumiLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _group(BuildContext context, String title, Color color, List<KanjiEntry> entries) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entries.map((e) {
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
                    border: Border.all(color: color.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    children: [
                      Text(e.char,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.beni, height: 1.15)),
                      Text(on, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                      if (hun.isNotEmpty)
                        Text(hun, style: const TextStyle(fontSize: 9, color: AppColors.sumiLight)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
