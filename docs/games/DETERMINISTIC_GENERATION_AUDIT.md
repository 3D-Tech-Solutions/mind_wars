# Deterministic Generation Audit

**Current Implementation Status:** April 2, 2026  
**Review Scope:** All 15 Games  
**Purpose:** Identify gaps between spec requirements and current code

---

## Audit Results Summary

| Game | RNG Seeding | Server Hash | Metrics Tracking | Reproducible | Status | Priority |
|------|-------------|------------|-----------------|--------------|--------|----------|
| Puzzle Race | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Focus Finder | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Path Finder | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Pattern Memory | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Spot Difference | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Logic Grid | ✅ Yes | ❌ Missing | ❌ Missing | ✅ Yes | ⚠️ PARTIAL | P0 |
| Rotation Master | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Sequence Recall | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Color Rush | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Sudoku Duel | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P0 |
| Code Breaker | ✅ Yes | ❌ Missing | ❌ Missing | ✅ Yes | ⚠️ PARTIAL | P1 |
| Memory Match | ✅ Yes | ❌ Missing | ❌ Missing | ✅ Yes | ⚠️ PARTIAL | P1 |
| Anagram Attack | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P2 |
| Word Builder | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P2 |
| Vocabulary Showdown | ⚠️ Partial | ❌ Missing | ❌ Missing | 🟡 Needs Verification | ⚠️ TODO | P2 |

**Overall Status:** ❌ **NOT COMPLIANT** — No games have full implementation

---

## Detailed Findings

### ✅ Fully Seeded (Good RNG Practice)

#### Logic Grid Game
**File:** `lib/games/widgets/logic_grid_game.dart`

Current code:
```dart
void _generatePuzzle() {
  final random = Random();  // ⚠️ UNSEEDED - NEEDS FIX
  final shuffledColors = List.from(_colors)..shuffle(random);
  // ...
}
```

**Issue:** Uses unseeded `Random()` which depends on system time  
**Fix Required:** Accept `randomSeed` parameter and initialize as:
```dart
final random = Random(randomSeed);
```

**Mitigation:** Seed-based generation would be straightforward since logic is already in place

---

#### Code Breaker Game
**File:** `lib/games/widgets/code_breaker_game.dart`

Current code:
```dart
void _initializeGame() {
  _secretCode = List.generate(_codeLength, (_) => Random().nextInt(6) + 1);
  // ...
}
```

**Issue:** Uses unseeded `Random()` for every game  
**Fix Required:** 
```dart
final random = Random(gameInstance.randomSeed);
_secretCode = List.generate(_codeLength, (_) => random.nextInt(6) + 1);
```

**Impact:** Critical for multiplayer fairness — players must get same code

---

#### Memory Match Game
**File:** `lib/games/widgets/memory_match_game.dart`

Current code:
```dart
void _initializeGame() {
  final symbols = ['🌟', '🎨', '🎭', '🎪', '🎯', '🎲', '🎸', '🎹'];
  _cards = [...symbols, ...symbols];
  _cards.shuffle(Random());  // ⚠️ UNSEEDED
  // ...
}
```

**Issue:** Unseeded shuffle means different card orders for each player  
**Fix Required:**
```dart
final random = Random(gameInstance.randomSeed);
_cards.shuffle(random);
```

**Impact:** Players in same Mind War would get different card layouts

---

### ⚠️ Partially Seeded (Inconsistent)

#### Puzzle Race Game
**File:** `lib/games/widgets/puzzle_race_game.dart`

Current code:
```dart
void _generatePuzzle() {
  final random = Random();  // ⚠️ UNSEEDED
  for (var i = 0; i < shuffleCount; i++) {
    final validMoves = _getValidMoves();
    if (validMoves.isNotEmpty) {
      _moveTile(validMoves[random.nextInt(validMoves.length)]);
    }
  }
  // ...
}
```

**Issue:** Shuffle sequence is different each time; players face different puzzle difficulties  
**Fix Required:** Accept `randomSeed` and initialize `Random(randomSeed)`

**Impact:** HIGH — Two players in same Mind War would have different shuffle sequences, leading to different solution path lengths

---

#### Focus Finder Game
**File:** `lib/games/widgets/focus_finder_game.dart`

Current code:
```dart
void _generateScene() {
  final random = Random();  // ⚠️ UNSEEDED
  final shuffled = List<String>.from(_itemPool)..shuffle(random);
  // ...
}
```

**Issue:** Unseeded shuffle produces different scenes for each player  
**Fix Required:** Use seeded RNG

**Impact:** HIGH — Target positions vary per player, creating unfair difficulty

---

#### Path Finder Game
**File:** `lib/games/widgets/path_finder_game.dart`

Current code:
```dart
void _generateMaze() {
  final random = Random();  // ⚠️ UNSEEDED
  final addedWalls = <String>{};
  while (addedWalls.length < wallCount) {
    final row = random.nextInt(_gridSize);
    final col = random.nextInt(_gridSize);
    // ...
  }
}
```

**Issue:** Unseeded wall placement produces different mazes  
**Fix Required:** Use seeded RNG

**Impact:** HIGH — Two players in same Mind War play different mazes

---

#### Pattern Memory Game
**File:** `lib/games/widgets/pattern_memory_game.dart`

Current code:
```dart
void _generatePattern() {
  _pattern = List.filled(totalCells, false);
  final random = Random();  // ⚠️ UNSEEDED
  final indices = List.generate(totalCells, (i) => i)..shuffle(random);
  // ...
}
```

**Issue:** Different patterns generated for each player  
**Fix Required:** Use seeded RNG

**Impact:** HIGH — Pattern complexity differs per player

---

#### Spot Difference Game
**File:** `lib/games/widgets/spot_difference_game.dart`

Current code:
```dart
void _generatePuzzle() {
  final random = Random();  // ⚠️ UNSEEDED
  _pattern1 = List.generate(totalCells, (_) => random.nextBool());
  final available = List.generate(totalCells, (i) => i)..shuffle(random);
  // ...
}
```

**Issue:** Patterns and difference placement vary per player  
**Fix Required:** Use seeded RNG

**Impact:** HIGH — Different difficulty per player

---

#### Rotation Master Game
**File:** `lib/games/widgets/rotation_master_game.dart`

Current code:
```dart
void _generateRound() {
  final random = Random();  // ⚠️ UNSEEDED
  _targetShape = _shapes[random.nextInt(_shapes.length)];
  _targetRotation = (random.nextInt(4) * 90).toDouble();
  // ...
}
```

**Issue:** Different shapes/rotations per player  
**Fix Required:** Use seeded RNG

**Impact:** MEDIUM — Shape variety differs, but difficulty is similar

---

#### Sequence Recall Game
**File:** `lib/games/widgets/sequence_recall_game.dart`

Current code:
```dart
void _generateSequence() {
  _sequence = List.generate(
    3 + _level,
    (index) => Random().nextInt(4),  // ⚠️ UNSEEDED for each item
  );
  // ...
}
```

**Issue:** Different sequences generated for each player  
**Fix Required:** Seed RNG before generation

**Impact:** HIGH — Exact sequence differs per player

---

#### Color Rush Game
**File:** `lib/games/widgets/color_rush_game.dart`

Current code:
```dart
void _generateRound() {
  final random = Random();  // ⚠️ UNSEEDED
  _targetColor = _baseColors[random.nextInt(_baseColors.length)];
  final gridColors = [];
  gridColors.addAll(List.filled(2, _targetColor));
  for (int i = 0; i < gridSize - 2; i++) {
    gridColors.add(nonTargetColors[random.nextInt(nonTargetColors.length)]);
  }
  gridColors.shuffle(random);
  // ...
}
```

**Issue:** Different grid layouts per player  
**Fix Required:** Use seeded RNG

**Impact:** MEDIUM — Color positions vary, difficulty is similar

---

#### Sudoku Duel Game
**File:** `lib/games/widgets/sudoku_duel_game.dart`

Current code:
```dart
void _generateBoard() {
  final random = Random();  // ⚠️ UNSEEDED
  final solution = solutions[random.nextInt(solutions.length)];
  final cellsToRemove = <String>{};
  while (cellsToRemove.length < 6) {
    final row = random.nextInt(4);
    final col = random.nextInt(4);
    // ...
  }
}
```

**Issue:** Different puzzle variants per player  
**Fix Required:** Use seeded RNG

**Impact:** MEDIUM — Different blank positions, but fixed difficulty

---

#### Anagram Attack Game
**File:** `lib/games/widgets/anagram_attack_game.dart`

Current code:
```dart
void _nextAnagram() {
  if (_words.isEmpty) {
    completeGame();
    return;
  }
  _targetWord = _words.removeAt(Random().nextInt(_words.length));  // ⚠️ UNSEEDED
  // ...
}
```

**Issue:** Different word order per player  
**Fix Required:** Seed RNG for word pool shuffling at init

**Impact:** LOW-MEDIUM — Word difficulty varies, words are constant

---

#### Word Builder Game
**File:** `lib/games/word_builder/word_builder_game_enhanced.dart`

Current code (delegated):
```dart
// Needs investigation in enhanced implementation
```

**Status:** NEEDS REVIEW — Complex generation in enhanced implementation

**Fix Required:** Ensure seeded RNG for tile placement

---

#### Vocabulary Showdown Game
**File:** `lib/games/widgets/vocabulary_showdown_game.dart`

Current code:
```dart
late VocabularyGameService _gameService;

void _initializeSession() {
  _session = _gameService.createSession(
    gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',  // ⚠️ TIME-BASED ID
    // ...
  );
}
```

**Issue:** Game ID based on timestamp, not deterministic seed  
**Fix Required:** Accept `randomSeed` from backend, use it for question ordering

**Impact:** HIGH — Different question sequences per player

---

## Missing Implementations

### ❌ Server-Side Game Instance Generation

**Status:** Not implemented

**Required:** Backend API to:
1. Generate `gameInstanceId` 
2. Assign `randomSeed` (deterministic from gameId + level)
3. Compute `puzzleHash` (for verification)
4. Store in database for validation

```dart
// Required API endpoint
POST /api/mind-wars/{warId}/generate-game
{
  "gameType": "puzzle_race",
  "level": 1
}
→ Returns gameInstanceId, randomSeed, puzzleHash
```

---

### ❌ Client-Side Puzzle Hash Verification

**Status:** Not implemented

**Required:** Client must:
1. Receive `gameInstanceId` + `randomSeed` from server
2. Generate puzzle with that seed
3. Compute hash of puzzle state
4. Verify hash matches server's expected hash
5. Send hash with score submission for validation

---

### ❌ Metrics Collection

**Status:** Not implemented

**Required:** Track per game instance:
- `playCount` — How many times played
- `avgScore` — Average score
- `solveRate` — % of players who solved
- `avgTime` — Average completion time
- `difficultyAccuracy` — How close to expected difficulty

---

## Fix Priority

### P0 — CRITICAL (Before Multiplayer Launch)

**Affecting:** Puzzle Race, Focus Finder, Path Finder, Pattern Memory, Spot Difference  
**Impact:** Players in same Mind War play different games  
**Timeline:** Must fix immediately

**Action Items:**
```
1. [ ] Modify all 5 P0 games to accept randomSeed parameter
2. [ ] Replace all Random() with Random(randomSeed)
3. [ ] Test reproducibility: same seed produces identical puzzle
4. [ ] Create unit tests verifying determinism across platforms
```

### P1 — HIGH (Before Ranked Play)

**Affecting:** Logic Grid  
**Impact:** Code generation is currently unseeded  
**Timeline:** Fix in next sprint

---

### P2 — MEDIUM (Before Full Launch)

**Affecting:** Anagram Attack, Word Builder, Vocabulary Showdown, Color Rush, Sudoku Duel, Rotation Master, Sequence Recall  
**Impact:** Affects fairness and metrics tracking  
**Timeline:** Before public leaderboards

---

## Implementation Roadmap

### Phase 1: Immediate (This Week)
- [ ] Audit all 15 games for unseeded RNG
- [ ] Flag critical unfairness issues
- [ ] Patch P0 games (5 total)
- [ ] Add unit tests for determinism

### Phase 2: Backend Integration (Next 2 Weeks)
- [ ] Create `/api/mind-wars/{warId}/generate-game` endpoint
- [ ] Store gameInstance + randomSeed in database
- [ ] Compute puzzleHash on generation
- [ ] Pass gameInstanceId to client

### Phase 3: Client Verification (Next 2 Weeks)
- [ ] Client receives gameInstanceId + randomSeed
- [ ] Client verifies puzzle reproducibility
- [ ] Client computes puzzleHash
- [ ] Client sends hash with score submission

### Phase 4: Metrics & Validation (Next 3 Weeks)
- [ ] Server validates puzzleHash on score submission
- [ ] Collect per-game metrics
- [ ] Build fairness audit dashboard
- [ ] Identify difficulty outliers

### Phase 5: Leaderboard Certification (Week 5+)
- [ ] Only accept scores with valid puzzleHash
- [ ] Certify historic leaderboard scores
- [ ] Flag uncertified scores
- [ ] Publish fairness metrics publicly

---

## Testing Checklist

For each game, verify:

```
[ ] Same seed produces identical puzzle on run 1
[ ] Same seed produces identical puzzle on run 2
[ ] Same seed produces identical puzzle on different device
[ ] Different seed produces different puzzle
[ ] Puzzle is valid (solvable, within bounds, etc.)
[ ] Hash computation is deterministic
[ ] Client verification passes for valid seed
[ ] Client verification fails for corrupted seed
```

---

## Document Status

**Created:** April 2, 2026  
**Severity:** CRITICAL  
**Owner:** Backend Architecture  
**Next Review:** Weekly (until all P0 fixed)

**Dependencies:** 
- DETERMINISTIC_GENERATION_SPEC.md (requirements)
- All 15 game implementations

