import 'package:flutter/material.dart';
import '../theme.dart';
import 'talky_character.dart';

/// TalkY mood — 캐릭터 표정 enum (FloatingTalky / TalkyCharacter 양쪽에서 사용).
enum TalkyMood { idle, happy, encouraging, sleep, wave, surprise, sad }

/// Static TalkY — SVG 풍 캐릭터 + 옵션 halo (✿✦❀♡).
class TalkyMascot extends StatelessWidget {
  final TalkyMood mood;
  final double size;
  final bool showHalo;
  const TalkyMascot({super.key, this.mood = TalkyMood.idle, this.size = 80, this.showHalo = false});

  String? get _halo => switch (mood) {
        TalkyMood.happy => '✿',
        TalkyMood.surprise => '✦',
        TalkyMood.encouraging => '❀',
        TalkyMood.wave => '♡',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final core = TalkyCharacter(mood: mood, size: size);
    if (!showHalo || _halo == null) return core;
    return SizedBox(
      width: size * 1.4,
      height: size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          core,
          Positioned(
            top: 0,
            right: size * 0.05,
            child: Text(
              _halo!,
              style: TextStyle(
                fontSize: size * 0.32,
                color: AppColors.sakuraDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
