# Color Rush

## Quick Reference

| Attribute | Value |
|---|---|
| Category | Attention |
| Players | 2-10 |
| Core Mechanic | Rapid target-color identification under time pressure |
| Async Compatible | Yes |
| Primary Cognitive Skill | Processing speed and selective attention |
| Current Source Basis | Game catalog, branding spec, widget implementation, puzzle generator |

## Overview

Color Rush is a fast-response attention game where players identify a target color from a field of distractors as quickly and accurately as possible. It rewards fast recognition, clean reactions, and sustained streak performance.

Within Mind Wars, Color Rush should follow the same platform-level rules as the other async competitive games:

- mobile-first interaction with immediate visual clarity and large tap zones
- offline-first play through locally generated or cached prompt sets
- async fairness through identical prompt sequences and timing rules for all players in a match
- server-authoritative validation of responses, timing, and final score

## Current Implementation Snapshot

The current playable widget is a color-target search game, not a Stroop-style word-color conflict game.

Current observed widget behavior:

- Round prompt: a large target color swatch is shown to the player
- Play field: a 4x4 grid with 16 color tiles
- Target distribution: exactly 2 tiles match the target color each round
- Color pool: 8 base colors
- Timer: starts at 3 seconds and drops to 2 seconds after later progression
- Correct result: combo increases and score gain equals `5 + (combo x 2)`
- Wrong result: combo resets and the next round begins immediately
- Timeout result: combo resets and the next round begins immediately
- Completion: the player clears the experience after level > 3
- Difficulty progression: time pressure scales inversely (3s → 2s → 1s)

This makes the alpha widget a strong quick-reaction game with proper difficulty scaling, but it does not currently match the Stroop-style production direction described in the branding documentation.

## Concept And Core Loop

### Concept

Players are shown a target color and must rapidly identify matching instances within a crowded grid before the short timer expires.

### Core Gameplay Loop

1. Read the target prompt.
2. Scan the available color choices quickly.
3. Tap a matching color before the timer expires.
4. Build combo and score through consecutive correct answers.
5. Continue through the round sequence until the run ends.

## Core Rules

### Setup

1. Generate a target color prompt.
2. Populate the response field with a mix of matching and non-matching colors.
3. Start the response timer.
4. Apply mode-specific scoring, combo, and timeout rules.

### Gameplay

1. The player sees the target color.
2. The player taps a candidate tile from the color grid.
3. A correct match awards points and extends the run.
4. A wrong choice or timeout breaks the combo.
5. The next prompt begins immediately after the current round resolves.

### Ending

Color Rush should end when one of the following conditions is met:

- a fixed number of prompts is completed
- the session timer expires
- the format uses a mistake cap
- the progression ladder reaches its completion threshold

### Special Rules

- In the current widget, the player is rewarded for any correct tap even though two valid target tiles exist in the grid.
- The current alpha implementation does not use text labels or word-ink conflicts.
- Competitive async play should standardize prompt count, response windows, combo logic, and scoring rules across all players.

## Difficulty Structure

### Current Widget Behavior

- The widget currently uses a fixed 4x4 response grid.
- It uses 8 possible colors.
- Each round guarantees exactly 2 correct targets.
- The response timer starts at 3 seconds and later drops to 2 seconds.
- Difficulty comes from speed pressure and sustained repetition rather than from changing prompt semantics.

That makes the current implementation a reaction-and-visual-discrimination game rather than a Stroop interference game.

### Current Generator Behavior

The content generator currently defines Color Rush difficulty like this:

- Easy: sequence length 5
- Medium: sequence length 8
- Hard: sequence length 12

It also attaches:

- max score 100, 200, or 300 depending on difficulty
- a time limit based on 60 seconds

The generated puzzle package stores a color sequence as both puzzle data and solution data.

### Important Design Gap

There is a meaningful mismatch across the current sources:

- The widget is a target-color search game using colored tiles.
- The branding spec describes a Stroop-style word display with text-label response buttons.
- The generator stores a color sequence but does not define the current widget's 4x4 target-grid layout.

That gap should be resolved before ranked multiplayer rollout.

### Target Difficulty Direction

- Easy: longer response windows, fewer prompts, stronger contrast between target and distractors.
- Medium: more prompts, faster transitions, and tighter response windows.
- Hard: shorter timers, more perceptual interference, and stricter punishment for broken streaks.

If the production direction stays aligned with the branding docs, difficulty may eventually come from Stroop incongruence rather than only from raw speed.

## Winning And Scoring

### Current Widget Scoring

- Correct answer score: `5 + (combo x 2)` after combo increments
- Wrong answer: combo resets, no explicit point penalty
- Timeout: combo resets, no explicit point penalty
- Completion: after level 20

In the current widget, that means:

- first consecutive correct answer awards 7 points
- second consecutive correct answer awards 9 points
- third consecutive correct answer awards 11 points
- streak value continues rising until the player answers incorrectly or times out

### Target Competitive Scoring Direction

For Mind Wars multiplayer, the production scoring model should balance:

- total correct responses
- response speed
- sustained combo or streak quality
- wrong answers and timeouts
- hint usage if hints exist

### Recommended Competitive Formula

One workable production formula would be:

```text
BaseScore = 5 x correctResponses
ComboBonus = totalComboBonusEarned
SpeedBonus = max(0, roundTimeBudget - totalResponseTime)
WrongPenalty = 3 x incorrectResponses
TimeoutPenalty = 3 x timeouts
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + ComboBonus + SpeedBonus - WrongPenalty - TimeoutPenalty - HintPenalty
```

This keeps the current combo-based character of the widget while making accuracy and timeouts matter more explicitly in competitive play.

### Recommended Ranked Formula For Color Rush Mind Wars

To align Color Rush with the platform ranking template, the recommended ranked formula for sealed Mind War competition is:

```text
BaseScore = 5 x correctResponses
ComboBonus = sum of 2 x comboLevel for each correct response
SpeedBonus = max(0, totalTimeBudgetSeconds - totalResponseTimeSeconds)
WrongPenalty = 3 x incorrectResponses
TimeoutPenalty = 3 x timedOutPrompts
HintPenalty = 5 x hintsUsed

FinalScore = BaseScore + ComboBonus + SpeedBonus - WrongPenalty - TimeoutPenalty - HintPenalty
```

Where:

- `correctResponses` = total prompts answered correctly
- `comboLevel` = streak count after a correct answer resolves
- `totalTimeBudgetSeconds` = total deterministic time budget assigned to the Mind War
- `totalResponseTimeSeconds` = sum of validated response times across all prompts
- `incorrectResponses` = wrong taps on active prompts
- `timedOutPrompts` = prompts that expired without a correct answer
- `hintsUsed` = all assists consumed during the run

If a Mind War disables hints, then `HintPenalty = 0` and all valid runs belong to the Pure category.

### Victory Condition

- In practice mode: survive and score through the full progression ladder.
- In async multiplayer: compete for the best validated local Mind War result on the exact same prompt sequence and timing rules, with eligible ranked runs routing into the matching persistent leaderboard buckets defined in [Mind Wars Ranking Specification](../MIND_WARS_RANKING_SPEC.md).
- Secondary tiebreakers can use higher accuracy, then faster total response time.

## Mind War Ranking Methodology

### Purpose

For Color Rush, the Mind War ranking layer answers:

> Who performed best on this exact prompt package under these exact timing and scoring rules?

Mind War placement is local to that sealed competitive instance and is never replaced by any public leaderboard outcome.

### Mind War Configuration Fields

Every ranked or unranked Color Rush Mind War should define the following immutable fields at creation time:

| Field | Color Rush Requirement |
|---|---|
| Game ID | `color_rush` |
| Difficulty Tier | Easy, Medium, or Hard |
| Challenge Seed | Deterministic server-generated seed or stored prompt payload |
| Hint Policy | Disabled or Enabled |
| Scoring Model | Explicit formula declared before play starts |
| Time Handling | Included as a scoring modifier through response-time accounting |
| Attempt Limits | Fixed prompt count or fixed run window |
| Ranked Flag | Yes or No |

For Color Rush specifically, the deterministic package should also lock:

- prompt order
- target-color sequence
- response window per prompt
- color pool
- grid layout generation rules or direct grid payloads
- combo logic
- timeout behavior

### Exact Same Game Delivery Method

To ensure every player receives the exact same Color Rush game inside a Mind War:

- the server should issue one immutable battle payload containing the prompt order, target-color sequence, response windows, grid-state generation rules or direct prompt grids, combo rules, and timeout behavior
- each client should cache that payload locally and resolve prompts from that exact package without local prompt reshuffling or timer drift in the gameplay model
- final ranking should be validated by replaying the response log against that same prompt package on the server

### Mind War Final Score Rule

Players in a Color Rush Mind War should be ranked purely by `FinalScore`, using the declared scoring model for that war.

Recommended ranked formula:

```text
FinalScore = BaseScore + ComboBonus + SpeedBonus - WrongPenalty - TimeoutPenalty - HintPenalty
```

This keeps all local placements enclosed inside the Mind War itself.

### Tie Resolution

If two Color Rush runs share the same `FinalScore`, the recommended tiebreak order is:

1. Fewer failed prompt resolutions, defined as `incorrectResponses + timedOutPrompts`
2. Faster total validated response time
3. Shared placement

This preserves the spirit of the platform template while using a Color Rush-specific equivalent for fewer attempts.

### Mind War Output

Each Color Rush Mind War should produce:

- ordered placements
- final scores
- total correct responses
- incorrect responses
- timed out prompts
- total response time
- hints used
- peak combo and total combo bonus
- difficulty and ranked eligibility metadata

## Public Ranking Methodology

### Purpose

If a Color Rush Mind War is created as Ranked, validated runs may also be routed to public leaderboards. Those public rankings answer:

> How strong is this player in Color Rush under a specific ruleset?

Public rankings never change the outcome of the original Mind War.

### Ranked Vs Unranked

- Unranked Color Rush Mind Wars affect only the local Mind War results.
- Ranked Color Rush Mind Wars affect local results and may also contribute to public leaderboards after server validation.

### Global Ranking Axes

If public rankings are enabled, Color Rush should follow the platform matrix exactly:

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

Color Rush public rankings should therefore exist as:

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

A Color Rush run should contribute to a public leaderboard only if:

1. the Mind War is marked as Ranked
2. the run is fully completed
3. server validation passes
4. the run's difficulty matches the leaderboard cell
5. the run's assistance usage matches the leaderboard cell

### Public Ranking Metric

The recommended public metric for Color Rush is:

- Best Valid Score

That metric should be labeled explicitly on public leaderboard surfaces.

### Player-Facing Transparency

Every Color Rush result screen should display:

- Mind War placement
- final score
- difficulty tier
- assistance category
- ranked or unranked status
- public eligibility outcome, if applicable

No run should be silently excluded from public ranking without an explicit reason.

## Async And Multiplayer Notes

### Async Format

Color Rush is a strong async game because players can complete the same sequence of prompts independently while the system compares validated results afterward.

### Fairness Requirements

- Every player in the same match should receive the exact same puzzle difficulty and setup that was designated during the voting round.
- The prompt order, color pool, response windows, combo rules, and scoring rules must be identical for all players.
- Competitive matches should use a deterministic server-generated prompt set rather than local random target generation.
- The current catalog already aligns with the broader 2-10 player platform target.

### Server Validation

The authoritative backend should validate:

- puzzle ID or seed
- prompt sequence
- player response sequence
- per-prompt timing
- correct and incorrect counts
- combo progression
- final score

### Offline-First Behavior

- Practice prompt sets can be generated locally.
- Battle prompt sequences can be cached locally once distributed.
- Response history can be stored offline and synchronized later.
- Ranked results should still be revalidated server-side before local placement is finalized and before any persistent leaderboard route is published.

## Hints And Assistance

There is currently no dedicated Color Rush hint branch in the generic offline screen beyond the default fallback hint text.

That means the present alpha experience does not yet have game-specific assistance such as:

- clarifying the active response rule
- previewing the valid target style
- temporarily reducing distractor complexity

If ranked hints are added later, they should carry a score penalty and should not distort timing fairness across players.

## UI And Interaction Notes

- The current target-swatch-plus-grid layout is immediately legible on phones.
- The production Stroop version described in the branding spec would create a different feel and a different cognitive demand profile.
- If the game shifts to a word-and-ink design, typography, contrast, and response-zone clarity become much more important than they are in the current tile-grid version.
- The current widget benefits from simple large tap areas and strong color separation, which should be preserved in any redesign.

## Current Implementation Notes

- Catalog definition: [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- Playable widget: [lib/games/widgets/color_rush_game.dart](../../../lib/games/widgets/color_rush_game.dart)
- Offline practice host: [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- Puzzle generation: [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- Hint text: [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- Branding direction: [docs/branding.md](../../branding.md)

Current state summary:

- The app has a playable rapid color-selection practice game.
- The current widget is not the same design as the branded Stroop-style production concept.
- The generator already supports difficulty-based prompt sequence lengths but does not map directly to the widget's current grid-round model.
- Ranked multiplayer will need deterministic prompt sequencing, explicit server timing validation, and a declared leaderboard-routing policy before rollout.

## Ranked Readiness

Status: Partial.

Before ranked rollout, Color Rush still needs:

- a final ranked design choice between the current tile-search format and the branded Stroop-style concept
- deterministic prompt-sequence payloads with locked timing windows for every player in a Mind War
- server-side validation of per-prompt timing, response history, combo state, and final score
- a defined ranked assistance policy because the current generic hint behavior is only placeholder level

## Recommended Next Design Decisions

To finalize Color Rush as a full Mind Wars game, the next decisions should be documented explicitly:

1. Whether production keeps the current tile-search gameplay or shifts fully to the Stroop-style branded concept.
2. Whether the ranked game uses fixed-length prompt runs, survival progression, or a timed-score window.
3. Whether combo remains a core scoring mechanic or becomes secondary to accuracy and speed.
4. Whether players must select one correct tile or all correct tiles when multiple matches exist on screen.
5. Whether the generator and server should produce per-prompt response windows as part of the battle payload.

## Related References

- [lib/games/game_catalog.dart](../../../lib/games/game_catalog.dart)
- [lib/games/widgets/color_rush_game.dart](../../../lib/games/widgets/color_rush_game.dart)
- [lib/services/game_content_generator.dart](../../../lib/services/game_content_generator.dart)
- [lib/services/hint_and_challenge_system.dart](../../../lib/services/hint_and_challenge_system.dart)
- [lib/screens/offline_game_play_screen.dart](../../../lib/screens/offline_game_play_screen.dart)
- [docs/branding.md](../../branding.md)