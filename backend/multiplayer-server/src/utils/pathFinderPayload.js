const crypto = require('crypto');

const schemaVersion = 2;
const gridWidth = 16;
const gridHeight = 16;

function normalizeDifficulty(difficulty) {
  const normalized = String(difficulty || '').toLowerCase();
  return ['easy', 'medium', 'hard', 'elite'].includes(normalized) ? normalized : 'medium';
}

function configForDifficulty(difficulty) {
  if (difficulty === 'easy') {
    return { wallCount: 22, cargoCount: 2, carvePassages: 0 };
  }
  if (difficulty === 'hard') {
    return { wallCount: 40, cargoCount: 4, carvePassages: 0 };
  }
  if (difficulty === 'elite') {
    return { wallCount: 48, cargoCount: 5, carvePassages: 3 };
  }
  return { wallCount: 30, cargoCount: 3, carvePassages: 0 };
}

function stableSeed(input) {
  const source = String(input);
  let hash = 0x811c9dc5;
  for (let i = 0; i < source.length; i += 1) {
    hash ^= source.charCodeAt(i);
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

function createRandom(seed) {
  let state = seed || 1;
  return {
    nextInt(max) {
      if (max <= 0) {
        throw new Error('max must be positive');
      }
      state = (state * 1103515245 + 12345) & 0x7fffffff;
      return Math.floor((state / 0x80000000) * max);
    },
    nextBool() {
      return this.nextInt(2) === 0;
    },
  };
}

function buildBattleKey({ battleSeed, gameIndex, difficulty, hintPolicy }) {
  return `path_finder|${battleSeed}|index:${gameIndex}|difficulty:${normalizeDifficulty(difficulty)}|hint:${hintPolicy}|schema:${schemaVersion}`;
}

function pointKey(point) {
  return `${point.x}:${point.y}`;
}

function stateKey(point, cargoMask) {
  return `${point.x}:${point.y}:${cargoMask}`;
}

function pointToMap(point) {
  return { x: point.x, y: point.y };
}

function pointFromMap(map) {
  return { x: Number(map.x), y: Number(map.y) };
}

function isSamePoint(a, b) {
  return a.x === b.x && a.y === b.y;
}

function isInside(point) {
  return point.x >= 0 && point.x < gridWidth && point.y >= 0 && point.y < gridHeight;
}

function manhattanDistance(a, b) {
  return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
}

function directionOffset(move) {
  if (move === 'up') return { x: 0, y: -1 };
  if (move === 'down') return { x: 0, y: 1 };
  if (move === 'left') return { x: -1, y: 0 };
  if (move === 'right') return { x: 1, y: 0 };
  return null;
}

function bitCount(value) {
  let working = value;
  let count = 0;
  while (working > 0) {
    count += working & 1;
    working >>= 1;
  }
  return count;
}

function shuffledCells(random) {
  const cells = [];
  for (let y = 0; y < gridHeight; y += 1) {
    for (let x = 0; x < gridWidth; x += 1) {
      cells.push({ x, y });
    }
  }

  for (let i = cells.length - 1; i > 0; i -= 1) {
    const swapIndex = random.nextInt(i + 1);
    const temp = cells[i];
    cells[i] = cells[swapIndex];
    cells[swapIndex] = temp;
  }

  return cells;
}

function solveRoute({ grid, startCell, goalCell, cargoCells }) {
  const cargoIndexByKey = new Map();
  cargoCells.forEach((cell, index) => {
    cargoIndexByKey.set(pointKey(cell), index);
  });

  const targetMask = cargoCells.length === 0 ? 0 : (1 << cargoCells.length) - 1;
  const queue = [{ position: startCell, cargoMask: 0 }];
  const visited = new Set([stateKey(startCell, 0)]);
  const parent = new Map();
  const stateLookup = new Map([[stateKey(startCell, 0), { position: startCell, cargoMask: 0 }]]);
  let cursor = 0;

  while (cursor < queue.length) {
    const current = queue[cursor];
    cursor += 1;

    if (isSamePoint(current.position, goalCell) && current.cargoMask === targetMask) {
      const path = [];
      let currentKey = stateKey(current.position, current.cargoMask);
      while (true) {
        const state = stateLookup.get(currentKey);
        path.unshift(state.position);
        if (!parent.has(currentKey)) {
          break;
        }
        currentKey = parent.get(currentKey);
      }
      return { solvable: true, path };
    }

    for (const direction of [
      { x: 0, y: -1 },
      { x: 0, y: 1 },
      { x: -1, y: 0 },
      { x: 1, y: 0 },
    ]) {
      const nextPoint = {
        x: current.position.x + direction.x,
        y: current.position.y + direction.y,
      };
      if (!isInside(nextPoint) || grid[nextPoint.y][nextPoint.x] === 1) {
        continue;
      }

      let nextMask = current.cargoMask;
      if (cargoIndexByKey.has(pointKey(nextPoint))) {
        nextMask |= (1 << cargoIndexByKey.get(pointKey(nextPoint)));
      }

      const nextKey = stateKey(nextPoint, nextMask);
      if (!visited.has(nextKey)) {
        visited.add(nextKey);
        parent.set(nextKey, stateKey(current.position, current.cargoMask));
        const nextState = { position: nextPoint, cargoMask: nextMask };
        stateLookup.set(nextKey, nextState);
        queue.push(nextState);
      }
    }
  }

  return { solvable: false, path: [] };
}

function collectCells(grid, cellType) {
  const cells = [];
  for (let y = 0; y < grid.length; y += 1) {
    for (let x = 0; x < grid[y].length; x += 1) {
      if (grid[y][x] === cellType) {
        cells.push({ x, y });
      }
    }
  }
  return cells;
}

function stableSerialize(value) {
  if (value === null || value === undefined) return 'null';
  if (typeof value === 'boolean' || typeof value === 'number') return String(value);
  if (typeof value === 'string') return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(stableSerialize).join(',')}]`;
  if (typeof value === 'object') {
    const keys = Object.keys(value).sort();
    return `{${keys.map((key) => `${JSON.stringify(key)}:${stableSerialize(value[key])}`).join(',')}}`;
  }
  throw new Error(`Unsupported value for serialization: ${value}`);
}

function checksumForMap(payload) {
  return crypto.createHash('sha256').update(stableSerialize(payload)).digest('hex');
}

function generateChallengeSet({ seed, difficulty }) {
  const normalizedDifficulty = normalizeDifficulty(difficulty);
  const config = configForDifficulty(normalizedDifficulty);
  const random = createRandom(stableSeed(`path_finder|${seed}|${normalizedDifficulty}|schema:${schemaVersion}`));
  const grid = Array.from({ length: gridHeight }, () => Array(gridWidth).fill(0));

  const startCell = {
    x: random.nextInt(gridWidth / 2),
    y: random.nextInt(gridHeight / 2),
  };

  let goalCell;
  do {
    goalCell = {
      x: (gridWidth / 2) + random.nextInt(gridWidth / 2),
      y: (gridHeight / 2) + random.nextInt(gridHeight / 2),
    };
  } while (manhattanDistance(startCell, goalCell) < (gridWidth / 2));

  grid[startCell.y][startCell.x] = 2;
  grid[goalCell.y][goalCell.x] = 3;

  const cargoCells = [];
  for (const candidate of shuffledCells(random)) {
    if (cargoCells.length >= config.cargoCount) break;
    if (grid[candidate.y][candidate.x] !== 0) continue;
    if (manhattanDistance(candidate, startCell) < 3 || manhattanDistance(candidate, goalCell) < 3) {
      continue;
    }
    cargoCells.push(candidate);
    grid[candidate.y][candidate.x] = 4;
  }

  cargoCells.forEach((cell) => {
    grid[cell.y][cell.x] = 0;
  });

  const protectedCells = new Set([pointKey(startCell), pointKey(goalCell), ...cargoCells.map(pointKey)]);
  let wallsPlaced = 0;
  for (const candidate of shuffledCells(random)) {
    if (wallsPlaced >= config.wallCount) break;
    if (grid[candidate.y][candidate.x] !== 0 || protectedCells.has(pointKey(candidate))) continue;

    grid[candidate.y][candidate.x] = 1;
    const solution = solveRoute({ grid, startCell, goalCell, cargoCells });
    if (solution.solvable) {
      wallsPlaced += 1;
    } else {
      grid[candidate.y][candidate.x] = 0;
    }
  }

  for (let index = 0; index < config.carvePassages; index += 1) {
    const origin = {
      x: 2 + random.nextInt(gridWidth - 4),
      y: 2 + random.nextInt(gridHeight - 4),
    };
    const isHorizontal = random.nextBool();
    const length = 3 + random.nextInt(4);

    for (let delta = 0; delta < length; delta += 1) {
      const point = {
        x: isHorizontal ? origin.x + delta : origin.x,
        y: isHorizontal ? origin.y : origin.y + delta,
      };
      if (!isInside(point) || protectedCells.has(pointKey(point))) continue;
      grid[point.y][point.x] = 0;
    }
  }

  const wallCells = collectCells(grid, 1);
  const solution = solveRoute({ grid, startCell, goalCell, cargoCells });
  if (!solution.solvable) {
    throw new Error('Path Finder challenge generation failed to produce a solvable maze');
  }

  const challengeSet = {
    schemaVersion,
    type: 'path_finder',
    challengeKey: seed,
    difficulty: normalizedDifficulty,
    gridWidth,
    gridHeight,
    startCell: pointToMap(startCell),
    goalCell: pointToMap(goalCell),
    cargoCells: cargoCells.map(pointToMap),
    wallCells: wallCells.map(pointToMap),
    cargoCount: cargoCells.length,
    wallCount: wallCells.length,
    optimalMoveCount: Math.max(0, solution.path.length - 1),
    optimalPathCells: solution.path.map(pointToMap),
    drawable: {
      viewBox: { width: gridWidth, height: gridHeight },
      cellSize: 1,
      walls: wallCells.map(pointToMap),
      cargo: cargoCells.map(pointToMap),
      start: pointToMap(startCell),
      goal: pointToMap(goalCell),
    },
  };

  return {
    ...challengeSet,
    canonicalChecksum: checksumForMap(challengeSet),
  };
}

function generateBattleChallengeSet({ battleSeed, gameIndex, difficulty, hintPolicy }) {
  const challengeKey = buildBattleKey({
    battleSeed,
    gameIndex,
    difficulty,
    hintPolicy,
  });

  return {
    ...generateChallengeSet({
      seed: challengeKey,
      difficulty,
    }),
    battleSeed,
    gameIndex,
    hintPolicy,
  };
}

function replaySubmission({ challengeSet, moves }) {
  const startCell = pointFromMap(challengeSet.startCell);
  const goalCell = pointFromMap(challengeSet.goalCell);
  const wallCells = new Set((challengeSet.wallCells || []).map((cell) => pointKey(pointFromMap(cell))));
  const cargoCells = (challengeSet.cargoCells || []).map((cell) => pointFromMap(cell));
  const cargoIndexByKey = new Map();
  cargoCells.forEach((cell, index) => {
    cargoIndexByKey.set(pointKey(cell), index);
  });

  let player = startCell;
  let invalidMove = false;
  let collectedMask = 0;
  const visitedCells = [pointToMap(startCell)];

  for (const move of moves) {
    const direction = directionOffset(move);
    if (!direction) {
      invalidMove = true;
      break;
    }

    const next = {
      x: player.x + direction.x,
      y: player.y + direction.y,
    };

    if (!isInside(next) || wallCells.has(pointKey(next))) {
      invalidMove = true;
      break;
    }

    player = next;
    if (cargoIndexByKey.has(pointKey(player))) {
      collectedMask |= (1 << cargoIndexByKey.get(pointKey(player)));
    }
    visitedCells.push(pointToMap(player));
  }

  const allCargoCollectedMask = cargoCells.length === 0 ? 0 : (1 << cargoCells.length) - 1;
  const completed = !invalidMove && collectedMask === allCargoCollectedMask && isSamePoint(player, goalCell);

  return {
    finalCell: pointToMap(player),
    visitedCells,
    moveCount: moves.length,
    collectedCargoCount: bitCount(collectedMask),
    cargoMask: collectedMask,
    completed,
    invalidMove,
  };
}

function computeScore({ challengeSet, replay, hintsUsed = 0 }) {
  const optimalMoveCount = Number(challengeSet.optimalMoveCount || 0);
  const moveCount = Number(replay.moveCount || 0);
  const cargoCount = Number(challengeSet.cargoCount || 0);

  if (!replay.completed) {
    return 0;
  }

  const overflowMoves = Math.max(0, moveCount - optimalMoveCount);
  const baseScore = 120 + (cargoCount * 10);
  return Math.max(25, baseScore - (overflowMoves * 2) - (hintsUsed * 8));
}

function computeSubmissionHash(submission) {
  return checksumForMap(submission);
}

function buildSubmissionPayload({ challengeSet, moves, totalTimeMs, hintsUsed = 0 }) {
  const replay = replaySubmission({ challengeSet, moves });
  const optimalMoveCount = Number(challengeSet.optimalMoveCount || 0);
  const score = computeScore({ challengeSet, replay, hintsUsed });

  const payload = {
    challengeKey: challengeSet.challengeKey,
    challengeChecksum: challengeSet.canonicalChecksum,
    moveCount: moves.length,
    moves,
    finalCell: replay.finalCell,
    collectedCargoCount: replay.collectedCargoCount,
    completed: replay.completed,
    invalidMove: replay.invalidMove,
    totalTimeMs,
    hintsUsed,
    score,
    perfect: replay.completed && hintsUsed === 0 && moves.length === optimalMoveCount,
  };

  return {
    ...payload,
    submissionHash: computeSubmissionHash(payload),
  };
}

function verifySubmission({ challengeSet, submission }) {
  if (!challengeSet || !submission) {
    return { valid: false, error: 'Path Finder verification requires challengeSet and submission' };
  }

  const expectedChallengeChecksum = challengeSet.canonicalChecksum;
  if (submission.challengeChecksum !== expectedChallengeChecksum) {
    return { valid: false, error: 'Challenge checksum mismatch' };
  }

  const receivedHash = submission.submissionHash;
  const payloadForHash = { ...submission };
  delete payloadForHash.submissionHash;
  if (computeSubmissionHash(payloadForHash) !== receivedHash) {
    return { valid: false, error: 'Submission hash mismatch' };
  }

  if (!Array.isArray(submission.moves)) {
    return { valid: false, error: 'Move transcript is missing' };
  }

  const replay = replaySubmission({
    challengeSet,
    moves: submission.moves,
  });

  if (submission.invalidMove !== replay.invalidMove) {
    return { valid: false, error: 'Invalid move flag mismatch' };
  }

  if (submission.completed !== replay.completed) {
    return { valid: false, error: 'Completion state mismatch' };
  }

  if (submission.moveCount !== replay.moveCount) {
    return { valid: false, error: 'Move count mismatch' };
  }

  if (submission.collectedCargoCount !== replay.collectedCargoCount) {
    return { valid: false, error: 'Collected cargo count mismatch' };
  }

  const finalCell = submission.finalCell || {};
  if (Number(finalCell.x) !== replay.finalCell.x || Number(finalCell.y) !== replay.finalCell.y) {
    return { valid: false, error: 'Final cell mismatch' };
  }

  const validatedScore = computeScore({
    challengeSet,
    replay,
    hintsUsed: Number(submission.hintsUsed || 0),
  });
  const optimalMoveCount = Number(challengeSet.optimalMoveCount || 0);
  const perfect = replay.completed &&
    Number(submission.hintsUsed || 0) === 0 &&
    replay.moveCount === optimalMoveCount;

  return {
    valid: true,
    replay,
    validatedScore,
    totalTimeMs: Number(submission.totalTimeMs || 0),
    hintsUsed: Number(submission.hintsUsed || 0),
    perfect,
  };
}

module.exports = {
  schemaVersion,
  gridWidth,
  gridHeight,
  buildBattleKey,
  generateChallengeSet,
  generateBattleChallengeSet,
  replaySubmission,
  computeScore,
  buildSubmissionPayload,
  computeSubmissionHash,
  verifySubmission,
};
