import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/japanese_decor.dart';
import 'episode_screen.dart';
import 'grammar_lesson_screen.dart';
import 'sentence_flashcard_screen.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

/// 회화 허브 — 스토리 에피소드(L1~L3) + 문법 + 문장 플래시카드.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await EpisodeCatalog.instance.ensureLoaded();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('회화'), style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 2),
            Text('Conversation', style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : Stack(
              children: [
                const Positioned.fill(child: SeigaihaPattern(opacity: 0.05)),
                ListView(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 80 + bottomInset(context)),
                  children: [
                    _storyHub(),
                    const SizedBox(height: 8),
                    _grammarHub(),
                    const SizedBox(height: 16),
                    _characters(),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _storyHub() {
    final catalog = EpisodeCatalog.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final level in ['L1', 'L2', 'L3'])
          if (catalog.plannedForLevel(level).isNotEmpty) ...[
            Row(
              children: [
                SealStamp(text: level, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trf('{0} · {1}/{2}편', [EpisodeCatalog.levelLabels[level], catalog.forLevel(level).length, catalog.plannedForLevel(level).length]),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: catalog.plannedForLevel(level).length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final meta = catalog.plannedForLevel(level)[i];
                  final ready = catalog.forLevel(level).any((m) => m.id == meta.id);
                  return InkWell(
                    onTap: ready
                        ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => EpisodeScreen(meta: meta)))
                        : null,
                    child: Container(
                      width: 104,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ready ? AppColors.washi : AppColors.washiDeep,
                        border: Border.all(
                          color: ready ? AppColors.beni : AppColors.kin.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(meta.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            '${i + 1}. ${meta.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: ready ? AppColors.sumi : AppColors.sumiLight,
                            ),
                          ),
                          if (meta.place.isNotEmpty)
                            Text(
                              ready ? meta.place : tr('준비 중'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9, color: AppColors.sumiLight),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _grammarHub() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SealStamp(text: '学', size: 22),
            const SizedBox(width: 8),
            Text(
              tr('우리 콘텐츠 (자체 제작)'),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.sumi, letterSpacing: 2),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _HubCard(
          title: tr('조사 (助詞) 핵심 20'),
          sub: tr('은/는·이/가·을/를 1:1 매핑 + 종조사 ね·よ·か'),
          seal: '助詞',
          color: AppColors.ai,
          builder: (_) => const GrammarLessonScreen(),
        ),
        const SizedBox(height: 8),
        _HubCard(
          title: tr('문장 플래시카드'),
          sub: tr('전 레벨 랜덤 20문장 · 뜻 뒤집기 · 남/녀 음성'),
          seal: '復習',
          color: AppColors.matcha,
          builder: (_) => const SentenceFlashcardScreen(),
        ),
      ],
    );
  }

  Widget _characters() {
    return JapaneseCard(
      title: tr('등장인물'),
      sealText: '人',
      accent: AppColors.sumi,
      child: Column(
        children: [
          _CharRow(
            avatar: '民',
            color: AppColors.ai,
            name: tr('민준 (28)'),
            role: tr('한국 IT 직장인 · 도쿄 출장 중 · 화자 A (남)'),
          ),
          const SizedBox(height: 8),
          _CharRow(
            avatar: '桜',
            color: AppColors.beni,
            name: tr('사쿠라 (26)'),
            role: tr('도쿄 디자이너 · 화자 B (여) · 표준어 (도쿄)'),
          ),
        ],
      ),
    );
  }
}

class _CharRow extends StatelessWidget {
  final String avatar;
  final Color color;
  final String name;
  final String role;
  const _CharRow({required this.avatar, required this.color, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text(avatar, style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.w900, fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.sumi)),
              Text(role, style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String sub;
  final String seal;
  final Color color;
  final WidgetBuilder builder;

  const _HubCard({
    required this.title,
    required this.sub,
    required this.seal,
    required this.color,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: builder)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.washi,
          border: Border.all(color: color, width: 1.2),
        ),
        child: Row(
          children: [
            SealStamp(text: seal, size: 40, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.sumi)),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.sumiLight),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.sumiLight),
          ],
        ),
      ),
    );
  }
}
