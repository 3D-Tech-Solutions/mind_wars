import 'package:flutter/material.dart';

import 'brand_tokens.dart';

/// [2026-03-14 Feature] Centralized theme factory for the Mind Wars brand rollout.
///
/// This theme layer replaces ad hoc seeded theme generation with explicit brand
/// tokens while keeping the rest of the application stable. Screens can migrate
/// to the full visual system in phases without redefining colors and component
/// styles in multiple files.
class MindWarsBrandTheme {
  MindWarsBrandTheme._();

  static ThemeData lightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: MindWarsBrandTokens.mwCyan,
      onPrimary: MindWarsBrandTokens.mwVoid,
      secondary: MindWarsBrandTokens.mwCoral,
      onSecondary: MindWarsBrandTokens.mwText,
      error: MindWarsBrandTokens.mwCoral,
      onError: MindWarsBrandTokens.mwText,
      surface: Color(0xFFF4F6FF),
      onSurface: MindWarsBrandTokens.mwDeep,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F8FF),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFF7F8FF),
        foregroundColor: MindWarsBrandTokens.mwDeep,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: MindWarsBrandTokens.mwCyan,
          foregroundColor: MindWarsBrandTokens.mwVoid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: MindWarsBrandTokens.mwLine),
          foregroundColor: MindWarsBrandTokens.mwDeep,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFD8DEFF)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8DEFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8DEFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MindWarsBrandTokens.mwCyan, width: 2),
        ),
      ),
      textTheme: _baseTextTheme(Brightness.light),
    );
  }

  static ThemeData darkTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: MindWarsBrandTokens.mwCyan,
      onPrimary: MindWarsBrandTokens.mwVoid,
      secondary: MindWarsBrandTokens.mwCoral,
      onSecondary: MindWarsBrandTokens.mwText,
      error: MindWarsBrandTokens.mwCoral,
      onError: MindWarsBrandTokens.mwText,
      surface: MindWarsBrandTokens.mwSurface,
      onSurface: MindWarsBrandTokens.mwText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MindWarsBrandTokens.mwVoid,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: MindWarsBrandTokens.mwVoid,
        foregroundColor: MindWarsBrandTokens.mwText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: MindWarsBrandTokens.mwCyan,
          foregroundColor: MindWarsBrandTokens.mwVoid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(120, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: MindWarsBrandTokens.mwLine),
          foregroundColor: MindWarsBrandTokens.mwText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: MindWarsBrandTokens.mwDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: MindWarsBrandTokens.mwLine),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MindWarsBrandTokens.mwDeep,
        labelStyle: const TextStyle(color: MindWarsBrandTokens.mwMuted),
        hintStyle: const TextStyle(color: MindWarsBrandTokens.mwMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MindWarsBrandTokens.mwLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MindWarsBrandTokens.mwLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MindWarsBrandTokens.mwCyan, width: 2),
        ),
      ),
      textTheme: _baseTextTheme(Brightness.dark),
    );
  }

  /// [2026-03-14 Feature] Shared loading surface used before the app finishes bootstrapping.
  static const BoxDecoration loadingBackgroundDecoration = BoxDecoration(
    color: MindWarsBrandTokens.mwVoid,
  );

  static TextTheme _baseTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color headingColor = isDark ? MindWarsBrandTokens.mwText : MindWarsBrandTokens.mwDeep;
    final Color bodyColor = isDark ? MindWarsBrandTokens.mwText : MindWarsBrandTokens.mwDeep;
    final Color mutedColor = isDark ? MindWarsBrandTokens.mwMuted : const Color(0xFF4E5684);

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: headingColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: headingColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: headingColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: headingColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: headingColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: bodyColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: bodyColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
    );
  }
}