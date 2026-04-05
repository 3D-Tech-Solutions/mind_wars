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
// Valid session types
const VALID_SESSION_TYPES = ['solo_training', 'vs_friends', 'vs_random', 'vs_mixed'];

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

  // Determine session type: default to solo_training when no lobbyId present
  const rawSessionType = requestBody.sessionType || requestBody.session_type;
  const sessionType = VALID_SESSION_TYPES.includes(rawSessionType)
    ? rawSessionType
    : requestBody.lobbyId ? 'vs_random' : 'solo_training';

  return {
    gameId,
    lobbyId: requestBody.lobbyId || null,
    sessionType,
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
// Supports both multiplayer (lobbyId required) and solo training (lobbyId optional)
router.post('/:id/submit', [
  body('lobbyId').optional().isUUID(),
  body('sessionType').optional().isIn(VALID_SESSION_TYPES),
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
    const { lobbyId, sessionType, submittedScore, timeTaken, hintsUsed, perfect } = submission;
    const userId = req.user.id;

    // Only validate lobby membership for multiplayer sessions
    if (lobbyId) {
      const lobbyCheck = await query(
        `SELECT id FROM lobbies WHERE id = $1 AND status = 'playing'`,
        [lobbyId]
      );

      if (lobbyCheck.rows.length === 0) {
        throw new AppError('Lobby not found or not in playing state', 404);
      }

      const playerCheck = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, userId]
      );

      if (playerCheck.rows.length === 0) {
        throw new AppError('Player not in lobby', 403);
      }
    }

    // [2026-03-13 Security] Derive the score from normalized gameplay data on
    // the server rather than trusting the client to supply a final score.
    const validatedScore = calculateValidatedScore(submission);

    // Save game result
    const result = await transaction(async (client) => {
      const gameResult = await client.query(
        `INSERT INTO game_results
           (lobby_id, user_id, game_id, score, time_taken, hints_used, perfect, session_type, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
         RETURNING *`,
        [lobbyId, userId, gameId, validatedScore, timeTaken, hintsUsed, perfect || false, sessionType]
      );

      // [2026-03-14 Bugfix] Rely on DB trigger to update users.total_score and
      // game_high_scores. Do not manually update these here to avoid double-counts.

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
        perfect: result.perfect,
        sessionType: result.session_type
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/games/:id/events - Record in-game telemetry events
// Called by the client during gameplay to stream granular event data
router.post('/:id/events', [
  body('gameResultId').isUUID(),
  body('events').isArray({ min: 1, max: 100 }),
  body('events.*.eventType').isString().notEmpty(),
  body('events.*.payload').optional().isObject(),
  body('events.*.occurredAt').optional().isISO8601()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const userId = req.user.id;
    const { gameResultId, events } = req.body;

    // Verify the game result belongs to this user
    const ownerCheck = await query(
      'SELECT id FROM game_results WHERE id = $1 AND user_id = $2',
      [gameResultId, userId]
    );

    if (ownerCheck.rows.length === 0) {
      throw new AppError('Game result not found', 404);
    }

    // Batch insert events
    if (events.length > 0) {
      const placeholders = events.map((_, i) => {
        const base = i * 5;
        return `($${base + 1}, $${base + 2}, $${base + 3}, $${base + 4}, $${base + 5})`;
      }).join(', ');

      const values = events.flatMap(e => [
        gameResultId,
        userId,
        e.eventType,
        JSON.stringify(e.payload || {}),
        e.occurredAt || new Date().toISOString()
      ]);

      await query(
        `INSERT INTO game_events (game_result_id, user_id, event_type, payload, occurred_at)
         VALUES ${placeholders}`,
        values
      );
    }

    res.status(201).json({ success: true, data: { recorded: events.length } });
  } catch (error) {
    next(error);
  }
});

// GET /api/games/:id/results - Get game results for a specific game in a lobby
router.get('/:id/results', async (req, res, next) => {
  try {
    const { id: gameId } = req.params;
    const { lobbyId } = req.query;

    if (!lobbyId) {
      throw new AppError('lobbyId query parameter required', 400);
    }

    // Get all game results for this game in this lobby
    const results = await query(
      `SELECT
         gr.id,
         gr.user_id,
         u.display_name,
         u.avatar_url,
         gr.score,
         gr.time_taken,
         gr.hints_used,
         gr.perfect,
         gr.created_at
       FROM game_results gr
       JOIN users u ON gr.user_id = u.id
       WHERE gr.game_id = $1 AND gr.lobby_id = $2
       ORDER BY gr.score DESC, gr.time_taken ASC`,
      [gameId, lobbyId]
    );

    if (results.rows.length === 0) {
      throw new AppError('No results found for this game', 404);
    }

    // Determine winner (highest score, fastest time as tiebreaker)
    const winnerResult = results.rows[0];

    res.json({
      success: true,
      data: {
        gameId,
        gameName: 'Game', // Could be enhanced to fetch from game catalog
        lobbyId,
        results: results.rows.map(row => ({
          resultId: row.id,
          userId: row.user_id,
          displayName: row.display_name,
          avatarUrl: row.avatar_url,
          score: row.score,
          timeTaken: row.time_taken,
          hintsUsed: row.hints_used,
          perfect: row.perfect,
          completedAt: row.created_at
        })),
        winner: {
          userId: winnerResult.user_id,
          displayName: winnerResult.display_name,
          score: winnerResult.score
        },
        timestamp: new Date().toISOString()
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
