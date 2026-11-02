import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/pane.dart';
import '../core/theme.dart';
import '../services/dialogue_service.dart';
import '../services/tts_service.dart';
import '../widgets/episode_play_pane.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';
import 'custom_script_screen.dart';
import 'dialogue_card_screen.dart';

/// 새 회화(R0~R4) 섬 목록 → 편 목록 → 편 화면 — 2026-11-03, 아이패드 두 화면 우선.
/// 아이패드: 왼쭉 목록(섬·편) → 오른쪽 칸에 편 화면(버블) → 「모든 문장 듣기」를 누르면 오른쪽 칸이 재생 패널로 바뀐다.
/// 폰: 각 단계가 push, 재생 패널은 전체 화면.
class DialogueHomeScreen extends StatefulWidget {
  const DialogueHomeScreen({super.key});
  @override
  State<DialogueHomeScreen> createState() => _DialogueHomeScreenState();
}

class _DialogueHomeScreenState extends State<DialogueHomeScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    DialogueService.instance.ensureLoaded().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = DialogueService.instance;
    final level = svc.level; // R0 왕초보 / R1 초보
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Text(tr('회화'), style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 16)),
        actions: [
          // 「너무 힘들면 왕초보 모드」 — 기본은 초보(R1)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact, textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              segments: [
                ButtonSegment(value: 'R0', label: Text(tr('왕초보'))),
                ButtonSegment(value: 'R1', label: Text(tr('초보'))),
              ],
              selected: {level == 'R0' ? 'R0' : 'R1'},
              onSelectionChanged: (s) async {
                await svc.setLevel(s.first);
                if (mounted) setState(() {});
              },
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context)),
              children: [
                const CustomScriptEntryCard(),
                const SizedBox(height: 10),
                _hint(level),
                const SizedBox(height: 8),
                for (final lv in ['R0', 'R1', 'R2', 'R3', 'R4'])
                  if (svc.count(lv) > 0 && (lv != 'R0' && lv != 'R1' || lv == level)) ...[
                    _LevelHeader(lv: lv, count: svc.count(lv)),
                    for (final isl in svc.islandsOf(lv))
                      _IslandRow(
                        lv: lv,
                        island: isl,
                        count: svc.list(region: lv, island: isl).length,
                        onTap: () => openPane(context, (_) => DialogueListScreen(region: lv, island: isl)),
                      ),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
    );
  }

  Widget _hint(String level) => Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
        child: Text(
          level == 'R0'
              ? tr('왕초보 모드: 짧은 문장(2~5단어)으로 같은 장면을 배웁니다. 익숙해지면 초보로 돌아오세요.')
              : tr('초보가 기본입니다. 너무 힘들면 위의 「왕초보」로 바꾸세요 — 같은 이야기를 짧은 문장으로 봅니다.'),
          style: const TextStyle(fontSize: 12, color: AppColors.sumiLight, height: 1.4),
        ),
      );
}

class _LevelHeader extends StatelessWidget {
  final String lv;
  final int count;
  const _LevelHeader({required this.lv, required this.count});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
        child: Row(children: [
          GradText(lv, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Text(tr(DialogueService.levelKo[lv] ?? lv), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi)),
          const SizedBox(width: 8),
          Text(trf('{0}편', [count]), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ]),
      );
}

class _IslandRow extends StatelessWidget {
  final String lv;
  final String island;
  final int count;
  final VoidCallback onTap;
  const _IslandRow({required this.lv, required this.island, required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: onTap,
            leading: Text(DialogueService.islandEmoji[island] ?? '💬', style: const TextStyle(fontSize: 26)),
            title: Text(tr(DialogueService.islandKo[island] ?? island), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.sumi)),
            subtitle: Text(trf('{0}편', [count]), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
          ),
        ),
      );
}

/// 섬의 편 목록.
class DialogueListScreen extends StatelessWidget {
  final String region;
  final String island;
  const DialogueListScreen({super.key, required this.region, required this.island});

  @override
  Widget build(BuildContext context) {
    final list = DialogueService.instance.list(region: region, island: island);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Text('${DialogueService.islandEmoji[island] ?? ''} ${tr(DialogueService.islandKo[island] ?? island)} · $region',
            style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context)),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = list[i];
          return Container(
            decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(14), boxShadow: kCardShadow),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                onTap: () => openPane(context, (_) => DialogueScreen(dialogue: d)),
                leading: Text(d.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(d.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                subtitle: Text('${d.isChat ? '💬 ' : ''}${d.scene}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.3)),
                trailing: Text(trf('{0}턴', [d.turns.length]), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 편 화면: 맨 위 「▶ 모든 문장 듣기」, 그 아래 버블. 아이패드는 오른쪽 칸이 재생 패널로 바뀌고, 폰은 전체 화면.
class DialogueScreen extends StatefulWidget {
  final Dialogue dialogue;
  const DialogueScreen({super.key, required this.dialogue});
  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  bool _playing = false;

  Dialogue get d => widget.dialogue;

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  void _openPlay({int at = 0}) {
    if (isWide(context)) {
      setState(() => _playing = true);
    } else {
      openFull(context, (_) => _PlayFull(dialogue: d, at: at));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${d.emoji} ${d.title}', style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          Text('${d.region} · ${tr(DialogueService.islandKo[d.island] ?? d.island)} · ${d.turns.length}${tr('턴')}',
              style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1)),
        ]),
        actions: [
          IconButton(
            tooltip: tr('그림 카드(글자 없이)'),
            icon: const Icon(Icons.style_outlined, color: AppColors.ai),
            onPressed: () => openFull(context, (_) => DialogueCardScreen(dialogue: d)),
          ),
          if (wide && _playing)
            IconButton(
              tooltip: tr('대화로 돌아가기'),
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.sumi),
              onPressed: () {
                TtsService.instance.stop();
                setState(() => _playing = false);
              },
            ),
        ],
      ),
      body: wide && _playing
          ? EpisodePlayPane(key: ValueKey(d.id), dialogue: d)
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openPlay(),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.beni, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: const StadiumBorder()),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(tr('모든 문장 듣기'), style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Text(d.scene, style: const TextStyle(fontSize: 12, color: AppColors.sumiLight, height: 1.4)),
              ),
              const BrushDivider(height: 2),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context)),
                  itemCount: d.turns.length,
                  itemBuilder: (context, i) => _Bubble(d: d, t: d.turns[i], onPlayFrom: () => _openPlay(at: i)),
                ),
              ),
            ]),
    );
  }
}

class _PlayFull extends StatelessWidget {
  final Dialogue dialogue;
  final int at;
  const _PlayFull({required this.dialogue, required this.at});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.washi,
        appBar: AppBar(title: Text('${dialogue.emoji} ${dialogue.title}', style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 15))),
        body: EpisodePlayPane(dialogue: dialogue, initialIndex: at),
      );
}

class _Bubble extends StatelessWidget {
  final Dialogue d;
  final DialogueTurn t;
  final VoidCallback onPlayFrom;
  const _Bubble({required this.d, required this.t, required this.onPlayFrom});

  @override
  Widget build(BuildContext context) {
    final me = t.speaker == 'A';
    final name = d.speakerName(t.speaker);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!me) _avatar(name),
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: me ? AppColors.beni.withValues(alpha: 0.08) : AppColors.washi,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(me ? 16 : 4),
                  bottomRight: Radius.circular(me ? 4 : 16),
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('$name${t.at != null ? ' · ${t.at}' : ''}', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => TtsService.instance.speakAs(t.ja.replaceAll(RegExp(r'[（(][^)）]*[)）]'), '').replaceAll(RegExp(r'\{[a-z_]+\}'), ''), gender: me ? 'male' : 'female'),
                    child: const Icon(Icons.volume_up, size: 16, color: AppColors.beni),
                  ),
                  const SizedBox(width: 4),
                  InkWell(onTap: onPlayFrom, child: const Icon(Icons.play_circle_outline, size: 16, color: AppColors.ai)),
                ]),
                const SizedBox(height: 4),
                // 한자를 누르면 한자 팝업(글자 형성·그림) — 사용자가 좋아한 그 창 그대로
                SelectableJaText(text: t.ja, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.4)),
                if (t.kana.isNotEmpty && t.kana != t.ja) Text(t.kana, style: const TextStyle(fontSize: 12, color: AppColors.ai, fontWeight: FontWeight.w700)),
                if (t.rd.isNotEmpty) Text(t.rd, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 3),
                Text(t.ko, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight, height: 1.35)),
                if (t.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('💡 ${t.note}', style: const TextStyle(fontSize: 11, color: AppColors.beniDeep, height: 1.35)),
                ],
                if (t.stamp != null) Text(t.stamp!, style: const TextStyle(fontSize: 28)),
              ]),
            ),
          ),
          if (me) _avatar(name),
        ],
      ),
    );
  }

  Widget _avatar(String name) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.washiDeep,
          child: Text(name.isEmpty ? '?' : name.characters.first, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.sumi)),
        ),
      );
}
