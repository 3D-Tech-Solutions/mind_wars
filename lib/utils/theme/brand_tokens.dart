import 'package:flutter/material.dart';

/// [2026-03-14 Feature] Centralized Mind Wars brand token definitions.
///
/// This file provides a single source of truth for the documented brand
/// palette and planned typography families so rollout work can replace
/// placeholder values incrementally without scattering constants across
/// screens and widgets.
class MindWarsBrandTokens {
  MindWarsBrandTokens._();

  static const Color mwVoid = Color(0xFF090A12);
  static const Color mwDeep = Color(0xFF0E1028);
  static const Color mwSurface = Color(0xFF14183A);
  static const Color mwLine = Color(0xFF1A2050);
  static const Color mwCyan = Color(0xFF00D4FF);
  static const Color mwCoral = Color(0xFFE94560);
  static const Color mwGold = Color(0xFFFFB800);
  static const Color mwPurple = Color(0xFF7C3AED);
  static const Color mwText = Color(0xFFEEF0FC);
  static const Color mwMuted = Color(0xFF6868A0);

  /// [2026-03-14 Feature] Planned font family names for later asset wiring.
  ///
  /// The actual font files are not committed yet, so rollout work should add
  /// the assets and pubspec registrations before depending on these names.
  static const String orbitronFontFamily = 'Orbitron';
  static const String spaceMonoFontFamily = 'Space Mono';
}

/// [2026-03-14 Feature] Category-specific palette tokens for staged rollout.
///
/// The category colors are separated from the global palette so game selection,
/// headers, badges, and game-specific widgets can migrate independently.
class MindWarsCategoryTokens {
  MindWarsCategoryTokens._();

  static const Color memory = Color(0xFF9333EA);
  static const Color memoryLight = Color(0xFFC084FC);
  static const Color memoryBackground = Color(0xFF1A0830);

  static const Color logic = Color(0xFF2563EB);
  static const Color logicLight = Color(0xFF60A5FA);
  static const Color logicBackground = Color(0xFF081430);

  static const Color attention = Color(0xFF0891B2);
  static const Color attentionLight = Color(0xFF22D3EE);
  static const Color attentionBackground = Color(0xFF041820);

  static const Color spatial = Color(0xFFD97706);
  static const Color spatialLight = Color(0xFFFCD34D);
  static const Color spatialBackground = Color(0xFF1A1204);

  static const Color language = Color(0xFFDC2626);
  static const Color languageLight = Color(0xFFF87171);
  static const Color languageBackground = Color(0xFF200608);
}