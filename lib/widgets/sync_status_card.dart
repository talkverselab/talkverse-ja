import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/db/seed_loader.dart';
import '../services/art_service.dart';
import '../services/content_sync.dart';

/// 프로필의 내려받기 현황(사용자 지시 2026-11-11 "프로필에 db다운로드 진행률 보이고 재시작 버튼도").
/// 종류별 받은 수/전체·%·막대, 마지막으로 받은 시각·콘텐츠 번호·단어표(DB) 번호, 「다시 받기」.
class SyncStatusCard extends StatefulWidget {
  const SyncStatusCard({super.key});
  @override
  State<SyncStatusCard> createState() => _SyncStatusCardState();
}

class _SyncStatusCardState extends State<SyncStatusCard> {
  final _sync = ContentSync.instance;
  int? _db;
  String? _note;

  @override
  void initState() {
    super.initState();
    SeedLoader.bundledVersion().then((v) {
      if (mounted) setState(() => _db = v);
    });
  }

  Future<void> _restart() async {
    setState(() => _note = null);
    final ok = await _sync.restart();
    if (ok) await ArtService.instance.reload();
    if (mounted) setState(() => _note = ok ? null : tr('서버에 닿지 못했어요. 연결을 확인하고 다시 눌러 주세요.'));
  }

  static String _when(DateTime? t) {
    if (t == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<SyncProgress>(
        valueListenable: _sync.progress,
        builder: (context, p, _) {
          final kinds = _sync.kindProgress;
          final done = kinds.values.fold<int>(0, (a, k) => a + k.$1), total = kinds.values.fold<int>(0, (a, k) => a + k.$2);
          final busy = p.running || _sync.restarting;
          final state = switch (p.phase) {
            'manifest' => tr('목록 확인 중…'),
            'offline' => tr('오프라인 — 받은 것만 사용'),
            _ when p.running => tr('내려받는 중…'),
            _ when total > 0 && done >= total => tr('모두 받음'),
            _ => tr('받을 것이 남음'),
          };
          return Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(12), boxShadow: kCardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(tr('내려받기 현황'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi))),
                Text(state, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p.phase == 'offline' ? AppColors.beni : AppColors.sumiLight)),
              ]),
              const SizedBox(height: 10),
              _bar(tr('전체'), done, total, AppColors.sumi, bold: true),
              _bar(tr('단어 그림'), kinds['word']!.$1, kinds['word']!.$2, AppColors.matcha),
              _bar(tr('장면 컷'), kinds['scene']!.$1, kinds['scene']!.$2, AppColors.ai),
              _bar(tr('회화 음성'), kinds['audio']!.$1, kinds['audio']!.$2, AppColors.kinDeep),
              const SizedBox(height: 6),
              Text(
                '${tr('마지막으로 받은 때')} ${_when(_sync.lastAt)} · ${tr('콘텐츠 번호')} ${_sync.seq ?? '—'} · ${tr('단어표(DB)')} ${_db ?? '—'}',
                style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, height: 1.4),
              ),
              if (_note != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_note!, style: const TextStyle(fontSize: 11, color: AppColors.beni, fontWeight: FontWeight.w700))),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Text(tr('다시 받기 = 목록을 새로 받아 처음부터 다시 맞춥니다. 이미 받은 같은 파일은 건너뜁니다.'), style: const TextStyle(fontSize: 10.5, color: AppColors.sumiLight, height: 1.35)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: busy && p.phase == 'manifest' ? null : _restart,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.sumi, foregroundColor: Colors.white, visualDensity: VisualDensity.compact),
                  icon: busy ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.refresh, size: 16),
                  label: Text(tr('다시 받기'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ]),
            ]),
          );
        },
      );

  Widget _bar(String label, int done, int total, Color color, {bool bold = false}) {
    final r = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final pct = total == 0 ? '—' : '${(r * 100).floor()}%';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 64, child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.sumi))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: r, minHeight: bold ? 8 : 6, backgroundColor: AppColors.washiDeep, valueColor: AlwaysStoppedAnimation(color)),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 104,
          child: Text('$done/$total · $pct', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.sumiLight, fontFeatures: const [FontFeature.tabularFigures()])),
        ),
      ]),
    );
  }
}
