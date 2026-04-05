const payload = require('../../src/utils/rotationMasterPayload');

describe('rotationMasterPayload', () => {
  test('generates identical battle challenge sets for the same inputs', () => {
    const first = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 12,
      difficulty: 'hard',
      hintPolicy: 'disabled',
    });
    const second = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 12,
      difficulty: 'hard',
      hintPolicy: 'disabled',
    });

    expect(first).toEqual(second);
    expect(first.challengeKey).toContain('index:12');
    expect(first.canonicalChecksum).toHaveLength(64);
  });

  test('prompt payload stores explicit discrete primitives', () => {
    const challengeSet = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 3,
      difficulty: 'medium',
      hintPolicy: 'enabled',
    });

    const prompt = challengeSet.prompts[0];
    expect(typeof prompt.shapeIndex).toBe('number');
    expect(Array.isArray(prompt.targetRotationSteps)).toBe(true);
    expect(Array.isArray(prompt.answerOrder)).toBe(true);
    expect(typeof prompt.correctOptionIndex).toBe('number');
    expect(typeof prompt.canonicalChecksum).toBe('string');
    expect(Array.isArray(prompt.target.segments)).toBe(true);
    expect(Array.isArray(prompt.target.segments[0])).toBe(true);
  });

  test('submission verification accepts canonical valid transcript', () => {
    const challengeSet = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 8,
      difficulty: 'easy',
      hintPolicy: 'disabled',
    });

    let score = 0;
    let streak = 0;
    const responses = challengeSet.prompts.map((prompt, roundIndex) => {
      streak += 1;
      score += 12 + (streak * 3) + prompt.dimension;
      return {
        roundIndex,
        promptChecksum: prompt.canonicalChecksum,
        selectedOptionIndex: prompt.correctOptionIndex,
        correctOptionIndex: prompt.correctOptionIndex,
        isCorrect: true,
        responseTimeMs: 1200 + (roundIndex * 10),
      };
    });

    const submission = {
      challengeKey: challengeSet.challengeKey,
      challengeChecksum: challengeSet.canonicalChecksum,
      promptCount: challengeSet.promptCount,
      responses,
      totalTimeMs: 9000,
      score,
      hintsUsed: 0,
      perfect: true,
    };
    submission.submissionHash = payload.computeSubmissionHash(submission);

    const verification = payload.verifySubmission({
      challengeSet,
      submission,
    });

    expect(verification.valid).toBe(true);
    expect(verification.validatedScore).toBe(score);
    expect(verification.perfect).toBe(true);
  });

  test('submission verification rejects tampered hashes', () => {
    const challengeSet = payload.generateBattleChallengeSet({
      battleSeed: 'battle-seed',
      gameIndex: 8,
      difficulty: 'easy',
      hintPolicy: 'disabled',
    });

    const prompt = challengeSet.prompts[0];
    const submission = {
      challengeKey: challengeSet.challengeKey,
      challengeChecksum: challengeSet.canonicalChecksum,
      promptCount: challengeSet.promptCount,
      responses: [
        {
          roundIndex: 0,
          promptChecksum: prompt.canonicalChecksum,
          selectedOptionIndex: prompt.correctOptionIndex,
          correctOptionIndex: prompt.correctOptionIndex,
          isCorrect: true,
          responseTimeMs: 1000,
        },
      ],
      totalTimeMs: 1000,
      score: 17,
      hintsUsed: 0,
      perfect: false,
      submissionHash: 'tampered',
    };

    const verification = payload.verifySubmission({
      challengeSet,
      submission,
    });

    expect(verification.valid).toBe(false);
    expect(verification.error).toMatch(/hash mismatch|count mismatch/i);
  });
});
