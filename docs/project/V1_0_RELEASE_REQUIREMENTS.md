<!-- [2026-03-13 Documentation] Added the March 2026 public v1.0 release requirements as an explicit source-of-truth document. -->
# Mind Wars v1.0 Release Requirements

**Version:** 1.0  
**Date:** March 2026  
**Status:** Public Release Requirements Baseline  
**Visibility:** Repository-tracked release-planning document

---

## Purpose

This document defines the public v1.0 acceptance baseline for Mind Wars. It covers:

1. Game catalog validation
2. Per-game scoring specifications
3. Competitive fairness enforcement
4. Scoreboard integration
5. Asynchronous multiplayer mechanics
6. Persistent cross-device chat

> **[2026-03-13 Documentation] Current repository context:** the repository still contains a broader 15-game frontend/gameplay foundation and partially stubbed backend validation paths. Until the launch requirements in this document are implemented and validated, the repository should be treated as **pre-public-v1.0**.

---

## 1. v1.0 Game Catalog

### 1.1 Games included in public v1.0

The following nine games define the public v1.0 release catalog.

| Game | Category | Scoring Formula | Fairness Method |
|------|----------|-----------------|-----------------|
| Word Ladder | Language | 90 pts − seconds; +20 no hints; −5/hint | Identical start/end words, server-generated seed |
| Anagram Sprint | Language | 1 pt/letter; +5 for unique words | Same scrambled letter set, server-seeded |
| Vocabulary Showdown | Language | Speed bonus; −2/incorrect match | Identical word bank, simultaneous play |
| Mastermind | Logic | 90 − (10 × guesses); +15 if ≤6 guesses | Server-generated code, same difficulty |
| Pattern Recognition | Logic | Points/correct answer + time bonus | Identical sequences from server seed |
| 24 Puzzle | Math | 90 pts − seconds; −5/hint; +20 no hints | Same 4-number set, server-generated |
| Sudoku Duel | Puzzle | 90 pts − seconds; −5/hint; +15 no errors | Server-generated grid, same seed per Battle |
| Picross Race | Puzzle | Completion speed; −5/incorrect square | Identical pixel grid from server seed |
| Memory Match | Memory | Pairs found × streak multipliers | Same card layout, server-seeded shuffle |

### 1.2 Catalog design principle

- Every game must fit a **2–10 minute** mobile session.
- No v1.0 game may require synchronous opponent presence.
- All puzzles must be generated **server-side before play begins** so every participant receives bitwise-identical content.

### 1.3 Per-game validation requirements

#### 1.3.1 Word Ladder
- Game renders correctly on phones (5") and tablets (12")
- Server generates start/end word pair with verified solution path before player notification
- Timer starts only on first letter input
- Hint deducts 5 pts atomically from server-calculated score
- Submission rejected if word is not in the embedded dictionary
- Score posts to the Battle scoreboard within 3 seconds
- Players may see peer completion indicators, but not peer scores before game completion

#### 1.3.2 Anagram Sprint
- All players receive the same scrambled letter set from the same server seed
- Word submission validated server-side against a dictionary source
- Duplicate word submissions rejected inline
- Unique word bonus applied server-side only after all submissions or deadline expiry
- 5-minute timer enforced server-side
- Score written as valid-letter total plus unique-word bonuses

#### 1.3.3 Vocabulary Showdown
- Word bank generated server-side and pushed identically to all players
- Speed bonus uses server-received timestamp
- Incorrect match deducts 2 pts server-side, floored at 0
- All synonym pairs validated before game start
- Game ends when all matches are completed or time expires

#### 1.3.4 Mastermind
- 4-digit color code generated server-side with locked seed
- Solution encrypted at rest
- Guess feedback computed server-side only
- Score equals `90 − (10 × guesses)` with +15 bonus if solved in 6 or fewer guesses
- Maximum 10 guesses; unsolved games score 0

#### 1.3.5 Pattern Recognition
- Sequence type randomised per Battle but identical for all players
- Points and time bonus applied server-side
- Wrong answer deducts 2 pts, floored at 0
- Every sequence must be pre-validated to have exactly one correct answer

#### 1.3.6 24 Puzzle
- Server generates a 4-number set with at least one valid 24 solution
- Player submits an expression string; server evaluates the result
- Score equals `90 − seconds − (5 × hints) + 20 if no hints`
- Impossible sets are rejected before distribution
- Server tracks net active time, including app background/resume behavior

#### 1.3.7 Sudoku Duel
- Grid generated server-side with a verified unique solution
- Difficulty mapped to empty-cell counts: Easy 40, Medium 50, Hard 60
- Score equals `90 − seconds − (5 × hints) + 15 if no errors`
- Error count tracked server-side
- Partial progress auto-saved every 30 seconds

#### 1.3.8 Picross Race
- Pixel grid generated server-side at 10×10 to 15×15
- Score equals completion-speed bonus minus 5 per incorrect square
- Incorrect squares computed server-side
- Cell touch targets remain at least 44×44pt

#### 1.3.9 Memory Match
- Card layout shuffled server-side with the same layout per Battle
- Board reshuffle every 3 turns from the same deterministic seed
- Score uses pairs found multiplied by streak multiplier
- Opponents must not be able to infer unrevealed card state before a card is intentionally revealed

---

## 2. Scoring System

### 2.1 Universal scoring principles

- **All score calculation is performed server-side.**
- Clients submit raw inputs only.
- Clients must never self-report authoritative scores.
- Timeout/no submission scores 0.

Applicable universal bonuses and penalties:

| Event | Delta | Notes |
|-------|-------|-------|
| Base score | 90 pts | Starting value where applicable |
| No hints bonus | +20 pts | Applied when no hints were used |
| Perfect solve bonus | +15 pts | Applied when error tracking exists |
| Hint usage | −5 pts each | Server-tracked |
| Wrong answer | −2 to −10 pts | Game-specific; floor at 0 |
| Timeout | 0 pts | No submission by deadline |
| Skip vote success | +5 pts per voter | Applied on skip quorum |
| Unique word bonus | +5 pts per word | Post-deadline in Anagram Sprint |

### 2.2 Battle scoreboard flow

1. Player submits game inputs
2. Server validates inputs
3. Server computes final score
4. Score is written to the authoritative battle/game score store
5. Battle total is aggregated automatically
6. War leaderboard is updated automatically
7. Players receive a results notification
8. Results screen is shown within 3 seconds of the last submission

### 2.3 Scoreboard requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| S-01 | Server-side score authority | MUST | Score display always comes from authoritative server storage |
| S-02 | Score written within 5 seconds | MUST | 95th percentile submit-to-write latency ≤ 5s |
| S-03 | Battle total equals sum of game scores | MUST | Automated aggregation test passes |
| S-04 | War leaderboard updates after each Battle | MUST | Running totals refresh after Battle resolution |
| S-05 | Tie-breaking defined | MUST | Equal scores rank by fastest average completion time |
| S-06 | Score visibility rules enforced | MUST | Competitor scores stay hidden until game completion |
| S-07 | Bonus scores applied atomically | SHOULD | Post-game bonus writes occur transactionally |

---

## 3. Competitive Fairness and Anti-Cheat

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| F-01 | Server-side puzzle generation | MUST | No puzzle data generated client-side |
| F-02 | Identical seed per Battle | MUST | All players receive identical puzzle data |
| F-03 | Solution encryption | MUST | Solutions are never transmitted during play |
| F-04 | Server-side timestamp authority | MUST | Device clock changes do not affect completion time |
| F-05 | Rate limiting on answer submission | MUST | >20 submissions/minute returns HTTP 429 |
| F-06 | Impossible-puzzle guard | MUST | Generator tests show 0 unsolvable outputs |
| F-07 | Suspicious timing detection | SHOULD | Impossibly fast solves are flagged for review |

---

## 4. Asynchronous Multiplayer

### 4.1 Battle lifecycle

Every Battle follows the lifecycle:

1. **Selection**
2. **Play**
3. **Results**

The lifecycle must auto-advance once Battle configuration exists.

#### Selection phase
- Players vote for 2 games from the eligible pool
- Voting window is configurable from 15 minutes to 48 hours
- If no votes are cast, the system auto-selects 2 games pseudo-randomly
- Previously played games receive reduced selection weight
- Phase closes automatically once all players vote or the window expires

#### Play phase
- Players receive a push notification when the Battle goes live
- Play window is configurable from 24 hours to 7 days
- Games may be played in any order
- Completion state is visible, scores remain hidden
- Results phase auto-triggers when all players complete both games or when the play window expires

#### Results phase
- Individual game rankings shown first
- Battle total shown second
- Running War leaderboard updated
- Battle winner highlighted
- Next Battle selection begins after a short hold or manual Big Brain advance

### 4.2 Async requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| A-01 | Push notification for every phase transition | MUST | Delivery within 30 seconds in 95% of cases |
| A-02 | Auto-advance on completion | MUST | Results phase triggers within 10 seconds of the final submission |
| A-03 | Play window enforcement | MUST | Late submissions return HTTP 410 Gone |
| A-04 | Progress auto-save | MUST | Progress restores accurately after app restart |
| A-05 | Offline play with sync | MUST | Offline completion syncs correctly on reconnect |
| A-06 | Vote-to-skip inactive players | MUST | Majority quorum grants +5 to each voter and 0 to the skipped player |
| A-07 | Multi-Battle War support | MUST | 1–10 Battles cycle correctly |
| A-08 | Big Brain configuration panel | SHOULD | Configuration persists and applies correctly |

---

## 5. Chat System

### 5.1 Chat overview

Mind Wars chat is persistent, lobby-scoped, and accessible from iOS, Android, and web. Chat is available throughout the entire War and is not gated behind game completion.

### 5.2 Chat requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| C-01 | Real-time message delivery | MUST | Messages appear for all lobby members within 2 seconds |
| C-02 | Persistent message history | MUST | Full history remains visible across app restarts |
| C-03 | Cross-device access | MUST | History and live updates match on iOS, Android, and web |
| C-04 | Sender identification | MUST | Username, avatar, and timestamp render correctly |
| C-05a | Profanity filter | MUST | Hate speech and slurs are replaced before authoritative write |
| C-05b | Profanity bypass detection | SHOULD | Bypass attempts (spacing, l33tspeak, homoglyphs) are flagged into an admin moderation queue for review |
| C-06 | Emoji reactions | MUST | Reaction counts update in real time |
| C-07 | Chat push notifications | MUST | Backgrounded clients receive chat notifications |
| C-08 | System messages | MUST | Phase transitions and completions emit chat system messages |
| C-09 | Message character limit | MUST | Messages capped at 500 characters |
| C-10 | GIF and sticker support | SHOULD | Only assets from the curated/allowlisted GIF and sticker provider render inline; non-approved media is rejected with an error |
| C-11 | Message reporting | SHOULD | Messages can be flagged for admin review |
| C-12 | Scroll-to-latest on load | SHOULD | Chat opens at the newest message |

### 5.3 Chat data model

Chat messages are stored in the authoritative lobby-scoped chat store with at least:

- `messageId`
- `senderId`
- `senderUsername`
- `senderAvatarUrl`
- `content`
- `type`
- `reactions`

---

## QA Release Gate

Public v1.0 is shippable only when:

- The launch catalog matches the nine-game list above
- Puzzle generation, timestamps, and scoring are server-authoritative
- Scoreboard propagation and tie-break rules are validated end to end
- Battle phase automation works without manual intervention
- Offline sync and autosave scenarios pass
- Persistent chat and moderation requirements pass across supported clients
