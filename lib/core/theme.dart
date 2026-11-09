import 'package:flutter/material.dart';

/// 컬러 팔레트 — talkverse.uk 일본어 페이지 톤(2026-11-01, 사용자 지시).
///
/// 기준 = https://talkverse.uk/talkverse/lang/ja 의 「일본어」 워드마크: 흰 바탕 + 남색 글자에
/// 구리(`#b77548`) → 황갈(`#c19e6d`) 그라데이션 포인트(사이트 `--a: #e88b4a`·`--a2: #f5c07a` 의 잉크판).
/// 이름(beni·ai·kin·sumi·washi…)은 옛 和風 팔레트에서 온 것이라 화면 코드가 그대로 쓰고, 값만 바꿨다.
class AppColors {
  // 主色 — 옛 紅 자리. 워드마크 구리색
  static const Color beni = Color(0xFFB77548);
  static const Color beniDeep = Color(0xFF9A5F38);
  static const Color beniLight = Color(0xFFE88B4A); // 사이트 `--a`

  // 副色 — 옛 藍 자리. 사이트 `--accent` 인디고(링크·보조 강조·화자 A)
  static const Color ai = Color(0xFF635BFF);
  static const Color aiDeep = Color(0xFF4B44D6);
  static const Color aiLight = Color(0xFFA9A4FF);

  // 옛 金 자리 — 테두리는 사이트 `--line` 계열, 밝은 강조는 `--a2` 금빛, 진한 쪽은 워드마크 황갈
  static const Color kin = Color(0xFFDDE3EC);
  static const Color kinBright = Color(0xFFF5C07A);
  static const Color kinDeep = Color(0xFFC19E6D);

  // 墨 — 사이트 `--ink` / `--body`
  static const Color sumi = Color(0xFF0A2540);
  static const Color sumiLight = Color(0xFF425466);

  // 和紙 — 흰 바탕 / `--soft`
  static const Color washi = Color(0xFFFFFFFF);
  static const Color washiDeep = Color(0xFFF6F9FC);

  // 抹茶 — 완료·학습됨(사이트 `--ok`)
  static const Color matcha = Color(0xFF0E6245);

  // 桜 — 보조 강조(사이트 메시 분홍 / `--danger` 장미색)
  static const Color sakura = Color(0xFFF5B8E6);
  static const Color sakuraDeep = Color(0xFFCD3D64);

  // 사이트 토큰 그대로
  static const Color line = Color(0xFFE6EBF1);
  static const Color muted = Color(0xFF627389); // 흰 바탕 대비 4.85:1(AA, 출시 점검 2026-11-09 — 이전 6B7C93 은 4.26)

  // 가나 행 컬러 (50음도 시각 학습용) — 학습 의미가 있어 그대로
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

  /// 「일본어」 워드마크 그라데이션(왼쪽 구리 → 오른쪽 황갈). 제목 글자·도장·구분선에 쓴다.
  static const LinearGradient wordmark = LinearGradient(colors: [beni, kinDeep]);
}

/// 카드·타일 공통 그림자(사이트 `0 2px 5px -1px rgba(50,50,93,.1), 0 1px 3px -1px rgba(0,0,0,.1)`)
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0x1A32325D), blurRadius: 5, offset: Offset(0, 2)),
  BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
];

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.beni,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFF8E8D8),
        onPrimaryContainer: AppColors.sumi,
        secondary: AppColors.ai,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFEFEEFE),
        onSecondaryContainer: AppColors.sumi,
        tertiary: AppColors.matcha,
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFD5EADF),
        onTertiaryContainer: AppColors.sumi,
        error: AppColors.sakuraDeep,
        onError: Colors.white,
        surface: AppColors.washi,
        onSurface: AppColors.sumi,
        surfaceContainerHighest: AppColors.washiDeep,
        onSurfaceVariant: AppColors.sumiLight,
        outline: AppColors.muted,
        outlineVariant: AppColors.line,
      ),
      scaffoldBackgroundColor: AppColors.washi,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.washi,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.sumi,
        shape: Border(bottom: BorderSide(color: AppColors.line)),
        titleTextStyle: TextStyle(
          color: AppColors.sumi,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.washi,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.washi,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFF8E8D8),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? AppColors.beni : AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.beniDeep : AppColors.muted,
            size: 24,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.washiDeep,
        labelStyle: const TextStyle(color: AppColors.sumiLight, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        selectedColor: const Color(0xFFF8E8D8),
        secondaryLabelStyle: const TextStyle(color: AppColors.beniDeep),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.beni,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sumi,
          side: const BorderSide(color: AppColors.line),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.beni,
        textColor: AppColors.sumi,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.washi,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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

/// 두 화면(왼쪽 목록 | 오른쪽 내용) 기준 — 가로 720 논리픽셀 이상: 아이패드(세로·가로)·안드로이드 태블릿·
/// 갤럭시/아이폰 폴드 펼침(세로 ≈740 포함). 접은 폴드·일반 폰은 한 화면. 한자유니버스와 같은 기준(사용자 지시 2026-11-01).
const wideMin = 720.0;
bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= wideMin;
