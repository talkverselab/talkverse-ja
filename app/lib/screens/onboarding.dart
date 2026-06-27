import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/talky_mascot.dart';
import '../widgets/manga_panel.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/app_background.dart';
import '../widgets/pressable_scale.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        scatterSeed: 1,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 36),
                const TalkyMascot(mood: TalkyMood.wave, size: 140, showHalo: true),
                const SizedBox(height: 24),
                SpeechBubble(
                  color: AppColors.honey,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text('はじめまして!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ),
                ),
                const SizedBox(height: 24),
                Transform.rotate(
                  angle: -0.02,
                  child: const Text('日本語ユニバース',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: AppColors.ink)),
                ),
                const SizedBox(height: 14),
                MangaPanel(
                  rotation: 0.3,
                  backgroundColor: AppColors.sakuraSoft,
                  padding: const EdgeInsets.all(18),
                  child: const Text(
                    '하루 10장으로 일본어를 외워봐요.\n조사·종조사·한자·실전 대화 — 4 가지 덱.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.ink, height: 1.6, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: PressableScale(
                    onTap: () => context.go('/'),
                    child: MangaPanel(
                      backgroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: const Center(
                        child: Text('始める!',
                            style: TextStyle(color: AppColors.paper, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
