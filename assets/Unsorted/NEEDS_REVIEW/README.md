# assets/Unsorted/NEEDS_REVIEW

<!-- [2026-03-22 Maintenance] Created during the 2026-03-22 asset sort pass. -->
<!-- [2026-03-22 Maintenance] Updated after pass 2 cross-reference against ai_asset_generation_list.md:
     26 of the original 41 files were identified and placed. 15 remain and need direct team review. -->

This folder now contains **15 files** that require developer team input before
they can be placed, renamed, or discarded.

---

## What Has Already Been Moved Out

### Pass 1 — 2026-03-22 (initial sort from Unsorted/)

| Source group | Destination |
|---|---|
| `Achievements/*.svg` (11 SVGs) | `assets/branding/badges/badge_achievement_*_256.svg` |
| `Avatars/Avatar*.svg` (60 SVGs) | `assets/branding/avatars/avatar_default_*.svg` |
| `Categories/*.png` (5 PNGs at 1600×800) | `assets/branding/system/hero_category_*_1600x800.png` |
| `CategoryBadges/*Badge*.svg` (5 SVGs) | `assets/branding/badges/badge_category_*_256.svg` |
| `Core/` logos, icons, splashes (8 files) | `assets/branding/logos/` and `assets/branding/onboarding/` |
| `GameIcons/*` (42 files) | `assets/branding/icons/icon_*` |
| `Profiles/` crown and streak overlays (4 files) | `assets/branding/badges/overlay_* and icon_streak-*` |
| `RankBadges/*.svg` (5 SVGs) | `assets/branding/badges/badge_rank_*_128.svg` |
| `MindWars*.mp4` + `MindWars_Splash.mp4` (4 MP4s) | `assets/branding/animations/anim_*.mp4` |
| Confirmed duplicate loose PNGs (31 files) | Removed — canonical versions already in `assets/branding/` |
| `LogoMaster.png` | `assets/branding/logos/logo_mind-wars_mark_1024.png` |
| `WordmarkMaster.png` | `assets/branding/logos/logo_mind-wars_wordmark-horizontal_2048.png` |
| `RankBadges/BronzeRank128x128.svg` | `assets/branding/badges/badge_rank_bronze_128.svg` |

### Pass 2 — 2026-03-22 (ai_asset_generation_list.md cross-reference)

Dimension analysis, colour profiling, and visual inspection were used to match
26 NEEDS_REVIEW files to specs in `docs/ai_asset_generation_list.md`.

| Source file(s) | Destination | Classification basis |
|---|---|---|
| `AttentionPrompt.png` (1456×720) | `assets/branding/system/hero_category_attention_1456x720.png` | Batch C hero — cyan reticle motif, visually confirmed |
| `LanguagePrompt.png` (1456×720) | `assets/branding/system/hero_category_language_1456x720.png` | Batch C hero — red letter tile cascade, visually confirmed |
| `LogicPrompt.png` (1456×720) | `assets/branding/system/hero_category_logic_1456x720.png` | Batch C hero — blue circuit diagram, visually confirmed |
| `MemoryPrompt.png` (2912×1440) | `assets/branding/system/hero_category_memory_2912x1440.png` | Batch C hero — Memory category at @2× resolution |
| `SpacialPrompt.png` (2912×1440) | `assets/branding/system/hero_category_spatial_2912x1440.png` | Batch C hero — Spatial category at @2× resolution |
| `MindWarsAlternative.png` (1024×1024, RGBA) | `assets/branding/logos/logo_mind-wars_mark_alt_1024.png` | Transparent-bg logomark alternative |
| `MindWarsVertical.png` (704×1520, RGBA) | `assets/branding/logos/logo_mind-wars_vertical_704x1520.png` | Vertical/portrait wordmark layout |
| `MindWarsAchievmentSplash.png` (1024×1024) | `assets/branding/system/image_achievement-splash_1024.png` | Achievement unlock splash art |
| 14 × `Gemini_*_2pdcty*.png` … `_zt4znz*.png` (2048×2048) | `assets/games/attention/focus-finder/scene_focus-finder_01–14_2048x2048.png` | Focus Finder clutter scenes — exact spec size match |
| 4 × `Gemini_*_dkc8on*.png`, `_m3zxtk*.png`, `_mplddw*.png`, `_wz6e2x*.png` (1024×1024) | `assets/games/memory/memory-match/symbol_memory-match_review_01–04_1024.png` | Memory Match symbol review exports (near-white bg) |

---

## What Still Needs Team Input (15 files)

### Group A — Unidentified 16:9 Gemini Images (10 files)

These images have a 16:9 landscape aspect ratio that does not match any defined
spec in `docs/ai_asset_generation_list.md`. They use the brand palette but their
intended game or UI surface is unknown.

**7 files at 2816×1536:**

- `Gemini_Generated_Image_28qaas28qaas28qa.png`
- `Gemini_Generated_Image_2o10gq2o10gq2o10.png`
- `Gemini_Generated_Image_bz1s2cbz1s2cbz1s.png`
- `Gemini_Generated_Image_kivzynkivzynkivz.png`
- `Gemini_Generated_Image_lfyxpjlfyxpjlfyx.png`
- `Gemini_Generated_Image_odaz8nodaz8nodaz.png`
- `Gemini_Generated_Image_uw8oksuw8oksuw8o.png`

**3 files at 1408×768:**

- `Gemini_Generated_Image_atldrgatldrgatld.png`
- `Gemini_Generated_Image_pztg73pztg73pztg.png`
- `Gemini_Generated_Image_yetjmeyetjmeyetj.png` ← **very bright / near-white background, outlier**

**Team action required:** Open each image, identify its intended surface, then
rename to the canonical convention and move to the correct folder. Possible
candidates: Spot the Difference scene pairs (spec is 800×600; if these are the
source art, crop/resize will be needed), wide-format UI banners, or rejected
concept art. Delete any images not approved for use.

---

### Group B — BrainBoss Banner (1 file)

> `BrainBoss.png` — 1408×768

A `badge_achievement_brain-boss_256.svg` already exists in `assets/branding/badges/`.
This wide-format PNG is too large for a badge slot and is likely either:
- An achievement celebration banner shown on the win screen
- A promotional hero image for the "Brain Boss" achievement unlock

**Team action required:** Confirm the intended surface.
- If a celebration banner → place as `assets/branding/system/image_achievement-brain-boss-banner_1408x768.png`
- If not needed → delete

---

### Group C — StreakFlameAlt (1 file)

> `StreakFlameAlt.png` — 2816×1536

The canonical streak flame SVG is already in `assets/branding/badges/icon_streak-flame.svg`.
This 2816×1536 PNG is far too large for an icon; it may be a scene or splash
illustration for a streak milestone screen.

**Team action required:** Confirm intended use.
- If a milestone splash/scene → rename and place in `assets/branding/system/`
- If an unused source export → delete

---

### Group D — High-Res Badge Source / Profile Composites (3 files)

> `BronzeRankAlt.png` — 2048×2048
> `ProfilesAlt.png` — 1408×768
> `ProifileImages.png` — 1408×768 *(note: typo in filename)*

- **`BronzeRankAlt.png`**: Very high resolution; likely a source export of the bronze rank badge. The canonical badge is already at `assets/branding/badges/badge_rank_bronze_128.svg`. Place as `badge_rank_bronze_source_2048.png` or delete.
- **`ProfilesAlt.png`** and **`ProifileImages.png`**: Both 1408×768 with light backgrounds. Likely profile-page UI composites or avatar sheet exports.

**Team action required:** View each image, confirm purpose, place or delete.

---

## Summary Decision Table

| File | Dimensions | Suggested Action |
|---|---|---|
| `Gemini_*_28qaas*.png` | 2816×1536 | Identify → place or delete |
| `Gemini_*_2o10gq*.png` | 2816×1536 | Identify → place or delete |
| `Gemini_*_bz1s2c*.png` | 2816×1536 | Identify → place or delete |
| `Gemini_*_kivzyn*.png` | 2816×1536 | Identify → place or delete |
| `Gemini_*_lfyxpj*.png` | 2816×1536 | Identify → place or delete |
| `Gemini_*_odaz8n*.png` | 2816×1536 | Identify → place or delete |
| `Gemini_*_uw8oks*.png` | 2816×1536 | Identify → place or delete |
| `Gemini_*_atldrg*.png` | 1408×768 | Identify → place or delete |
| `Gemini_*_pztg73*.png` | 1408×768 | Identify → place or delete |
| `Gemini_*_yetjme*.png` | 1408×768 | **Bright outlier** — likely discard |
| `BrainBoss.png` | 1408×768 | Confirm surface → `branding/system/` or delete |
| `StreakFlameAlt.png` | 2816×1536 | Confirm if scene → `branding/system/` or delete |
| `BronzeRankAlt.png` | 2048×2048 | Source PNG or duplicate → place or delete |
| `ProfilesAlt.png` | 1408×768 | View → place or delete |
| `ProifileImages.png` *(typo)* | 1408×768 | View → place or delete |

---

## Pending Follow-up Work for Already-Placed Assets

### Focus Finder scenes (`assets/games/attention/focus-finder/`)

14 scenes were placed as `scene_focus-finder_01–14_2048x2048.png`. The spec
requires **24 scenes** (8 easy / 8 medium / 8 hard). Remaining work:

1. View each scene and assign difficulty based on object density and complexity.
2. Rename to: `scene_focus-finder_[easy|medium|hard]_##_2048x2048.png`
3. Commission/generate 10 additional scenes to reach 24.

### Memory Match symbols (`assets/games/memory/memory-match/`) — COMPLETE

<!-- [2026-03-22 Maintenance] 36 SVG symbol files delivered and placed. -->

36 SVG symbols have been placed at `assets/games/memory/memory-match/`:
- `symbol_memory-match_easy_01–12_512.svg` (12 symbols)
- `symbol_memory-match_medium_01–12_512.svg` (12 symbols)
- `symbol_memory-match_hard_01–12_512.svg` (12 symbols)

The 4 review PNGs (`symbol_memory-match_review_01–04_1024.png`) remain for reference. No further action needed for Memory Match symbols.
