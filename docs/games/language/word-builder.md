# Word Builder

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Language |
| Players | 2-10 |
| Core Mechanic | Build valid words from a deterministic 3x3 tile grid |
| Async Compatible | Yes |
| Primary Cognitive Skill | Lexical retrieval and pattern formation |
| Current Source Basis | Game catalog, branding spec, enhanced widget implementation, puzzle generator, enhancement docs |

## Overview

Word Builder is a competitive word-construction game built around a 3x3 cascade-chain tile grid. Players form words through adjacency paths, trigger deterministic tile cascades, and maximize score through high-value vocabulary, special-tile usage, and efficiency.

Within Mind Wars, Word Builder should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with large tile targets and clear path feedback
- offline-first play through deterministic local puzzle state and later sync
- async fairness through identical seeded tile streams and identical rules for all players in a match
- server-authoritative validation of submissions, cascades, and final score

## Current Implementation Snapshot

Unlike several other games in the repo, Word Builder already has a richer live implementation that wraps an enhanced dedicated subsystem.

Current observed implementation direction:

- Public widget: `WordBuilderGame` is now a wrapper around `WordBuilderGameEnhanced`
- Core board: deterministic 3x3 grid
- Input model: touch selection of adjacent tiles with visual path feedback
- Word rules: minimum 3 letters, no tile reuse in a single word, dictionary validation, duplicate-word rejection
- Core mechanics: cascade, gravity, deterministic refill, optional chain rule
- Special tiles: anchor, golden, and locked tile variants by difficulty
- Determinism: seeded PRNG and column-major refill are explicitly documented for server replay
- Architecture: dedicated models, tile stream, grid engine, scorer, and dictionary service

This makes Word Builder one of the most mature game implementations currently present in the codebase.

## Concept And Core Loop

### Concept

Players build words by tracing adjacent letter paths through a live 3x3 grid, then use the resulting cascades and refill behavior to create new opportunities for higher-value follow-up words.

### Core Gameplay Loop

1. Inspect the current 3x3 grid.
2. Select an adjacent tile path that forms a valid word.
3. Submit the word for validation.
4. Score the word and apply special-tile effects.
5. Resolve cascade and refill, then continue building toward the round target.

## Core Rules

### Setup

1. Generate an initial 3x3 tile grid from a deterministic seed.
2. Apply the active difficulty configuration.
3. Place any special tiles required for the mode.
4. Set target word count, chain rule state, and round scoring rules.

### Gameplay

1. The player traces a path through adjacent tiles.
2. The path cannot reuse a tile in the same word.
3. The submitted word must pass dictionary validation.
4. Duplicate words are rejected.
5. If valid, the system scores the word, applies effects, cascades the board, and refills deterministically.

### Ending

Word Builder should end when one of the following conditions is met:

- the target word count is reached
- the round timer expires
- the mode uses a fixed session length
- the competitive format defines a hard end-state after a capped number of moves

### Special Rules

- Anchor tiles do not cascade after use.
- Golden tiles apply a score multiplier.
- Locked tiles must be unlocked through longer-word play in expert configurations.
- When chain rule is active, the next word must begin with the previous word's final letter.

## Difficulty Structure

### Current Enhanced Difficulty Model

The enhancement documentation defines four levels:

- Beginner: chain rule off, no special tiles, target 10 words
- Intermediate: optional chain rule, 1-2 anchors, target 12 words
- Advanced: chain rule on, 1 anchor plus 1-2 golden tiles, target 15 words
- Expert: chain rule on, 1 anchor plus 1 golden plus 1-2 locked tiles, target 20 words

### Current Generator Behavior

The generic puzzle generator still defines a much simpler model:

- Easy: 6 letters
- Medium: 8 letters
- Hard: 10 letters

It also attaches:

- max score 100, 200, or 300 depending on difficulty
- a time limit based on 120 seconds

The generated puzzle package currently stores a flat `letters` string and an empty `possibleWords` solution list.

### Important Design Gap

There is a meaningful mismatch across the current sources:

- The live game implementation is a deterministic 3x3 cascade-chain system with dictionary validation and special tiles.
- The generic puzzle generator still describes an older flat-letter-pool model.
- The alpha summary still references an earlier simple 9-letter implementation.

For Word Builder, the production direction is already clearer than the generic generator, so the generator should eventually be brought into line with the enhanced game rather than the other way around.

### Target Difficulty Direction

- Easier play should reduce chain pressure and special-tile complexity.
- Harder play should demand stronger vocabulary, better route planning, and smarter board management.
- Difficulty should come from rule interactions and board state quality, not from unfair tile distributions.

## Winning And Scoring

### Current Enhanced Scoring Direction

The existing enhancement docs already define a rich model including:

- base score = word length squared
- rarity bonuses based on dictionary frequency bucket
- pattern bonuses for recognized prefixes, suffixes, and compounds
- pangram bonus with multiplier behavior
- golden tile multiplier
- end-of-round efficiency multiplier

### Concrete Scoring Examples From Current Docs

- 3 letters: 9 base points
- 4 letters: 16 base points
- 5 letters: 25 base points
- 7 letters: 49 base points
- Pangram bonus: +50 with a 2x multiplier
- Golden tile: 2x multiplier

### Target Competitive Interpretation

For Mind Wars multiplayer, Word Builder scoring should continue to emphasize:

- valid word quality
- board efficiency
- vocabulary rarity
- special-tile usage
- end-of-round efficiency

Because the scoring model is already mature, this doc should treat the enhancement spec as the primary scoring source rather than inventing a replacement formula.

### Victory Condition

- In practice mode: maximize score while meeting the round target.
- In async multiplayer: compete for the best validated local Mind War result on the exact same seeded tile stream and ruleset, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use words found, then higher efficiency, then faster completion.

## Mind War Ranking Methodology

Word Builder should treat each Mind War as a sealed local competition around one locked deterministic board package.

Each battle should lock:

- Game ID: `word-builder`
- Difficulty tier
- Puzzle seed
- Initial grid state
- Tile refill order
- Special tile placement rules
- Chain-rule state
- Hint policy
- Time limit and target-count rules
- Scoring formula version
- Ranked flag

### Exact Same Game Delivery Method

To ensure every player receives the exact same Word Builder game inside a Mind War:

- the server should issue one immutable battle payload containing the initial grid, refill stream, special-tile placements, chain-rule state, dictionary version, timer rules, and hint policy
- each client should cache that payload locally and execute the board state from that exact deterministic package without local tile regeneration
- final ranking should be validated by replaying accepted word paths and board mutations against that same payload on the server

Local Mind War placement should be decided by:

1. Highest validated Final Score.
2. If scores tie, more accepted valid words.
3. If still tied, higher end-of-round efficiency.
4. If still tied, faster validated completion time.
5. If still tied after full validation, assign shared placement.

This keeps the local competition fair because every player receives the exact same seeded tile stream, refill behavior, and special-tile logic.

## Public Ranking Methodology

Public routing should happen only when the Mind War is marked as ranked and the completed run passes full server validation.

Eligible runs should route only into compatible persistent buckets for:

- Difficulty tier
- Assistance category: Pure if no hints or helper reveals were used, Assisted if any hinting aid was used
- Scope: Global, Regional, or National

Within each bucket, the public metric should be Best Valid Score, with ties ordered by:

1. More accepted valid words.
2. Higher end-of-round efficiency.
3. Faster validated completion time.
4. Earlier server-validated completion timestamp if the product requires a final deterministic ordering.

Unranked runs should still determine the local winner of the sealed Mind War but must not update public boards.

## Async And Multiplayer Notes

### Async Format

Word Builder is an especially strong async fit because every player can complete the same seeded board sequence independently while the server later replays and validates each turn.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The initial grid, seed, refill order, special tile placement, chain-rule state, target count, and scoring rules must be identical for all players.
- Competitive matches should use the deterministic enhanced game model rather than local ad hoc random tile generation.
- The broader platform should support matches up to 10 players even though the current catalog entry still reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle seed
- initial grid state
- submitted word sequence
- path indices for each word
- dictionary validity and duplicate rejection
- cascade and refill results after every move
- final score and round completion state

### Offline-First Behavior

- The deterministic design already supports strong offline play.
- Moves can be recorded locally and replayed later.
- Because the tile stream and refill order are deterministic, the server can validate offline submissions after sync.
- Ranked outcomes should still be confirmed server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

The shared generic hint service still reflects the older simplified letter-pool model. It currently offers hints such as:

- how many letters are available
- looking for common suffixes like `-ING` or `-ED`
- rearranging vowels and consonants
- longer words scoring more points

That hint model is directionally useful, but it does not yet fully reflect the enhanced adjacency-grid and cascade-chain implementation.

## UI And Interaction Notes

- The enhanced implementation is explicitly mobile-first and touch-optimized.
- The repo documentation calls out visual path feedback, numbered overlays, progress tracking, and real-time score preview.
- The branding system also defines richer tile states, rarity badges, and chain-related presentation layers.
- Because this is a language game with spatial adjacency, clarity of selection path matters as much as letter readability.

## Current Implementation Notes

- Catalog definition: [../../../lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Wrapper widget: [../../../lib/games/widgets/word_builder_game.dart](../../../lib/games/widgets/word_builder_game.dart)
- Enhanced subsystem overview: [../../../lib/games/word_builder/README.md](../../../lib/games/word_builder/README.md)
- Puzzle generation scaffold: [../../../lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [../../../lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Branding direction: [../../branding.md](../../branding.md)
- Enhancement spec: [../../WORD_BUILDER_ENHANCEMENT.md](../../WORD_BUILDER_ENHANCEMENT.md)

Current state summary:

- The app has a comparatively mature enhanced Word Builder implementation.
- The current live widget already uses the enhanced cascade-chain system.
- The generic puzzle generator and some older docs still describe an earlier simpler model.
- Ranked multiplayer is well aligned conceptually because deterministic replay and server validation are already built into the design.

## Ranked Readiness

Status: Strong foundation.

Before ranked rollout, Word Builder still needs:

- the generic puzzle generator and battle payload format to be fully aligned with the enhanced deterministic board model
- backend leaderboard routing that preserves difficulty, assistance category, and scope metadata for validated runs
- a final ranked policy for chain-rule availability, special-tile behavior, and Pure versus Assisted ladders
- confirmation that dictionary and duplicate-rejection rules are identical across client and server validation paths

## Recommended Next Design Decisions

To finalize Word Builder as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether the generic puzzle generator should be rebuilt around the enhanced 3x3 seed model and deprecated from the older flat-letter model.
2. Whether chain rule is optional only in practice or also configurable in ranked modes.
3. Whether the MVP dictionary should be expanded before public competitive rollout.
4. Whether ranked matches use one standardized difficulty or a voted difficulty package with fixed special-tile behavior.
5. Whether the generic hint system should be upgraded to reflect adjacency, cascade, and chain-rule realities.

## Related References

- [../../../lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [../../../lib/games/widgets/word_builder_game.dart](../../../lib/games/widgets/word_builder_game.dart)
- [../../../lib/games/word_builder/README.md](../../../lib/games/word_builder/README.md)
- [../../../lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [../../../lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [../../branding.md](../../branding.md)
- [../../WORD_BUILDER_ENHANCEMENT.md](../../WORD_BUILDER_ENHANCEMENT.md)