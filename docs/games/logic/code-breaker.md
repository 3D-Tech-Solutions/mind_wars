# Code Breaker

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Logic |
| Players | 2-10 |
| Core Mechanic | Infer a hidden code using structured feedback |
| Async Compatible | Yes |
| Primary Cognitive Skill | Hypothesis testing and elimination |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator, alpha summary, release requirements |

## Overview

Code Breaker is a Mastermind-style deduction game where players guess a hidden code and use structured feedback to narrow the remaining possibilities. Strong play depends on information-efficient guesses, not blind trial and error.

Within Mind Wars, Code Breaker should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with clear input choices and readable feedback
- offline-first practice and cached battle content
- async fairness through identical hidden-code content for all players in the same match
- server-authoritative validation of guesses, feedback, and final score

## Current Implementation Snapshot

The current playable widget is a solid alpha implementation of the core Code Breaker loop and is closer to a production-ready game shape than several of the other early puzzle widgets.

Current observed widget behavior:

- Secret code length: 4 digits
- Symbol range: digits 1 through 6
- Input flow: player taps digits into a current guess until 4 digits are entered
- Guess submission: automatic once the fourth digit is entered
- Feedback types: exact-position matches and wrong-position matches
- Solved result: awards +50 and immediately completes the game
- Unsolved result: stores the guess, shows feedback, and clears the current guess
- Guess cap: none in the current widget

The current alpha game is therefore a playable Mastermind-style practice implementation, but it still differs from the stricter battle rules described elsewhere in the repo.

## Concept And Core Loop

### Concept

Players attempt to infer a hidden sequence by submitting guesses and interpreting feedback that tells them how many entries are exactly correct and how many belong in the code but are currently misplaced.

### Core Gameplay Loop

1. Enter a full guess using the available symbol set.
2. Submit the guess.
3. Review exact-match and wrong-position feedback.
4. Eliminate impossible code patterns.
5. Repeat until the code is cracked or attempts run out.

## Core Rules

### Setup

1. Generate a hidden code of defined length.
2. Keep the code secret from the player.
3. Provide an input surface containing the allowed symbols.
4. Apply mode-specific guess limits, timers, and scoring rules.

### Gameplay

1. The player assembles a full-length guess.
2. The guess is evaluated against the hidden code.
3. Feedback reports how many entries are exactly correct.
4. Feedback also reports how many remaining entries are correct but misplaced.
5. The player uses that information to refine the next guess.

### Ending

Code Breaker should end when one of the following conditions is met:

- the code is solved correctly
- the guess limit is exhausted
- the match timer expires
- the rules define a hard failure state after too many invalid actions

### Special Rules

- The current widget allows unlimited guessing until the player eventually solves the code.
- The current alpha implementation auto-submits the guess as soon as the fourth digit is entered.
- Ranked async play should standardize guess limits, scoring, and feedback rules across all players on the same code.

## Difficulty Structure

### Current Widget Behavior

- The widget currently uses a fixed 4-digit code.
- The symbol set is fixed to digits 1 through 6.
- There is no built-in easy, medium, or hard mode inside the widget.
- There is no explicit maximum guess count in the current implementation.

That makes the widget suitable for alpha practice, but it is less constrained than the intended competitive version.

### Current Generator Behavior

The content generator currently defines Code Breaker difficulty like this:

- Easy: 3-digit code
- Medium: 4-digit code
- Hard: 5-digit code

It also attaches:

- max score 100, 200, or 300 depending on difficulty
- a time limit based on 180 seconds

Unlike some other generators in the repo, the Code Breaker generator does already produce the core secret code payload.

### Existing Release Requirement Direction

The v1 release requirements define the public competitive version under the name `Mastermind` with these rules:

- 4-digit color code generated server-side with a locked seed
- solution encrypted at rest
- guess feedback computed server-side only
- score equals `90 - (10 x guesses)` with +15 bonus if solved in 6 or fewer guesses
- maximum 10 guesses
- unsolved games score 0

### Important Design Gap

There is still a meaningful mismatch across the current sources:

- The widget uses digits rather than colored pegs.
- The widget allows unlimited guesses and gives a flat +50 on success.
- The generator supports variable code lengths.
- The release spec expects a fixed 4-slot competitive format with server-side feedback and a 10-guess cap.

That gap should be resolved before ranked multiplayer rollout.

### Target Difficulty Direction

- Easy: shorter codes or more forgiving symbol sets for onboarding and practice.
- Medium: standard 4-position battle format.
- Hard: longer codes, stricter guess cap, or more symbol ambiguity if the game expands beyond v1.

If the release target remains the public `Mastermind` ruleset, ranked play should likely standardize on the 4-slot competitive format for fairness and comparability.

## Winning And Scoring

### Current Widget Scoring

- Solving the code awards +50.
- There is currently no penalty for extra guesses.
- There is no unsolved failure score because the game does not currently enforce a guess cap.

### Existing Product Scoring Direction

The release requirements already specify a target formula:

```text
FinalScore = 90 - (10 x guesses) + 15 if solved in 6 or fewer guesses
```

With the additional rule that unsolved games score 0.

## Mind War Ranking Methodology

Code Breaker should use the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md) as the platform contract, but each local Mind War still needs a locked battle configuration.

Each battle should lock:

- Game ID: `code-breaker`
- Difficulty tier
- Puzzle ID or deterministic hidden-code seed
- Code length and allowed symbol set
- Guess cap policy
- Hint policy
- Feedback rule set
- Scoring formula version
- Time rules
- Ranked flag

### Exact Same Game Delivery Method

To ensure every player receives the exact same Code Breaker game inside a Mind War:

- the server should issue one immutable battle payload containing the hidden code package or deterministic seed, code length, allowed symbol set, feedback rules, guess-cap policy, and hint policy
- each client should cache that payload locally and use it only for controlled guess submission and feedback rendering rather than generating a local secret code
- final ranking should be validated by replaying every submitted guess against that same hidden-code package on the server

Local Mind War placement should be decided by:

1. Highest validated Final Score.
2. If scores tie, solved status beats unsolved status.
3. If still tied, fewer guesses.
4. If still tied, faster validated completion time.
5. If still tied, fewer hints used.
6. If still tied after full validation, assign shared placement.

This keeps local battle placement clear while preventing comparisons across incompatible Code Breaker variants or hidden-code packages.

## Public Ranking Methodology

If a Code Breaker Mind War is marked as ranked, completed runs should route only into compatible persistent leaderboard buckets after server validation.

Each eligible run should be written only into buckets for:

- Difficulty tier: Easy, Medium, or Hard
- Assistance category: Pure if no hints were used, Assisted if any hints were used
- Scope: Global, Regional, or National

Within each compatible bucket, the public metric should be Best Valid Score, with ties ordered by:

1. Solved status over unsolved status.
2. Fewer guesses.
3. Faster validated completion time.
4. Fewer hints used.

That means a Hard ranked Pure run can affect Hard / Pure views, while an otherwise identical run that used a hint must route to Hard / Assisted instead. Unranked runs should still settle the local Mind War but must not alter persistent public boards.

### Victory Condition

- In practice mode: crack the current secret code.
- In async multiplayer: win the local Mind War on the exact same hidden code package, then route eligible ranked runs into the matching persistent leaderboard buckets defined in the shared ranking spec.
- Secondary tiebreakers can use faster completion time after equal guess count.

## Async And Multiplayer Notes

### Async Format

Code Breaker works very well asynchronously because every player can solve the same hidden code independently while the server preserves fairness and secrecy.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The secret code, guess limit, hint rules, scoring rules, and feedback rules must be identical for all players.
- Competitive matches should use a deterministic server-generated code or an explicit stored puzzle payload rather than local random generation.
- The broader platform target remains support for matches up to 10 players even though the current catalog entry reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or locked seed
- hidden code payload
- each submitted guess
- exact-match and wrong-position feedback
- guess count
- hint usage if applicable
- final score and solve status
- persistent leaderboard routing based on ranked flag, difficulty, and Pure versus Assisted eligibility

### Offline-First Behavior

- Practice codes can be generated locally.
- Battle codes can be cached locally once distributed.
- Guess history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

The shared hint system already supports Code Breaker and currently exposes hints such as:

- the code length
- the fact that each digit is between 1 and 6
- the first digit of the code
- a suggestion to use previous feedback carefully

In ranked multiplayer, hints should remain optional and should reduce score or disable certain bonuses. Revealing the first digit is especially strong and should be governed carefully in competitive play.

## UI And Interaction Notes

- The current digit-button input is simple and mobile friendly.
- The branding spec points toward a peg-based visual system with dedicated feedback pegs, a hidden-code shield, and a reveal animation.
- If the production version shifts from digits to colored pegs, the UI should preserve strong contrast and avoid ambiguity between visually similar choices.
- Guess history readability matters because players rely on scanning prior attempts for deduction.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/code_breaker_game.dart](../../../lib/games/widgets/code_breaker_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Alpha summary: [docs/ALPHA_IMPLEMENTATION_SUMMARY.md](../../ALPHA_IMPLEMENTATION_SUMMARY.md)
- Release requirements: [docs/project/V1_0_RELEASE_REQUIREMENTS.md](../../project/V1_0_RELEASE_REQUIREMENTS.md)

Current state summary:

- The app has a playable Mastermind-style Code Breaker implementation.
- The generator already produces secret-code content and difficulty-based code lengths.
- The release requirements define a stricter public competitive format than the current alpha widget enforces.
- The branded visual language is richer than the current digit-card presentation.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Code Breaker still needs:

- one locked ranked rule package for code length, guess-cap policy, hint policy, and scoring version
- server-side validation of every guess, returned feedback, solve status, and ranked routing metadata
- a final product decision on digits versus colored pegs so ranked visuals match the public ruleset
- confirmation of whether unsolved runs and hard-mode variants belong in public ladders

## Recommended Next Design Decisions

To finalize Code Breaker as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether the public competitive version keeps the current `Code Breaker` name or aligns fully to the `Mastermind` release label.
2. Whether ranked play uses digits, colored pegs, or a skinned version of the same underlying 1-6 value system.
3. Whether hard mode exists in ranked play or whether public battle mode standardizes on a fixed 4-slot competitive format.
4. Whether completion time is only a tiebreaker or part of the main score formula.
5. Whether hints are disabled entirely in ranked mode or retained with strict Pure versus Assisted leaderboard separation.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/code_breaker_game.dart](../../../lib/games/widgets/code_breaker_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)
- [docs/ALPHA_IMPLEMENTATION_SUMMARY.md](../../ALPHA_IMPLEMENTATION_SUMMARY.md)
- [docs/project/V1_0_RELEASE_REQUIREMENTS.md](../../project/V1_0_RELEASE_REQUIREMENTS.md)