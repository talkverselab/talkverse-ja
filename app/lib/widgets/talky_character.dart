import 'package:flutter/material.dart';
import 'talky_mascot.dart' show TalkyMood;

/// 글로비 — 사용자 제공 PNG 12 표현 그대로.
/// app/assets/png/characters/character_NN_name.png
class TalkyCharacter extends StatelessWidget {
  final TalkyMood mood;
  final double size;
  const TalkyCharacter({super.key, this.mood = TalkyMood.idle, this.size = 80});

  // 12 표현 — 추출된 PNG 파일명
  // 1 happy 행복 / 2 excited 신남 / 3 worried 고민 / 4 surprise 놀람
  // 5 angry 화남 / 6 annoyed 짜증 / 7 sad 슬픔 / 8 gaveup 포기
  // 9 shy 부끄러움 / 10 meltdown 멘붕 / 11 confident 자신감 / 12 proud 뿌듯
  static const Map<TalkyMood, String> _moodAsset = {
    TalkyMood.idle: 'assets/png/characters/character_01_happy.png',
    TalkyMood.happy: 'assets/png/characters/character_12_proud.png',       // 뿌듯
    TalkyMood.encouraging: 'assets/png/characters/character_02_excited.png', // 신남
    TalkyMood.wave: 'assets/png/characters/character_11_confident.png',    // 자신감
    TalkyMood.surprise: 'assets/png/characters/character_04_surprise.png', // 놀람
    TalkyMood.sleep: 'assets/png/characters/character_08_gaveup.png',      // 포기 (눈 감음 비슷)
    TalkyMood.sad: 'assets/png/characters/character_07_sad.png',           // 슬픔
  };

  @override
  Widget build(BuildContext context) {
    final asset = _moodAsset[mood] ?? _moodAsset[TalkyMood.idle]!;
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
