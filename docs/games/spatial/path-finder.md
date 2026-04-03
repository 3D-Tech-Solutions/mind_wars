# Path Finder

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Spatial |
| Players | 2-10 |
| Core Mechanic | Navigate a maze and reach the goal efficiently |
| Async Compatible | Yes |
| Primary Cognitive Skill | Spatial planning |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Path Finder is a maze-navigation game where players move from a start position to a goal while minimizing wasted movement. Strong play depends on route planning, decision quality, and clean execution through constrained space.

Within Mind Wars, Path Finder should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with clear maze readability and precise movement controls
- offline-first play through local or cached maze payloads
- async fairness through identical maze layouts and rules for all players in a match
- server-authoritative validation of movement, completion, and final score

## Current Implementation Snapshot

The current playable widget is a grid-maze navigation prototype with explicit directional controls.

Current observed widget behavior:

- Grid size: fixed 8x8 in the current widget
- Start position: top-left corner
- Goal position: bottom-right corner
- Maze generation: starts as an empty 8×8 grid, adds level-based wall count, then verifies solvability with BFS
- Fallback: if no solvable maze is found after repeated attempts, the board becomes an open grid
- Controls: four directional buttons outside the board
- Legal movement: only inside bounds and onto floor cells
- Score on solve: `30 - moves.clamp(0, 20)`
- Progression: advances through 3 levels with increasing wall density, then completes the game
- Difficulty progression: wall count scales per level (16 → 24 → 32 walls in 8×8 grid)

This makes the alpha version a real pathfinding game with proper difficulty scaling, but it is still simpler than a fuller production maze system with richer path-review features.

## Concept And Core Loop

### Concept

Players study a maze, predict an efficient route, and execute directional movement to reach the exit in as few wasted steps as possible.

### Core Gameplay Loop

1. Observe the maze layout.
2. Plan a route from start to goal.
3. Move step by step through valid floor cells.
4. Avoid dead ends and unnecessary detours.
5. Reach the goal with efficient movement.

## Core Rules

### Setup

1. Generate a maze with a valid path from start to goal.
2. Place the player marker at the start.
3. Place the goal marker at the exit.
4. Apply mode-specific timer, move, and scoring rules.

### Gameplay

1. The player chooses a directional move.
2. Movement succeeds only if the destination is inside the grid and not blocked by a wall.
3. Each successful move updates the current position and move count.
4. The player continues until the goal is reached or the round ends.
5. Competitive modes should record the full path, move count, and time taken.

### Ending

Path Finder should end when one of the following conditions is met:

- the player reaches the goal
- the timer expires
- the format uses a move cap
- a fixed round set is completed

### Special Rules

- In the current widget, illegal moves are simply ignored.
- The current alpha implementation uses BFS only to validate that a generated path exists, not to compute or award an optimal-path bonus.
- Competitive async play should standardize maze generation, movement rules, and scoring rules across all players.

## Difficulty & Progression

Path Finder follows the **standard 3-level progression model**. See [GAMES_DIFFICULTY_MATRIX.md](../GAMES_DIFFICULTY_MATRIX.md) for complete matrix and [DIFFICULTY_PROGRESSION_SPEC.md](../DIFFICULTY_PROGRESSION_SPEC.md) for full specification.

### Level Progression Summary

| Level | Grid | Wall Count | Maze Density | Difficulty |
|-------|------|-----------|-------------|-----------|
| 1 | 8×8 (64 cells) | 16 walls | ~25% blocked | Light maze |
| 2 | 8×8 (64 cells) | 24 walls | ~37% blocked | Moderate maze |
| 3 | 8×8 (64 cells) | 32 walls | ~50% blocked | Dense maze |

**Completion:** When level > 3  
**Scoring:** 30 - (moves × 1), minimum 10 points per maze  

Wall count scales linearly while keeping grid size constant, increasing the branching complexity and dead-end risk at higher levels. All mazes are validated for solvability via BFS before presentation.

### Current Widget Implementation

- The widget currently uses a fixed 8×8 maze grid.
- Wall placement is randomized but constrained to level-based wall count.
- Difficulty is explicitly represented by maze density scaling (16 → 24 → 32 walls).
- The board validates solvability before player interaction.

This implementation provides a solid maze prototype with proper 3-level progression. Target production enhancements include path-overlay visualization and optimal-path bonus scoring.

## Winning And Scoring

### Current Widget Scoring

- Solving the maze awards `30 - moves.clamp(0, 20)`.
- Lower move counts therefore produce higher scores.
- The player completes the experience after 5 solved rounds.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- completion status
- move efficiency
- solve time
- optimal-path quality
- hint usage if hints exist

### Recommended Competitive Formula

One workable production formula would be:

```text
CompletionScore = 40 if goalReached else 0
MoveEfficiencyBonus = max(0, optimalPathLength - extraMoves)
TimeBonus = max(0, roundTimeLimit - secondsTaken)
HintPenalty = 5 x hintsUsed

FinalScore = CompletionScore + MoveEfficiencyBonus + TimeBonus - HintPenalty
```

This preserves the move-efficiency emphasis already present in the alpha widget while adding room for route-quality comparison.

### Recommended Ranked Formula For Path Finder Mind Wars

To align Path Finder with the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md), the recommended ranked formula for sealed Mind War competition is:

```text
CompletionScore = 40 if goalReached else 0
MoveEfficiencyBonus = max(0, optimalPathLength - extraMoves)
TimeBonus = max(0, totalTimeBudgetSeconds - totalSolveTimeSeconds)
HintPenalty = 5 x hintsUsed

FinalScore = CompletionScore + MoveEfficiencyBonus + TimeBonus - HintPenalty
```

Where:

- `goalReached` = whether the player successfully reached the exit
- `optimalPathLength` = shortest validated path length for the exact maze payload
- `extraMoves` = validated player move count minus optimal path length
- `totalTimeBudgetSeconds` = deterministic round or session budget declared by the Mind War
- `totalSolveTimeSeconds` = validated elapsed time from start to completion or timeout
- `hintsUsed` = all assists consumed during the run

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: reach the exit on the current maze.
- In async multiplayer: compete for the best validated local Mind War result on the exact same maze layout, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use fewer moves, then faster completion time.

## Mind War Ranking Methodology

### Purpose

For Path Finder, the Mind War ranking layer answers:

> Who performed best on this exact maze under these exact movement and scoring rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Path Finder Mind War should define the following immutable fields at creation time:

| Field | Path Finder Requirement |
|---|---|
| Game ID | `path_finder` |
| Difficulty Tier | Easy, Medium, or Hard |
| Challenge Seed | Deterministic server-generated seed or stored maze payload |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included as a scoring modifier through solve-time accounting |
| Attempt Limits | Fixed maze count, move cap, or fixed session window |
| Ranked Flag | Yes or No |

For Path Finder specifically, the deterministic package should also lock:

- maze layout
- start and goal positions
- movement rules
- optimal-path metadata if used by scoring
- timer rules
- hint behavior
- scoring weights

### Exact Same Game Delivery Method

To ensure every player receives the exact same Path Finder game inside a Mind War:

- the server should issue one immutable battle payload containing the full maze layout, start and goal positions, movement rules, timer rules, hint policy, and any hidden optimal-path metadata used for scoring
- each client should cache that payload locally and render the maze exactly as distributed without local wall generation or path mutation
- final ranking should be validated by replaying the submitted movement history against that same maze payload on the server

### Mind War Final Score Rule

Players in a Path Finder Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = CompletionScore + MoveEfficiencyBonus + TimeBonus - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Path Finder runs share the same `FinalScore`, the recommended tiebreak order is:

1. Fewer moves
2. Faster total validated completion time
3. Shared placement

This matches the platform template while using the game's natural equivalent for fewer attempts.

### Mind War Output

Each Path Finder Mind War should produce:

- ordered placements
- final scores
- completion status
- move count
- total completion time
- hints used
- optimal-path comparison metadata if applicable
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If a Path Finder Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Path Finder under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Path Finder Mind Wars affect only the local Mind War results.
- Ranked Path Finder Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Path Finder should follow the platform matrix exactly:

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

Path Finder public rankings should therefore exist as:

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

A Path Finder run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Path Finder is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Path Finder result screen should display:

- Mind War placement
- final score
- difficulty tier
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Path Finder works well asynchronously because every player can solve the same maze independently while the system compares validated outcomes afterward.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The maze layout, start and goal positions, movement rules, timer rules, and scoring rules must be identical for all players.
- Competitive matches should use an explicit server-generated maze payload rather than local random wall generation.
- The broader platform should support matches up to 10 players even though the current catalog entry still reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- maze layout
- start and goal positions
- player movement history or final path
- move count
- completion time
- hint usage if applicable
- final score

### Offline-First Behavior

- Practice mazes can be generated locally.
- Battle maze payloads can be cached locally once distributed.
- Movement history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

There is currently no dedicated Path Finder hint branch in the generic offline screen beyond the default fallback hint text.

That means the current practice experience does not yet offer game-specific help such as:

- highlighting one step of the correct route
- previewing the shortest path length
- marking dead-end regions lightly

If ranked hints are enabled later, they should carry a clear score penalty and reveal only limited route information.

## UI And Interaction Notes

- The current maze view and external directional controls are readable on phones.
- The production version could eventually support swipe controls or path tracing, but those would materially change competitive interaction rules.
- The branding system already defines wall, floor, player, start, goal, and solved-path visual treatments.
- If optimal-path review is added, the post-round UI should clearly separate the player's route from the shortest valid path.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/path_finder_game.dart](../../../lib/games/widgets/path_finder_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Branding direction: [docs/branding.md](../../branding.md)

Current state summary:

- The app has a playable maze-navigation Path Finder implementation.
- The generator currently provides only grid-size scaffolding, not real maze payloads or optimal routes.
- The current widget uses fixed-size local random mazes rather than deterministic battle content.
- Ranked multiplayer will need deterministic maze generation, server-side validation, and explicit leaderboard-routing metadata before rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Path Finder still needs:

- deterministic maze payload generation so ranked battles are not tied to one hard-coded local layout
- server-side validation of move history, solvability, completion state, and final score
- a final ranked policy for shortest-path handling, timeout behavior, and hint eligibility
- alignment between generator output and the live widget so ranked maze metadata is authoritative

## Recommended Next Design Decisions

To finalize Path Finder as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production keeps button-based movement or shifts to swipe or tap-to-path controls.
2. Whether ranked scoring prioritizes shortest path, fastest time, or a hybrid of both.
3. Whether the server distributes full maze layouts plus optimal path metadata to support fair scoring.
4. Whether illegal move attempts should count against efficiency in ranked mode.
5. Whether solved-path review and optimal-path comparison are visible only after submission.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/path_finder_game.dart](../../../lib/games/widgets/path_finder_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)