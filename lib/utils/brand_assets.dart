import 'package:flutter/material.dart';

import '../models/models.dart';

/// [2026-03-16 Integration] Centralized branded asset and color mapping.
///
/// Keeps asset paths and category colors in one place so imported brand files
/// can be used consistently across the app shell and gameplay discovery UI.
class BrandAssets {
  static const String logomark =
      'assets/branding/logos/logo_mind-wars_mark.svg';
  static const String wordmarkHorizontal =
      'assets/branding/logos/logo_mind-wars_wordmark-horizontal.svg';
  static const String wordmarkStacked =
      'assets/branding/logos/logo_mind-wars_wordmark-stacked.svg';
  static const String splashAndroid =
      'assets/branding/onboarding/splash_mind-wars_android_1080x2340.png';
  static const String splashIos =
      'assets/branding/onboarding/splash_mind-wars_ios_1290x2796.png';
  static const String crownOverlay =
      'assets/branding/badges/overlay_big-brain-crown_128.png';
  static const String streakFlame =
      'assets/branding/badges/icon_streak-flame_64.png';

  /// [2026-03-16 Integration] Returns the canonical category badge asset.
  static String categoryBadge(CognitiveCategory category) {
    switch (category) {
      case CognitiveCategory.memory:
        return 'assets/branding/badges/badge_category_memory_256.png';
      case CognitiveCategory.logic:
        return 'assets/branding/badges/badge_category_logic_256.png';
      case CognitiveCategory.attention:
        return 'assets/branding/badges/badge_category_attention_256.png';
      case CognitiveCategory.spatial:
        return 'assets/branding/badges/badge_category_spatial_256.png';
      case CognitiveCategory.language:
        return 'assets/branding/badges/badge_category_language_256.png';
    }
  }

  /// [2026-03-16 Integration] Returns the canonical category hero art.
  static String categoryHero(CognitiveCategory category) {
    switch (category) {
      case CognitiveCategory.memory:
        return 'assets/branding/system/hero_category_memory_1600x800.png';
      case CognitiveCategory.logic:
        return 'assets/branding/system/hero_category_logic_1600x800.png';
      case CognitiveCategory.attention:
        return 'assets/branding/system/hero_category_attention_1600x800.png';
      case CognitiveCategory.spatial:
        return 'assets/branding/system/hero_category_spatial_1600x800.png';
      case CognitiveCategory.language:
        return 'assets/branding/system/hero_category_language_1600x800.png';
    }
  }

  /// [2026-03-16 Integration] Returns the imported PNG icon for a game.
  static String? gameIcon(String templateId) {
    switch (templateId) {
      case 'memory_match':
        return 'assets/branding/icons/icon_memory-match_512.png';
      case 'sequence_recall':
        return 'assets/branding/icons/icon_sequence-recall_512.png';
      case 'pattern_memory':
        return 'assets/branding/icons/icon_pattern-memory_512.png';
      case 'sudoku_duel':
        return 'assets/branding/icons/icon_sudoku-duel_512.png';
      case 'logic_grid':
        return 'assets/branding/icons/icon_logic-grid_512.png';
      case 'code_breaker':
        return 'assets/branding/icons/icon_code-breaker_512.png';
      case 'spot_difference':
        return 'assets/branding/icons/icon_spot-the-difference_512.png';
      case 'focus_finder':
        return 'assets/branding/icons/icon_focus-finder_512.png';
      case 'puzzle_race':
        return 'assets/branding/icons/icon_puzzle-race_512.png';
      case 'rotation_master':
        return 'assets/branding/icons/icon_rotation-master_512.png';
      case 'path_finder':
        return 'assets/branding/icons/icon_path-finder_512.png';
      case 'word_builder':
        return 'assets/branding/icons/icon_word-builder_512.png';
      case 'anagram_attack':
        return 'assets/branding/icons/icon_anagram-attack_512.png';
      case 'vocabulary_showdown':
        return 'assets/branding/icons/icon_vocabulary-showdown_512.png';
      default:
        return null;
    }
  }

  /// [2026-03-16 Integration] Provides the imported branded avatar paths.
  static String defaultAvatar(int index) {
    final normalizedIndex = index.clamp(1, 60);
    return 'assets/branding/avatars/avatar_default_${normalizedIndex.toString().padLeft(2, '0')}.svg';
  }

  /// [2026-03-16 Integration] Returns the category accent color for UI chrome.
  static Color categoryColor(CognitiveCategory category) {
    switch (category) {
      case CognitiveCategory.memory:
        return const Color(0xFF9333EA);
      case CognitiveCategory.logic:
        return const Color(0xFF2563EB);
      case CognitiveCategory.attention:
        return const Color(0xFF0891B2);
      case CognitiveCategory.spatial:
        return const Color(0xFFD97706);
      case CognitiveCategory.language:
        return const Color(0xFFDC2626);
    }
  }

  /// [2026-03-16 Integration] Shared dark surface palette for brand-led screens.
  static const Color voidBlack = Color(0xFF090A12);
  static const Color deepNavy = Color(0xFF0E1028);
  static const Color surface = Color(0xFF14183A);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color coral = Color(0xFFE94560);
  static const Color text = Color(0xFFEEF0FC);
}