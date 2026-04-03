# Focus Finder

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Attention |
| Players | 2-10 |
| Core Mechanic | Locate target items inside a cluttered field |
| Async Compatible | Yes |
| Primary Cognitive Skill | Visual search |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Focus Finder is a search-and-select attention game where players scan a crowded field for specific targets while ignoring distractors. Strong performance depends on fast recognition, efficient scanning patterns, and low error rates.

Within Mind Wars, Focus Finder should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with readable target indicators and large tap zones
- offline-first play through local or cached puzzle content
- async fairness through identical target sets, scene layouts, and validation rules for all players in a match
- server-authoritative validation of found targets, wrong taps, and final score

## Difficulty & Progression

Focus Finder follows the **standard 3-level progression model**. See [GAMES_DIFFICULTY_MATRIX.md](../GAMES_DIFFICULTY_MATRIX.md) for complete matrix and [DIFFICULTY_PROGRESSION_SPEC.md](../DIFFICULTY_PROGRESSION_SPEC.md) for full specification.

### Level Progression Summary

| Level | Targets | Distractors | Total | Difficulty |
|-------|---------|------------|-------|-----------|
| 1 | 3 | 19 | 22 | Low clutter |
| 2 | 4 | 18 | 22 | Moderate clutter |
| 3 | 5 | 17 | 22 | High clutter |

**Completion:** When level > 3  
**Scoring:** +15 per target found  

Target count increases while keeping total items constant, creating difficulty scaling through increasing clutter ratio while maintaining grid stability.

## Current Implementation Snapshot

The current playable widget is an emoji-based target-search prototype rather than an illustrated clutter-scene hidden-object game.

Current observed widget behavior:

- Target model: dynamically selected based on level (3, 4, or 5 targets)
- Scene content: 22 total emoji items (constant across all levels)
- Distractors: calculated to complement target count
- Source item pool: symbols from sports, music, and fruit-style emoji sets
- Correct find result: each newly found target awards +15
- Found-state feedback: target chips in the header are highlighted and struck through once found
- Progression: advances through 3 levels, then completes the game
- Wrong tap handling: no explicit penalty or feedback in the current widget

This makes the alpha version a functional visual-search game, but it is materially different from the branded production design based on dense illustrated clutter scenes and target preview cards.

## Concept And Core Loop

### Concept

Players are shown a small set of target items and must locate those items within a crowded field faster and more accurately than opponents.

### Core Gameplay Loop

1. Review the target list.
2. Scan the cluttered play field.
3. Tap an item believed to match a target.
4. Confirm the find and reduce the remaining target list.
5. Continue until all targets are found or the round ends.

## Core Rules

### Setup

1. Select a target set for the current level.
2. Build a cluttered field containing the targets plus distractors.
3. Present the target preview area clearly.
4. Apply level-appropriate target count and difficulty scaling.

### Gameplay

1. The player reads the target list.
2. The player taps suspected target items in the scene.
3. Valid targets are marked as found.
4. Invalid taps should apply a defined competitive penalty.
5. The round ends when all targets are found or time expires.

### Ending

Focus Finder should end when one of the following conditions is met:

- all targets for the final level are found
- progression advances beyond level 3 (game complete)
- the timer expires (if applicable in competitive mode)

### Special Rules

- In the current widget, only successful target taps have explicit gameplay consequences.
- The current alpha implementation does not currently penalize wrong taps.
- Difficulty scaling: target count increases per level (3 → 4 → 5) while total item count stays constant.

### Important Design Gap

There is a mismatch between current sources:

- The widget is an emoji-grid search puzzle with difficulty scaling.
- The branding system expects illustrated clutter scenes, target preview cards, highlight rings, and found stamps.

That gap should be resolved for production rollout, but the difficulty progression is now standardized and consistent.

## Winning And Scoring

### Current Widget Scoring

- Each valid target find awards +15.
- There is currently no wrong-tap penalty.
- The player completes the experience after clearing 5 rounds.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- total targets found
- full-clear completion speed
- wrong-tap count
- hint usage if hints exist

### Recommended Competitive Formula

One workable production formula would be:

```text
BaseScore = 15 x foundTargets
CompletionBonus = 20 if all targets are found
TimeBonus = max(0, roundTimeLimit - secondsTaken)
WrongTapPenalty = 5 x incorrectTaps
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + CompletionBonus + TimeBonus - WrongTapPenalty - HintPenalty
```

This keeps target discovery central while rewarding clean, efficient visual search.

### Recommended Ranked Formula For Focus Finder Mind Wars

To align Focus Finder with the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md), the recommended ranked formula for sealed Mind War competition is:

```text
BaseScore = 15 x foundTargets
CompletionBonus = 20 if allTargetsFound else 0
SpeedBonus = max(0, totalTimeBudgetSeconds - totalResponseTimeSeconds)
WrongTapPenalty = 5 x incorrectTaps
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + CompletionBonus + SpeedBonus - WrongTapPenalty - HintPenalty
```

Where:

- `foundTargets` = total validated targets found by the player
- `allTargetsFound` = whether the run cleared the entire target set
- `totalTimeBudgetSeconds` = deterministic round or session budget declared by the Mind War
- `totalResponseTimeSeconds` = validated time from round start to completion or timeout
- `incorrectTaps` = taps on non-target items or already-resolved invalid regions
- `hintsUsed` = all assists consumed during the run

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: find every target in the current emoji-grid round.
- In async multiplayer: compete for the best validated local Mind War result on the exact same target set and scene layout, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use fewer wrong taps, then faster completion time.

## Mind War Ranking Methodology

### Purpose

For Focus Finder, the Mind War ranking layer answers:

> Who performed best on this exact search scene under these exact validation and scoring rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Focus Finder Mind War should define the following immutable fields at creation time:

| Field | Focus Finder Requirement |
|---|---|
| Game ID | `focus_finder` |
| Difficulty Tier | Easy, Medium, or Hard |
| Challenge Seed | Deterministic server-generated seed or stored scene payload |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included as a scoring modifier through completion-time accounting |
| Attempt Limits | Fixed scene count, wrong-tap cap, or fixed session window |
| Ranked Flag | Yes or No |

For Focus Finder specifically, the deterministic package should also lock:

- target list
- scene layout
- object positions
- tap hit regions or object IDs
- timer rules
- wrong-tap policy
- scoring weights

### Exact Same Game Delivery Method

To ensure every player receives the exact same Focus Finder game inside a Mind War:

- the server should issue one immutable battle payload containing the scene layout, target list, object positions or hit regions, wrong-tap policy, timer rules, and hint policy
- each client should cache that payload locally and render the identical search scene and target preview set without local content substitutions
- final ranking should be validated by checking found targets, wrong taps, and completion state against that same scene payload on the server

### Mind War Final Score Rule

Players in a Focus Finder Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = BaseScore + CompletionBonus + SpeedBonus - WrongTapPenalty - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Focus Finder runs share the same `FinalScore`, the recommended tiebreak order is:

1. Fewer incorrect taps
2. Faster total validated completion time
3. Shared placement

This matches the platform template while using the game's natural equivalent for fewer attempts.

### Mind War Output

Each Focus Finder Mind War should produce:

- ordered placements
- final scores
- total targets found
- completion status
- incorrect tap count
- total completion time
- hints used
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If a Focus Finder Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Focus Finder under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Focus Finder Mind Wars affect only the local Mind War results.
- Ranked Focus Finder Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Focus Finder should follow the platform matrix exactly:

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

Focus Finder public rankings should therefore exist as:

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

A Focus Finder run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Focus Finder is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Focus Finder result screen should display:

- Mind War placement
- final score
- difficulty tier
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Focus Finder works well asynchronously because every player can inspect the same target scene independently while the system compares validated outcomes afterward.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The target list, scene layout, object positions, tap hitboxes, timer rules, and scoring rules must be identical for all players.
- Competitive matches should use an explicit server-generated scene payload rather than local random target distribution.
- The broader platform should support matches up to 10 players even though the current catalog entry still reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- target list
- scene layout or object-position payload
- player tap events
- wrong-tap count
- hint usage if applicable
- final score and completion time

### Offline-First Behavior

- Practice boards can be generated locally using symbolic content.
- Production battle scenes can be cached locally after distribution.
- Tap history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

There is currently no dedicated Focus Finder hint branch in the generic offline screen beyond the default fallback hint text.

That means the current practice experience does not yet offer game-specific help such as:

- narrowing the search region
- highlighting the approximate area of one target
- previewing a target in more detail

If ranked hints are enabled later, they should carry a clear score penalty and should reveal only limited information.

## UI And Interaction Notes

- The current target-header-plus-grid layout is clean and readable on phones.
- The production illustrated-scene version will need more careful support for zoom, tap accuracy, and target preview clarity.
- The branding spec already defines a target highlight ring, found stamp, target preview card, and dedicated header treatment.
- If the scene density increases substantially, the UI may need optional zoom or sectional scanning support to remain fair on small screens.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/focus_finder_game.dart](../../../lib/games/widgets/focus_finder_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Branding direction: [docs/branding.md](../../branding.md)

Current state summary:

- The app has a playable symbolic Focus Finder practice widget.
- The current widget is much simpler than the intended illustrated clutter-scene production design.
- The generator currently provides only target-count and distractor-count scaffolding, not real scene payloads.
- Ranked multiplayer will need server-tracked scene layouts, hit regions, wrong-tap rules, and explicit leaderboard-routing metadata before rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Focus Finder still needs:

- deterministic search-scene payloads with locked target sets for every player in a ranked battle
- server-side validation of hit accuracy, false taps, completion state, and final score
- production scene content that matches the branded visual-search concept instead of alpha-level scaffolding
- a finalized Pure versus Assisted hint policy for ranked ladders

## Recommended Next Design Decisions

To finalize Focus Finder as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production validates targets by object ID, coordinate regions, or region masks.
2. Whether wrong taps reduce score, add time, or both.
3. Whether zoom and pan are required for the first production scene-based version.
4. Whether the emoji-grid alpha version remains as a fallback practice mode after illustrated scene rollout.
5. Whether target preview cards persist throughout the round or collapse once each target is found.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/focus_finder_game.dart](../../../lib/games/widgets/focus_finder_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)