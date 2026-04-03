# Sequence Recall

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Memory |
| Players | 2-10 |
| Core Mechanic | Watch and repeat ordered sequences |
| Async Compatible | Yes |
| Primary Cognitive Skill | Sequential working memory |
| Current Source Basis | Game catalog, branding spec, alpha summary, widget implementation, puzzle generator |

## Overview

Sequence Recall challenges players to observe a sequence of visual signals and reproduce it in the correct order. The game emphasizes short-term memory, attention control, and consistency as sequences lengthen.

Within Mind Wars, Sequence Recall should preserve the same platform-level rules as every core game:

- mobile-first interaction with large, obvious tap targets
- offline-first play through locally generated or cached puzzle content
- async fairness via shared sequence content or deterministic seeds
- server-authoritative validation of score and completion results

## Current Implementation Snapshot

The current playable widget presents a 2×2 grid of four large colored buttons. The game automatically flashes a sequence after a short delay, asks the player to repeat it, and advances to the next level when the sequence is entered correctly.

Current observed widget behavior:

- Input surface: 4 colored buttons
- Level 1 sequence length: `3 + level`, which starts at 4 items
- Correct reward: `10 × current level`
- Correct result: advance one level and generate a fresh sequence
- Wrong result: clear the player's current attempt and retry
- Replay option: player can show the sequence again manually

The current widget behaves like an endless progressive practice mode. It does not currently define a fixed number of rounds or an explicit end state, which means it is functionally playable but not yet aligned to a finalized competitive match format.

## Concept And Core Loop

### Concept

Players observe a short sequence of visual cues and then reproduce it from memory in the correct order. The challenge escalates by increasing sequence length, tightening playback clarity, or increasing distractor complexity.

### Core Gameplay Loop

1. Watch the presented sequence.
2. Encode the order of cues before the playback phase ends.
3. Reproduce the sequence through taps.
4. Receive immediate correctness feedback.
5. Advance to a harder sequence or retry after failure.

## Core Rules

### Setup

1. Generate a sequence puzzle or level state.
2. Determine the sequence length based on difficulty or current level.
3. Present a visual input surface with clearly distinguishable buttons or nodes.
4. Begin the sequence display phase.

### Gameplay

1. The game shows a sequence one step at a time.
2. Each cue becomes active briefly, then turns off before the next cue begins.
3. When playback finishes, the player reproduces the sequence in order.
4. The input is validated step by step.
5. A correct full entry increases score and difficulty.
6. A wrong input clears the current attempt and forces a retry or applies a competitive penalty.

### Ending

Sequence Recall should end when one of the following conditions is met:

- a fixed round count is completed
- the player fails too many times
- the match timer expires
- the async battle rules define a capped session length

### Special Rules

- In the current widget, the same level can be retried indefinitely after an error.
- The player can replay the sequence manually through a dedicated action button.
- Competitive async mode should avoid unlimited replay without a clear score cost or cap.

## Difficulty Structure

### Current Widget Behavior

- The widget uses level-based scaling.
- Sequence length is generated as `3 + level`.
- Level 1 therefore begins at 4 steps, not 3.
- Each correct round increases level by 1 and regenerates the sequence.

### Current Generator Behavior

The content generator currently defines a different fixed model:

- Easy: sequence length 4, max score 100, time limit based on 60s × 1.5
- Medium: sequence length 6, max score 200, time limit based on 60s
- Hard: sequence length 8, max score 300, time limit based on 60s × 0.7

That corresponds to effective target time limits of:

- Easy: 90 seconds
- Medium: 60 seconds
- Hard: 42 seconds

### Important Design Gap

There is currently a rules mismatch between the widget and generator:

- The widget uses 4 button inputs and randomly generates values from 0-3.
- The generator currently creates numeric sequences using values from 1-9.

That mismatch should be resolved before ranked or server-validated multiplayer rollout.

### Target Difficulty Direction

- Easy: shorter sequences, slower playback, replay-friendly presentation.
- Medium: longer sequences, reduced pause between flashes, less recovery time.
- Hard: longer chains, faster playback, stricter retry rules, and less forgiving scoring.

The branding spec suggests a node-state system, which supports a cleaner long-term visual identity than the current four-color practice layout.

## Winning And Scoring

### Current Widget Scoring

- Each correct round awards `10 × current level`.
- Because the score is level-based, later correct rounds are worth more than earlier ones.
- There is currently no explicit end condition in the widget, so score growth is theoretically open-ended.

### Current Alpha Documentation

- Alpha documentation describes progressive difficulty and `10 points × level` scoring for each correct sequence.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- sequence length completed
- accuracy
- retry count
- time efficiency
- optional replay penalties if the sequence can be shown again

### Recommended Competitive Formula

One workable production formula would be:

```text
BaseScore = 10 × sequenceLength
LevelBonus = 5 × completedLevel
TimeBonus = max(0, roundTimeLimit - secondsTaken)
ReplayPenalty = 5 × replayCount
MistakePenalty = 10 × failedAttempts

FinalScore = BaseScore + LevelBonus + TimeBonus - ReplayPenalty - MistakePenalty
```

### Victory Condition

- In practice mode: reach the highest level possible.
- In async multiplayer: compete for the best validated local Mind War result on the same fixed sequence set, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use fewer failed attempts or faster completion time.

## Mind War Ranking Methodology

Sequence Recall should treat each Mind War as a sealed local competition where every player receives the exact same sequence package and ruleset.

Each battle should lock:

- Game ID: `sequence-recall`
- Difficulty tier
- Sequence seed or stored sequence payload
- Sequence length plan or round count
- Replay policy
- Hint policy
- Time rules
- Scoring formula version
- Failure-attempt limits
- Ranked flag

### Exact Same Game Delivery Method

To ensure every player receives the exact same Sequence Recall game inside a Mind War:

- the server should issue one immutable battle payload containing the exact sequence package, reveal timing, replay policy, timer values, and hint policy
- each client should cache that payload locally and play back the sequence from the locked package rather than generating prompts on-device
- final ranking should be validated by checking the submitted tap order, replay usage, and failure count against that same payload on the server

Local Mind War placement should be decided by:

1. Highest validated Final Score.
2. If scores tie, highest completed level or longest validated sequence.
3. If still tied, fewer failed attempts.
4. If still tied, fewer replay uses.
5. If still tied, faster validated completion time.
6. If still tied after full validation, assign shared placement.

This preserves fairness because players are compared only against others who played the same fixed sequence content under the same replay and timing rules.

## Public Ranking Methodology

Public leaderboard routing should occur only for runs from ranked Mind Wars that complete under a server-validated configuration.

Eligible runs should route to the matching persistent buckets for:

- Difficulty tier
- Assistance category: Pure if no hints or replay assistance were used, Assisted if any hint or replay aid was used
- Scope: Global, Regional, or National

Within each bucket, the public metric should be Best Valid Score, with ties ordered by:

1. Higher completed level or longer validated sequence.
2. Fewer failed attempts.
3. Fewer replay uses.
4. Faster validated completion time.

Unranked runs remain valid for local battle placement only and must not update public boards.

## Async And Multiplayer Notes

### Async Format

Sequence Recall works cleanly as an async game because each player can complete the same prompt set independently, without requiring live interaction with opponents.

### Fairness Requirements

- Every player in a match should receive the same sequence content.
- Sequence length, replay rules, timers, and scoring rules must be identical for all players.
- The production version should use a deterministic seed or explicit puzzle payload.

### Server Validation

The authoritative backend should validate:

- sequence seed or puzzle ID
- the generated source sequence
- player tap order
- retry count and replay count
- final score and completion time

### Offline-First Behavior

- Sequence puzzles can be generated locally or cached for offline matches.
- Input history can be stored offline and uploaded later.
- Final ranked scoring should still be confirmed server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

The shared hint system already supports Sequence Recall and currently exposes hints such as:

- the total sequence length
- the first number in the sequence
- the last number in the sequence
- a chunking recommendation for memorization

In ranked multiplayer, hints should remain optional and should reduce score or disqualify certain bonuses.

## UI And Interaction Notes

- The current widget uses a 2×2 layout with strong color separation, which is good for mobile clarity.
- Flash timing in the current implementation is roughly 600ms on, 300ms off, after a short lead-in.
- The replay button is useful for practice but should be governed carefully in ranked mode.
- The branding spec supports a more abstract node-based visual system that can replace the current color-block practice layout later.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/sequence_recall_game.dart](../../lib/games/widgets/sequence_recall_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../lib/services/hint_and_challenge_system.dart)

Current state summary:

- The app has a playable Sequence Recall practice implementation.
- The generator already defines fixed easy, medium, and hard sequence lengths.
- The widget and generator currently describe different sequence models and should be reconciled.
- The production visual system is richer than the current practice interface and still needs rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Sequence Recall still needs:

- one canonical ranked sequence model so the widget and generator no longer describe different rule sets
- deterministic sequence payloads with locked replay policy for every player in the same Mind War
- server-side validation of tap order, replay usage, failed attempts, and final score
- a final decision on whether replay assistance is allowed in Pure ladders at all

## Recommended Next Design Decisions

To finalize Sequence Recall as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether the production input surface uses 4 nodes, more nodes, or difficulty-based node counts.
2. Whether replaying the sequence is free, limited, or score-penalized in ranked matches.
3. Whether a match uses endless progression, fixed rounds, or capped failure attempts.
4. Whether the generator should be updated to match the widget or the widget should be rebuilt around the generator.
5. Whether timing or raw level progression is the primary tiebreaker.

## Related References

- [lib/games/game_catalog.dart](../../lib/games/game_catalog.dart)
- [lib/games/widgets/sequence_recall_game.dart](../../lib/games/widgets/sequence_recall_game.dart)
- [lib/services/game_content_generator.dart](../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../lib/screens/offline_game_play_screen.dart)
- [docs/branding.md](../branding.md)
- [docs/ALPHA_IMPLEMENTATION_SUMMARY.md](../ALPHA_IMPLEMENTATION_SUMMARY.md)