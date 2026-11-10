import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../services/art_service.dart';
import '../services/content_sync.dart';
import '../services/ko_reading.dart';
import '../services/word_service.dart' show FuriSeg;
import 'furigana_text.dart';

/// 단어 카드 — 모든 단어 화면 공용(사용자 지시 2026-11-10 "모든 단어화면 카드형식").
/// 위: 단어 그림(없으면 단어를 크게), 아래: 표기(후리가나)·읽기·뜻. 왼쪽 위 배지, 오른쪽 위 듣기.
class WordCard extends StatelessWidget {
  final String word;
  final List<FuriSeg>? segs; // 없으면 word 를 그대로
  final String kana; // 읽기(가나) — 비면 읽기 줄 생략
  final String gloss;
  final String? note; // 뜻 아래 작은 한 줄(예외·메모)
  final bool dimGloss;
  final String? badge;
  final Color badgeColor;
  final String? artWord; // 그림 찾을 낱말(기본 word)
  final int? artRank;
  final bool showRuby;
  final Color? borderColor;
  final VoidCallback? onTap, onLongPress, onSpeak;
  const WordCard({
    super.key,
    required this.word,
    this.segs,
    this.kana = '',
    required this.gloss,
    this.note,
    this.dimGloss = false,
    this.badge,
    this.badgeColor = AppColors.sumi,
    this.artWord,
    this.artRank,
    this.showRuby = false,
    this.borderColor,
    this.onTap,
    this.onLongPress,
    this.onSpeak,
  });

  /// 카드 격자 — 폰 2열, 넓을수록 열이 는다.
  static const grid = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 210,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 0.78,
  );

  Widget _word(double size) => segs != null
      ? FuriganaText(segs: segs!, fontSize: size, showRuby: showRuby)
      : Text(
          word,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: AppColors.sumi,
          ),
        );

  Future<String?> get artUrl =>
      ArtService.instance.urlFor(artWord ?? word, rank: artRank);

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: artUrl,
    builder: (context, snap) => render(context, snap.data),
  );

  /// 그림 주소를 이미 아는 채로 그린다([WordCardGrid]).
  Widget render(BuildContext context, String? url) {
    {
      {
        Widget bigWord() => Container(
          color: AppColors.washiDeep,
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(10, 22, 10, 8),
          child: FittedBox(fit: BoxFit.scaleDown, child: _word(34)),
        );
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.washi,
            border: Border.all(color: borderColor ?? AppColors.line),
            borderRadius: BorderRadius.circular(14),
            boxShadow: kCardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? onSpeak,
              onLongPress: onLongPress,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (url == null)
                          bigWord()
                        else
                          Image(
                            image: artProvider(url),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => bigWord(),
                          ),
                        if (badge != null)
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (onSpeak != null)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: IconButton(
                              tooltip: tr('듣기'),
                              visualDensity: VisualDensity.compact,
                              onPressed: onSpeak,
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.washi.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volume_up,
                                  size: 16,
                                  color: AppColors.beni,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (url != null)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _word(19),
                          ),
                        if (kana.isNotEmpty)
                          KoReadingText(
                            kana,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.sumiLight,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          gloss,
                          maxLines: note == null ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: dimGloss ? 11 : 13,
                            fontWeight: FontWeight.w700,
                            color: dimGloss
                                ? AppColors.sumiLight
                                : AppColors.sumi,
                            height: 1.3,
                          ),
                        ),
                        if (note != null)
                          Text(
                            note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.sumiLight,
                              height: 1.3,
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
  }

  /// 그림 없는 단어의 낮은 카드 — 빈 그림 칸 없이 표기·읽기·뜻만(사용자 지적 2026-11-11 "빈칸이 왜이리 많어").
  Widget renderCompact(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AppColors.washi,
      border: Border.all(color: borderColor ?? AppColors.line),
      borderRadius: BorderRadius.circular(12),
      boxShadow: kCardShadow,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onSpeak,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _word(20),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (kana.isNotEmpty && kana != word)
                      KoReadingText(
                        kana,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.sumiLight,
                        ),
                      ),
                    Text(
                      note == null ? gloss : '$gloss · $note',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: dimGloss ? AppColors.sumiLight : AppColors.sumi,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSpeak != null)
                IconButton(
                  tooltip: tr('듣기'),
                  visualDensity: VisualDensity.compact,
                  onPressed: onSpeak,
                  icon: const Icon(
                    Icons.volume_up,
                    size: 17,
                    color: AppColors.beni,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 단어 카드 묶음 — 그림 있는 단어는 그림 카드 격자, 그림 없는 단어는 그 아래 낮은 카드 격자.
/// 그림 없는 카드가 큰 빈칸으로 남지 않게 한다. 목록 안에 끼워 쓰는 용도(스크롤하지 않는다).
class WordCardGrid extends StatefulWidget {
  final List<WordCard> cards;
  const WordCardGrid({super.key, required this.cards});

  static const compactGrid = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 210,
    mainAxisSpacing: 8,
    crossAxisSpacing: 10,
    mainAxisExtent: 74,
  );

  @override
  State<WordCardGrid> createState() => _WordCardGridState();
}

class _WordCardGridState extends State<WordCardGrid> {
  List<String?>? _urls;
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(WordCardGrid old) {
    super.didUpdateWidget(old);
    final same =
        old.cards.length == widget.cards.length &&
        [
          for (var i = 0; i < old.cards.length; i++)
            old.cards[i].word == widget.cards[i].word &&
                old.cards[i].artRank == widget.cards[i].artRank,
        ].every((x) => x);
    if (!same) _resolve();
  }

  Future<void> _resolve() async {
    final gen = ++_gen;
    final urls = await Future.wait(widget.cards.map((c) => c.artUrl));
    if (mounted && gen == _gen) setState(() => _urls = urls);
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    final cards = widget.cards;
    if (urls == null || urls.length != cards.length) {
      return const SizedBox(height: 74);
    }
    final pic = [
      for (var i = 0; i < cards.length; i++)
        if (urls[i] != null) i,
    ];
    final plain = [
      for (var i = 0; i < cards.length; i++)
        if (urls[i] == null) i,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pic.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: WordCard.grid,
            itemCount: pic.length,
            itemBuilder: (context, i) =>
                cards[pic[i]].render(context, urls[pic[i]]),
          ),
        if (pic.isNotEmpty && plain.isNotEmpty) const SizedBox(height: 10),
        if (plain.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: WordCardGrid.compactGrid,
            itemCount: plain.length,
            itemBuilder: (context, i) => cards[plain[i]].renderCompact(context),
          ),
      ],
    );
  }
}
