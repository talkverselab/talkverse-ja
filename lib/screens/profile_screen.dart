import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import 'update_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../main.dart';
import '../services/memo_service.dart';
import '../services/learner_prefs.dart';
import '../widgets/japanese_decor.dart';
import '../core/l10n.dart';


class ProfileScreen extends StatefulWidget {
  final bool embedded; // 「나」 탭 안(앱바·스크롤 없이, 바깥 ListView 에 들어감)
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _memoCount = 0;
  int _turns = 0;
  int _kanji = 0;
  int _words = 0;
  int _jlptWords = 0;

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
    final jlpt = await appDb.jlptWords.count().getSingle();
    if (!mounted) return;
    setState(() {
      _memoCount = memo;
      _turns = turns;
      _kanji = kanji;
      _words = words;
      _jlptWords = jlpt;
    });
  }

  Future<void> _exportMemos() async {
    final all = await MemoService.instance.all();
    if (all.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('메모가 없어요'))));
      }
      return;
    }
    final buf = StringBuffer(tr('# 일본어유니버스 메모 export\n\n'));
    for (final m in all) {
      buf.writeln('- [${m.patternId} #${m.idx}] ${m.value}');
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trf('메모 {0}건 클립보드 복사 완료', [all.length])), backgroundColor: AppColors.matcha),
      );
    }
  }

  Future<void> _resetProgress() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.washi,
        shape: const RoundedRectangleBorder(),
        title: Text(tr('학습 기록 초기화')),
        content: Text(tr('회화 진행·한자 퀴즈·복습 카드 기록을 모두 지웁니다. 메모는 유지돼요.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr('취소'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('초기화'), style: TextStyle(color: AppColors.beni)),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('초기화 완료'))));
    }
  }

  Future<void> _editName() async {
    final c = TextEditingController(text: LearnerPrefs.name.value);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('이름')),
        content: TextField(controller: c, maxLength: 20, autofocus: true, decoration: InputDecoration(hintText: tr('회화 속 「나」로 나와요'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('취소'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(tr('저장'))),
        ],
      ),
    );
    if (v == null) return;
    await LearnerPrefs.setName(v);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
          const UpdateEntryTile(),
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
                      Text(tr('학습자'),
                          style: TextStyle(color: AppColors.washi, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text(tr('한국 화자 → 일본어 · 도쿄 표준어'),
                          style: TextStyle(color: AppColors.kinBright.withValues(alpha: 0.95), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(tr('데이터')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(icon: Icons.chat_bubble_outline, title: tr('회화 턴'), subtitle: trf('{0}턴 (L1 ep1 · 민준×사쿠라)', [_turns])),
            _SettingItem(icon: Icons.translate, title: tr('한자 DB'), subtitle: trf('{0}자 · JLPT N5-N1 + 회화 빈도', [_kanji])),
            _SettingItem(icon: Icons.menu_book, title: tr('JLPT 단어 · 후리가나'), subtitle: trf('{0}어 · 한자↔읽기↔단어 링크', [_jlptWords])),
            _SettingItem(icon: Icons.format_list_numbered, title: tr('단어 빈도'), subtitle: trf('{0}어 · R1-R4', [_words])),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(tr('메모 · 기록')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.sticky_note_2_outlined,
              title: tr('메모 내보내기'),
              subtitle: trf('{0}건 → 클립보드 (Claude 검수용)', [_memoCount]),
              onTap: _exportMemos,
            ),
            _SettingItem(
              icon: Icons.restart_alt,
              title: tr('학습 기록 초기화'),
              subtitle: tr('회화·한자·복습 기록 삭제'),
              onTap: _resetProgress,
            ),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(tr('학습자 프로필')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.badge_outlined,
              title: tr('이름'),
              subtitle: LearnerPrefs.name.value.isNotEmpty ? trf('{0} — 회화 속 「나」로 나와요', [LearnerPrefs.name.value]) : tr('없음 — 회화에서 「〇〇」로 보여요'),
              onTap: _editName,
            ),
            _SettingItem(
              icon: LearnerPrefs.isFemale ? Icons.face_3 : Icons.face,
              title: tr('성별 (화자 「나」의 목소리)'),
              subtitle: LearnerPrefs.isFemale ? tr('여성 — 탭하면 남성') : tr('남성 — 탭하면 여성'),
              onTap: () async {
                await LearnerPrefs.setGender(LearnerPrefs.isFemale ? 'male' : 'female');
                if (mounted) setState(() {});
              },
            ),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(tr('설정')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
                icon: Icons.language,
                title: tr('언어 / Language'),
                subtitle: '${AppLangPrefs.lang.value.label}  →  ${AppLangPrefs.peekNext().label}',
                onTap: AppLangPrefs.next),
            _SettingItem(icon: Icons.volume_up, title: tr('TTS 음성'), subtitle: tr('시스템 ja-JP · 남/녀 피치 구분')),
            _SettingItem(icon: Icons.palette, title: tr('테마'), subtitle: tr('낮 · talkverse.uk 구리 #B77548')),
          ]),
          const SizedBox(height: 16),
          _SectionTitle(tr('정보')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(icon: Icons.info_outline, title: tr('앱 버전'), subtitle: '0.1.0 · alpha'),
            _SettingItem(icon: Icons.code, title: 'Stack', subtitle: 'Flutter 3.41 · Material 3 · Drift SQLite'),
            _SettingItem(icon: Icons.copyright, title: tr('저작권'), subtitle: tr('일본어유니버스 · 2026')),
          ]),
          const SizedBox(height: 20),
          const BrushDivider(),
          const SizedBox(height: 12),
          const Center(child: ToriiIcon(size: 26)),
          const SizedBox(height: 6),
          Center(
            child: Text(tr('継続は力なり · 계속은 힘이다'),
                style: TextStyle(color: AppColors.sumiLight, fontSize: 11, letterSpacing: 3)),
          ),
          const SizedBox(height: 32),
        ];
    if (widget.embedded) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('프로필 · 설정'))),
      body: ListView(padding: const EdgeInsets.all(16), children: children),
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
    // ListTile 은 가장 가까운 Material 에 잉크를 그리므로 색 있는 Container 안에서는 Material 로 감싼다
    return Material(
      color: AppColors.washi,
      shape: Border.all(color: AppColors.kin.withValues(alpha: 0.5)),
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
