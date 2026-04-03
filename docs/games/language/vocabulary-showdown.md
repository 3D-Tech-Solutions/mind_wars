# Vocabulary Showdown

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Language |
| Players | 2-10 |
| Core Mechanic | Answer vocabulary questions accurately and quickly |
| Async Compatible | Yes |
| Primary Cognitive Skill | Vocabulary knowledge and fast semantic retrieval |
| Current Source Basis | Game catalog, branding spec, production widget implementation, vocabulary service layer, scoring utility, implementation docs |

## Overview

Vocabulary Showdown is a rapid-fire vocabulary challenge built around speed, accuracy, and adaptive difficulty. Players answer definition, synonym, and fill-in-the-blank prompts while the system scores both correctness and response speed.

Within Mind Wars, Vocabulary Showdown should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with readable prompt layout and fast answer input
- offline-first play through local or cached seeded session payloads
- async fairness through identical question order, answer options, and timers for all players in a match
- server-authoritative validation of the seed, answer log, timing, and final score

## Current Implementation Snapshot

Vocabulary Showdown is one of the most mature game implementations currently in the repo and is much closer to production shape than many of the other alpha puzzle widgets.

Current observed implementation behavior:

- Session size: 10 questions by default
- Determinism: session creation is seed-based for reproducible multiplayer fairness
- Question types: multiple choice, fill-in-the-blank, synonym or antonym prompts
- Scoring model: hybrid accuracy plus speed formula with difficulty multipliers
- Streak system: capped streak bonuses at defined milestones
- Difficulty system: adaptive targeting around a 70% success rate
- Timing system: per-question timers with automatic timeout submission
- Feedback: per-question score breakdown dialog with correct-answer review
- Validation: answer processing and session state handled through a dedicated service layer

This makes Vocabulary Showdown one of the clearest examples of a Mind Wars-compliant service-oriented game architecture in the codebase.

## Concept And Core Loop

### Concept

Players answer seeded vocabulary prompts as accurately and quickly as possible, building streaks and exploiting higher difficulty tiers for stronger scoring.

### Core Gameplay Loop

1. Read the prompt.
2. Interpret the question type.
3. Submit the answer before the timer expires.
4. Receive validation and a score breakdown.
5. Continue through the seeded question set.

## Core Rules

### Setup

1. Generate a deterministic question session from a seed.
2. Assign question types, difficulty distribution, and timing windows.
3. Present the first prompt with the appropriate answer UI.
4. Apply scoring, streak, and hint rules.

### Gameplay

1. The player reads the prompt.
2. The player answers through option selection or text entry depending on question type.
3. The system validates correctness and records response time.
4. Correct answers contribute accuracy score, speed score, and possible streak bonus.
5. The session ends when all questions are answered or timed out.

### Ending

Vocabulary Showdown should end when one of the following conditions is met:

- the fixed question set is completed
- the session timer or all per-question timers are exhausted
- the format uses a hard end-state after all questions resolve

### Special Rules

- In the current implementation, timed-out answers are auto-submitted as wrong.
- Difficulty adjusts between games, but seeded session generation still allows fair same-seed comparison.
- Competitive async play should standardize question order, option order, timer values, difficulty tier logic, and scoring weights across all players.

## Difficulty Structure

### Current Implementation Behavior

The current documented structure includes:

- four effective difficulty tiers through multiplier bands
- adaptive difficulty adjustment targeting roughly 70% success rate
- multiple question types with different time budgets

Question types currently implemented:

- multiple choice
- fill-in-the-blank
- synonym or antonym prompts

### Difficulty Multipliers

The current production scoring utility defines:

- Tier 1: `1.0x`
- Tier 2: `1.5x`
- Tier 3: `2.0x`
- Tier 4: `2.5x`

### Timing Budgets

The technical docs currently describe:

- Multiple choice: 25 seconds
- Fill-in-the-blank: 35 seconds
- Synonym or antonym prompts: 30 seconds

### Target Difficulty Direction

- Easy: lower-tier prompts, more common vocabulary, stronger readability.
- Medium: broader semantic range and tighter timing pressure.
- Hard: rarer words, higher tiers, and greater accuracy pressure.

Because the game already has adaptive difficulty logic, ranked Mind Wars should lock the exact session payload and tier distribution rather than relying on live post-answer adaptation inside a shared competitive instance.

## Winning And Scoring

### Current Implemented Scoring Model

Vocabulary Showdown already has a documented hybrid scoring model based on:

- accuracy points
- speed points
- difficulty multiplier
- streak bonuses

The current technical implementation defines:

```text
AccuracyPoints = correct ? 1000 : 0
SpeedPoints = max(200, 1000 x (1 - timeTaken/maxTime))
RawScore = (AccuracyPoints x 0.7) + (SpeedPoints x 0.3)
QuestionScore = round(RawScore x DifficultyMultiplier)
```

With capped streak bonuses:

- 3 questions: +100
- 5 questions: +300
- 7 questions: +500
- 10+ questions: +1000 maximum

### Recommended Ranked Formula For Vocabulary Showdown Mind Wars

To align Vocabulary Showdown with the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md), the recommended ranked formula for sealed Mind War competition is:

```text
QuestionScore = round(((AccuracyPoints x 0.7) + (SpeedPoints x 0.3)) x DifficultyMultiplier)
FinalScore = sum(QuestionScore across session) + StreakBonusTotal - HintPenalty
```

Where:

- `AccuracyPoints = 1000` for a correct answer, otherwise `0`
- `SpeedPoints = max(200, 1000 x (1 - timeTaken/maxTime))`
- `DifficultyMultiplier` comes from the locked tier mapping for the session payload
- `StreakBonusTotal` is the sum of awarded capped streak bonuses
- `HintPenalty` should be defined explicitly if hints are enabled in ranked sessions

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: complete the full question set with the highest possible score.
- In async multiplayer: compete for the best validated local Mind War result on the exact same seeded session, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use more correct answers, then faster total response time.

## Mind War Ranking Methodology

### Purpose

For Vocabulary Showdown, the Mind War ranking layer answers:

> Who performed best on this exact seeded vocabulary session under these exact scoring and timing rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Vocabulary Showdown Mind War should define the following immutable fields at creation time:

| Field | Vocabulary Showdown Requirement |
|---|---|
| Game ID | `vocabulary_showdown` |
| Difficulty Tier | Locked tier package or fixed tier distribution |
| Challenge Seed | Deterministic server-generated session seed |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included through per-question timing and speed scoring |
| Attempt Limits | Fixed question count and one scored answer resolution per question |
| Ranked Flag | Yes or No |

For Vocabulary Showdown specifically, the deterministic package should also lock:

- question order
- question types
- option ordering
- timer values
- difficulty tier mapping
- streak bonus rules
- scoring weights

### Exact Same Game Delivery Method

To ensure every player receives the exact same Vocabulary Showdown game inside a Mind War:

- the server should issue one immutable battle payload containing the session seed or explicit question set, question order, answer ordering, timer values, tier mapping, streak rules, and hint policy
- each client should cache that payload locally and run the session from that exact package without local reshuffling or live difficulty drift inside the sealed match
- final ranking should be validated by replaying the answer log and timing data against that same session payload on the server

### Mind War Final Score Rule

Players in a Vocabulary Showdown Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = sum(QuestionScore across session) + StreakBonusTotal - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Vocabulary Showdown runs share the same `FinalScore`, the recommended tiebreak order is:

1. More correct answers
2. Faster total validated response time
3. Shared placement

This matches the platform template while using the game's natural equivalent for fewer attempts.

### Mind War Output

Each Vocabulary Showdown Mind War should produce:

- ordered placements
- final scores
- per-question correctness
- total correct answers
- total response time
- streak bonus total
- hint usage
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If a Vocabulary Showdown Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Vocabulary Showdown under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Vocabulary Showdown Mind Wars affect only the local Mind War results.
- Ranked Vocabulary Showdown Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Vocabulary Showdown should follow the platform matrix exactly:

#### Axis A: Difficulty

- Easy leaderboard
- Medium leaderboard
- Hard leaderboard

Or a locked tier-distribution leaderboard model if the platform chooses to group seeded mixed-tier sessions under one declared difficulty package.

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

Vocabulary Showdown public rankings should therefore exist as:

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

A Vocabulary Showdown run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty package matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Vocabulary Showdown is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Vocabulary Showdown result screen should display:

- Mind War placement
- final score
- difficulty tier or tier package
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Vocabulary Showdown works very well asynchronously because every player can receive the same seeded session and complete it independently while the server replays the seed and answer log afterward.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The question order, answer options, timer rules, difficulty tier mapping, and scoring rules must be identical for all players.
- Competitive matches should use explicit server-generated session payloads or replayable seeds rather than local ad hoc generation.
- The current implementation already aligns with the broader 2-10 player platform target.

### Server Validation

The authoritative backend should validate:

- session seed
- question order and types
- option ordering
- answer log
- per-question timing
- streak bonus triggers
- hint usage if applicable
- final score and ranking route

### Offline-First Behavior

- Seeded sessions can be cached locally once distributed.
- Local answer logs can be stored offline and synchronized later.
- Because the generation model is deterministic, the server can replay and validate a run after sync.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

Vocabulary Showdown is already well suited to explicit assistance policies because its scoring model is granular and replayable. If hints are enabled in ranked variants, they should be logged and penalized in a clearly declared way rather than applied implicitly.

## UI And Interaction Notes

- The production widget already supports multiple question types, timers, and score-breakdown feedback.
- The current implementation is service-oriented and significantly more mature than most other games in the repo.
- Because this is a language-speed game, readability and timer clarity matter more than visual ornament.
- Post-answer breakdown dialogs are valuable, but ranked sessions should ensure they do not alter the timing model unfairly.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/vocabulary_showdown_game.dart](../../../lib/games/widgets/vocabulary_showdown_game.dart)
- Service layer: [lib/services/vocabulary_game_service.dart](../../../lib/services/vocabulary_game_service.dart)
- Models: [lib/models/vocabulary_models.dart](../../../lib/models/vocabulary_models.dart)
- Scoring utility: [lib/utils/vocabulary_scoring_utility.dart](../../../lib/utils/vocabulary_scoring_utility.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Branding direction: [docs/branding.md](../../branding.md)
- Technical implementation doc: [docs/VOCABULARY_SHOWDOWN_README.md](../../VOCABULARY_SHOWDOWN_README.md)
- Summary doc: [docs/VOCABULARY_SHOWDOWN_SUMMARY.md](../../VOCABULARY_SHOWDOWN_SUMMARY.md)
- Migration doc: [docs/VOCABULARY_SHOWDOWN_MIGRATION.md](../../VOCABULARY_SHOWDOWN_MIGRATION.md)

Current state summary:

- Vocabulary Showdown is one of the most production-ready games in the repo.
- The implementation already uses deterministic session generation, a dedicated service layer, and a detailed scoring utility.
- The main remaining gap in the game docs was explicit ranked-routing language and a full platform-aligned ranking-methodology section.
- Ranked multiplayer is conceptually well aligned because replayable seeds and detailed answer logs already fit server validation cleanly.

## Ranked Readiness

Status: Strong foundation.

Before ranked rollout, Vocabulary Showdown still needs:

- final platform integration for ranked routing, bucket assignment, and leaderboard persistence
- a locked ranked assistance policy if hints or breakdown aids are exposed in competitive sessions
- backend confirmation that answer logs, timing, and streak bonuses are replayed identically during validation
- final QA around timer fairness and post-question breakdown behavior in sealed Mind Wars

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/vocabulary_showdown_game.dart](../../../lib/games/widgets/vocabulary_showdown_game.dart)
- [lib/services/vocabulary_game_service.dart](../../../lib/services/vocabulary_game_service.dart)
- [lib/models/vocabulary_models.dart](../../../lib/models/vocabulary_models.dart)
- [lib/utils/vocabulary_scoring_utility.dart](../../../lib/utils/vocabulary_scoring_utility.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)
- [docs/VOCABULARY_SHOWDOWN_README.md](../../VOCABULARY_SHOWDOWN_README.md)
- [docs/VOCABULARY_SHOWDOWN_SUMMARY.md](../../VOCABULARY_SHOWDOWN_SUMMARY.md)
- [docs/VOCABULARY_SHOWDOWN_MIGRATION.md](../../VOCABULARY_SHOWDOWN_MIGRATION.md)