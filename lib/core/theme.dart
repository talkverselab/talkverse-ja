import 'package:flutter/material.dart';

/// 和風 컬러 팔레트 — 紅 · 藍 · 金 · 墨 · 和紙 · 抹茶 · 桜
class AppColors {
  // 主色 — 紅 (beni, 일장기 빨강·토리이)
  static const Color beni = Color(0xFFBC002D);
  static const Color beniDeep = Color(0xFF8E0022);
  static const Color beniLight = Color(0xFFE24A5F);

  // 副色 — 藍 (ai, 인디고 염색·노렌)
  static const Color ai = Color(0xFF274A78);
  static const Color aiDeep = Color(0xFF16324F);
  static const Color aiLight = Color(0xFF6E8FBF);

  // 金 (kin, 병풍·마키에)
  static const Color kin = Color(0xFFC9A227);
  static const Color kinBright = Color(0xFFE8C547);
  static const Color kinDeep = Color(0xFF8A6D1E);

  // 墨 (sumi, 먹·서예)
  static const Color sumi = Color(0xFF1E1B1A);
  static const Color sumiLight = Color(0xFF4B4643);

  // 和紙 (washi, 미색 배경)
  static const Color washi = Color(0xFFFBF7EC);
  static const Color washiDeep = Color(0xFFF1E9D6);

  // 抹茶 (matcha, 성공·완료)
  static const Color matcha = Color(0xFF6E9B3B);

  // 桜 (sakura, 보조 강조)
  static const Color sakura = Color(0xFFF4B6C2);
  static const Color sakuraDeep = Color(0xFFD9748A);

  // 가나 행 컬러 (50음도 시각 학습용)
  static const Color kanaVowel = Color(0xFFE53935);
  static const Color kanaK = Color(0xFFFB8C00);
  static const Color kanaS = Color(0xFFFDD835);
  static const Color kanaT = Color(0xFF43A047);
  static const Color kanaN = Color(0xFF00ACC1);
  static const Color kanaH = Color(0xFF1E88E5);
  static const Color kanaM = Color(0xFF5E35B1);
  static const Color kanaY = Color(0xFF8E24AA);
  static const Color kanaR = Color(0xFFD81B60);
  static const Color kanaW = Color(0xFF6D4C41);

  // brand alias
  static const Color brand = beni;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.beni,
        onPrimary: AppColors.washi,
        primaryContainer: AppColors.beniLight,
        onPrimaryContainer: AppColors.sumi,
        secondary: AppColors.ai,
        onSecondary: AppColors.washi,
        secondaryContainer: AppColors.aiLight,
        onSecondaryContainer: AppColors.sumi,
        tertiary: AppColors.matcha,
        onTertiary: AppColors.washi,
        tertiaryContainer: const Color(0xFFD5E6BE),
        onTertiaryContainer: AppColors.sumi,
        error: const Color(0xFFB00020),
        onError: Colors.white,
        surface: AppColors.washi,
        onSurface: AppColors.sumi,
        surfaceContainerHighest: AppColors.washiDeep,
        onSurfaceVariant: AppColors.sumiLight,
        outline: AppColors.kinDeep,
        outlineVariant: const Color(0xFFDCCFB0),
      ),
      scaffoldBackgroundColor: AppColors.washi,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.washi,
        foregroundColor: AppColors.sumi,
        titleTextStyle: TextStyle(
          color: AppColors.sumi,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.washi,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.kin, width: 0.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.sumi,
        indicatorColor: AppColors.beni,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? AppColors.kinBright : AppColors.washiDeep,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.washi : AppColors.washiDeep,
            size: 24,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.washiDeep,
        labelStyle: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.kin),
        selectedColor: AppColors.beni,
        secondaryLabelStyle: const TextStyle(color: AppColors.washi),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.kin, thickness: 0.5),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.beni,
        textColor: AppColors.sumi,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.beni,
        brightness: Brightness.dark,
      ),
    );
  }
}

/// 50음도 행(行) 인덱스 → 색
Color kanaRowColor(int row) {
  const colors = [
    AppColors.kanaVowel,
    AppColors.kanaK,
    AppColors.kanaS,
    AppColors.kanaT,
    AppColors.kanaN,
    AppColors.kanaH,
    AppColors.kanaM,
    AppColors.kanaY,
    AppColors.kanaR,
    AppColors.kanaW,
  ];
  return colors[row % colors.length];
}
