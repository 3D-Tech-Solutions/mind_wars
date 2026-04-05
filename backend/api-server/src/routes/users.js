const express = require('express');
const { body, validationResult } = require('express-validator');
const { query } = require('../utils/database');
const { AppError } = require('../middleware/errorHandler');
const { authenticate } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');
const fs = require('fs');
const path = require('path');
const multer = require('multer');
const crypto = require('crypto');

const router = express.Router();

router.use(authenticate);
router.use(standardLimiter);

// Setup multer for avatar uploads
const uploadsDir = path.join(__dirname, '../../uploads/avatars');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename: userId_timestamp_originalname
    const filename = `${req.user.id}_${Date.now()}_${file.originalname}`;
    cb(null, filename);
  }
});

const uploadFilter = (req, file, cb) => {
  // Accept only image files
  if (!file.mimetype.startsWith('image/')) {
    return cb(new AppError('Only image files are allowed', 400));
  }
  cb(null, true);
};

const upload = multer({
  storage: storage,
  fileFilter: uploadFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// Helper function to compute MD5 checksum of a file
const getFileChecksum = (filePath) => {
  try {
    const fileBuffer = fs.readFileSync(filePath);
    return crypto.createHash('md5').update(fileBuffer).digest('hex');
  } catch (err) {
    return null;
  }
};

// Helper function to build avatar response object
const buildAvatarResponse = (avatarUrl) => {
  if (!avatarUrl || !avatarUrl.startsWith('/uploads/avatars/')) {
    return { avatarUrl, avatarChecksum: null };
  }

  // Extract filename from URL
  const filename = avatarUrl.split('/').pop();
  const filePath = path.join(uploadsDir, filename);
  const checksum = getFileChecksum(filePath);

  return { avatarUrl, avatarChecksum: checksum };
};

// GET /api/users/:id - Get user profile
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await query(
      `SELECT id, email, username, display_name, avatar_url, level, total_score,
              current_streak, longest_streak, games_played, games_won,
              created_at, last_login_at
       FROM users WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      throw new AppError('User not found', 404);
    }

    const user = result.rows[0];
    const avatarData = buildAvatarResponse(user.avatar_url);

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.display_name,
        avatarUrl: avatarData.avatarUrl,
        avatarChecksum: avatarData.avatarChecksum,
        level: user.level,
        totalScore: user.total_score,
        currentStreak: user.current_streak,
        longestStreak: user.longest_streak,
        gamesPlayed: user.games_played,
        gamesWon: user.games_won,
        createdAt: user.created_at,
        lastLoginAt: user.last_login_at
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/users/:id/progress - Get user progress
router.get('/:id/progress', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Get badges
    const badgesResult = await query(
      `SELECT b.*, ub.earned_at
       FROM badges b
       LEFT JOIN user_badges ub ON b.id = ub.badge_id AND ub.user_id = $1
       ORDER BY b.category, b.name`,
      [id]
    );

    // Get recent games
    const gamesResult = await query(
      `SELECT gr.*, g.name as game_name, l.name as lobby_name
       FROM game_results gr
       JOIN lobbies l ON gr.lobby_id = l.id
       WHERE gr.user_id = $1
       ORDER BY gr.created_at DESC
       LIMIT 20`,
      [id]
    );

    // Get statistics
    const statsResult = await query(
      `SELECT
         COUNT(*) as total_games,
         AVG(score) as avg_score,
         MAX(score) as best_score,
         SUM(CASE WHEN perfect THEN 1 ELSE 0 END) as perfect_games
       FROM game_results
       WHERE user_id = $1`,
      [id]
    );

    const stats = statsResult.rows[0];

    res.json({
      success: true,
      data: {
        badges: badgesResult.rows.map(b => ({
          id: b.id,
          name: b.name,
          description: b.description,
          category: b.category,
          icon: b.icon,
          earned: !!b.earned_at,
          earnedAt: b.earned_at
        })),
        recentGames: gamesResult.rows.map(g => ({
          id: g.id,
          gameName: g.game_name,
          lobbyName: g.lobby_name,
          score: g.score,
          timeTaken: g.time_taken,
          perfect: g.perfect,
          createdAt: g.created_at
        })),
        statistics: {
          totalGames: parseInt(stats.total_games),
          avgScore: parseFloat(stats.avg_score) || 0,
          bestScore: parseInt(stats.best_score) || 0,
          perfectGames: parseInt(stats.perfect_games)
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// PATCH /api/users/:id - Update user profile
// Can update: username (unique), displayName (non-unique), avatar, avatarUrl
router.patch('/:id', [
  body('username').optional().trim().isLength({ min: 3, max: 20 }),
  body('displayName').optional().trim(),
  body('avatarUrl').optional().isURL(),
  body('avatar').optional().isString().trim() // Accept avatar name or emoji
], async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if user is updating their own profile
    if (id !== req.user.id) {
      throw new AppError('Cannot update another user\'s profile', 403);
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { username, displayName, avatarUrl, avatar } = req.body;
    const updates = [];
    const values = [];
    let paramCount = 1;

    // Handle username updates (unique, rarely changed)
    if (username) {
      // Server-side username validation
      if (username.length < 3 || username.length > 20) {
        throw new AppError('Username must be 3–20 characters', 400);
      }
      if (!/^[a-zA-Z0-9_-]+$/.test(username)) {
        throw new AppError('Username can only contain letters, numbers, _ and -', 400);
      }

      // Check uniqueness, excluding current user
      const taken = await query(
        'SELECT id FROM users WHERE LOWER(username) = LOWER($1) AND id != $2',
        [username, id]
      );

      if (taken.rows.length > 0) {
        throw new AppError('Username already taken', 409);
      }

      updates.push(`username = $${paramCount++}`);
      values.push(username);
    }

    // Handle displayName updates (non-unique, optional, freely editable)
    if (displayName !== undefined) {
      updates.push(`display_name = $${paramCount++}`);
      values.push(displayName); // Can be empty string, null, or any length
    }

    if (avatarUrl) {
      updates.push(`avatar_url = $${paramCount++}`);
      values.push(avatarUrl);
    }

    // Avatar field overrides avatarUrl if both present
    if (avatar) {
      updates.push(`avatar_url = $${paramCount++}`);
      values.push(avatar);
    }

    if (updates.length === 0) {
      throw new AppError('No fields to update', 400);
    }

    updates.push(`updated_at = NOW()`);
    values.push(id);

    // Return full profile including username, displayName, level, streaks, and game stats
    const result = await query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}
       RETURNING id, email, username, display_name, avatar_url, level, total_score,
                 current_streak, longest_streak, games_played, games_won, updated_at`,
      values
    );

    const user = result.rows[0];
    const avatarData = buildAvatarResponse(user.avatar_url);

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.display_name,
        avatarUrl: avatarData.avatarUrl,
        avatarChecksum: avatarData.avatarChecksum,
        level: user.level,
        totalScore: user.total_score,
        currentStreak: user.current_streak,
        longestStreak: user.longest_streak,
        gamesPlayed: user.games_played,
        gamesWon: user.games_won,
        updatedAt: user.updated_at
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/users/:id/profile - Get user personal profile info
router.get('/:id/profile', async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await query(
      `SELECT id, user_id, first_name, last_name, date_of_birth, gender, bio, location, created_at, updated_at
       FROM user_profiles WHERE user_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      // Return empty profile if user has no profile yet
      return res.json({
        success: true,
        data: {
          userId: id,
          firstName: null,
          lastName: null,
          dateOfBirth: null,
          gender: null,
          bio: null,
          location: null
        }
      });
    }

    const profile = result.rows[0];

    res.json({
      success: true,
      data: {
        userId: profile.user_id,
        firstName: profile.first_name,
        lastName: profile.last_name,
        dateOfBirth: profile.date_of_birth,
        gender: profile.gender,
        bio: profile.bio,
        location: profile.location
      }
    });
  } catch (error) {
    next(error);
  }
});

// PATCH /api/users/:id/profile - Update user personal profile info
router.patch('/:id/profile', [
  body('firstName').optional().trim().isLength({ min: 1, max: 100 }),
  body('lastName').optional().trim().isLength({ min: 1, max: 100 }),
  body('dateOfBirth').optional().isISO8601(),
  body('gender').optional().isIn(['M', 'F', 'Other', 'Prefer not to say']),
  body('bio').optional().trim().isLength({ min: 0, max: 1000 }),
  body('location').optional().trim().isLength({ min: 1, max: 255 })
], async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if user is updating their own profile
    if (id !== req.user.id) {
      throw new AppError('Cannot update another user\'s profile', 403);
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { firstName, lastName, dateOfBirth, gender, bio, location } = req.body;
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (firstName !== undefined) {
      updates.push(`first_name = $${paramCount++}`);
      values.push(firstName);
    }

    if (lastName !== undefined) {
      updates.push(`last_name = $${paramCount++}`);
      values.push(lastName);
    }

    if (dateOfBirth !== undefined) {
      updates.push(`date_of_birth = $${paramCount++}`);
      values.push(dateOfBirth);
    }

    if (gender !== undefined) {
      updates.push(`gender = $${paramCount++}`);
      values.push(gender);
    }

    if (bio !== undefined) {
      updates.push(`bio = $${paramCount++}`);
      values.push(bio);
    }

    if (location !== undefined) {
      updates.push(`location = $${paramCount++}`);
      values.push(location);
    }

    if (updates.length === 0) {
      throw new AppError('No fields to update', 400);
    }

    updates.push(`updated_at = NOW()`);
    values.push(id);

    // Ensure profile exists, create if needed
    await query(
      `INSERT INTO user_profiles (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
      [id]
    );

    // Update profile
    const result = await query(
      `UPDATE user_profiles SET ${updates.join(', ')} WHERE user_id = $${paramCount}
       RETURNING user_id, first_name, last_name, date_of_birth, gender, bio, location`,
      values
    );

    const profile = result.rows[0];

    res.json({
      success: true,
      data: {
        userId: profile.user_id,
        firstName: profile.first_name,
        lastName: profile.last_name,
        dateOfBirth: profile.date_of_birth,
        gender: profile.gender,
        bio: profile.bio,
        location: profile.location
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/users/:id/avatar - Upload custom avatar image
router.post('/:id/avatar', upload.single('avatar'), async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if user is updating their own avatar
    if (id !== req.user.id) {
      // Delete uploaded file if not authorized
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      throw new AppError('Cannot update another user\'s avatar', 403);
    }

    if (!req.file) {
      throw new AppError('No image file provided', 400);
    }

    // Generate URL for the uploaded file (relative to backend /uploads)
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;

    // Update user's avatar_url in database
    const result = await query(
      `UPDATE users SET avatar_url = $1, updated_at = NOW() WHERE id = $2
       RETURNING id, email, username, display_name, avatar_url, level, total_score,
                 current_streak, longest_streak, games_played, games_won, updated_at`,
      [avatarUrl, id]
    );

    if (result.rows.length === 0) {
      throw new AppError('User not found', 404);
    }

    const user = result.rows[0];
    const avatarData = buildAvatarResponse(user.avatar_url);

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.display_name,
        avatarUrl: avatarData.avatarUrl,
        avatarChecksum: avatarData.avatarChecksum,
        level: user.level,
        totalScore: user.total_score,
        currentStreak: user.current_streak,
        longestStreak: user.longest_streak,
        gamesPlayed: user.games_played,
        gamesWon: user.games_won,
        updatedAt: user.updated_at
      }
    });
  } catch (error) {
    // Delete uploaded file if error occurs
    if (req.file) {
      try {
        fs.unlinkSync(req.file.path);
      } catch (err) {
        // Ignore delete errors
      }
    }
    next(error);
  }
});

module.exports = router;
