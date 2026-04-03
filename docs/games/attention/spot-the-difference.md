# Spot the Difference

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Attention |
| Players | 2-10 |
| Core Mechanic | Identify differences between two parallel visual layouts |
| Async Compatible | Yes |
| Primary Cognitive Skill | Selective visual attention |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Spot the Difference asks players to compare two nearly identical visual fields and locate the places where they do not match. Strong performance depends on fast scanning, careful comparison, and avoiding wasted taps.

Within Mind Wars, Spot the Difference should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with readable visuals and clear target feedback
- offline-first play through cached or local puzzle content
- async fairness through identical scene pairs and identical difference maps for every player in a match
- server-authoritative validation of found targets, wrong taps, and score

## Difficulty & Progression

Spot the Difference follows the **standard 3-level progression model**. See [GAMES_DIFFICULTY_MATRIX.md](../GAMES_DIFFICULTY_MATRIX.md) for complete matrix and [DIFFICULTY_PROGRESSION_SPEC.md](../DIFFICULTY_PROGRESSION_SPEC.md) for full specification.

### Level Progression Summary

| Level | Grid | Differences | Difficulty |
|-------|------|------------|-----------|
| 1 | 6×6 | 5 differences | Clear patterns |
| 2 | 6×6 | 7 differences | Mixed patterns |
| 3 | 6×6 | 9 differences | Complex patterns |

**Completion:** When level > 3  
**Scoring:** +10 per difference found  

Difficulty scales through increasing difference count while keeping grid size constant, requiring players to examine details more carefully at higher levels.

## Current Implementation Snapshot

The current playable widget is an abstract alpha implementation that uses two side-by-side 6×6 boolean pattern grids instead of illustrated scene pairs.

Current observed widget behavior:

- Visual format: two side-by-side 6×6 grids
- Base content: left pattern is randomly generated from boolean cell states
- Difference generation: right pattern copies the left pattern, then flips level-based cell count (5, 7, or 9)
- Interaction: the player taps cells only on the right-side grid
- Correct tap result: each found difference awards +10
- Progression: advances through 3 levels, then completes the game
- Found-state feedback: found cells gain a green border
- Wrong tap handling: no explicit penalty or feedback in the current widget

This makes the alpha version a functional attention and comparison puzzle with proper level scaling, but it is materially different from the illustrated scene-pair version described in the branding documents.

## Concept And Core Loop

### Concept

Players inspect two similar visuals, identify the mismatched elements, and tap each valid difference within the difficulty constraints of their current level.

### Core Gameplay Loop

1. Scan both visuals for mismatches at the current level.
2. Tap a suspected difference area.
3. Receive confirmation if the tap matches a valid difference.
4. Track remaining undiscovered differences for the level.
5. Continue until all level differences are found or advance to next level.

## Core Rules

### Setup

1. Generate or load a pair of nearly identical visuals.
2. Define the complete set of valid difference targets for the current level.
3. Present both visuals side by side.
4. Apply level-appropriate difficulty scaling and scoring rules.

### Gameplay

1. The player compares the two visuals.
2. The player taps a suspected difference target.
3. If the tap matches an unfound difference, it is marked as found.
4. If the tap is incorrect, the game allows retry without explicit penalty in alpha.
5. The player continues until all level differences are found.

### Ending

Spot the Difference ends when one of the following conditions is met:

- all differences for the final level are found
- progression advances beyond level 3 (game complete)
- the timer expires (if applicable in competitive mode)

### Special Rules

- In the current widget, only correct taps are handled explicitly.
- Difficulty scaling: difference count increases per level (5 → 7 → 9) while grid size stays constant at 6×6.
- Competitive async play should standardize the difference count, tap hitboxes, and scoring rules for all players on the same scene pair.

### Design Status

The current widget implements proper 3-level progression but uses abstract patterns rather than illustrated scene pairs. The branding spec indicates this game has one of the heaviest content-production requirements because each scene pair requires two matched illustrations.

## Winning And Scoring

### Current Widget Scoring

- Each correct difference awards +10.
- There is currently no wrong-tap penalty.
- The player completes the experience after clearing 5 rounds.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- total valid differences found
- time to full completion
- wrong-tap count
- hint usage if hints are enabled

### Recommended Competitive Formula

One workable production formula would be:

```text
BaseScore = 10 x foundDifferences
CompletionBonus = 20 if all differences are found
TimeBonus = max(0, roundTimeLimit - secondsTaken)
WrongTapPenalty = 5 x incorrectTaps
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + CompletionBonus + TimeBonus - WrongTapPenalty - HintPenalty
```

This keeps correct discovery as the main scoring driver while making accuracy matter in a competitive setting.

### Recommended Ranked Formula For Spot the Difference Mind Wars

To align Spot the Difference with the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md), the recommended ranked formula for sealed Mind War competition is:

```text
BaseScore = 10 x foundDifferences
CompletionBonus = 20 if allDifferencesFound else 0
SpeedBonus = max(0, totalTimeBudgetSeconds - totalResponseTimeSeconds)
WrongTapPenalty = 5 x incorrectTaps
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + CompletionBonus + SpeedBonus - WrongTapPenalty - HintPenalty
```

Where:

- `foundDifferences` = total validated differences found by the player
- `allDifferencesFound` = whether the run cleared the full difference set
- `totalTimeBudgetSeconds` = deterministic round or session budget declared by the Mind War
- `totalResponseTimeSeconds` = validated time from round start to completion or timeout
- `incorrectTaps` = taps outside valid difference regions or repeated invalid taps
- `hintsUsed` = all assists consumed during the run

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: find all differences in the current abstract round.
- In async multiplayer: compete for the best validated local Mind War result on the exact same scene pair and difference map, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use fewer wrong taps, then faster completion time.

## Mind War Ranking Methodology

### Purpose

For Spot the Difference, the Mind War ranking layer answers:

> Who performed best on this exact scene pair under these exact validation and scoring rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Spot the Difference Mind War should define the following immutable fields at creation time:

| Field | Spot the Difference Requirement |
|---|---|
| Game ID | `spot_difference` |
| Difficulty Tier | Easy, Medium, or Hard |
| Challenge Seed | Deterministic server-generated seed or stored scene payload |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included as a scoring modifier through completion-time accounting |
| Attempt Limits | Fixed scene count, wrong-tap cap, or fixed session window |
| Ranked Flag | Yes or No |

For Spot the Difference specifically, the deterministic package should also lock:

- scene-pair asset package
- difference coordinates or approved hit regions
- timer rules
- wrong-tap policy
- hint behavior
- scoring weights

### Exact Same Game Delivery Method

To ensure every player receives the exact same Spot the Difference game inside a Mind War:

- the server should issue one immutable battle payload containing the exact scene-pair asset IDs, difference-map coordinates or object IDs, wrong-tap policy, timer rules, and hint policy
- each client should cache that payload locally and render the same comparison pair without shifting hit regions or difference counts
- final ranking should be validated by checking found targets, wrong taps, and completion state against that same difference map on the server

### Mind War Final Score Rule

Players in a Spot the Difference Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = BaseScore + CompletionBonus + SpeedBonus - WrongTapPenalty - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Spot the Difference runs share the same `FinalScore`, the recommended tiebreak order is:

1. Fewer incorrect taps
2. Faster total validated completion time
3. Shared placement

This matches the platform template while using the game's natural equivalent for fewer attempts.

### Mind War Output

Each Spot the Difference Mind War should produce:

- ordered placements
- final scores
- total differences found
- completion status
- incorrect tap count
- total completion time
- hints used
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If a Spot the Difference Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Spot the Difference under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Spot the Difference Mind Wars affect only the local Mind War results.
- Ranked Spot the Difference Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Spot the Difference should follow the platform matrix exactly:

#### Axis A: Difficulty

- Easy leaderboard
- Medium leaderboard
- Hard leaderboard

Runs do not cross difficulty tiers.

#### Axis B: Assistance Category

- Pure: no hints or assists used
- Assisted: one or more hints or assists used

Each validated run belongs to exactly one assistance category.

#### Axis C: Geographic Scope

- Global
- Regional
- National

Scope is a display and filtering axis, not a scoring modifier.

### Public Leaderboard Matrix

Spot the Difference public rankings should therefore exist as:

`Difficulty x Assistance Category x Scope`

Example matrix:

| Difficulty | Pure | Assisted |
|---|---|---|
| Easy | Yes | Yes |
| Medium | Yes | Yes |
| Hard | Yes | Yes |

Each of those cells can then be viewed at:

- Global scope
- Regional scope
- National scope

### Public Eligibility Rules

A Spot the Difference run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Spot the Difference is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Spot the Difference result screen should display:

- Mind War placement
- final score
- difficulty tier
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Spot the Difference works cleanly as an async game because every player can inspect the same visual pair independently without requiring live interaction.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The scene pair, valid difference coordinates, tap hitboxes, timer rules, and scoring rules must be identical for all players.
- Competitive matches should use an explicit server-generated puzzle payload rather than client-side local scene mutation.
- The broader platform target remains support for matches up to 10 players even though the current catalog entry reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- scene-pair asset package
- approved difference coordinates or hit regions
- player tap events
- incorrect tap count
- hint usage if applicable
- final score and completion time

### Offline-First Behavior

- Practice layouts can be generated locally using abstract patterns.
- Production battle scene pairs can be cached locally after distribution.
- Tap history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

There is currently no dedicated Spot the Difference hint branch in the generic offline screen beyond the default fallback hint text.

That means the current practice experience does not yet offer game-specific hint behavior such as:

- narrowing the search area
- highlighting a region
- reducing the active difference count remaining to a smaller set

If ranked hints are enabled later, they should carry a clear score penalty and should reveal only limited information.

## UI And Interaction Notes

- The current two-grid alpha layout is easy to understand and tap on small screens.
- The production scene-pair version will need much more careful handling of zoom, tap precision, and found-marker visibility.
- Wrong-tap feedback should be clear but brief so it does not block scanning flow.
- The branding spec already defines a found marker, a wrong-tap marker, and a dedicated header treatment for this game.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/spot_difference_game.dart](../../../lib/games/widgets/spot_difference_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Branding direction: [docs/branding.md](../../branding.md)

Current state summary:

- The app has a playable abstract Spot the Difference practice widget.
- The generator currently provides only difference-count scaffolding, not actual scene-pair payloads.
- The production design depends on a major illustration pipeline that is not yet integrated into gameplay.
- Ranked multiplayer will need server-tracked tap validation, wrong-tap rules, and explicit leaderboard-routing metadata before rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Spot the Difference still needs:

- deterministic scene-pair payloads with validated difference maps for each ranked battle
- server-side verification of discovered differences, wrong taps, completion state, and score
- a final rule on whether ranked hints exist and how Pure versus Assisted separation is enforced
- production visual assets that match the branded design rather than placeholder comparison content

## Recommended Next Design Decisions

To finalize Spot the Difference as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production uses exact coordinate hitboxes, region masks, or object IDs to validate found differences.
2. Whether wrong taps reduce score, add time, or both.
3. Whether players may tap on either image or only one designated image surface.
4. Whether zoom and pan are required for the first production version on mobile.
5. Whether the alpha abstract pattern version remains as a fallback practice mode after illustrated scene-pair rollout.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/spot_difference_game.dart](../../../lib/games/widgets/spot_difference_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)