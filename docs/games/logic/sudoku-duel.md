# Sudoku Duel

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Logic |
| Players | 2-10 |
| Core Mechanic | Solve the same Sudoku puzzle competitively |
| Async Compatible | Yes |
| Primary Cognitive Skill | Deductive reasoning |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator, release requirements |

## Overview

Sudoku Duel turns Sudoku into a competitive async logic race. Every player should receive the same puzzle, solve it independently, and be ranked by validated accuracy, error control, hint usage, and completion speed.

Within Mind Wars, Sudoku Duel should follow the same product-level rules as the other core games:

- mobile-first interaction with large number-entry targets and clear grid states
- offline-first handling for practice and cached battle content
- async fairness through identical server-generated puzzles for every player in the match
- server-authoritative validation of placements, errors, hints, and final score

## Current Implementation Snapshot

The current playable widget is an alpha practice implementation built around a simplified 4x4 Sudoku rather than a production-scale competitive Sudoku format.

Current observed widget behavior:

- Board size: 4x4
- Subgrids: 2x2 boxes
- Source board: randomly chosen from a small hardcoded list of valid solved boards
- Puzzle creation: 6 unique cells are blanked per round
- Number entry: fixed keypad with digits 1 through 4
- Round reward: +50 for a completed valid solve
- Progression: advances from level 1 to level 3, then completes the game
- Validation timing: duplicates are only checked when the board is fully filled and submitted implicitly by completion

This makes the current widget a functional practice mode, but it is materially different from the intended competitive Sudoku Duel described elsewhere in the repo.

## Concept And Core Loop

### Concept

Players solve a constrained number-placement puzzle using deduction. The competitive layer comes from solving the exact same puzzle more accurately and efficiently than other players.

### Core Gameplay Loop

1. Review the starting clue layout.
2. Select an editable cell.
3. Enter a number consistent with row, column, and box rules.
4. Continue deductive solving until the board is complete.
5. Submit or complete the board and receive a validated result.

## Core Rules

### Setup

1. Generate a Sudoku puzzle with a verified unique solution.
2. Present the clue board to the player.
3. Mark fixed clues and editable cells clearly.
4. Apply any mode-specific timer, error policy, hint rules, or pencil-mark support.

### Gameplay

1. The player selects an editable cell.
2. The player enters a number from the allowed digit range.
3. Rows, columns, and subgrids must not contain duplicates.
4. Competitive mode should track mistakes, hints, and solve time explicitly.
5. The puzzle is complete only when all required cells are filled and the full board is valid.

### Ending

Sudoku Duel should end when one of the following conditions is met:

- the puzzle is solved correctly
- the match timer expires
- the format uses a limited mistake cap
- the rules allow an unsolved submission at deadline for partial scoring

### Special Rules

- In the current widget, invalid duplicate states are not blocked inline; they only matter once the board is full.
- The current practice implementation uses no pencil marks, candidate notes, or explicit submit button.
- Ranked async play should use a standardized error model so all players are judged under identical conditions.

## Difficulty Structure

### Current Widget Behavior

- The widget currently uses only 4x4 Sudoku boards.
- Difficulty is represented mostly by repeated rounds rather than true puzzle-depth changes.
- Each round blanks 6 cells from a solved board.
- The keypad remains fixed at digits 1 to 4.

That works for alpha practice, but it is not yet aligned with the intended long-term Sudoku Duel design.

### Current Generator Behavior

The content generator currently defines Sudoku sizes like this:

- Easy: 4x4
- Medium: 6x6
- Hard: 9x9

It also attaches:

- max score 100, 200, or 300 depending on difficulty
- a time limit based on 300 seconds

However, the generator currently returns an empty `clues` map. That means the competitive puzzle-generation pipeline is still placeholder and does not yet produce a playable validated Sudoku board.

### Existing Release Requirement Direction

The v1 release requirements define a stronger target model:

- server-generated grid with a verified unique solution
- difficulty mapped to empty-cell counts: Easy 40, Medium 50, Hard 60
- score equals `90 - seconds - (5 x hints) + 15 if no errors`
- error count tracked server-side
- partial progress auto-saved every 30 seconds

### Important Design Gap

There is a major mismatch across the current sources:

- The widget is a small 4x4 alpha practice Sudoku.
- The generator implies scalable difficulty tiers but currently lacks real clue generation.
- The release spec expects full server-generated competitive Sudoku with unique-solution validation and server-side scoring.

That gap should be resolved before multiplayer rollout.

### Target Difficulty Direction

- Easy: more clues, lower branching, lighter deduction depth.
- Medium: fewer clues, more multi-step inference, tighter time pressure.
- Hard: sparse clues, deeper dependency chains, stronger penalty for errors and hints.

The branding spec already anticipates richer cell states such as clue, input, error, and hint-revealed cells, which supports a more production-ready Sudoku experience than the current widget.

## Winning And Scoring

### Current Widget Scoring

- Completing a valid 4x4 board awards +50.
- There is no explicit time bonus, error penalty, or hint-aware adjustment inside the widget.
- The player clears the experience after solving 3 boards.

### Existing Product Scoring Direction

The release requirements already specify a target formula:

```text
FinalScore = 90 - secondsTaken - (5 x hintsUsed) + 15 if no errors
```

That is a strong fit for async competition because it rewards fast, clean, efficient solving on identical puzzle content.

### Recommended Competitive Interpretation

For Sudoku Duel multiplayer, the production rules should rank players using:

- puzzle completion status
- validated solve time
- server-tracked error count
- hints used

If partial submissions are allowed at deadline, the server should also define a partial-progress scoring model that cannot exceed a full correct solve.

### Victory Condition

- In practice mode: solve the current board and progress through the small alpha ladder.
- In async multiplayer: compete for the best validated local Mind War result on the exact same server-generated puzzle, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use fewer errors, then faster completion time.

## Mind War Ranking Methodology

Sudoku Duel should treat each Mind War as a sealed local competition around one locked Sudoku puzzle package.

Each battle should lock:

- Game ID: `sudoku-duel`
- Difficulty tier
- Puzzle ID or deterministic puzzle seed
- Clue layout and canonical solution
- Time rules
- Hint policy
- Error policy
- Scoring formula version
- Partial-submission policy at deadline
- Ranked flag

### Exact Same Game Delivery Method

To ensure every player receives the exact same Sudoku Duel game inside a Mind War:

- the server should issue one immutable battle payload containing the clue board, canonical solution, difficulty tier, timer rules, error policy, and hint policy
- each client should cache that payload locally and render the exact same Sudoku board without regenerating clues or modifying placement rules
- final ranking should be validated by checking placements, errors, hint usage, and completion state against that same puzzle package on the server

Local Mind War placement should be decided by:

1. Highest validated Final Score.
2. If scores tie, fewer validated errors.
3. If still tied, faster validated completion time.
4. If still tied, fewer hints used.
5. If still tied after full validation, assign shared placement.

If deadline-based partial submissions are supported, they should remain rankable only inside that same locked battle configuration and should never outrank a full correct solve under the same ruleset.

## Public Ranking Methodology

Public leaderboard routing should happen only for runs from ranked Mind Wars that complete under a server-validated puzzle package.

Eligible runs should route only into matching buckets for:

- Difficulty tier
- Assistance category: Pure if no hints were used, Assisted if any hints were used
- Scope: Global, Regional, or National

Within each compatible bucket, the public metric should be Best Valid Score, with ties ordered by:

1. Fewer validated errors.
2. Faster validated completion time.
3. Fewer hints used.
4. Earlier server-validated completion timestamp if the product requires a final deterministic ordering.

Unranked Sudoku Duels should still determine the local winner but must not update persistent public standings.

## Async And Multiplayer Notes

### Async Format

Sudoku Duel is a strong async game because each player can independently solve the same puzzle without any live interaction requirement.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The clue layout, solution grid, timer rules, hint rules, and error policy must be identical for all players.
- Ranked matches should use a server-generated puzzle or a deterministic puzzle payload rather than client-side ad hoc randomness.
- The broader platform target remains support for matches up to 10 players even though the current catalog entry reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- clue board and unique solution
- every submitted placement or final board state
- error count
- hint usage
- completion time and final score

### Offline-First Behavior

- Practice Sudoku boards can be generated locally.
- Battle puzzles can be cached locally once received.
- In-progress boards should be saved periodically offline and synchronized later.
- Final ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

The shared hint system already supports Sudoku Duel and currently exposes hints such as:

- each row must contain unique numbers
- each column must contain unique numbers
- start with rows or columns that have the most clues
- use process of elimination

The branding spec also implies a dedicated hint-revealed cell state and a visible hint button treatment. In ranked multiplayer, hints should remain optional and should reduce score in a consistent server-tracked way.

## UI And Interaction Notes

- The current 4x4 board and number keypad are easy to use on phones.
- The production version should preserve large touch targets while supporting denser Sudoku layouts.
- If 9x9 boards are used on mobile, zoom, focus selection, and keypad ergonomics will matter more than in the current alpha widget.
- The branding system already defines clue cells, player input cells, error cells, hint cells, and a dedicated grid background treatment.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/sudoku_duel_game.dart](../../../lib/games/widgets/sudoku_duel_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Release requirements: [docs/project/V1_0_RELEASE_REQUIREMENTS.md](../../project/V1_0_RELEASE_REQUIREMENTS.md)

Current state summary:

- The app has a playable alpha Sudoku practice widget.
- The generator scaffolds Sudoku difficulty sizes but does not yet create actual clue boards.
- The release documentation already defines a stronger server-generated competitive model.
- The production visual and rules system is more advanced than the current alpha implementation.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Sudoku Duel still needs:

- real server-generated puzzle packages with clue boards and canonical solutions instead of size-only scaffolding
- server-side validation of placements, error counts, hints, and completion state
- a final ranked policy for partial submissions at deadline versus full-solve-only scoring
- confirmation of the ranked board format, especially if production extends beyond the current 4x4 alpha scope

## Recommended Next Design Decisions

To finalize Sudoku Duel as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production launches with 4x4, 6x6, 9x9, or a staged rollout across board sizes.
2. Whether invalid placements are blocked immediately or merely counted as server-tracked errors.
3. Whether partial-progress scoring exists at timeout or only full solves score.
4. Whether pencil marks and note-taking are required for the first ranked version.
5. Whether the generator and backend share a single puzzle-validation implementation to guarantee identical battle content.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/sudoku_duel_game.dart](../../../lib/games/widgets/sudoku_duel_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/branding.md](../../branding.md)
- [docs/project/V1_0_RELEASE_REQUIREMENTS.md](../../project/V1_0_RELEASE_REQUIREMENTS.md)