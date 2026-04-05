const crypto = require('crypto');

const schemaVersion = 2;

const easyShapes = [
  { family: 'polyomino_2d', dimensions: 2, cells: [[0, 0], [1, 0], [2, 0], [0, 1], [0, 2]] },
  { family: 'polyomino_2d', dimensions: 2, cells: [[0, 0], [1, 0], [1, 1], [2, 1], [1, 2]] },
  { family: 'polyomino_2d', dimensions: 2, cells: [[0, 0], [1, 0], [2, 0], [2, 1], [3, 1]] },
  { family: 'polyomino_2d', dimensions: 2, cells: [[0, 0], [0, 1], [1, 1], [2, 1], [2, 2]] },
];

const mediumShapes = [
  { family: 'shepard_3d', dimensions: 3, cells: [[0, 0, 0], [1, 0, 0], [2, 0, 0], [2, 1, 0], [2, 1, 1]] },
  { family: 'shepard_3d', dimensions: 3, cells: [[0, 0, 0], [1, 0, 0], [1, 1, 0], [1, 1, 1], [2, 1, 1]] },
  { family: 'shepard_3d', dimensions: 3, cells: [[0, 0, 0], [0, 1, 0], [1, 1, 0], [1, 1, 1], [1, 2, 1]] },
  { family: 'shepard_3d', dimensions: 3, cells: [[0, 0, 0], [1, 0, 0], [1, 0, 1], [1, 1, 1], [2, 1, 1]] },
];

const hardShapes = [
  { family: 'embedded_3d', dimensions: 3, cells: [[0, 0, 0], [1, 0, 0], [2, 0, 0], [1, 1, 0], [1, 1, 1], [1, 2, 1]] },
  { family: 'embedded_3d', dimensions: 3, cells: [[0, 0, 0], [1, 0, 0], [1, 1, 0], [1, 1, 1], [2, 1, 1], [2, 2, 1]] },
  { family: 'hypercube_4d', dimensions: 4, cells: [[0, 0, 0, 0], [1, 0, 0, 0], [1, 1, 0, 0], [1, 1, 1, 0], [1, 1, 1, 1]] },
  { family: 'hypercube_4d', dimensions: 4, cells: [[0, 0, 0, 0], [0, 1, 0, 0], [1, 1, 0, 0], [1, 1, 1, 0], [1, 1, 1, 1]] },
];

function normalizeDifficulty(difficulty) {
  const normalized = String(difficulty || '').toLowerCase();
  return ['easy', 'medium', 'hard'].includes(normalized) ? normalized : 'medium';
}

function defaultPromptCount(difficulty) {
  if (difficulty === 'easy') return 5;
  if (difficulty === 'hard') return 10;
  return 8;
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

function buildBattleKey({ battleSeed, gameIndex, difficulty, hintPolicy }) {
  return `rotation_master|${battleSeed}|index:${gameIndex}|difficulty:${normalizeDifficulty(difficulty)}|hint:${hintPolicy}|schema:${schemaVersion}`;
}

function configForDifficulty(difficulty) {
  if (difficulty === 'easy') {
    return {
      colorProfile: 'vivid',
      targetStepCount: 1,
      optionStepCount: 1,
      allowedPlanes: [[0, 1]],
      shapes: easyShapes,
    };
  }
  if (difficulty === 'hard') {
    return {
      colorProfile: 'mono',
      targetStepCount: 3,
      optionStepCount: 2,
      allowedPlanes: [[0, 1], [0, 2], [1, 2], [0, 3], [1, 3], [2, 3]],
      shapes: hardShapes,
    };
  }
  return {
    colorProfile: 'mono',
    targetStepCount: 1,
    optionStepCount: 1,
    allowedPlanes: [[0, 2], [1, 2]],
    shapes: mediumShapes,
  };
}

function createRandom(seed) {
  let state = stableSeed(seed) || 1;
  return () => {
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    return state / 0x80000000;
  };
}

function nextInt(rng, max) {
  return Math.floor(rng() * max);
}

function shuffledOrder(rng, length) {
  const order = Array.from({ length }, (_, index) => index);
  for (let i = order.length - 1; i > 0; i -= 1) {
    const swapIndex = nextInt(rng, i + 1);
    const temp = order[i];
    order[i] = order[swapIndex];
    order[swapIndex] = temp;
  }
  return order;
}

function buildRotationSteps({ rng, dimensions, stepCount, allowedPlanes }) {
  const validPlanes = allowedPlanes.filter((plane) => plane[0] < dimensions && plane[1] < dimensions);
  return Array.from({ length: stepCount }, () => {
    const plane = validPlanes[nextInt(rng, validPlanes.length)];
    return {
      plane,
      quarterTurns: nextInt(rng, 3) + 1,
    };
  });
}

function centerCells(cells, dimensions) {
  const mins = Array(dimensions).fill(Number.MAX_SAFE_INTEGER);
  const maxs = Array(dimensions).fill(Number.MIN_SAFE_INTEGER);

  cells.forEach((cell) => {
    for (let axis = 0; axis < dimensions; axis += 1) {
      mins[axis] = Math.min(mins[axis], cell[axis]);
      maxs[axis] = Math.max(maxs[axis], cell[axis]);
    }
  });

  return cells.map((cell) =>
    Array.from({ length: dimensions }, (_, axis) => (cell[axis] * 2) - mins[axis] - maxs[axis]));
}

function cellVertices(cellCenter, dimensions) {
  const vertexCount = 1 << dimensions;
  return Array.from({ length: vertexCount }, (_, index) =>
    Array.from({ length: dimensions }, (_, axis) => {
      const sign = ((index >> axis) & 1) === 0 ? -1 : 1;
      return (cellCenter[axis] * 2) + sign;
    }));
}

function edgePairs(dimensions) {
  const pairs = [];
  const vertexCount = 1 << dimensions;
  for (let index = 0; index < vertexCount; index += 1) {
    for (let axis = 0; axis < dimensions; axis += 1) {
      const neighbor = index ^ (1 << axis);
      if (index < neighbor) {
        pairs.push([index, neighbor]);
      }
    }
  }
  return pairs;
}

function applyTransforms({ point, rotationSteps, mirrorAxis }) {
  const transformed = [...point];
  if (mirrorAxis !== null && mirrorAxis !== undefined && mirrorAxis < transformed.length) {
    transformed[mirrorAxis] = -transformed[mirrorAxis];
  }

  rotationSteps.forEach((step) => {
    const [axisA, axisB] = step.plane;
    const turns = step.quarterTurns % 4;
    for (let i = 0; i < turns; i += 1) {
      const a = transformed[axisA];
      const b = transformed[axisB];
      transformed[axisA] = -b;
      transformed[axisB] = a;
    }
  });

  return transformed;
}

function projectPoint(point) {
  if (point.length === 2) {
    return [point[0] * 4, point[1] * 4];
  }
  if (point.length === 3) {
    return [
      (point[0] * 4) - (point[1] * 2),
      (point[2] * 4) + (point[1] * 2),
    ];
  }

  const x3 = (point[0] * 4) + (point[3] * 2);
  const y3 = (point[1] * 4) - (point[3] * 2);
  const z3 = point[2] * 4;
  return [
    (x3 * 2) - y3,
    (z3 * 2) + y3,
  ];
}

function comparePoints(a, b) {
  if (a[0] !== b[0]) return a[0] - b[0];
  return a[1] - b[1];
}

function normalizeSegment(start, end) {
  return comparePoints(start, end) <= 0
    ? [start[0], start[1], end[0], end[1]]
    : [end[0], end[1], start[0], start[1]];
}

function compareSegments(a, b) {
  for (let i = 0; i < 4; i += 1) {
    if (a[i] !== b[i]) return a[i] - b[i];
  }
  return 0;
}

function buildSegments({ cells, dimensions, rotationSteps, mirrorAxis }) {
  const centeredCells = centerCells(cells, dimensions);
  const segments = [];

  centeredCells.forEach((cell) => {
    const vertices = cellVertices(cell, dimensions);
    const transformedVertices = vertices.map((vertex) =>
      applyTransforms({ point: vertex, rotationSteps, mirrorAxis }));

    edgePairs(dimensions).forEach(([startIndex, endIndex]) => {
      const start = projectPoint(transformedVertices[startIndex]);
      const end = projectPoint(transformedVertices[endIndex]);
      segments.push(normalizeSegment(start, end));
    });
  });

  segments.sort(compareSegments);

  let minX = Number.MAX_SAFE_INTEGER;
  let minY = Number.MAX_SAFE_INTEGER;
  let maxX = Number.MIN_SAFE_INTEGER;
  let maxY = Number.MIN_SAFE_INTEGER;

  segments.forEach((segment) => {
    minX = Math.min(minX, segment[0], segment[2]);
    minY = Math.min(minY, segment[1], segment[3]);
    maxX = Math.max(maxX, segment[0], segment[2]);
    maxY = Math.max(maxY, segment[1], segment[3]);
  });

  return {
    segments: segments.map((segment) => [
      segment[0] - minX,
      segment[1] - minY,
      segment[2] - minX,
      segment[3] - minY,
    ]),
    viewBox: {
      width: Math.max(1, maxX - minX),
      height: Math.max(1, maxY - minY),
    },
  };
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
  return JSON.stringify(String(value));
}

function checksumForMap(map) {
  return crypto.createHash('sha256').update(stableSerialize(map)).digest('hex');
}

function generatePrompt({ seed, difficulty, roundIndex }) {
  const normalizedDifficulty = normalizeDifficulty(difficulty);
  const rng = createRandom(`rotation_master|${seed}|${normalizedDifficulty}|${roundIndex}`);
  const config = configForDifficulty(normalizedDifficulty);
  const shapeIndex = nextInt(rng, config.shapes.length);
  const shape = config.shapes[shapeIndex];
  const answerOrder = shuffledOrder(rng, 4);
  const correctOptionIndex = answerOrder.indexOf(0);
  const targetRotationSteps = buildRotationSteps({
    rng,
    dimensions: shape.dimensions,
    stepCount: config.targetStepCount,
    allowedPlanes: config.allowedPlanes,
  });

  const target = buildSegments({
    cells: shape.cells,
    dimensions: shape.dimensions,
    rotationSteps: targetRotationSteps,
    mirrorAxis: null,
  });

  const distractorMirrorAxes = Array.from({ length: 3 }, (_, index) => index % shape.dimensions);
  const optionBlueprints = [
    { optionId: 'correct', kind: 'correct', mirrorAxis: null },
    ...distractorMirrorAxes.map((axis, index) => ({
      optionId: `mirror_${index}`,
      kind: 'mirror',
      mirrorAxis: axis,
    })),
  ];

  const options = answerOrder.map((blueprintIndex) => {
    const blueprint = optionBlueprints[blueprintIndex];
    const rotationSteps = buildRotationSteps({
      rng,
      dimensions: shape.dimensions,
      stepCount: config.optionStepCount,
      allowedPlanes: config.allowedPlanes,
    });
    const geometry = buildSegments({
      cells: shape.cells,
      dimensions: shape.dimensions,
      rotationSteps,
      mirrorAxis: blueprint.mirrorAxis,
    });

    return {
      optionId: blueprint.optionId,
      kind: blueprint.kind,
      mirrorAxis: blueprint.mirrorAxis,
      rotationSteps,
      segments: geometry.segments,
      viewBox: geometry.viewBox,
    };
  });

  const prompt = {
    roundIndex,
    mode: 'single_choice',
    family: shape.family,
    dimension: shape.dimensions,
    shapeIndex,
    colorProfile: config.colorProfile,
    targetRotationSteps,
    mirrorAxis: distractorMirrorAxes[0],
    answerOrder,
    correctOptionIndex,
    correctIndices: [correctOptionIndex],
    baseCells: shape.cells,
    target,
    options,
  };

  return {
    ...prompt,
    canonicalChecksum: checksumForMap(prompt),
  };
}

function generateChallengeSet({ seed, difficulty, promptCount }) {
  const normalizedDifficulty = normalizeDifficulty(difficulty);
  const count = promptCount || defaultPromptCount(normalizedDifficulty);
  const prompts = Array.from({ length: count }, (_, index) =>
    generatePrompt({ seed, difficulty: normalizedDifficulty, roundIndex: index }));

  const challengeSet = {
    schemaVersion,
    type: 'rotation_master',
    challengeKey: seed,
    difficulty: normalizedDifficulty,
    promptCount: count,
    prompts,
  };

  return {
    ...challengeSet,
    canonicalChecksum: checksumForMap(challengeSet),
  };
}

function generateBattleChallengeSet({ battleSeed, gameIndex, difficulty, hintPolicy, promptCount }) {
  const challengeKey = buildBattleKey({ battleSeed, gameIndex, difficulty, hintPolicy });
  return {
    ...generateChallengeSet({ seed: challengeKey, difficulty, promptCount }),
    battleSeed,
    gameIndex,
    hintPolicy,
  };
}

function computeSubmissionHash(submission) {
  return checksumForMap(submission);
}

function verifySubmission({ challengeSet, submission }) {
  if (!challengeSet || !submission) {
    return { valid: false, error: 'Missing challenge set or submission' };
  }

  const expectedChallengeChecksum = challengeSet.canonicalChecksum;
  if (submission.challengeChecksum !== expectedChallengeChecksum) {
    return { valid: false, error: 'Challenge checksum mismatch' };
  }

  const expectedSubmissionHash = computeSubmissionHash({
    challengeKey: submission.challengeKey,
    challengeChecksum: submission.challengeChecksum,
    promptCount: submission.promptCount,
    responses: submission.responses,
    totalTimeMs: submission.totalTimeMs,
    score: submission.score,
    hintsUsed: submission.hintsUsed,
    perfect: submission.perfect,
  });

  if (submission.submissionHash !== expectedSubmissionHash) {
    return { valid: false, error: 'Submission hash mismatch' };
  }

  if (!Array.isArray(submission.responses) || submission.responses.length !== challengeSet.promptCount) {
    return { valid: false, error: 'Prompt response count mismatch' };
  }

  let correctAnswers = 0;
  let streak = 0;
  let validatedScore = 0;

  for (let i = 0; i < challengeSet.prompts.length; i += 1) {
    const prompt = challengeSet.prompts[i];
    const response = submission.responses.find((item) => item.roundIndex === i);
    if (!response) {
      return { valid: false, error: `Missing response for prompt ${i}` };
    }
    if (response.promptChecksum !== prompt.canonicalChecksum) {
      return { valid: false, error: `Prompt checksum mismatch for prompt ${i}` };
    }

    const isCorrect = response.selectedOptionIndex === prompt.correctOptionIndex;
    if (Boolean(response.isCorrect) !== isCorrect) {
      return { valid: false, error: `Client correctness mismatch for prompt ${i}` };
    }

    if (isCorrect) {
      streak += 1;
      correctAnswers += 1;
      validatedScore += 12 + (streak * 3) + prompt.dimension;
    } else {
      streak = 0;
    }
  }

  return {
    valid: true,
    validatedScore,
    correctAnswers,
    perfect: correctAnswers === challengeSet.promptCount,
    totalTimeMs: Number(submission.totalTimeMs) || 0,
    hintsUsed: Number(submission.hintsUsed) || 0,
  };
}

module.exports = {
  schemaVersion,
  buildBattleKey,
  generatePrompt,
  generateChallengeSet,
  generateBattleChallengeSet,
  computeSubmissionHash,
  verifySubmission,
};
