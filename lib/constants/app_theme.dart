import 'package:flutter/material.dart';

class AppThemeConstants {
  static const String defaultThemeId = 'neo-brutalist';

  static const Color primaryColor = Colors.black;
  static const Color backgroundColor = Color(0xFFF9F9F9);
  static const Color surfaceColor = Colors.white;
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowest = Color(0xFFFDFDFD);
  static const Color tertiaryFixed = Color(0xFF72FF70);
  static const Color secondaryFixed = Color(0xFFEAEA00);
  static const Color quarterFixed = Color(0xFFFF1100);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onSurfaceVariant = Color(0xFF4C4546);
  static const Color onTertiaryFixed = Color(0xFF002203);
  static const Color successColor = Colors.green;

  static List<BoxShadow> get neoShadow => const [
    BoxShadow(
      color: Colors.black,
      offset: Offset(6, 6),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get neoShadowSm => const [
    BoxShadow(
      color: Colors.black,
      offset: Offset(4, 4),
      blurRadius: 0,
      spreadRadius: 0,
    ),
  ];

  static ThemeData buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      surface: surfaceColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: Typography.material2021().black.apply(
        bodyColor: primaryColor,
        displayColor: primaryColor,
      ),
    );
  }
}
