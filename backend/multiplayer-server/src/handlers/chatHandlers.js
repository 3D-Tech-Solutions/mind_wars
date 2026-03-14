const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');
const profanityFilterService = require('../utils/profanityFilter');
const encryptionService = require('../utils/encryption');

const logger = createLogger('chat-handlers');

module.exports = (io, socket) => {
  // Send chat message
  socket.on('chat-message', async (data, callback) => {
    try {
      const { lobbyId, message } = data;

      if (!message || message.trim().length === 0) {
        return callback({ success: false, error: 'Message cannot be empty' });
      }

      if (message.length > 500) {
        return callback({ success: false, error: 'Message too long (max 500 characters)' });
      }

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Get user info
      const userResult = await query(
        `SELECT display_name, avatar_url FROM users WHERE id = $1`,
        [socket.userId]
      );

      const user = userResult.rows[0];

      // Apply profanity filter with lobby-specific configuration
      const filterResult = profanityFilterService.filterMessage(message, lobbyId);
      const filteredMessage = filterResult.filtered;

      // [2026-03-13 Security] Store the original payload encrypted whenever the
      // moderation system alters or flags the visible message.
      const encryptedOriginal = filterResult.requiresReview ? encryptionService.encrypt(message) : null;

      // Save message to database
      const messageResult = await query(
        `INSERT INTO chat_messages (lobby_id, user_id, message, filtered_message, flagged_for_review, flagged_reason)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, timestamp`,
        [
          lobbyId,
          socket.userId,
          encryptedOriginal,
          filteredMessage,
          filterResult.requiresReview,
          filterResult.flaggedReason
        ]
      );

      const savedMessage = messageResult.rows[0];

      // Only broadcast after successful database insertion
      try {
        io.to(`lobby:${lobbyId}`).emit('chat-message', {
          id: savedMessage.id,
          userId: socket.userId,
          displayName: user.display_name,
          avatarUrl: user.avatar_url,
          message: filteredMessage,
          timestamp: savedMessage.timestamp.toISOString()
        });

        logger.info(`Chat message in lobby ${lobbyId} from user ${socket.userId}${filterResult.requiresReview ? ' (moderated)' : ''}`);

        callback({
          success: true,
          moderation: {
            action: filterResult.moderationAction,
            flagged: filterResult.requiresReview
          }
        });
      } catch (broadcastError) {
        // Message was saved but broadcast failed - log but don't fail the request
        logger.error('Failed to broadcast message after successful save', { error: broadcastError, messageId: savedMessage.id });
        callback({
          success: true,
          warning: 'Message saved but some users may not receive it immediately',
          moderation: {
            action: filterResult.moderationAction,
            flagged: filterResult.requiresReview
          }
        });
      }
    } catch (error) {
      logger.error('Chat message error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Send emoji reaction
  socket.on('emoji-reaction', async (data, callback) => {
    try {
      const { lobbyId, emoji } = data;

      const allowedEmojis = ['👍', '❤️', '😂', '🎉', '🔥', '👏', '😮', '🤔'];

      if (!allowedEmojis.includes(emoji)) {
        return callback({ success: false, error: 'Invalid emoji' });
      }

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Get user info
      const userResult = await query(
        `SELECT display_name FROM users WHERE id = $1`,
        [socket.userId]
      );

      const user = userResult.rows[0];

      // Save reaction to database with explicit error handling
      let savedReaction;
      try {
        const reactionResult = await query(
          `INSERT INTO emoji_reactions (lobby_id, user_id, emoji)
           VALUES ($1, $2, $3)
           RETURNING id, timestamp`,
          [lobbyId, socket.userId, emoji]
        );
        savedReaction = reactionResult.rows[0];
      } catch (dbError) {
        logger.error('Database insertion failed for emoji reaction', { error: dbError, lobbyId, userId: socket.userId });
        return callback({ 
          success: false, 
          error: 'Failed to save reaction. Please try again.',
          errorType: 'database_error'
        });
      }

      // Only broadcast after successful database insertion
      try {
        io.to(`lobby:${lobbyId}`).emit('emoji-reaction', {
          id: savedReaction.id,
          userId: socket.userId,
          displayName: user.display_name,
          emoji,
          timestamp: savedReaction.timestamp.toISOString()
        });

        logger.info(`Emoji reaction ${emoji} in lobby ${lobbyId} from user ${socket.userId}`);

        callback({ success: true });
      } catch (broadcastError) {
        // Reaction was saved but broadcast failed - log but don't fail the request
        logger.error('Failed to broadcast reaction after successful save', { error: broadcastError, reactionId: savedReaction.id });
        callback({ success: true, warning: 'Reaction saved but some users may not receive it immediately' });
      }
    } catch (error) {
      logger.error('Emoji reaction error', error);
      callback({ success: false, error: error.message });
    }
  });
};
