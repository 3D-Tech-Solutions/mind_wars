# Branding Rollout Plan

March 2026

This plan converts the branding audit into an execution sequence for the next implementation phase. It is intended to work alongside [branding.md](branding.md) and [branding_integration_checklist.md](branding_integration_checklist.md).

## Goal

Establish the Mind Wars brand system in the app without mixing foundational work, native shell work, and game-specific asset rollout into the same change set.

## Current Starting Point

- The repo has the application flows needed for branding rollout.
- The repo does not yet have a committed brand asset library.
- Android launcher and splash hooks exist, but they still use placeholders.
- Flutter currently relies on generic Material icons, emoji placeholders, and a seeded purple theme.

## Phase 1: Foundation

**Objective:** Create stable branding primitives before changing user-facing screens.

### Deliverables

- Centralized brand color tokens.
- Centralized Flutter theme factory.
- Tracked asset directory structure.
- Agreed naming and placement conventions for assets.

### Files

- [lib/utils/theme/brand_tokens.dart](../lib/utils/theme/brand_tokens.dart)
- [lib/utils/theme/brand_theme.dart](../lib/utils/theme/brand_theme.dart)
- [assets/branding/README.md](../assets/branding/README.md)
- [assets/games/README.md](../assets/games/README.md)
- [assets/fonts/README.md](../assets/fonts/README.md)

### Exit Criteria

- Theme primitives exist in one place.
- Asset folders exist and are ready to receive production files.
- The team can begin rollout without inventing new storage patterns per asset type.

## Phase 2: Native Shell

**Objective:** Replace the first-touch platform branding.

### Deliverables

- Android launcher icons replaced.
- Android splash artwork integrated.
- iOS app icon catalog populated.
- iOS launch screen aligned with brand splash layout.
- Notification icons generated for both platforms.

### Primary Files

- [android/app/src/main/AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml)
- [android/app/src/main/res/drawable/launch_background.xml](../android/app/src/main/res/drawable/launch_background.xml)
- [android/app/src/main/res](../android/app/src/main/res)
- [ios/Runner/Info.plist](../ios/Runner/Info.plist)

### Exit Criteria

- App icon and splash branding are visible before Flutter renders.

## Phase 3: App Shell

**Objective:** Replace placeholder styling in the highest-visibility Flutter surfaces.

### Deliverables

- Splash screen rebranded.
- Login and registration rebranded.
- Onboarding rebranded with actual illustration assets.
- Profile setup updated to use branded default avatars.
- Home and shared shell surfaces updated to use the centralized theme.

### Primary Files

- [lib/main.dart](../lib/main.dart)
- [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart)
- [lib/screens/login_screen.dart](../lib/screens/login_screen.dart)
- [lib/screens/registration_screen.dart](../lib/screens/registration_screen.dart)
- [lib/screens/onboarding_screen.dart](../lib/screens/onboarding_screen.dart)
- [lib/screens/profile_setup_screen.dart](../lib/screens/profile_setup_screen.dart)

### Exit Criteria

- The user no longer sees seeded purple defaults or `Icons.psychology` in the shell.

## Phase 4: Discovery And Navigation

**Objective:** Rebrand the surfaces that help users browse and understand the game library.

### Deliverables

- Category badges integrated.
- Navigation and system icons replaced with branded SVGs.
- Game selection cards updated to use category colors, game icons, and thumbnails.
- Empty-state, error-state, and loading assets introduced.

### Primary Files

- [lib/screens/game_selection_screen.dart](../lib/screens/game_selection_screen.dart)
- [lib/games/game_catalog.dart](../lib/games/game_catalog.dart)
- Shared widgets under [lib/widgets](../lib/widgets)

### Exit Criteria

- Discovery surfaces use real assets rather than emoji or stock icons.

## Phase 5: In-Game Asset Rollout

**Objective:** Move game experiences from generic widgets to branded play surfaces.

### Deliverables

- Category-by-category game asset integration.
- Header skins, markers, tiles, pegs, boards, and badges replaced with branded assets.
- Any needed motion assets introduced with fallbacks.

### Suggested Sequence

1. Memory games
2. Logic games
3. Attention games
4. Spatial games
5. Language games

### Exit Criteria

- Each game category has at least one fully branded reference implementation.
- Shared patterns are reused for the remaining games.

## Phase 6: QA And Store Readiness

**Objective:** Validate that branding is complete, stable, and platform-correct.

### Deliverables

- Android device verification.
- iOS simulator or device verification.
- Missing-asset checks.
- Contrast and readability pass.
- Final checklist review against [branding_integration_checklist.md](branding_integration_checklist.md).

## Immediate Next Implementation Target

When rollout begins, start with Phase 3 and update the following files first:

1. [lib/main.dart](../lib/main.dart)
2. [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart)
3. [lib/screens/login_screen.dart](../lib/screens/login_screen.dart)
4. [lib/screens/registration_screen.dart](../lib/screens/registration_screen.dart)

That group gives the largest visible improvement with the lowest dependency on game-specific art delivery.