import '../widgets/sync_status_card.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'download_settings_screen.dart';

import '../core/prefs.dart';

import '../widgets/legal_links.dart';
import '../core/pane.dart';
import '../core/theme.dart';
import '../embed.dart';
import '../services/learner_prefs.dart';
import '../services/account.dart';
import '../services/purchase.dart';
import '../widgets/achievement_desk.dart';
import '../widgets/furigana_toggle.dart';
import 'about_screen.dart';
import 'app_guide_screen.dart';
import 'login_screen.dart';
import 'paywall_screen.dart';
import '../widgets/japanese_decor.dart';
import '../core/l10n.dart';


class ProfileScreen extends StatefulWidget {
  final bool embedded; // 「나」 탭 안(앱바·스크롤 없이, 바깥 ListView 에 들어감)
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _version; // 실제 버전·빌드 번호(예: 0.1.0 · 빌드 88)

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) {
      if (mounted) setState(() => _version = '${i.version} · ${tr('빌드')} ${i.buildNumber}');
    }).catchError((_) {});
  }

  /// 표시 언어 고르기 — 탭마다 돌리지 않고 목록에서 고른다(바꾸면 앱이 새로 그려진다).
  Future<void> _pickLanguage() async {
    final picked = await showDialog<AppLang>(
      context: context,
      builder: (c) => SimpleDialog(
        backgroundColor: AppColors.washi,
        title: Text(tr('언어 / Language')),
        children: [
          for (final l in AppLang.values)
            ListTile(
              key: ValueKey('lang-${l.name}'),
              title: Text(l.label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.sumi)),
              trailing: l == AppLangPrefs.lang.value ? const Icon(Icons.check, color: AppColors.beni, size: 20) : null,
              onTap: () => Navigator.pop(c, l),
            ),
        ],
      ),
    );
    if (picked != null && picked != AppLangPrefs.lang.value) await AppLangPrefs.set(picked);
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
    final prefs = await Prefs.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith('card:')).toList()) {
      await prefs.remove(k);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('초기화 완료'))));
    }
  }

  /// Talkverse 계정 — 로그인 전: 로그인 타일 / 로그인 후: 이름·이메일·로그아웃·계정 삭제(스토어 심사 요구) + 구매 복원·이용권(한자앱 방식).
  Widget _accountSection() => ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: Account.user,
        builder: (context, u, _) => _SettingsGroup(items: [
          if (u == null)
            _SettingItem(icon: Icons.account_circle_outlined, title: tr('로그인'), subtitle: tr('Talkverse 계정 하나로 모든 앱에서 (선택)'), onTap: () => LoginScreen.open(context).then((_) => setState(() {})))
          else ...[
            _SettingItem(icon: Icons.account_circle, title: (u['display_name'] as String?) ?? tr('이름 없음'), subtitle: (u['email'] as String?) ?? ''),
            _SettingItem(icon: Icons.logout, title: tr('로그아웃'), subtitle: tr('이 기기에서만 로그아웃'), onTap: () => Account.signOut()),
            _SettingItem(icon: Icons.person_remove_outlined, title: tr('계정 삭제'), subtitle: tr('서버의 개인정보 삭제 · 모든 기기 로그아웃'), onTap: () => _confirmDelete(context)),
          ],
          _SettingItem(
            icon: Icons.workspace_premium_outlined,
            title: tr('이용권'),
            subtitle: Account.has('ja') || Purchase.owns('ja') ? tr('보유 중 — 맞춤 회화 무제한') : tr('1개월·3개월·1년·평생 · 구매 또는 이전 구매 복원'),
            onTap: () => PaywallScreen.show(context),
          ),
        ]),
      );

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(tr('계정을 삭제할까요?')),
        content: Text(tr('Talkverse 계정과 이름·이메일·로그인 정보가 지워지고 모든 기기에서 로그아웃됩니다. 이 기기의 학습 기록은 그대로 남습니다. 되돌릴 수 없습니다.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(tr('취소'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(tr('삭제'), style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Account.deleteAccount();
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('삭제하지 못했습니다. 네트워크를 확인하고 다시 시도해 주세요.'))));
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
    final name = LearnerPrefs.name.value;
    final children = <Widget>[
          // 맨 위 카드: 이름이 있으면 이름(누르면 고침)
          InkWell(
            onTap: _editName,
            child: Container(
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
                        Text(name.isNotEmpty ? name : tr('학습자'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.washi, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: name.isNotEmpty ? 0.5 : 2)),
                        const SizedBox(height: 4),
                        Text(AppLangPrefs.isKo ? tr('한국 화자 → 일본어 · 도쿄 표준어') : tr('일본어 · 도쿄 표준어'),
                            style: TextStyle(color: AppColors.kinBright.withValues(alpha: 0.95), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.washi.withValues(alpha: 0.8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(tr('계정')),
          const SizedBox(height: 8),
          _accountSection(),
          const SizedBox(height: 18),
          _SectionTitle(tr('성과')),
          const SizedBox(height: 8),
          const AchievementDesk(),
          const SizedBox(height: 18),
          _SectionTitle(tr('학습 설정')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.badge_outlined,
              title: tr('이름'),
              subtitle: name.isNotEmpty ? trf('{0} — 회화 속 「나」로 나와요', [name]) : tr('없음 — 회화에서 「〇〇」로 보여요'),
              onTap: _editName,
            ),
            _SettingItem(
              icon: LearnerPrefs.isFemale ? Icons.face_3 : Icons.face,
              title: tr('성별'),
              subtitle: tr('회화 속 「나」의 목소리'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                for (final g in const ['male', 'female'])
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      key: ValueKey('gender-$g'),
                      label: Text(g == 'male' ? tr('남성') : tr('여성'), style: const TextStyle(fontSize: 12)),
                      selected: LearnerPrefs.gender.value == g,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      showCheckmark: false,
                      onSelected: (_) async {
                        await LearnerPrefs.setGender(g);
                        if (mounted) setState(() {});
                      },
                    ),
                  ),
              ]),
            ),
            _SettingItem(
              icon: Icons.text_fields,
              title: tr('후리가나'),
              subtitle: tr('기본은 끔 — 힘들어도 보지 않고 익혀보세요'),
              trailing: Switch(
                key: const ValueKey('furigana-switch'),
                value: LearnerPrefs.furigana.value,
                onChanged: (_) async { await FuriganaToggleAction.toggle(context); if (mounted) setState(() {}); },
              ),
            ),
          ]),
          const SizedBox(height: 18),
          _SectionTitle(tr('내려받기')),
          const SizedBox(height: 8),
          const SyncStatusCard(),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
                icon: Icons.download_outlined,
                title: tr('내려받기 설정'),
                subtitle: tr('받을 회화 단계·단어 급 고르기 · 변경 기록'),
                onTap: () => openPane(context, (_) => const DownloadSettingsScreen())),
          ]),
          const SizedBox(height: 18),
          _SectionTitle(tr('앱 설정')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
                icon: Icons.language,
                title: tr('언어 / Language'),
                subtitle: AppLangPrefs.lang.value.label,
                onTap: _pickLanguage),
            // 통합 앱(Talkverse)에서만: 다른 언어 앱으로(2026-11-09)
            if (switchLanguage != null)
              _SettingItem(icon: Icons.swap_horiz, title: tr('다른 언어 배우기'), subtitle: tr('Talkverse 의 다른 언어로 이동'), onTap: switchLanguage!),
          ]),
          const SizedBox(height: 18),
          _SectionTitle(tr('정보')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(icon: Icons.help_outline, title: tr('앱 사용법'), subtitle: tr('처음이라면 이 순서로'), onTap: () => openPane(context, (_) => const AppGuideScreen())),
            _SettingItem(icon: Icons.menu_book_outlined, title: tr('앱 소개'), subtitle: tr('절벽구간 — 단어·한자를 나누는 기준'), onTap: () => openPane(context, (_) => const AboutScreen())),
            _SettingItem(icon: Icons.description_outlined, title: tr('이용약관'), subtitle: 'talkverse.uk/terms', onTap: () => Legal.open(Legal.terms)),
            _SettingItem(icon: Icons.privacy_tip_outlined, title: tr('개인정보처리방침'), subtitle: 'talkverse.uk/talkverse/ja/privacy', onTap: () => Legal.open(Legal.privacy)),
            _SettingItem(icon: Icons.info_outline, title: tr('앱 버전'), subtitle: _version ?? '—'),
            _SettingItem(icon: Icons.copyright, title: tr('저작권'), subtitle: tr('일본어 유니버스 · 2026')),
          ]),
          const SizedBox(height: 18),
          // 되돌릴 수 없는 것은 맨 아래에
          _SectionTitle(tr('기록')),
          const SizedBox(height: 8),
          _SettingsGroup(items: [
            _SettingItem(
              icon: Icons.restart_alt,
              title: tr('학습 기록 초기화'),
              subtitle: tr('회화·한자·복습 기록 삭제'),
              onTap: _resetProgress,
            ),
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
      appBar: AppBar(title: Text(tr('설정 및 프로필'))),
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
              trailing: items[i].trailing ??
                  (items[i].onTap != null ? const Icon(Icons.chevron_right, color: AppColors.beni, size: 18) : null),
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
  final Widget? trailing; // 스위치·고르기 칩(없으면 누를 수 있을 때 화살표)
  const _SettingItem({required this.icon, required this.title, required this.subtitle, this.onTap, this.trailing});
}
