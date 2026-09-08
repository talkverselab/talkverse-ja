import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/kana_phonetics.dart';
import '../services/tts_service.dart';

/// 가나 탭 → 발음 상세 시트.
/// 열리면 1초 뒤 자동 재생, IPA·조음 위치·영어/한국어 비교, 다시듣기 버튼.
Future<void> showKanaSoundSheet(BuildContext context, {
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
  const _KanaSoundSheet({required this.kana, required this.romaji, required this.color});

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
    final color = widget.color;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
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
                width: 84, height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(widget.kana,
                    style: const TextStyle(
                        fontSize: 44, fontWeight: FontWeight.w900, color: AppColors.washi)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.romaji,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                    const SizedBox(height: 4),
                    if (p != null)
                      Text('IPA [${p.ipa}]',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.sumi)),
                  ],
                ),
              ),
              // 다시듣기
              IconButton(
                iconSize: 44,
                color: color,
                tooltip: '다시 듣기',
                icon: const Icon(Icons.play_circle_fill),
                onPressed: () => TtsService.instance.speak(widget.kana),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (p != null) ...[
            _section('👄 소리나는 곳 · 입모양', p.place, color),
            const SizedBox(height: 6),
            // IPA 차트 (위키미디어 자료)
            InkWell(
              onTap: () => setState(() => _showChart = !_showChart),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(_showChart ? Icons.expand_less : Icons.expand_more,
                        size: 18, color: color),
                    Text(p.vowelOnly ? 'IPA 모음 차트 보기' : 'IPA 조음 위치 그림 보기',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: color)),
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
                    p.vowelOnly
                        ? 'assets/images/ipa/ipa_vowel_chart.png'
                        : 'assets/images/ipa/places_of_articulation.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('차트: Wikimedia Commons IPA 자료 (CC BY-SA)',
                    style: TextStyle(fontSize: 9, color: AppColors.sumiLight)),
              ),
            ],
            const SizedBox(height: 14),
            _section('🇺🇸 영어와 비교', '${p.engIpa}\n\n${p.engHow}', color),
            const SizedBox(height: 14),
            _section('🇰🇷 한국어와 비교', '비슷한 소리: ${p.korSim}\n\n${p.korDiff}', color),
          ] else
            const Text('발음 정보가 아직 없어요.',
                style: TextStyle(color: AppColors.sumiLight)),
        ],
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
          Text(title,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  fontSize: 13.5, height: 1.55, color: AppColors.sumi)),
        ],
      ),
    );
  }
}
