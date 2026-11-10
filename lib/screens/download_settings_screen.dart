import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/prefs.dart';
import '../core/theme.dart';
import '../data/db/seed_loader.dart';
import '../services/content_sync.dart';

/// 내려받기 설정 — 회화 단계·단어 급·음성을 골라 그 몫만 기기에 받는다(저장됨). 아래에 변경 기록(사용자 지시 2026-11-10).
class DownloadSettingsScreen extends StatefulWidget {
  const DownloadSettingsScreen({super.key});
  @override
  State<DownloadSettingsScreen> createState() => _DownloadSettingsScreenState();
}

class _DownloadSettingsScreenState extends State<DownloadSettingsScreen> {
  final sync = ContentSync.instance;
  late SyncChoice _c = sync.choice;
  List<Map<String, dynamic>> _log = [], _dbLog = [];
  Map<int, String> _notes = {};
  int _dbVersion = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await Prefs.getInstance();
    final log = await sync.log();
    final notes = await SeedLoader.bundledNotes();
    final v = await SeedLoader.bundledVersion();
    if (!mounted) return;
    setState(() {
      _log = log;
      _dbLog = SeedLoader.dbLog(prefs);
      _notes = notes;
      _dbVersion = v;
    });
  }

  bool get _dirty => !(_c.audio == sync.choice.audio && _same(_c.dialogue, sync.choice.dialogue) && _same(_c.words, sync.choice.words));
  static bool _same(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

  Future<void> _save() async {
    setState(() => _saving = true);
    final need = await sync.setChoice(_c);
    if (need) sync.download(); // 뒤에서 받는다 — 진행은 위 막대에
    await _load();
    if (mounted) setState(() => _saving = false);
  }

  static String _mb(int kb) => kb >= 1024 ? '${(kb / 1024).round()}MB' : '${kb}KB';

  Widget _chip(String label, String sub, bool on, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 104,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: on ? AppColors.beni.withValues(alpha: 0.08) : AppColors.washi,
            border: Border.all(color: on ? AppColors.beni : AppColors.line, width: on ? 1.6 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: on ? AppColors.beniDeep : AppColors.sumi))),
              Icon(on ? Icons.check_circle : Icons.circle_outlined, size: 16, color: on ? AppColors.beni : AppColors.muted),
            ]),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
          ]),
        ),
      );

  Widget _title(String t, [String? sub]) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.sumi)),
          if (sub != null) Padding(padding: const EdgeInsets.only(top: 3), child: Text(sub, style: const TextStyle(fontSize: 11.5, color: AppColors.sumiLight, height: 1.4))),
        ]),
      );

  static String _counts(Map? m) {
    if (m == null || m.isEmpty) return '';
    final names = {'word': tr('단어 그림'), 'scene': tr('장면 컷'), 'audio': tr('음성')};
    return [for (final e in m.entries) '${names[e.key] ?? e.key} ${e.value}'].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final st = sync.stats;
    final (n, mb) = sync.estimateFor(_c);
    final lvNames = {'R0': tr('왕초보'), 'R1': tr('초보'), 'R2': 'R2', 'R3': 'R3', 'R4': 'R4'};
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('내려받기 설정'), style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w800, fontSize: 16))),
      body: ListView(padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context)), children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
          child: Text(tr('고른 단계·급의 그림과 음성만 기기에 받아 둡니다. 고르지 않은 것은 기기에서 지우고, 열 때 인터넷으로 바로 보여 줍니다. 선택은 저장됩니다.'),
              style: const TextStyle(fontSize: 12.5, color: AppColors.sumi, height: 1.5)),
        ),
        _title(tr('회화 단계'), tr('장면 그림과 회화 음성')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final lv in SyncChoice.dialogueLevels)
            _chip('$lv ${lvNames[lv] == lv ? '' : lvNames[lv]}'.trim(), _mb((st['D:$lv']?.$2 ?? 0) + (_c.audio ? (st['A:$lv']?.$2 ?? 0) : 0)), _c.dialogue.contains(lv), () {
              final s = {..._c.dialogue};
              s.contains(lv) ? s.remove(lv) : s.add(lv);
              setState(() => _c = _c.copyWith(dialogue: s));
            }),
        ]),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeThumbColor: AppColors.beni,
          title: Text(tr('회화 음성도 받기'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.sumi)),
          subtitle: Text(tr('끄면 음성은 들을 때마다 인터넷으로 재생합니다'), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          value: _c.audio,
          onChanged: (v) => setState(() => _c = _c.copyWith(audio: v)),
        ),
        _title(tr('단어 급'), tr('단어 카드의 그림')),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final lv in SyncChoice.wordLevels)
            _chip(lv == 'etc' ? tr('그 밖') : lv, '${st['W:$lv']?.$1 ?? 0}${tr('장')} · ${_mb(st['W:$lv']?.$2 ?? 0)}', _c.words.contains(lv), () {
              final s = {..._c.words};
              s.contains(lv) ? s.remove(lv) : s.add(lv);
              setState(() => _c = _c.copyWith(words: s));
            }),
        ]),
        const SizedBox(height: 16),
        ValueListenableBuilder<SyncProgress>(
          valueListenable: sync.progress,
          builder: (context, p, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(trf('고른 몫: 파일 {0}개 · 약 {1}MB', [n, mb]), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.sumi)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: p.total == 0 ? 0 : p.ratio, minHeight: 8, backgroundColor: AppColors.washiDeep, color: AppColors.beni),
            ),
            const SizedBox(height: 4),
            Text(
                p.phase == 'offline'
                    ? tr('오프라인 — 목록을 받지 못했습니다')
                    : '${trf('기기에 {0} / {1}', [p.done, p.total])}${p.running ? ' · ${tr('받는 중')}' : ''}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _saving || !_dirty ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: AppColors.beni, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: const StadiumBorder()),
              icon: const Icon(Icons.download_done_rounded, size: 18),
              label: Text(_dirty ? tr('저장하고 받기') : tr('저장됨'), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        _title(tr('변경 기록'), trf('콘텐츠 번호 {0} · DB 번호 {1} · 앱 빌드 {2}', [sync.seq?.toString() ?? '—', _dbVersion, sync.appBuild])),
        if (_log.isEmpty && _dbLog.isEmpty) Text(tr('아직 기록이 없습니다'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        for (final e in _log.take(30))
          _LogRow(
            head: '${'${e['at']}'.substring(0, 16).replaceFirst('T', ' ')} · ${tr('그림·음성')}${e['seq'] != null ? ' #${e['seq']}' : ''} · ${tr('빌드')} ${e['build']}',
            lines: [
              if ((e['add'] as Map?)?.isNotEmpty ?? false) '+ ${_counts(e['add'] as Map?)}',
              if ((e['chg'] as Map?)?.isNotEmpty ?? false) '~ ${_counts(e['chg'] as Map?)}',
              if ((e['del'] as Map?)?.isNotEmpty ?? false) '− ${_counts(e['del'] as Map?)}',
            ],
            tag: switch (e['reason']) { 'first' => tr('첫 설치'), 'choice' => tr('선택 변경'), 'restart' => tr('다시 받기'), _ => tr('서버 변경') },
          ),
        for (final e in _dbLog.take(20))
          _LogRow(
            head: '${'${e['at']}'.substring(0, 16).replaceFirst('T', ' ')} · DB ${e['from'] ?? '—'} → ${e['v']} · ${tr('빌드')} ${e['build']}',
            lines: [
              if (_notes[e['v']] != null) _notes[e['v']]!,
              if ((e['changed'] as Map?)?.isNotEmpty ?? false) '~ ${[for (final x in (e['changed'] as Map).entries) '${x.key} ${x.value}'].join(' · ')}',
              if ((e['same'] as List?)?.isNotEmpty ?? false) '= ${(e['same'] as List).join(' · ')} (${tr('그대로')})',
            ],
            tag: tr('단어·회화 DB'),
          ),
      ]),
    );
  }
}

class _LogRow extends StatelessWidget {
  final String head, tag;
  final List<String> lines;
  const _LogRow({required this.head, required this.lines, required this.tag});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(color: AppColors.washi, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(head, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.sumi))),
            Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.beni)),
          ]),
          for (final l in lines) Padding(padding: const EdgeInsets.only(top: 2), child: Text(l, style: const TextStyle(fontSize: 11.5, color: AppColors.sumiLight, height: 1.35, fontFamily: 'monospace'))),
        ]),
      );
}
