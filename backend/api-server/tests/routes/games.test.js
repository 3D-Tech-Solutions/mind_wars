const {
  normalizeGameSubmission,
  calculateValidatedScore
} = require('../../src/routes/games');

describe('games route scoring helpers', () => {
  test('normalizes nested gameData submissions from the client API service', () => {
    const submission = normalizeGameSubmission('vocabulary-showdown', {
      lobbyId: '13f0e6a6-fd35-4d97-bd64-2fa8dc0ad275',
      gameData: {
        timeTaken: 32000,
        hintsUsed: 1,
        wrongAnswers: 3,
        perfect: false
      }
    });

    expect(submission.lobbyId).toBe('13f0e6a6-fd35-4d97-bd64-2fa8dc0ad275');
    expect(submission.timeTaken).toBe(32000);
    expect(submission.hintsUsed).toBe(1);
    expect(submission.wrongAnswers).toBe(3);
    expect(submission.perfect).toBe(false);
  });

  test('ignores an inflated client score and recalculates a default timed score on the server', () => {
    const validatedScore = calculateValidatedScore({
      gameId: 'sudoku-duel',
      submittedScore: 999999,
      timeTaken: 20000,
      hintsUsed: 0,
      perfect: true,
      wrongAnswers: 0
    });

    expect(validatedScore).toBe(105);
  });

  test('applies vocabulary showdown wrong-answer penalties server-side', () => {
    const validatedScore = calculateValidatedScore({
      gameId: 'vocabulary-showdown',
      timeTaken: 10000,
      hintsUsed: 0,
      wrongAnswers: 4,
      perfect: false
    });

    expect(validatedScore).toBe(92);
  });

  test('uses guesses instead of client score for code-breaker submissions', () => {
    const validatedScore = calculateValidatedScore({
      gameId: 'code-breaker',
      timeTaken: 0,
      guesses: 5,
      solved: true
    });

    expect(validatedScore).toBe(55);
  });

  test('uses pairs and streak multiplier for memory-match submissions', () => {
    const validatedScore = calculateValidatedScore({
      gameId: 'memory-match',
      pairsFound: 7,
      streakMultiplier: 2
    });

    expect(validatedScore).toBe(14);
  });
});
