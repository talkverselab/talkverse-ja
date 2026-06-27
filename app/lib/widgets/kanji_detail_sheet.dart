import 'package:flutter/material.dart';
import '../models/flash_card.dart';
import '../services/tts.dart';
import '../theme.dart';
import 'manga_panel.dart';
import 'pressable_scale.dart';

/// 한자 상세 시트 — 한자 탭 시 bottom sheet 로 표시.
/// 구성:
///   1. 큰 한자 + 의미
///   2. 후리가나 readings (행 별 — 음독/훈독)
///   3. 가중 빈도 정보
///   4. 대표 단어 3개 (1행)
class KanjiDetailSheet extends StatelessWidget {
  final FlashCard card;
  const KanjiDetailSheet({super.key, required this.card});

  static Future<void> show(BuildContext context, FlashCard card) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (c) => KanjiDetailSheet(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // grab handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inkLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            _kanjiHead(),
            const SizedBox(height: 14),
            if (card.readings.isNotEmpty) ...[
              _sectionLabel('후리가나 / よみ'),
              const SizedBox(height: 8),
              _readingsList(),
              const SizedBox(height: 16),
            ],
            if (card.exampleWords.isNotEmpty) ...[
              _sectionLabel('대표 단어'),
              const SizedBox(height: 8),
              _exampleWordsRow(),
              const SizedBox(height: 16),
            ],
            _closeBtn(context),
          ],
        ),
      ),
    );
  }

  Widget _kanjiHead() {
    // 한자 음성 = 첫 reading 또는 한자 자체
    final speakText = card.readings.isNotEmpty ? card.readings.first.reading : card.front;
    return MangaPanel(
      backgroundColor: AppColors.sakuraSoft,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PressableScale(
            onTap: () => Tts.instance.speakJa(speakText),
            child: Text(
              card.front,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SpeakerBtn(onTap: () => Tts.instance.speakJa(speakText), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.back,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                    ),
                    _SpeakerBtn(onTap: () => Tts.instance.speakKo(card.back), size: 22),
                  ],
                ),
                if (card.weightedRank != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.honey,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.inkOutline, width: 0.8),
                    ),
                    child: Text(
                      '가중 빈도 #${card.weightedRank}${card.weightedPct != null ? " · ${card.weightedPct!.toStringAsFixed(2)}%" : ""}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.inkSoft,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _readingsList() {
    final kunColor = AppColors.cloverSoft;
    final onColor = AppColors.cobaltSoft;
    return Column(
      children: card.readings.map((r) {
        final isKun = r.kind == '훈독';
        // 발음용 — 하이픈/괄호 제거
        final readPure = r.reading.replaceAll(RegExp(r'[\-\(\)、]'), '');
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isKun ? kunColor : onColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inkOutline, width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  r.kind,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ),
              const SizedBox(width: 10),
              PressableScale(
                onTap: () => Tts.instance.speakJa(readPure),
                child: Text(
                  r.reading,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
                ),
              ),
              const SizedBox(width: 6),
              _SpeakerBtn(onTap: () => Tts.instance.speakJa(readPure), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.gloss,
                  style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _exampleWordsRow() {
    // 3 단어를 1행 — 균등 분배
    return Row(
      children: card.exampleWords.take(3).map((ex) {
        return Expanded(
          child: PressableScale(
            onTap: () => Tts.instance.speakJa(ex.word),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardFront,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.inkOutline, width: 0.8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          ex.word,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.volume_up_rounded, size: 12, color: AppColors.inkSoft),
                    ],
                  ),
                  if (ex.ko.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      ex.ko,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      '#${ex.rank}',
                      style: const TextStyle(fontSize: 10, color: AppColors.inkLight, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _closeBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PressableScale(
        onTap: () {
          Tts.instance.stop();
          Navigator.pop(context);
        },
        child: MangaPanel(
          backgroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Center(
            child: Text(
              '닫기',
              style: TextStyle(color: AppColors.paper, fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeakerBtn extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  const _SpeakerBtn({required this.onTap, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          color: AppColors.honey,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.inkOutline, width: 0.8),
        ),
        child: Icon(Icons.volume_up_rounded, size: size * 0.7, color: AppColors.ink),
      ),
    );
  }
}
