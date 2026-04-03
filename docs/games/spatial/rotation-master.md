# Rotation Master

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Spatial |
| Players | 2-10 |
| Core Mechanic | Identify the correct rotated version of a target form |
| Async Compatible | Yes |
| Primary Cognitive Skill | Mental rotation |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Rotation Master tests mental-rotation skill by asking players to compare a target form against several candidate orientations and choose the matching rotation. Strong play depends on visual transformation accuracy, not guesswork.

Within Mind Wars, Rotation Master should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with highly legible target forms and answer tiles
- offline-first play through local or cached prompt sets
- async fairness through identical target prompts and answer sets for all players in a match
- server-authoritative validation of prompt sequence, answers, and final score

## Current Implementation Snapshot

The current playable widget is a letter-rotation multiple-choice game rather than a richer abstract-shape library challenge.

Current observed widget behavior:

- Target pool: 8 character-based shapes `F, R, P, L, Z, N, G, J`
- Rotation model: target and answers use only `0, 90, 180, 270` degrees
- Prompt format: one target form displayed at a chosen rotation
- Answer format: 4 multiple-choice options showing the same base form at different rotations
- Correct result: streak increases and points equal `10 + (streak x 2)`
- Wrong result: streak resets and the next round begins immediately
- Progression: advances through 15 levels, then completes the game
- Distractor model: other three quarter-turn rotations of the same base form

This makes the alpha version a working mental-rotation game, but it is simpler than the production design implied by the branding and asset planning documents.

## Concept And Core Loop

### Concept

Players inspect a target form, mentally rotate it, and identify which answer option represents the same form in the correct orientation.

### Core Gameplay Loop

1. Observe the target form.
2. Mentally transform the target orientation.
3. Compare the answer options.
4. Select the matching rotated form.
5. Continue through the prompt sequence while maintaining streak and accuracy.

## Core Rules

### Setup

1. Select a base form for the round.
2. Apply a target rotation.
3. Generate answer options with one correct orientation and several distractors.
4. Apply mode-specific timer, streak, and scoring rules.

### Gameplay

1. The player studies the target form.
2. The player compares the answer options.
3. The player selects the option that represents the correct rotated match.
4. Correct answers increase score and may build streak.
5. Incorrect answers should reduce competitive efficiency through score or streak loss.

### Ending

Rotation Master should end when one of the following conditions is met:

- a fixed prompt set is completed
- the timer expires
- the format uses a mistake cap
- the progression ladder reaches its end

### Special Rules

- In the current widget, all answer options are quarter-turn rotations of the same underlying form.
- The current alpha implementation does not yet use mirrored distractors or non-letter abstract forms.
- Competitive async play should standardize prompt count, answer ordering, and distractor rules for all players.

## Difficulty Structure

### Current Widget Behavior

- The widget uses a fixed 4-option multiple-choice format.
- It uses 8 base forms.
- It restricts all rotations to quarter turns.
- Difficulty is represented mostly by sustained streak play rather than by expanding shape complexity.

That makes the current implementation a useful mental-rotation prototype, but it is less sophisticated than the intended production concept.

### Current Generator Behavior

The content generator currently defines Rotation Master difficulty like this:

- Easy: 5 rotations
- Medium: 8 rotations
- Hard: 12 rotations

It also attaches:

- max score 100, 200, or 300 depending on difficulty
- a time limit based on 90 seconds

However, the generated puzzle package currently stores only `rotationCount` metadata with an empty `matches` solution list. That means it does not yet define a real prompt sequence, shape library usage, or answer payload.

### Important Design Gap

There is a meaningful mismatch across the current sources:

- The widget is a letter-based quarter-turn multiple-choice game.
- The generator only stores rotation-count scaffolding.
- The branding system expects a 20-shape geometric library, explicit answer states, and richer visual identity than rotated letters.

That gap should be resolved before ranked multiplayer rollout.

### Target Difficulty Direction

- Easy: simpler shapes, clearer angular differences, and fewer prompts.
- Medium: more complex silhouettes, more similar distractors, and longer prompt sets.
- Hard: mirrored distractors, subtler angle differences, and tighter time pressure.

If the production version aligns with the branding plan, difficulty should come from actual spatial transformation complexity rather than only from streak length.

## Winning And Scoring

### Current Widget Scoring

- Correct answer score: `10 + (streak x 2)`
- Wrong answer: streak resets and no score gain
- Completion: after level 15

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- total correct answers
- streak consistency
- prompt completion speed
- wrong answers
- hint usage if hints exist

### Recommended Competitive Formula

One workable production formula would be:

```text
BaseScore = 10 x correctAnswers
StreakBonus = totalStreakBonusEarned
TimeBonus = max(0, roundTimeLimit - secondsTaken)
WrongPenalty = 5 x incorrectAnswers
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + StreakBonus + TimeBonus - WrongPenalty - HintPenalty
```

This preserves the streak-driven character of the alpha widget while making accuracy and time more explicit in ranked play.

### Recommended Ranked Formula For Rotation Master Mind Wars

To align Rotation Master with the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md), the recommended ranked formula for sealed Mind War competition is:

```text
BaseScore = 10 x correctAnswers
StreakBonus = totalStreakBonusEarned
TimeBonus = max(0, totalTimeBudgetSeconds - totalResponseTimeSeconds)
WrongPenalty = 5 x incorrectAnswers
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + StreakBonus + TimeBonus - WrongPenalty - HintPenalty
```

Where:

- `correctAnswers` = total validated correct responses
- `totalStreakBonusEarned` = all streak-related bonus points accumulated during the run
- `totalTimeBudgetSeconds` = deterministic prompt budget declared by the Mind War
- `totalResponseTimeSeconds` = validated elapsed response time across the prompt set
- `incorrectAnswers` = wrong responses submitted during the run
- `hintsUsed` = all assists consumed during the run

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: continue through the progression ladder and maximize score.
- In async multiplayer: compete for the best validated local Mind War result on the exact same prompt sequence and answer ordering, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use higher accuracy, then faster completion time.

## Mind War Ranking Methodology

### Purpose

For Rotation Master, the Mind War ranking layer answers:

> Who performed best on this exact rotation prompt set under these exact validation and scoring rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Rotation Master Mind War should define the following immutable fields at creation time:

| Field | Rotation Master Requirement |
|---|---|
| Game ID | `rotation_master` |
| Difficulty Tier | Easy, Medium, or Hard |
| Challenge Seed | Deterministic server-generated seed or stored prompt payload |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included as a scoring modifier through response-time accounting |
| Attempt Limits | Fixed prompt count, mistake cap, or fixed session window |
| Ranked Flag | Yes or No |

For Rotation Master specifically, the deterministic package should also lock:

- prompt sequence
- target form identities
- target rotations
- answer-option ordering
- distractor rules
- timer rules
- scoring weights

### Exact Same Game Delivery Method

To ensure every player receives the exact same Rotation Master game inside a Mind War:

- the server should issue one immutable battle payload containing the exact prompt order, shape IDs, target rotations, answer ordering, mirror rules, timer rules, and hint policy
- each client should cache that payload locally and present the same prompt and answer set without local option reshuffling or substitute shapes
- final ranking should be validated by replaying the submitted answers against that same prompt package on the server

### Mind War Final Score Rule

Players in a Rotation Master Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = BaseScore + StreakBonus + TimeBonus - WrongPenalty - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Rotation Master runs share the same `FinalScore`, the recommended tiebreak order is:

1. Fewer incorrect answers
2. Faster total validated completion time
3. Shared placement

This matches the platform template while using the game's natural equivalent for fewer attempts.

### Mind War Output

Each Rotation Master Mind War should produce:

- ordered placements
- final scores
- total correct answers
- total incorrect answers
- total completion time
- hints used
- streak bonus total
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If a Rotation Master Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Rotation Master under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Rotation Master Mind Wars affect only the local Mind War results.
- Ranked Rotation Master Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Rotation Master should follow the platform matrix exactly:

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

Rotation Master public rankings should therefore exist as:

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

A Rotation Master run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Rotation Master is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Rotation Master result screen should display:

- Mind War placement
- final score
- difficulty tier
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Rotation Master works well asynchronously because every player can complete the same prompt set independently while the system compares validated outcomes afterward.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The target forms, rotations, answer options, timer rules, and scoring rules must be identical for all players.
- Competitive matches should use an explicit server-generated prompt payload rather than local random prompt creation.
- The broader platform should support matches up to 10 players even though the current catalog entry still reflects an older smaller range.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- prompt sequence
- target form identities and rotations
- answer-option ordering
- player responses
- correct and incorrect counts
- streak progression and final score

### Offline-First Behavior

- Practice prompt sets can be generated locally.
- Battle prompt payloads can be cached locally once distributed.
- Response history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

There is currently no dedicated Rotation Master hint branch in the generic offline screen beyond the default fallback hint text.

That means the current practice experience does not yet offer game-specific help such as:

- showing the axis or direction of rotation
- eliminating one distractor
- briefly previewing the target in intermediate rotation steps

If ranked hints are enabled later, they should carry a clear score penalty and reveal only limited information.

## UI And Interaction Notes

- The current target-and-4-options layout is clear and mobile friendly.
- The production shape-library version described in the branding system would benefit from more abstract, less letter-like forms to avoid language bias.
- Answer tiles need strong contrast and consistent centering so players are tested on rotation skill rather than rendering ambiguity.
- If mirrored distractors are added later, the UI will need to ensure players can distinguish reflection from rotation cleanly.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/rotation_master_game.dart](../../../lib/games/widgets/rotation_master_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Branding direction: [docs/branding.md](../../branding.md)

Current state summary:

- The app has a playable multiple-choice mental-rotation widget.
- The current widget is simpler than the intended abstract-shape production design.
- The generator currently provides only rotation-count scaffolding, not a real prompt payload.
- Ranked multiplayer will need deterministic prompt generation, server-side validation, and explicit leaderboard-routing metadata before rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Rotation Master still needs:

- a locked ranked prompt-pack format so every player receives the same ordered shape set
- server-side validation of answer sequence, timing, mistakes, and final score
- a final decision on whether mirrored prompts are part of all ranked tiers or only some difficulties
- explicit assistance rules for Pure versus Assisted buckets if shape previews or clarifiers are ever introduced

## Recommended Next Design Decisions

To finalize Rotation Master as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production keeps the current letter-like forms or shifts fully to the planned abstract shape library.
2. Whether mirrored distractors are included in ranked mode or reserved for hard difficulty only.
3. Whether prompt order and answer ordering are fixed by battle payload for strict fairness.
4. Whether streak remains a core scoring mechanic or becomes secondary to raw accuracy and time.
5. Whether the generator and backend should share a single shape-prompt builder to guarantee identical multiplayer content.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/rotation_master_game.dart](../../../lib/games/widgets/rotation_master_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)