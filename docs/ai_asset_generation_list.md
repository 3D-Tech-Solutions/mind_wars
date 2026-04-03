# AI Asset Generation List

March 2026

This document is a generator-ready asset brief for AI Agent Developers who specialize in image, illustration, icon, and motion generation. It converts [branding.md](branding.md) into a practical production queue with prompt guidance, output constraints, and delivery rules.

Use this together with [branding.md](branding.md), [branding_integration_checklist.md](branding_integration_checklist.md), and [branding_rollout_plan.md](branding_rollout_plan.md).

## Important Usage Note

This document is the creative-generation brief.

It is correct for:

- style direction
- prompt construction
- priority batching
- output constraints

It is not the final source of truth for exact repo drop locations or final filenames.

For exact asset placement and naming inside this repository, use:

- [ALPHA_ASSET_DROP_MANIFEST.md](ALPHA_ASSET_DROP_MANIFEST.md)
- [assets/branding/README.md](../assets/branding/README.md)
- [assets/games/README.md](../assets/games/README.md)
- [assets/fonts/README.md](../assets/fonts/README.md)

If there is any conflict between prompt wording here and exact file placement, the manifest and asset-folder README files should win.

## Quick Status Matrix

Use this table as the fast checkpoint for what is already well-defined and what still needs creation or refinement.

`Spec status` means whether this document defines clear production requirements.

`Description status` means whether the creative look is described well enough for direct generation without needing additional interpretation.

`Repo status` means whether the canonical asset tree already contains a usable alpha-ready version.

| Asset Area | Spec Status | Description Status | Repo Status | Primary Brief Section | Current State / Next Need |
| --- | --- | --- | --- | --- | --- |
| Brand core logos and splash | Complete | Clear | Partial | [Batch A](#batch-a-brand-core-and-store-presence) | Core SVG/PNG assets are imported, but derivative exports and native launcher packaging still need finishing. |
| Game icon suite | Complete | Clear | Partial | [Batch B](#batch-b-game-icon-suite) | Most canonical icons are imported; Color Rush still needs a final delivered asset set. |
| Category heroes and badges | Complete | Clear | Complete for alpha base | [Batch C](#batch-c-category-system) | Canonical category PNGs and SVG badge sources are present. |
| Onboarding illustrations | Complete | Clear | Missing | [Batch D](#batch-d-onboarding-and-system-illustrations) | Specs are defined, but the three onboarding slide illustrations still need final delivered assets. |
| Empty and error states | Complete | Clear | Missing | [Batch D](#batch-d-onboarding-and-system-illustrations) | Specs are defined, but the no-wars, waiting-results, offline, and generic-error assets still need to be created. |
| Default avatars | Complete | Clear | Partial | [Batch E](#batch-e-profile-and-badge-assets) | A large avatar library is imported, but the minimum curated launch set remains the required handoff target. |
| Rank badges and overlays | Complete | Clear | Partial | [Batch E](#batch-e-profile-and-badge-assets) | PNG and most SVG badge assets exist; Bronze SVG is still missing from the structured source set. |
| Achievement badges | Complete | Clear | Partial | [Batch F](#batch-f-achievement-badge-set) | Core PNG badges exist, but the remaining source-of-truth SVG deliveries are still needed for a fully clean bundle. |
| Motion assets | Complete | Clear | Partial | [Batch G](#batch-g-motion-assets) | Only the achievement unlock has a canonical repo filename; other motion assets still need final exported deliveries. |
| Spot the Difference scene pairs | Complete | Clear | Missing | [Spot the Difference Scene Pairs](#spot-the-difference-scene-pairs) | Full production specs exist, but all scene-pair assets still need to be created. |
| Focus Finder clutter scenes | Complete | Clear | Missing | [Focus Finder Clutter Scenes](#focus-finder-clutter-scenes) | Full production specs and prompt packs exist, but final scene files are not yet delivered. |
| Puzzle Race image sets | Complete | Clear | Missing | [Puzzle Race Image Sets](#puzzle-race-image-sets) | Production specs are defined, but the full puzzle illustration set still needs to be generated. |
| Memory Match symbol set | Complete | Clear | Missing | [Memory Match Symbol Set](#memory-match-symbol-set) | Specs are defined for the 18 base pairs and 12 hard extras, but the assets are not yet delivered. |
| Memory Match card back | Complete | Clear | Missing | [Memory Match Card Back](#memory-match-card-back) | Canonical filename and exact 512 SVG spec are defined, but the production asset is still needed. |
| Fonts | Complete | Clear | Missing | [Batch D](#batch-d-onboarding-and-system-illustrations) | Exact filenames are known, but the Orbitron and Space Mono font files are not committed yet. |
| Game-specific alpha widget assets | Partial | Mixed | Mostly missing | [Spot the Difference Scene Pairs](#spot-the-difference-scene-pairs), [Focus Finder Clutter Scenes](#focus-finder-clutter-scenes), [Puzzle Race Image Sets](#puzzle-race-image-sets), [Memory Match Symbol Set](#memory-match-symbol-set), [Memory Match Card Back](#memory-match-card-back) | The manifest lists the required files, but many in-game P1 widget assets still need explicit source deliveries. |

## 1. Core Direction

### Brand Positioning

Mind Wars sits at the intersection of cognitive training and competitive multiplayer. The visual output should feel:

- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- dark-first, not flat-black and empty

### Visual Rules

- Use dark-first surfaces built from deep navy and void black.
- Use electric cyan and coral as the main action accents.
- Keep imagery abstract and geometric.
- Do not use literal brains, war scenes, weapons, soldiers, explosions, blood, or military symbolism.
- Do not use photography for app UI assets.
- Avoid gradients except where specifically called for in the source brief.
- Keep icon systems simple enough to read at small mobile sizes.

### Brand Colors

- Void: `#090A12`
- Deep: `#0E1028`
- Surface: `#14183A`
- Line: `#1A2050`
- Cyan: `#00D4FF`
- Coral: `#E94560`
- Gold: `#FFB800`
- Purple: `#7C3AED`
- Text: `#EEF0FC`
- Muted: `#6868A0`

### Category Colors

- Memory: `#9333EA`
- Logic: `#2563EB`
- Attention: `#0891B2`
- Spatial: `#D97706`
- Language: `#DC2626`

### Canonical Design Property Matrix

These properties are the design baseline for every asset brief in this document.

If a later prompt is missing a property, inherit it from this matrix instead of improvising.

| Property | Canonical Requirement |
| --- | --- |
| Tone | Premium, intelligent, competitive, playful, and abstract. Never clinical, violent, childish, or mascot-led. |
| Shape Language | Geometric, vector-like, crisp silhouettes, controlled curves, and clean negative space. |
| Detail Level | Simple enough to read on mobile. Prefer one dominant motif and at most one supporting motif for icons and badges. |
| Surfaces | Dark-first using Void, Deep, Surface, and Line for base structure. Avoid empty flat-black compositions with no depth cues. |
| Accent Use | Cyan and Coral are the default action accents. Gold is reserved for reward, rank, crown, and achievement emphasis. |
| Category Color Use | Use the category color as the primary tint only for category-scoped assets or game assets belonging to that category. |
| Contrast | Maintain strong silhouette readability at small sizes. Icons should pass a tiny-launcher test, and badges should remain legible at 64-128 px. |
| Lighting And Effects | Prefer flat fills and restrained glow accents. Avoid heavy gradients, glossy 3D rendering, or noisy texture overlays. |
| Typography | Use display typography only for explicit wordmark assets. Do not rely on image-model text rendering for final production output. |
| Motion | Precise, purposeful, sharp, premium, and short. Default motion window is about 0.8s to 1.5s unless the asset explicitly needs a loop. |
| Background Policy | Use transparent backgrounds for marks, icons, badges, and overlays unless the asset explicitly requires a dark or full-frame background. |
| Hard Exclusions | No photography, no literal brain anatomy, no war or military imagery, no weapons, no blood, no clutter, no stock-logo feel. |

### Asset Family Defaults

Use these defaults before editing any individual prompt.

| Asset Family | Motif Rule | Background Rule | Color Rule | Detail Ceiling | Special Notes |
| --- | --- | --- | --- | --- | --- |
| Brand core | One central emblem or wordmark system | Transparent or dark | Brand palette first, category colors only if explicitly requested | Extremely low | Must read as platform branding before game content |
| Game icons | One gameplay metaphor | Dark category-tinted background | Category color plus limited brand accents | Very low | Must remain readable at launcher and card size |
| Category badges | One category symbol inside a ring or circular container | Transparent preferred | Category color dominant | Very low | Should visually match as a set |
| Hero illustrations | One ambient scene or systems metaphor | Full-frame dark | Category color led, brand accents secondary | Medium | Use depth through layering, not texture noise |
| Onboarding and system illustrations | One product story concept per frame | Full-frame dark or transparent depending on use | Brand palette first, category accents optional | Medium | Prioritize clarity over spectacle |
| Profile, rank, and achievement badges | One symbolic reward motif inside a strong frame | Transparent preferred | Gold for prestige, category color for specialization | Low | Keep symbols centered and trophy-like, not fantasy armor |
| Motion assets | One assembly, pulse, resolve, or countdown action | Transparent or dark depending on destination | Brand accents first | Low | Motion should feel engineered, not chaotic |
| Large content scenes | Multiple objects allowed, but organized around one scene theme | Full-frame dark | Controlled 4-6 color limit | Medium | Family-safe, readable, and designed for gameplay recognition |

### Editing Rule For Every Asset Entry

Before editing any individual asset brief below, make sure it explicitly answers these fields:

- asset family
- output type
- priority
- required dimensions
- background requirement
- primary palette
- allowed accent colors
- subject motif
- detail ceiling
- typography allowance
- readability target
- exclusions
- naming target

If a field is omitted in a specific prompt, inherit it from the canonical design property matrix and asset family defaults above.

The design-property sections above are the source of truth for style consistency. The prompts below are editable production briefs and should be tuned to match the matrix, not the other way around.

## 2. Delivery Rules For Asset Generators

Every asset request should include all of the following:

- output type: icon, illustration, badge, splash, onboarding, motion
- required dimensions
- background requirement: transparent, dark, or full-frame
- style constraints: flat vector, geometric, no photography, no literal brains or war imagery
- palette constraints: use only approved brand and category colors
- readability requirement: must remain clear on mobile and at small sizes where applicable
- file naming target based on the spec in [branding.md](branding.md#105-naming-convention)

## 3. Recommended Prompt Wrapper

Use this wrapper at the top of each image-generation request:

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

Use this wrapper for motion-generation requests:

> Create a short premium motion asset for the Mind Wars brand system. Style direction: fast, purposeful, clean, geometric, dark-first, premium mobile game UI, no cartoon slapstick, no particle chaos unless explicitly requested. Motion should read clearly on phone screens and feel sharp under 1.5 seconds unless otherwise specified.

## 4. Negative Prompt Guidance

Use these exclusions when the generation tool supports negative prompting:

- no photorealism
- no human faces
- no literal brain anatomy
- no battlefields
- no weapons
- no military insignia
- no fantasy armor
- no 3D plastic toy look
- no neon rainbow overload
- no soft pastel palette
- no childish mascot design
- no busy background noise
- no text unless specifically requested
- no watermark
- no stock-logo look

## 5. Priority Batches

### Batch A: Brand Core And Store Presence

These assets unblock the native shell and first impression.

#### A1. Logomark Master

- Type: logo mark
- Priority: P1
- Output: SVG plus high-res PNG
- Size: variable, export at 1024×1024 and 2048×2048
- Background: transparent and dark-background variants
- Prompt:

> Design a premium abstract mobile game logomark for Mind Wars. The mark must combine two symmetrical cyan arc structures suggesting cognitive duality with a central coral lightning bolt. Include subtle node intersections as filled circles. Keep it geometric, balanced, sharp, and iconic. No literal brain drawing. No war symbols. Flat vector style, dark-tech premium feel, clean silhouette, readable at app icon size.

#### A2. Wordmark Master

- Type: wordmark
- Priority: P1
- Output: SVG plus PNG
- Size: horizontal and stacked compositions
- Background: dark and transparent variants
- Prompt:

> Create a futuristic premium wordmark for the name Mind Wars using a geometric sci-fi type style inspired by Orbitron. The word MIND should feel lighter and the word WARS heavier. Use Mind Wars brand colors with MIND in near-white and WARS in electric cyan. Tight precision, clean spacing, strong digital competition feel, suitable for app splash and marketing.

Note: text-generation quality from image models can be unreliable. Final wordmark should be vector-refined after concept generation.

#### A3. App Icon Master

- Type: app icon
- Priority: P1
- Output: PNG plus source composition
- Size: 1024×1024 master
- Background: dark solid background
- Prompt:

> Create a premium iOS and Android app icon for Mind Wars using the brand logomark. Dark void background, cyan structural arcs, coral lightning bolt centerpiece, crisp high contrast, minimal but distinctive, luxurious mobile game utility feel, optimized for tiny launcher size, no text, no extra ornament.

#### A4. Splash Screen Artwork

- Type: splash composition
- Priority: P1
- Output: PNG
- Sizes: 1290×2796 and 1080×2340
- Background: full-frame dark
- Prompt:

> Create a mobile splash screen for Mind Wars on a deep void-black background. Center the logomark and wordmark with strong balance and negative space. The look should feel premium, minimal, and high-stakes. No gradients unless extremely subtle. No decorative clutter. Built for a sharp mobile startup experience.

#### A5. Notification Icon Source

- Type: monochrome symbol
- Priority: P1
- Output: SVG plus PNG
- Size: 256×256 source
- Background: transparent
- Prompt:

> Create a simplified white-only version of the Mind Wars logomark for mobile push notifications. It must remain readable as a tiny silhouette and work on transparent backgrounds.

### Batch B: Game Icon Suite

These assets are needed across game selection, lobbies, and notifications.

#### Global Requirements For All 15 Game Icons

- Type: app-style game icons
- Priority: P1
- Output: SVG, PNG 512×512, PNG 1024×1024
- Background: dark category-tinted background
- Style: single motif, maximum 3 core shapes, readable at 29pt

#### B1. Memory Match

> Create a flat geometric game icon for Memory Match. Show two overlapping cards, one face-down with a subtle abstract back pattern and one face-up revealing a symbol. Use the memory purple palette on a dark tinted background. Simple, crisp, premium, readable at tiny mobile size.

#### B2. Sequence Recall

> Create a flat geometric game icon for Sequence Recall. Show three circles connected by dashed arc paths with implied 1-2-3 progression through scale and layout. Use the memory purple palette on a dark tinted background.

#### B3. Pattern Memory

> Create a flat geometric game icon for Pattern Memory. Show a 3×3 dot or cell grid with an asymmetric arrangement of filled and outlined elements. Use the memory purple palette on a dark tinted background.

#### B4. Sudoku Battle

> Create a flat geometric game icon for Sudoku Duel. Show a 3×3 section of a Sudoku grid with three highlighted cells on a diagonal and a subtle sense of speed. Use the logic blue palette on a dark tinted background.

#### B5. Logic Grid

> Create a flat geometric game icon for Logic Grid. Show four nodes in a square with connecting edges and crossing diagonals, like a deduction network. Use the logic blue palette on a dark tinted background.

#### B6. Code Breaker

> Create a flat geometric game icon for Code Breaker. Show three code circles in a row and two smaller feedback circles below, one filled and one outlined. Use the logic blue palette on a dark tinted background.

#### B7. Spot the Difference

> Create a flat geometric game icon for Spot the Difference. Show two simple side-by-side shapes with one subtle change highlighted by a ring. Use the attention cyan palette on a dark tinted background.

#### B8. Color Rush

> Create a flat geometric game icon for Color Rush. Show three strong horizontal color bands based on Mind Wars brand accents. Make it abstract and crisp, not messy. Use the attention cyan family with controlled use of coral and gold.

#### B9. Focus Finder

> Create a flat geometric game icon for Focus Finder. Show a targeting reticle with three rings, crosshair lines, and a central dot. Use the attention cyan palette on a dark tinted background.

#### B10. Puzzle Race

> Create a flat geometric game icon for Puzzle Race. Show four puzzle pieces, three joined and one hovering near its slot with a dashed target cue. Use the spatial amber palette on a dark tinted background.

#### B11. Rotation Master

> Create a flat geometric game icon for Rotation Master. Show a bold L-shaped or T-shaped polygon with a curved rotation arrow. Use the spatial amber palette on a dark tinted background.

#### B12. Path Finder

> Create a flat geometric game icon for Path Finder. Show a simple maze grid with a highlighted route moving from lower left to upper right. Use the spatial amber palette on a dark tinted background.

#### B13. Word Builder

> Create a flat geometric game icon for Word Builder. Show three letter-tile squares in a rising staircase composition implying word construction. Use the language red palette on a dark tinted background.

#### B14. Anagram Attack

> Create a flat geometric game icon for Anagram Attack. Show three letter tiles arranged in a triangle with curved arrows suggesting rearrangement. Use the language red palette on a dark tinted background.

#### B15. Vocabulary Showdown

> Create a flat geometric game icon for Vocabulary Showdown. Show two open books facing each other with a duel-like composition. Use the language red palette on a dark tinted background.

### Batch C: Category System

#### C1. Category Hero Illustrations

- Type: wide header illustrations
- Priority: Memory P1, others P2
- Output: PNG
- Size: 1600×800 recommended master

Memory prompt:

> Create a wide premium hero illustration for the Memory category. Show an abstract field of glowing nodes in a grid-like cognitive network, with some nodes lit and some dimmed, suggesting remembered and forgotten information. Purple palette, geometric, elegant, no literal brain.

Logic prompt:

> Create a wide premium hero illustration for the Logic category. Show an abstract circuit or deduction web with nodes, paths, and clean flow lines. Blue palette, geometric, analytical, premium, minimal noise.

Attention prompt:

> Create a wide premium hero illustration for the Attention category. Show a strong cyan reticle or focus field isolating one bright target within abstract noise. Geometric, high contrast, selective-attention metaphor.

Spatial prompt:

> Create a wide premium hero illustration for the Spatial category. Show floating geometric solids such as cubes, prisms, and pyramids above a subtle amber grid plane. Precise, architectural, premium.

Language prompt:

> Create a wide premium hero illustration for the Language category. Show abstract letter tiles or symbolic glyph blocks moving in a controlled cascade, with some partial word formations implied. Red palette, geometric, elegant.

#### C2. Category Badges

- Type: circular badge icons
- Priority: P1
- Output: SVG plus PNG 256×256

Memory badge prompt:

> Create a circular category badge for Memory using an abstract node cluster motif in purple with a tinted ring.

Logic badge prompt:

> Create a circular category badge for Logic using a clean node-and-edge geometric graph in blue.

Attention badge prompt:

> Create a circular category badge for Attention using a precise reticle motif in cyan.

Spatial badge prompt:

> Create a circular category badge for Spatial using an isometric cube or geometric volume in amber.

Language badge prompt:

> Create a circular category badge for Language using a stack or cascade of letter-tile forms in red.

### Batch D: Onboarding And System Illustrations

#### Delivery Specs For Batch D

- Onboarding slide production format: PNG
- Onboarding slide optional source format: SVG or editable layered source
- Onboarding slide exact alpha delivery size: 1500×2668 px each
- Onboarding slide aspect ratio: portrait
- Onboarding slide background: full-frame, no transparency
- Onboarding naming targets:
	- `assets/branding/onboarding/illustration_onboarding_play-your-way_1500x2668.png`
	- `assets/branding/onboarding/illustration_onboarding_train-your-brain_1500x2668.png`
	- `assets/branding/onboarding/illustration_onboarding_challenge-friends_1500x2668.png`
- Empty and error state production format: SVG
- Empty and error state exact dimensions: 400×300 px each
- Empty and error state background: transparent preferred unless a specific full-frame composition is required
- Empty and error naming targets:
	- `assets/branding/system/state_no-wars_400x300.svg`
	- `assets/branding/system/state_waiting-results_400x300.svg`
	- `assets/branding/system/state_offline_400x300.svg`
	- `assets/branding/system/state_generic-error_400x300.svg`
- Achievement modal animation production format: Lottie JSON
- Achievement modal animation exact dimensions: 400×400 px
- Achievement modal naming target:
	- `assets/branding/system/anim_achievement-unlock_400.json`

#### D1. Onboarding Slide 1: Play Your Way

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a portrait onboarding illustration for the Mind Wars mobile app.

**Theme:** Async mobile gameplay — emphasizing flexibility, turn-based freedom, and the ability to play on your own schedule.

DESCRIPTION:
Compose a vertical illustration showing the concept of flexible, asynchronous gameplay. Central visual ideas:

- **Player presence nodes:** Abstract avatar-like circles or geometric profiles scattered across the composition, representing multiple players in turn-based interaction
- **Time flow cues:** Stylized clocks, timers, or cyclic geometric patterns suggesting turn timing and async scheduling
- **Turn-based flow symbols:** Arrows or connection lines flowing between player nodes, showing move sequences without literal action
- **Message bubble or notification cue:** A small geometric notification panel suggesting real-time updates arriving during play

Keep all elements geometric and abstract — no characters or faces. Layer elements with varying opacity or line weights to create depth. Use dark-first background (Void/Deep/Surface), with Cyan and Coral accent pops on interactive flow elements.

COMPOSITION:
- Vertical portrait aspect (1500×2668 px)
- Center the primary "game flow" motif in the upper-middle section
- Place supporting player nodes and time cues around it
- Bottom third reserved for message text overlay
- Maintain generous margins for safe mobile text rendering

STYLE:
- Flat vector, no 3D, no photorealism
- Premium, game-UI-ready aesthetic
- Bold geometric shapes with clean silhouettes
- High contrast between background and accent colors
- No gradients except where specifically needed for depth layering
- Minimal shadow or depth effects — keep it flat

PALETTE:
- Dark-first base: Void (#090A12), Deep (#0E1028), or Surface (#14183A)
- Accent highlights: Cyan (#00D4FF) for turn-flow, Coral (#E94560) for player activity
- Optional: Muted (#6868A0) for secondary information elements

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text rendering; no watermark.

DESIGN TONE:
- Intelligent, not clinical
- Competitive, not violent
- Playful, not childish
- Abstract, not literal

FILE NAMING TARGET:
`assets/branding/onboarding/illustration_onboarding_play-your-way_1500x2668.png`

---

#### D2. Onboarding Slide 2: Train Your Brain

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a portrait onboarding illustration for the Mind Wars mobile app.

**Theme:** Cognitive training across five skill categories — showing variety, progression, and mental engagement.

DESCRIPTION:
Compose a vertical illustration centered on the five Mind Wars cognitive categories (Memory, Logic, Attention, Spatial, Language), each represented as a distinct abstract icon or badge, radiating outward from a central "competitive intelligence" motif.

Central motif ideas:
- An abstract node cluster or neural-network-like geometric pattern (no literal brain imagery)
- Alternatively, a stylized tournament bracket or ranking symbol suggesting competition

Five category radiators (one per direction, arranged in a circular/radial pattern):
- **Memory (Purple #9333EA):** An arc or stacked-layer icon
- **Logic (Blue #2563EB):** A branching decision-tree or geometric grid icon
- **Attention (Cyan #0891B2):** A reticle or concentric-circle icon
- **Spatial (Amber #D97706):** A rotating cube or polygon transformation icon
- **Language (Red #DC2626):** A letter-tile cascade or stacked-text icon

Connect each category icon to the center with subtle lines or geometric connectors. Vary line thickness and opacity to suggest a hierarchy or flow of information. Use background elements (abstract geometric shapes, subtle patterns) to fill negative space without creating noise.

COMPOSITION:
- Vertical portrait aspect (1500×2668 px)
- Center the main intelligence motif in the middle of the frame
- Radiate the five category icons around it at equal distances
- Upper third: intro area with space for headline
- Lower third: supporting design space, reserved for call-to-action text

STYLE:
- Flat vector, geometric, abstract
- Balanced symmetry with premium visual weight
- High contrast between dark background and colored category accents
- Clean lines, no gradients except minimal depth layering
- Icons should be bold and readable at small mobile sizes

PALETTE:
- Dark-first base: Void (#090A12) or Deep (#0E1028)
- Category color accents: Memory purple, Logic blue, Attention cyan, Spatial amber, Language red
- Connector lines: Cyan (#00D4FF) or Muted (#6868A0)

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no medical imagery; no war scenes; no weapons; no explosions; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text rendering.

DESIGN TONE:
- Intelligent and strategic
- Empowering, not intimidating
- Playful, not childish
- Abstract, not literal

FILE NAMING TARGET:
`assets/branding/onboarding/illustration_onboarding_train-your-brain_1500x2668.png`

---

#### D3. Onboarding Slide 3: Challenge Friends

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a portrait onboarding illustration for the Mind Wars mobile app.

**Theme:** Multiplayer social gameplay — connection, collaboration, and competitive challenge with friends.

DESCRIPTION:
Compose a vertical illustration showing an abstract multiplayer lobby environment where multiple players connect, compete, and communicate.

Visual elements:
- **Avatar nodes:** 4–6 abstract geometric avatar circles distributed across the scene, representing friends in a lobby
- **Connection lines:** Subtle geometric connectors (lines, curves, or network paths) linking avatars together, showing real-time connection and relationship
- **Chat or communication cue:** One or two small notification badges, speech-bubble-like shapes, or message indicators suggesting active communication
- **Game selector or bracket hint:** Optional smaller icons or panels suggesting available games or competitive structure
- **Lobby container:** Abstract boundaries (rectangles, geometric frames, or layered panels) suggesting the "room" or "space" where players gather

Keep all elements geometric, abstract, and non-character-focused. Use varying line weights and opacity to suggest hierarchy and information flow. Add subtle shading or depth layering (no gradients) to separate avatar nodes from background.

COMPOSITION:
- Vertical portrait aspect (1500×2668 px)
- Distribute avatars across the frame (avoid centering just one)
- Place connection lines and chat cues at strategic intersections
- Upper section: intro space for headline
- Middle section: main lobby composition with avatars and connections
- Lower section: supporting space for call-to-action text

STYLE:
- Flat vector, no 3D, no photorealism
- Clean, organized, premium visual language
- High contrast with accent pops for interactive elements
- Readable at mobile scale, not over-detailed
- Geometric precision with premium aesthetic

PALETTE:
- Dark-first base: Void (#090A12) or Deep (#0E1028)
- Avatar nodes: Mix of Surface (#14183A) with subtle color variety (category color accents optional)
- Connection lines: Cyan (#00D4FF) for active connection, or Muted (#6868A0) for secondary structure
- Chat/notification accents: Coral (#E94560) for active messages

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text rendering.

DESIGN TONE:
- Social, not isolating
- Inclusive, not exclusive
- Competitive, not hostile
- Playful, not childish
- Premium, intelligent aesthetic

FILE NAMING TARGET:
`assets/branding/onboarding/illustration_onboarding_challenge-friends_1500x2668.png`

#### D4. Empty And Error States

**Delivery Specs:**
- Format: SVG for all four states
- Optional review export: PNG at 512×512 px
- Exact dimensions: 400×300 px per state
- Aspect ratio: landscape (4:3)
- Background: transparent preferred (no background color unless compositionally needed)
- Naming targets:
  - `assets/branding/system/state_no-wars_400x300.svg`
  - `assets/branding/system/state_waiting-results_400x300.svg`
  - `assets/branding/system/state_offline_400x300.svg`
  - `assets/branding/system/state_generic-error_400x300.svg`

---

##### D4.1 — No Wars (Empty Lobby State)

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create an empty-state illustration for Mind Wars showing an idle, vacant competitive environment.

**Theme:** No active games or lobbies available — a calm, inviting "waiting for action" state.

DESCRIPTION:
Compose a landscape illustration (4:3 aspect) showing an abstract arena, board, or competitive space that is visibly empty but not sad or dejected. The illustration should feel calm and peaceful, inviting players to create new games.

Visual approach:
- **Arena/space motif:** An abstract geometric arena, tournament bracket frame, or game board rendered in simple flat shapes
- **Emptiness cue:** Sparse objects or clear negative space suggesting nothing is currently happening
- **Accent elements:** 1–2 Cyan or Gold geometric accents to suggest potential or readiness, not loss
- **Optional human element:** An abstract small avatar or profile circle (optional) to suggest "you are here but waiting"

Composition should feel open and spacious, not cramped. Use the dark-first palette with selective accent pops to create visual interest without noise.

COMPOSITION:
- Landscape 400×300 px canvas
- Center the main arena/space motif
- Allow generous negative space around it
- Place accent elements (Cyan lines, Gold highlights) strategically to suggest "ready to start"
- Bottom area suitable for accompanying UI text like "No active wars" or "Create a game"

STYLE:
- Flat vector, geometric, abstract
- Minimal, clean aesthetic
- Premium, not depressing
- Simple silhouettes, high contrast
- Transparent background preferred

PALETTE:
- Background: transparent (no fill)
- Primary shapes: Surface (#14183A) or Line (#1A2050) outlines
- Accent highlights: Cyan (#00D4FF) for "ready" cues, optionally Gold (#FFB800)
- Muted (#6868A0) for secondary structural elements

TONE:
- Calm, not sad
- Inviting, not lonely
- Ready, not empty
- Peaceful, not stagnant

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no sad emoticons or emoji; no literal brain anatomy; no war scenes; no weapons; no explosions; no dark, depressing imagery; no graffiti or worn-down aesthetic.

---

##### D4.2 — Waiting For Results (Pending Turns State)

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create an empty-state illustration for Mind Wars showing the passage of time while waiting for opponent moves or game results.

**Theme:** Time passing, pending results, turn-based waiting — suggest patience and progress without showing literal clocks.

DESCRIPTION:
Compose a landscape illustration showing abstract time-passing or pending-state visuals. The illustration should feel active and patient, not anxious or slow.

Visual approach:
- **Primary motif:** An abstract hourglass, stopwatch, timer dial, or cyclic time symbol rendered geometrically (no realism)
- **Time flow elements:** Stylized sand particles, timer rings, or cyclic arcs suggesting the passage of time
- **Progress indicator (optional):** A subtle progress bar, phase indicator, or cyclic pattern suggesting incremental advancement
- **Accent animation cues:** Cyan or Coral geometric accents to suggest active processes running in the background

The composition should feel dynamic and forward-moving, not static or frustrated.

COMPOSITION:
- Landscape 400×300 px canvas
- Center the primary time motif (hourglass, stopwatch, or timer)
- Distribute time-flow elements around it (sand particles, ring arcs, etc.)
- Use Cyan accents to show "processes running"
- Frame with geometric borders or background layers suggesting the "game is progressing"
- Bottom area suitable for accompanying UI text like "Waiting for opponent" or "Game in progress"

STYLE:
- Flat vector, geometric, abstract
- Dynamic, forward-moving aesthetic
- Premium, sophisticated
- Clear visual hierarchy
- Transparent background preferred

PALETTE:
- Background: transparent (no fill)
- Primary time motif: Line (#1A2050) or Surface (#14183A)
- Time-flow accents: Cyan (#00D4FF) or Coral (#E94560)
- Structural elements: Muted (#6868A0)

TONE:
- Patient, not anxious
- Active, not passive
- Progressive, not stalled
- Premium, intelligent feel

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no literal clock faces with numbers; no stressed faces; no anxious emoji; no literal brain anatomy; no war scenes; no weapons; no explosions; no sand textures or realistic grains.

---

##### D4.3 — Offline (Disconnected State)

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create an offline-state illustration for Mind Wars showing a disconnected or network-unavailable condition.

**Theme:** Network disconnection, no internet, offline mode — clear visual indication of connection loss without negativity.

DESCRIPTION:
Compose a landscape illustration showing a broken or disconnected network/connection motif. The illustration should be clear and informative, not alarming or distressing.

Visual approach:
- **Primary motif:** An abstract network node system, connection topology, or link symbol with a visible break, gap, or severed connection
- **Disconnection cue:** A deliberately broken line, separated nodes, or a gap in the middle of a connection line
- **Secondary elements:** Optional individual node shapes to represent devices or services
- **Color treatment:** Cyan (#00D4FF) for the disconnected/broken aspect, emphasizing the technical nature of the disconnection

The composition should feel informative and temporary, suggesting a recoverable state.

COMPOSITION:
- Landscape 400×300 px canvas
- Center the main network/connection motif with the break or gap clearly visible
- Distribute node shapes around it to suggest a system topology
- Use Cyan to highlight the break point
- Frame with subtle geometric borders
- Bottom area suitable for accompanying UI text like "No connection" or "Offline mode"

STYLE:
- Flat vector, geometric, abstract
- Technical, not organic
- Clear and readable
- Premium, clean aesthetic
- Transparent background preferred

PALETTE:
- Background: transparent (no fill)
- Network nodes: Surface (#14183A) or Line (#1A2050)
- Connection lines (intact): Muted (#6868A0)
- Broken/disconnected element: Cyan (#00D4FF)
- Optional structural accents: Deep (#0E1028)

TONE:
- Informative, not alarming
- Technical, not emotional
- Temporary, not permanent
- Clear, not confusing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no satellite dishes or towers; no literal wifi symbols; no angry faces; no error-message aesthetics; no skull imagery; no war scenes; no weapons; no explosions; no realistic wire textures.

---

##### D4.4 — Generic Error (System Error State)

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a generic error-state illustration for Mind Wars showing an unexpected system or application error.

**Theme:** Unexpected system failure, app malfunction, server error — clear visual indication without distress.

DESCRIPTION:
Compose a landscape illustration showing a scrambled, glitching, or disrupted geometric grid or structure. The illustration should feel technical and recoverable, not catastrophic.

Visual approach:
- **Primary motif:** A geometric grid, checkerboard pattern, or structured layout that is visibly scrambled, misaligned, or disrupted
- **Glitch cue:** Offset geometric shapes, misaligned grid lines, or shifted color blocks suggesting a system hiccup
- **Color treatment:** Coral (#E94560) to suggest alert/error, combined with dark navy to maintain the dark-first aesthetic
- **Optional secondary elements:** Small geometric fragments or scattered pieces suggesting a temporary disruption

The composition should feel like a technical issue that can be recovered, not a complete failure.

COMPOSITION:
- Landscape 400×300 px canvas
- Center the primary scrambled grid or disrupted structure
- Offset or misalign elements to create the "glitch" visual effect
- Use Coral accents to highlight the error points
- Frame with geometric borders suggesting the system is still partially intact
- Bottom area suitable for accompanying UI text like "Something went wrong" or "Try again"

STYLE:
- Flat vector, geometric, abstract
- Deliberately structured but scrambled
- Technical and modern aesthetic
- Premium, not careless
- Transparent background preferred

PALETTE:
- Background: transparent (no fill)
- Primary grid/structure: Line (#1A2050) or Surface (#14183A)
- Scrambled/error elements: Coral (#E94560)
- Offset pieces: Coral or optional Purple (#7C3AED)
- Structural frames: Deep (#0E1028) or Muted (#6868A0)

TONE:
- Technical, not emotional
- Recoverable, not permanent
- Alert, not alarming
- Professional, not careless

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no angry faces or frowning emoji; no red alarm lights or danger symbols; no explosive imagery; no literal brain anatomy; no war scenes; no weapons; no explosions; no distressed or destroyed aesthetics; no realistic error-code text.

### Batch E: Profile And Badge Assets

#### Delivery Specs For Batch E

- Default avatar production format: SVG
- Default avatar optional review export: PNG
- Default avatar exact dimensions: 256×256 px each
- Default avatar required launch count: 12 curated avatars
- Default avatar naming pattern:
	- `assets/branding/avatars/avatar_default_01.svg`
	- `assets/branding/avatars/avatar_default_12.svg`
- Rank badge production format: SVG plus PNG export
- Rank badge exact dimensions: 128×128 px each
- Rank badge naming pattern:
	- `assets/branding/badges/badge_rank_bronze_128.svg`
	- `assets/branding/badges/badge_rank_silver_128.svg`
	- `assets/branding/badges/badge_rank_gold_128.svg`
	- `assets/branding/badges/badge_rank_platinum_128.svg`
	- `assets/branding/badges/badge_rank_diamond_128.svg`
- Crown overlay production format: SVG plus PNG export
- Crown overlay exact dimensions: 128×128 px
- Crown overlay naming pattern:
	- `assets/branding/badges/overlay_big-brain-crown_128.svg`
	- `assets/branding/badges/overlay_big-brain-crown_128.png`
- Streak flame production format: SVG plus PNG export
- Streak flame exact dimensions: 64×64 px
- Streak flame naming pattern:
	- `assets/branding/badges/icon_streak-flame.svg`
	- `assets/branding/badges/icon_streak-flame_64.png`

#### E1. Default Avatars

- Type: abstract profile set
- Priority: P1
- Output: SVG plus PNG 256×256
- Count: 12
- Prompt:

> Create a set of 12 default avatars for Mind Wars. Each avatar should be a distinct abstract geometric composition that feels identity-like without showing a human face. Use the Mind Wars palette, dark-first backgrounds, premium multiplayer game feel, and enough variation for players to feel visually distinct.

#### E2. Rank Badges

- Bronze, Silver, Gold, Platinum, Diamond
- Output: SVG plus PNG 128×128
- Prompt:

> Create a premium hexagonal rank badge for a competitive cognitive game. Strong geometric frame, central tier mark area, dark premium interior, polished but not fantasy-like. Generate one palette variant for [BRONZE or SILVER or GOLD or PLATINUM or DIAMOND].

#### E3. Big Brain Crown Overlay

> Create a compact gold crown overlay badge for the lobby admin role in Mind Wars. It should sit cleanly over an avatar without obscuring the avatar design.

#### E4. Streak Flame

> Create a compact streak icon for Mind Wars using a stylized geometric flame in coral and gold. Premium, sharp, mobile-readable, energetic but controlled.

### Batch F: Achievement Badge Set

- Type: achievement badges
- Output: SVG plus PNG 256×256
- Style: hexagonal frame, category fill, white symbol, optional legendary glow
Here is the batch of 12 premium achievement badges for Mind Wars, ready for asset generation.

Each prompt adheres to the visual rules and incorporates the recommended wrapper and specific requirements for hexagonal frames, category fills, and motifs.

---

### General Achievement Badges

* **First Win:**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for First Win. It features a flat vector gold star (brand color `#FFB800`) symbol centered within a geometric hexagonal badge frame. The hexagonal fill uses deep navy (`#0E1028`) with an electric cyan (`#00D4FF`) hexagonal border. Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Undefeated (5-win streak):**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for a 5-win streak. It features a bold, flat vector crown motif in gold (`#FFB800`) inside a geometric hexagonal frame. The hexagonal fill uses coral (`#E94560`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Brain Boss (Master Achievement):**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Brain Boss." The design combines a flat vector trophy silhouette and a central lightning bolt motif in coral (`#E94560`) and gold (`#FFB800`) accents, set against a deep navy (`#0E1028`) hexagonal fill with a gold (`#FFB800`) border. Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Speed Demon (General Speed):**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Speed Demon." The design uses a flat vector stopwatch with speed lines motif in a cyan-led palette (using brand cyan `#00D4FF`) inside a hexagonal frame. The hexagonal fill uses attention cyan (`#0891B2`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Perfect Score:**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Perfect Score." The design features a flat vector bullseye or perfect target motif in gold (`#FFB800`) inside a hexagonal frame. The hexagonal fill uses deep navy (`#0E1028`) with a gold (`#FFB800`) hexagonal border. Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **No Hints (Challenge):**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "No Hints." The design features a flat vector lightbulb with a strike-through motif inside a hexagonal frame. The palette is purple-led, using memory purple (`#9333EA`) for the hexagonal fill and a white symbol. Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

### Category Master Badges

* **Memory Master:**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Memory Master." It features a simplified, flat vector cognitive-arc or node-cluster motif as a white symbol inside a geometric hexagonal frame. The hexagonal fill uses memory purple (`#9333EA`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Logic Legend:**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Logic Legend." It features a flat vector logic graph motif as a white symbol inside a geometric hexagonal frame. The hexagonal fill uses logic blue (`#2563EB`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Attention Ace:**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Attention Ace." It features a flat vector reticle motif as a white symbol inside a geometric hexagonal frame. The hexagonal fill uses attention cyan (`#0891B2`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Spatial Savant:**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Spatial Savant." It features a flat vector rotating cube motif as a white symbol inside a geometric hexagonal frame. The hexagonal fill uses spatial amber (`#D97706`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

* **Word Wizard:**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium achievement badge for "Word Wizard." It features a flat vector letter-tile cascade motif as a white symbol inside a geometric hexagonal frame. The hexagonal fill uses language red (`#DC2626`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

### Legendary Badge

* **Legendary (All 15 Wins):**

> Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android. Create a premium legendary achievement badge for winning all 15 games. It uses the full Mind Wars abstract geometric emblem language as a centralized white symbol inside a hexagonal frame. The deep navy (`#0E1028`) fill is accented by a restrained line-based premium shimmer that cycles geometric accents through all five category colors: memory purple (`#9333EA`), logic blue (`#2563EB`), attention cyan (`#0891B2`), spatial amber (`#D97706`), and language red (`#DC2626`). Render this as a flat vector illustration on a transparent background, clear and readable at 256×256 master size.

### Batch G: Motion Assets

These are best suited to motion-capable AI or animation specialists after still-style approval is complete.

#### Delivery Specs For Batch G

- Preferred production format for all motion assets: Lottie JSON
- Preferred source format: layered After Effects or other editable motion source
- Splash assembly recommended composition: 1080×2340 px vertical with key animation centered inside a safe 1080×1080 zone
- Loading spinner recommended composition: 256×256 px square
- Achievement unlock exact composition: 400×400 px square
- Battle countdown recommended composition: 1080×1080 px square with transparent background support
- Background policy:
	- splash assembly: dark full-frame
	- loading spinner: transparent preferred
	- achievement unlock: transparent preferred
	- battle countdown: transparent preferred
- Naming pattern:
	- `anim_splash-assembly_1080x2340.json`
	- `anim_loading-spinner_256.json`
	- `assets/branding/system/anim_achievement-unlock_400.json`
	- `anim_battle-countdown_1080.json`

#### G1. Splash Assembly Animation

- Type: motion
- Priority: P2
- Output: Lottie JSON or layered motion source
- Duration: about 1.2s
- Prompt:

> Create a short splash animation for Mind Wars where cyan arc elements assemble into the logomark and a coral lightning bolt resolves at center. Motion should be precise, premium, fast, and clean, with no chaotic particles.

#### G2. Loading Spinner

> Create a looping loading animation for Mind Wars based on the logomark assembling and resolving in a continuous clean cycle. Premium, minimal, mobile-friendly.

#### G3. Achievement Unlock

> Create a short achievement unlock animation where a badge lands sharply into place with a controlled burst of particles. Premium mobile UI, no confetti overload.

#### G4. Battle Countdown

> Create a 3-2-1-GO countdown animation for Mind Wars using sharp geometric numerals, cyan and coral accents, and strong competitive pacing.

#### G5. Game Feedback Motion Set

Request separately after UI direction is approved:

- Memory Match particle burst
- Sequence path draw animation
- Pattern reveal overlay
- Code reveal shield lift
- Puzzle snap flash
- Puzzle completion fireworks
- Word submitted cascade animation
- Pangram celebration

## 6. Largest Content Commissions

These are the biggest art-production items and should be assigned explicitly.

### Spot the Difference Scene Pairs

- Easy: 10 pairs
- Medium: 10 pairs
- Hard: 10 pairs
- Style: flat vector scene illustration, family-safe, geometric, 4-6 dominant colors, no photo textures
- Output type: paired scene illustrations
- Delivery format: PNG for production delivery
- Optional source format: layered SVG or editable vector source if available
- Exact dimensions: 800×600 px per image
- Pair structure: 2 images per pair, same dimensions and framing
- Total deliverables: 60 PNG files for the full set
- Aspect ratio: 4:3 landscape
- Background: full-frame, no transparency
- Naming pattern:
	- `scene_spot-the-difference_easy_01_a_800x600.png`
	- `scene_spot-the-difference_easy_01_b_800x600.png`
	- `scene_spot-the-difference_medium_01_a_800x600.png`
	- `scene_spot-the-difference_hard_01_b_800x600.png`
- Difference count by difficulty:
	- Easy: 3 differences per pair
	- Medium: 5 differences per pair
	- Hard: 7-8 differences per pair
- Prompt template:

> Create a flat vector scene illustration pair for a mobile Spot the Difference game. Scene theme: [living room, park, kitchen, playground, etc.]. Produce two nearly identical versions with [3, 5, or 7-8] deliberate differences depending on difficulty. Keep shapes simple, readable, family-safe, colorful, premium, and mobile friendly.

### Focus Finder Clutter Scenes

- Easy: 8 scenes
- Medium: 8 scenes
- Hard: 8 scenes
- Output type: full-frame clutter scene illustrations
- Delivery format: PNG for production delivery
- Optional source format: layered SVG or editable vector source if available
- Exact dimensions: 2048×2048 px per image
- Aspect ratio: 1:1 square
- Total deliverables: 24 PNG files for the current scene pack
- Background: full-frame dark, no transparency
- Naming pattern:
	- `scene_focus-finder_easy_01_2048x2048.png`
	- `scene_focus-finder_medium_01_2048x2048.png`
	- `scene_focus-finder_hard_01_2048x2048.png`

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast, no photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter beyond intentional scene design. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game. 
Scene Theme: Abstract-geometric desk workspace.

This is an EASY difficulty scene. Build the composition with:
- clear object separation,
- bold, simple silhouettes,
- 12–20 distinct objects,
- no micro-details,
- enough breathing room that target objects can be isolated cleanly on mobile.

OUTPUT TYPE:
- full-frame flat vector scene illustration

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- maintain subtle depth using geometric layering, not gradients

STYLE CONSTRAINTS:
- flat vector
- geometric, abstract, premium visual language
- no photorealism
- no literal brain imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text or lettering on objects

PALETTE:
Use only approved Mind Wars colors:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, Text #EEF0FC, Muted #6868A0.
Optional accent category colors may appear subtly: Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- limited, intentional accent pops (Cyan and Coral)
- 4–6 total visible colors in the final scene

EASY-LEVEL CLUTTER DIRECTION:
Create a geometric desk environment containing larger, clear shapes. Include objects such as:
- stacked abstract notebooks,
- blocky pen cup with 2–3 geometric pens,
- simplified tablet or device shape,
- abstract lamp silhouette,
- angled papers or slabs,
- small geometric tokens or chips,
- a simple mug silhouette.

Avoid ultra-small objects. Keep object spacing readable.

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- dark-first, premium aesthetic

READABILITY REQUIREMENT:
- All objects must maintain clarity at reduced mobile scale.
- Target objects should stand out cleanly when isolated later.
- No excessive visual noise or micro-textures.

FILE NAMING TARGET:
MW_FocusFinder_Easy_DeskScene_01.png

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no 3D glossy toys; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo style.

Each scene uses:

*   **Mind Wars dark‑first palette**
*   **flat vector geometric style**
*   **premium, abstract, game‑UI feel**
*   **EASY difficulty** → readable shapes, 12–20 objects, strong silhouette clarity
*   **Cluttered but not noisy**, with clean object separation
*   **Fully family‑safe and on‑brand**

You now have **8 total Easy scenes**.

***

# ✅ EASY SCENE 2 — *Abstract-Geometric Workbench*

**Scene Theme:** Abstract-geometric workbench with scattered creative tools.

Description:  
A flat vector workbench scene containing **12–20 simplified, blocky maker‑style objects** arranged with clear spacing. Include items such as:

*   geometric pliers and a ruler-like bar
*   stacked rectangular tool boxes
*   abstract screws/bolts rendered as hex tokens
*   simplified cutting mat grid panel
*   two or three angled slabs suggesting wooden boards
*   small geometric tools like a square, chisel shape, or tiny clamps
*   a simple lamp or overhead bar for illumination shape

Keep silhouettes bold and readable. Accent a few objects with Cyan and Coral. Maintain a dark-first tabletop surface using Void / Deep / Surface tones.

***

# ✅ EASY SCENE 3 — *Abstract-Geometric Kitchen Counter*

**Scene Theme:** Minimal abstract kitchen counter workspace.

Description:  
A geometric kitchen prep area featuring **12–20 bold objects**, such as:

*   cutting-board slab
*   simplified pot silhouette
*   stacked bowl forms
*   geometric fruit shapes (triangles, circles)
*   two utensils in abstract shapes
*   a blocky kettle or pitcher
*   angled panels representing cabinets or tiles

All shapes stay abstract and geometric, no realism or texture. Use Cyan/Coral sparingly for highlights (edges or handles). Maintain strong separation so target objects can be isolated cleanly.

***

# ✅ EASY SCENE 4 — *Abstract-Geometric Study Corner*

**Scene Theme:** Simple study/writing corner with angular shapes.

Description:  
A reading/study nook containing **12–20 objects**, for example:

*   stacked book-like rectangular blocks
*   a geometric desk lamp
*   heavy outline tablet or e-reader
*   bookmark-like triangle shapes
*   notepad slabs
*   abstract cup or pencil holder
*   simple wall panel shapes

Keep spacing generous, silhouettes chunky, and composition dark-first with Cyan/Coral accent pops. Avoid text on books.

***

# ✅ EASY SCENE 5 — *Abstract-Geometric Market Stall*


Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

SCENE THEME:
Simple geometric market vendor table.

DESCRIPTION:
A marketplace table scene with **12–20 abstract objects**, such as:

*   geometric fruit/vegetable tokens
*   rectangular crates
*   bowl/nightstand-like containers
*   simple canopy shapes
*   blocky jars
*   angled display boards
*   coins or tokens as circular shapes

Make sure objects remain large and simple. Use category colors lightly to vary accents while keeping the palette Mind Wars–true.


REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

# ✅ EASY SCENE 6 — *Abstract-Geometric Workshop Shelf*

Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A shelf system with spaced-out workshop items.

Description:  
A wall shelf environment containing **12–20 clear geometric items**, possibly including:

*   stacked rectangular bins
*   blocky bottles or spray shapes
*   chunky wrench-like silhouette
*   geometric boxes
*   small containers and cylinders
*   simplified gears as shape tokens (abstract, not mechanical realism)

Shelves should read as simple rectangular bars. Keep silhouettes bold and reduce micro-details.


REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

# ✅ EASY SCENE 7 — *Abstract-Geometric Beach Setup*

Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A stylized beach setup with geometric props.

Description:  
An abstract beach environment with **12–20 simple objects**, such as:

*   umbrella triangles or polygon shapes
*   blocky beach chair silhouette
*   geometric shells as simple ovals/triangles
*   small bucket/pail shapes (vector simple)
*   towel rectangles
*   waves represented by layered angled bands or arcs

Keep shapes flat and geometric — nothing cute or cartoonish. Maintain a dark-first reinterpretation of a bright scene (e.g., deep blues instead of light sand).

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

# ✅ EASY SCENE 8 — *Abstract-Geometric Lab Table*
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A simple but techy lab table.

Description:  
A scientific/tech workspace with **12–20 readable geometric props**, including:

*   simple beaker/tube silhouette shapes (no realism, no liquid effects)
*   stacked rectangular data pads
*   geometric vials rendered as cylinders with capped tops
*   small scatter of tokens or chips
*   angled equipment slab
*   abstract monitor panel

Avoid any content that feels medical or clinical — keep it abstract and premium. Use Cyan/Coral accent stripes selectively to reinforce the Mind Wars visual identity.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

# ✅ MEDIUM SCENE 1 — *Abstract-Geometric Desk With Overlapping Tools*
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Dense desk workspace with layered tools and materials.

Description:  
A moderately cluttered geometric desk scene containing **16–28 objects** with slightly tighter spacing and subtle overlaps. Include items such as:

*   stacked notebooks with angled alignment
*   overlapping device panels (tablet, data pad)
*   multiple geometric pens and markers crossing each other
*   layered sheets or slabs partially hidden beneath objects
*   small block tokens (chips, cubes, sliders) scattered around
*   angular lamp silhouette extending into frame
*   geometric clips, tabs, or brackets for added visual complexity

Maintain detectable object boundaries, but allow slight occlusion to increase difficulty.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.
***

# ✅ MEDIUM SCENE 2 — *Abstract-Geometric Workshop With Tiered Tools*
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A workshop table with tools arranged in tiered layers.

Description:  
A workshop scene featuring **16–28 geometric objects**, including:

*   overlapping rectangular tool trays
*   similar silhouettes of plier-like shapes
*   multiple rulers/bars layered at different angles
*   abstract bolts and hex tokens in clusters
*   chisels or knife-like vector shapes
*   layered boards in staggered orientations
*   small clamps and mechanic shapes aligned along edges

Object shapes should be distinct but visually similar enough to create challenge.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***



# ✅ MEDIUM SCENE 2 — *Abstract-Geometric Workshop With Tiered Tools*

# ✅ MEDIUM SCENE 3 — *Abstract-Geometric Kitchen Prep Area With Layered Containers*
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A geometric kitchen area with subtle object similarity.

Description:  
A kitchen workspace containing **16–28 objects**, such as:

*   stacks of bowls with similar silhouettes
*   multiple cutting-board slabs at slight angles
*   geometric utensils with similar profiles
*   jars and containers with only subtle shape differences
*   angled tiles or backsplash shapes for depth
*   simple pot/pan shapes overlapping slightly
*   abstract fruit/veg tokens in groups

Focus on clusters of near‑identical shapes to increase difficulty without hurting readability.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

# ✅ MEDIUM SCENE 4 — *Abstract-Geometric Study Corner With Parallel Surfaces*
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A reading/study zone with many paper- and slab-like shapes.

Description:  
A medium-difficulty study corner with **16–28 objects**, including:

*   many stacked or fanned-out papers/slabs
*   overlapping book silhouettes with similar dimensions
*   tablet or e-reader shapes placed at differing rotations
*   rectangular desk accessories with comparable shapes
*   geometric pen/pencil variants scattered around
*   abstract sticky note tiles

Objects should visually echo one another—more repetition than Easy scenes.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.





***

# ✅ MEDIUM SCENE 5 — *Abstract-Geometric Market Table With Similar Containers*

Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A reading/study zone with many paper- and slab-like shapes.

Description:  
A medium-difficulty study corner with **16–28 objects**, including:

*   many stacked or fanned-out papers/slabs
*   overlapping book silhouettes with similar dimensions
*   tablet or e-reader shapes placed at differing rotations
*   rectangular desk accessories with comparable shapes
*   geometric pen/pencil variants scattered around
*   abstract sticky note tiles

Objects should visually echo one another—more repetition than Easy scenes.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.


**Scene Theme:** A dense vendor table with repeated shapes.

Description:  
A market scene featuring **16–28 items**, such as:

*   multiple crates with slight variations
*   bowls and containers in near-matching silhouettes
*   geometric produce tokens (circles, triangles, ovals) repeating in color groups
*   stacked jars rendered with consistent shape language
*   angled boards/signs overlapping behind objects

Clutter is denser but still readable. Many objects should look “same family” for difficulty.

***

# ✅ MEDIUM SCENE 6 — *Abstract-Geometric Workshop Shelf With Repeated Object Types*

Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** A multi-shelf layout with repeating forms.

Description:  
A shelf environment containing **16–28 objects**, including:

*   sets of identical or near-identical bottles/cylinders
*   multiple tool silhouettes with minor angular variations
*   geometric gear tokens repeated in clusters
*   bins and boxes in stacked or side-by-side arrangements
*   trays or flat panels behind objects for layered occlusion

Make silhouettes intentionally similar, but keep edges readable.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

# ✅ MEDIUM SCENE 7 — *Abstract-Geometric Beach Setup With Repeated Shapes*
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Beach scene using geometric reinterpretations.

Description:  
A stylized beach scene with **16–28 objects**, including:

*   repeating triangular umbrella shapes (different sizes)
*   multiple towel rectangles in slightly different orientations
*   similar bucket/pail silhouettes
*   geometric shell tokens repeated in clusters
*   angled wave bands creating background structure
*   chair silhouettes layered with minimal variation

Use subtle size/angle changes to create visual complexity.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

# ✅ MEDIUM SCENE 8 — *Abstract-Geometric Lab Table With Clusters of Similar Items*
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Techy lab table designed for moderate challenge.

Description:  
A lab workspace containing **16–28 objects**, such as:

*   multiple vial/cylinder silhouettes with tiny differences
*   geometric beaker shapes that echo each other
*   repeated tablet/data-pad slabs
*   clusters of identical chip/tile tokens
*   abstract monitor panel behind tools for layering
*   angled equipment blocks

Differences should require more careful attention than Easy scenes, but nothing microscopic.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

## ✅ HARD SCENE 1 — Abstract-Geometric Command Desk
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Dense abstract command desk workspace.

**Description:**  
A richly layered geometric command desk filled with **24–36 objects** and **multiple overlapping layers**. The dark desk surface is broken into angular panels and bands. Populate it with:

*   multiple stacked notebooks and data pads, partially overlapped and rotated at subtle angles
*   3–5 device panels (tablets/monitor tiles) arranged in a fan, some partially off-frame
*   several pen/marker silhouettes clustered in different cups, some pens lying across notebooks
*   overlapping document/paper slabs fanned out under devices and cups
*   small chip/tile tokens scattered in tight clusters
*   a geometric desk lamp whose arm passes over other objects
*   slim organizer trays with nearly identical rectangular dividers

Objects should often **overlap or partially obscure each other**, while still remaining distinguishable. Many items should share **very similar silhouettes** (e.g., several rectangles only slightly different in size/angle), forcing close visual attention. Maintain clear line work so target objects can still be isolated when cropped.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

## ✅ HARD SCENE 2 — Abstract-Geometric Precision Workshop Bench
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Complex workshop bench with repeated tool families.

**Description:**  
A tightly packed geometric workshop bench containing **24–36 objects**, designed for high visual density. The work surface is divided into angular zones. Include:

*   several nearly identical plier-like silhouettes at slightly different rotations
*   multiple ruler/straight-edge bars overlapping and crossing each other
*   stacked tool trays with similar compartments, some partially hidden below others
*   clusters of hex tokens and bolt-like shapes in small piles
*   chisel/knife-like vector tools with minimal shape differences
*   2–3 layered board/plank slabs underneath tools
*   a slim overhead lamp or tool rail cutting across the upper portion of the scene

Many tools should be **nearly indistinguishable at a glance**, differing only in angle, length, or accent color distribution. Use overlap and partial occlusion to increase search difficulty, while preserving crisp edges and separations.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

## ✅ HARD SCENE 3 — Abstract-Geometric Chef’s Prep Counter
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Intricate kitchen prep counter with repeated containers.

**Description:**  
A dark, premium geometric kitchen counter holding **24–36 objects** with lots of subtle repetition. The counter is segmented into angled regions. Populate with:

*   several stacks of bowls with almost identical shapes and only minor size differences
*   multiple cutting-board slabs layered and rotated, some partially concealed under bowls
*   3–5 utensil silhouettes (spatulas, knives, spoons) that share very similar forms
*   a cluster of jars and containers with consistent base shapes, varying only in height or lid style
*   2–3 pot/pan shapes overlapping each other or partially cropped by the frame
*   groups of abstract fruit/vegetable tokens (circles/triangles) spread near the edges
*   tiled backsplash panels or counter insets adding extra visual structure behind the clutter

Emphasize **shape similarity** and **careful object overlap** so it’s difficult to distinguish which bowl, jar, or slab is which at first glance.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.


***

## ✅ HARD SCENE 4 — Abstract-Geometric Study War Room
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Advanced study/analysis corner with layered documents and devices.

**Description:**  
A complex study/analysis scene with **24–36 objects**, designed like a cognitive war room in abstract form. Include:

*   numerous overlapping paper slabs and document rectangles, fanned and stacked
*   3–4 book-like blocks with very similar proportions, seen at varying angles
*   multiple tablet/e-reader panels partially overlapping books and papers
*   geometric sticky-note tiles clustered in groups, some partially hidden
*   several writing instruments (pens/pencils) aligned along edges or resting across pages
*   a simple lamp or wall panel crossing behind the main cluster
*   a few small tokens (clips, bookmarks) adding more detail at edges of stacks

Most rectangles should feel **very close in size and style**, with only slight rotation or layering differences, making it challenging to isolate a specific one quickly.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

## ✅ HARD SCENE 5 — Abstract-Geometric Market Display Grid
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Dense market vendor table with repeated containers and goods.

**Description:**  
A market table scene with **24–36 objects**, built as a tight grid of repeated shapes. The table surface is divided into geometric sections. Include:

*   multiple crates with nearly identical outlines, some stacked or overlapping
*   clusters of bowls and trays where several share the same silhouette and size
*   repeating geometric produce tokens (circles/ovals/triangles) arranged in small piles
*   several jars/bottles with almost identical shapes, varying only in height or accent color
*   angled display boards or panels slightly obscured by foreground items
*   a few coin/token clusters rendered as small circles in different groups

Objects should form **visually similar families** (crates with crates, bowls with bowls, jars with jars), tightening the cognitive demand while preserving clean, vector readability.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.


***

## ✅ HARD SCENE 6 — Abstract-Geometric Multi-Shelf Workshop Wall
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Multi-tiered workshop shelf system with repeated silhouettes.

**Description:**  
A vertical multi-shelf scene with **24–36 objects**, spanning several shelf levels. Each shelf holds families of similar shapes, such as:

*   rows of identical or near-identical bottles/cylinders on different shelves
*   repeated tool silhouettes (wrench-like, screwdriver-like) with small length or angle differences
*   stacked bins and boxes where several share matching dimensions
*   gear-like tokens grouped in small clusters at different heights
*   trays or flat panels running behind the objects, adding layered depth
*   a few hanging tools or elements intersecting the shelves subtly

Most objects should appear as **series and sets**, with small variations, demanding precise focus to distinguish one target from another.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.


***

## ✅ HARD SCENE 7 — Abstract-Geometric Night Beach Layout
Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

**Scene Theme:** Complex night beach arrangement with repeated props.

**Description:**  
A dark, stylized beach scene containing **24–36 objects**, using repeated families of geometric shapes. Build it with:

*   multiple triangular umbrella forms, similar in size, at various rotations and partial overlaps
*   several lounge/seat silhouettes that differ only slightly in angle or width
*   repeated towel rectangles, some partially under umbrellas or chairs
*   several identical bucket/pail silhouettes positioned near each other
*   clusters of small shell-like tokens (simple ovals/triangles) near the “sand” bands
*   layered wave bands or shoreline panels behind the objects for extra structure

The difficulty comes from **repetition and overlap**: many umbrellas, towels, chairs, and buckets looking very similar but arranged in subtly different ways.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.


***

## ✅ HARD SCENE 8 — Abstract-Geometric Advanced Lab Console

Create a production-ready mobile app asset for the Mind Wars brand system. 
Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. 
No photography, no literal brains, no war imagery, no weapons, no mascots, and no unintentional clutter. 
Use only the approved Mind Wars palette. 
Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create a dense but readable flat vector clutter scene for the Mind Wars “Focus Finder” cognitive game.

SCENE THEME:
High-density lab/console table with repeated instruments.

DESCRIPTION:
A techy lab scene with **24–36 objects**, heavily layered and rich in repeated forms. Include:

*   multiple vials/cylinders in tight rows, differing only slightly in height or cap design
*   several geometric beaker/Erlenmeyer-like silhouettes with similar proportions
*   repeated tablet/data-pad slabs stacked or overlapping under instruments
*   clusters of small chip/tile tokens scattered around equipment bases
*   one or two monitor panel shapes behind the main clutter, partially covered by foreground items
*   angular equipment blocks with similar base shapes, positioned at different angles

Most lab items should come in **clusters of very similar shapes**, encouraging fine-grained visual discrimination while keeping overall scene clean and vector-based.

REQUIRED DIMENSIONS:
- 2048 × 2048 px square canvas

BACKGROUND REQUIREMENTS:
- dark-first background (Void #090A12, Deep #0E1028, Surface #14183A)
- no transparent background
- convey depth through geometric layering (no gradients except minimal lighting accents)

STYLE CONSTRAINTS:
- flat vector, geometric, abstract
- premium, intelligent, non-childish visual language
- no photorealism
- no medical or clinical imagery
- no war/military symbolism
- no 3D plastic toy look
- no soft pastel palette
- no childish cartoon style
- no text on objects

PALETTE:
Use approved Mind Wars colors only:
Void #090A12, Deep #0E1028, Surface #14183A, Line #1A2050, 
Cyan #00D4FF, Coral #E94560, Gold #FFB800, Purple #7C3AED, 
Text #EEF0FC, Muted #6868A0.

Optional subtle category accents:
Memory #9333EA, Logic #2563EB, Attention #0891B2, Spatial #D97706, Language #DC2626.

Ensure:
- dark-first base
- 4–6 visible colors maximum
- intentional Cyan/Coral accent pops

DESIGN TONE:
- intelligent, not clinical
- competitive, not violent
- playful, not childish
- abstract, not literal
- premium, dark-first aesthetic

READABILITY REQUIREMENTS:
- all objects must remain readable at small mobile scale
- target objects must isolate cleanly when cropped
- avoid excessive noise or micro-detailing

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text; no watermark; no stock-logo look.

***

### Puzzle Race Image Sets

**Delivery Specs:**
- Easy: 12 unique illustrations
- Medium: 12 unique illustrations
- Hard: 8 unique illustrations
- Output type: square puzzle source illustrations
- Delivery format: PNG for production delivery
- Optional source format: layered SVG or editable vector source if available
- Exact dimensions: 1080×1080 px per image
- Aspect ratio: 1:1 square
- Background: full-frame, no transparency
- Naming pattern:
	- `scene_puzzle-race_easy_01_1080x1080.png` through `scene_puzzle-race_easy_12_1080x1080.png`
	- `scene_puzzle-race_medium_01_1080x1080.png` through `scene_puzzle-race_medium_12_1080x1080.png`
	- `scene_puzzle-race_hard_01_1080x1080.png` through `scene_puzzle-race_hard_08_1080x1080.png`

**General Style Direction for All Puzzle Scenes:**

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

Each puzzle scene must be:
- Bold geometric composition with strong visual elements
- High contrast between shapes for clear piece separation
- Abstract, no photorealism or literal representations
- Full-frame, no transparent areas
- Visually interesting and distinct from other puzzle scenes
- Premium, intelligent aesthetic
- No text, no labels, no characters, no faces

**Composition Guidelines:**
- Avoid centering a single focal point; use distributed composition
- Create visual rhythm through geometric repetition and color variation
- Balance dark backgrounds with accent pops (Cyan, Coral, Gold)
- Ensure puzzle pieces will be distinct when cut (varied colors and clear edges)

---

#### EASY SET (Difficulty 1) — 12 Puzzle Scenes

These scenes feature larger, clearer geometric elements with strong shape separation for easy piece identification.

##### Easy Puzzle 1: Stacked Abstraction
**Theme:** Layered geometric blocks and rectangles.
**Description:** A composition of stacked rectangular and square blocks in varying sizes, creating a Tetris-like arrangement. Use a dark Surface (#14183A) background with blocks in Muted (#6868A0), Cyan (#00D4FF), Coral (#E94560), and Gold (#FFB800). Blocks should be clearly separated with dark outlines for easy piece cutting.
**Design notes:** Full-frame fill, clear geometric boundaries, high contrast.

##### Easy Puzzle 2: Radiant Geometry
**Theme:** Radiating lines and bursts.
**Description:** A central point with geometric rays or lines radiating outward uniformly across the entire canvas. Alternate ray colors between Cyan and Gold on a dark background (Void #090A12 or Deep #0E1028). Vary ray lengths and thicknesses for visual rhythm.
**Design notes:** Symmetrical radial pattern, full-frame composition.

##### Easy Puzzle 3: Hexagonal Grid
**Theme:** Honeycomb or hexagonal tessellation.
**Description:** A field of regular hexagons filling the entire canvas, with alternating colors (Surface #14183A, Muted #6868A0, Cyan #00D4FF). Vary the color distribution to create visual interest without appearing random. Dark outline for each hexagon.
**Design notes:** Perfect geometric tessellation, balanced color distribution.

##### Easy Puzzle 4: Geometric Waves
**Theme:** Flowing wave patterns.
**Description:** 3–4 large undulating wave bands flowing across the canvas in parallel. Use alternating colors (Cyan, Coral, Gold, Purple) with a dark background. Waves should have smooth, bold curves with clear separation between each band.
**Design notes:** Smooth flowing shapes, clear band separation, full-frame.

##### Easy Puzzle 5: Angular Shards
**Theme:** Fractured or shattered geometric pieces.
**Description:** A composition of triangular and angular shapes arranged as if a grid or plane has been shattered. Use a mix of Surface (#14183A), Coral (#E94560), and Cyan (#00D4FF) on a dark Void (#090A12) background. Each shard should have clear edges and distinct colors.
**Design notes:** Angular geometry, varied shard sizes, high contrast.

##### Easy Puzzle 6: Concentric Circles
**Theme:** Nested circular rings.
**Description:** 5–7 concentric circles of varying diameters, each filled with alternating colors (Muted #6868A0, Cyan #00D4FF, Gold #FFB800, Surface #14183A). Dark background. Clear outline between each ring.
**Design notes:** Perfect circle geometry, balanced color rings.

##### Easy Puzzle 7: Gradient Blocks
**Theme:** Color-blocked composition with gradient-like effect.
**Description:** Large rectangular blocks arranged in rows and columns, with colors transitioning across the composition (e.g., from Void → Deep → Surface → Cyan → Coral). Each block should be distinct and clearly outlined. No actual gradients within blocks—use color banding.
**Design notes:** Bold block shapes, clear color progression.

##### Easy Puzzle 8: Diamond Tessellation
**Theme:** Diamond or rhombus-shaped tessellation.
**Description:** A field of diamond shapes filling the canvas, each rotated 45 degrees. Alternate colors between Surface (#14183A), Coral (#E94560), and Cyan (#00D4FF). Dark backgrounds and clear outlines for each diamond.
**Design notes:** Perfect geometric tessellation, balanced color alternation.

##### Easy Puzzle 9: Starburst Composition
**Theme:** Multiple geometric bursts or explosions.
**Description:** 3–5 geometric starburst or sunburst shapes distributed across the canvas, each with radiating triangular or wedge-shaped segments in Cyan or Coral. Dark background fills remaining space. Bursts vary in size and intensity.
**Design notes:** Multiple focal points, varied starburst sizes.

##### Easy Puzzle 10: Layered Rectangles
**Theme:** Overlapping rectangular planes.
**Description:** Multiple rectangular shapes of varying sizes overlapping and offset to create depth. Use dark background with shapes in Muted (#6868A0), Purple (#7C3AED), Cyan (#00D4FF), and Coral (#E94560). Clear outlines show overlap boundaries.
**Design notes:** Overlapping geometry, clear depth layering.

##### Easy Puzzle 11: Circular Nodes and Lines
**Theme:** Connected node network.
**Description:** 8–12 circular nodes (dots or small circles) distributed across the canvas, connected by geometric lines or curves in Muted (#6868A0). Accent nodes with Cyan or Coral colors. Dark background. Simple, readable network feeling.
**Design notes:** Clear node distribution, visible connection lines.

##### Easy Puzzle 12: Color-Blocked Mosaic
**Theme:** Large multi-colored geometric mosaic.
**Description:** A balanced composition of various geometric shapes (squares, hexagons, triangles) arranged as a mosaic using all accent colors (Cyan, Coral, Gold, Purple) on a dark background. Each shape should be clearly defined with outlines.
**Design notes:** Variety of shapes, balanced color distribution, premium tech-mosaic feel.

---

#### MEDIUM SET (Difficulty 2) — 12 Puzzle Scenes

These scenes introduce more complex geometric arrangements, subtle overlaps, and interwoven compositions for moderate puzzle difficulty.

##### Medium Puzzle 1: Interlocking Rings
**Theme:** Overlapping circular rings.
**Description:** 4–6 large circles of different sizes overlapping in a balanced composition. Each circle is outlined in a different color (Cyan, Coral, Gold, Purple) on a dark background. Overlap areas suggest depth through color layering.
**Design notes:** Overlapping circles, subtle color blending in overlap areas.

##### Medium Puzzle 2: Geometric Labyrinth
**Theme:** Maze-like pattern or intricate pathways.
**Description:** An intricate but balanced geometric maze or pathway pattern. Use Muted (#6868A0) or Line (#1A2050) for pathways with Cyan (#00D4FF) accent highlights on key intersections. Dark background suggests negative space. Complex but not chaotic.
**Design notes:** Intricate symmetry, balanced complexity.

##### Medium Puzzle 3: Layered Abstract Landscape
**Theme:** Stylized horizon and elevation layers.
**Description:** 4–5 horizontal bands of varying heights suggesting a stylized landscape (not photorealistic). Use a color gradient effect across bands (Surface → Muted → Cyan → Coral → Gold) to suggest depth. Dark sky background at top.
**Design notes:** Horizontal banding, color-based depth.

##### Medium Puzzle 4: Geometric Network
**Theme:** Complex interconnected nodes and paths.
**Description:** 15–20 nodes of varying sizes interconnected by thin geometric lines creating a complex network pattern. Use node colors in Cyan, Coral, Gold, and Purple with a dark background. Lines in Muted (#6868A0).
**Design notes:** Complex connections, varied node sizing.

##### Medium Puzzle 5: Prismatic Shapes
**Theme:** Geometric prisms and 3D-looking forms.
**Description:** Multiple geometric prism-like shapes rendered with flat colors but arranged to suggest 3D depth (isometric-style). Use multiple colors (all accent colors) with clear outline definition. Dark background.
**Design notes:** Pseudo-3D geometry, isometric arrangement.

##### Medium Puzzle 6: Cascading Geometry
**Theme:** Stepped or cascading pattern.
**Description:** A series of geometric shapes (typically squares or hexagons) arranged in a cascading or waterfall-like pattern descending across the canvas. Colors progress through the accent palette (Cyan → Gold → Coral → Purple) creating a visual flow.
**Design notes:** Cascading arrangement, directional color flow.

##### Medium Puzzle 7: Angular Symmetry
**Theme:** Symmetrical angular composition.
**Description:** A composition with bilateral or radial symmetry composed of angular shapes (triangles, diamonds, stars). Use a mix of all accent colors symmetrically arranged on a dark background. High visual impact.
**Design notes:** Perfect symmetry, angular geometry.

##### Medium Puzzle 8: Interlocking Abstract Forms
**Theme:** Multiple overlapping geometric planes.
**Description:** 3–5 abstract geometric forms (irregular polygons, curved shapes, free-form geometric elements) interlocking in a balanced composition. Use distinct colors for each form (Cyan, Coral, Gold, Purple) with overlap showing darker blending.
**Design notes:** Overlapping complexity, form interlocking.

##### Medium Puzzle 9: Geometric Portal
**Theme:** Nested frames or vanishing point illusion.
**Description:** Multiple geometric frames (squares, hexagons, or custom polygons) nested within each other leading toward a central point or vanishing point. Use graduated colors and opacity (from Muted → Cyan) to enhance the portal effect.
**Design notes:** Perspective illusion, nested frames.

##### Medium Puzzle 10: Hybrid Tessellation
**Theme:** Mixed-shape tessellation pattern.
**Description:** A tessellation combining multiple geometric shapes (hexagons, triangles, squares) in a unified pattern. Colors alternate between Surface (#14183A), Muted (#6868A0), Cyan (#00D4FF), and Coral (#E94560). Complex but organized.
**Design notes:** Multiple shape types, balanced tessellation.

##### Medium Puzzle 11: Radiant Grid
**Theme:** Grid with radiating energy.
**Description:** A regular geometric grid (square or hexagonal) with radiating energy lines or bursts emanating from selected grid intersections. Use grid in Muted (#6868A0) with burst elements in Cyan (#00D4FF) and Coral (#E94560).
**Design notes:** Grid structure with radiating accents.

##### Medium Puzzle 12: Abstract Constellation
**Theme:** Star-like node pattern.
**Description:** A composition resembling a constellation or astronomical pattern: multiple node points of varying brightness (rendered as circles in Cyan, Gold, Purple) connected by subtle lines on a dark Void (#090A12) background. Suggests a cosmic map without being literal.
**Design notes:** Node distribution, subtle connection lines, cosmic feel.

---

#### HARD SET (Difficulty 3) — 8 Puzzle Scenes

These scenes feature complex, interwoven compositions with subtle color gradations, intricate geometry, and high visual sophistication.

##### Hard Puzzle 1: Fractal-Inspired Composition
**Theme:** Self-similar recursive geometry.
**Description:** A composition suggesting fractal properties with geometric patterns repeating at different scales. Use nested geometric shapes with color variation suggesting iteration (Surface → Muted → Cyan). Complex but with underlying order.
**Design notes:** Recursive geometry, varied scales, premium mathematical feel.

##### Hard Puzzle 2: Quantum Lattice Structure
**Theme:** Complex interconnected nodes at multiple levels.
**Description:** An intricate network of nodes and connections suggesting quantum or molecular structure. Combine nodes in various sizes (Cyan, Coral, Gold, Purple) with a multi-layered connection system. Dark background with some transparency effects (suggesting depth).
**Design notes:** Multi-level complexity, varied node scales and connections.

##### Hard Puzzle 3: Crystalline Geometry
**Theme:** Gemstone or crystal-like composition.
**Description:** Multiple interlocking angular forms suggesting a crystalline structure or gemstone facets. Use all accent colors with strategic placement to suggest light refraction and depth. High visual sophistication.
**Design notes:** Angular precision, color-based facet definition.

##### Hard Puzzle 4: Atmospheric Layers
**Theme:** Complex gradient-like horizontal composition.
**Description:** Multiple overlapping curved bands creating the illusion of atmospheric layers or planetary cross-section. Use subtle color gradients (Void → Deep → Surface → Cyan → Coral) across the full frame, with accent lines defining layer boundaries.
**Design notes:** Subtle color transitions, smooth curves, sophisticated depth.

##### Hard Puzzle 5: Geometric Chaos
**Theme:** Controlled complexity with apparent randomness.
**Description:** Multiple overlapping geometric shapes of varying sizes, colors, and opacity levels arranged in apparent chaos but with underlying balanced composition. Use all accent colors with selective semi-transparency effects (if SVG gradients are available).
**Design notes:** Apparent disorder with balanced composition, varied opacity levels.

##### Hard Puzzle 6: Nested Dimensional Forms
**Theme:** Multiple planes suggesting 3D space.
**Description:** Complex isometric or pseudo-3D geometric arrangement with multiple planes, layers, and forms suggesting depth through geometric arrangement and color. Use all accent colors with careful attention to visual hierarchy.
**Design notes:** Pseudo-3D composition, complex layering.

##### Hard Puzzle 7: Abstract Data Visualization
**Theme:** Sophisticated information architecture visualization.
**Description:** A complex composition resembling data visualization or information architecture: multiple nodes (varied sizes in Cyan, Coral, Gold, Purple) connected by paths of varying thickness and colors creating a sophisticated network map.
**Design notes:** Data visualization aesthetic, complex connections, premium tech feel.

##### Hard Puzzle 8: Infinite Pattern Composition
**Theme:** Seamless repeating pattern with focal center.
**Description:** A composition designed to feel like an infinite repeating pattern but with a visual focal point or center of interest. Use a tessellation or repeating geometric pattern (tessellating polygons with all accent colors) arranged to draw the eye toward a central area.
**Design notes:** Seamless pattern feel with focal organization, balanced infinity concept.

---

**Puzzle Generation Notes:**

- All puzzle scenes should be designed with **clear piece separation potential** — ensure that cut puzzle pieces will have visually distinct colors, patterns, or edges
- Use **high contrast** between adjacent pieces to maintain readability when separated
- Avoid **uniform or monochromatic areas** that would make pieces indistinguishable
- Consider **varied piece sizes and shapes** emerging from the geometric composition
- **Premium, sophisticated aesthetic** should be maintained across all difficulty levels
- **No photorealism, characters, animals, or literal imagery**

### Memory Match Symbol Set

**Delivery Specs:**
- Base set: 18 pairs (9 unique symbols, each appears twice on cards)
- Hard extra set: 12 additional symbols for difficulty escalation
- Output type: individual card-face symbols
- Delivery format: SVG for production delivery
- Optional review export: PNG at 512×512 px
- Exact dimensions: 512×512 px per symbol
- Aspect ratio: 1:1 square
- Background: transparent preferred for source, with a white or very light preview background if needed for review
- Naming pattern:
	- `symbol_memory-match_easy_01_512.svg` through `symbol_memory-match_easy_09_512.svg`
	- `symbol_memory-match_medium_01_512.svg` through `symbol_memory-match_medium_09_512.svg`
	- `symbol_memory-match_hard_01_512.svg` through `symbol_memory-match_hard_12_512.svg`

**General Style Direction for All Symbols:**

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

Each symbol must be:
- Clean and uncluttered
- High contrast for dark backgrounds
- Readable at small mobile card sizes
- Geometric and abstract (no realistic objects)
- Instantly recognizable when paired
- Premium, intelligent aesthetic
- No text, no labels, no mascots

---

#### EASY SET (Difficulty 1) — 9 Base Symbols

These symbols use simple, clear geometric forms and represent foundational concept categories.

##### Easy Symbol 1: Node Cluster
**Concept:** Network or connection network.
**Description:** An abstract cluster of 4–6 circles or nodes connected by simple lines forming a geometric network pattern. Use Surface (#14183A) for nodes, with Cyan (#00D4FF) or Muted (#6868A0) for connector lines. Simple, readable, premium tech aesthetic.
**Design notes:** Centered composition, equal node sizing, evenly spaced connectors.

##### Easy Symbol 2: Spiral Arc
**Concept:** Growth, iteration, or cyclic progress.
**Description:** An elegant geometric spiral or concentric arc form, drawn with clean lines. Render in a single accent color (Cyan or Coral) with subtle graduated line weight. Suggest motion or progression without being literal or animated-looking.
**Design notes:** Balanced spiral starting from center, smooth curves, clear visual hierarchy.

##### Easy Symbol 3: Stacked Layers
**Concept:** Depth, complexity, or multiple levels.
**Description:** 3–4 horizontal rectangular layers slightly offset from one another, suggesting depth and stratification. Use dark Surface (#14183A) for layers with Coral (#E94560) or Gold (#FFB800) accent on one or two layers to create visual interest.
**Design notes:** Even spacing, clear separation, premium minimal aesthetic.

##### Easy Symbol 4: Angular Compass
**Concept:** Direction, navigation, or orientation.
**Description:** A geometric compass form: a central circle with four primary directional points (north, south, east, west) rendered as triangular or arrow shapes in clean lines. Accent one or two points with Cyan. Keep geometry sharp and modern.
**Design notes:** Symmetrical design, centered, clear cardinal directions.

##### Easy Symbol 5: Geometric Burst
**Concept:** Energy, expansion, or radiance.
**Description:** A central circle with 8–12 radiating lines or geometric rays extending outward uniformly. Use a primary color accent (Coral or Gold) for rays with subtle graduation. Premium, controlled energy.
**Design notes:** Symmetrical radial design, even spacing, clean line weights.

##### Easy Symbol 6: Hexagonal Frame
**Concept:** Structure, stability, or containment.
**Description:** A large hexagon outline (regular six-sided polygon) with optional subtle geometric details inside (a smaller concentric shape or minimal internal structure). Use Line (#1A2050) for primary outline with optional Cyan or Purple accent on alternate edges.
**Design notes:** Clean geometry, symmetrical, premium tech aesthetic.

##### Easy Symbol 7: Diamond Core
**Concept:** Precision, value, or central focus.
**Description:** A centered diamond or rhombus shape, optionally nested within a second larger diamond. Use Surface (#14183A) for the inner diamond and Coral (#E94560) or Gold (#FFB800) for accent or outline on the outer shape.
**Design notes:** Centered, geometric precision, balanced proportions.

##### Easy Symbol 8: Wave Form
**Concept:** Flow, rhythm, or oscillation.
**Description:** A smooth geometric wave pattern: 2–3 undulating sine-like curves rendered as clean lines or filled shapes. Use a primary accent color (Cyan) with subtle line weight variation. Suggest motion without being literal.
**Design notes:** Smooth, flowing, symmetrical composition.

##### Easy Symbol 9: Triangular Lattice
**Concept:** Framework, interconnection, or foundation.
**Description:** A grid of connected triangles (tessellation pattern) arranged in a balanced geometric composition. Use Line (#1A2050) for primary structure with optional Cyan or Purple accent on select triangles to create visual rhythm.
**Design notes:** Regular tessellation, balanced, premium geometric pattern.

---

#### MEDIUM SET (Difficulty 2) — 9 Intermediate Symbols

These symbols use more complex geometric arrangements and suggest more sophisticated concepts.

##### Medium Symbol 1: Nested Circles
**Concept:** Hierarchy, progression, or infinite cycles.
**Description:** 3–4 concentric circles with varying line weights and colors. Outermost in Muted (#6868A0), intermediate in Surface (#14183A), innermost accented in Cyan or Coral. Create visual depth through layering and color variation.
**Design notes:** Perfect circles, even spacing, clear color hierarchy.

##### Medium Symbol 2: Branching Tree
**Concept:** Evolution, decision paths, or organic growth (abstract).
**Description:** A geometric, abstract tree-like structure: a central trunk with 2–3 branches extending upward, each with sub-branches. Use Line (#1A2050) for primary structure, Cyan for branch endpoints. Sharp angles, not naturalistic curves.
**Design notes:** Symmetrical or balanced asymmetry, angular geometry, premium tech tree feel.

##### Medium Symbol 3: Interlocking Polygons
**Concept:** Connection, diversity, or unity.
**Description:** 2–3 geometric shapes (hexagons, pentagons, or diamonds) overlapping or interlocking in a balanced composition. Use Surface (#14183A) fills with Line (#1A2050) outlines, and selectively accent overlapping areas with Cyan or Coral.
**Design notes:** Balanced composition, clear overlaps, premium geometric puzzle feel.

##### Medium Symbol 4: Radial Sunburst
**Concept:** Illumination, breakthrough, or dispersal.
**Description:** A central geometric core (small circle or hexagon) with 12–16 radiating triangular or wedge-shaped segments of varying lengths. Alternate segment colors between Surface (#14183A) and accent colors (Coral, Gold, Cyan).
**Design notes:** Radial symmetry, varied segment lengths for visual interest, premium starburst feel.

##### Medium Symbol 5: Geometric Graph
**Concept:** Data, visualization, or analytical framework.
**Description:** A simplified graph or chart composition: a vertical and horizontal axis line in Muted (#6868A0), with 4–6 geometric bars, points, or line segments suggesting data. Use Cyan and Coral as accent colors for data elements.
**Design notes:** Clear axes, balanced data representation, premium analytics aesthetic.

##### Medium Symbol 6: Intersecting Lines
**Concept:** Intersection, crossroads, or convergence.
**Description:** 3–4 geometric lines at various angles intersecting at or near a central point. Use Line (#1A2050) for primary lines, with Cyan or Coral accents at intersection points creating geometric shapes (stars, diamonds).
**Design notes:** Clear intersection point, varied angles, premium geometric precision.

##### Medium Symbol 7: Segmented Ring
**Concept:** Cycles, progression, or division.
**Description:** A ring or circle divided into 6–8 segments by radiating lines. Alternate segments use different fills: Surface (#14183A), Muted (#6868A0), and accent colors (Cyan, Coral). Create visual rhythm through color sequencing.
**Design notes:** Perfect ring geometry, even segment division, clear color pattern.

##### Medium Symbol 8: Abstract Grid
**Concept:** Organization, structure, or information density.
**Description:** A grid pattern (4×4 or 5×5) of small squares or rectangles with selective fills and outlines. Use Muted (#6868A0) for outlines, with random or patterned fills of Surface (#14183A) and accent colors (Cyan, Coral, Gold) creating an abstract mosaic.
**Design notes:** Regular grid, balanced color distribution, premium technical feel.

##### Medium Symbol 9: Geometric Mandala
**Concept:** Balance, symmetry, or cosmic order.
**Description:** A complex but balanced circular composition: concentric circles with radiating geometric shapes (triangles, diamonds, or arcs) arranged in perfect radial symmetry. Use 3–4 colors in a harmonious pattern (Dark base with Cyan, Coral, and Gold accents).
**Design notes:** Perfect radial symmetry, balanced complexity, premium meditation-game aesthetic.

---

#### HARD SET (Difficulty 3) — 12 Advanced Symbols

These symbols use intricate geometry, subtle color work, and more abstract concepts suitable for expert-level play.

##### Hard Symbol 1: Fractal-Like Geometry
**Concept:** Complexity, self-similarity, or recursive structures.
**Description:** A geometric pattern suggesting fractal properties: a primary shape containing smaller versions of itself within specific regions. Use Line (#1A2050) for primary structure with Cyan and Coral accents highlighting recursive elements.
**Design notes:** Complex but balanced, premium mathematical feel.

##### Hard Symbol 2: Multi-Ring Network
**Concept:** Distributed systems, interconnected networks, or multiple scales.
**Description:** 2–3 concentric rings with radiating spokes connecting to multiple nodes across the rings. Use Muted (#6868A0) for rings, Cyan for spokes, and small node circles in Surface (#14183A) or Coral.
**Design notes:** Complex but organized, premium systems design aesthetic.

##### Hard Symbol 3: Layered Geometric Composition
**Concept:** Depth perception, dimensional space, or information layers.
**Description:** Multiple geometric shapes (rectangles, circles, diamonds) arranged to suggest 3D depth through layering and offset positioning. Use dark background shapes with lighter Surface (#14183A) and accent color (Cyan, Coral) foreground shapes.
**Design notes:** Subtle depth illusion, premium geometric composition.

##### Hard Symbol 4: Complex Lattice
**Concept:** Interconnection, infrastructure, or foundation systems.
**Description:** An intricate geometric lattice: a web of connected points and lines forming a complex but balanced pattern (e.g., isometric grid, honeycomb variant, or custom tessellation). Use multiple colors in a structured pattern (Muted, Line, Cyan, Coral).
**Design notes:** Intricate but organized, premium architecture feel.

##### Hard Symbol 5: Geometric Mandala v2
**Concept:** Transcendence, advanced meditation, or supreme balance.
**Description:** An extremely detailed geometric mandala with multiple layers: central core surrounded by concentric rings, radiating petals or triangles, and intricate inner details. Use balanced color distribution (5+ colors) in perfect symmetry.
**Design notes:** Complex but symmetrical, premium spiritual-geometry aesthetic.

##### Hard Symbol 6: Abstract Portal
**Concept:** Transition, dimensional shift, or gateway.
**Description:** A composition suggesting a portal or gateway: nested geometric frames (squares, hexagons, or circles) leading toward a vanishing point or central void. Use graduated opacity and color (from Muted → Surface → Cyan) to suggest depth.
**Design notes:** Perspective illusion, premium sci-fi aesthetic.

##### Hard Symbol 7: Interlocking Rings
**Concept:** Unbreakable bonds, interconnection, or infinite loops.
**Description:** 3–4 geometric rings (hexagons, circles, or custom polygons) interlocking in a balanced, non-planar-looking arrangement. Use varied line weights and strategic color accents (Cyan, Coral, Gold) to enhance the interlocking effect.
**Design notes:** 3D illusion, premium geometric puzzle feel.

##### Hard Symbol 8: Stellated Polygon
**Concept:** Expansion, breakthrough, or advanced growth.
**Description:** A primary polygon (hexagon, octagon) with geometric projections extending from each edge creating a star-like or stellated appearance. Use Surface (#14183A) for primary shape, Coral or Gold for star points.
**Design notes:** Complex geometry, premium tech aesthetic.

##### Hard Symbol 9: Gradient Geometry
**Concept:** Transition, variation, or spectrum.
**Description:** Geometric shapes (rectangles, circles, or custom forms) arranged to suggest color transition or spectrum. Use a gradient of Mind Wars colors (Void → Deep → Surface → Cyan → Coral) distributed across the composition (SVG gradients acceptable for hard set).
**Design notes:** Premium visual flow, complex color coordination.

##### Hard Symbol 10: Möbius-Like Form
**Concept:** Continuous flow, paradox, or infinite surface.
**Description:** An abstract geometric representation of a twisted or continuous surface, rendered geometrically (not 3D). Use interlocking shapes and strategic line placement to suggest the impossible-geometry concept. Accent with Cyan and Coral.
**Design notes:** Abstract impossible geometry, premium mathematical feel.

##### Hard Symbol 11: Quantum Lattice
**Concept:** Quantum mechanics, uncertainty, or probabilistic states.
**Description:** An asymmetrical but balanced lattice with nodes, connections, and optional geometric clouds or uncertainty regions. Use nodes in varied sizes (Surface, Cyan), connections in Muted (#6868A0), and Coral or Purple for uncertainty areas.
**Design notes:** Complex asymmetry, premium quantum/scientific aesthetic.

##### Hard Symbol 12: Celestial Geometry
**Concept:** Cosmic order, astronomical pattern, or universal harmony.
**Description:** A composition suggesting celestial or astronomical geometry: geometric planet circles, orbital paths (arcs or ellipses), and star-like points arranged in a balanced cosmic pattern. Use Cyan, Gold, and Coral for celestial accents on a dark base.
**Design notes:** Balanced complexity, premium space aesthetic.

### Memory Match Card Back

**Delivery Specs:**
- Output type: reusable card back skin (face-down card design)
- Production format: SVG
- Optional review export: PNG at 512×512 px
- Exact dimensions: 512×512 px
- Aspect ratio: 1:1 square
- Background: opaque, not transparent, should be a solid dark color
- Canonical alpha filename: `assets/games/memory/memory-match/card-back_memory-match_512.svg`
- Optional review export filename: `card-back_memory-match_512.png`

**Critical Design Note:**
This is the reusable face-down state for every Memory Match card in the game. It will be scaled, animated, flipped, and repeated extensively across gameplay. The source SVG should:
- Remain crisp under repeated scaling (use clean geometric forms, not rasterized textures)
- Animate smoothly during flip transitions
- Maintain visual impact at reduced sizes (down to ~64×64 px in-game)
- Use only the approved Mind Wars palette
- Feel premium and branded enough to reinforce game identity

**Design Brief:**

Create a production-ready mobile app asset for the Mind Wars brand system. Style direction: dark-first, geometric, abstract, premium, intelligent, competitive, clean, vector-like, high contrast. No photography, no literal brains, no war imagery, no weapons, no mascots, and no clutter. Use only the approved Mind Wars palette. Output must feel like a polished game platform asset for iOS and Android.

TASK:
Create the card-back (face-down) design for the Memory Match card game. This is a 512×512 px square SVG that will be used for every card in the deck while face-down.

THEME:
The card back should evoke mystery, anticipation, and readiness — players see this design repeatedly as they flip cards. It should feel:
- Inviting, not intimidating
- Premium, not cheap or novelty
- Branded with Mind Wars identity
- Geometric and abstract
- Iconic and memorable

DESIGN APPROACH:

**Background Layer:**
- Solid dark fill: Use Void (#090A12), Deep (#0E1028), or Surface (#14183A)
- Opaque, no transparency
- This should feel like the "sealed" side of a card

**Primary Visual Element (Central Motif):**
Choose one of the following approaches:

*Option A: Geometric Frame & Symbol*
- Central geometric frame (hexagon, circle, or diamond) using Line (#1A2050) or Surface (#14183A)
- Inside the frame, place a simple abstract symbol suggesting "unknown" or "reveal" (e.g., a question mark rendered geometrically, a sealed envelope, a locked box, or a veiled shape)
- Accent the symbol or frame edges with Cyan (#00D4FF) or Coral (#E94560) for visual pop
- Keep the motif balanced and centered for readable scaling

*Option B: Radial Pattern*
- A radial or concentric pattern emanating from the center (e.g., geometric rings, radiating lines, or burst pattern)
- Use alternating colors between dark base and accent colors (Cyan, Coral, Gold, Purple)
- Should feel dynamic and energetic, suggesting readiness to flip

*Option C: Premium Badge Design*
- A central geometric badge or seal design (similar to rank badge style)
- Incorporate the Mind Wars visual language (geometric, abstract, premium)
- Use a border or frame to contain the design with clear boundaries
- Accent colors strategically placed for visual hierarchy

SECONDARY DETAILS (Optional but recommended):
- Subtle geometric patterns or textures within the background (not photorealistic, use geometric shapes or line patterns)
- Optional corner accents or edge details suggesting a physical card
- Subtle visual cues suggesting the card is ready to be flipped (e.g., directional lines, dynamic geometry)

STYLE CONSTRAINTS:
- Flat vector design (no 3D, no bevels, no photorealism)
- Geometric, abstract, clean aesthetic
- High contrast for readability at small mobile sizes
- Premium, game-UI-ready feel
- Must remain crisp when exported to PNG and scaled

COLOR PALETTE (Required):
- Dark base: Void (#090A12), Deep (#0E1028), or Surface (#14183A)
- Accent highlights: Cyan (#00D4FF) and/or Coral (#E94560)
- Optional supporting: Gold (#FFB800), Purple (#7C3AED), or Muted (#6868A0)
- **Maximum 4–5 total colors in the final design**

SYMMETRY & BALANCE:
- Centered, balanced composition
- Either perfect radial symmetry or balanced asymmetry
- Should feel equally good when viewed from any angle (important for card-flipping animation)

ANIMATION COMPATIBILITY:
- Design should work well during 3D flip animation (half the card visible at rotation midpoint)
- Avoid composition that relies heavily on top/bottom orientation
- Pattern should feel coherent even when partially visible during flip transition

NEGATIVE PROMPT / EXCLUSIONS:
no photorealism; no faces; no characters; no animals; no literal brain anatomy; no war scenes; no weapons; no explosions; no military insignia; no neon rainbows; no pastel palettes; no childish icons; no cluttered noise textures; no text or numerals; no watermark; no cheap or novelty aesthetic.

DESIGN TONE:
- Inviting, not cold
- Mysterious, not confusing
- Premium, not generic
- Branded, instantly recognizable as Mind Wars
- Energetic, suggesting action

READABILITY CHECKLIST:
- [ ] Remains visually distinct at 512×512 px (master size)
- [ ] Maintains clarity when scaled down to 128×128 px (in-game card grid)
- [ ] Remains recognizable at 64×64 px (if used for other UI layouts)
- [ ] Accent colors pop without overwhelming the design
- [ ] Geometric forms are clean and vector-precise, not rasterized
- [ ] Symmetry or balance is evident, supporting mental model of a flippable card

## 7. Recommended Hand-Off Order To AI Asset Teams

Give the work to specialists in this order:

1. Logo and app icon specialist
2. Game icon specialist
3. System illustration specialist
4. Avatar and badge specialist
5. Scene illustration specialist for Spot the Difference and Focus Finder
6. Motion specialist
7. Game-specific UI asset specialist

## 8. Delivery Checklist For Each External Generator

Before accepting output, require the following:

- asset name
- prompt used
- seed or reproducibility settings if available
- background type
- exact output size
- source format and exported PNG format
- transparent-background variant where needed
- confirmation that output avoids literal brain and war imagery
- confirmation that palette stays within the approved system
- confirmation that the asset was checked at mobile scale

## 9. Minimum Launch Asset Set To Generate First

If you want the smallest useful first generation batch, start with this set:

1. Logomark master
2. Wordmark master
3. App icon master
4. Splash screen artwork
5. Notification icon source
6. All 15 game icons
7. All 5 category badges
8. Onboarding illustrations x3
9. Default avatars x12
10. Memory Match card back

That batch gives you enough material to begin the native shell rollout, app shell rollout, and game discovery rollout without waiting on the full game art library.