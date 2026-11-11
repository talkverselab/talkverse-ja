import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/theme.dart';
import '../embed.dart';
import '../review/review_engine.dart';
import '../review/review_ui.dart';
import '../services/art_service.dart';
import '../services/deck_service.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/today_mission.dart';
import 'custom_script_screen.dart';
import 'dialogue_screen.dart';
import 'episode_screen.dart';
import 'flashcard_screen.dart';
import 'gairaigo_screen.dart';
import 'hanja_sound_screen.dart';
import 'jlpt_words_screen.dart';
import 'kana_chart_screen.dart';
import 'kanji_dictionary_screen.dart';
import 'kanji_practice_screen.dart';
import 'kanji_stages_screen.dart';
import 'phonetic_roots_screen.dart';
import 'sense_course_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'sentence_flashcard_screen.dart';
import 'sentence_units_screen.dart';
import 'word_freq_screen.dart';
import 'about_screen.dart';
import 'app_guide_screen.dart';

/// 메인 — 탭 4개: 배우기(오늘의 학습·기초 수업·에피소드 단원) · 복습(문장 카드·덱·한자 퀴즈) · 탐색(사전·단어·한자음…) · 나(진행·설정).
/// 한자유니버스와 같은 구조(사용자 지시 2026-11-01: 아이패드·갤탭·폴드 UX 를 한자앱 기준으로).
/// 넓은 화면(isWide): 앱바 아래 왼쪽 = 탭 레일 + 그 탭의 목록, 오른쪽 = 고른 내용(자기 Navigator). 폰: 하단 탭 + 내용 전체 화면.
/// 학습(에피소드·카드 세션·퀴즈)은 어느 쪽이든 openFull 로 목록을 감추고 전체 화면.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final _pane = GlobalKey<NavigatorState>();
  final _wide = GlobalKey<NavigatorState>(); // 레일 오른쪽 전체(목록 칸 + 오른쪽 칸)를 덮는 넓은 칸
  bool _wideOpen = false;
  late final _wideObs = _CountObserver((n) {
    final open = n > 1;
    if (open == _wideOpen) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _wideOpen = open);
    });
  });

  void _selectTab(int i) {
    _wide.currentState?.popUntil((r) => r.isFirst); // 탭을 바꾸면 넓은 칸(회화)을 닫는다
    setState(() => _index = i);
  }

  static List<(IconData, IconData, String)> get _tabs => [
    (Icons.menu_book_outlined, Icons.menu_book, tr('배우기')),
    (Icons.style_outlined, Icons.style, tr('복습')),
    (Icons.explore_outlined, Icons.explore, tr('탐색')),
    (Icons.person_outline, Icons.person, tr('설정 및 프로필')),
  ];

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      centerTitle: false,
      // 「일본어」 워드마크 그라데이션(구리 → 황갈) — talkverse.uk 일본어 페이지 기준
      title: GradText(
        tr('일본어유니버스'),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          tooltip: tr('한자 사전'),
          icon: const Icon(Icons.search, color: AppColors.sumi),
          onPressed: () =>
              openPane(context, (_) => const KanjiDictionaryScreen()),
        ),
        const SizedBox(width: 4),
      ],
    );
    final stack = IndexedStack(
      index: _index,
      children: const [LearnTab(), ReviewTab(), ExploreTab(), MeTab()],
    );
    // 폰(한 화면): 하단 탭 + 내용 전체 화면
    if (!isWide(context)) {
      return Scaffold(
        appBar: appBar,
        body: stack,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final t in _tabs)
              NavigationDestination(
                icon: Icon(t.$1),
                selectedIcon: Icon(t.$2),
                label: t.$3,
              ),
          ],
        ),
      );
    }
    // 넓은 화면(아이패드·안드로이드 태블릿·폴드 펼침): 레일 + 왼쪽 칸(탭 목록) | 오른쪽 칸(연 화면). 두 칸까지만.
    final w = MediaQuery.sizeOf(context).width;
    final left = (w * 0.34).clamp(
      300.0,
      440.0,
    ); // 폴드 펼침(≈740) 은 300, 아이패드는 더 넓게
    return Pane(
      navKey: _pane,
      wideKey: _wide,
      child: NavigatorPopHandler(
        onPopWithResult: (_) => _wideOpen ? _wide.currentState?.maybePop() : _pane.currentState?.maybePop(),
        child: Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _selectTab,
                labelType: w >= 900
                    ? NavigationRailLabelType.all
                    : NavigationRailLabelType.selected,
                backgroundColor: AppColors.washiDeep,
                indicatorColor: const Color(0xFFF8E8D8),
                selectedIconTheme: const IconThemeData(
                  color: AppColors.beniDeep,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: AppColors.muted,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppColors.beni,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                destinations: [
                  for (final t in _tabs)
                    NavigationRailDestination(
                      icon: Icon(t.$1),
                      selectedIcon: Icon(t.$2),
                      label: Text(t.$3),
                    ),
                ],
                // 맨 아래 「앱 사용법」(2026-11-08)·「앱 소개」(절벽구간, 2026-11-07)
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RailLink(icon: Icons.help_outline, label: tr('앱 사용법'), onTap: () => openPane(context, (_) => const AppGuideScreen())),
                          const SizedBox(height: 6),
                          _RailLink(icon: Icons.info_outline, label: tr('앱 소개'), onTap: () => openPane(context, (_) => const AboutScreen())),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.line,
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: left, child: stack),
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: AppColors.line,
                        ),
                        Expanded(
                          child: ClipRect(
                            child: Navigator(
                              key: _pane,
                              onGenerateInitialRoutes: (_, _) => [
                                MaterialPageRoute(
                                  builder: (_) => const _PanePlaceholder(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 넓은 칸: 비어 있을 때는 투명하고 터치를 통과시킨다. 회화 편을 열면 목록 칸 + 오른쪽 칸을 덮는다.
                    IgnorePointer(
                      ignoring: !_wideOpen,
                      child: ClipRect(
                        child: Navigator(
                          key: _wide,
                          observers: [_wideObs],
                          onGenerateInitialRoutes: (_, _) => [
                            PageRouteBuilder(opaque: false, pageBuilder: (_, _, _) => const SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigator 에 쌓인 화면 수를 알려 준다(넓은 칸이 열렸는지 판단).
class _CountObserver extends NavigatorObserver {
  final void Function(int) onCount;
  int _n = 0;
  _CountObserver(this.onCount);
  @override
  void didPush(Route route, Route? previousRoute) => onCount(++_n);
  @override
  void didPop(Route route, Route? previousRoute) => onCount(--_n);
  @override
  void didRemove(Route route, Route? previousRoute) => onCount(--_n);
}

/// 오른쪽 칸이 비어 있을 때.
class _PanePlaceholder extends StatelessWidget {
  const _PanePlaceholder();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.washi,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SealStamp(text: '学', size: 56),
          const SizedBox(height: 14),
          Text(
            tr('왼쪽에서 고르면 여기에 열립니다 · 에피소드·카드·퀴즈는 전체 화면'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

/// 탭 안의 한 줄(카드) — 도장 + 제목·부제 + 꺾쇠. 누르면 오른쪽 칸(넓은 화면) 또는 push.
class _NavRow extends StatelessWidget {
  final String seal;
  final Color? sealColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _NavRow({
    required this.seal,
    this.sealColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.washi,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
          boxShadow: kCardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SealStamp(text: seal, size: 40, color: sealColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sumi,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _section(String title) => Padding(
  padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
  child: Text(
    title,
    style: const TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
      letterSpacing: 0.5,
    ),
  ),
);

// ────────── 배우기 ──────────

/// 배우기: 오늘의 학습 카드 → 기초 수업(50음도·조사·한자 단계) → 에피소드 단원(L1~L3). 단원은 전체 화면.
class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  String _filter = tr('전체');
  List<String> _readyLevels = const [];
  List<String> get _filters => [tr('전체'), ..._readyLevels];
  List<_LessonItem> _lessons = [];
  EpisodeMeta? _today;
  int _todayLearned = 0;
  int _todayTotal = 40;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await EpisodeCatalog.instance.ensureLoaded();
    final turns = await appDb.select(appDb.turns).get();
    final progress = await appDb.select(appDb.userProgress).get();
    final learnedIds = progress
        .where((p) => p.learned)
        .map((p) => p.turnId)
        .toSet();

    // 오늘의 학습 = 첫 미완료 에피소드
    EpisodeMeta? today;
    var todayLearned = 0, todayTotal = 40;
    for (final meta in EpisodeCatalog.instance.all) {
      final epTurns = turns
          .where(
            (t) =>
                t.level == meta.level &&
                t.dialect == 'north' &&
                t.episodeId == meta.id,
          )
          .toList();
      if (epTurns.isEmpty) continue; // 내용 없는 편은 「오늘의 학습」에도 안 띄운다
      final learned = epTurns.where((t) => learnedIds.contains(t.id)).length;
      today = meta; // 다 끝냈으면 마지막 편이 남는다
      todayLearned = learned;
      todayTotal = epTurns.length;
      if (learned < epTurns.length) break;
    }

    final items = <_LessonItem>[];
    final ready = <String>[];
    for (final level in ['L1', 'L2', 'L3']) {
      // 출시 기준(2026-11-09, 지침 2.1): 내용이 없는 편(「준비 중」)은 목록에 두지 않는다.
      final metas = EpisodeCatalog.instance.plannedForLevel(level).where((m) => turns.any((t) => t.level == level && t.dialect == 'north' && t.episodeId == m.id)).toList();
      if (metas.isEmpty) continue;
      ready.add(level);
      if (_filter != tr('전체') && _filter != level) continue;
      items.add(
        _LessonItem.header(
          EpisodeCatalog.levelLabels[level] ?? level,
          metas.length,
        ),
      );
      var currentAssigned = false;
      for (var i = 0; i < metas.length; i++) {
        final meta = metas[i];
        final epTurns = turns
            .where(
              (t) =>
                  t.level == level &&
                  t.dialect == 'north' &&
                  t.episodeId == meta.id,
            )
            .toList();
        final total = epTurns.length;
        final learned = epTurns.where((t) => learnedIds.contains(t.id)).length;
        final done = total > 0 && learned >= total;
        _LessonState state;
        if (done) {
          state = _LessonState.done;
        } else if (!currentAssigned && total > 0) {
          state = _LessonState.current;
          currentAssigned = true;
        } else {
          state = _LessonState.locked;
        }
        items.add(
          _LessonItem(
            '${level == 'L1' ? 'EP' : 'D'}${i + 1}',
            '${meta.emoji} ${meta.title}',
            state,
            meta: meta,
            learned: learned,
            total: total,
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _lessons = items;
        _readyLevels = ready;
        _today = today;
        _todayLearned = todayLearned;
        _todayTotal = todayTotal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    return Stack(
      children: [
        // 사이트 첫 화면처럼 위쪽만 파스텔 메시, 아래는 흰 바탕
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 260,
          child: MeshBackdrop(),
        ),
        ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Row(
              children: [
                const GradText(
                  'こんにちは!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                const SakuraIcon(size: 18),
                const Spacer(),
                const StreakChip(days: 1),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              tr('한국 학습자, 오늘도 시작해요'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.sumiLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            _section(tr('오늘의 학습')),
            if (today == null)
              const SizedBox(height: 120)
            else
              TodayMissionCard(
                level: today.level == 'L1' ? 'BEGINNER 1' : today.level,
                lessonTitle: '${today.level} · ${today.title}',
                lessonSubtitle: trf('민준 & 사쿠라 스토리 {0}{1}', [
                  today.emoji,
                  today.place.isNotEmpty ? ' · ${today.place}' : '',
                ]),
                progress: _todayLearned,
                total: _todayTotal,
                onTap: () async {
                  await openFull(
                    context,
                    (_) => EpisodeScreen(meta: today),
                  ); // 학습은 전체 화면
                  _load();
                },
              ),
            _section(tr('정규과정')),
            _NavRow(
              seal: '感覚',
              sealColor: AppColors.ai,
              title: tr('언어감각 익히기'),
              subtitle: tr('L1 조사 익히기부터 · 문법 짧게 → 문장으로 감 익히기'),
              onTap: () => openPane(context, (_) => const SenseCourseScreen()),
            ),
            _section(tr('기초')),
            _NavRow(
              seal: 'かな',
              sealColor: AppColors.sakuraDeep,
              title: tr('50음도와 발음'),
              subtitle: 'ひらがな·カタカナ',
              onTap: () => openPane(context, (_) => const KanaChartScreen()),
            ),
            _NavRow(
              seal: '漢字',
              sealColor: AppColors.beni,
              title: tr('한자 배우기'),
              subtitle: tr('글자 형성·소리 가족·그림 · 단계별 20자 → 문제'),
              onTap: () => openPane(context, (_) => const KanjiStagesScreen(learn: true)),
            ),
            _NavRow(
              seal: 'カナ',
              sealColor: AppColors.matcha,
              title: tr('외국어 발음 규칙'),
              subtitle: tr('영어 소리 → 가타카나 · 규칙 한눈에 · 16줄기'),
              onTap: () => openPane(context, (_) => const GairaigoScreen(rulesFirst: true)),
            ),
            _NavRow(
              seal: '練習',
              sealColor: AppColors.kinDeep,
              title: tr('한자 연습'),
              subtitle: tr('패밀리가 큰 한자부터 · 하루 3패밀리 · 94패밀리'),
              onTap: () => openPane(context, (_) => const KanjiPracticeScreen()),
            ),
            _section(tr('회화')),
            _NavRow(
              seal: '会話',
              sealColor: AppColors.beni,
              title: tr('주제별 회화 R0~R4'),
              subtitle: tr('모든 문장 듣기 · 그림 카드 · 왕초보/초보'),
              onTap: () => openPane(context, (_) => const DialogueHomeScreen()),
            ),
            _NavRow(
              seal: '✨',
              sealColor: AppColors.kinDeep,
              title: tr('맞춤 회화 만들기'),
              subtitle: tr('주제·상황·레벨 → 나만의 1편 · 첫 편 무료'),
              onTap: () => openPane(context, (_) => const CustomScriptScreen()),
            ),
            _section(tr('단어')),
            _NavRow(
              seal: '語彙',
              title: tr('절벽 단어 R1~R5'),
              subtitle: tr('빈도 2,000 · 20어 단원 · 회화 단어 포함'),
              onTap: () => openPane(context, (_) => const WordFreqScreen()),
            ),
            _NavRow(
              seal: 'N5',
              sealColor: AppColors.matcha,
              title: tr('JLPT 단어'),
              subtitle: 'N5 735 · N4 676 · N3 2,135 · N2 1,744 · N1 2,698',
              onTap: () => openPane(context, (_) => const JlptWordsScreen()),
            ),
            if (_lessons.isNotEmpty) _section(tr('에피소드')),
            if (_readyLevels.length > 1) SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final selected = f == _filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _filter = f);
                      _load();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.beni : AppColors.washiDeep,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? AppColors.beni : AppColors.line,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        f,
                        style: TextStyle(
                          color: selected ? AppColors.washi : AppColors.sumi,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            for (final l in _lessons) _LessonRow(lesson: l, onReturn: _load),
            _section(tr('참고')),
            _NavRow(
              seal: '音符',
              sealColor: AppColors.ai,
              title: tr('패밀리 한자'),
              subtitle: tr('소리 부품이 같은 한자 가족 · 工·方·令·青…'),
              onTap: () => openPane(context, (_) => const PhoneticRootsScreen()), // 사용자 지시 2026-11-02 밤 "원래 니 구조가 더 좋았어" — 앱 자체 발음부 화면으로 원복(한자앱식 HanjaFamilyScreen 은 파일만 남김)
            ),
          ],
        ),
      ],
    );
  }
}

enum _LessonState { done, current, locked }

class _LessonItem {
  final String id;
  final String title;
  final _LessonState state;
  final EpisodeMeta? meta;
  final int learned;
  final int total;
  final bool isHeader;
  _LessonItem(
    this.id,
    this.title,
    this.state, {
    required this.meta,
    required this.learned,
    required this.total,
  }) : isHeader = false;

  _LessonItem.header(this.title, int count)
    : id = '',
      state = _LessonState.locked,
      meta = null,
      learned = 0,
      total = count,
      isHeader = true;
}

class _LessonRow extends StatelessWidget {
  final _LessonItem lesson;
  final VoidCallback onReturn;
  const _LessonRow({required this.lesson, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    if (lesson.isHeader) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(2, 12, 2, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sumi,
                ),
              ),
            ),
            Text(
              trf('{0}편', [lesson.total]),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.beni,
              ),
            ),
          ],
        ),
      );
    }
    final current = lesson.state == _LessonState.current;
    final locked = lesson.state == _LessonState.locked;
    final Color textColor = current
        ? AppColors.washi
        : locked
        ? AppColors.muted
        : AppColors.sumi;
    final Widget trailing = switch (lesson.state) {
      _LessonState.done => const Icon(
        Icons.check_circle,
        color: AppColors.matcha,
        size: 20,
      ),
      _LessonState.current => const Icon(
        Icons.arrow_forward,
        color: AppColors.washi,
        size: 20,
      ),
      _LessonState.locked => const Icon(
        Icons.lock_outline,
        color: AppColors.muted,
        size: 18,
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: current
              ? AppColors.beni
              : locked
              ? AppColors.washiDeep
              : AppColors.washi,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: current ? AppColors.beniDeep : AppColors.line,
          ),
          boxShadow: current ? kCardShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: locked || lesson.meta == null || lesson.total == 0
                ? null
                : () async {
                    await openFull(
                      context,
                      (_) => EpisodeScreen(meta: lesson.meta!),
                    ); // 학습은 전체 화면
                    onReturn();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      lesson.id,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (lesson.total > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${lesson.learned}/${lesson.total}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: textColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────── 복습 ──────────

/// 복습: 문장 카드(전 레벨 랜덤) · 복습 덱 5 · 한자 퀴즈 — 세션은 전체 화면.
class ReviewTab extends StatelessWidget {
  const ReviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _section(tr('오늘의 복습')),
        const _TodayReview(),
        const SizedBox(height: 12),
        _section(tr('복습')),
        _NavRow(
          seal: '十文',
          sealColor: AppColors.ai,
          title: tr('문장 단원'),
          subtitle: tr('회화에 나온 줄 10문장씩 · 다시/알았음 · 숙련도 %'),
          onTap: () => openPane(context, (_) => const SentenceUnitsScreen()),
        ),
        _NavRow(
          seal: '文',
          title: tr('문장 플래시카드'),
          subtitle: tr('전 레벨 랜덤 20'),
          onTap: () =>
              openFull(context, (_) => const SentenceFlashcardScreen()),
        ),
        _NavRow(
          seal: '復習',
          sealColor: AppColors.kinDeep,
          title: tr('복습 덱'),
          subtitle: tr('Flashcard 덱 5'),
          onTap: () => openPane(context, (_) => const FlashcardScreen()),
        ),
        _NavRow(
          seal: '漢字',
          sealColor: AppColors.sumi,
          title: tr('한자 퀴즈'),
          subtitle: tr('JLPT N5→N1 · 4~8지선다 · 헷갈리는 보기'),
          onTap: () => openPane(context, (_) => const KanjiStagesScreen()),
        ),
      ],
    );
  }
}

// ────────── 탐색 ──────────

/// 탐색: 사전·단어·한자음·외래어(발음부는 배우기 → 참고 「패밀리 한자」 하나로 합침, 2026-11-08) — 참고 자료는 오른쪽 칸에.
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => openPane(context, (_) => const KanjiDictionaryScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.washiDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.beni, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr('한자 · 뜻(사랑) · 읽기(あい) · 단어'),
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _section(tr('한자')),
        _NavRow(
          seal: '辞書',
          sealColor: const Color(0xFF6A1B9A),
          title: tr('한자 사전'),
          subtitle: tr('2,285자 · 읽기별 단어'),
          onTap: () => openPane(context, (_) => const KanjiDictionaryScreen()),
        ),
        _NavRow(
          seal: '音',
          sealColor: AppColors.sumi,
          title: tr('한자음'),
          subtitle: tr('한국 한자음 ↔ 音読み'),
          onTap: () => openPane(context, (_) => const HanjaSoundScreen()),
        ),
        _section(tr('단어')),
        _NavRow(
          seal: 'N5',
          sealColor: AppColors.matcha,
          title: tr('JLPT 단어'),
          subtitle: 'N5 735 · N4 676 · N3 2,135 · N2 1,744 · N1 2,698',
          onTap: () => openPane(context, (_) => const JlptWordsScreen()),
        ),
        _NavRow(
          seal: '語彙',
          title: tr('절벽 단어 R1~R5'),
          subtitle: tr('빈도 2,000 · 20어 단원 · 회화 단어 포함'),
          onTap: () => openPane(context, (_) => const WordFreqScreen()),
        ),
        _NavRow(
          seal: '外来',
          sealColor: const Color(0xFF00695C),
          title: tr('영어등유래단어'),
          subtitle: tr('음차 규칙·유래 언어'),
          onTap: () => openPane(context, (_) => const GairaigoScreen()),
        ),
      ],
    );
  }
}

// ────────── 설정 및 프로필 ──────────

/// 설정 및 프로필 탭: 진행·달성률 + 프로필·설정(표시 언어·기록 초기화). 앱 업데이트 타일은 2026-11-07 사용자 지시로 뺌(배포는 스토어·TestFlight).
class MeTab extends StatelessWidget {
  const MeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        _section(tr('진행')),
        _NavRow(
          seal: '進',
          title: tr('진행'),
          subtitle: tr('학습 기록 · 달성률'),
          onTap: () => openPane(context, (_) => const ProgressScreen()),
        ),
        const ProfileScreen(embedded: true),
      ],
    );
  }
}


/// 라이트너 7단계 복습(공용 엔진 `lib/review`, talkverse.uk 세션 제작) — 카드 소스 = R1 회화 골격 덱.
/// 앞면 = 한국어 뜻(기본), 뒷면 = 일본어 + 가나. 하루 새 카드 20장, 정답→승급·오답→1단계, 틀린 카드는 세션 끝에 다시.
class _TodayReview extends StatefulWidget {
  const _TodayReview();
  @override
  State<_TodayReview> createState() => _TodayReviewState();
}

class _TodayReviewState extends State<_TodayReview> {
  final Map<String, DeckCard> _cards = {};
  List<ReviewCandidate> _cands = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DeckService.instance.ensureLoaded();
    await ArtService.instance.urlFor(''); // 매니페스트를 먼저 받아 두면 카드마다 동기 조회 가능
    final cands = <ReviewCandidate>[];
    for (final deck in DeckService.instance.decks) {
      if (deck.id != 'r1' && deck.id != 'native') continue; // 절벽 R1 골격 + 회화 톤 핵심
      for (final c in deck.cards) {
        _cards[c.id] = c;
        cands.add(ReviewCandidate(c.id, category: deck.id, soundKey: c.kana.isNotEmpty ? c.kana : null));
      }
    }
    if (mounted) setState(() => _cands = cands);
  }

  ReviewFace? _resolve(String id) {
    final c = _cards[id];
    if (c == null) return null;
    final m = RegExp(r'^r1_(\d+)$').firstMatch(c.id);
    final rank = m == null ? null : int.tryParse(m.group(1)!);
    final art = ArtService.instance.urlForSync(c.front, rank: rank); // 공용 단어 그림(네트워크 URL — review_ui 가 http 면 Image.network)
    return ReviewFace(prompt: c.back, target: c.front, reading: c.kana, asset: art, note: c.key.isNotEmpty ? c.key : null);
  }

  @override
  Widget build(BuildContext context) {
    if (_cands.isEmpty) return const SizedBox.shrink();
    return ReviewTodayCard(
      candidates: _cands,
      resolve: _resolve,
      speak: (id, face) => TtsService.instance.speak(face.reading?.isNotEmpty == true ? face.reading! : face.target),
      title: tr('오늘의 복습'),
    );
  }
}

/// 레일 맨 아래 작은 링크(앱 사용법·앱 소개).
class _RailLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _RailLink({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.muted, size: 22),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
