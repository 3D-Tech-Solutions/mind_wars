# Puzzle Race

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Spatial |
| Players | 2-10 |
| Core Mechanic | Reassemble a scrambled spatial layout as quickly as possible |
| Async Compatible | Yes |
| Primary Cognitive Skill | Spatial assembly |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Puzzle Race is a spatial reconstruction game where players restore a broken layout to its correct arrangement faster and more efficiently than opponents. The underlying skill is spatial planning: reading structure, recognizing valid moves, and minimizing wasted actions.

Within Mind Wars, Puzzle Race should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with clear move affordances and readable puzzle state
- offline-first play through local or cached puzzle content
- async fairness through identical puzzle layouts and rules for all players in a match
- server-authoritative validation of move history, completion, and score

## Current Implementation Snapshot

The current playable widget is not a jigsaw puzzle. It is an alpha sliding-tile puzzle implementation.

Current observed widget behavior:

- Puzzle type: numbered sliding puzzle with one empty space
- Starting size: 3×3 at level 1, 4×4 at levels 2-3
- Shuffle method: begins from solved state and applies level-based random valid moves
- Solvability: guaranteed because the shuffle uses valid moves from a solved state
- Move rule: only tiles adjacent to the empty space can move
- Score on solve: `40 - moves.clamp(0, 30)`
- Progression: advances through 3 levels with grid expansion and increased shuffle intensity, then completes the game
- Completion condition: all numbered tiles in ascending order with empty tile last
- Difficulty progression: grid size scales (3×3 → 4×4 → 4×4), shuffle passes increase (100 → 120 → 150)

This makes the alpha version a real spatial puzzle with proper difficulty scaling, but it is materially different from the image-based jigsaw assembly game described in the branding and asset documents.

## Concept And Core Loop

### Concept

Players inspect a scrambled puzzle state, plan the most efficient restoration sequence, and resolve the board with as few wasted moves as possible.

### Core Gameplay Loop

1. Read the current puzzle state.
2. Identify legal moves.
3. Move a piece toward its correct position.
4. Reduce the overall disorder of the puzzle.
5. Continue until the board reaches the solved state.

## Core Rules

### Setup

1. Generate a solved puzzle state.
2. Scramble it into a valid playable arrangement.
3. Present the board and any mode-specific constraints.
4. Apply timer, move-count, scoring, and hint rules.

### Gameplay

1. The player identifies a movable tile.
2. The player taps or drags a valid tile into the empty position.
3. The board updates after each move.
4. The system tracks move count and solve progress.
5. The round ends when the puzzle is solved or the mode terminates.

### Ending

Puzzle Race should end when one of the following conditions is met:

- the puzzle is solved correctly
- the timer expires
- the format uses a move cap
- a fixed round set is completed

### Special Rules

- In the current widget, only legal adjacent moves are allowed.
- The current alpha implementation is move-count based and does not use image-piece placement.
- Competitive async play should standardize board state, puzzle type, allowed moves, and scoring rules across all players.

## Difficulty & Progression

Puzzle Race follows the **standard 3-level progression model**. See [GAMES_DIFFICULTY_MATRIX.md](../GAMES_DIFFICULTY_MATRIX.md) for complete matrix and [DIFFICULTY_PROGRESSION_SPEC.md](../DIFFICULTY_PROGRESSION_SPEC.md) for full specification.

### Level Progression Summary

| Level | Grid | Shuffle Passes | Difficulty | Scaling |
|-------|------|---------------|-----------|---------|
| 1 | 3×3 (9 tiles) | 100 random moves | Easy puzzle | Smaller grid |
| 2 | 4×4 (16 tiles) | 120 random moves | Moderate puzzle | Larger grid |
| 3 | 4×4 (16 tiles) | 150 random moves | Hard puzzle | More shuffling |

**Completion:** When level > 3  
**Scoring:** 40 - (moves × 1), minimum 10 points per puzzle  

Grid size expands at level 2 (3×3 → 4×4); shuffle intensity increases at level 3 to force deeper puzzle solutions. All puzzles are solvable because shuffle uses valid moves from solved state.

### Current Widget Implementation

- The widget begins with a 3×3 sliding puzzle at level 1.
- Upgrades to a 4×4 sliding puzzle at level 2 and 3.
- Difficulty comes from board size and move efficiency.
- Shuffle passes scale with level to increase solution depth.

This implementation provides a legitimate spatial challenge with proper 3-level progression, though it remains a numbered sliding-tile puzzle rather than the image-based jigsaw described in branding docs.

## Winning And Scoring

### Current Widget Scoring

- Solving the board awards `40 - moves.clamp(0, 30)`.
- Lower move counts therefore produce higher scores.
- The player completes the experience after 5 solved rounds.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- completion status
- move efficiency
- solve speed
- hint usage if hints exist

### Recommended Competitive Formula

One workable production formula would be:

```text
CompletionScore = 50 if solved else 0
MoveEfficiencyBonus = max(0, targetMoves - actualMoves)
TimeBonus = max(0, roundTimeLimit - secondsTaken)
HintPenalty = 5 x hintsUsed

FinalScore = CompletionScore + MoveEfficiencyBonus + TimeBonus - HintPenalty
```

This preserves the move-efficiency emphasis already present in the alpha widget while making race timing relevant for ranked play.

### Recommended Ranked Formula For Puzzle Race Mind Wars

To align Puzzle Race with the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md), the recommended ranked formula for sealed Mind War competition is:

```text
CompletionScore = 50 if solved else 0
MoveEfficiencyBonus = max(0, targetMoves - actualMoves)
TimeBonus = max(0, totalTimeBudgetSeconds - totalSolveTimeSeconds)
HintPenalty = 5 x hintsUsed

FinalScore = CompletionScore + MoveEfficiencyBonus + TimeBonus - HintPenalty
```

Where:

- `solved` = whether the board reached a fully validated solved state
- `targetMoves` = benchmark move target declared for the Mind War payload
- `actualMoves` = validated number of legal moves taken by the player
- `totalTimeBudgetSeconds` = deterministic round or session budget declared by the Mind War
- `totalSolveTimeSeconds` = validated elapsed time from start to completion or timeout
- `hintsUsed` = all assists consumed during the run

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: solve the current sliding puzzle board.
- In async multiplayer: compete for the best validated local Mind War result on the exact same puzzle configuration, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use fewer moves, then faster completion time.

## Mind War Ranking Methodology

### Purpose

For Puzzle Race, the Mind War ranking layer answers:

> Who performed best on this exact puzzle configuration under these exact move and scoring rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Puzzle Race Mind War should define the following immutable fields at creation time:

| Field | Puzzle Race Requirement |
|---|---|
| Game ID | `puzzle_race` |
| Difficulty Tier | Easy, Medium, or Hard |
| Challenge Seed | Deterministic server-generated seed or stored puzzle payload |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included as a scoring modifier through solve-time accounting |
| Attempt Limits | Fixed board count, move cap, or fixed session window |
| Ranked Flag | Yes or No |

For Puzzle Race specifically, the deterministic package should also lock:

- puzzle type, such as sliding board or jigsaw board
- initial board arrangement or piece layout
- allowed move rules
- target move benchmark if used by scoring
- timer rules
- hint behavior
- scoring weights

### Exact Same Game Delivery Method

To ensure every player receives the exact same Puzzle Race game inside a Mind War:

- the server should issue one immutable battle payload containing the exact board layout or piece arrangement, puzzle mode, image asset or tile set, move rules, timer rules, and hint policy
- each client should cache that payload locally and render the puzzle from that exact arrangement without applying a local reshuffle
- final ranking should be validated by replaying move history and solved-state checks against that same puzzle payload on the server

### Mind War Final Score Rule

Players in a Puzzle Race Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = CompletionScore + MoveEfficiencyBonus + TimeBonus - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Puzzle Race runs share the same `FinalScore`, the recommended tiebreak order is:

1. Fewer moves
2. Faster total validated completion time
3. Shared placement

This matches the platform template while using the game's natural equivalent for fewer attempts.

### Mind War Output

Each Puzzle Race Mind War should produce:

- ordered placements
- final scores
- completion status
- move count
- total completion time
- hints used
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If a Puzzle Race Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Puzzle Race under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Puzzle Race Mind Wars affect only the local Mind War results.
- Ranked Puzzle Race Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Puzzle Race should follow the platform matrix exactly:

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

Puzzle Race public rankings should therefore exist as:

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

A Puzzle Race run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Puzzle Race is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Puzzle Race result screen should display:

- Mind War placement
- final score
- difficulty tier
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Puzzle Race works well asynchronously because every player can receive the same puzzle arrangement and solve it independently within the battle window.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The initial board arrangement, allowed move rules, timer rules, and scoring rules must be identical for all players.
- Competitive matches should use an explicit server-generated puzzle payload rather than local random shuffling.
- The broader platform should support matches up to 10 players even though the current catalog entry still reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- initial board layout or image-piece arrangement
- move history or final board state
- completion time
- move count
- hint usage if applicable
- final score

### Offline-First Behavior

- Practice sliding boards can be generated locally.
- Battle puzzle payloads can be cached locally once distributed.
- Move history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

There is currently no dedicated Puzzle Race hint branch in the generic offline screen beyond the default fallback hint text.

That means the current practice experience does not yet offer game-specific help such as:

- previewing the solved layout
- highlighting the next best movable piece
- temporarily showing correct placement targets

If ranked hints are enabled later, they should carry a clear score penalty and reveal only limited strategic information.

## UI And Interaction Notes

- The current sliding-tile grid is readable and mobile friendly.
- The production jigsaw version described in the branding system would create a very different interaction model based on piece placement rather than empty-slot motion.
- If the game shifts to image-based assembly, drag precision, snap zones, and piece visibility become much more important.
- The branding plan already assumes image sets and puzzle-piece treatments that are not used by the current widget.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/puzzle_race_game.dart](../../../lib/games/widgets/puzzle_race_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Branding direction: [docs/branding.md](../../branding.md)

Current state summary:

- The app has a playable sliding-puzzle Puzzle Race implementation.
- The current widget is not the same design as the jigsaw-based branded production concept.
- The generator currently provides only piece-count scaffolding, not real board-state or image payloads.
- Ranked multiplayer will need deterministic puzzle-state generation, server validation, and explicit leaderboard-routing metadata before rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Puzzle Race still needs:

- a final ranked decision between the current sliding-puzzle model and the branded jigsaw direction
- explicit deterministic ranked payloads for board state or piece layout, depending on the chosen production model
- server-side validation of move history, completion state, time, and score
- a clear policy for timeout scoring, preview aids, and Pure versus Assisted ladder separation

## Recommended Next Design Decisions

To finalize Puzzle Race as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production keeps the sliding-puzzle model or shifts fully to the image-based jigsaw concept.
2. Whether ranked play scores move efficiency, time, or a hybrid of both.
3. Whether partial-progress scoring exists at timeout or only full solves score.
4. Whether solved-layout preview is allowed in practice only or also in ranked mode with penalties.
5. Whether the generator and backend should produce explicit board layouts for sliding mode or image-piece payloads for jigsaw mode.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/puzzle_race_game.dart](../../../lib/games/widgets/puzzle_race_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)