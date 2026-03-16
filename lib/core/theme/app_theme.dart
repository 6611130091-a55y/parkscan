// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const maroon         = Color(0xFF6B0F1A);
  static const maroonLight    = Color(0xFF8B1A28);
  static const maroonDark     = Color(0xFF4A0A12);
  static const paleBrown      = Color(0xFFD4B8A8);
  static const paleBrownLight = Color(0xFFEAD9CE);
  static const paleBrownDark  = Color(0xFFB89880);
  static const cream          = Color(0xFFFAF5F0);
  static const warmWhite      = Color(0xFFF5EDE5);
  static const charcoal       = Color(0xFF2C2420);
  static const warmGray       = Color(0xFF8C7B74);
  static const divider        = Color(0xFFE8D8CC);
  static const darkBg         = Color(0xFF1A1210);
  static const darkSurface    = Color(0xFF2A1E1A);
  static const darkSurface2   = Color(0xFF3A2A24);
  static const catShopping    = Color(0xFF6B0F1A);
  static const catRestaurant  = Color(0xFFB85C2A);
  static const catBeverage    = Color(0xFF7A9E7E);
  static const success        = Color(0xFF4A7C59);
  static const warning        = Color(0xFFB8860B);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Sarabun',
    colorScheme: const ColorScheme.light(
      primary: AppColors.maroon,
      onPrimary: Colors.white,
      secondary: AppColors.paleBrown,
      onSecondary: AppColors.charcoal,
      surface: AppColors.cream,
      onSurface: AppColors.charcoal,
      surfaceContainerHighest: AppColors.warmWhite,
      outline: AppColors.divider,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.maroon,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Sarabun',
        fontSize: 18, fontWeight: FontWeight.w600,
        color: Colors.white, letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.warmWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(fontFamily: 'Sarabun', fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.maroon,
        side: const BorderSide(color: AppColors.maroon, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.warmWhite,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.maroon, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
      labelStyle: const TextStyle(color: AppColors.warmGray),
      hintStyle: const TextStyle(color: AppColors.warmGray),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.warmWhite,
      selectedItemColor: AppColors.maroon,
      unselectedItemColor: AppColors.warmGray,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontFamily: 'Sarabun', fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontFamily: 'Sarabun', fontSize: 12),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Sarabun',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.paleBrown,
      onPrimary: AppColors.charcoal,
      secondary: AppColors.maroonLight,
      onSecondary: Colors.white,
      surface: AppColors.darkBg,
      onSurface: Color(0xFFF0E6DF),
      surfaceContainerHighest: AppColors.darkSurface,
      outline: AppColors.darkSurface2,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Color(0xFFF0E6DF),
      elevation: 0, centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'Sarabun', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFF0E6DF)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkSurface2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroonLight, foregroundColor: Colors.white,
        elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.darkSurface2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkSurface2)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.darkSurface2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.paleBrown, width: 2)),
      labelStyle: const TextStyle(color: AppColors.warmGray),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.paleBrown,
      unselectedItemColor: AppColors.warmGray,
      elevation: 8, type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontFamily: 'Sarabun', fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontFamily: 'Sarabun', fontSize: 12),
    ),
  );
}
