const payload = require('../../src/utils/pathFinderPayload');

function movesFromPath(path) {
  const moves = [];
  for (let i = 1; i < path.length; i += 1) {
    const previous = path[i - 1];
    const current = path[i];
    const dx = current.x - previous.x;
    const dy = current.y - previous.y;
    if (dx === 1) moves.push('right');
    else if (dx === -1) moves.push('left');
    else if (dy === 1) moves.push('down');
    else if (dy === -1) moves.push('up');
  }
  return moves;
}

describe('pathFinderPayload', () => {
  test('generates identical battle challenge sets for the same inputs', () => {
    const first = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 5,
      difficulty: 'hard',
      hintPolicy: 'disabled',
    });
    const second = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 5,
      difficulty: 'hard',
      hintPolicy: 'disabled',
    });

    expect(first).toEqual(second);
    expect(first.challengeKey).toContain('index:5');
    expect(first.canonicalChecksum).toHaveLength(64);
  });

  test('challenge payload stores explicit discrete maze primitives', () => {
    const challengeSet = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 11,
      difficulty: 'medium',
      hintPolicy: 'enabled',
    });

    expect(typeof challengeSet.gridWidth).toBe('number');
    expect(typeof challengeSet.gridHeight).toBe('number');
    expect(Array.isArray(challengeSet.wallCells)).toBe(true);
    expect(Array.isArray(challengeSet.cargoCells)).toBe(true);
    expect(Array.isArray(challengeSet.optimalPathCells)).toBe(true);
    expect(challengeSet.wallCells.length).toBeGreaterThan(0);
    expect(challengeSet.optimalMoveCount).toBeGreaterThan(0);
    expect(challengeSet.drawable.walls).toEqual(challengeSet.wallCells);
  });

  test('submission verification accepts canonical valid transcript', () => {
    const challengeSet = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 8,
      difficulty: 'easy',
      hintPolicy: 'disabled',
    });

    const submission = payload.buildSubmissionPayload({
      challengeSet,
      moves: movesFromPath(challengeSet.optimalPathCells),
      totalTimeMs: 12000,
    });

    const verification = payload.verifySubmission({
      challengeSet,
      submission,
    });

    expect(verification.valid).toBe(true);
    expect(verification.validatedScore).toBe(submission.score);
    expect(verification.perfect).toBe(true);
  });

  test('submission verification rejects tampered hashes', () => {
    const challengeSet = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 8,
      difficulty: 'easy',
      hintPolicy: 'disabled',
    });

    const submission = payload.buildSubmissionPayload({
      challengeSet,
      moves: movesFromPath(challengeSet.optimalPathCells),
      totalTimeMs: 12000,
    });
    submission.submissionHash = 'tampered';

    const verification = payload.verifySubmission({
      challengeSet,
      submission,
    });

    expect(verification.valid).toBe(false);
    expect(verification.error).toMatch(/hash mismatch/i);
  });
});
