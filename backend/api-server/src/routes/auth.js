const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { query } = require('../utils/database');
const { AppError } = require('../middleware/errorHandler');
const { authLimiter } = require('../middleware/rateLimit');
const { authenticate } = require('../middleware/auth');
const { createLogger } = require('../utils/logger');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const router = express.Router();
const logger = createLogger('auth-routes');

// Helper function to get avatar checksum
const getAvatarChecksum = (avatarUrl) => {
  if (!avatarUrl || !avatarUrl.startsWith('/uploads/avatars/')) {
    return null;
  }
  try {
    const uploadsDir = path.join(__dirname, '../../uploads/avatars');
    const filename = avatarUrl.split('/').pop();
    const filePath = path.join(uploadsDir, filename);
    const fileBuffer = fs.readFileSync(filePath);
    return crypto.createHash('md5').update(fileBuffer).digest('hex');
  } catch (err) {
    return null;
  }
};

// Validation middleware
const registerValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
  body('displayName').optional().trim().isLength({ min: 2, max: 50 })
];

const loginValidation = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
];

// Generate JWT tokens
const generateTokens = (userId, email) => {
  const accessToken = jwt.sign(
    { userId, email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_ACCESS_EXPIRY || '15m' }
  );

  const refreshToken = jwt.sign(
    { userId, email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRY || '7d' }
  );

  return { accessToken, refreshToken };
};

// POST /api/auth/register - Register new user
router.post('/register', authLimiter, registerValidation, async (req, res, next) => {
  try {
    // Validate input
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { email, password, displayName } = req.body;

    // Check if user already exists
    const existingUser = await query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      throw new AppError('Email already registered', 409);
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, parseInt(process.env.BCRYPT_ROUNDS) || 12);

    // Generate default username from email prefix
    // Users can change this during profile setup
    const emailPrefix = email.split('@')[0].toLowerCase().replace(/[^a-z0-9_-]/g, '_').slice(0, 20);
    let defaultUsername = emailPrefix || 'user';

    // If username collision likely, add random suffix
    let usernameToUse = defaultUsername;
    let conflict = true;
    let attempt = 0;
    while (conflict && attempt < 10) {
      const checkUsername = attempt === 0 ? usernameToUse : `${usernameToUse}${attempt}`;
      const taken = await query('SELECT id FROM users WHERE LOWER(username) = LOWER($1)', [checkUsername]);
      if (taken.rows.length === 0) {
        usernameToUse = checkUsername;
        conflict = false;
      }
      attempt++;
    }

    // Use provided displayName or default to empty string (will be set during profile setup)
    const finalDisplayName = displayName || '';

    // Create user
    const result = await query(
      `INSERT INTO users (email, password_hash, username, display_name, created_at, updated_at)
       VALUES ($1, $2, $3, $4, NOW(), NOW())
       RETURNING id, email, username, display_name, created_at`,
      [email, passwordHash, usernameToUse, finalDisplayName]
    );

    const user = result.rows[0];

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id, user.email);

    logger.info(`User registered: ${user.email}`);

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          displayName: user.display_name,
          createdAt: user.created_at
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/auth/login - Login user
router.post('/login', authLimiter, loginValidation, async (req, res, next) => {
  try {
    // Validate input
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { email, password } = req.body;

    // Find user
    const result = await query(
      `SELECT id, email, password_hash, username, display_name, avatar_url, level, total_score
       FROM users WHERE email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      throw new AppError('Invalid email or password', 401);
    }

    const user = result.rows[0];

    // Verify password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      throw new AppError('Invalid email or password', 401);
    }

    // Update last login
    await query('UPDATE users SET last_login_at = NOW() WHERE id = $1', [user.id]);

    // Generate tokens
    const { accessToken, refreshToken } = generateTokens(user.id, user.email);

    logger.info(`User logged in: ${user.email}`);

    const avatarChecksum = getAvatarChecksum(user.avatar_url);

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          displayName: user.display_name,
          avatarUrl: user.avatar_url,
          avatarChecksum: avatarChecksum,
          level: user.level,
          totalScore: user.total_score
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/auth/refresh - Refresh access token
router.post('/refresh', async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      throw new AppError('Refresh token required', 400);
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);

    // Generate new tokens
    const tokens = generateTokens(decoded.userId, decoded.email);

    res.json({
      success: true,
      data: tokens
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return next(new AppError('Invalid refresh token', 401));
    }
    next(error);
  }
});

// POST /api/auth/logout - Logout user
router.post('/logout', authenticate, async (req, res, next) => {
  try {
    // In a production system, you might want to blacklist the token
    logger.info(`User logged out: ${req.user.email}`);

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/auth/me - Get current user
router.get('/me', authenticate, async (req, res, next) => {
  try {
    const result = await query(
      `SELECT id, email, display_name, avatar_url, level, total_score,
              current_streak, longest_streak, created_at
       FROM users WHERE id = $1`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      throw new AppError('User not found', 404);
    }

    const user = result.rows[0];

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        level: user.level,
        totalScore: user.total_score,
        currentStreak: user.current_streak,
        longestStreak: user.longest_streak,
        createdAt: user.created_at
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/auth/check-username - Check if username is available
router.post('/check-username', async (req, res, next) => {
  try {
    const { username, userId } = req.body;

    if (!username || username.trim().length === 0) {
      return res.status(400).json({
        success: false,
        available: false,
        error: 'Username is required'
      });
    }

    // Check if username already exists (using username column, which is unique)
    // If userId provided (for edit flow), exclude that user from the check
    let query_text = 'SELECT id FROM users WHERE LOWER(username) = LOWER($1)';
    const params = [username.trim()];

    if (userId) {
      query_text += ' AND id != $2';
      params.push(userId);
    }

    const result = await query(query_text, params);

    const available = result.rows.length === 0;

    res.json({
      success: true,
      available,
      username: username.trim()
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
