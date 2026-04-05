# Brand System & Asset Requirements

Complete visual identity · 15-game asset library · image creation briefs

March 2026 | CONFIDENTIAL | v1.0

Companion document: [Branding Integration Checklist](branding_integration_checklist.md)

**Purpose:** This document defines the complete Mind Wars visual identity system and serves as the master brief for every image, icon, illustration, and graphic asset required across the application and all 15 games. Each asset is assigned a priority tier (P1 = launch blocker, P2 = launch quality, P3 = post-launch), a format specification, and a detailed creative brief.

# 01 | Brand Identity & Visual Language

## 1.1  Brand Positioning

Mind Wars is positioned as "Peak meets Plato" — a platform that combines the cognitive rigor of premium brain-training apps with the social energy of competitive multiplayer. The visual identity must carry both halves of that tension simultaneously: it should feel intelligent without being sterile, competitive without being aggressive, and playful without being childish.

> **Design North Star:** The brand lives at the intersection of neural science and arcade competition. Every visual decision, from a game card to a push notification icon, should feel like it belongs to both worlds at once.


## 1.2  Aesthetic Direction

|**Dimension**|**Specification**|
|---|---|
|**Tone**|Dark-first. Deep navy / void black backgrounds with electric cyan and coral accents. Intelligence meets arena.|
|**Texture**|Flat with intention. No gradients except where encoding data (score bars, time remaining). Clean surfaces.|
|**Geometry**|Angular precision. Rounded corners at 8–12 dp on cards. Harder edges on interactive elements (buttons, badges).|
|**Motion style**|Purposeful and fast. Transitions under 300ms. Score reveals dramatic. Errors subtle but clear.|
|**Photography**|None in core UI. All imagery is illustrative or iconographic. Photography reserved for marketing only.|
|**Illustration**|Abstract / geometric. No literal representations of brains or war imagery. Cognitive metaphor over cliché.|

# 02 | Color System & Tokens

## 2.1  Primary Brand Palette

|**Token Name**|**Hex Value**|**RGB**|**Usage**|
|---|---|---|---|
|**--mw-void**|#090A12|rgb(9,10,18)|App background, deepest surface|
|**--mw-deep**|#0E1028|rgb(14,16,40)|Card backgrounds, secondary surfaces|
|**--mw-surface**|#14183A|rgb(20,24,58)|Elevated cards, modals|
|**--mw-line**|#1A2050|rgb(26,32,80)|Dividers, borders, inactive states|
|**--mw-cyan**|#00D4FF|rgb(0,212,255)|Primary interactive, active states, logo accent|
|**--mw-coral**|#E94560|rgb(233,69,96)|Lightning bolt mark, CTAs, errors|
|**--mw-gold**|#FFB800|rgb(255,184,0)|Victory, top scores, achievement gold|
|**--mw-purple**|#7C3AED|rgb(124,58,237)|Premium features, special events|
|**--mw-text**|#EEF0FC|rgb(238,240,252)|Primary text on dark surfaces|
|**--mw-muted**|#6868A0|rgb(104,104,160)|Secondary text, labels, placeholders|

## 2.2  Category Color Palette

|**Token Name**|**Hex Value**|**RGB**|**Usage**|
|---|---|---|---|
|**--cat-memory**|#9333EA|rgb(147,51,234)|Memory category — primary|
|**--cat-memory-lt**|#C084FC|rgb(192,132,252)|Memory category — light / text on dark bg|
|**--cat-memory-bg**|#1A0830|rgb(26,8,48)|Memory category — tinted background|
|**--cat-logic**|#2563EB|rgb(37,99,235)|Logic category — primary|
|**--cat-logic-lt**|#60A5FA|rgb(96,165,250)|Logic category — light / text on dark bg|
|**--cat-logic-bg**|#081430|rgb(8,20,48)|Logic category — tinted background|
|**--cat-attn**|#0891B2|rgb(8,145,178)|Attention category — primary|
|**--cat-attn-lt**|#22D3EE|rgb(34,211,238)|Attention category — light / text on dark bg|
|**--cat-attn-bg**|#041820|rgb(4,24,32)|Attention category — tinted background|
|**--cat-spatial**|#D97706|rgb(217,119,6)|Spatial category — primary|
|**--cat-spatial-lt**|#FCD34D|rgb(252,211,77)|Spatial category — light / text on dark bg|
|**--cat-spatial-bg**|#1A1204|rgb(26,18,4)|Spatial category — tinted background|
|**--cat-lang**|#DC2626|rgb(220,38,38)|Language category — primary|
|**--cat-lang-lt**|#F87171|rgb(248,113,113)|Language category — light / text on dark bg|
|**--cat-lang-bg**|#200608|rgb(32,6,8)|Language category — tinted background|

# 03 | Typography System

## 3.1  Type Scale

|**Role**|**Font**|**Weight**|**Size**|**Usage**|
|---|---|---|---|---|
|**Display Hero**|Orbitron|700 Bold|48 / 36 sp|App wordmark, splash screen only|
|**Display Title**|Orbitron|700 Bold|28 sp|Battle titles, major results screens|
|**Display Label**|Orbitron|400 Regular|18 sp|Category labels, section headers in-game|
|**Display Micro**|Orbitron / Space Mono|400|10–12 sp|Metadata labels, stat tags, mono readouts|
|**UI Heading**|System UI|700 Bold|22 sp|In-game instructions, modal titles|
|**UI Body**|System UI|400 Regular|16 sp|Descriptions, chat messages, game rules|
|**UI Caption**|System UI|400 Regular|13 sp|Timestamps, helper text, footnotes|
|**UI Mono**|Space Mono|400 Regular|10 sp|Score readouts, debug labels, hint counters|

> **Font licensing note:** Orbitron is open source (SIL OFL). Space Mono is open source (Apache 2.0). Both are available on Google Fonts and safe for commercial use. System UI falls back to SF Pro (iOS) and Roboto (Android); no license is needed.


# 04 | Logo & Watermark - Asset Requirements

## 4.1  Logo Mark Description

The Mind Wars mark consists of two elements: (1) a symmetrical brain-hemisphere arc structure drawn in Cyan Electric (#00D4FF) representing the two cognitive hemispheres, and (2) a coral lightning bolt (#E94560) bisecting the centre vertically, representing competitive energy and the "wars" element. Intersection nodes at the hemisphere junctions are rendered as filled circles.

## 4.2  Wordmark

Two-weight wordmark in Orbitron: "MIND" in weight 400 (regular) and "WARS" in weight 700 (bold), with "MIND" in #EEF0FC and "WARS" in #00D4FF. Letter-spacing 0.12em. The weight and colour contrast between the two words encodes the brand tension directly in the typography.

## 4.3  Logo Asset Requirements

|**Asset**|**Format**|**Size**|**Colourway**|**Priority**|**Notes**|
|---|---|---|---|---|---|
|**App Store icon — iOS**|PNG|1024×1024 px|Dark bg|P1|No alpha, rounded corners applied by OS|
|**App Store icon — Android**|PNG|512×512 px|Dark bg|P1|Adaptive icon foreground layer|
|**App icon — adaptive bg**|PNG|108×108 dp|Void black|P1|Android adaptive background layer|
|**Home screen icon @1×**|PNG|60×60 px|Dark bg|P1|iOS iPhone|
|**Home screen icon @2×**|PNG|120×120 px|Dark bg|P1|iOS Retina|
|**Home screen icon @3×**|PNG|180×180 px|Dark bg|P1|iOS Retina HD|
|**Spotlight icon @2×**|PNG|80×80 px|Dark bg|P1|iOS search|
|**Settings icon @2×**|PNG|58×58 px|Dark bg|P1|iOS settings|
|**Notification icon**|PNG|40×40 px|Dark bg|P1|iOS notification|
|**Android launcher XXXHDPI**|PNG|192×192 px|Dark bg|P1|Android all densities|
|**Favicon**|ICO/PNG|32×32 px|Dark bg|P2|Web companion|
|**Wordmark — horizontal**|SVG+PNG|Max width use|Dark bg|P1|Primary wordmark|
|**Wordmark — stacked**|SVG+PNG|Square format|Dark bg|P2|Square contexts|
|**Wordmark — reversed**|SVG+PNG|Max width use|Light bg|P2|Marketing / white bg use|
|**Logomark only (no text)**|SVG+PNG|Variable|Dark + lt|P1|Social media avatars, embossed|
|**Monochrome mark — white**|SVG+PNG|Variable|White on transparent|P2|Watermark / overlay use|
|**Monochrome mark — black**|SVG+PNG|Variable|Black on transparent|P2|Print / light bg use|

# 05 | App Icon Suite - Creative Brief

## 5.1  Icon Design Language

All 15 game icons follow a unified design system: dark background matching the category tint colour, a single-colour line-art SVG symbol in the category light colour, and a subtle corner radius of 9dp. Icons must be instantly readable at 29pt (Settings size) and remain distinct from each other at a glance. No text in icons.

## 5.2  Icon Design Principles

- Single central motif: one clear idea per icon, no compositions of multiple metaphors.
- 1.5pt stroke weight at 40×40 viewport: scales cleanly to all sizes.
- Maximum 3 distinct shapes per icon: simplicity at small sizes is non-negotiable.
- Filled shapes for the primary element; outlined or stroked shapes for secondary elements.
- Category accent colour only: no off-palette colours in game icons.
- Test at 29×29pt before finalising: this is the minimum rendered size.

## 5.3  Game Icon Asset Requirements

| **Game**                | **Category** | **Accent** | **Pri** | **Icon Brief**                                                                                                   |
| ----------------------- | ------------ | ---------- | ------- | ---------------------------------------------------------------------------------------------------------------- |
| **Memory Match**        | Memory       | Purple     | P1      | Two overlapping cards, one face-down (back pattern), one revealing a symbol. Back card offset behind face card.  |
| **Sequence Recall**     | Memory       | Purple     | P1      | Three circles connected by dashed arc paths, numbered 1-2-3 implied by size progression.                         |
| **Pattern Memory**      | Memory       | Purple     | P1      | 3×3 grid of dots; 5 filled (pattern), 4 outlined (empty). Asymmetric arrangement.                                |
| **Sudoku Duel**         | Logic        | Blue       | P1      | 3×3 section of a Sudoku grid. Three highlighted cells (diagonal) with a subtle speed-line.                       |
| **Logic Grid**          | Logic        | Blue       | P1      | Four nodes at corners of a square, connected by four edges plus two crossing diagonals. Web-like.                |
| **Code Breaker**        | Logic        | Blue       | P1      | Three circles in a row (the "code"). Below: two smaller circles (one filled = correct position).                 |
| **Spot the Difference** | Attention    | Cyan       | P1      | Two side-by-side simple shapes (e.g., house outlines). One has a small difference highlighted with a circle.     |
| **Color Rush**          | Attention    | Cyan       | P1      | Three bold horizontal bands of brand colour (coral, cyan, gold). Clean Stroop visual.                            |
| **Focus Finder**        | Attention    | Cyan       | P1      | Concentric targeting reticle (3 rings), crosshair lines, small filled circle at centre.                          |
| **Puzzle Race**         | Spatial      | Amber      | P1      | Four puzzle pieces; three connected, one hovering nearby with a dashed slot. Race implied by the floating piece. |
| **Rotation Master**     | Spatial      | Amber      | P1      | L-shaped or T-shaped polygon with a circular rotation arrow (quarter-arc with arrowhead) around it.              |
| **Path Finder**         | Spatial      | Amber      | P1      | Simple grid with walls. A highlighted path snaking from bottom-left to top-right.                                |
| **Word Builder**        | Language     | Red        | P1      | Three letter-tile squares stacked in ascending staircase (W, O, R). Cascade metaphor.                            |
| **Anagram Attack**      | Language     | Red        | P1      | Three letter-tiles in a triangle arrangement with curved arrows between them showing rearrangement.              |
| **Vocabulary Showdown** | Language     | Red        | P1      | Two open books facing each other, spines touching, like a VS duel. Text lines on pages.                          |

> Each icon must be delivered as: (1) SVG source file, (2) PNG at 512×512 px @1x with transparency, and (3) PNG at 1024×1024 px @2x with transparency. Naming convention: `icon_[game-slug]_512.png`, `icon_[game-slug]_1024.png`.

# 06 | Category Visual System - Asset Requirements

## 6.1  Category Hero Illustrations

Each of the 5 cognitive categories requires a hero illustration used on the category landing screen, the game selection header, and marketing materials. These are larger, more detailed than game icons — they must convey the cognitive concept visually without using text.

| **Category**  | **Priority** | **Creative Brief — Hero Illustration**                                                                                                                                                                      |
| ------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Memory**    | P1           | Abstract representation of working memory: a 3D grid of glowing nodes, some lit (remembered), some dark (forgotten). Neural connection lines between lit nodes. Purple palette. Dimensions: 800×400 px @2×. |
| **Logic**     | P2           | Abstract circuit board or constraint web: interconnected nodes with logical flow indicators. Clean geometric. Blue palette with white accent lines. 800×400 px @2×.                                         |
| **Attention** | P2           | Targeting reticle zooming in on a single bright point in a field of noise. Cyan spotlight on dark field. Conveys selective attention visually. 800×400 px @2×.                                              |
| **Spatial**   | P2           | Floating 3D geometric shapes (cube, prism, pyramid) arranged in space, some slightly rotated. Amber grid floor plane. 800×400 px @2×.                                                                       |
| **Language**  | P2           | Abstract word-cascade: a stream of letter tiles falling/rising, some forming words mid-flight. Red palette. 800×400 px @2×.                                                                                 |

## 6.2  Category Badge Assets

Each category uses a circular badge icon for use in leaderboards, notifications, and achievement tiles. These are distinct from game icons and represent the cognitive domain rather than a specific game.

| **Category**  | **Priority** | **Format**     | **Badge Brief**                                                                         |
| ------------- | ------------ | -------------- | --------------------------------------------------------------------------------------- |
| **Memory**    | P1           | PNG 256×256 px | Brain/node cluster motif in purple. Circular format with category-tint background ring. |
| **Logic**     | P1           | PNG 256×256 px | Geometric node-and-edge graph in blue. Circular format.                                 |
| **Attention** | P1           | PNG 256×256 px | Targeting reticle in cyan. Circular format.                                             |
| **Spatial**   | P1           | PNG 256×256 px | 3D cube or isometric form in amber. Circular format.                                    |
| **Language**  | P1           | PNG 256×256 px | Letter-tile stack in red. Circular format.                                              |


# 07 | Application-Level Assets

## 7.1  Splash Screen & Onboarding

|**Asset**|**Format**|**Size**|**Priority**|**Notes/Brief**|
|---|---|---|---|---|
|**Splash screen — iOS**|PNG|1290×2796 px|P1|Void black bg, centred logomark + wordmark. Animated version (Lottie): neural arc "assembles" over 1.2s.|
|**Splash screen — Android**|PNG|1080×2340 px|P1|Same layout as iOS. Vector preferred for adaptive sizing.|
|**Onboarding slide 1**|PNG/SVG|750×1334 px|P1|Hero illustration: "Play your way." Async gameplay visual — player at phone, time icons floating around.|
|**Onboarding slide 2**|PNG/SVG|750×1334 px|P1|Hero illustration: "Train your brain." Split-screen of 5 category icons radiating from centre.|
|**Onboarding slide 3**|PNG/SVG|750×1334 px|P1|Hero illustration: "Challenge friends." Simplified lobby with 4 avatar circles and a chat bubble.|
|**Empty state — no wars**|SVG|400×300 px|P2|Illustration: lonely arena with "Start your first Mind War" prompt. Friendly, not sad.|
|**Empty state — no results**|SVG|400×300 px|P2|Illustration: hourglass or stopwatch. "Waiting for opponents to finish."|
|**Error state — offline**|SVG|400×300 px|P2|Illustration: broken circuit/disconnected node. Cyan line with a gap.|
|**Error state — generic**|SVG|400×300 px|P2|Illustration: glitching screen / scrambled grid. Coral palette.|
|**Achievement unlock modal**|Lottie|400×400 px|P2|Animation: badge "lands" with particle burst. Duration ~1.5s. Loop: none.|

## 7.2  Avatar & Profile Assets

|**Asset**|**Format**|**Size**|**Priority**|**Notes/Brief**|
|---|---|---|---|---|
|**Default avatar — set of 12**|SVG/PNG|256×256 px|P1|Abstract geometric face-like compositions using brand palette. 12 unique designs. No human features.|
|**Big Brain crown badge**|SVG/PNG|128×128 px|P1|Gold crown overlay for lobby admin avatar. Applied as overlay, not embedded.|
|**Player rank badge — Bronze**|SVG/PNG|128×128 px|P1|Hexagonal badge, bronze palette. Roman numeral or tier label inside.|
|**Player rank badge — Silver**|SVG/PNG|128×128 px|P1|Hexagonal badge, silver palette.|
|**Player rank badge — Gold**|SVG/PNG|128×128 px|P1|Hexagonal badge, gold palette.|
|**Player rank badge — Platinum**|SVG/PNG|128×128 px|P2|Hexagonal badge, cyan/platinum palette.|
|**Player rank badge — Diamond**|SVG/PNG|128×128 px|P2|Hexagonal badge, purple/holographic palette.|
|**Streak flame icon**|SVG/PNG|64×64 px|P1|Stylised flame in coral/gold. Used on streak counters. Animated (Lottie) version for P2.|

## 7.3  Achievement & Badge System

Achievements use a consistent badge template: hexagonal outer frame, category-colour fill, white iconographic inner symbol, optional glow effect for legendary tier.

| **Achievement Badge**            | **Format** | **Size**   | **Priority** | **Creative Brief**                                                             |
| -------------------------------- | ---------- | ---------- | ------------ | ------------------------------------------------------------------------------ |
| **First Win**                    | SVG/PNG    | 256×256 px | P1           | Gold star on void background. Simple, iconic.                                  |
| **Undefeated (5 wins streak)**   | SVG/PNG    | 256×256 px | P1           | Five-pointed crown, gold palette. Bold.                                        |
| **Brain Boss (War winner)**      | SVG/PNG    | 256×256 px | P1           | Lightning bolt inside a trophy silhouette. Coral + gold.                       |
| **Speed Demon (fastest time)**   | SVG/PNG    | 256×256 px | P2           | Stopwatch with speed lines. Cyan palette.                                      |
| **Perfect Score**                | SVG/PNG    | 256×256 px | P1           | Circular target with bullseye, all rings hit. Gold palette.                    |
| **No Hints (full game)**         | SVG/PNG    | 256×256 px | P2           | Lightbulb with a strike-through. Purple palette.                               |
| **Memory Master**                | SVG/PNG    | 256×256 px | P2           | Brain-arc motif (simplified logo mark) in purple.                              |
| **Logic Legend**                 | SVG/PNG    | 256×256 px | P2           | Node-graph motif in blue.                                                      |
| **Attention Ace**                | SVG/PNG    | 256×256 px | P2           | Reticle motif in cyan.                                                         |
| **Spatial Savant**               | SVG/PNG    | 256×256 px | P2           | Rotating cube in amber.                                                        |
| **Word Wizard**                  | SVG/PNG    | 256×256 px | P2           | Letter-tile cascade in red.                                                    |
| **Legendary (all 15 games won)** | SVG/PNG    | 256×256 px | P3           | Full-detail Mind Wars emblem with all 5 category colours. Holographic palette. |


# 08 | Game-by-Game Asset Register

Each game entry below lists: (A) the game card thumbnail required for the lobby game selector, (B) any in-game-specific image assets (card backs, pattern sets, scene images, etc.), and (C) the in-game header or skin treatment. All assets use the category colour palette defined in Section 02.

## **🧠  MEMORY GAMES**

### 08.1  Memory Match

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark purple bg. Two overlapping cards — back card (pattern side up) and front card (symbol revealed). Category badge top-right.|
|**Card back design**|SVG/PNG|512×512 px|P1|CRITICAL ASSET. The back of every memory card. Pattern: Mind Wars logomark tiled at 45°, semi-transparent, on deep purple (#1A0830). A faint cyan border ring. This appears every time a card is face-down.|
|**Card face — symbol set (18 pairs)**|SVG|512×512 px each|P1|18 abstract symbols used as card faces. Geometric shapes only — no representational imagery. 4 easy (large simple shapes), 8 medium (compound shapes), 6 hard (complex compositions). All on white or very light bg for contrast. Purple accent colour.|
|**Card face — symbol set extra (hard tier)**|SVG|512×512 px each|P2|12 additional symbols for hard mode. Slight variation on medium-tier symbols (rotation, detail addition).|
|**Board background texture**|PNG|1080×1920 px|P2|Subtle grid dot pattern on void-black. Used as the table the cards sit on. Very low opacity texture.|
|**Match particle burst (Lottie)**|JSON|n/a|P2|Celebration animation on successful pair match. Duration 0.6s. Purple particles, disappears cleanly.|
|**In-game header skin**|SVG|750×120 px|P1|Purple gradient-free header bar. Timer on left, score on right, game title centre. Orbitron font.|

### 08.2  Sequence Recall

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark purple bg. Three glowing circles connected by dashed arcs, numbered 1-2-3. Purple/lilac palette.|
|**Sequence node — lit state**|SVG|128×128 px|P1|Filled circle, bright purple (#C084FC), subtle outer glow ring. Used when node is "showing" in sequence.|
|**Sequence node — idle state**|SVG|128×128 px|P1|Outlined circle, dim purple (#9333EA at 40% opacity). Awaiting player tap.|
|**Sequence node — correct tap**|SVG|128×128 px|P1|Filled circle, cyan flash state. Momentary correct-tap feedback.|
|**Sequence node — wrong tap**|SVG|128×128 px|P1|Filled circle, coral (#E94560). Error feedback state.|
|**Connection path (Lottie)**|JSON|n/a|P2|Animated dashed arc that "draws" between nodes during playback phase. Purple dashes.|
|**In-game header skin**|SVG|750×120 px|P1|Matches Memory Match header. Shows: sequence length, current round, score.|

### 08.3  Pattern Memory

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark purple bg. 4×4 dot grid, half filled in lilac, half empty — asymmetric pattern. Timer implied by faint arc.|
|**Grid cell — filled**|SVG|96×96 px|P1|Rounded square, filled #C084FC. This is the "active/remembered" cell state.|
|**Grid cell — empty**|SVG|96×96 px|P1|Rounded square outline only, #9333EA at 30%. The blank grid cell.|
|**Grid cell — player-placed**|SVG|96×96 px|P1|Rounded square, filled #00D4FF (cyan). Player's own input, distinct from the "shown" pattern.|
|**Grid cell — error**|SVG|96×96 px|P1|Rounded square, filled #E94560. Wrong cell selected.|
|**Pattern reveal overlay (Lottie)**|JSON|n/a|P2|Flash animation on pattern reveal phase — cells light up in sequence then fade. 1.5s.|
|**In-game header skin**|SVG|750×120 px|P1|Purple header. Shows: grid size, time to memorise, round progress.|

## **🧩  LOGIC GAMES**

### 08.4  Sudoku Duel

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark blue bg. 9×9 Sudoku grid, mostly filled, a few cells highlighted cyan as "solving". Speed lines imply race.|
|**Grid background — light**|SVG|750×750 px|P1|9×9 grid with thick 3×3 box borders in blue, thin cell borders in lighter blue. Clean, no noise.|
|**Cell — pre-filled (clue)**|SVG|72×72 px|P1|White bg cell. Number in Orbitron bold, blue (#2563EB). These are the given clues.|
|**Cell — player input**|SVG|72×72 px|P1|Very light blue bg (#E8F0FF). Number in regular weight, dark blue. Player-entered digit.|
|**Cell — error**|SVG|72×72 px|P1|Light coral bg (#FFF0F0). Red number. Incorrect digit state.|
|**Cell — hint revealed**|SVG|72×72 px|P1|Light gold bg (#FFFBEA). Gold number. Server-revealed hint digit.|
|**Pencil mark cell**|SVG|72×72 px|P2|White bg with 3×3 mini-digit grid (candidates). Very small Orbitron text.|
|**Hint button icon**|SVG|64×64 px|P1|Lightbulb outline in gold. Tap to reveal a single cell. Badge shows cost (–5 pts).|
|**In-game header skin**|SVG|750×120 px|P1|Blue header. Shows: time elapsed, error count, difficulty tag.|

### 08.5  Logic Grid

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark blue bg. Logic grid with a few filled cells (✓ and ✗), node connections visible. Deductive feel.|
|**Grid cell — confirmed TRUE**|SVG|80×80 px|P1|Blue filled cell with white checkmark. Confirmed logical deduction.|
|**Grid cell — confirmed FALSE**|SVG|80×80 px|P1|Dark cell with subtle X mark in muted colour. Eliminated.|
|**Grid cell — empty**|SVG|80×80 px|P1|Light outlined cell. Available for deduction.|
|**Clue icon — person**|SVG|64×64 px|P2|Abstract person silhouette for row/column labels. Geometric, no face detail.|
|**Clue icon — object set (8)**|SVG|64×64 px each|P2|8 abstract object icons (house, car, book, pet, etc.) for puzzle element labels. Geometric.|
|**In-game header skin**|SVG|750×120 px|P1|Blue header. Shows: puzzle title, clues remaining, timer.|

### 08.6  Code Breaker

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark blue bg. A row of 4 colour pegs (code), below it a guess row with feedback pegs. Mastermind-style.|
|**Code peg — colour set (8)**|SVG|64×64 px each|P1|8 peg colours: cyan, coral, gold, purple, green, amber, white, pink. Circular peg shape, flat fill, subtle top-highlight.|
|**Code peg — empty slot**|SVG|64×64 px|P1|Dark outlined circle. Empty peg slot.|
|**Feedback peg — correct position**|SVG|32×32 px|P1|Small filled white circle. "Right colour, right position."|
|**Feedback peg — correct colour**|SVG|32×32 px|P1|Small filled grey circle. "Right colour, wrong position."|
|**Feedback peg — wrong**|SVG|32×32 px|P1|Small empty circle. No match.|
|**Code shield (hidden code display)**|SVG|280×80 px|P1|Visual treatment for the hidden code row at top. Question mark pegs behind a shield/lock graphic.|
|**Code reveal animation (Lottie)**|JSON|n/a|P2|Shield lifts to reveal solution pegs. 0.8s. Used when game ends.|
|**In-game header skin**|SVG|750×120 px|P1|Blue header. Shows: guess number (e.g., "Guess 4 of 10"), score, remaining guesses.|

  


## **👁️  ATTENTION GAMES**

### 08.7  Spot the Difference

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark teal bg. Two side-by-side scene thumbnails with a magnifying glass overlay hinting at differences.|
|**Scene image set — Easy (10 pairs)**|PNG|800×600 px each|P1|10 illustrated scene pairs (e.g., living room, park, kitchen, playground). Each pair has 3 differences. GEOMETRIC ILLUSTRATION STYLE — no photography. Simple, colourful, family-friendly. Scenes should feel like a cartoon guidebook.|
|**Scene image set — Medium (10 pairs)**|PNG|800×600 px each|P1|10 scene pairs with 5 differences each. Slightly more complex scenes. Same illustration style.|
|**Scene image set — Hard (10 pairs)**|PNG|800×600 px each|P2|10 scene pairs with 7–8 subtle differences. Colour shifts, small object additions/removals.|
|**Difference found marker**|SVG|80×80 px|P1|Animated cyan circle that "closes in" on a found difference. Lottie preferred for animation.|
|**Wrong tap marker**|SVG|80×80 px|P1|Coral X mark that fades out after 0.5s. Quick penalty feedback.|
|**Magnifying glass cursor asset**|SVG|64×64 px|P2|Custom cursor/pointer for the game area. Cyan magnifying glass.|
|**In-game header skin**|SVG|750×120 px|P1|Cyan/teal header. Shows: differences found (e.g., 3/5), timer, score.|

> **Important - Scene illustrations:** The 20 Easy/Medium scene pairs for Spot the Difference represent the largest single illustration commission in the project. Each pair is essentially two nearly identical illustrations. Budget and timeline accordingly. Illustration style guide: flat vector, 4-6 dominant colors per scene, no gradients, no photography elements, WCAG AA contrast on all difference elements.

### 08.8  Color Rush

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark teal bg. Three bold colour bands (Stroop visual), large TYPE word in mismatching colour.|
|**Word display background**|SVG|750×400 px|P1|Full-width card for the Stroop word display. Void black bg, centred large Orbitron word in the ink colour. No other elements.|
|**Tap response — CORRECT**|SVG|750×120 px|P1|Bottom zone flashes cyan briefly (0.2s). Button label = the ink colour name.|
|**Tap response — WRONG**|SVG|750×120 px|P1|Bottom zone flashes coral briefly (0.2s).|
|**Colour name button set**|SVG|160×64 px each|P1|Buttons for each of the 6 ink colours used in the game. Flat, no fill — just text + border. Activates on tap.|
|**In-game header skin**|SVG|750×120 px|P1|Teal header. Shows: question number (e.g., "12/30"), accuracy %, timer.|

### 08.9  Focus Finder

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark teal bg. Dense cluttered scene with one object highlighted by a reticle.|
|**Clutter scene set — Easy (8)**|PNG|1080×1080 px each|P1|8 cluttered flat-illustration scenes (desk, beach, market, etc.). Each has 3–5 target objects to find. SAME ILLUSTRATION STYLE as Spot the Difference scenes.|
|**Clutter scene set — Hard (8)**|PNG|1080×1080 px each|P2|8 more complex cluttered scenes. 8–10 targets. Higher density of objects.|
|**Target highlight ring**|SVG|100×100 px|P1|Animated pulsing ring shown on TARGET CARD (what to find). Cyan, pulsing glow at ~1s interval.|
|**Found target stamp**|SVG|100×100 px|P1|Cyan checkmark stamp with brief scale animation. Applied to each found object.|
|**Target card — item preview**|SVG|120×120 px|P1|Small card template showing the item to find. Teal border, white bg, item centred with label below.|
|**In-game header skin**|SVG|750×120 px|P1|Teal header. Shows: targets found / total, timer, score.|

  
## **🗺️  SPATIAL GAMES**

### 08.10  Puzzle Race

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark amber bg. Partially assembled jigsaw, one piece hovering above its slot.|
|**Puzzle image set — Easy (12)**|PNG|800×800 px each|P1|12 colourful, abstract geometric illustration images used as puzzle images. 4×4 grid (16 pieces). Simple, bold shapes, brand palette. NO PHOTOGRAPHY.|
|**Puzzle image set — Medium (12)**|PNG|800×800 px each|P1|12 images at 5×5 grid (25 pieces). Slightly more complex compositions.|
|**Puzzle image set — Hard (8)**|PNG|800×800 px each|P2|8 images at 6×6 grid (36 pieces). Dense, detailed illustrations.|
|**Puzzle piece — outline hover**|SVG|n/a (generated)|P1|SVG mask/clip treatment for cut-out piece shape. Jigsaw tab cut style. Used programmatically.|
|**Piece snap animation (Lottie)**|JSON|n/a|P2|Brief gold flash + settle when piece snaps into place. 0.3s.|
|**Completion fireworks (Lottie)**|JSON|n/a|P2|Full-board celebration. Gold/amber particles. 2s. Non-looping.|
|**In-game header skin**|SVG|750×120 px|P1|Amber header. Shows: pieces placed / total, timer, score.|

### 08.11  Rotation Master

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark amber bg. L-shaped polygon with rotation arrow, and 4 answer options shown as small shapes.|
|**Shape library — 20 base shapes**|SVG|256×256 px each|P1|20 distinct 2D geometric shapes (L, T, F, Z, S, mirrored-L, cross, arrow, etc.). All in amber palette. These are the shapes shown to players. Each shape must be visually unambiguous when rotated.|
|**Rotation arrow animation (Lottie)**|JSON|n/a|P2|Spinning rotation-arrow animation that plays during the question display. 1s, looping.|
|**Answer tile — default**|SVG|160×160 px|P1|White-border card on deep bg. Shape centred. Tap target.|
|**Answer tile — selected**|SVG|160×160 px|P1|Amber border, light amber tint. Shows player's selection before confirmation.|
|**Answer tile — correct**|SVG|160×160 px|P1|Green border, green tint. Correct answer feedback.|
|**Answer tile — incorrect**|SVG|160×160 px|P1|Coral border, coral tint. Wrong answer feedback.|
|**In-game header skin**|SVG|750×120 px|P1|Amber header. Shows: question counter, streak count, timer.|

### 08.12  Path Finder

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark amber bg. Top-down grid maze with a highlighted gold path from start to end.|
|**Maze grid — wall tile**|SVG|48×48 px|P1|Solid dark amber tile. Impenetrable wall segment.|
|**Maze grid — floor tile**|SVG|48×48 px|P1|Light amber/transparent tile. Walkable path cell.|
|**Player position marker**|SVG|48×48 px|P1|Bright amber filled circle, slightly smaller than the grid cell. Player's current position.|
|**Start marker**|SVG|48×48 px|P1|Green circle with "S" or play icon. Start cell overlay.|
|**End / goal marker**|SVG|48×48 px|P1|Gold star or flag icon. Goal cell overlay.|
|**Solved path highlight**|SVG|n/a|P1|Amber trail overlay applied on top of floor tiles to show the route taken. Used for results review.|
|**Optimal path badge**|SVG|128×128 px|P2|"+20 OPTIMAL" badge that appears when bonus is earned. Gold with lightning bolt.|
|**In-game header skin**|SVG|750×120 px|P1|Amber header. Shows: moves taken, timer, score.|

  
## **📚  LANGUAGE GAMES**

### 08.13  Word Builder

| **Asset**                             | **Format** | **Size**   | **Priority** | **Brief**                                                                                                   |
| ------------------------------------- | ---------- | ---------- | ------------ | ----------------------------------------------------------------------------------------------------------- |
| **Game card thumbnail**               | PNG/SVG    | 600×360 px | P1           | Dark red bg. 3×3 letter grid, a few tiles highlighted as a word, cascading-physics implied by offset.       |
| **Letter tile — default**             | SVG        | 96×96 px   | P1           | Dark red card with rounded corners (10dp). Letter in Orbitron Bold, #F87171 colour. Subtle embossed border. |
| **Letter tile — selected/chain**      | SVG        | 96×96 px   | P1           | Bright coral fill (#E94560). Letter in white. Active tile in current word chain.                            |
| **Letter tile — used (cascaded)**     | SVG        | 96×96 px   | P1           | Faded / semi-transparent version. Tile has been used and is awaiting the cascade replacement.               |
| **Letter tile — bonus (rare)**        | SVG        | 96×96 px   | P1           | Gold-bordered tile. Indicates a letter in a rare word. Gold glow ring around tile.                          |
| **Chain connection line**             | SVG        | n/a        | P1           | Coral line connecting adjacent selected tiles. Drawn programmatically but needs stroke style spec.          |
| **Word submitted animation (Lottie)** | JSON       | n/a        | P2           | Tiles "shoot" upward and disappear as word is accepted. Replacement tiles fall from top. 0.4s physics.      |
| **Pangram celebration (Lottie)**      | JSON       | n/a        | P2           | Full board rainbow flash + "+50 PANGRAM!" badge drop. 1.5s.                                                 |
| **Rarity badge — Uncommon**           | SVG        | 100×40 px  | P1           | "+10 UNCOMMON" pill badge. Purple outline on dark bg.                                                       |
| **Rarity badge — Rare**               | SVG        | 100×40 px  | P1           | "+25 RARE" pill badge. Gold outline, subtle glow.                                                           |
| **In-game header skin**               | SVG        | 750×120 px | P1           | Red header. Shows: words found, target word count, score, timer.                                            |

### 08.14  Anagram Attack

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark red bg. Scrambled letter tiles with rearrangement arrows. Speed-lines suggest urgency.|
|**Letter tile — scramble state**|SVG|88×88 px|P1|Same tile design as Word Builder default tile. Letters appear "tumbling" via slight rotation per tile (±5°).|
|**Letter tile — input slot**|SVG|88×88 px|P1|Empty outlined slot. Target zone where player places tiles to form words.|
|**Shuffle button icon**|SVG|64×64 px|P1|Circular arrows (reshuffle) in coral. Tap to re-scramble the unused letters.|
|**Word submitted — valid (Lottie)**|JSON|n/a|P2|Brief green flash on the word, tiles fly to "found words" zone. 0.4s.|
|**Word submitted — invalid**|SVG|750×60 px|P1|Red shake animation of the input row + "Not a word" error text. CSS animation, 0.3s.|
|**Unique word badge**|SVG|120×40 px|P2|"+5 UNIQUE" badge that appears post-deadline when unique-word bonus is applied.|
|**Timer urgency states**|SVG|120×60 px|P1|Timer display that changes colour at 60s (amber) and 30s (red). Pulsing at <30s.|
|**In-game header skin**|SVG|750×120 px|P1|Red header. Shows: 5-min countdown timer, word count, current score.|

### 08.15  Vocabulary Showdown

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Game card thumbnail**|PNG/SVG|600×360 px|P1|Dark red bg. Two open books facing each other with a lightning bolt between them. VS energy.|
|**Word card — main word**|SVG|600×120 px|P1|Large word display card. Orbitron bold, #EEF0FC on deep red bg. Word is bold/centred.|
|**Match option card — default**|SVG|280×80 px|P1|Synonym option card. System UI font, outline border, dark bg. 4 per screen in 2×2 grid.|
|**Match option card — selected**|SVG|280×80 px|P1|Coral border + tint. Player has chosen this option.|
|**Match option card — correct**|SVG|280×80 px|P1|Green border + tint. Correct synonym confirmed.|
|**Match option card — wrong**|SVG|280×80 px|P1|Coral fill + red X. Wrong synonym selected.|
|**Speed bonus badge**|SVG|120×40 px|P1|"+SPEED" badge with a lightning bolt. Appears briefly when player answers fast.|
|**In-game header skin**|SVG|750×120 px|P1|Red header. Shows: words matched / total, timer, score, accuracy %.|


# 09 | UI Component Assets

## 9.1  Navigation & Global UI

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Tab bar — home icon**|SVG|28×28 px|P1|House/arena icon in two states: active (cyan filled) and inactive (muted outline).|
|**Tab bar — wars icon**|SVG|28×28 px|P1|Lightning bolt in two states. Active / inactive.|
|**Tab bar — leaderboard icon**|SVG|28×28 px|P1|Podium / trophy icon. Active / inactive.|
|**Tab bar — profile icon**|SVG|28×28 px|P1|Person/avatar circle icon. Active / inactive.|
|**Back navigation chevron**|SVG|24×24 px|P1|Thin chevron left. Cyan in active state, muted in disabled.|
|**Close / X button**|SVG|24×24 px|P1|Thin cross. Used on modals.|
|**Hint icon**|SVG|28×28 px|P1|Lightbulb outline. Gold. Used on all hint buttons across games.|
|**Settings gear icon**|SVG|28×28 px|P1|Minimal gear/cog. Muted colour.|
|**Share icon**|SVG|28×28 px|P2|Up-arrow-from-box. Cyan. Used on result screens.|
|**Notification bell**|SVG|28×28 px|P1|Bell outline. Badge dot overlay for unread count.|
|**Chat bubble icon**|SVG|28×28 px|P1|Rounded speech bubble. Cyan. Used in lobby navigation.|
|**Trophy / war winner icon**|SVG|40×40 px|P1|Gold trophy. Used on final results screen.|
|**Skull / eliminated icon**|SVG|32×32 px|P2|Playful geometric skull. Used when player is skipped or eliminated.|

## 9.2  Notification & System Assets

|**Asset**|**Format**|**Size**|**Priority**|**Brief**|
|---|---|---|---|---|
|**Push notification icon — iOS**|PNG|40×40 px @2×|P1|White logomark on transparent bg. Apple requires white-only notification icons.|
|**Push notification icon — Android**|PNG|96×96 px|P1|White logomark on transparent bg.|
|**Rich notification thumbnail — battle start**|PNG|300×300 px|P2|Mini game card thumbnail + "Battle X is live!" overlay text.|
|**Rich notification thumbnail — results**|PNG|300×300 px|P2|Score comparison mini-card with winner highlighted.|
|**Loading spinner**|Lottie|120×120 px|P1|Mind Wars logomark that "assembles" on loop. Duration 1.2s looping. Cyan palette.|
|**Battle countdown animation**|Lottie|300×300 px|P2|3-2-1-GO countdown for battle start. Orbitron numbers, coral/cyan.|


# 10 | Master Asset Checklist

> Use this checklist to track production status for every asset. P1 = must be complete before App Store submission. P2 = must be complete for quality launch. P3 = post-launch milestone.

## 10.1  Summary Count

|**Category**|**P1 Assets**|**P2 Assets**|**P3 Assets**|
|---|---|---|---|
|**Logo & Wordmark**|11|6|0|
|**App Icon Suite (all sizes)**|10|5|0|
|**Game Icons (15 games)**|15|0|0|
|**Category heroes & badges**|5|10|0|
|**Application-level (splash, onboarding, states)**|10|10|0|
|**Avatars & rank badges**|4|8|0|
|**Achievement badges**|5|6|1|
|**Memory Match specific**|5|3|0|
|**Sequence Recall specific**|4|2|0|
|**Pattern Memory specific**|5|2|0|
|**Sudoku Duel specific**|7|1|0|
|**Logic Grid specific**|5|2|0|
|**Code Breaker specific**|7|2|0|
|**Spot the Difference specific**|5|13|0|
|**Color Rush specific**|5|1|0|
|**Focus Finder specific**|5|3|0|
|**Puzzle Race specific**|4|9|0|
|**Rotation Master specific**|6|3|0|
|**Path Finder specific**|7|2|0|
|**Word Builder specific**|9|3|0|
|**Anagram Attack specific**|7|3|0|
|**Vocabulary Showdown specific**|7|1|0|
|**UI / Navigation icons**|13|0|0|
|**Notification & system assets**|4|6|0|
|**TOTAL**|≈ 189|≈ 101|≈ 1|

## 10.2  Highest-Impact Assets — Prioritise First

The following 10 assets have the widest visual impact and should be the first commissions issued:

- Memory Match card back design: appears on every flip in the most-played game.
- App icon: first thing every user sees; represents the entire brand.
- Splash screen: brand moment that sets the tone before any UI is visible.
- All 15 game icons: appear on every game selector, lobby, and notification.
- Spot the Difference scene pairs (Easy × 10): launch-blocking game content.
- Sudoku Duel grid assets (cells, backgrounds): most technically used Logic game.
- Code Breaker colour peg set: used on every turn of every game session.
- Onboarding illustrations × 3: first impression for every new user.
- Word Builder letter tile set: appears on every turn in the highest-engagement Language game.
- Default avatar set (12): profile identity for all users before photo upload.

## 10.3  Production Checklist — P1 Assets

### Brand & Identity

☐   App icon — all iOS sizes generated from master 1024×1024

☐   Android adaptive icon — foreground + background layers

☐   Wordmark SVG — horizontal, dark bg

☐   Logomark SVG — standalone mark, dark + light versions

☐   Splash screen — iOS @3×

☐   Splash screen — Android XXXHDPI

☐   Push notification icon — iOS (white on transparent)

☐   Push notification icon — Android (white on transparent)

### Category & Navigation

☐   All 5 category badge icons (Memory, Logic, Attention, Spatial, Language)

☐   All 15 game card thumbnails (600×360 px)

☐   All 15 game icons (512×512 px PNG + SVG source)

☐   Tab bar icons — 4 tabs, active + inactive states (8 SVGs total)

☐   Core UI icons — back, close, hint, notification, chat, trophy (7 SVGs)

### Game-Specific P1 Assets

☐   Memory Match: card back design, symbol set (18 pairs), in-game header

☐   Sequence Recall: node states (lit/idle/correct/wrong), header

☐   Pattern Memory: grid cell states (filled/empty/player/error), header

☐   Sudoku Duel: cell states (clue/input/error/hint), grid bg, hint button, header

☐   Logic Grid: cell states (true/false/empty), header

☐   Code Breaker: all peg colours (8 × 64px), feedback pegs, code shield, header

☐   Spot the Difference: scene pairs Easy × 10 pairs, found/wrong markers, header

☐   Color Rush: word display bg, response zone states, colour buttons, header

☐   Focus Finder: clutter scenes Easy × 8, target highlight ring, found stamp, target card, header

☐   Puzzle Race: puzzle image set Easy × 12, header

☐   Rotation Master: 20 base shapes, answer tile states (4), header

☐   Path Finder: wall/floor/player/start/end tiles, solved path, header

☐   Word Builder: letter tile states (4), chain spec, rarity badges, header

☐   Anagram Attack: tile states, shuffle icon, invalid shake spec, timer states, header

☐   Vocabulary Showdown: word card, match option cards (4 states), speed badge, header

## 10.4  File Delivery Format

|**Asset Type**|**Required Formats**|**Notes**|
|---|---|---|
|**Icons & badges**|SVG + PNG @1× & @2×|SVG is source of truth. PNG exports at 1× and 2× for Flutter asset resolution.|
|**Illustrations**|PNG @2× minimum|Save at 2× target display size. Lossless PNG for game content, compressed for marketing.|
|**Animations**|Lottie JSON|Use After Effects + Bodymovin or Rive. Validate playback in LottieFiles before delivery.|
|**Logos & wordmarks**|SVG + PNG @4×|SVG for all digital use. High-res PNG for print/marketing contexts.|
|**Scene images**|PNG @2× (800×600 = 1600×1200px)|WebP conversion handled by Flutter build. Deliver PNG masters.|

## 10.5  Naming Convention

All files must follow this naming convention exactly to integrate with the Flutter asset pipeline:

`[type]_[game-or-scope]_[variant]_[size].ext`

Examples:

- `icon_memory-match_512.png`
- `tile_letter_selected_96.svg`
- `scene_living-room_v1_1600x1200.png`
- `badge_achievement_brain-boss_256.png`
- `header_sudoku-duel_750x120.svg`

---

**MIND WARS**

*Brand System & Asset Requirements | ~290 Total Assets | v1.0*

March 2026 | CONFIDENTIAL