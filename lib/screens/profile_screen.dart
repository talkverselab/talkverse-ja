import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../main.dart';
import '../services/memo_service.dart';
import '../widgets/japanese_decor.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _memoCount = 0;
  int _turns = 0;
  int _kanji = 0;
  int _words = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memo = await MemoService.instance.count();
    final turns = await appDb.turns.count().getSingle();
    final kanji = await appDb.kanji.count().getSingle();
    final words = await appDb.words.count().getSingle();
    if (!mounted) return;
    setState(() {
      _memoCount = memo;
      _turns = turns;
      _kanji = kanji;
      _words = words;
    });
  }

  Future<void> _exportMemos() async {
    final all = await MemoService.instance.all();
    if (all.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('메모가 없어요')));
      }
      return;
    }
    final buf = StringBuffer('# 일본어유니버스 메모 export\n\n');
    for (final m in all) {
      buf.writeln('- [${m.patternId} #${m.idx}] ${m.value}');
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모 ${all.length}건 클립보드 복사 완료'), backgroundColor: AppColors.matcha),
      );
    }
  }

  Future<void> _resetProgress() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.washi,
        shape: const RoundedRectangleBorder(),
        title: const Text('학습 기록 초기화'),
        content: const Text('회화 진행·한자 퀴즈·복습 카드 기록을 모두 지웁니다. 메모는 유지돼요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화', style: TextStyle(color: AppColors.beni)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await appDb.delete(appDb.userProgress).go();
    await appDb.delete(appDb.kanjiProgress).go();
    await appDb.delete(appDb.stageResults).go();
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith('card:')).toList()) {
      await prefs.remove(k);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('초기화 완료')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: const Text('프로필 · 설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.beniDeep, AppColors.beni]),
              border: Border.all(color: AppColors.kin, width: 1.5),
            ),
            child: Row(
              children: [
                const SealStamp(text: '学', size: 60, color: AppColors.sumi),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('학습자',
                          style: TextStyle(color: AppColors.washi, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('한국 화자 → 일본어 · 도쿄 표준어',
                          style: TextStyle(color: AppColors.kinBright.withValues(alpha: 0.95), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle('데이터'),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(icon: Icons.chat_bubble_outline, title: '회화 턴', subtitle: '$_turns턴 (L1 ep1 · 민준×사쿠라)'),
            _SettingItem(icon: Icons.translate, title: '한자 사전', subtitle: '$_kanji자 · 회화 가중 빈도'),
            _SettingItem(icon: Icons.format_list_numbered, title: '단어 빈도', subtitle: '$_words어 · R1-R4'),
          ]),
          const SizedBox(height: 16),
          const _SectionTitle('메모 · 기록'),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.sticky_note_2_outlined,
              title: '메모 내보내기',
              subtitle: '$_memoCount건 → 클립보드 (Claude 검수용)',
              onTap: _exportMemos,
            ),
            _SettingItem(
              icon: Icons.restart_alt,
              title: '학습 기록 초기화',
              subtitle: '회화·한자·복습 기록 삭제',
              onTap: _resetProgress,
            ),
          ]),
          const SizedBox(height: 16),
          const _SectionTitle('설정'),
          const SizedBox(height: 8),
          const _SettingsGroup(items: [
            _SettingItem(icon: Icons.volume_up, title: 'TTS 음성', subtitle: '시스템 ja-JP · 남/녀 피치 구분'),
            _SettingItem(icon: Icons.palette, title: '테마', subtitle: '낮 · 和風 紅 #BC002D'),
          ]),
          const SizedBox(height: 16),
          const _SectionTitle('정보'),
          const SizedBox(height: 8),
          const _SettingsGroup(items: [
            _SettingItem(icon: Icons.info_outline, title: '앱 버전', subtitle: '0.1.0 · alpha 和風'),
            _SettingItem(icon: Icons.code, title: 'Stack', subtitle: 'Flutter 3.41 · Material 3 · Drift SQLite'),
            _SettingItem(icon: Icons.copyright, title: '저작권', subtitle: '일본어유니버스 · 2026'),
          ]),
          const SizedBox(height: 20),
          const BrushDivider(),
          const SizedBox(height: 12),
          const Center(child: ToriiIcon(size: 26)),
          const SizedBox(height: 6),
          const Center(
            child: Text('継続は力なり · 계속은 힘이다',
                style: TextStyle(color: AppColors.sumiLight, fontSize: 11, letterSpacing: 3)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.sumi, letterSpacing: 2));
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.washi,
        border: Border.all(color: AppColors.kin.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              onTap: items[i].onTap,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.beni.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.beni, width: 0.8),
                ),
                child: Icon(items[i].icon, color: AppColors.beni, size: 18),
              ),
              title: Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.sumi)),
              subtitle: Text(items[i].subtitle, style: const TextStyle(color: AppColors.sumiLight, fontSize: 11)),
              trailing: items[i].onTap != null
                  ? const Icon(Icons.chevron_right, color: AppColors.beni, size: 18)
                  : null,
            ),
            if (i < items.length - 1) Container(height: 0.5, color: AppColors.kin.withValues(alpha: 0.3)),
          ],
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _SettingItem({required this.icon, required this.title, required this.subtitle, this.onTap});
}
