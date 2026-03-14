const express = require('express');
const { body, validationResult } = require('express-validator');
const { query, transaction } = require('../utils/database');
const { AppError } = require('../middleware/errorHandler');
const { authenticate } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');

const router = express.Router();

router.use(authenticate);
router.use(standardLimiter);

// [2026-03-13 Bugfix] Normalize incoming submissions so the backend can derive
// authoritative scores from raw gameplay data even when clients send nested
// `gameData` payloads.
function normalizeGameSubmission(gameId, requestBody = {}) {
  const source = requestBody.gameData && typeof requestBody.gameData === 'object'
    ? requestBody.gameData
    : requestBody;

  const parseNumericOrDefault = (value, fallback = 0) => {
    const number = Number(value);
    return Number.isFinite(number) ? number : fallback;
  };

  // [2026-03-14 Security] Strictly parse boolean flags to avoid treating
  // truthy strings like "false" as true, which could incorrectly award
  // perfect bonuses or other score-related advantages.
  const parseBooleanFlag = (value) => {
    if (typeof value === 'boolean') {
      return value;
    }
    if (typeof value === 'string') {
      const normalized = value.trim().toLowerCase();
      if (normalized === 'true') {
        return true;
      }
      if (normalized === 'false') {
        return false;
      }
    }
    // For any other type or unexpected string, default to false so we only
    // apply bonuses when the client explicitly indicates a true value.
    return false;
  };

  const perfectRaw = source.perfect ?? requestBody.perfect;

  return {
    gameId,
    lobbyId: requestBody.lobbyId,
    // [2026-03-13 Integration] Preserve the client-provided score separately
    // for debugging/telemetry while still deriving the authoritative score from
    // gameplay metrics below.
    submittedScore: parseNumericOrDefault(requestBody.score, null),
    timeTaken: parseNumericOrDefault(source.timeTaken ?? requestBody.timeTaken, 0),
    hintsUsed: parseNumericOrDefault(source.hintsUsed ?? requestBody.hintsUsed, 0),
    perfect: parseBooleanFlag(perfectRaw),
    wrongAnswers: parseNumericOrDefault(source.wrongAnswers ?? requestBody.wrongAnswers, 0),
    guesses: parseNumericOrDefault(source.guesses ?? requestBody.guesses, 0),
    pairsFound: parseNumericOrDefault(source.pairsFound ?? requestBody.pairsFound, 0),
    streakMultiplier: parseNumericOrDefault(source.streakMultiplier ?? requestBody.streakMultiplier, 1),
    totalLetters: parseNumericOrDefault(source.totalLetters ?? requestBody.totalLetters, 0),
    uniqueWords: parseNumericOrDefault(source.uniqueWords ?? requestBody.uniqueWords, 0),
    solved: source.solved ?? requestBody.solved,
    completed: source.completed ?? requestBody.completed,
  };
}

// [2026-03-13 Security] Calculate scores exclusively from gameplay metrics on
// the server. Client-reported score fields are ignored except for debugging.
function calculateValidatedScore(submission) {
  // [2026-03-14 Security] Clamp numeric gameplay metrics to sane ranges
  // before scoring so clients cannot send negative values to reduce
  // penalties or otherwise manipulate server-authoritative scores.
  const timeTakenMs = Math.max(0, Math.floor(submission.timeTaken));
  const secondsElapsed = Math.floor(timeTakenMs / 1000);
  const hintsUsed = Math.max(0, Math.floor(submission.hintsUsed));
  const wrongAnswers = Math.max(0, Math.floor(submission.wrongAnswers));
  const guesses = Math.max(0, Math.floor(submission.guesses));
  const pairsFound = Math.max(0, Math.floor(submission.pairsFound));
  const streakMultiplier = Math.max(1, Math.floor(submission.streakMultiplier || 1));
  const totalLetters = Math.max(0, Math.floor(submission.totalLetters));
  const uniqueWords = Math.max(0, Math.floor(submission.uniqueWords));

  const baseTimedScore = Math.max(0, 90 - secondsElapsed);
  const noHintBonus = hintsUsed === 0 ? 20 : 0;
  const perfectBonus = submission.perfect ? 15 : 0;
  const hintPenalty = hintsUsed * 5;
  const wrongAnswerPenalty = wrongAnswers * 2;

  switch (submission.gameId) {
    case 'memory-match':
      // [2026-03-13 Feature] Memory Match score follows server-side pairs found
      // and streak multiplier rather than any client-reported total.
      const validStreakMultiplier = streakMultiplier;
      return Math.max(0, Math.round(pairsFound * validStreakMultiplier));
    case 'code-breaker': {
      const solved = submission.solved !== false && submission.completed !== false;
      if (!solved || guesses > 10) {
        return 0;
      }
      return Math.max(0, 90 - (10 * guesses) + (guesses <= 6 ? 15 : 0));
    }
    case 'anagram-attack':
    case 'word-builder':
      return Math.max(0, totalLetters + (uniqueWords * 5) - hintPenalty);
    case 'vocabulary-showdown':
      return Math.max(0, baseTimedScore + noHintBonus - wrongAnswerPenalty);
    default:
      return Math.max(0, baseTimedScore + noHintBonus + perfectBonus - hintPenalty - wrongAnswerPenalty);
  }
}

/// [2026-03-14 Security] Validate that required gameplay metrics are present
/// 
/// Ensures that critical gameplay metrics used for server-side scoring are
/// explicitly provided by the client, either at the top level of the request
/// body or within the `gameData` object. This prevents missing metrics from
/// being silently defaulted to `0` in `normalizeGameSubmission`, which could
/// otherwise allow players to omit fields like `timeTaken`/`hintsUsed` and
/// receive inflated scores (e.g., 0ms completion and 0 hints used).
///
/// The mapping below can be extended per game. By default, all games require
/// `timeTaken` and `hintsUsed`, and some games may require additional fields.
function validateRequiredGameplayMetrics(gameId, requestBody = {}) {
  // [2026-03-14 Security] Per-game required gameplay metrics configuration.
  const GAME_METRIC_REQUIREMENTS = {
    // Vocabulary Showdown uses timed scoring, hints, and wrong-answer penalties.
    'vocabulary-showdown': ['timeTaken', 'hintsUsed', 'wrongAnswers'],
    // Word games use hint penalties; we also require timing for consistency.
    'anagram-attack': ['timeTaken', 'hintsUsed'],
    'word-builder': ['timeTaken', 'hintsUsed'],
    // Default requirement for all other games.
    default: ['timeTaken', 'hintsUsed']
  };

  const requiredFields = GAME_METRIC_REQUIREMENTS[gameId] || GAME_METRIC_REQUIREMENTS.default;

  // [2026-03-14 Security] Check both top-level and nested `gameData` payloads
  // so that clients can send metrics in either location without bypassing
  // validation.
  const missingFields = requiredFields.filter((field) => {
    const hasTopLevel = Object.prototype.hasOwnProperty.call(requestBody, field);
    const hasNested =
      requestBody.gameData &&
      typeof requestBody.gameData === 'object' &&
      Object.prototype.hasOwnProperty.call(requestBody.gameData, field);

    return !hasTopLevel && !hasNested;
  });

  if (missingFields.length > 0) {
    // [2026-03-14 Security] Reject submissions that omit gameplay metrics
    // required for accurate server-side scoring.
    throw new AppError(
      400,
      `Missing required gameplay metrics: ${missingFields.join(', ')}`
    );
  }
}

// GET /api/games - Get available games
router.get('/', async (req, res, next) => {
  try {
    // Return game catalog (this matches the Flutter app's game_catalog.dart)
    const games = [
      { id: 'memory-match', name: 'Memory Match', category: 'Memory', minPlayers: 2, maxPlayers: 4 },
      { id: 'sequence-recall', name: 'Sequence Recall', category: 'Memory', minPlayers: 2, maxPlayers: 6 },
      { id: 'pattern-memory', name: 'Pattern Memory', category: 'Memory', minPlayers: 2, maxPlayers: 8 },
      { id: 'sudoku-duel', name: 'Sudoku Duel', category: 'Logic', minPlayers: 2, maxPlayers: 4 },
      { id: 'logic-grid', name: 'Logic Grid', category: 'Logic', minPlayers: 2, maxPlayers: 6 },
      { id: 'code-breaker', name: 'Code Breaker', category: 'Logic', minPlayers: 2, maxPlayers: 4 },
      { id: 'spot-difference', name: 'Spot the Difference', category: 'Attention', minPlayers: 2, maxPlayers: 8 },
      { id: 'color-rush', name: 'Color Rush', category: 'Attention', minPlayers: 2, maxPlayers: 10 },
      { id: 'focus-finder', name: 'Focus Finder', category: 'Attention', minPlayers: 2, maxPlayers: 6 },
      { id: 'puzzle-race', name: 'Puzzle Race', category: 'Spatial', minPlayers: 2, maxPlayers: 4 },
      { id: 'rotation-master', name: 'Rotation Master', category: 'Spatial', minPlayers: 2, maxPlayers: 8 },
      { id: 'path-finder', name: 'Path Finder', category: 'Spatial', minPlayers: 2, maxPlayers: 6 },
      { id: 'word-builder', name: 'Word Builder', category: 'Language', minPlayers: 2, maxPlayers: 6 },
      { id: 'anagram-attack', name: 'Anagram Attack', category: 'Language', minPlayers: 2, maxPlayers: 8 },
      { id: 'vocabulary-showdown', name: 'Vocabulary Showdown', category: 'Language', minPlayers: 2, maxPlayers: 10 }
    ];

    res.json({
      success: true,
      data: { games }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/games/:id/submit - Submit game result
router.post('/:id/submit', [
  body('lobbyId').isUUID(),
  body('score').optional().isNumeric(),
  body('timeTaken').optional().isNumeric(),
  body('hintsUsed').optional().isNumeric(),
  body('gameData').optional().isObject()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { id: gameId } = req.params;

    // [2026-03-14 Security] Ensure that required gameplay metrics for this game
    // are explicitly present in the payload before normalizing. This prevents
    // missing values from being defaulted to 0 inside `normalizeGameSubmission`.
    validateRequiredGameplayMetrics(gameId, req.body);

    const submission = normalizeGameSubmission(gameId, req.body);
    const { lobbyId, submittedScore, timeTaken, hintsUsed, perfect } = submission;
    const userId = req.user.id;

    // Validate game exists in lobby
    const lobbyCheck = await query(
      `SELECT id FROM lobbies WHERE id = $1 AND status = 'playing'`,
      [lobbyId]
    );

    if (lobbyCheck.rows.length === 0) {
      throw new AppError('Lobby not found or not in playing state', 404);
    }

    // Validate player is in lobby
    const playerCheck = await query(
      `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
      [lobbyId, userId]
    );

    if (playerCheck.rows.length === 0) {
      throw new AppError('Player not in lobby', 403);
    }

    // [2026-03-13 Security] Derive the score from normalized gameplay data on
    // the server rather than trusting the client to supply a final score.
    const validatedScore = calculateValidatedScore(submission);

    // Save game result
    const result = await transaction(async (client) => {
      // Insert game result
      const gameResult = await client.query(
        `INSERT INTO game_results (lobby_id, user_id, game_id, score, time_taken, hints_used, perfect, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
         RETURNING *`,
        [lobbyId, userId, gameId, validatedScore, timeTaken, hintsUsed, perfect || false]
      );

      // [2026-03-14 Bugfix] Rely on DB trigger to update users.total_score.
      // The database schema defines a trigger that increments users.total_score
      // whenever a row is inserted into game_results. Performing a manual
      // UPDATE here would double-count scores, so we intentionally do not
      // adjust total_score in application code.

      return gameResult.rows[0];
    });

    res.json({
      success: true,
      data: {
        id: result.id,
        validatedScore: result.score,
        originalScore: submittedScore,
        timeTaken: result.time_taken,
        hintsUsed: result.hints_used,
        perfect: result.perfect
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/games/:id/validate-move - Validate game move
router.post('/:id/validate-move', async (req, res, next) => {
  try {
    const { id: gameId } = req.params;
    const { move, gameState } = req.body;

    // Server-side move validation would go here
    // For now, we'll just acknowledge the move
    const isValid = true;

    res.json({
      success: true,
      data: {
        valid: isValid,
        gameId,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
module.exports.normalizeGameSubmission = normalizeGameSubmission;
module.exports.calculateValidatedScore = calculateValidatedScore;
