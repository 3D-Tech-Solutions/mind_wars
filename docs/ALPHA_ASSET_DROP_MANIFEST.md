# Alpha Asset Drop Manifest

March 2026

This document defines what is still missing as Mind Wars moves toward alpha testing and gives the exact asset paths and filenames to use when dropping in production-ready brand assets.

Use this with:

- [docs/branding.md](branding.md)
- [docs/branding_rollout_plan.md](branding_rollout_plan.md)
- [docs/games/MIND_WAR_BATTLE_PAYLOAD_SPEC.md](games/MIND_WAR_BATTLE_PAYLOAD_SPEC.md)

## What This Manifest Does And Does Not Define

This manifest is the source of truth for:

- exact repo paths
- canonical filenames
- delivery grouping for alpha
- missing-file tracking

This manifest is not the primary source of truth for the creative look of each asset.

The visual descriptions live in:

- [docs/branding.md](branding.md) for asset-level creative briefs, sizes, and system intent
- [docs/ai_asset_generation_list.md](ai_asset_generation_list.md) for generator-ready prompts, production constraints, and handoff detail

If you need to answer “where does this file go?”, use this manifest.

If you need to answer “what should this asset look like?”, use the branding document and the AI asset generation brief.

## Creative Description Coverage

| Asset Group | Does This Manifest Define The Look? | Primary Description Source | Direct Section Links |
| --- | --- | --- | --- |
| Brand core logos and splash | Partial | [docs/branding.md](branding.md) and [docs/ai_asset_generation_list.md](ai_asset_generation_list.md) | [Batch A](ai_asset_generation_list.md#batch-a-brand-core-and-store-presence) |
| Category badges and hero illustrations | No | [docs/branding.md](branding.md) and [docs/ai_asset_generation_list.md](ai_asset_generation_list.md) | [Batch C](ai_asset_generation_list.md#batch-c-category-system) |
| Onboarding and system illustrations | No | [docs/branding.md](branding.md) and [docs/ai_asset_generation_list.md](ai_asset_generation_list.md) | [Batch D](ai_asset_generation_list.md#batch-d-onboarding-and-system-illustrations) |
| Fonts | No visual brief needed | This manifest for filenames, external font files for the actual typeface | [Fonts](#34-fonts) |
| Game icons | No | [docs/branding.md](branding.md) and [docs/ai_asset_generation_list.md](ai_asset_generation_list.md) | [Batch B](ai_asset_generation_list.md#batch-b-game-icon-suite) |
| In-game alpha widget assets | No | [docs/branding.md](branding.md), then [docs/ai_asset_generation_list.md](ai_asset_generation_list.md) where detailed production specs exist | [Spot the Difference Scene Pairs](ai_asset_generation_list.md#spot-the-difference-scene-pairs), [Focus Finder Clutter Scenes](ai_asset_generation_list.md#focus-finder-clutter-scenes), [Puzzle Race Image Sets](ai_asset_generation_list.md#puzzle-race-image-sets), [Memory Match Symbol Set](ai_asset_generation_list.md#memory-match-symbol-set), [Memory Match Card Back](ai_asset_generation_list.md#memory-match-card-back) |
| Native Android and iOS shell packaging | Yes, structurally | This manifest for file structure and required outputs | [Brand Core](#31-brand-core), [Android Native Shell Exact Files](#6-android-native-shell-exact-files), [iOS Native Shell Exact Structure](#7-ios-native-shell-exact-structure) |

## Quick Creative Lookup

Use this shortcut map when you are in this manifest and need the matching design brief immediately.

- Brand core logos, wordmarks, icon master, splash art: [Batch A](ai_asset_generation_list.md#batch-a-brand-core-and-store-presence)
- All 15 game icons: [Batch B](ai_asset_generation_list.md#batch-b-game-icon-suite)
- Category heroes and category badges: [Batch C](ai_asset_generation_list.md#batch-c-category-system)
- Onboarding slides, empty states, error states, achievement unlock animation: [Batch D](ai_asset_generation_list.md#batch-d-onboarding-and-system-illustrations)
- Default avatars, rank badges, crown overlay, streak flame: [Batch E](ai_asset_generation_list.md#batch-e-profile-and-badge-assets)
- Achievement badges: [Batch F](ai_asset_generation_list.md#batch-f-achievement-badge-set)
- Motion assets: [Batch G](ai_asset_generation_list.md#batch-g-motion-assets)
- Spot the Difference scene sets: [Spot the Difference Scene Pairs](ai_asset_generation_list.md#spot-the-difference-scene-pairs)
- Focus Finder scene sets: [Focus Finder Clutter Scenes](ai_asset_generation_list.md#focus-finder-clutter-scenes)
- Puzzle Race scene sets: [Puzzle Race Image Sets](ai_asset_generation_list.md#puzzle-race-image-sets)
- Memory Match symbols and card back: [Memory Match Symbol Set](ai_asset_generation_list.md#memory-match-symbol-set) and [Memory Match Card Back](ai_asset_generation_list.md#memory-match-card-back)

## 1. What Is Left Before Alpha Testing

The main remaining asset work is not concept creation. It is structured integration.

What is still missing:

1. Flutter asset registration in [pubspec.yaml](../pubspec.yaml) for branding, game, and font files.
2. Native shell branding for Android launcher and splash assets.
3. iOS asset catalog creation, because no `Assets.xcassets` structure is currently committed.
4. App shell replacement of placeholder Material icons and purple gradients in:
   - [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart)
   - [lib/screens/login_screen.dart](../lib/screens/login_screen.dart)
   - [lib/screens/onboarding_screen.dart](../lib/screens/onboarding_screen.dart)
   - [lib/screens/game_selection_screen.dart](../lib/screens/game_selection_screen.dart)
5. Game discovery integration for category and game icons.
6. In-game P1 asset integration for the alpha widgets.
7. Asset QA: missing-file checks, contrast, density validation, and fallback behavior.

For alpha testing, the fastest practical path is:

1. Brand core and shell assets.
2. Category badges and game icons.
3. One P1 asset set per game for the current 15 widgets.
4. Native launcher and splash.

## 2. Naming Rule

Use the existing convention from [docs/branding.md](branding.md#105-naming-convention):

`[type]_[game-or-scope]_[variant]_[size].ext`

Examples used below:

- `logo_mind-wars_mark_1024.png`
- `icon_memory-match_512.png`
- `badge_category_memory_256.png`
- `header_sudoku-duel_750x120.svg`
- `tile_sequence-recall_idle_128.svg`

## 3. Exact Drop Locations For Alpha

## 3.1 Brand Core

Drop these files exactly here:

| Asset | Exact Path |
| --- | --- |
| Logomark SVG | `assets/branding/logos/logo_mind-wars_mark.svg` |
| Logomark PNG master | `assets/branding/logos/logo_mind-wars_mark_1024.png` |
| Wordmark horizontal SVG | `assets/branding/logos/logo_mind-wars_wordmark-horizontal.svg` |
| Wordmark horizontal PNG | `assets/branding/logos/logo_mind-wars_wordmark-horizontal_2048.png` |
| Wordmark stacked SVG | `assets/branding/logos/logo_mind-wars_wordmark-stacked.svg` |
| App icon master PNG | `assets/branding/logos/icon_mind-wars_app_1024.png` |
| Notification mark SVG | `assets/branding/logos/icon_mind-wars_notification.svg` |
| Notification mark PNG | `assets/branding/logos/icon_mind-wars_notification_256.png` |
| Splash artwork portrait Android | `assets/branding/onboarding/splash_mind-wars_android_1080x2340.png` |
| Splash artwork portrait iOS | `assets/branding/onboarding/splash_mind-wars_ios_1290x2796.png` |

## 3.2 Category Assets

| Asset | Exact Path |
| --- | --- |
| Memory category badge | `assets/branding/badges/badge_category_memory_256.png` |
| Logic category badge | `assets/branding/badges/badge_category_logic_256.png` |
| Attention category badge | `assets/branding/badges/badge_category_attention_256.png` |
| Spatial category badge | `assets/branding/badges/badge_category_spatial_256.png` |
| Language category badge | `assets/branding/badges/badge_category_language_256.png` |
| Memory hero illustration | `assets/branding/system/hero_category_memory_1600x800.png` |
| Logic hero illustration | `assets/branding/system/hero_category_logic_1600x800.png` |
| Attention hero illustration | `assets/branding/system/hero_category_attention_1600x800.png` |
| Spatial hero illustration | `assets/branding/system/hero_category_spatial_1600x800.png` |
| Language hero illustration | `assets/branding/system/hero_category_language_1600x800.png` |

## 3.3 Onboarding And Shell

| Asset | Exact Path |
| --- | --- |
| Onboarding slide 1 | `assets/branding/onboarding/illustration_onboarding_play-your-way_1500x2668.png` |
| Onboarding slide 2 | `assets/branding/onboarding/illustration_onboarding_train-your-brain_1500x2668.png` |
| Onboarding slide 3 | `assets/branding/onboarding/illustration_onboarding_challenge-friends_1500x2668.png` |
| Empty state no wars | `assets/branding/system/state_no-wars_400x300.svg` |
| Empty state waiting results | `assets/branding/system/state_waiting-results_400x300.svg` |
| Error state offline | `assets/branding/system/state_offline_400x300.svg` |
| Error state generic | `assets/branding/system/state_generic-error_400x300.svg` |
| Achievement modal animation | `assets/branding/system/anim_achievement-unlock_400.json` |

## 3.4 Fonts

Drop the exact font files here:

| Font | Exact Path |
| --- | --- |
| Orbitron Regular | `assets/fonts/Orbitron-Regular.ttf` |
| Orbitron Bold | `assets/fonts/Orbitron-Bold.ttf` |
| Space Mono Regular | `assets/fonts/SpaceMono-Regular.ttf` |
| Space Mono Bold | `assets/fonts/SpaceMono-Bold.ttf` |

## 4. Exact Game Icon Filenames

These are the canonical filenames to use for alpha game discovery and selection surfaces.

### Memory

- `assets/branding/icons/icon_memory-match.svg`
- `assets/branding/icons/icon_memory-match_512.png`
- `assets/branding/icons/icon_memory-match_1024.png`
- `assets/branding/icons/icon_sequence-recall.svg`
- `assets/branding/icons/icon_sequence-recall_512.png`
- `assets/branding/icons/icon_sequence-recall_1024.png`
- `assets/branding/icons/icon_pattern-memory.svg`
- `assets/branding/icons/icon_pattern-memory_512.png`
- `assets/branding/icons/icon_pattern-memory_1024.png`

### Logic

- `assets/branding/icons/icon_sudoku-duel.svg`
- `assets/branding/icons/icon_sudoku-duel_512.png`
- `assets/branding/icons/icon_sudoku-duel_1024.png`
- `assets/branding/icons/icon_logic-grid.svg`
- `assets/branding/icons/icon_logic-grid_512.png`
- `assets/branding/icons/icon_logic-grid_1024.png`
- `assets/branding/icons/icon_code-breaker.svg`
- `assets/branding/icons/icon_code-breaker_512.png`
- `assets/branding/icons/icon_code-breaker_1024.png`

### Attention

- `assets/branding/icons/icon_spot-the-difference.svg`
- `assets/branding/icons/icon_spot-the-difference_512.png`
- `assets/branding/icons/icon_spot-the-difference_1024.png`
- `assets/branding/icons/icon_color-rush.svg`
- `assets/branding/icons/icon_color-rush_512.png`
- `assets/branding/icons/icon_color-rush_1024.png`
- `assets/branding/icons/icon_focus-finder.svg`
- `assets/branding/icons/icon_focus-finder_512.png`
- `assets/branding/icons/icon_focus-finder_1024.png`

### Spatial

- `assets/branding/icons/icon_puzzle-race.svg`
- `assets/branding/icons/icon_puzzle-race_512.png`
- `assets/branding/icons/icon_puzzle-race_1024.png`
- `assets/branding/icons/icon_rotation-master.svg`
- `assets/branding/icons/icon_rotation-master_512.png`
- `assets/branding/icons/icon_rotation-master_1024.png`
- `assets/branding/icons/icon_path-finder.svg`
- `assets/branding/icons/icon_path-finder_512.png`
- `assets/branding/icons/icon_path-finder_1024.png`

### Language

- `assets/branding/icons/icon_word-builder.svg`
- `assets/branding/icons/icon_word-builder_512.png`
- `assets/branding/icons/icon_word-builder_1024.png`
- `assets/branding/icons/icon_anagram-attack.svg`
- `assets/branding/icons/icon_anagram-attack_512.png`
- `assets/branding/icons/icon_anagram-attack_1024.png`
- `assets/branding/icons/icon_vocabulary-showdown.svg`
- `assets/branding/icons/icon_vocabulary-showdown_512.png`
- `assets/branding/icons/icon_vocabulary-showdown_1024.png`

## 5. Exact Alpha Game Asset Filenames

These are the first in-game asset files to drop for the current alpha widgets.

## 5.1 Memory

- `assets/games/memory/memory-match/header_memory-match_750x120.svg`
- `assets/games/memory/memory-match/card-back_memory-match_512.svg`
- `assets/games/memory/memory-match/texture_memory-match-board_1080x1920.png`
- `assets/games/memory/sequence-recall/header_sequence-recall_750x120.svg`
- `assets/games/memory/sequence-recall/tile_sequence-recall_idle_128.svg`
- `assets/games/memory/sequence-recall/tile_sequence-recall_lit_128.svg`
- `assets/games/memory/sequence-recall/tile_sequence-recall_correct_128.svg`
- `assets/games/memory/sequence-recall/tile_sequence-recall_wrong_128.svg`
- `assets/games/memory/pattern-memory/header_pattern-memory_750x120.svg`
- `assets/games/memory/pattern-memory/tile_pattern-memory_filled_96.svg`
- `assets/games/memory/pattern-memory/tile_pattern-memory_empty_96.svg`
- `assets/games/memory/pattern-memory/tile_pattern-memory_player_96.svg`
- `assets/games/memory/pattern-memory/tile_pattern-memory_error_96.svg`

## 5.2 Logic

- `assets/games/logic/sudoku-duel/header_sudoku-duel_750x120.svg`
- `assets/games/logic/sudoku-duel/grid_sudoku-duel_background_750.svg`
- `assets/games/logic/sudoku-duel/cell_sudoku-duel_clue_72.svg`
- `assets/games/logic/sudoku-duel/cell_sudoku-duel_player_72.svg`
- `assets/games/logic/sudoku-duel/cell_sudoku-duel_error_72.svg`
- `assets/games/logic/sudoku-duel/cell_sudoku-duel_hint_72.svg`
- `assets/games/logic/logic-grid/header_logic-grid_750x120.svg`
- `assets/games/logic/logic-grid/cell_logic-grid_true_80.svg`
- `assets/games/logic/logic-grid/cell_logic-grid_false_80.svg`
- `assets/games/logic/logic-grid/cell_logic-grid_empty_80.svg`
- `assets/games/logic/code-breaker/header_code-breaker_750x120.svg`
- `assets/games/logic/code-breaker/peg_code-breaker_empty_64.svg`
- `assets/games/logic/code-breaker/feedback_code-breaker_exact_32.svg`
- `assets/games/logic/code-breaker/feedback_code-breaker_color_32.svg`
- `assets/games/logic/code-breaker/feedback_code-breaker_none_32.svg`
- `assets/games/logic/code-breaker/panel_code-breaker_shield_280x80.svg`

## 5.3 Attention

- `assets/games/attention/spot-the-difference/header_spot-the-difference_750x120.svg`
- `assets/games/attention/spot-the-difference/marker_spot-the-difference_found_64.svg`
- `assets/games/attention/spot-the-difference/marker_spot-the-difference_wrong_64.svg`
- `assets/games/attention/color-rush/header_color-rush_750x120.svg`
- `assets/games/attention/focus-finder/header_focus-finder_750x120.svg`
- `assets/games/attention/focus-finder/marker_focus-finder_target_64.svg`
- `assets/games/attention/focus-finder/marker_focus-finder_found_64.svg`

## 5.4 Spatial

- `assets/games/spatial/puzzle-race/header_puzzle-race_750x120.svg`
- `assets/games/spatial/rotation-master/header_rotation-master_750x120.svg`
- `assets/games/spatial/path-finder/header_path-finder_750x120.svg`
- `assets/games/spatial/path-finder/tile_path-finder_wall_64.svg`
- `assets/games/spatial/path-finder/tile_path-finder_floor_64.svg`
- `assets/games/spatial/path-finder/tile_path-finder_player_64.svg`
- `assets/games/spatial/path-finder/tile_path-finder_goal_64.svg`

## 5.5 Language

- `assets/games/language/word-builder/header_word-builder_750x120.svg`
- `assets/games/language/anagram-attack/header_anagram-attack_750x120.svg`
- `assets/games/language/vocabulary-showdown/header_vocabulary-showdown_750x120.svg`

## 6. Android Native Shell Exact Files

Replace these exact files directly:

- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

If you also want native Android splash artwork, add:

- `android/app/src/main/res/mipmap-mdpi/launch_image.png`
- `android/app/src/main/res/mipmap-hdpi/launch_image.png`
- `android/app/src/main/res/mipmap-xhdpi/launch_image.png`
- `android/app/src/main/res/mipmap-xxhdpi/launch_image.png`
- `android/app/src/main/res/mipmap-xxxhdpi/launch_image.png`

Then [android/app/src/main/res/drawable/launch_background.xml](../android/app/src/main/res/drawable/launch_background.xml) can be switched to reference `@mipmap/launch_image`.

## 7. iOS Native Shell Exact Structure

The repo does not currently include an iOS asset catalog, so create this structure exactly:

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`

For alpha, that is enough to establish a valid app icon set on iOS once the asset catalog is created.

## 8. Recommended Alpha Delivery Order

If you have a lot of finished assets already, drop them in this order:

1. Brand core logos and splash art.
2. Android launcher icons.
3. Fonts.
4. 15 game icons.
5. 5 category badges and 5 hero images.
6. Onboarding illustrations and system states.
7. One P1 asset set per game widget.

## 9. What To Send Me Next

When you are ready for integration, send either:

1. A list of the assets you already have, matched against the exact filenames above.
2. A zip or staged drop using these exact paths.
3. The first batch only, starting with brand core plus the 15 game icons.

That is enough for the next integration pass.