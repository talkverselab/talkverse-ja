import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kana_phonetics.dart';
import 'vowel_compare_chart.dart';
import '../services/tts_service.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

/// 가나 탭 → 발음 상세 시트.
/// 열리면 1초 뒤 자동 재생, IPA·조음 위치·영어/한국어 비교, 다시듣기 버튼.
Future<void> showKanaSoundSheet(
  BuildContext context, {
  required String kana,
  required String romaji,
  required Color color,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.washi,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _KanaSoundSheet(kana: kana, romaji: romaji, color: color),
  );
}

class _KanaSoundSheet extends StatefulWidget {
  final String kana;
  final String romaji;
  final Color color;
  const _KanaSoundSheet({
    required this.kana,
    required this.romaji,
    required this.color,
  });

  @override
  State<_KanaSoundSheet> createState() => _KanaSoundSheetState();
}

class _KanaSoundSheetState extends State<_KanaSoundSheet> {
  Timer? _autoPlay;
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    // 1초 지연 자동 재생
    _autoPlay = Timer(const Duration(seconds: 1), () {
      TtsService.instance.speak(widget.kana);
    });
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = kanaPhoneticsOf(widget.romaji);
    final vc = vowelChartOf(widget.romaji);
    final color = widget.color;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scroll) => SafeArea(
        top: false,
        child: ListView(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20, 12, 20, 32 + bottomInset(context)),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.sumiLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 헤더: 가나 + 로마자/IPA + 재생 버튼
            Row(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.kana,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.washi,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.romaji,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (p != null)
                        Text(
                          'IPA [${p.ipa}]',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sumi,
                          ),
                        ),
                    ],
                  ),
                ),
                // 다시듣기
                IconButton(
                  iconSize: 44,
                  color: color,
                  tooltip: tr('다시 듣기'),
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: () => TtsService.instance.speak(widget.kana),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (p != null) ...[
              _section(tr('👄 소리나는 곳 · 입모양'), p.place, color),
              // 모음 위치 비교 — 한 차트 위에 일본어(빨강) vs 영어(파랑)
              if (vc != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.washiDeep,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('📍 모음 위치 — 일본어 vs 영어'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      VowelCompareChart(data: vc),
                    ],
                  ),
                ),
              ],
              if (!p.vowelOnly) ...[
                const SizedBox(height: 6),
                // 자음 조음 위치 그림 (위키미디어 자료)
                InkWell(
                  onTap: () => setState(() => _showChart = !_showChart),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          _showChart ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                          color: color,
                        ),
                        Text(
                          tr('자음 조음 위치 그림 보기'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showChart) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/ipa/places_of_articulation.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      tr('그림: Wikimedia Commons IPA 자료 (CC BY-SA)'),
                      style: TextStyle(fontSize: 9, color: AppColors.sumiLight),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 14),
              _section(tr('🇺🇸 영어와 비교'), '${p.engIpa}\n\n${p.engHow}', color),
              const SizedBox(height: 14),
              _section(
                tr('🇰🇷 한국어와 비교'),
                trf('비슷한 소리: {0}\n\n{1}', [p.korSim, p.korDiff]),
                color,
              ),
            ] else
              Text(
                tr('발음 정보가 아직 없어요.'),
                style: TextStyle(color: AppColors.sumiLight),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.washiDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.sumi,
            ),
          ),
        ],
      ),
    );
  }
}
