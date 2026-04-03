# Logic Grid

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Logic |
| Players | 2-10 |
| Core Mechanic | Deduce correct relationships from clues |
| Async Compatible | Yes |
| Primary Cognitive Skill | Structured deduction |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Logic Grid is a clue-driven deduction game where players determine the correct relationship between sets of entities by ruling out impossible combinations and confirming valid matches.

Within Mind Wars, Logic Grid should follow the same core platform rules as the other async competitive games:

- mobile-first interaction with readable clues and clear state changes
- offline-first play through locally cached or generated puzzle content
- async fairness through identical clue sets and solution states for every player in the same match
- server-authoritative validation of the final solution and score

## Current Implementation Snapshot

The current playable widget is a lightweight alpha deduction puzzle rather than a full matrix-based logic-grid implementation.

Current observed widget behavior:

- Puzzle domain: 3 people and 3 colors
- People set: Anna, Bob, Carol
- Color set: Red, Blue, Green
- Solution generation: colors are randomly shuffled and assigned one-to-one to people
- Clue set: one instruction line plus 2 randomly selected clues
- Input method: filter chips for selecting one color per person
- Check flow: player presses `Check Solution`
- Round reward: +40 for a fully correct solution
- Progression: advances to level 3, then completes the game

The alpha widget is therefore closer to a compact direct-assignment logic quiz than the branded target of a more traditional deduction matrix with explicit true, false, and unresolved states.

## Concept And Core Loop

### Concept

Players read a set of clues about relationships between entities, infer what combinations are possible or impossible, and submit the final correct arrangement.

### Core Gameplay Loop

1. Read the clue set.
2. Infer which relationships are possible and which are impossible.
3. Record answers or elimination states.
4. Continue narrowing the solution space.
5. Submit the final arrangement for validation.

## Core Rules

### Setup

1. Generate a puzzle with categories, entities, clues, and a single valid solution.
2. Present the clue list clearly.
3. Provide an interaction surface for marking or selecting relationships.
4. Apply mode-specific timer, hint, and scoring rules.

### Gameplay

1. The player reviews all provided clues.
2. The player marks answers or elimination states based on those clues.
3. Each new deduction reduces the valid search space.
4. The player completes the full arrangement and submits the result.
5. Ranked modes should record mistakes, hints, and completion time consistently.

### Ending

Logic Grid should end when one of the following conditions is met:

- the full arrangement is solved correctly
- the match timer expires
- the format uses a fixed number of submission attempts
- the rules allow partial-progress scoring at deadline

### Special Rules

- In the current widget, the player does not mark true and false states on a visible matrix.
- The alpha version allows only one selected answer per person, so it skips most of the elimination mechanics expected from a classic logic-grid game.
- Competitive async play should standardize clue count, categories, submission rules, and whether partial-progress credit is allowed.

## Difficulty Structure

### Current Widget Behavior

- The widget currently uses a fixed 3-person, 3-color structure.
- Difficulty is represented mostly by random clue selection rather than category growth or deeper inference chains.
- Each round uses only 2 generated clues in addition to the base instruction.
- The player solves by direct answer selection rather than working through a full matrix.

That makes the current implementation useful as a proof of concept, but it is not yet a full production Logic Grid design.

### Current Generator Behavior

The content generator currently defines Logic Grid puzzle size like this:

- Easy: 3 items per category
- Medium: 4 items per category
- Hard: 5 items per category

It also defines a fixed category set:

- Colors
- Numbers
- Letters

The generated puzzle package includes:

- category metadata
- items-per-category metadata
- max score by difficulty
- a time limit based on 180 seconds

However, the generator currently returns an empty `matches` solution object and no actual clue list. That means the competitive puzzle pipeline is still a scaffold rather than a complete logic-grid generator.

### Important Design Gap

There is a clear mismatch across the current sources:

- The widget is a small answer-selection puzzle with 3 people and 3 colors.
- The generator implies expandable logic-grid structures but does not yet produce real clues or match solutions.
- The branding spec suggests a more traditional grid UI with explicit true, false, and empty cell states.

That gap should be resolved before ranked multiplayer rollout.

### Target Difficulty Direction

- Easy: fewer categories, more direct clues, lower ambiguity.
- Medium: more entities, clue interdependence, and multi-step deduction.
- Hard: larger category sets, indirect clues, and higher elimination depth.

The production version should only increase difficulty when the clue set remains logically fair, uniquely solvable, and readable on mobile screens.

## Winning And Scoring

### Current Widget Scoring

- A fully correct answer awards +40.
- Incorrect submissions do not currently apply a numeric penalty.
- The player clears the experience after solving 3 rounds.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- final correctness
- deduction efficiency
- mistake count
- time to solution
- hint usage

### Recommended Competitive Formula

One workable production formula would be:

```text
BaseScore = 60 if the full arrangement is correct else 0
TimeBonus = max(0, roundTimeLimit - secondsTaken)
HintPenalty = 5 x hintsUsed
MistakePenalty = 5 x incorrectSubmissions
AccuracyBonus = 10 if solved with no mistakes

FinalScore = BaseScore + TimeBonus + AccuracyBonus - HintPenalty - MistakePenalty
```

This keeps Logic Grid rewardable as a deduction game without over-weighting raw tapping speed.

### Victory Condition

- In practice mode: solve the current generated round and advance through the alpha ladder.
- In async multiplayer: compete for the best validated local Mind War result on the exact same clue set and solution package, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use fewer incorrect submissions, then faster solve time.

## Mind War Ranking Methodology

Logic Grid should treat each Mind War as a sealed local competition around one locked clue-and-solution package.

Each battle should lock:

- Game ID: `logic-grid`
- Difficulty tier
- Puzzle seed or stored clue package
- Category set and entity labels
- Hint policy
- Time rules
- Submission policy
- Scoring formula version
- Partial-progress policy if timeout scoring exists
- Ranked flag

### Exact Same Game Delivery Method

To ensure every player receives the exact same Logic Grid game inside a Mind War:

- the server should issue one immutable battle payload containing the full clue list, categories, entity labels, canonical solution mapping, timer rules, and hint policy
- each client should cache that payload locally and present the identical clue package instead of generating deductions or clue order independently
- final ranking should be validated by comparing the submitted solution state and assist usage against that same clue package on the server

Local Mind War placement should be decided by:

1. Highest validated Final Score.
2. If scores tie, fewer incorrect submissions.
3. If still tied, faster validated solve time.
4. If still tied, fewer hints used.
5. If still tied after full validation, assign shared placement.

This keeps the battle fair because every player is solving the same exact clue package and solution map rather than comparable-but-different generated puzzles.

## Public Ranking Methodology

Public leaderboard routing should happen only for runs from ranked Mind Wars that complete under a fully validated puzzle package.

Eligible runs should route only into compatible buckets for:

- Difficulty tier
- Assistance category: Pure if no hints were used, Assisted if any hints were used
- Scope: Global, Regional, or National

Within each bucket, the public metric should be Best Valid Score, with ties ordered by:

1. Fewer incorrect submissions.
2. Faster validated solve time.
3. Fewer hints used.
4. Earlier server-validated completion timestamp if a final deterministic ordering is required.

Unranked runs remain local-only and must not affect public boards.

## Async And Multiplayer Notes

### Async Format

Logic Grid is a strong async fit because players do not need simultaneous interaction. Each player can solve the same puzzle independently inside the battle window.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The clue list, categories, entity labels, solution state, timer rules, and hint rules must be identical for all players in the same match.
- Competitive matches should use a deterministic seed or an explicit server-generated puzzle payload rather than client-side random clue generation.
- The broader platform target remains support for matches up to 10 players even though the current catalog entry reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- full clue set
- solution mapping
- player submission
- hint usage
- submission count or mistake count
- completion time and final score

### Offline-First Behavior

- Practice puzzles can be generated locally.
- Battle puzzles can be cached locally once distributed.
- Player progress or final submissions can be stored offline and synchronized later.
- Ranked outcomes should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

The shared hint system already supports Logic Grid and currently exposes hints such as:

- read all clues carefully before starting
- mark impossible combinations with X
- when you find a match, eliminate other options
- work through the clues systematically

These hints align better with a true matrix deduction interface than with the current simplified chip-selection widget, which is another sign that the longer-term design is ahead of the alpha implementation.

## UI And Interaction Notes

- The current alpha chip-based layout is readable on phones but does not represent classic logic-grid play.
- The branded target implies explicit true, false, and empty cell states, which would support clearer elimination workflows.
- Clue readability, scroll behavior, and touch size will matter heavily if the puzzle grows beyond the current small example.
- A production version may need segmented views, sticky clue panels, or category headers to remain usable on 5-inch screens.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/logic_grid_game.dart](../../../lib/games/widgets/logic_grid_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)

Current state summary:

- The app has a playable alpha deduction puzzle for Logic Grid.
- The current widget is simpler than a full logic-grid matrix game.
- The generator scaffolds difficulty metadata but does not yet generate actual clue-and-solution packages.
- The branded asset design implies a richer production interface than what currently exists.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Logic Grid still needs:

- a production clue-and-solution generator that emits deterministic ranked puzzle payloads
- a solver-validating backend that can verify submissions against the locked clue package
- a final decision on the ranked interaction model, because the current alpha widget is not yet a full logic-grid experience
- a clear timeout and partial-progress policy so local and public ranking behavior is defensible

## Recommended Next Design Decisions

To finalize Logic Grid as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production uses a true matrix deduction board or a refined card-and-selection hybrid.
2. Whether puzzles are solved through a single final submission, incremental validation, or both.
3. How many categories and entities each difficulty tier should support on mobile without reducing readability.
4. Whether partial-progress scoring exists at timeout or only full correct solves score.
5. Whether the clue generator and solver validator share a single source of truth to guarantee fair multiplayer puzzle distribution.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/logic_grid_game.dart](../../../lib/games/widgets/logic_grid_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../lib/screens/offline_game_play_screen.dart)
- [docs/branding.md](../branding.md)