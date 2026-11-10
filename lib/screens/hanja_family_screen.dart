import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/hanja_family_service.dart';
import '../services/kanji_index_service.dart';
import '../widgets/family_map.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';

/// 「패밀리 한자」 — 한자유니버스 가족 DB(한자 세션 지시 2026-11-02): 소리 가족(발음부) + 책 가족(교재 소리 쌍) + 헷갈리는 쌍.
/// 목록(가족 뿌리) → 가족 지도(FamilyMap) + 구성원 → 글자 탭 = 한자 팝업(글자 형성·어원·모핑 그림). 아이패드: 왼쪽 목록 · 오른쪽 가족.
class HanjaFamilyScreen extends StatefulWidget {
  const HanjaFamilyScreen({super.key});
  @override
  State<HanjaFamilyScreen> createState() => _HanjaFamilyScreenState();
}

class _HanjaFamilyScreenState extends State<HanjaFamilyScreen> with SingleTickerProviderStateMixin {
  final _svc = HanjaFamilyService.instance;
  late final TabController _tab = TabController(length: 3, vsync: this);
  bool _loading = true;
  bool _jlptOnly = true; // JLPT 한자가 든 가족만(기본)
  HanjaChar? _root;
  BookFamily? _book;
  String _q = '';

  @override
  void initState() {
    super.initState();
    KanjiIndexService.instance.ensureLoaded();
    _svc.ensureLoaded().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  bool _isJlpt(HanjaChar h) => h.jlpt != null || KanjiIndexService.instance.lookup(h.jp)?.jlpt != null;

  List<HanjaChar> get _roots {
    var r = _svc.familyRoots();
    if (_jlptOnly) r = r.where((x) => _isJlpt(x) || _svc.familyOf(x.code).any(_isJlpt)).toList();
    if (_q.isNotEmpty) r = r.where((x) => x.jp.contains(_q) || x.kr.contains(_q) || x.krHun.contains(_q) || x.on.contains(_q)).toList();
    return r;
  }

  void _open(HanjaChar h) => showKanjiSheet(context, char: h.jp, entry: KanjiIndexService.instance.lookup(h.jp));

  @override
  Widget build(BuildContext context) {
    // 칸 너비 900 이상(아이패드 가로)만 좌 목록·우 상세, 그 밖(아이패드 세로 칸·폰)은 목록 → 밀어서 상세
    final wide = isWide(context) && MediaQuery.sizeOf(context).width >= 1200;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(tr('패밀리 한자'), style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text(tr('한자유니버스 공용 가족 DB'), style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 2)),
        ]),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.beni,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.beni,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: [Tab(text: tr('소리 가족')), Tab(text: tr('책 가족')), Tab(text: tr('헷갈리는 쌍'))],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : TabBarView(controller: _tab, children: [
              _soundTab(wide),
              _bookTab(wide),
              _confuseTab(),
            ]),
    );
  }

  // ── 소리 가족 ──────────────────────────────────────
  Widget _soundTab(bool wide) {
    final roots = _roots;
    final list = Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _q = v.trim()),
              decoration: InputDecoration(hintText: tr('글자·훈·음독 찾기'), isDense: true, prefixIcon: const Icon(Icons.search, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line))),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(label: Text(tr('JLPT')), selected: _jlptOnly, onSelected: (v) => setState(() => _jlptOnly = v), selectedColor: AppColors.ai.withValues(alpha: 0.12), labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ]),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(16, 2, 16, 4), child: Align(alignment: Alignment.centerLeft, child: Text(trf('{0}가족 · 소리 부품이 같은 글자끼리', [roots.length]), style: const TextStyle(fontSize: 11, color: AppColors.muted)))),
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(12, 4, 12, 24 + bottomInset(context)),
          itemCount: roots.length,
          itemBuilder: (context, i) {
            final r = roots[i];
            final fam = _svc.familyOf(r.code);
            final on = _root?.code == r.code;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: on ? AppColors.beni.withValues(alpha: 0.07) : AppColors.washi, border: Border.all(color: on ? AppColors.beni : AppColors.line), borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
              child: ListTile(
                onTap: () {
                  if (wide) {
                    setState(() => _root = r);
                  } else {
                    openPane(context, (_) => _FamilyDetailScreen(root: r));
                  }
                },
                leading: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.sumi, borderRadius: BorderRadius.circular(12)),
                  child: Text(r.jp, style: const TextStyle(fontSize: 24, color: Colors.white, height: 1)),
                ),
                title: Text('${r.hun} ${r.krSound}${r.on.isNotEmpty ? ' · ${r.on}' : ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                subtitle: Text(fam.take(10).map((h) => h.jp).join(' ') + (fam.length > 10 ? ' …' : ''), style: const TextStyle(fontSize: 14, color: AppColors.sumiLight)),
                trailing: Text(trf('{0}자', [fam.length]), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ),
            );
          },
        ),
      ),
    ]);
    if (!wide) return list;
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: 340, child: list),
      const VerticalDivider(width: 1, color: AppColors.line),
      Expanded(
        child: _root == null
            ? Center(child: Text(tr('왼쪽에서 가족을 고르세요'), style: const TextStyle(color: AppColors.muted)))
            : _FamilyDetail(root: _root!, key: ValueKey(_root!.code)),
      ),
    ]);
  }

  // ── 책 가족 ──────────────────────────────────────
  Widget _bookTab(bool wide) {
    final fams = _svc.book;
    final list = ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 24 + bottomInset(context)),
      itemCount: fams.length,
      itemBuilder: (context, i) {
        final f = fams[i];
        final chars = [for (final c in f.codes) if (_svc.byCode.containsKey(c)) _svc.byCode[c]!];
        final on = _book == f;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: on ? AppColors.beni.withValues(alpha: 0.07) : AppColors.washi, border: Border.all(color: on ? AppColors.beni : AppColors.line), borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
          child: ListTile(
            onTap: () {
              if (wide) {
                setState(() => _book = f);
              } else {
                openPane(context, (_) => _BookDetailScreen(family: f));
              }
            },
            leading: SealStamp(text: f.sound, size: 40, color: AppColors.beni),
            title: Text(chars.map((h) => h.jp).join('  '), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.sumi)),
            subtitle: Text(chars.map((h) => h.hun).join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            trailing: Text('p.${f.page}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ),
        );
      },
    );
    if (!wide) return list;
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: 340, child: list),
      const VerticalDivider(width: 1, color: AppColors.line),
      Expanded(child: _book == null ? Center(child: Text(tr('왼쪽에서 가족을 고르세요'), style: const TextStyle(color: AppColors.muted))) : _BookDetail(family: _book!, key: ValueKey(_book!.sound + _book!.page.toString()))),
    ]);
  }

  // ── 헷갈리는 쌍 ──────────────────────────────────────
  Widget _confuseTab() {
    final pairs = _svc.confuse;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 24 + bottomInset(context)),
      itemCount: pairs.length,
      itemBuilder: (context, i) {
        final p = pairs[i];
        final a = _svc.byCode[p.aCode], b = _svc.byCode[p.bCode];
        Widget cell(HanjaChar? h, String hun) => Expanded(
              child: InkWell(
                onTap: h == null ? null : () => _open(h),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    Text(h?.jp ?? '?', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(hun, style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                    if (h != null && h.on.isNotEmpty) Text(h.on, style: const TextStyle(fontSize: 10.5, color: AppColors.ai, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            );
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
          child: Row(children: [cell(a, p.aHun), const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.compare_arrows, color: AppColors.muted)), cell(b, p.bHun)]),
        );
      },
    );
  }
}

/// 가족 상세(지도 + 구성원). 아이패드 오른쪽 칸 / 폰 전체 화면.
class _FamilyDetail extends StatefulWidget {
  final HanjaChar root;
  const _FamilyDetail({super.key, required this.root});
  @override
  State<_FamilyDetail> createState() => _FamilyDetailState();
}

class _FamilyDetailState extends State<_FamilyDetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) prefetchFamilyMorphs(context, [widget.root, ...HanjaFamilyService.instance.familyOf(widget.root.code)]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = HanjaFamilyService.instance;
    final members = svc.familyOf(widget.root.code);
    final jlpt = {for (final m in members) if (m.jlpt != null || KanjiIndexService.instance.lookup(m.jp)?.jlpt != null) m.code};
    void open(HanjaChar h) => showKanjiSheet(context, char: h.jp, entry: KanjiIndexService.instance.lookup(h.jp));
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
      children: [
        Text(trf('{0} 가족 — 소리 부품 「{1}」({2})을 품은 글자 {3}자', [widget.root.hun, widget.root.jp, widget.root.krSound, members.length]), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi)),
        const SizedBox(height: 4),
        Text(tr('가운데 씨앗을 누르면 그림이 글자로 바뀌는 모핑, 글자를 누르면 한자 팝업(형성·어원·단어). 선 색 = 한국 한자음이 씨앗과 같은 정도. 테두리 굵은 글자 = JLPT.'), style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4)),
        const SizedBox(height: 12),
        Center(child: FamilyMap(root: widget.root, members: members, onTap: open, highlight: jlpt)),
        const SizedBox(height: 14),
        const BrushDivider(height: 2),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final m in members)
            InkWell(
              onTap: () => open(m),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                decoration: BoxDecoration(color: AppColors.washiDeep, border: Border.all(color: jlpt.contains(m.code) ? AppColors.ai : AppColors.line), borderRadius: BorderRadius.circular(10)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(m.jp, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.1)),
                  Text('${m.hun} ${m.krSound}', style: const TextStyle(fontSize: 10, color: AppColors.sumiLight)),
                  if (m.on.isNotEmpty) Text(m.on, style: const TextStyle(fontSize: 10, color: AppColors.ai, fontWeight: FontWeight.w700)),
                  if (svc.isAppOnly(widget.root.code, m.code)) Text(tr('앱 판정'), style: const TextStyle(fontSize: 8.5, color: AppColors.kinDeep, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
        ]),
      ],
    );
  }
}

/// 가족 화면을 바로 연다(단어 시트·플래시카드의 「가족 지도」).
Future<void> openHanjaFamily(BuildContext context, HanjaChar root) => openFull(context, (_) => _FamilyDetailScreen(root: root));

class _FamilyDetailScreen extends StatelessWidget {
  final HanjaChar root;
  const _FamilyDetailScreen({required this.root});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.washi,
        appBar: AppBar(title: Text('${root.jp} ${root.hun} ${root.krSound}', style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15))),
        body: _FamilyDetail(root: root),
      );
}

class _BookDetail extends StatelessWidget {
  final BookFamily family;
  const _BookDetail({super.key, required this.family});
  @override
  Widget build(BuildContext context) {
    final svc = HanjaFamilyService.instance;
    final chars = [for (final c in family.codes) if (svc.byCode.containsKey(c)) svc.byCode[c]!];
    void open(HanjaChar h) => showKanjiSheet(context, char: h.jp, entry: KanjiIndexService.instance.lookup(h.jp));
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
      children: [
        Row(children: [
          SealStamp(text: family.sound, size: 44, color: AppColors.beni),
          const SizedBox(width: 10),
          Expanded(child: Text(trf('「{0}」 소리 가족 · 교재 p.{1} · {2}자', [family.sound, family.page, chars.length]), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi))),
        ]),
        const SizedBox(height: 12),
        for (final h in chars)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
            child: ListTile(
              onTap: () => open(h),
              leading: Text(h.jp, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.sumi)),
              title: Text('${h.hun} ${h.krSound}${h.on.isNotEmpty ? ' · ${h.on}' : ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi)),
              subtitle: Text(h.jp != h.kr ? trf('정자 {0}', [h.kr]) : tr('한·일 자형 같음'), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              trailing: h.morphFile != null ? const Icon(Icons.play_circle_outline, color: AppColors.beni) : const Icon(Icons.chevron_right, color: AppColors.muted),
            ),
          ),
      ],
    );
  }
}

class _BookDetailScreen extends StatelessWidget {
  final BookFamily family;
  const _BookDetailScreen({required this.family});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.washi,
        appBar: AppBar(title: Text('${family.sound} · p.${family.page}', style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15))),
        body: _BookDetail(family: family),
      );
}
