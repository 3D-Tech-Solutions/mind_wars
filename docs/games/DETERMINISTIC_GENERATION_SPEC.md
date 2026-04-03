# Deterministic Game Generation & Fairness Specification

**Status:** Critical Architecture Requirement  
**Last Updated:** April 2, 2026  
**Scope:** All 15 Launch Games + Future Variants

This specification defines how all Mind Wars games must implement deterministic, reproducible puzzle/challenge generation to ensure **fairness across all players in the same Mind War**.

---

## Core Principle

**Every puzzle, game state, level, and challenge variant in a Mind War must be generated identically for ALL players.**

A Mind War is unfair if:
- ❌ Player A gets an easy puzzle seed while Player B gets a hard one
- ❌ Player A's shuffle produces a 5-move solution while Player B's produces 25 moves
- ❌ Player A's target colors are sparse while Player B's are dense
- ❌ Players cannot verify they played the same game

A Mind War is fair if:
- ✅ All players receive the same `gameId` + `levelId` pair
- ✅ That pair deterministically generates identical puzzle state
- ✅ Every player solves the EXACT same puzzle
- ✅ The generation is reproducible and verifiable

---

## Implementation Pattern

### 1. Seeded Random Generation

Every game must use **seeded randomness** for deterministic output:

```dart
// GOOD: Seeded RNG produces identical output every time
final seed = int.parse('${gameId}${levelId}');
final random = Random(seed);
final puzzle = _generatePuzzle(random);

// BAD: Unseeded RNG produces different output each time
final random = Random();  // Uses system time - WRONG!
final puzzle = _generatePuzzle(random);
```

### 2. Unique Identifiers

Each game instance requires:

```dart
class GameInstance {
  final String gameId;              // Unique per Mind War
  final String gameType;             // e.g., "puzzle_race", "focus_finder"
  final int level;                   // 1, 2, or 3
  final int maxLevel;                // Typically 3 (game completion threshold)
  final Map<String, dynamic> config; // Difficulty parameters (optional overrides)
  final DateTime generatedAt;        // For metrics tracking
  
  // Derived from gameId + gameType + level
  String get puzzleId => '${gameId}_${gameType}_L${level}';
  
  // Seed for RNG (reproducible across platforms/devices)
  int get randomSeed {
    final combined = '$gameId$gameType$level';
    return combined.hashCode.abs();
  }
}
```

### 3. Generation Must Be Reproducible

Every generation function must:

1. Accept a `Random` instance with fixed seed
2. Produce identical output when called with same seed
3. NOT depend on device state, time, or external variables
4. Be deterministic: `f(seed) == f(seed)` always

```dart
// GOOD: Deterministic
List<int> generatePuzzle(Random random, int gridSize) {
  final items = List.generate(gridSize, (i) => i);
  items.shuffle(random);  // Uses provided Random instance
  return items;
}

// BAD: Non-deterministic
List<int> generatePuzzle(Random random, int gridSize) {
  final items = List.generate(gridSize, (i) => DateTime.now().microsecond);
  return items;  // Uses system time - NOT reproducible!
}
```

---

## Per-Game Implementation Requirements

### Puzzle Race (Spatial)

```dart
class PuzzleRaceGame {
  void _initializeGame(GameInstance gameInstance) {
    final random = Random(gameInstance.randomSeed);
    
    // Level determines grid size and shuffle intensity
    final gridSize = gameInstance.level == 1 ? 3 : 4;
    final shuffleCount = gameInstance.level == 1 ? 100 : gameInstance.level == 2 ? 120 : 150;
    
    // Generate solved state
    _tiles = List.generate(gridSize * gridSize - 1, (i) => i + 1);
    _tiles.add(0);
    
    // Shuffle from solved state (ensures solvability)
    _emptyIndex = _tiles.length - 1;
    for (int i = 0; i < shuffleCount; i++) {
      final validMoves = _getValidMoves();
      final moveIndex = validMoves[random.nextInt(validMoves.length)];
      _tiles[_emptyIndex] = _tiles[moveIndex];
      _tiles[moveIndex] = 0;
      _emptyIndex = moveIndex;
    }
  }
}
```

### Focus Finder (Attention)

```dart
class FocusFinderGame {
  void _initializeGame(GameInstance gameInstance) {
    final random = Random(gameInstance.randomSeed);
    
    final targetCount = 2 + gameInstance.level;  // 3, 4, or 5
    final distractorCount = 20 - gameInstance.level;  // 19, 18, or 17
    
    // Generate targets deterministically
    final allItems = List.from(_itemPool)..shuffle(random);
    _targets = allItems.take(targetCount).toList();
    
    // Generate distractors deterministically
    final distractors = List.from(_itemPool)
      ..removeWhere((item) => _targets.contains(item))
      ..shuffle(random);
    _allItems = [..._targets, ...distractors.take(distractorCount)]
      ..shuffle(random);
  }
}
```

### Logic Grid (Logic)

```dart
class LogicGridGame {
  void _initializeGame(GameInstance gameInstance) {
    final random = Random(gameInstance.randomSeed);
    
    // Generate clues based on level (deterministic)
    final shuffledColors = List.from(_colors)..shuffle(random);
    
    _solution = {};
    for (var i = 0; i < _people.length; i++) {
      _solution[_people[i]] = shuffledColors[i];
    }
    
    // Clue generation based on level (deterministic mix)
    if (gameInstance.level == 1) {
      // All positive clues
      _clues = _generatePositiveClues();
    } else if (gameInstance.level == 2) {
      // Mixed clues
      _clues = _generateMixedClues(random);
    } else {
      // Strategic negatives
      _clues = _generateStratégicClues(random);
    }
  }
}
```

### All Other Games

Follow the same pattern:
1. Initialize `Random(gameInstance.randomSeed)`
2. Use seeded RNG for all randomization
3. Never use `Random()` without seed
4. Never use `DateTime.now()` for game generation
5. Document seed generation formula

---

## Tracking & Metrics

### Game Instance Schema

Store for every Mind War game:

```json
{
  "mindWarId": "war_2026_04_02_abc123",
  "gameInstanceId": "gi_2026_04_02_puzzle_race_001",
  "gameType": "puzzle_race",
  "levelNumber": 1,
  "randomSeed": 12345678,
  "generatedAt": "2026-04-02T14:30:00Z",
  "players": [
    {
      "playerId": "player_alice",
      "result": "solved",
      "movesUsed": 15,
      "timeSeconds": 45,
      "scoreEarned": 25
    },
    {
      "playerId": "player_bob",
      "result": "solved",
      "movesUsed": 18,
      "timeSeconds": 52,
      "scoreEarned": 22
    }
  ],
  "difficulty": {
    "level": 1,
    "expectedMoves": 12,
    "avgMovesDifficulty": 0.95
  }
}
```

### Metrics to Track

For each `(gameType, level)` pair, track:

```
- playCount: How many times this puzzle was played
- avgScore: Average player score
- solveRate: % of players who solved it
- avgTime: Average completion time
- difficultyAccuracy: How close to expected difficulty
- easierThanExpected: % where solve was faster than average
- harderThanExpected: % where solve was slower than average
```

Use this to identify:
- 🔥 Broken puzzles (unsolvable or trivial)
- 📊 Difficulty outliers (too easy/hard for level)
- 🎯 Popular game types (which games played most)
- 🏆 Leaderboard-relevant variants (which are competitive)

---

## Verification & Validation

### Client-Side Verification

Before displaying a puzzle, verify reproducibility:

```dart
void verifyGameInstance(GameInstance gameInstance) {
  // Generate puzzle twice with same seed
  final puzzle1 = _generatePuzzle(Random(gameInstance.randomSeed));
  final puzzle2 = _generatePuzzle(Random(gameInstance.randomSeed));
  
  // They must be identical
  assert(puzzle1 == puzzle2, 'Game generation is non-deterministic!');
  
  // Store hash for server validation
  gameInstance.puzzleHash = sha256.convert(puzzle1.toString()).toString();
}
```

### Server-Side Validation

Before accepting a score submission, validate:

1. **Puzzle Hash Match** — Client hash == Server hash
2. **Seed Reproducibility** — Can regenerate same puzzle from seed
3. **Player Identity** — scoreSubmission.playerId matches authenticated user
4. **Fair Play** — Submission time reasonable for difficulty level
5. **Completion Status** — Player reached valid end-state

```
POST /api/minds-war/{warId}/games/{gameInstanceId}/submit-score

{
  "playerId": "player_alice",
  "gameInstanceId": "gi_2026_04_02_puzzle_race_001",
  "result": "solved",
  "movesUsed": 15,
  "timeSeconds": 45,
  "clientPuzzleHash": "abc123...",  // For verification
  "submission": { /* game-specific result */ }
}

Server validates:
✓ gameInstanceId exists
✓ clientPuzzleHash matches known seed
✓ playerId is authenticated
✓ timeSeconds is reasonable
✓ result is valid end-state
```

---

## Game-Specific Generation Details

### Anagram Attack
- **Seed Determines:** Word pool order, difficulty tier assignment
- **Non-Random:** Word solutions themselves (fixed dictionary)
- **Tracking:** Level reached, words solved, solve times per word

### Code Breaker
- **Seed Determines:** 4-digit code, hint sequence (if applicable)
- **Non-Random:** Validation logic, feedback rules
- **Tracking:** Attempts needed, guessing strategy efficiency

### Color Rush
- **Seed Determines:** Color order, distractor distribution
- **Non-Random:** Timer values (fixed per level: 3s, 2s, 1s)
- **Tracking:** Combos achieved, reaction time, accuracy

### Focus Finder
- **Seed Determines:** Target selection, distractor placement, grid layout
- **Non-Random:** Grid dimensions (constant per level)
- **Tracking:** Search efficiency, false taps, target found order

### Logic Grid
- **Seed Determines:** Person-attribute assignments, clue generation
- **Non-Random:** Clue types per level (positive, mixed, strategic)
- **Tracking:** Solve time, logical deduction efficiency, hint usage

### Memory Match
- **Seed Determines:** Symbol/emoji assignment to cards, shuffle
- **Non-Random:** Card grid (constant: 8 pairs)
- **Tracking:** Pair matching efficiency, memory span, solve time

### Path Finder
- **Seed Determines:** Wall placement, maze solvability check
- **Non-Random:** Grid size, BFS validation
- **Tracking:** Path efficiency vs. optimal, detour count, solve time

### Pattern Memory
- **Seed Determines:** Filled cell positions, reveal timer, grid pattern
- **Non-Random:** Grid size per level, accuracy threshold
- **Tracking:** Pattern complexity achieved, recall accuracy, view time effectiveness

### Puzzle Race
- **Seed Determines:** Starting grid scramble, shuffle sequence
- **Non-Random:** Grid size per level, move-count scoring formula
- **Tracking:** Move efficiency, shuffle complexity impact, solve difficulty

### Rotation Master
- **Seed Determines:** Shape selection, rotation angle, distractor order
- **Non-Random:** Rotation options (always 0°, 90°, 180°, 270°)
- **Tracking:** Streak length, visual recognition speed, rotation complexity

### Sequence Recall
- **Seed Determines:** Sequence item selection, flash timing variations
- **Non-Random:** Sequence length per level, button count
- **Tracking:** Memory span, recall accuracy, sequence complexity achieved

### Spot the Difference
- **Seed Determines:** Base pattern, difference cell selection
- **Non-Random:** Grid size (constant 6×6), difference count per level
- **Tracking:** Scanning efficiency, false taps, systematic search patterns

### Sudoku Duel
- **Seed Determines:** Sudoku solution, blank cell selection
- **Non-Random:** Grid size (constant 4×4), blank count per level
- **Tracking:** Solving strategy, constraint propagation efficiency, solve time

### Vocabulary Showdown
- **Seed Determines:** Question pool order, difficulty tier assignment, MCQ distractor order
- **Non-Random:** Question count (10), tier selection algorithm
- **Tracking:** Question difficulty tier accuracy, time per question, accuracy per tier

### Word Builder
- **Seed Determines:** Initial tile configuration, cascade/refill sequences
- **Non-Random:** Grid size (3×3), tile variant frequency
- **Tracking:** Word length distribution, word rarity scoring, cascade efficiency

---

## Implementation Checklist

For each of the 15 games:

- [ ] Seeded RNG initialized in `_initializeGame()` with `gameInstance.randomSeed`
- [ ] No unseeded `Random()` calls in puzzle generation
- [ ] No `DateTime.now()` or system time in deterministic code paths
- [ ] Generation verified as reproducible (same seed → same puzzle)
- [ ] Puzzle hash computed for server validation
- [ ] Game instance metadata passed from backend to client
- [ ] Client sends `gameInstanceId` + `clientPuzzleHash` with score submission
- [ ] Server validates hash matches expected seed
- [ ] Metrics collected: solveRate, avgScore, avgTime per (gameType, level)
- [ ] Difficulty outliers identified and flagged

---

## Server API Contract

### Generate Game Instance

```
POST /api/mind-wars/{warId}/generate-game

Request:
{
  "gameType": "puzzle_race",
  "level": 1,
  "configOverrides": { /* optional */ }
}

Response:
{
  "gameInstanceId": "gi_2026_04_02_puzzle_race_001",
  "gameType": "puzzle_race",
  "level": 1,
  "randomSeed": 12345678,
  "puzzleHash": "abc123def456...",
  "generatedAt": "2026-04-02T14:30:00Z",
  "expectedDifficulty": {
    "level": 1,
    "expectedSolveTime": 45,
    "expectedScore": 25
  }
}
```

### Submit Score

```
POST /api/mind-wars/{warId}/games/{gameInstanceId}/submit-score

Request:
{
  "playerId": "player_alice",
  "gameInstanceId": "gi_2026_04_02_puzzle_race_001",
  "result": { /* game-specific */ },
  "clientPuzzleHash": "abc123def456...",
  "timeSeconds": 45,
  "score": 25
}

Validation:
- clientPuzzleHash == serverPuzzleHash (ensures same game)
- playerId authenticated
- timeSeconds reasonable
- result is valid end-state
```

---

## Critical Warnings

🚨 **Common Mistakes**

1. **Unseeded Random()**
   - ❌ `final random = Random();` — Uses system time
   - ✅ `final random = Random(gameInstance.randomSeed);` — Deterministic

2. **Time-Based Variation**
   - ❌ Using `DateTime.now()` in puzzle generation
   - ✅ Using only RNG with fixed seed

3. **Platform Differences**
   - ❌ Assuming same RNG on iOS vs. Android produces identical shuffles
   - ✅ Testing seed reproducibility across platforms

4. **Missing Server Validation**
   - ❌ Accepting scores without verifying puzzle hash
   - ✅ Server regenerates puzzle from seed and validates hash match

5. **No Fairness Audit Trail**
   - ❌ Not logging which players got which seeds
   - ✅ Storing gameInstanceId + seed + all player results for audit

---

## Future Extensions

As the game library expands:

1. **Difficulty Calibration** — Use historical metrics to calibrate difficulty curves
2. **Player-Specific Seeding** — Optional: seed based on player skill rating (for ranked play)
3. **Tournament Variants** — All players in tournament tier play same game, different tier gets different seed
4. **Leaderboard Certification** — Scores only count if puzzleHash verifies to known seed

---

**Document Status:** Complete and mandatory for all implementations  
**Review Cycle:** Quarterly (based on fairness audit metrics)  
**Owner:** Backend Architecture / Game Systems

