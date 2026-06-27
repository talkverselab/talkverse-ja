import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_stats.dart';
import '../theme.dart';
import '../widgets/manga_panel.dart';
import '../widgets/app_background.dart';
import '../widgets/sketchy_divider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _stats = UserStats();
  int _goal = 10;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final g = await _stats.getGoal();
    if (!mounted) return;
    setState(() => _goal = g);
  }

  Future<void> _resetAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.ink, width: 2.5),
        ),
        title: const Text('学習データ初期化', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('SRS·즐겨찾기·streak 모두 삭제합니다. 되돌릴 수 없어요.',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소', style: TextStyle(color: AppColors.inkSoft))),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final p = await SharedPreferences.getInstance();
    final keys = p.getKeys().where((k) => k.startsWith('wordReviews.') || k.startsWith('favoriteWords') || k.startsWith('userStats.')).toList();
    for (final k in keys) {
      await p.remove(k);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('초기화 완료')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定', style: TextStyle(fontWeight: FontWeight.w700))),
      body: AppBackground(
        scatterSeed: 5,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SketchyDivider(caption: '学習'),
            MangaPanel(
              rotation: -0.5,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('하루 목표', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text('$_goal 장 / 일 (Streak 유지 기준)',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.sakuraDeep,
                      inactiveTrackColor: AppColors.paperDeep,
                      thumbColor: AppColors.ink,
                      overlayColor: AppColors.sakura.withValues(alpha: 0.3),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _goal.toDouble(),
                      min: 5,
                      max: 30,
                      divisions: 5,
                      label: '$_goal',
                      onChanged: (v) async {
                        final g = v.round();
                        await _stats.setGoal(g);
                        setState(() => _goal = g);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SketchyDivider(caption: 'データ'),
            MangaPanel(
              rotation: 0.5,
              backgroundColor: AppColors.honeySoft,
              padding: const EdgeInsets.all(14),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.refresh, color: AppColors.warning),
                title: const Text('学習データ初期化',
                    style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
                subtitle: const Text('SRS·즐겨찾기·streak 모두 삭제',
                    style: TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                onTap: _resetAll,
              ),
            ),
            const SketchyDivider(caption: 'バージョン'),
            MangaPanel(
              rotation: -0.3,
              padding: const EdgeInsets.all(14),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline, color: AppColors.ink),
                title: Text('日本語ユニバース', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                subtitle: Text('v0.2.0 · Flutter 3.41 · git local · H&C edition',
                    style: TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
