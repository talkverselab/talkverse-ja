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
  final int bestRank; // 가장 빈도 높은 멤버의 회화 순위
  const _Root(
      {required this.root, required this.on, this.ko, required this.members, required this.bestRank});

  /// 절벽구간 (회화 빈도 기준)
  String get region => bestRank <= 294
      ? 'R1'
      : bestRank <= 437
          ? 'R2'
          : bestRank <= 998
              ? 'R3'
              : 'R4';
}

const Map<String, Color> _regionColors = {
  'R1': AppColors.beni,
  'R2': AppColors.beniLight,
  'R3': AppColors.kin,
  'R4': AppColors.matcha,
};

class _PhoneticRootsScreenState extends State<PhoneticRootsScreen> {
  bool _loading = true;
  List<_Root> _roots = [];
  String _query = '';
  String _region = 'ALL';

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
        bestRank: rankOf(members.first),
      ));
    }
    // 절벽구간(빈도) 순 — 내 회화 절벽 기준으로 공부
    roots.sort((a, b) => a.bestRank.compareTo(b.bestRank));
    if (!mounted) return;
    setState(() {
      _roots = roots;
      _loading = false;
    });
  }

  List<_Root> get _filtered {
    final base = _region == 'ALL' ? _roots : _roots.where((r) => r.region == _region).toList();
    final q = _query.trim();
    if (q.isEmpty) return base;
    return base.where((r) {
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
                Container(
                  color: AppColors.washiDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['ALL', 'R1', 'R2', 'R3', 'R4'].map((k) {
                        final selected = _region == k;
                        final c = _regionColors[k] ?? AppColors.sumi;
                        final label = k == 'ALL'
                            ? '전체'
                            : '$k · ${_roots.where((r) => r.region == k).length}';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _region = k),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? c : AppColors.washi,
                                border: Border.all(color: c, width: selected ? 1.5 : 0.8),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: selected ? AppColors.washi : c,
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (_regionColors[root.region] ?? AppColors.sumi)
                                .withValues(alpha: 0.15),
                            border: Border.all(
                                color: _regionColors[root.region] ?? AppColors.sumi),
                          ),
                          child: Text(
                            root.region,
                            style: TextStyle(
                                fontSize: 9,
                                color: _regionColors[root.region] ?? AppColors.sumi,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.kin.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.kin),
                          ),
                          child: Text(
                            '가족 ${root.members.length}자',
                            style: const TextStyle(
                                fontSize: 9, color: AppColors.sumi, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
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

/// 발음부 가족 시트 — 완전공유 / 부분공유 / 비슷한 음차 / 예외 4분류.
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

  /// 훈음 목록 → 한국 한자음 집합 ('어찌 하' → 하)
  static Set<String> _eumsOf(KanjiEntry e) {
    final out = <String>{};
    for (final m in e.meanings) {
      final t = m.trim();
      if (t.isEmpty) continue;
      final last = t.characters.last;
      final code = last.codeUnitAt(0);
      if (code >= 0xAC00 && code <= 0xD7A3) out.add(last);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final rootNorm = _norm(root.on);
    final rootFirst = rootNorm.isEmpty ? '' : rootNorm.substring(0, 1);
    final exact = <KanjiEntry>[];
    final partial = <KanjiEntry>[];
    final similar = <KanjiEntry>[];
    final except = <KanjiEntry>[];

    final rootEntry = KanjiIndexService.instance.lookup(root.root);
    // 기준 한국 한자음: roots 데이터의 ko, 없으면 루트 훈음에서
    var rootKo = root.ko;
    if (rootKo == null && rootEntry != null) {
      final es = _eumsOf(rootEntry);
      if (es.isNotEmpty) rootKo = es.first;
    }

    // 루트 자신은 완전공유 맨 앞에
    if (rootEntry != null) exact.add(rootEntry);

    for (final c in root.members) {
      if (c == root.root) continue;
      final e = KanjiIndexService.instance.lookup(c);
      if (e == null || e.on.isEmpty) continue;
      final ons = e.on.map((r) => r.reading).toList();
      final norms = ons.map(_norm).toList();
      final jaExact = ons.contains(root.on);
      final jaDaku = !jaExact && norms.contains(rootNorm);
      final koSame = rootKo != null && _eumsOf(e).contains(rootKo);
      if (jaExact && koSame) {
        // 완전공유: 일본 음독 + 한국 한자음 모두 같음 (가=가)
        exact.add(e);
      } else if (jaExact || (jaDaku && koSame)) {
        // 부분공유: 음독은 같은데 한자음 다름(하), 또는 탁음만 차이
        partial.add(e);
      } else if (jaDaku ||
          (rootFirst.isNotEmpty && norms.any((n) => n.startsWith(rootFirst)))) {
        similar.add(e);
      } else {
        except.add(e);
      }
    }

    final total = exact.length + partial.length + similar.length + except.length;
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
                      Row(
                        children: [
                          Text('$total자',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.beni, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: _regionColors[root.region] ?? AppColors.sumi),
                            ),
                            child: Text(root.region,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: _regionColors[root.region] ?? AppColors.sumi)),
                          ),
                        ],
                      ),
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
            if (exact.isNotEmpty)
              _groupBox(context, '완전공유', '음독·한국 한자음 모두 같음', const Color(0xFF2E7D32), exact),
            if (partial.isNotEmpty)
              _groupBox(context, '부분공유', '음독은 같지만 한자음 다름 · 탁음 차이', const Color(0xFFB26A00), partial),
            if (similar.isNotEmpty)
              _groupBox(context, '비슷한 음차', '첫소리 같음, 끝·탁음 변형', const Color(0xFF1565C0), similar),
            if (except.isNotEmpty)
              _groupBox(context, '예외', '음이 크게 달라짐', const Color(0xFFC62828), except),
            const SizedBox(height: 10),
            const Text(
              '💡 같은 발음부 = 음독이 비슷한 경향. 단 한자가 진화하며 일부 음이 변형됨.',
              style: TextStyle(fontSize: 11, color: AppColors.sumiLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupBox(
      BuildContext context, String badge, String desc, Color color, List<KanjiEntry> entries) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.04),
          border: Border.all(color: color.withValues(alpha: 0.55)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: color,
                  child: Text(badge,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.washi)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(desc,
                      style: const TextStyle(fontSize: 11, color: AppColors.sumi)),
                ),
                Text('${entries.length}자',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.map((e) => _tile(context, e, color)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, KanjiEntry e, Color color) {
    final on = e.on.map((r) => r.reading).take(2).join('·');
    final hun = e.meanings.isEmpty ? '' : e.meanings.first;
    return InkWell(
      onTap: () => showKanjiSheet(context, char: e.char, entry: e),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.washi,
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(e.char,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1.1)),
                const SizedBox(width: 3),
                InkWell(
                  onTap: () {
                    if (e.on.isNotEmpty) TtsService.instance.speak(e.on.first.reading);
                  },
                  child: const Icon(Icons.volume_up, size: 15, color: AppColors.beni),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(on,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w800)),
            if (hun.isNotEmpty)
              Text(hun,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
          ],
        ),
      ),
    );
  }
}
