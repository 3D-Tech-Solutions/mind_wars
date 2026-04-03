# Memory Match

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Memory |
| Players | 2-10 |
| Core Mechanic | Match pairs of hidden cards |
| Async Compatible | Yes |
| Primary Cognitive Skill | Visual memory and recall |
| Current Source Basis | Game catalog, branding spec, alpha summary, widget implementation, puzzle generator |

## Overview

Memory Match is a competitive recall game where players reveal hidden cards two at a time and try to find matching pairs. Success depends on remembering card positions, minimizing wasted flips, and maintaining concentration over the full board.

Within Mind Wars, Memory Match should preserve the platform's core principles:

- Mobile-first interaction with large, simple tap targets.
- Offline-first play with local puzzle generation and later sync.
- Async fairness through standardized or deterministic board setups.
- Server-authoritative validation for submitted outcomes in competitive matches.

## Current Implementation Snapshot

The current playable implementation is a compact 4×4 practice board with 16 cards and 8 matching pairs. The active widget uses a fixed emoji symbol set, awards 10 points per successful pair, and briefly reveals mismatched cards before hiding them again.

Current observed values from the implementation:

- Board size: 4 columns, 16 cards total.
- Symbol pool in widget: 8 emoji pairs.
- Match reward: +10 points per completed pair.
- Mismatch reveal window: about 800ms.
- Practice-mode completion: all pairs found.

The content generator already defines a difficulty-aware Memory Match puzzle model for easy, medium, and hard generation, but the widget currently behaves like a single compact practice variant rather than the full target design.

## Concept And Core Loop

### Concept

Players are presented with a hidden board of paired symbols. Each turn consists of selecting two cards, checking whether they match, and using memory of prior reveals to progressively clear the board more efficiently than opponents.

### Core Gameplay Loop

1. Observe the current hidden board state.
2. Reveal the first card and identify its symbol.
3. Reveal the second card and compare it to the first.
4. Score the pair if it matches; otherwise memorize both positions before they hide again.
5. Continue until the board is solved or the timer expires.

## Core Rules

### Setup

1. Generate a board containing paired symbols.
2. Shuffle card positions.
3. Start with all cards face down.
4. Apply any mode-specific timer, score cap, or difficulty adjustments.

### Gameplay

1. The player taps one hidden card to reveal it.
2. The player taps a second hidden card.
3. If both cards match, the pair is marked complete and points are awarded.
4. If both cards do not match, the cards remain visible briefly and then return face down.
5. Already matched cards cannot be selected again.
6. The same card cannot be counted twice within a single reveal pair.

### Ending

The round ends when one of the following conditions is met:

- all pairs are matched
- the timer expires
- the match format defines a fixed turn or round cap

### Special Rules

- In the current widget, mismatched cards are temporarily locked before resetting, which prevents rapid mis-taps during the reveal delay.
- In competitive async mode, every player should receive the same board seed or same prepared board layout.

## Difficulty Structure

### Current Generator Behavior

The puzzle generator currently defines Memory Match difficulty like this:

- Easy: 4 pairs, max score 100, time limit based on 120s × 1.5.
- Medium: 6 pairs, max score 200, time limit based on 120s.
- Hard: 8 pairs, max score 300, time limit based on 120s × 0.7.

That corresponds to effective target time limits of:

- Easy: 180 seconds
- Medium: 120 seconds
- Hard: 84 seconds

### Target Difficulty Direction

- Easy: fewer pairs, simpler symbol set, longer reveal tolerance, stronger visual contrast.
- Medium: more pairs, denser board, faster decision-making, less forgiving memory load.
- Hard: larger or more visually complex board state, tighter timers, more similar symbols, reduced error tolerance.

The branding spec also defines an 18-pair core symbol set plus additional hard-tier symbols, which supports a more advanced content pipeline than the current emoji-based implementation.

## Winning And Scoring

### Current Widget Scoring

- +10 points for each successful pair.
- With 8 pairs on the current 4×4 widget board, the practical perfect score is 80.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, scoring should reflect more than simple pair count. A production scoring model should combine:

- pairs matched
- time efficiency
- miss efficiency or attempt count
- clean completion bonus
- optional streak or no-hint bonus

### Recommended Competitive Formula

One workable production formula would be:

```text
BaseScore = 10 × matchedPairs
CompletionBonus = 20 if all pairs are found
EfficiencyBonus = max(0, targetAttempts - actualAttempts)
TimeBonus = max(0, roundTimeLimit - secondsTaken)
HintPenalty = 5 × hintsUsed

FinalScore = BaseScore + CompletionBonus + EfficiencyBonus + TimeBonus - HintPenalty
```

This preserves the simplicity of the current widget while aligning better with async competitive comparison.

### Victory Condition

- In practice mode: solve the full board.
- In async multiplayer: compete for the best validated local Mind War result on the same puzzle setup, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use completion time or lower miss count.

## Mind War Ranking Methodology

Memory Match should treat each Mind War as a sealed local competition with one locked configuration for every player in that battle.

Each ranked or unranked Mind War instance should lock:

- Game ID: `memory-match`
- Difficulty tier
- Board seed or stored layout payload
- Pair count and symbol set
- Time limit or untimed rule
- Hint policy
- Scoring formula version
- Attempt-count and miss-count rules
- Ranked flag

### Exact Same Game Delivery Method

To ensure every player receives the exact same Memory Match game inside a Mind War:

- the server should issue one immutable battle payload containing either a full board layout or a deterministic board seed, plus the symbol set, pair count, timer rules, and hint policy
- each client should cache that payload locally and render the board from it without introducing any client-side reshuffle or symbol substitution
- final ranking should be validated by replaying the submitted flip history against that same payload on the server

Local Mind War placement should then be decided by:

1. Highest validated Final Score.
2. If scores tie, fastest validated completion time.
3. If still tied, fewer miss attempts.
4. If still tied, fewer total card flips.
5. If still tied after full validation, assign shared placement.

This keeps the local battle fair because every player receives the exact same board configuration and is compared only against others who played that identical package.

## Public Ranking Methodology

Public leaderboard routing should happen only when the Mind War is marked as ranked and the final result passes server validation.

Eligible runs should be written only into compatible leaderboard buckets for:

- Difficulty tier
- Assistance category: Pure if no hints were used, Assisted if any hint or reveal aid was used
- Scope: Global, Regional, or National

Within each compatible bucket, the public metric should be Best Valid Score, with ties ordered by:

1. Faster validated completion time.
2. Lower miss count.
3. Lower total flip count.
4. Earlier server-validated completion timestamp if the product requires a final deterministic ordering.

Unranked runs should still determine the winner of the local Mind War but must not alter persistent public boards.

## Async And Multiplayer Notes

### Async Format

Memory Match fits Mind Wars async play well because players do not need to interact in real time. Each player can complete the same board independently within the match window.

### Fairness Requirements

- All players in the same match should receive the same card layout or deterministic seed.
- Match conditions must be consistent across players: same board, same pair count, same symbol set, same timer rules.
- Final results should be validated server-side before local ranking is finalized and before any persistent leaderboard route is published.

### Server Validation

The authoritative backend should validate:

- board seed or puzzle ID
- submitted card match sequence
- completed pairs
- final score calculation
- completion time

### Offline-First Behavior

- Puzzle boards can be generated or cached locally.
- Player actions can be stored offline and submitted later.
- Sync conflict rules should preserve user input locally but allow the server to own scoring validation.

## Hints And Assistance

The shared hint system already includes Memory Match hint copy such as:

- focus on remembering positions in pairs
- work systematically row by row
- reveal the total number of unique pairs

For competitive play, hints should remain available but should reduce score or disable certain bonuses.

## UI And Interaction Notes

- The game is naturally mobile-friendly because each action is a direct tap.
- Card surfaces should remain visually clean and easily scannable on small screens.
- The branding spec defines a dedicated card-back treatment, abstract symbol packs, board texture, and match animation that should eventually replace the current emoji card faces.
- Touch handling should continue to prevent double-tapping the same card as a full pair action.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/memory_match_game.dart](../../lib/games/widgets/memory_match_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../lib/services/hint_and_challenge_system.dart)

Current state summary:

- The app has a playable classic Memory Match practice implementation.
- The generator already supports difficulty-based puzzle data.
- The production visual design is richer than the current widget and still needs rollout.
- Competitive async rules should standardize the generated board and move validation path.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Memory Match still needs:

- a locked board-payload format for ranked Mind Wars so every player receives the exact same pair layout
- server-side validation of flip history, miss count, completion state, and final score
- a finalized production scoring formula version that is carried in ranked battle metadata
- an explicit Pure versus Assisted rule for hints and any reveal aids

## Recommended Next Design Decisions

To finalize Memory Match as a full Mind Wars game, the next decisions should be documented explicitly:

1. Final production scoring formula.
2. Whether multiplayer uses shared exact card positions or shared symbol pool plus deterministic shuffle.
3. Whether hints are enabled in ranked matches.
4. Whether hard mode uses more pairs, more similar symbols, or both.
5. Whether completion time or miss count is the primary tiebreaker.

## Related References

- [lib/games/game_catalog.dart](../../lib/games/game_catalog.dart)
- [lib/games/widgets/memory_match_game.dart](../../lib/games/widgets/memory_match_game.dart)
- [lib/services/game_content_generator.dart](../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../lib/screens/offline_game_play_screen.dart)
- [docs/branding.md](../branding.md)
- [docs/ALPHA_IMPLEMENTATION_SUMMARY.md](../ALPHA_IMPLEMENTATION_SUMMARY.md)