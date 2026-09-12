import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kana_hangul_map.dart';
import '../core/l10n.dart';

/// 가나 → 한글독음 변환 + 전역 표시 설정 (모든 메뉴 공용).
class KoReading {
  KoReading._();

  static const _jongN = 4; // ㄴ 받침
  static const _jongS = 19; // ㅅ 받침

  /// 가나 문자열을 한글독음으로 변환.
  /// 'きょうは いい てんき' → '쿄우와 이이 텐키' 식의 학습용 근사 표기.
  /// ん→ㄴ받침, っ→ㅅ받침, ー는 생략. 가나 이외 문자는 그대로 통과.
  static String convert(String kana) {
    final out = StringBuffer();
    String? pending; // 직전 한글 음절 (받침 병합용)
    void flush() {
      if (pending != null) {
        out.write(pending);
        pending = null;
      }
    }

    var i = 0;
    while (i < kana.length) {
      // 요음(2글자) 우선
      String? ko;
      var len = 1;
      if (i + 2 <= kana.length) {
        ko = kanaHangulMap[kana.substring(i, i + 2)];
        if (ko != null) len = 2;
      }
      ko ??= kanaHangulMap[kana[i]];
      if (ko == null) {
        flush();
        out.write(kana[i]);
        i++;
        continue;
      }
      if (ko == 'ㄴ' || ko == 'ㅅ') {
        final jong = ko == 'ㄴ' ? _jongN : _jongS;
        final p = pending;
        if (p != null && p.isNotEmpty) {
          final code = p.codeUnitAt(p.length - 1) - 0xAC00;
          if (code >= 0 && code < 11172 && code % 28 == 0) {
            pending = p.substring(0, p.length - 1) +
                String.fromCharCode(0xAC00 + code + jong);
            i += len;
            continue;
          }
        }
        flush();
        out.write(ko);
      } else if (ko.isEmpty) {
        // 장음 ー 생략
      } else {
        flush();
        pending = ko;
      }
      i += len;
    }
    flush();
    return out.toString();
  }
}

/// 한글독음 표시/숨김 전역 설정.
class KoReadingPrefs {
  KoReadingPrefs._();

  static const _key = 'show_ko_reading';
  static final ValueNotifier<bool> show = ValueNotifier<bool>(true);

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    show.value = p.getBool(_key) ?? true;
  }

  static Future<void> toggle() async {
    show.value = !show.value;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, show.value);
  }
}

/// 앱바용 한글독음 토글 버튼 — 모든 메뉴 공통.
class KoReadingToggleAction extends StatelessWidget {
  const KoReadingToggleAction({super.key});

  @override
  Widget build(BuildContext context) {
    final base = IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    return ValueListenableBuilder<bool>(
      valueListenable: KoReadingPrefs.show,
      builder: (context, on, _) {
        final color = on ? base : base.withValues(alpha: 0.35);
        return IconButton(
          tooltip: on ? tr('한글독음 숨기기') : tr('한글독음 표시'),
          onPressed: KoReadingPrefs.toggle,
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tr('한'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
                decoration: on ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 가나 아래 붙는 한글독음 텍스트 — 전역 설정이 꺼져 있으면 빈 위젯.
class KoReadingText extends StatelessWidget {
  const KoReadingText(
    this.kana, {
    super.key,
    this.style,
    this.textAlign,
  });

  final String kana;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KoReadingPrefs.show,
      builder: (context, on, _) {
        if (!on) return const SizedBox.shrink();
        return Text(KoReading.convert(kana), textAlign: textAlign, style: style);
      },
    );
  }
}
