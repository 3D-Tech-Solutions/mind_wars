# Anagram Attack

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Language |
| Players | 2-10 |
| Core Mechanic | Unscramble a shared letter set into valid word answers |
| Async Compatible | Yes |
| Primary Cognitive Skill | Lexical flexibility and pattern recognition |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator, hint system, alpha summary, release requirements |

## Overview

Anagram Attack is a rapid language challenge where players rearrange scrambled letters into valid words as quickly and accurately as possible. Strong play depends on lexical pattern recognition, spelling fluency, and fast recovery after failed attempts.

Within Mind Wars, Anagram Attack should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with clear letter presentation and fast answer submission
- offline-first play through local or cached word payloads
- async fairness through identical scrambled content and rule sets for all players in a match
- server-authoritative validation of submissions, duplicates, timing, and final score

## Current Implementation Snapshot

The current playable widget is a simple predefined-word anagram challenge rather than a fuller battle-ready shared-letter-set system.

Current observed widget behavior:

- Word pool: 18 predefined words
- Selection model: one random target word removed from the remaining list each round
- Prompt format: a single scrambled version of the target word
- Input model: free-text answer entry in a text field
- Correct result: +15 points and advance to the next word
- Wrong result: no score change and retry prompt remains active
- Progression: continues until the predefined word pool is exhausted
- Validation model: exact whole-word match against the hidden target word

This makes the alpha version a playable language puzzle, but it is materially simpler than the production-ranked model described in the public release requirements under the name `Anagram Sprint`.

## Concept And Core Loop

### Concept

Players inspect a scrambled letter sequence, infer the original valid word or accepted word set, and submit correct answers faster and more accurately than opponents.

### Core Gameplay Loop

1. Read the scrambled letter prompt.
2. Mentally test candidate word arrangements.
3. Submit a candidate answer.
4. Receive validation.
5. Continue through the word set or round timer.

## Core Rules

### Setup

1. Select or generate a valid source word or shared letter set.
2. Scramble the letters into a non-solved presentation.
3. Present the scramble and any mode-specific timers or limits.
4. Apply scoring, duplicate, and hint rules.

### Gameplay

1. The player reviews the scrambled letters.
2. The player enters a candidate answer.
3. The system validates the answer against the allowed solution rules.
4. Correct answers score and progress the run.
5. Incorrect or duplicate answers should be rejected consistently under the active ruleset.

### Ending

Anagram Attack should end when one of the following conditions is met:

- a fixed prompt set is completed
- the timer expires
- the format uses a submission cap
- the session reaches its designed completion threshold

### Special Rules

- In the current widget, each prompt has one exact target word.
- The current alpha implementation does not yet expose a shared multi-word letter bank or unique-word bonus system.
- Competitive async play should standardize scramble source, accepted answer rules, duplicate handling, and scoring rules across all players.

## Difficulty Structure

### Current Widget Behavior

- The widget uses a fixed predefined word list rather than a dynamic generator.
- Difficulty is implied mostly by word length and familiarity, not by a formal difficulty ladder.
- The player enters free-text answers instead of manipulating visible letter tiles.
- The run ends when the current local word pool is exhausted.

That makes the current implementation a workable alpha language puzzle, but not yet a production difficulty system.

### Current Generator Behavior

The content generator currently defines Anagram Attack difficulty like this:

- Easy: `HELLO`, `WORLD`, `HAPPY`
- Medium: `PUZZLE`, `MASTER`, `CHALLENGE`
- Hard: `COGNITIVE`, `STRATEGIC`, `COMPETITIVE`

It also attaches:

- max score 100, 200, or 300 depending on difficulty
- a time limit based on 60 seconds

Unlike several other generators in the repo, the Anagram Attack generator does already produce both a scrambled prompt and a canonical solution word.

### Existing Release Requirement Direction

The v1.0 release requirements define the public competitive version under the name `Anagram Sprint` with these rules:

- all players receive the same scrambled letter set from the same server seed
- word submission is validated server-side against a dictionary source
- duplicate submissions are rejected inline
- unique word bonus is applied server-side only after all submissions or deadline expiry
- a 5-minute timer is enforced server-side
- score is written as valid-letter total plus unique-word bonuses

### Important Design Gap

There is a meaningful mismatch across the current sources:

- The widget is a single-target exact-answer anagram game.
- The generator also models single-solution prompts.
- The release requirements describe a broader shared-letter-set competitive system with duplicate rejection and post-deadline unique-word bonuses.

That gap should be resolved before ranked multiplayer rollout.

### Target Difficulty Direction

- Easy: shorter words, familiar vocabulary, and lower ambiguity.
- Medium: longer words, less common vocabulary, and more deceptive rearrangements.
- Hard: denser letter ambiguity, rarer words, and stricter time pressure.

If the production direction stays aligned with the release spec, difficulty may also come from how many valid words can be extracted from the same seeded letter set.

## Winning And Scoring

### Current Widget Scoring

- Each correct answer awards +15.
- Wrong answers do not currently deduct points.
- The current widget does not apply streak bonuses, unique-word bonuses, or server-timed scoring adjustments.

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- total valid letters submitted
- total valid words found
- unique-word bonuses if enabled
- completion speed or deadline efficiency
- hint usage if hints exist

### Recommended Competitive Formula

One workable production formula, aligned to the release direction, would be:

```text
BaseScore = totalValidLettersSubmitted
UniqueWordBonus = 5 x uniqueWordsAccepted
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + UniqueWordBonus - HintPenalty
```

This preserves the release requirement emphasis on valid-letter scoring and unique-word bonuses while leaving server timing to eligibility and deadline enforcement rather than making it the only scoring axis.

### Recommended Ranked Formula For Anagram Attack Mind Wars

To align Anagram Attack with the shared [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md), the recommended ranked formula for sealed Mind War competition is:

```text
BaseScore = totalValidLettersSubmitted
UniqueWordBonus = 5 x uniqueWordsAccepted
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + UniqueWordBonus - HintPenalty
```

Where:

- `totalValidLettersSubmitted` = sum of letters from all validated accepted submissions
- `uniqueWordsAccepted` = accepted words that no other player in the same Mind War submitted before deadline resolution, if that ruleset is enabled
- `hintsUsed` = all assists consumed during the run

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: solve the current prompt set as accurately as possible.
- In async multiplayer: compete for the best validated local Mind War result on the exact same scrambled letter package, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use more accepted words, then faster completion or earlier validated submission time where applicable.

## Mind War Ranking Methodology

### Purpose

For Anagram Attack, the Mind War ranking layer answers:

> Who performed best on this exact scrambled letter package under these exact validation and scoring rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Anagram Attack Mind War should define the following immutable fields at creation time:

| Field | Anagram Attack Requirement |
|---|---|
| Game ID | `anagram_attack` |
| Difficulty Tier | Easy, Medium, or Hard |
| Challenge Seed | Deterministic server-generated seed or stored scramble payload |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included as a fixed deadline or timer policy |
| Attempt Limits | Fixed prompt count, submission cap, or fixed session window |
| Ranked Flag | Yes or No |

For Anagram Attack specifically, the deterministic package should also lock:

- source word set or shared letter set
- scramble presentation
- accepted dictionary source
- duplicate-word handling rules
- unique-word bonus rules
- timer rules
- scoring weights

### Exact Same Game Delivery Method

To ensure every player receives the exact same Anagram Attack game inside a Mind War:

- the server should issue one immutable battle payload containing the exact scrambled letter package or prompt set, accepted-answer rules, dictionary version, duplicate policy, timer rules, and hint policy
- each client should cache that payload locally and validate only through the locked ruleset rather than generating alternate prompt content on-device
- final ranking should be validated by replaying accepted submissions and duplicate resolution against that same payload on the server

### Mind War Final Score Rule

Players in an Anagram Attack Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = BaseScore + UniqueWordBonus - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Anagram Attack runs share the same `FinalScore`, the recommended tiebreak order is:

1. More accepted words
2. Faster total validated completion time or earlier final accepted submission
3. Shared placement

This matches the platform template while using the game's natural equivalent for fewer attempts.

### Mind War Output

Each Anagram Attack Mind War should produce:

- ordered placements
- final scores
- accepted words list
- total valid letters submitted
- unique-word bonus total if enabled
- total completion time or deadline-resolved submission timing
- hints used
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If an Anagram Attack Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Anagram Attack under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Anagram Attack Mind Wars affect only the local Mind War results.
- Ranked Anagram Attack Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Anagram Attack should follow the platform matrix exactly:

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

Anagram Attack public rankings should therefore exist as:

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

An Anagram Attack run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Anagram Attack is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Anagram Attack result screen should display:

- Mind War placement
- final score
- difficulty tier
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Anagram Attack works well asynchronously because every player can receive the same scramble package and solve it independently while the server compares validated outcomes afterward.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The scramble source, accepted dictionary, duplicate rules, timer rules, and scoring rules must be identical for all players.
- Competitive matches should use an explicit server-generated scramble payload rather than local random word selection.
- The broader platform should support matches up to 10 players even though the current widget and older docs still reflect smaller ranges.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- source word set or shared letter set
- submitted words
- dictionary validity
- duplicate handling
- unique-word bonus eligibility
- hint usage if applicable
- final score and ranking route

### Offline-First Behavior

- Practice prompts can be generated locally.
- Battle scramble payloads can be cached locally once distributed.
- Submission history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

The shared hint system already supports Anagram Attack and currently exposes hints such as:

- the word length
- the first letter
- the last letter
- a suggestion to say the letters out loud

Those hints are useful for alpha practice, but they are strong enough that ranked play should either penalize them consistently or disable them entirely in Pure competitions.

## UI And Interaction Notes

- The current text-input implementation is functional but simpler than the tile-based branded concept.
- The branding spec defines tile states, shuffle icon behavior, urgency timer states, and valid or invalid submission feedback.
- If the production game shifts to draggable or tappable letter tiles, mobile ergonomics and rapid correction behavior will matter much more.
- The release direction may also support shared-letter-set play with multiple accepted answers rather than one exact hidden word.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/anagram_attack_game.dart](../../../lib/games/widgets/anagram_attack_game.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Shared ranking rules: [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- Branding direction: [docs/branding.md](../../branding.md)
- Alpha summary: [docs/ALPHA_IMPLEMENTATION_SUMMARY.md](../../ALPHA_IMPLEMENTATION_SUMMARY.md)
- Release requirements: [docs/project/V1_0_RELEASE_REQUIREMENTS.md](../../project/V1_0_RELEASE_REQUIREMENTS.md)

Current state summary:

- The app has a playable predefined-word Anagram Attack implementation.
- The current widget and generator are both oriented around single-solution prompts.
- The release requirements define a broader server-seeded `Anagram Sprint` model with duplicate rejection and unique-word bonuses.
- Ranked multiplayer will need deterministic scramble payloads, server validation, and explicit leaderboard-routing metadata before rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Anagram Attack still needs:

- a final ranked product decision between the current single-answer model and the broader `Anagram Sprint` release direction
- one shared validation pipeline for scramble generation, accepted answers, duplicate rejection, and scoring
- server-side ranked payloads with locked assistance policy and public routing metadata
- confirmation of whether free-text entry remains acceptable for ranked play or is replaced by tile interaction

## Recommended Next Design Decisions

To finalize Anagram Attack as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production keeps the single-answer anagram model or shifts fully to the broader shared-letter-set `Anagram Sprint` design.
2. Whether ranked play scores only accepted-letter totals or also rewards completion speed directly.
3. Whether duplicate rejection is local to the player, global to the Mind War, or both.
4. Whether the branded tile-based interaction replaces free-text entry in the first ranked release.
5. Whether the generator and backend should share a single dictionary-validation and scramble-generation pipeline to guarantee identical multiplayer content.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/anagram_attack_game.dart](../../../lib/games/widgets/anagram_attack_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [docs/games/MIND_WARS_RANKING_SPEC.md](../MIND_WARS_RANKING_SPEC.md)
- [docs/branding.md](../../branding.md)
- [docs/ALPHA_IMPLEMENTATION_SUMMARY.md](../../ALPHA_IMPLEMENTATION_SUMMARY.md)
- [docs/project/V1_0_RELEASE_REQUIREMENTS.md](../../project/V1_0_RELEASE_REQUIREMENTS.md)