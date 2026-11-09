import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../services/morph_cache.dart';

/// 그림 → 글자 모핑 재생기 — 한자앱 `lib/widgets/morph_player.dart` 복제(한자 세션 지시 2026-11-02).
/// 한 번만 재생하고 마지막 장면(글자)에서 멈춘다. 그때 ↻ 다시 재생 버튼. 상태 pending 은 제작용 빌드에서만 표시.
class MorphPlayer extends StatefulWidget {
  final String? morphFile; // 저장소 파일 이름(예 U706B_v1.gif). null = 아직 없음
  final String status; // ok | pending | none
  final String glyph; // 그림이 없을 때 보여 줄 글자
  final String caption; // 아래 한 줄(비면 없음)
  final double size;
  final bool compact;
  const MorphPlayer({super.key, required this.morphFile, required this.status, required this.glyph, this.caption = '', this.size = 300, this.compact = false});

  @override
  State<MorphPlayer> createState() => _MorphPlayerState();
}

class _MorphPlayerState extends State<MorphPlayer> {
  int _run = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (widget.morphFile == null) {
      return Container(
        height: widget.compact ? 80 : 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // 그림이 없는 글자는 글자만 크게(출시 기준 2026-11-09 — 「준비 중」 문구 없음)
          Text(widget.glyph, style: TextStyle(fontSize: widget.compact ? 40 : 60, color: AppColors.sumi, fontWeight: FontWeight.w700)),
        ]),
      );
    }
    final large = MorphCache.wantsLarge(context);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(
        child: Container(
          width: widget.size,
          height: widget.size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white, boxShadow: kCardShadow),
          child: Stack(fit: StackFit.expand, children: [
            FutureBuilder<File?>(
              key: ValueKey('${widget.morphFile}|$large'),
              future: MorphCache.fileFor(widget.morphFile!, large: large),
              builder: (c, snap) {
                if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator(color: AppColors.beni));
                final f = snap.data;
                if (f == null) return Center(child: Text(tr('불러오지 못했어요'), style: const TextStyle(color: AppColors.muted)));
                return _OncePlayer(
                  key: ValueKey('${f.path}#$_run'),
                  file: f,
                  onDone: () {
                    if (mounted) setState(() => _done = true);
                  },
                );
              },
            ),
            if (_done)
              Positioned(
                right: 6,
                bottom: 6,
                child: Material(
                  color: AppColors.washi.withValues(alpha: 0.92),
                  shape: const CircleBorder(side: BorderSide(color: AppColors.kinDeep)),
                  child: IconButton(
                    tooltip: tr('다시 재생'),
                    icon: const Icon(Icons.replay, color: AppColors.beni),
                    onPressed: () => setState(() {
                      _done = false;
                      _run++;
                    }),
                  ),
                ),
              ),
            if (widget.status != 'ok' && !kReleaseMode)
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.washi.withValues(alpha: 0.9), border: Border.all(color: AppColors.muted)),
                  child: Text(tr('리뷰 전'), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                ),
              ),
          ]),
        ),
      ),
      if (!widget.compact && widget.caption.isNotEmpty) ...[
        const SizedBox(height: 6),
        Center(child: Text(widget.caption, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.muted))),
      ],
    ]);
  }
}

/// 움직이는 그림(GIF/WebP)을 한 번만 재생하고 마지막 장면(글자)에서 멈춘다.
class _OncePlayer extends StatefulWidget {
  final File file;
  final VoidCallback onDone;
  const _OncePlayer({super.key, required this.file, required this.onDone});
  @override
  State<_OncePlayer> createState() => _OncePlayerState();
}

class _OncePlayerState extends State<_OncePlayer> {
  ui.Codec? _codec;
  ui.Image? _frame;
  Timer? _timer;
  int _shown = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await widget.file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      if (!mounted) {
        codec.dispose();
        return;
      }
      _codec = codec;
      _next();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _next() async {
    final codec = _codec;
    if (codec == null || !mounted) return;
    final fi = await codec.getNextFrame();
    if (!mounted) {
      fi.image.dispose();
      return;
    }
    _frame?.dispose();
    setState(() => _frame = fi.image);
    _shown++;
    if (_shown >= codec.frameCount) {
      widget.onDone();
      return;
    }
    _timer = Timer(fi.duration < const Duration(milliseconds: 20) ? const Duration(milliseconds: 66) : fi.duration, _next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _frame?.dispose();
    _codec?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return Center(child: Text(tr('불러오지 못했어요'), style: const TextStyle(color: AppColors.muted)));
    if (_frame == null) return const Center(child: CircularProgressIndicator(color: AppColors.beni));
    return RawImage(image: _frame, fit: BoxFit.contain);
  }
}
