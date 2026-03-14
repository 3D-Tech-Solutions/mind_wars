const express = require('express');
const { query } = require('../utils/database');
const { authenticate, optionalAuth } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');
const { getCache, setCache } = require('../utils/redis');

const router = express.Router();

router.use(optionalAuth);
router.use(standardLimiter);

// [2026-03-13 Bugfix] Centralize leaderboard ordering so ties are resolved
// consistently across weekly/all-time views and current-user rank lookups.
const MISSING_TIME_FALLBACK = 2147483647; // INT32_MAX keeps missing times at the end of ASC tie-break ordering.

// [2026-03-13 Bugfix] Keep missing completion times at the bottom of tie-break
// ordering while still returning a stable numeric value in API responses.
const WEEKLY_LEADERBOARD_ORDER_BY =
  `SUM(gr.score) DESC, AVG(COALESCE(gr.time_taken, ${MISSING_TIME_FALLBACK})) ASC, COUNT(gr.id) DESC, u.id ASC`;

// [2026-03-13 Bugfix] All-time leaderboard now uses average completion time
// as the first tie-breaker instead of leaving equal scores in undefined order.
const ALL_TIME_LEADERBOARD_ORDER_BY =
  `u.total_score DESC, AVG(COALESCE(gr.time_taken, ${MISSING_TIME_FALLBACK})) ASC, u.games_won DESC, u.id ASC`;

// GET /api/leaderboard/weekly - Get weekly leaderboard
router.get('/weekly', async (req, res, next) => {
  try {
    const { limit = 100 } = req.query;
    const cacheKey = `leaderboard:weekly:${limit}`;

    // Try to get from cache
    let leaderboard = await getCache(cacheKey);

    if (!leaderboard) {
      // Calculate weekly leaderboard (Monday to Sunday)
      /// [2026-03-14 Bugfix] Align average_time_taken with tie-break ordering
      ///
      /// Previously, the SELECT used AVG(gr.time_taken) while ORDER BY used
      /// AVG(COALESCE(gr.time_taken, MISSING_TIME_FALLBACK)), which could
      /// cause the reported averageTimeTaken to diverge from the metric used
      /// for ranking whenever NULL time_taken values existed. We now apply
      /// COALESCE before AVG and ROUND, matching WEEKLY_LEADERBOARD_ORDER_BY.
      const result = await query(
         `SELECT
            u.id, u.display_name, u.avatar_url, u.level,
            SUM(gr.score) as weekly_score,
            COUNT(gr.id) as games_played,
            ROUND(AVG(COALESCE(gr.time_taken, ${MISSING_TIME_FALLBACK}))) as average_time_taken,
            ROW_NUMBER() OVER (ORDER BY ${WEEKLY_LEADERBOARD_ORDER_BY}) as rank
          FROM users u
          JOIN game_results gr ON u.id = gr.user_id
          WHERE gr.created_at >= date_trunc('week', CURRENT_DATE)
          GROUP BY u.id, u.display_name, u.avatar_url, u.level
          ORDER BY ${WEEKLY_LEADERBOARD_ORDER_BY}
          LIMIT $1`,
        [limit]
      );

      leaderboard = result.rows.map(row => ({
        rank: parseInt(row.rank),
        userId: row.id,
        displayName: row.display_name,
        avatarUrl: row.avatar_url,
        level: row.level,
        score: parseInt(row.weekly_score),
        gamesPlayed: parseInt(row.games_played),
        averageTimeTaken: parseInt(row.average_time_taken)
      }));

      // Cache for 5 minutes
      await setCache(cacheKey, leaderboard, 300);
    }

    // Find current user's rank if authenticated
    let currentUserRank = null;
    if (req.user) {
      const userRankResult = await query(
        `WITH ranked_users AS (
           SELECT u.id, SUM(gr.score) as weekly_score,
                  ROUND(AVG(COALESCE(gr.time_taken, ${MISSING_TIME_FALLBACK}))) as average_time_taken,
                  ROW_NUMBER() OVER (ORDER BY ${WEEKLY_LEADERBOARD_ORDER_BY}) as rank
            FROM users u
            JOIN game_results gr ON u.id = gr.user_id
            WHERE gr.created_at >= date_trunc('week', CURRENT_DATE)
            GROUP BY u.id
          )
          SELECT rank, weekly_score, average_time_taken FROM ranked_users WHERE id = $1`,
        [req.user.id]
      );

      if (userRankResult.rows.length > 0) {
        currentUserRank = {
          rank: parseInt(userRankResult.rows[0].rank),
          score: parseInt(userRankResult.rows[0].weekly_score),
          averageTimeTaken: parseInt(userRankResult.rows[0].average_time_taken)
        };
      }
    }

    res.json({
      success: true,
      data: {
        leaderboard,
        currentUserRank,
        period: 'weekly',
        updatedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/leaderboard/all-time - Get all-time leaderboard
router.get('/all-time', async (req, res, next) => {
  try {
    const { limit = 100 } = req.query;
    const cacheKey = `leaderboard:all-time:${limit}`;

    // Try to get from cache
    let leaderboard = await getCache(cacheKey);

    if (!leaderboard) {
      /// [2026-03-14 Bugfix] Align all-time average_time_taken with ORDER BY expression
      ///
      /// Previously, the SELECT used AVG(gr.time_taken) (ignoring NULLs) while
      /// ALL_TIME_LEADERBOARD_ORDER_BY used AVG(COALESCE(gr.time_taken, MISSING_TIME_FALLBACK)).
      /// This could cause users with missing completion times to see an
      /// averageTimeTaken value that did not correspond to their tie-break rank.
      /// We now compute average_time_taken from AVG(COALESCE(gr.time_taken, MISSING_TIME_FALLBACK))
      /// so that the returned value matches the metric used for ordering.
      const result = await query(
        `SELECT
           u.id, u.display_name, u.avatar_url, u.level, u.total_score,
            u.games_played, u.games_won,
           COALESCE(ROUND(AVG(COALESCE(gr.time_taken, ${MISSING_TIME_FALLBACK}))), ${MISSING_TIME_FALLBACK}) as average_time_taken,
           ROW_NUMBER() OVER (ORDER BY ${ALL_TIME_LEADERBOARD_ORDER_BY}) as rank
          FROM users u
          LEFT JOIN game_results gr ON u.id = gr.user_id
          WHERE u.total_score > 0
          GROUP BY u.id, u.display_name, u.avatar_url, u.level, u.total_score, u.games_played, u.games_won
          ORDER BY ${ALL_TIME_LEADERBOARD_ORDER_BY}
          LIMIT $1`,
        [limit]
      );

      leaderboard = result.rows.map(row => ({
        rank: parseInt(row.rank),
        userId: row.id,
        displayName: row.display_name,
        avatarUrl: row.avatar_url,
        level: row.level,
        score: parseInt(row.total_score),
        gamesPlayed: parseInt(row.games_played),
        gamesWon: parseInt(row.games_won),
        averageTimeTaken: parseInt(row.average_time_taken)
      }));

      // Cache for 10 minutes
      await setCache(cacheKey, leaderboard, 600);
    }

    // Find current user's rank if authenticated
    let currentUserRank = null;
    if (req.user) {
      /// [2026-03-14 Bugfix] Use the same average_time_taken metric for rank lookup
      ///
      /// The ranked_users CTE now computes average_time_taken using
      /// AVG(COALESCE(gr.time_taken, MISSING_TIME_FALLBACK)), matching the
      /// ALL_TIME_LEADERBOARD_ORDER_BY tie-breaker and the main leaderboard query.
      /// This keeps the current user's reported averageTimeTaken consistent with
      /// their ordering in the all-time leaderboard.
      const userRankResult = await query(
        `WITH ranked_users AS (
           SELECT u.id, u.total_score,
                  COALESCE(ROUND(AVG(COALESCE(gr.time_taken, ${MISSING_TIME_FALLBACK}))), ${MISSING_TIME_FALLBACK}) as average_time_taken,
                  ROW_NUMBER() OVER (ORDER BY ${ALL_TIME_LEADERBOARD_ORDER_BY}) as rank
           FROM users u
           LEFT JOIN game_results gr ON u.id = gr.user_id
           WHERE u.total_score > 0
           GROUP BY u.id, u.total_score, u.games_won
          )
          SELECT rank, total_score, average_time_taken FROM ranked_users WHERE id = $1`,
        [req.user.id]
      );

      if (userRankResult.rows.length > 0) {
        currentUserRank = {
          rank: parseInt(userRankResult.rows[0].rank),
          score: parseInt(userRankResult.rows[0].total_score),
          averageTimeTaken: parseInt(userRankResult.rows[0].average_time_taken)
        };
      }
    }

    res.json({
      success: true,
      data: {
        leaderboard,
        currentUserRank,
        period: 'all-time',
        updatedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
module.exports.WEEKLY_LEADERBOARD_ORDER_BY = WEEKLY_LEADERBOARD_ORDER_BY;
module.exports.ALL_TIME_LEADERBOARD_ORDER_BY = ALL_TIME_LEADERBOARD_ORDER_BY;
module.exports.MISSING_TIME_FALLBACK = MISSING_TIME_FALLBACK;
