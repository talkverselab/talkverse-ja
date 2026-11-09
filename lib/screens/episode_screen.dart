import '../core/embed_env.dart';
import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/theme.dart';
import '../data/db/app_database.dart';
import '../embed.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/memo_toggle.dart';
import '../widgets/selectable_ja_text.dart';
import 'sentence_flashcard_screen.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

/// 에피소드/다이얼로그 메타 (Learn 탭·회화 허브·홈 공용).
class EpisodeMeta {
  final String level; // 'L1' | 'L2' | 'L3'
  final String id;
  final String title;
  final String emoji;
  final String place;
  final String tone;
  const EpisodeMeta(this.level, this.id, this.title, this.emoji, {this.place = '', this.tone = ''});
}

/// L1~L3 JSON에서 에피소드 목록을 1회 로드해 공유.
class EpisodeCatalog {
  EpisodeCatalog._();
  static final EpisodeCatalog instance = EpisodeCatalog._();

  final Map<String, List<EpisodeMeta>> _byLevel = {};
  final Map<String, List<EpisodeMeta>> _plannedByLevel = {}; // 턴 0 (미작성) 포함
  bool _loaded = false;

  static Map<String, String> get levelLabels => {
    'L1': tr('L1 스토리 — 만남'),
    'L2': tr('L2 카오스 챗 — 일상'),
    'L3': tr('L3 내러티브 — 사랑'),
  };

  static String get charA => tr('민준');
  static String get charB => tr('사쿠라');

  List<EpisodeMeta> forLevel(String level) => _byLevel[level] ?? const [];
  List<EpisodeMeta> plannedForLevel(String level) => _plannedByLevel[level] ?? const [];
  List<EpisodeMeta> get all => ['L1', 'L2', 'L3'].expand(forLevel).toList(growable: false);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    for (final level in ['L1', 'L2', 'L3']) {
      try {
        final raw = await rootBundle.loadString(assetPath('assets/data/dialogues/$level.json'));
        final data = json.decode(raw) as Map<String, dynamic>;
        final units = (data['episodes'] as List?) ?? (data['dialogues'] as List?) ?? [];
        final planned = <EpisodeMeta>[];
        for (final e in units.whereType<Map>()) {
          planned.add(EpisodeMeta(
            level,
            e['id'] as String,
            e['title'] as String? ?? e['id'] as String,
            e['emoji'] as String? ?? '💬',
            place: e['place'] as String? ?? '',
            tone: e['tone'] as String? ?? '',
          ));
        }
        _plannedByLevel[level] = planned;
        _byLevel[level] = [
          for (final e in units.whereType<Map>())
            if ((e['turns'] as List?)?.isNotEmpty ?? false)
              planned.firstWhere((m) => m.id == e['id']),
        ];
      } catch (_) {
        _byLevel[level] = const [];
        _plannedByLevel[level] = const [];
      }
    }
    _loaded = true;
  }
}

/// 에피소드 학습 화면 — 채팅 버블 + 한자 탭 + 턴별 학습 체크.
class EpisodeScreen extends StatefulWidget {
  final EpisodeMeta meta;
  const EpisodeScreen({super.key, required this.meta});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  List<TurnRow> _turns = [];
  final Map<int, bool> _learned = {};
  bool _loading = true;
  bool _showKana = true;
  bool _showRomaji = false;
  int? _cardIndex; // 넓은 화면: 오른쪽 반에 펼친 카드(턴 번호). 버블을 누르면 오른쪽 반만 바뀐다

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final turns = await (appDb.select(appDb.turns)
          ..where((t) =>
              t.level.equals(widget.meta.level) &
              t.dialect.equals('north') &
              t.episodeId.equals(widget.meta.id))
          ..orderBy([(t) => OrderingTerm.asc(t.num)]))
        .get();
    final progress = await appDb.select(appDb.userProgress).get();
    final progressMap = {for (final p in progress) p.turnId: p.learned};
    if (!mounted) return;
    setState(() {
      _turns = turns;
      _learned.addAll({for (final t in turns) t.id: progressMap[t.id] ?? false});
      _loading = false;
    });
  }

  Future<void> _toggleLearned(TurnRow turn) async {
    final now = !(_learned[turn.id] ?? false);
    setState(() => _learned[turn.id] = now);
    await appDb.into(appDb.userProgress).insertOnConflictUpdate(
          UserProgressCompanion(
            turnId: Value(turn.id),
            learned: Value(now),
            lastReviewed: Value(DateTime.now()),
          ),
        );
  }

  int get _learnedCount => _learned.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${meta.emoji} ${meta.title}',
              style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              '${meta.level} · ${EpisodeCatalog.charA} & ${EpisodeCatalog.charB}${meta.place.isNotEmpty ? ' · ${meta.place}' : ''}',
              style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          const KoReadingToggleAction(),
          IconButton(
            tooltip: tr('가나 표시'),
            icon: Text('か',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: _showKana ? AppColors.beni : AppColors.sumiLight,
                )),
            onPressed: () => setState(() => _showKana = !_showKana),
          ),
          IconButton(
            tooltip: tr('로마자 표시'),
            icon: Text('Aa',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: _showRomaji ? AppColors.beni : AppColors.sumiLight,
                )),
            onPressed: () => setState(() => _showRomaji = !_showRomaji),
          ),
          IconButton(
            tooltip: tr('이 에피소드 플래시카드'),
            icon: const Icon(Icons.style, color: AppColors.beni),
            onPressed: () async {
              await openFull(context, (_) => SentenceFlashcardScreen(meta: widget.meta));
              _load();
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Text(
                '$_learnedCount/${_turns.length}',
                style: const TextStyle(color: AppColors.beni, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : LayoutBuilder(builder: (context, box) {
              // 넓은 화면(아이패드 세로·가로, 태블릿, 폴드 펼침): 왼쪽 = 대화, 오른쪽 = 고른 턴의 카드(새 화면이 아니라 오른쪽 반만 바뀜).
              // 대화 버블은 전체 폭으로 늘이면 보기 나쁘므로 가로 720 이상이면 세로여도 반으로 나눈다.
              final split = box.maxWidth >= wideMin;
              final list = Column(
                children: [
                  const AsanohaDivider(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(12, 10, 12, 90 + bottomInset(context)),
                      itemCount: _turns.length,
                      itemBuilder: (context, i) {
                        final t = _turns[i];
                        return _EpisodeBubble(
                          turn: t,
                          learned: _learned[t.id] ?? false,
                          showKana: _showKana,
                          showRomaji: _showRomaji,
                          highlighted: split && _cardIndex == i,
                          onLearnedTap: () => _toggleLearned(t),
                          onCardTap: () async {
                            if (split) {
                              setState(() => _cardIndex = i);
                              return;
                            }
                            await openFull(context, (_) => SentenceFlashcardScreen(meta: widget.meta, initialIndex: i));
                            _load();
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
              if (!split) return list;
              final idx = _cardIndex ?? 0;
              return Row(children: [
                Expanded(child: list),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.kin),
                Expanded(
                  child: SentenceFlashcardScreen(
                    key: ValueKey('card-$idx'),
                    meta: widget.meta,
                    initialIndex: idx,
                    embedded: true,
                    onProgress: _load,
                  ),
                ),
              ]);
            }),
    );
  }
}

class _EpisodeBubble extends StatelessWidget {
  final TurnRow turn;
  final bool learned;
  final bool showKana;
  final bool showRomaji;
  final bool highlighted; // 넓은 화면에서 오른쪽 반에 펼쳐진 턴
  final VoidCallback onLearnedTap;
  final VoidCallback? onCardTap;

  const _EpisodeBubble({
    required this.turn,
    required this.learned,
    required this.showKana,
    required this.showRomaji,
    this.highlighted = false,
    required this.onLearnedTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final isA = turn.speaker == 'A';
    // 사이트 톤: 옅은 색조 버블 + 남색 글자, 화자 색(인디고·구리)은 아바타·테두리에만
    final speakerColor = isA ? AppColors.ai : AppColors.beni;
    final bubbleColor = isA ? const Color(0xFFEFEEFE) : const Color(0xFFF8E8D8);
    final bubbleText = AppColors.sumi;
    final ja = turn.ja;
    final kanaDiffers = turn.kana != null && turn.kana != ja;

    Widget bubble(double maxWidth) => GestureDetector(
      key: ValueKey('bubble-${turn.id}'),
      onTap: onCardTap,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isA ? 4 : 14),
            bottomRight: Radius.circular(isA ? 14 : 4),
          ),
          border: Border.all(
            color: highlighted
                ? speakerColor
                : learned
                    ? AppColors.matcha
                    : AppColors.line,
            width: highlighted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableJaText(
                    text: ja,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: bubbleText,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => TtsService.instance.speakAs(ja, gender: isA ? 'male' : 'female'),
                  child: Icon(Icons.volume_up, size: 16, color: speakerColor),
                ),
              ],
            ),
            if (showKana && kanaDiffers) ...[
              const SizedBox(height: 3),
              Text(
                turn.kana!,
                style: TextStyle(fontSize: 12, color: bubbleText.withValues(alpha: 0.85)),
              ),
            ],
            if (turn.kana != null)
              KoReadingText(
                turn.kana!,
                style: TextStyle(fontSize: 11, color: bubbleText.withValues(alpha: 0.75)),
              ),
            if (showRomaji && turn.romaji != null) ...[
              const SizedBox(height: 2),
              Text(
                turn.romaji!,
                style: TextStyle(fontSize: 11, color: bubbleText.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
              ),
            ],
            if (turn.ko != null) ...[
              const SizedBox(height: 4),
              Container(height: 0.5, color: bubbleText.withValues(alpha: 0.3)),
              const SizedBox(height: 4),
              Text(turn.ko!, style: TextStyle(fontSize: 12, color: bubbleText.withValues(alpha: 0.95))),
            ],
            if (turn.note != null && turn.note!.isNotEmpty) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.washi.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.line, width: 1),
                ),
                child: Text(
                  '💡 ${turn.note}',
                  style: TextStyle(fontSize: 10, color: bubbleText.withValues(alpha: 0.9), height: 1.3),
                ),
              ),
            ],
            MemoToggle(
              patternId: '${turn.level}_${turn.episodeId}',
              idx: turn.num,
              sentence: ja,
              foreground: bubbleText,
            ),
          ],
        ),
      ),
    );

    final avatar = Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: speakerColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            isA ? '民' : '桜',
            style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onLearnedTap,
          child: Icon(
            learned ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: learned ? AppColors.matcha : AppColors.sumiLight,
          ),
        ),
      ],
    );

    // 폰이면 화면의 74%, 넓은 화면의 반 칸이면 그 칸의 74% — MediaQuery 가 아니라 실제 칸 폭 기준
    return LayoutBuilder(builder: (context, box) {
      final b = bubble(box.maxWidth * 0.74);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isA ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: isA
              ? [avatar, const SizedBox(width: 6), Flexible(child: b)]
              : [Flexible(child: b), const SizedBox(width: 6), avatar],
        ),
      );
    });
  }
}
