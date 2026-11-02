import 'dart:async';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/art_service.dart';
import '../services/dialogue_service.dart';
import '../services/tts_service.dart';

/// 「모든 문장 듣기」 재생 패널 — 2026-11-03 (아이패드 두 화면 우선 설계).
///
/// 아이패드: 오른챘 칸에 그대로 들어간다(위 = 그림, 아래 = 문장). 폰: `openFull` 로 전체 화면.
/// - 턴을 순서대로 TTS 재생(화자 성별로 목소리 구분), 현재 턴 강조, 일시정지·이전·다음·배속(플루언트 B8).
/// - 자막 단계 토글: 일본어 / 가나 / 독음 / 한국어(플루언트 B7 "오늘 목표"에 맞춰 줄이기).
/// - 그림: 턴에 `art`(장면 그림)가 있으면 그것, 없으면 턴의 핵심 단어 그림(talkverse.uk 단어 그림), 그것도 없으면 장면 카드.
///   장면 그림은 나중에 Grok 이 그려 JSON `art` 에 채운다 — 코드는 바꾸지 않아도 된다.
class EpisodePlayPane extends StatefulWidget {
  final Dialogue dialogue;
  final int initialIndex;
  final bool autoPlay;
  const EpisodePlayPane({super.key, required this.dialogue, this.initialIndex = 0, this.autoPlay = true});

  @override
  State<EpisodePlayPane> createState() => _EpisodePlayPaneState();
}

class _EpisodePlayPaneState extends State<EpisodePlayPane> {
  late int _i = widget.initialIndex;
  bool _playing = false;
  double _rate = 1.0; // 0.75 / 1.0 / 1.25
  bool _showKana = true;
  bool _showRd = true;
  bool _showKo = true;
  int _session = 0; // 재생 루프 세대(중단 판별)
  final _scroll = ScrollController();

  Dialogue get d => widget.dialogue;
  DialogueTurn get turn => d.turns[_i];

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  @override
  void dispose() {
    _session++;
    TtsService.instance.stop();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final my = ++_session;
    setState(() => _playing = true);
    while (mounted && my == _session && _i < d.turns.length) {
      final t = d.turns[_i];
      _scrollTo(_i);
      await TtsService.instance.speakAs(_ttsText(t), gender: _gender(t.speaker), rate: _rate * 0.45);
      if (!mounted || my != _session) return;
      // 다음 턴 사이 짧은 숨(사람 대화 리듬)
      await Future.delayed(Duration(milliseconds: (650 / _rate).round()));
      if (!mounted || my != _session) return;
      if (_i >= d.turns.length - 1) break;
      setState(() => _i++);
    }
    if (mounted && my == _session) setState(() => _playing = false);
  }

  void _pause() {
    _session++;
    TtsService.instance.stop();
    setState(() => _playing = false);
  }

  void _jump(int delta) {
    final n = (_i + delta).clamp(0, d.turns.length - 1);
    _session++;
    TtsService.instance.stop();
    setState(() {
      _i = n;
      _playing = false;
    });
    _scrollTo(n);
  }

  void _scrollTo(int i) {
    if (!_scroll.hasClients) return;
    final target = (i * 76.0 - 60).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  String _ttsText(DialogueTurn t) {
    // 괄호 지시문·변수는 읽지 않는다. {name} 류는 「あなた」 대신 생략.
    var s = t.ja.replaceAll(RegExp(r'[（(][^)）]*[)）]'), '').replaceAll(RegExp(r'\{[a-z_]+\}'), '');
    s = s.replaceAll(RegExp(r'[wｗ]+$'), '').trim();
    return s.isEmpty ? t.kana : s;
  }

  String _gender(String sp) => sp == 'A' ? 'male' : (sp == 'C' ? 'male' : 'female');

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final art = _ArtBox(dialogue: d, turn: turn);
    final list = _TurnList(
      d: d,
      current: _i,
      controller: _scroll,
      showKana: _showKana,
      showRd: _showRd,
      showKo: _showKo,
      onTap: (i) {
        _session++;
        TtsService.instance.stop();
        setState(() {
          _i = i;
          _playing = false;
        });
        _play();
      },
    );
    return Column(children: [
      _Controls(
        playing: _playing,
        rate: _rate,
        showKana: _showKana,
        showRd: _showRd,
        showKo: _showKo,
        onPlay: _playing ? _pause : _play,
        onPrev: _i > 0 ? () => _jump(-1) : null,
        onNext: _i < d.turns.length - 1 ? () => _jump(1) : null,
        onRate: () => setState(() => _rate = _rate >= 1.25 ? 0.75 : (_rate + 0.25)),
        onKana: () => setState(() => _showKana = !_showKana),
        onRd: () => setState(() => _showRd = !_showRd),
        onKo: () => setState(() => _showKo = !_showKo),
        position: '${_i + 1} / ${d.turns.length}',
      ),
      Expanded(
        child: wide
            ? Row(children: [
                Expanded(flex: 5, child: Padding(padding: const EdgeInsets.all(12), child: art)),
                Expanded(flex: 6, child: list),
              ])
            : Column(children: [
                SizedBox(height: 220, child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: art)),
                Expanded(child: list),
              ]),
      ),
    ]);
  }
}

class _Controls extends StatelessWidget {
  final bool playing, showKana, showRd, showKo;
  final double rate;
  final VoidCallback onPlay, onRate, onKana, onRd, onKo;
  final VoidCallback? onPrev, onNext;
  final String position;
  const _Controls({
    required this.playing,
    required this.rate,
    required this.showKana,
    required this.showRd,
    required this.showKo,
    required this.onPlay,
    required this.onPrev,
    required this.onNext,
    required this.onRate,
    required this.onKana,
    required this.onRd,
    required this.onKo,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String t, bool on, VoidCallback tap) => Padding(
          padding: const EdgeInsets.only(left: 6),
          child: InkWell(
            onTap: tap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: on ? AppColors.ai.withValues(alpha: 0.12) : Colors.transparent,
                border: Border.all(color: on ? AppColors.ai : AppColors.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: on ? AppColors.ai : AppColors.muted)),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(color: AppColors.washi, border: Border(bottom: BorderSide(color: AppColors.line))),
      child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
        IconButton(onPressed: onPrev, icon: const Icon(Icons.skip_previous_rounded), color: AppColors.sumi),
        FilledButton.icon(
          onPressed: onPlay,
          style: FilledButton.styleFrom(backgroundColor: AppColors.beni, foregroundColor: Colors.white, shape: const StadiumBorder()),
          icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
          label: Text(playing ? tr('일시정지') : tr('모든 문장 듣기')),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.skip_next_rounded), color: AppColors.sumi),
        const SizedBox(width: 4),
        Text(position, style: const TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 1)),
        const SizedBox(width: 12),
        chip('×${rate.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}', true, onRate),
        chip('かな', showKana, onKana),
        chip('독음', showRd, onRd),
        chip('한국어', showKo, onKo),
      ])),
    );
  }
}

class _TurnList extends StatelessWidget {
  final Dialogue d;
  final int current;
  final ScrollController controller;
  final bool showKana, showRd, showKo;
  final void Function(int) onTap;
  const _TurnList({
    required this.d,
    required this.current,
    required this.controller,
    required this.showKana,
    required this.showRd,
    required this.showKo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context)),
      itemCount: d.turns.length,
      itemBuilder: (context, i) {
        final t = d.turns[i];
        final me = t.speaker == 'A';
        final on = i == current;
        final name = d.speakerName(t.speaker);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    decoration: BoxDecoration(
                      color: on ? (me ? AppColors.beni.withValues(alpha: 0.12) : AppColors.ai.withValues(alpha: 0.10)) : AppColors.washi,
                      border: Border.all(color: on ? (me ? AppColors.beni : AppColors.ai) : AppColors.line, width: on ? 1.6 : 1),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(me ? 16 : 4),
                        bottomRight: Radius.circular(me ? 4 : 16),
                      ),
                      boxShadow: on ? kCardShadow : null,
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text('${t.num} · ${name.replaceAll(RegExp(r'[{}]'), '')}${t.at != null ? ' · ${t.at}' : ''}',
                          style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text(t.ja, style: TextStyle(fontSize: on ? 19 : 16, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.35)),
                      if (showKana && t.kana.isNotEmpty && t.kana != t.ja)
                        Text(t.kana, style: const TextStyle(fontSize: 12, color: AppColors.ai, fontWeight: FontWeight.w700)),
                      if (showRd && t.rd.isNotEmpty) Text(t.rd, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      if (showKo) ...[
                        const SizedBox(height: 3),
                        Text(t.ko, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight, height: 1.35)),
                      ],
                      if (on && t.note.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('💡 ${t.note}', style: const TextStyle(fontSize: 11, color: AppColors.beniDeep, height: 1.35)),
                      ],
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 그림 칸: 장면 그림 → 단어 그림 → 장면 카드. 만화 한 컷처럼 둥근 틀 안에 그린다.
class _ArtBox extends StatelessWidget {
  final Dialogue dialogue;
  final DialogueTurn turn;
  const _ArtBox({required this.dialogue, required this.turn});

  Future<_ArtPick?> _pick() async {
    if (turn.art != null) return _ArtPick(turn.art!, null);
    for (final w in turn.pictureWords) {
      final u = await ArtService.instance.urlFor(w);
      if (u != null) return _ArtPick(u, w);
    }
    if (dialogue.art != null) return _ArtPick(dialogue.art!, null);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ArtPick?>(
      key: ValueKey('${dialogue.id}:${turn.num}'),
      future: _pick(),
      builder: (context, snap) {
        final p = snap.data;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.washiDeep,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(18),
            boxShadow: kCardShadow,
          ),
          child: p == null
              ? _SceneCard(dialogue: dialogue, turn: turn)
              : Stack(fit: StackFit.expand, children: [
                  Image.network(p.url, fit: BoxFit.contain, errorBuilder: (_, _, _) => _SceneCard(dialogue: dialogue, turn: turn)),
                  if (p.word != null)
                    Positioned(
                      left: 10,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.washi.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                        child: Text(p.word!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                      ),
                    ),
                ]),
        );
      },
    );
  }
}

class _ArtPick {
  final String url;
  final String? word;
  const _ArtPick(this.url, this.word);
}

/// 그림이 없을 때의 장면 카드(이모지 + 장면 한 줄 + 화자).
class _SceneCard extends StatelessWidget {
  final Dialogue dialogue;
  final DialogueTurn turn;
  const _SceneCard({required this.dialogue, required this.turn});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFF7F0), Color(0xFFF3F0FF)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(turn.stamp ?? dialogue.emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 10),
        Text(dialogue.scene, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.sumiLight, height: 1.4)),
        const SizedBox(height: 6),
        Text(dialogue.speakerName(turn.speaker), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.beni)),
      ]),
    );
  }
}
