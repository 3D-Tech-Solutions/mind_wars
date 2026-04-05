# Path Finder Puzzle Generation Specification

## Overview

Path Finder is a spatial navigation puzzle game where players must navigate from a start position to a goal position while collecting cargo boxes in a deterministically-generated maze. All players in a Mind War receive identical mazes through a **sealed payload architecture**: the backend generates one canonical maze payload, clients render only the declared integer cell coordinates, and the server replays the submitted move transcript before accepting the score.

**Critical Feature**: Exact same puzzle creation on Android, iOS, and the backend from the same `battleSeed`, `gameIndex`, and schema version.

---

## Architecture

### Key Components

1. **PathFinderEngine** (`path_finder_engine.dart`)
   - Deterministic sealed challenge generation
   - Cargo-aware BFS solvability validation
   - Canonical checksum + submission hashing
   - Replayable score verification

2. **GameGeneratorService** Integration
   - Entry point: `generateGameState(gameId: 'path_finder', ...)`
   - Calls `PathFinderEngine.generateBattleChallengeSet()`
   - Returns a `challengeSet` for UI rendering

---

## Maze Generation Algorithm

### Phase 1: Start & End Node Placement

```
Constraint: Start in top-left quadrant, goal in bottom-right quadrant
Distance: Minimum Manhattan distance = gridWidth / 2

Algorithm:
  1. Start: Random position in [0, width/2) × [0, height/2)
  2. Goal: Random position in [width/2, width) × [height/2, height)
     (Retry until Manhattan distance ≥ gridWidth/2)
```

**Grid Dimensions**: 16×16 cells

**RNG Call Sequence**:
```dart
// In strict order (must not deviate):
startX = random.nextInt(gridWidth ~/ 2);
startY = random.nextInt(gridHeight ~/ 2);

// Retry loop:
do {
  endX = (gridWidth ~/ 2) + random.nextInt(gridWidth ~/ 2);
  endY = (gridHeight ~/ 2) + random.nextInt(gridHeight ~/ 2);
} while (distance < minDistance);
```

### Phase 2: Cargo Box Placement

```
Difficulty-based cargo count:
  Easy:   2 boxes
  Medium: 3 boxes
  Hard:   4 boxes
  Elite:  5 boxes

Algorithm:
  1. Iterate with RNG until cargoCount boxes placed
  2. Each attempt: x = random.nextInt(16), y = random.nextInt(16)
  3. Place only on empty cells (not walls, start, goal, or existing cargo)
  4. Max 100 attempts before giving up
```

### Phase 3: Wall Placement

```
Difficulty-based wall count:
  Easy:   16 walls
  Medium: 24 walls
  Hard:   32 walls
  Elite:  40 walls

Algorithm:
  1. Iterate with RNG until wallCount walls placed
  2. Each attempt: x = random.nextInt(16), y = random.nextInt(16)
  3. Place only on empty cells
  4. Max 500 attempts before giving up
```

**Cell Type Encoding**:
```
0 = Empty
1 = Wall
2 = Player Start
3 = Goal
4 = Cargo Box
```

### Phase 4: Topological Elements (Elite Only)

For Elite difficulty, create wider corridors and chambers:

```dart
// Create 3 wider passages (2-3 cells wide)
for (i = 0 to 2) {
  startX = random.nextInt(gridWidth - 4) + 2;
  startY = random.nextInt(gridHeight - 4) + 2;
  
  direction = random.nextInt(2);  // 0=horizontal, 1=vertical
  length = 4 + random.nextInt(4);
  
  if (direction == 0) {
    // Horizontal corridor: clear cells in row
  } else {
    // Vertical corridor: clear cells in column
  }
}
```

**Purpose**: Makes Elite mazes more strategically complex with larger open areas requiring more navigation planning.

---

## Maze Validation: BFS Solvability Check

After all elements placed, validate maze is solvable using Breadth-First Search:

```dart
Algorithm: BFS(start, goal)
  queue = [start]
  visited = {start}
  parent = {}
  
  while (queue not empty):
    current = queue.pop()
    
    if (current == goal):
      reconstruct_path(parent) → return path, pathLength
    
    for each adjacent cell in [up, down, left, right]:
      if (is_valid(cell) AND cell not in visited):
        visited.add(cell)
        parent[cell] = current
        queue.add(cell)
  
  return no_path_found
```

**Valid Cell**: Must be within bounds AND not a wall (can be empty, cargo, start, or goal).

**Wall Validation Rule**: Candidate walls are only kept if the maze remains solvable for the full cargo-collection route. The deterministic identity never changes by mutating `gameIndex`.

---

## Fitness Scoring System

After validation, score maze fitness against difficulty-specific thresholds. Fitness ensures mazes are appropriately challenging for their difficulty level.

### Metrics Calculated

```
1. Path Length
   - Optimal path from start to goal (number of steps)
   
2. Corner Count
   - Number of direction changes in optimal path
   - Measures turning complexity
   
3. Empty Spaces
   - Total navigable (non-wall) cells
   - Indicates maze openness
   
4. Cargo Density
   - cargoCount / totalCells
   - Measures objective concentration
```

### Difficulty Thresholds

```
Easy:
  pathLength:    20-30 steps
  corners:       5-12 turns
  emptySpaces:   180-220 cells
  cargoDensity:  0.02-0.06

Medium:
  pathLength:    35-50 steps
  corners:       12-25 turns
  emptySpaces:   160-200 cells
  cargoDensity:  0.04-0.08

Hard:
  pathLength:    50-70 steps
  corners:       25-40 turns
  emptySpaces:   140-180 cells
  cargoDensity:  0.06-0.10

Elite:
  pathLength:    70-100 steps
  corners:       40-60 turns
  emptySpaces:   120-160 cells
  cargoDensity:  0.08-0.12
```

### Scoring Function

```
scoreMetric(actual, min, max):
  if actual < min:
    return 50 - ((min - actual) / 2)
  if actual > max:
    return 50 - ((actual - max) / 2)
  if min <= actual <= max:
    return 100

Overall Fitness Score (0-100):
  (pathScore × 0.3) +
  (cornerScore × 0.3) +
  (spaceScore × 0.2) +
  (cargoScore × 0.2)
```

**Interpretation**:
- Score **80-100**: Excellent fit for difficulty
- Score **60-79**: Good fit
- Score **<60**: Poor fit (rarely occurs with current generation parameters)

---

## Anti-Cheat Verification System

### Client-Side Hashing

When a player completes the maze, the client submits:
```json
{
  "path": [{"x": 0, "y": 0}, {"x": 1, "y": 0}, ...],
  "mazeHash": "sha256_of_grid_serialization",
  "completionTime": 12500
}
```

**Maze Hash Computation**:
```dart
mazeHash = SHA256(serialize(grid))

serialize(grid):
  Convert 16×16 grid to JSON string
  Hash entire serialized grid
```

### Server-Side Replay Validation

Server receives client data and validates:

```dart
function validateClientPath(clientPath, grid, start, goal):
  // 1. Verify maze hash
  computedHash = SHA256(serialize(grid))
  if (computedHash != clientHash):
    return CHEAT_DETECTED  // Maze tampered
  
  // 2. Verify path endpoints
  if (clientPath[0] != start OR clientPath[-1] != goal):
    return INVALID_PATH
  
  // 3. Compute optimal path via BFS
  optimalPath = BFS(grid, start, goal)
  optimalLength = optimalPath.length
  clientLength = clientPath.length
  
  // 4. Calculate path efficiency
  pathEfficiency = optimalLength / clientLength
  
  // 5. Detect suspicious behavior
  if (clientLength > optimalLength × 2.5):
    return SUSPICIOUS  // Path much longer than needed
  
  return {
    valid: true,
    pathEfficiency: pathEfficiency,
    lengthDifference: clientLength - optimalLength
  }
```

**Suspicious Threshold**: `clientPathLength > optimalPathLength × 2.5`
- Flag for review if player's path is >250% longer than optimal
- Indicates possible AI assistance or map knowledge cheating

### Reporting

```json
{
  "valid": true,
  "pathEfficiency": 0.95,        // 95% as efficient as optimal
  "optimalLength": 25,
  "clientLength": 26,
  "suspicious": false,
  "lengthDifference": 1
}
```

**Scoring Integration**:
```
Base Score: 100
Efficiency Bonus: pathEfficiency × 20
Time Bonus: speedBonus(completionTime)
Final Score: min(100 + bonuses, 200)
```

---

## RNG Seeding Mechanism

### Seed Generation (Server)

For each Mind War round, server generates:

```dart
// In multiplayer backend (lobbyHandlers.js / gameHandlers.dart):

mindWarId = UUID()
baseSeed = mindWarId.replace(/-/g, '').substring(0, 16)

// Per round:
gameIndex = hashFunction(
  `${mindWarId}:round:${roundNumber}:${gameId}`
) % 1000000

seed = `${baseSeed}_${roundNumber}_${gameIndex}`

// Broadcast to all clients in payload:
{
  "roundNumber": 1,
  "gameId": "path_finder",
  "seed": seed,
  "gameIndex": gameIndex,
  "difficulty": "medium"
}
```

### Client-Side RNG Initialization (Flutter)

```dart
// In game_generator_service.dart:

generateGameState(
  gameId: 'path_finder',
  seed: seedFromPayload,           // "base_seed_1_42847"
  gameIndex: gameIndexFromPayload, // 42847
  difficulty: 'medium',
  hintPolicy: 'enabled'
) {
  return PathFinderEngine.generateBattleChallengeSet(
    battleSeed: seed,
    gameIndex: gameIndex,
    difficulty: difficulty,
    hintPolicy: hintPolicy
  );
}
```

**Key Property**: Same `seed` + `gameIndex` on all devices and on the backend → **identical sealed maze payload**.

---

## Output Format

The `generateBattleChallengeSet()` method returns:

```dart
{
  'schemaVersion': 2,
  'type': 'path_finder',
  'challengeKey': 'path_finder|base_seed_1_42847|index:42847|difficulty:medium|hint:enabled|schema:2',
  'difficulty': 'medium',
  'gridWidth': 16,
  'gridHeight': 16,
  'startCell': {'x': 0, 'y': 0},
  'goalCell': {'x': 15, 'y': 15},
  'cargoCells': [
    {'x': 6, 'y': 1},
    {'x': 12, 'y': 5},
    {'x': 8, 'y': 12}
  ],
  'wallCells': [
    {'x': 1, 'y': 0},
    {'x': 3, 'y': 0}
  ],
  'wallCount': 24,
  'cargoCount': 3,
  'optimalMoveCount': 28,
  'optimalPathCells': [
    {'x': 0, 'y': 0},
    {'x': 0, 'y': 1}
  ],
  'drawable': {
    'viewBox': {'width': 16, 'height': 16},
    'cellSize': 1,
    'walls': [...],
    'cargo': [...],
    'start': {'x': 0, 'y': 0},
    'goal': {'x': 15, 'y': 15}
  },
  'canonicalChecksum': '7f3a4e8b2c1d9f6e5a3b4c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e'
}
```

---

## Integration with Phase 2 Architecture

### Game Flow

```
1. Server generates immutable payload
   ├─ Creates gameSequence with gameIndex + seed per round
   └─ Broadcasts to all clients

2. Client receives payload
   ├─ Calls GameGeneratorService.generateGameState()
   ├─ With gameId='path_finder', seed, gameIndex
   └─ PathFinderEngine returns identical sealed challengeSet

3. Player navigates maze
   ├─ Submits a move transcript when complete
   └─ Includes challenge checksum + submission hash for verification

4. Server validates submission
   ├─ Verifies mazeHash matches expected
   ├─ Replays optimal path via BFS
   ├─ Calculates pathEfficiency
   └─ Updates score with efficiency bonus

5. Leaderboard routing
   ├─ Pure (no hints): Pure leaderboard
   ├─ Standard (hints enabled): Standard leaderboard
   └─ Assisted (hints encouraged): Assisted leaderboard
```

---

## Testing Checklist

- [ ] Same seed + gameIndex produces identical maze on multiple devices
- [ ] BFS validation correctly identifies unsolvable mazes
- [ ] Fitness scores correctly categorize mazes by difficulty
- [ ] Maze hash changes when grid is modified
- [ ] Client path validation detects suspicious path lengths
- [ ] Path efficiency bonus correctly scales scores
- [ ] Cargo box collection properly tracked
- [ ] Corner counting accurate for optimal path
- [ ] Elite difficulty creates wider corridors
- [ ] RNG sequence strictly ordered per phase

---

## Performance Notes

- **Maze Generation Time**: ~5-50ms (typical), depends on randomness
- **Memory**: Grid stored as `List<List<int>>` (~512 bytes)
- **Hash Computation**: SHA256 ~1-2ms
- **BFS Validation**: ~2-5ms for 16×16 grid

All operations happen client-side for offline capability.

---

## Future Enhancements

1. **Procedural Obstacles**: Moving walls, locked doors requiring cargo
2. **Time Limits**: Difficulty-scaled time constraints
3. **Leaderboard Variants**: Speed runs, minimal-move challenges
4. **Visual Themes**: Different maze aesthetics per theme
5. **Cooperative Mode**: Multiple players navigating same maze collaboratively
