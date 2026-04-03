# Mind Wars Ranking Specification

**Version:** v1.0 (Draft)  
**Last Updated:** 2026-03-14  
**Applies To:** Code Breaker and all compatible ranked Mind Wars catalogue games  
**Scope:** Per-Mind-War rankings, ranked-run eligibility, and Global / Regional / National leaderboard routing

---

## 1. Terminology

**Mind War**  
A sealed competitive instance of a game in which all participants solve the same deterministic content package under identical rules.

**Run**  
A single player's completed attempt within a Mind War.

**Ranked Run**  
A completed run that is eligible to contribute to one or more persistent leaderboards.

**Pure Run**  
A run completed without any hints or assisted reveal actions.

**Assisted Run**  
A run completed with one or more hints or other allowed assistance actions.

---

## 2. Core Principles

1. Local competition and global prestige are separate systems.
2. Rules are explicit and immutable per Mind War.
3. Players are never compared across incompatible rule sets.
4. Hint usage is a valid playstyle, not a loophole.
5. All rankings must be server-verifiable.

---

## 3. Mind War Ranking

### 3.1 Purpose

Mind War ranking determines relative performance inside one sealed battle.

This answers:

> Who performed best under the rules of this specific Mind War?

### 3.2 Required Mind War Configuration

Each ranked or unranked Mind War must define the full competitive ruleset up front.

| Parameter | Description |
|---|---|
| Game Type | Example: Code Breaker, Sudoku Duel, Word Builder |
| Difficulty | Easy / Medium / Hard or game-specific equivalent |
| Puzzle Seed Or Payload | Server-generated deterministic content package |
| Hint Policy | Disabled / Enabled / Assisted mode definition |
| Scoring Formula | Fully defined scoring inputs, bonuses, and penalties |
| Attempt Or Guess Cap | Optional if applicable to the game |
| Time Handling | Included in score, tiebreak only, or ignored |
| Ranked Flag | Whether eligible runs can route into persistent leaderboards |

This configuration is locked when the Mind War is created.

For exact same-game delivery requirements, see [MIND_WAR_BATTLE_PAYLOAD_SPEC.md](MIND_WAR_BATTLE_PAYLOAD_SPEC.md).

### 3.3 Ranking Rule

Players are ranked inside the Mind War by Final Score only.

If Final Score ties, the default tiebreak order is:

1. Fewer attempts, guesses, mistakes, or other efficiency metric defined by the game.
2. Faster validated completion time.
3. Shared placement if the product chooses not to break the tie further.

Every game document must define its own Final Score formula, but that formula only applies inside compatible runs for that exact ruleset.

### 3.4 Mind War Output

Each Mind War produces:

- Ordered placement.
- Final Score per player.
- Run metadata including difficulty, hint usage, time, and game-specific efficiency metrics.
- Ranked eligibility status.

Mind War placement never directly compares players from different Mind Wars.

---

## 4. Persistent Ranking System

### 4.1 Purpose

Persistent rankings measure cross-Mind-War performance only across compatible runs.

This answers:

> How strong is this player overall under a specific ruleset?

Persistent rankings may be exposed as leaderboard views, seasonal standings, or profile prestige summaries.

---

## 5. Ranking Axes

Persistent leaderboards are defined by orthogonal axes.

### 5.1 Axis A: Difficulty

Separate leaderboard buckets must exist for each supported difficulty level.

- Easy
- Medium
- Hard

No cross-difficulty comparison is allowed.

### 5.2 Axis B: Hint Usage

Separate leaderboard buckets must exist for the run's assistance class.

**Pure**

- No hints or assist actions used.
- Highest prestige category.
- Represents unassisted mastery.

**Assisted**

- One or more hints or assist actions used.
- Score penalties apply as defined by the game's scoring formula.
- Represents adaptive, assisted problem-solving.

### 5.3 Axis C: Scope

Each leaderboard can be filtered by geography without changing scoring.

- Global
- Regional
- National

Scope only filters the player pool. It does not alter the underlying score model.

---

## 6. Leaderboard Matrix

Each valid combination of difficulty and hint usage produces a distinct leaderboard bucket.

| Difficulty | Pure | Assisted |
|---|---|---|
| Easy | Yes | Yes |
| Medium | Yes | Yes |
| Hard | Yes | Yes |

Each bucket can be viewed at:

- Global scope
- Regional scope
- National scope

Games that do not support hints may expose Pure only. Games that do not expose regional identity may still keep the same internal model and hide those filters until supported.

---

## 7. Eligibility Rules

A run contributes to a persistent leaderboard only if:

1. The Mind War is marked as ranked.
2. The run completed successfully according to the game's rules.
3. The difficulty matches the leaderboard bucket.
4. Hint usage matches the leaderboard bucket.
5. Server validation passes.

Routing example:

```json
{
  "game_type": "code_breaker",
  "difficulty": "hard",
  "ranked": true,
  "hints_used": false
}
```

This run is eligible for the Hard / Pure leaderboard views at Global, Regional, and National scope.

---

## 8. Ranking Metric Per Leaderboard

Each persistent leaderboard must define one primary ranking metric.

Recommended default:

- Best Valid Score

Supported future alternatives:

- Average of top N valid runs
- Seasonal best
- Consistency-weighted score

If different leaderboard metrics exist, the UI must label them explicitly.

---

## 9. Relationship Between Mind Wars And Persistent Rankings

| Scenario | Mind War Rank | Persistent Rank |
|---|---|---|
| Casual War | Yes | No |
| Ranked War, Assisted | Yes | Yes, Assisted bucket only |
| Ranked War, Pure | Yes | Yes, Pure bucket only |
| Practice Mode | No | No |

A single run always affects its own Mind War result. It may affect zero or more persistent leaderboard views if it is eligible and validated.

---

## 10. Player-Facing Clarity Requirements

Post-game UI must show at minimum:

- Mind War placement.
- Final Score.
- Difficulty.
- Hint usage status.
- Persistent ranking eligibility.
- The exact leaderboard bucket route if eligible.

Example:

> Mind War Result: 1st Place  
> Score: 214  
> Persistent Impact: Added to Hard / Assisted leaderboard  
> Pure Leaderboard: Not eligible because a hint was used

No hidden routing rules are allowed.

---

## 11. Server Authority And Validation

The server must:

- Recompute score-critical game outcomes.
- Verify hint usage and any assist actions.
- Validate timestamps and completion state.
- Reject tampered or incomplete transcripts.
- Assign the final leaderboard route.

Clients are never authoritative for ranked outcome publication.

---

## 12. Catalogue Adoption Rules

This specification applies across the Mind Wars catalogue.

Every game design document should:

1. Define the local Mind War scoring formula.
2. State the game-specific tie-efficiency metric.
3. Clarify whether hints are allowed in ranked play.
4. Reference this specification for persistent leaderboard routing.

Games may use different scoring formulas, but they must not share the same leaderboard bucket unless their rulesets are intentionally compatible and explicitly documented as such.

---

## 13. Extensibility

This system supports:

- New difficulties.
- New hint types.
- Seasonal ladders.
- Limited-time rule variants.
- Additional ranking axes.

These additions should create new compatible buckets rather than silently altering existing ones.

---

## 14. Summary

This specification is intended to preserve:

- Fair async competition.
- Clear player agency.
- Multiple valid mastery paths.
- Scalable worldwide rankings.
- Zero ambiguity between winning a Mind War and earning persistent prestige.