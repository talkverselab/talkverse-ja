import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/talky_mascot.dart';
import '../widgets/manga_panel.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/app_background.dart';
import '../widgets/sketchy_divider.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アプリ紹介', style: TextStyle(fontWeight: FontWeight.w700))),
      body: AppBackground(
        scatterSeed: 21,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  const TalkyMascot(mood: TalkyMood.wave, size: 100, showHalo: true),
                  const SizedBox(height: 14),
                  Transform.rotate(
                    angle: -0.02,
                    child: const Text('日本語ユニバース',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 6),
                  SpeechBubble(
                    color: AppColors.honeySoft,
                    child: const Text('만화책 보듯이 일본어 회화를 외우는 앱',
                        style: TextStyle(fontSize: 13, color: AppColors.ink, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SketchyDivider(caption: '✿'),
            _card('🌍 글로비 도감', '학습 진도에 따라 글로비 표정이 바뀝니다. (idle · happy · encouraging · sleep · wave · surprise · sad — 7 단계). 우하단 글로비를 드래그해서 옮길 수 있어요.', -0.5),
            _card('📊 데이터 출처', 'chriskempson 일본 자막 12,277편 빈도 분석 (R1=294어), native_top80 (회화체), hanja_crossref 80 (4-way ja↔zh↔ko), JMultiWOZ task-oriented, RealPersonaChat persona.', 0.3),
            _card('📚 콘텐츠 작성 표준', 'L1 5ep × 40turn = 200turn (narrative) / L2 23dial × 5block = 300turn (카오스 채팅) / L3 ≈ 304turn (사랑 narrative). v4 schema.', -0.2),
            _card('🎯 차별화', '"영어 우회 X" — 한국 화자 한정. 조사·종조사·경어 모두 ko↔ja 1:1 매핑.', 0.4),
            _card('🛠 Stack', 'Flutter 3.41 · Dart 3.11 · go_router · shared_preferences · git local. 옛 ja-lab (Expo SDK 52) 폐기 후 재작성.', -0.3),
            _card('📦 버전', 'v0.5.0 (2026-05-17 글로비 지구본 + 떠다님). 4 덱 265 카드, L1 ep1 작성. M1 ep2-5 + TTS 합성 예정.', 0.2),
            const SizedBox(height: 18),
            Center(
              child: Transform.rotate(
                angle: -0.04,
                child: Text(
                  '🌸 작은 출판사처럼 ✿',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String body, double rotation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MangaPanel(
        rotation: rotation,
        backgroundColor: AppColors.cardFront,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.sakuraDeep, letterSpacing: -0.2)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.ink, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
