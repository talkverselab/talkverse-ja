import 'package:flutter/material.dart';

/// 허니와 클로버 (ハチミツとクローバー) 풍 팔레트 — soft edition.
/// - 크림 종이 + 사쿠라 핑크 + 머스타드 + 세이지 + 부드러운 잉크.
/// - 만화책 보는 느낌이지만 두꺼운 검정 대신 연한 회갈색 + watercolor wash.
class AppColors {
  // 종이 배경 — 더 따뜻하게
  static const Color paper = Color(0xFFFBF8F1);
  static const Color paperDeep = Color(0xFFF3EBD7);
  static const Color paperShadow = Color(0xFFE8DFC8);

  // 사쿠라 (벚꽃)
  static const Color sakura = Color(0xFFF8C8D8);
  static const Color sakuraDeep = Color(0xFFE8A8B8);
  static const Color sakuraSoft = Color(0xFFFCE8EF);

  // 머스타드 (Honey)
  static const Color honey = Color(0xFFEDD27A);
  static const Color honeyDeep = Color(0xFFD4A934);
  static const Color honeySoft = Color(0xFFFDF6D9);

  // 세이지 (Clover)
  static const Color clover = Color(0xFFB8D2AE);
  static const Color cloverDeep = Color(0xFF8AB186);
  static const Color cloverSoft = Color(0xFFEAF3E4);

  // 잉크 — 부드러운 회갈색 (no longer pure black)
  static const Color ink = Color(0xFF4A4554);
  static const Color inkSoft = Color(0xFF7A7585);
  static const Color inkLight = Color(0xFFB0ACB8);
  static const Color inkOutline = Color(0xFF8B8294); // 테두리 전용 — 회보라

  // 워터컬러 보조
  static const Color violet = Color(0xFFD4B8D8);
  static const Color cobaltSoft = Color(0xFFC0D0E0);

  // brand 호환
  static const Color brand = sakuraDeep;
  static const Color brandDark = Color(0xFFB87890);
  static const Color brandLight = sakuraSoft;

  // 의미
  static const Color success = cloverDeep;
  static const Color warning = Color(0xFFD4A85A);
  static const Color streak = Color(0xFFE0936C);
  static const Color cardBack = paperDeep;
  static const Color cardFront = Color(0xFFFFFEFB);

  // 덱 컬러
  static const Color deckNative = honey;
  static const Color deckR1 = sakuraDeep;
  static const Color deckKanji = Color(0xFF6B6478); // 잉크보다 옅음
  static const Color deckL1 = clover;
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.sakuraDeep,
          brightness: Brightness.light,
          surface: AppColors.paper,
        ).copyWith(
          primary: AppColors.ink,
          secondary: AppColors.sakuraDeep,
          tertiary: AppColors.honey,
          surface: AppColors.paper,
        ),
        scaffoldBackgroundColor: AppColors.paper,
        fontFamily: 'Noto Sans JP',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.ink, letterSpacing: -0.3),
          displayMedium: TextStyle(color: AppColors.ink, letterSpacing: -0.3),
          headlineLarge: TextStyle(color: AppColors.ink, letterSpacing: -0.2),
          headlineMedium: TextStyle(color: AppColors.ink, letterSpacing: -0.2),
          headlineSmall: TextStyle(color: AppColors.ink),
          titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.ink, height: 1.6),
          bodyMedium: TextStyle(color: AppColors.ink, height: 1.6),
          bodySmall: TextStyle(color: AppColors.inkSoft, height: 1.55),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.cardFront,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.inkOutline, width: 1.2),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.inkLight,
          thickness: 0.8,
          space: 24,
        ),
      );

  static ThemeData get dark => light;
}
