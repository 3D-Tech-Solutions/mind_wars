# Branding Integration Checklist

March 2026

This checklist turns the branding spec into concrete acceptance criteria for this repository. Use it to answer two questions for every branding item:

1. Does the asset or styling exist?
2. Is it actually integrated into the app, native shells, and gameplay UI?

## How To Use This Checklist

- Mark an item complete only when the asset exists in the repo, is wired into code or native config, and has been verified in a running build.
- Treat "delivered" and "integrated" as separate states. A PNG or SVG sitting in a folder is not complete by itself.
- Use the current-state notes below as the starting baseline for this repo.

## Current Repo Baseline

<!-- [2026-03-22 Maintenance] Updated baseline to reflect asset sort pass completed on 2026-03-22.
     All clearly-defined assets moved from assets/Unsorted/ to canonical locations.
     pubspec.yaml updated to register all branding subdirectories. -->

| Area | Current State | Evidence |
|---|---|---|
| Brand asset library | **Populated** | Production assets are now committed. All well-defined alpha-level assets have been sorted from `assets/Unsorted/` into their canonical locations. A second pass cross-referenced 41 NEEDS_REVIEW files against `docs/ai_asset_generation_list.md`; 26 were identified and placed. **15 ambiguous files remain** in `assets/Unsorted/NEEDS_REVIEW/` pending developer team input (see Section 10). |
| Flutter asset registration | **Expanded** | [pubspec.yaml](../pubspec.yaml) now registers `assets/branding/` plus all subdirectories: `avatars/`, `badges/`, `icons/`, `logos/`, `onboarding/`, `system/`, `animations/`. Games subfolders are also registered. Brand fonts section is still commented out — fonts themselves are missing files. |
| Brand fonts | Missing | [pubspec.yaml](../pubspec.yaml) has the `fonts:` section commented out. Orbitron and Space Mono TTF files are not present in `assets/fonts/`. |
| Global theme | Partial | [lib/main.dart](../lib/main.dart#L125) now uses the centralized theme layer in [lib/utils/theme/brand_theme.dart](../lib/utils/theme/brand_theme.dart), but many screens still hard-code placeholder styling. |
| Splash screen UI | Placeholder | [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart#L61) uses a purple gradient and `Icons.psychology` instead of branded assets. |
| Onboarding UI | Placeholder | [lib/screens/onboarding_screen.dart](../lib/screens/onboarding_screen.dart#L21) uses stock Material icons and hard-coded accent colors. |
| Android launcher icon | Present but placeholder | Android still points to the placeholder icon set under [android/app/src/main/res](../android/app/src/main/res), described in [android/app/src/main/res/README.md](../android/app/src/main/res/README.md). |
| Android splash | Partial | [android/app/src/main/res/drawable/launch_background.xml](../android/app/src/main/res/drawable/launch_background.xml) is still the default template and does not reference a branded image. |
| iOS branding assets | Not visible in workspace snapshot | [ios/Runner/Info.plist](../ios/Runner/Info.plist#L27) points to `LaunchScreen`, but the storyboard and asset catalog are not present in the visible workspace. |

## First-Pass Assessment Summary

| Area | Status | What Is Already Integrated | What Still Needs To Be Done |
|---|---|---|---|
| Brand foundation | Partial | App naming is consistent as "Mind Wars" in Flutter and native config, `flutter_svg` is already available in [pubspec.yaml](../pubspec.yaml), tracked asset scaffolding now exists, and a centralized theme layer is in place. | Add production assets, register asset folders, add fonts, and migrate hard-coded screen styling onto the new brand layer. |
| Logo and native shell | Partial | Android manifest already points to `@mipmap/ic_launcher`, and Android plus iOS are both configured to use native launch surfaces. | Replace placeholder launcher icons, add branded splash assets, and verify iOS asset catalog and launch storyboard files. |
| Flutter app shell | Partial | Main routes, app title, and several shell screens already exist. | Replace `Icons.psychology`, seeded purple colors, generic gradients, and unbranded controls. |
| Onboarding and auth | Partial | Splash, onboarding, login, registration, and profile setup flows already exist and are functional UI surfaces. | Replace stock icons, generic colors, emoji avatars, and placeholder messaging with branded assets and typography. |
| Navigation and system UI | Partial | There are existing navigation and action surfaces throughout the app. | Replace stock Material icons with branded SVGs and add empty/error/loading assets. |
| Category and game discovery | Partial | The game catalog, category taxonomy, and selection screens are implemented in code. | Replace emoji-based game and category visuals with branded icons, thumbnails, and category color tokens. |
| In-game branding assets | Missing | Game widgets exist and are playable in code. | Add the documented game-specific assets, headers, badges, and illustrations; none appear to be wired yet. |
| Animation and motion assets | Missing | No integrated Lottie or equivalent branded motion system was found. | Add animation assets and runtime integration where required. |
| QA sign-off | Not started | Platform hooks exist for icon and splash verification. | Run device and simulator validation once branded assets are added. |

## What Is Already Integrated

- App naming is already aligned across key entry points: [lib/main.dart](../lib/main.dart#L125), [android/app/src/main/AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L15), and [ios/Runner/Info.plist](../ios/Runner/Info.plist#L6).
- Flutter already includes `flutter_svg` in [pubspec.yaml](../pubspec.yaml), so SVG-based branding is supported without adding a new package.
- A centralized theme and token foundation now exists in [lib/utils/theme/brand_tokens.dart](../lib/utils/theme/brand_tokens.dart) and [lib/utils/theme/brand_theme.dart](../lib/utils/theme/brand_theme.dart), and [lib/main.dart](../lib/main.dart#L125) now consumes it.
- Tracked asset scaffolding now exists for branding, game assets, and fonts via [assets/branding/README.md](../assets/branding/README.md), [assets/games/README.md](../assets/games/README.md), and [assets/fonts/README.md](../assets/fonts/README.md).
- Android is already wired to use a launcher icon and a native launch theme via [android/app/src/main/AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L17) and [android/app/src/main/res/values/styles.xml](../android/app/src/main/res/values/styles.xml#L4).
- The app shell already has concrete branding touchpoints to replace rather than needing new flows built from scratch: [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart), [lib/screens/login_screen.dart](../lib/screens/login_screen.dart), [lib/screens/registration_screen.dart](../lib/screens/registration_screen.dart), and [lib/screens/profile_setup_screen.dart](../lib/screens/profile_setup_screen.dart).
- The game catalog and category model are already established in [lib/games/game_catalog.dart](../lib/games/game_catalog.dart), which gives a clean place to swap emoji placeholders for real icon assets later.

## What Is Only Partially Integrated

- The overall visual identity now has a centralized foundation, but screen-level rollout is still incomplete. Many screens still bypass the new theme with hard-coded placeholder colors and icons.
- Android launcher icons exist physically in `mipmap-*`, but the repo documentation identifies them as placeholder regenerated PNGs in [android/app/src/main/res/README.md](../android/app/src/main/res/README.md).
- Android splash support exists structurally, but [android/app/src/main/res/drawable/launch_background.xml](../android/app/src/main/res/drawable/launch_background.xml) still contains the default Flutter template.
- Onboarding and game selection use working UI, but the visuals are generic. [lib/screens/onboarding_screen.dart](../lib/screens/onboarding_screen.dart) uses Material icons, and [lib/screens/game_selection_screen.dart](../lib/screens/game_selection_screen.dart) uses emoji icons and generic category colors.
- Profile setup includes avatar selection, but it is still emoji-based rather than using the 12 branded default avatars defined in [branding.md](branding.md).

## What Appears To Be Missing

- No committed production brand asset library under `assets/`; the new folder structure exists, but actual logo, icon, badge, illustration, and game art files are still missing.
- No registered brand fonts in [pubspec.yaml](../pubspec.yaml).
- No evidence of branded asset loading in Flutter screens or games; no `Image.asset`, `AssetImage`, `SvgPicture`, or Lottie-based branding surfaces were found in the app shell or game widgets.
- No committed category badges, game icons, card thumbnails, achievement badges, onboarding illustrations, or game-specific art assets were found in the workspace snapshot.
- No visible iOS asset catalog or launch storyboard files were found in the visible workspace, so iOS visual branding cannot yet be confirmed.

## Recommended Interpretation Of Status

- `Integrated` means the app or platform is already using a final or near-final branded implementation.
- `Partial` means the integration point exists and is functional, but it still uses placeholder visuals or generic styling.
- `Missing` means either the asset does not exist, or there is no code or native reference to it yet.

## Completion Rule

Mark a branding item complete only if all four checks below are true:

- Asset exists in the expected repo location.
- Asset is registered or referenced by Flutter or the native platform.
- Placeholder UI has been replaced.
- The result has been verified on at least one device or simulator build.

## 1. Brand Foundation

- [ ] Create a dedicated brand asset structure under `assets/`.
Suggested folders: `assets/branding/logos/`, `assets/branding/icons/`, `assets/branding/badges/`, `assets/branding/onboarding/`, `assets/games/`.
- [ ] Register all branding asset directories in [pubspec.yaml](../pubspec.yaml).
- [ ] Add Orbitron and Space Mono font files to the repo and register them in [pubspec.yaml](../pubspec.yaml).
- [ ] Introduce a single source of truth for brand colors and typography in Flutter.
Recommended integration point: [lib/main.dart](../lib/main.dart) or a dedicated theme/constants file under `lib/`.
- [ ] Replace hard-coded placeholder purple values such as `Color(0xFF6200EE)` across the app shell.
Known occurrences include [lib/main.dart](../lib/main.dart), [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart), [lib/screens/onboarding_screen.dart](../lib/screens/onboarding_screen.dart), [lib/screens/login_screen.dart](../lib/screens/login_screen.dart), [lib/screens/registration_screen.dart](../lib/screens/registration_screen.dart), and [lib/screens/profile_setup_screen.dart](../lib/screens/profile_setup_screen.dart).
- [ ] Adopt the file naming convention from [branding.md](branding.md#105-naming-convention) for every newly added asset.

## 2. Logo, App Icon, And Native Shell

- [ ] Add the final logomark and wordmark master files to the repo.
- [ ] Replace Android launcher icons in the `mipmap-*` directories with final branded exports.
Relevant folder: [android/app/src/main/res](../android/app/src/main/res).
- [ ] If using adaptive icons on Android, add foreground and background layers and verify manifest compatibility.
- [ ] Replace the Android launch background with the branded splash treatment.
Relevant file: [android/app/src/main/res/drawable/launch_background.xml](../android/app/src/main/res/drawable/launch_background.xml).
- [ ] Add iOS app icon assets to `Assets.xcassets/AppIcon.appiconset`.
The asset catalog is not visible in the current workspace snapshot, so this should be verified locally in Xcode.
- [ ] Add or update the iOS LaunchScreen storyboard to match the brand splash layout.
Reference config: [ios/Runner/Info.plist](../ios/Runner/Info.plist#L27).
- [ ] Generate and integrate white-only push notification icons for both platforms.

## 3. Flutter App Shell Branding

- [ ] Replace placeholder logo usage in the app shell.
Known placeholder usage: [lib/main.dart](../lib/main.dart#L241), [lib/main.dart](../lib/main.dart#L1013), [lib/screens/login_screen.dart](../lib/screens/login_screen.dart#L221), and [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart#L91).
- [ ] Update `ThemeData` to use the documented dark-first palette rather than seeded defaults.
Primary integration point: [lib/main.dart](../lib/main.dart#L128).
- [ ] Apply brand typography to primary headings, labels, and score displays.
- [ ] Ensure all common buttons, cards, chips, badges, and app bars reflect the brand geometry and color rules from [branding.md](branding.md).
- [ ] Replace generic gradients where the spec calls for flat dark surfaces.
Known mismatch: [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart#L63).

## 4. Onboarding, Authentication, And Core Screens

- [ ] Replace Material icon onboarding pages with the three branded onboarding illustrations defined in [branding.md](branding.md#71-splash-screen--onboarding).
Relevant file: [lib/screens/onboarding_screen.dart](../lib/screens/onboarding_screen.dart).
- [ ] Update the splash screen to use the branded logomark, wordmark, and loading treatment.
Relevant file: [lib/screens/splash_screen.dart](../lib/screens/splash_screen.dart).
- [ ] Update login and registration screens to use brand colors, typography, and logo assets instead of stock icons.
Relevant files: [lib/screens/login_screen.dart](../lib/screens/login_screen.dart) and [lib/screens/registration_screen.dart](../lib/screens/registration_screen.dart).
- [ ] Update profile setup to use branded default avatars and badge treatments when those assets are ready.
Relevant file: [lib/screens/profile_setup_screen.dart](../lib/screens/profile_setup_screen.dart).
- [ ] Update the home screen and lobby surfaces to use final category badges, navigation icons, and brand headings.
Relevant file: [lib/main.dart](../lib/main.dart#L222).

## 5. Navigation, Status, And System UI

- [ ] Replace stock navigation icons with the approved SVG icon set.
- [ ] Add branded notification, chat, hint, close, back, trophy, and settings icons where specified.
- [ ] Add the loading spinner animation or an equivalent branded loading state.
- [ ] Add empty-state and error-state illustrations for no wars, no results, offline, and generic failures.
- [ ] Verify all icons remain legible at mobile sizes and on dark backgrounds.

## 6. Category And Game Integration

### Shared Category Assets

- [ ] Add all 5 category badge icons.
- [ ] Add all 5 category hero illustrations.
- [ ] Wire category colors consistently across game selection, headers, and badges.

### Game Discovery Surfaces

- [ ] Add all 15 game icons.
- [ ] Add all 15 game card thumbnails.
- [ ] Verify those assets render in selectors, lobbies, notifications, and any game catalog screens.

### In-Game Assets

- [ ] Memory games use branded cards, nodes, grid states, and headers.
- [ ] Logic games use branded cells, pegs, clue assets, and headers.
- [ ] Attention games use branded scene illustrations, markers, and headers.
- [ ] Spatial games use branded puzzle, shape, maze, and header assets.
- [ ] Language games use branded tiles, badges, option cards, and headers.
- [ ] Every game-specific header matches its category palette and typography.

## 7. Animation And Motion Assets

- [ ] Add all required Lottie assets for splash, countdowns, celebrations, and game feedback.
- [ ] Integrate a Lottie runtime package if those files are used in Flutter.
- [ ] Verify motion timing stays within the brand rules from [branding.md](branding.md#12-aesthetic-direction).
- [ ] Provide non-animated fallback states where animation is not yet integrated.

## 8. QA Sign-Off Checklist

- [ ] Android debug build shows final launcher icon on device.
- [ ] Android splash shows final branded composition before Flutter renders.
- [ ] iOS build shows final app icon and branded launch screen.
- [ ] The app no longer shows `Icons.psychology` anywhere user-facing.
- [ ] The app no longer uses the placeholder seeded purple as the primary brand color.
- [ ] Orbitron and Space Mono render correctly on device without fallback issues.
- [ ] All required brand assets load without runtime missing-asset errors.
- [ ] Dark surfaces and text pass a basic contrast review.
- [ ] Onboarding, login, home, profile, and at least one screen per game category have been visually reviewed.
- [ ] Asset naming and folder organization match the spec so future additions remain consistent.

## 9. Suggested Rollout Order

1. Establish the brand theme, fonts, and asset folder structure.
2. Replace launcher icons and splash screens on Android and iOS.
3. Rebrand the app shell: splash, onboarding, login, registration, home, and profile setup.
4. Integrate navigation icons, badges, and loading or empty states.
5. Add category assets and game discovery assets.
6. Integrate game-specific assets category by category.
7. Add animations and complete final device QA.

---

## 10. Developer Team Input Required — assets/Unsorted/NEEDS_REVIEW/

<!-- [2026-03-22 Maintenance] Added section documenting 41 assets that could not be
     automatically classified during the 2026-03-22 sort pass. Each item below needs
     a decision from the team before it can be placed, renamed, or discarded. -->
<!-- [2026-03-22 Maintenance] Updated after pass 2: a second cross-reference against
     docs/ai_asset_generation_list.md resolved 26 of the 41 files. 15 remain. -->

During the 2026-03-22 sort pass, 41 files were moved to `assets/Unsorted/NEEDS_REVIEW/`. A second pass cross-referenced all 41 against `docs/ai_asset_generation_list.md` using dimension analysis, colour profiling, and visual inspection, resolving **26 files**. **15 files remain** and require a direct team decision.

### 10.1 Resolved in Pass 2 (26 files — already placed)

| File(s) | Placed at | Notes |
|---|---|---|
| `AttentionPrompt.png` (1456×720) | `assets/branding/system/hero_category_attention_1456x720.png` | Batch C hero, visually confirmed |
| `LanguagePrompt.png` (1456×720) | `assets/branding/system/hero_category_language_1456x720.png` | Batch C hero, visually confirmed |
| `LogicPrompt.png` (1456×720) | `assets/branding/system/hero_category_logic_1456x720.png` | Batch C hero, visually confirmed |
| `MemoryPrompt.png` (2912×1440) | `assets/branding/system/hero_category_memory_2912x1440.png` | Batch C hero @2× |
| `SpacialPrompt.png` (2912×1440) | `assets/branding/system/hero_category_spatial_2912x1440.png` | Batch C hero @2× |
| `MindWarsAlternative.png` (1024×1024 RGBA) | `assets/branding/logos/logo_mind-wars_mark_alt_1024.png` | Transparent logomark variant |
| `MindWarsVertical.png` (704×1520 RGBA) | `assets/branding/logos/logo_mind-wars_vertical_704x1520.png` | Portrait wordmark layout |
| `MindWarsAchievmentSplash.png` (1024×1024) | `assets/branding/system/image_achievement-splash_1024.png` | Achievement unlock splash |
| 14 × `Gemini_*` (2048×2048) | `assets/games/attention/focus-finder/scene_focus-finder_01–14_2048x2048.png` | Focus Finder clutter scenes — exact spec size |
| 4 × `Gemini_*` (1024×1024) | `assets/games/memory/memory-match/symbol_memory-match_review_01–04_1024.png` | Memory Match symbol review exports |

### 10.2 Still Requires Team Input (15 files)

**For each file, the team needs to answer:** is this a production asset we want to keep, or should it be discarded?

#### 10.2.1 Unidentified 16:9 Gemini Images (10 files)

These images have a 16:9 aspect ratio that does not match any spec in `docs/ai_asset_generation_list.md`.

| File | Dimensions | Action |
|---|---|---|
| `Gemini_*_28qaas*.png` | 2816×1536 | View → identify → place or delete |
| `Gemini_*_2o10gq*.png` | 2816×1536 | View → identify → place or delete |
| `Gemini_*_bz1s2c*.png` | 2816×1536 | View → identify → place or delete |
| `Gemini_*_kivzyn*.png` | 2816×1536 | View → identify → place or delete |
| `Gemini_*_lfyxpj*.png` | 2816×1536 | View → identify → place or delete |
| `Gemini_*_odaz8n*.png` | 2816×1536 | View → identify → place or delete |
| `Gemini_*_uw8oks*.png` | 2816×1536 | View → identify → place or delete |
| `Gemini_*_atldrg*.png` | 1408×768 | View → identify → place or delete |
| `Gemini_*_pztg73*.png` | 1408×768 | View → identify → place or delete |
| `Gemini_*_yetjme*.png` | 1408×768 | **Very bright outlier** — likely discard |

Possible candidates: Spot the Difference scene pairs at non-standard resolution (spec is 800×600), wide-format game banners, or exploratory concept art.

#### 10.2.2 Remaining Art Assets (5 files)

| File | Dimensions | Issue | Suggested Action |
|---|---|---|---|
| `BrainBoss.png` | 1408×768 | Wide-format — too large for the 256px badge slot. Badge SVG already placed. | Identify surface (celebr. banner?) → `branding/system/` or delete |
| `StreakFlameAlt.png` | 2816×1536 | Oversized flame; canonical SVG already placed. | Confirm if scene art → `branding/system/` or delete |
| `BronzeRankAlt.png` | 2048×2048 | High-res source export? Canonical SVG already placed. | Place as source PNG or delete |
| `ProfilesAlt.png` | 1408×768 | Bright background — profile composite. | View → place or delete |
| `ProifileImages.png` *(typo)* | 1408×768 | Same family as above. | View → place or delete |

### 10.3 Pending Follow-up for Already-Placed Assets

**Focus Finder scenes** (`assets/games/attention/focus-finder/`):
- 14 scenes placed; spec requires 24 (8 easy / 8 medium / 8 hard).
- Remaining: view and assign difficulty, rename, and commission 10 more scenes.
- Target naming: `scene_focus-finder_[easy|medium|hard]_##_2048x2048.png`

**Memory Match symbols** (`assets/games/memory/memory-match/`) — **COMPLETE**:
- 36 SVG symbols delivered: `symbol_memory-match_[easy|medium|hard]_01–12_512.svg` (12 per tier).
- 4 review PNGs retained for reference.
