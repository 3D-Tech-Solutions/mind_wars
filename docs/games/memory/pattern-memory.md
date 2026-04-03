# Pattern Memory

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Memory |
| Players | 2-10 |
| Core Mechanic | Study and recreate a visual cell pattern |
| Async Compatible | Yes |
| Primary Cognitive Skill | Visual-spatial memory |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Pattern Memory challenges players to briefly study a grid of filled cells and then rebuild that arrangement from memory. The game tests visual encoding, chunking, and accuracy under limited preview time.

Within Mind Wars, Pattern Memory should follow the same platform rules as the other core games:

- mobile-first interaction with large tap targets and clear cell states
- offline-first play through locally generated or cached puzzle content
- async fairness through identical puzzle setups for all players in a match
- server-authoritative validation of the final reconstructed pattern and score

## Current Implementation Snapshot

The current playable widget is a progressive practice mode built around level-based pattern recall. Players are shown a filled-cell arrangement, wait for the reveal timer to finish, and then tap cells to recreate the pattern before submitting.

Current observed widget behavior:

- Starting grid: 4×4 at level 1
- Progression cap: complete after level > 3
- Grid expansion: increases to 5×5 at level 3
- Reveal timer: scales with level (4 sec → 5 sec → 6 sec)
- Fill count: level-based (5 → 7 → 10 filled cells)
- Perfect result: awards `20 + (level × 5)` and advances to the next level
- Good result: `75%` or better accuracy awards 10 points and generates a new pattern at the same level
- Failed result: below `75%` accuracy clears the current attempt and requires retry
- Difficulty progression: grid size, cell count, and view time all scale with level

The widget implements proper 3-level progression with both grid expansion and cell-count scaling, providing a progressive practice implementation with clear difficulty increases.

## Concept And Core Loop

### Concept

Players view a temporary visual pattern on a grid, store it in working memory, and then rebuild it by toggling the cells they believe were active.

### Core Gameplay Loop

1. Observe the revealed pattern during the memorization window.
2. Encode the pattern using rows, clusters, symmetry, or landmarks.
3. Wait for the reveal to disappear.
4. Recreate the pattern by tapping the correct cells.
5. Submit the board and receive an accuracy-based result.

## Core Rules

### Setup

1. Generate a grid size and a valid filled-cell pattern.
2. Show the pattern for a defined memorization window.
3. Hide the source pattern and present an empty response grid.
4. Apply any mode-specific timer, scoring, or hint restrictions.

### Gameplay

1. During the reveal phase, the original pattern is visible and cannot be edited.
2. During the response phase, the player toggles cells on or off to recreate the pattern.
3. The player submits the board when satisfied.
4. The submission is scored based on how closely it matches the source pattern.
5. Competitive modes should record the exact submitted grid, completion time, and any hint usage.

### Ending

Pattern Memory should end when one of the following conditions is met:

- a fixed number of rounds is completed
- the session reaches a defined progression cap
- the timer expires
- the match format uses a limited attempt structure

### Special Rules

- In the current widget, accuracy is measured across every board cell, not just the cells the player activated.
- A score of `75%` or better currently counts as a successful round, even if the board is not perfect.
- In ranked async play, success thresholds, round count, and tie rules should be standardized for all players on the same puzzle set.

## Difficulty & Progression

Pattern Memory follows the **standard 3-level progression model**. See [GAMES_DIFFICULTY_MATRIX.md](../GAMES_DIFFICULTY_MATRIX.md) for complete matrix and [DIFFICULTY_PROGRESSION_SPEC.md](../DIFFICULTY_PROGRESSION_SPEC.md) for full specification.

### Level Progression Summary

| Level | Grid Size | Filled Cells | View Time | Difficulty |
|-------|-----------|------------|----------|-----------|
| 1 | 4×4 (16 cells) | 5 filled | 4 sec | Simple pattern |
| 2 | 4×4 (16 cells) | 7 filled | 5 sec | Moderate pattern |
| 3 | 5×5 (25 cells) | 10 filled | 6 sec | Complex pattern |

**Completion:** When level > 3  
**Perfect Match Scoring:** 20 + (level × 5)  
**Good Match Scoring (75%+):** +10 points, retry at same level  

Difficulty scales through grid expansion at level 3, cell-count increase across all levels, and view-time reduction to maintain memory challenge while grid size grows.

### Current Widget Implementation

- Widget starts at 4×4 grid and progresses to 5×5 at level 3.
- Reveal time and cell count both scale with level to increase difficulty.
- Partial success (≥75%) allowed at same level; perfect matches advance level.
- Provides a workable progressive practice loop with clear difficulty increases.

This implementation delivers proper 3-level progression with both grid expansion and density scaling, matching the standardized difficulty model across all 15 games.

## Winning And Scoring

### Current Widget Scoring

- Perfect submission: `20 + (level × 5)`
- Good submission at `75%` or better: `+10`
- Failed submission below `75%`: no score gain and retry
- Completion: when the player clears level 3 (level > 3)

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- pattern accuracy
- total correct cells
- false positives and missed cells
- completion speed
- hint usage or replay assistance

### Recommended Competitive Formula

One workable production formula would be:

```text
CorrectCells = number of cells that match the source pattern
MissedFilledCells = source filled cells left unselected
FalsePositiveCells = empty source cells selected by player
AccuracyScore = 5 × CorrectCells
PerfectBonus = 25 if MissedFilledCells == 0 and FalsePositiveCells == 0
TimeBonus = max(0, roundTimeLimit - secondsTaken)
HintPenalty = 5 × hintsUsed
ErrorPenalty = 4 × (MissedFilledCells + FalsePositiveCells)

FinalScore = AccuracyScore + PerfectBonus + TimeBonus - HintPenalty - ErrorPenalty
```

This preserves the spirit of the current implementation while giving ranked play a clearer and more defensible scoring structure.

### Victory Condition

- In practice mode: clear the defined progression path or reach the highest level possible.
- In async multiplayer: compete for the best validated local Mind War result on the exact same puzzle setup, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use faster completion time or fewer total errors.

## Mind War Ranking Methodology

Pattern Memory should treat each Mind War as a sealed local competition with one locked reveal pattern package for all participants.

Each battle should lock:

- Game ID: `pattern-memory`
- Difficulty tier
- Puzzle seed or stored pattern payload
- Grid size
- Reveal duration rules
- Hint and replay policy
- Time limit
- Scoring formula version
- Round format or progression cap
- Ranked flag

### Exact Same Game Delivery Method

To ensure every player receives the exact same Pattern Memory game inside a Mind War:

- the server should issue one immutable battle payload containing the exact pattern set, round order, reveal durations, grid size, timer rules, and hint or replay policy
- each client should cache that payload locally and reproduce the reveal and response phases from that locked pattern package without local random variation
- final ranking should be validated by comparing the submitted grids and assist usage against that same payload on the server

Local Mind War placement should be decided by:

1. Highest validated Final Score.
2. If scores tie, fewer total errors.
3. If still tied, faster validated completion time.
4. If still tied, fewer hint or replay assists.
5. If still tied after full validation, assign shared placement.

This local ranking model is fair because every player is solving the exact same filled-cell pattern package under the same reveal and response rules.

## Public Ranking Methodology

Public routing should occur only when a Mind War is marked as ranked and the submitted result passes full server validation.

Eligible runs should route only into compatible buckets for:

- Difficulty tier
- Assistance category: Pure if no hints or replay aids were used, Assisted if any such aid was used
- Scope: Global, Regional, or National

Within each bucket, the public metric should be Best Valid Score, with ties ordered by:

1. Fewer total errors.
2. Faster validated completion time.
3. Fewer hint or replay assists.
4. Earlier server-validated completion timestamp if a final deterministic order is required.

Unranked runs should still settle the local Mind War but must not affect persistent public standings.

## Async And Multiplayer Notes

### Async Format

Pattern Memory is a strong async fit because the reveal phase and response phase can be replayed independently for each player without changing the puzzle itself.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- Grid size, filled-cell pattern, reveal duration, timer rules, and scoring rules must be identical for all players in the match.
- Competitive matches should use a deterministic seed or an explicit stored puzzle payload rather than ad hoc local randomness.
- The broader platform should support matches up to 10 players even if the current catalog entry still reflects an older max-player value.

### Server Validation

The authoritative backend should validate:

- puzzle ID or deterministic seed
- source pattern definition
- submitted player grid
- completion time
- hint usage and any allowed replay usage
- final score calculation

### Offline-First Behavior

- Pattern puzzles can be generated locally for practice or cached locally for match play.
- Player submissions can be stored offline and synchronized later.
- Ranked outcomes should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

The shared hint system already supports Pattern Memory and currently exposes hints such as:

- the grid dimensions
- the total number of filled cells
- a suggestion to remember the board by sections
- a suggestion to focus on one row at a time

In ranked multiplayer, hints should remain optional and should reduce score or disable specific bonuses.

## UI And Interaction Notes

- The current grid-tap interaction is naturally mobile friendly and easy to understand.
- The production version should clearly distinguish source reveal cells, player-selected cells, and error feedback cells.
- The branding spec already defines dedicated filled, empty, player-placed, and error states for this game.
- A later refinement could add stronger reveal choreography, such as brief staged illumination or grouped pattern fades, as long as every player receives the exact same reveal behavior.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/pattern_memory_game.dart](../../lib/games/widgets/pattern_memory_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../lib/services/hint_and_challenge_system.dart)

Current state summary:

- The app has a playable Pattern Memory practice implementation with progressive rounds.
- The generator already supports fixed-difficulty pattern creation.
- The widget and generator currently describe different progression models and should be reconciled.
- The branding system already defines a stronger production-ready visual language than the current simple cell rendering.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Pattern Memory still needs:

- one canonical ranked format so fixed-difficulty payloads and progressive-round behavior are no longer in tension
- deterministic reveal-pattern payloads with locked reveal duration and assist policy
- server-side validation of the submitted grid, total errors, replay or hint usage, and final score
- a clear product decision on whether partial-threshold success is practice-only or also valid in ranked play

## Recommended Next Design Decisions

To finalize Pattern Memory as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether ranked matches use single-round exact reconstruction or multi-round progression.
2. Whether a `75%` result should count as success in competitive play or remain practice-only leniency.
3. Whether the production source of truth is the current progressive widget model or the fixed easy, medium, and hard generator model.
4. Whether reveal duration should scale with difficulty, level, or stay fixed by puzzle package.
5. Whether total accuracy, speed, or perfect completion should be the primary tiebreaker.

## Related References

- [lib/games/game_catalog.dart](../../lib/games/game_catalog.dart)
- [lib/games/widgets/pattern_memory_game.dart](../../lib/games/widgets/pattern_memory_game.dart)
- [lib/services/game_content_generator.dart](../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../lib/screens/offline_game_play_screen.dart)
- [docs/branding.md](../branding.md)