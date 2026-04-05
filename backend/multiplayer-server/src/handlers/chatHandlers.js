const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');
const profanityFilterService = require('../utils/profanityFilter');
const encryptionService = require('../utils/encryption');

const logger = createLogger('chat-handlers');

function respond(callback, payload) {
  if (typeof callback === 'function') {
    callback(payload);
  }
}

module.exports = (io, socket) => {
  // Send chat message
  socket.on('chat-message', async (data, callback) => {
    try {
      const { lobbyId, message } = data;

      if (!message || message.trim().length === 0) {
        return respond(callback, { success: false, error: 'Message cannot be empty' });
      }

      if (message.length > 500) {
        return respond(callback, { success: false, error: 'Message too long (max 500 characters)' });
      }

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return respond(callback, { success: false, error: 'Player not in lobby' });
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
      const encryptedOriginal = filterResult.requiresReview ? encryptionService.encrypt(message) : message;

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
          senderId: socket.userId,
          senderName: user.display_name,
          userId: socket.userId,
          displayName: user.display_name,
          avatarUrl: user.avatar_url,
          message: filteredMessage,
          timestamp: savedMessage.timestamp.toISOString()
        });

        logger.info(`Chat message in lobby ${lobbyId} from user ${socket.userId}${filterResult.requiresReview ? ' (moderated)' : ''}`);

        respond(callback, {
          success: true,
          moderation: {
            action: filterResult.moderationAction,
            flagged: filterResult.requiresReview
          }
        });
      } catch (broadcastError) {
        // Message was saved but broadcast failed - log but don't fail the request
        logger.error('Failed to broadcast message after successful save', { error: broadcastError, messageId: savedMessage.id });
        respond(callback, {
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
      respond(callback, { success: false, error: error.message });
    }
  });

  // Send emoji reaction
  socket.on('emoji-reaction', async (data, callback) => {
    try {
      const { lobbyId, emoji } = data;

      const allowedEmojis = ['👍', '❤️', '😂', '🎉', '🔥', '👏', '😮', '🤔'];

      if (!allowedEmojis.includes(emoji)) {
        return respond(callback, { success: false, error: 'Invalid emoji' });
      }

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return respond(callback, { success: false, error: 'Player not in lobby' });
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
        return respond(callback, { 
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

        respond(callback, { success: true });
      } catch (broadcastError) {
        // Reaction was saved but broadcast failed - log but don't fail the request
        logger.error('Failed to broadcast reaction after successful save', { error: broadcastError, reactionId: savedReaction.id });
        respond(callback, { success: true, warning: 'Reaction saved but some users may not receive it immediately' });
      }
    } catch (error) {
      logger.error('Emoji reaction error', error);
      respond(callback, { success: false, error: error.message });
    }
  });

  // Send typing indicator
  socket.on('typing-indicator', async (data, callback) => {
    try {
      const { lobbyId, isTyping } = data;

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return respond(callback, { success: false, error: 'Player not in lobby' });
      }

      // Broadcast typing status to other players in the lobby
      socket.to(`lobby:${lobbyId}`).emit('player-typing', {
        userId: socket.userId,
        isTyping: isTyping,
        timestamp: new Date().toISOString()
      });

      logger.info(`Typing indicator in lobby ${lobbyId} from user ${socket.userId}: ${isTyping}`);

      respond(callback, { success: true });
    } catch (error) {
      logger.error('Typing indicator error', error);
      respond(callback, { success: false, error: error.message });
    }
  });

  socket.on('get-chat-history', async (data, callback) => {
    try {
      const { lobbyId, limit = 50 } = data;
      const normalizedLimit = Math.min(Math.max(parseInt(limit, 10) || 50, 1), 100);

      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return respond(callback, { success: false, error: 'Player not in lobby' });
      }

      const historyResult = await query(
        `SELECT cm.id,
                cm.filtered_message,
                cm.timestamp,
                u.id AS user_id,
                u.display_name
         FROM chat_messages cm
         JOIN users u ON u.id = cm.user_id
         WHERE cm.lobby_id = $1
         ORDER BY cm.timestamp DESC
         LIMIT $2`,
        [lobbyId, normalizedLimit]
      );

      const messages = historyResult.rows
        .slice()
        .reverse()
        .map((row) => ({
          id: row.id,
          senderId: row.user_id,
          senderName: row.display_name,
          userId: row.user_id,
          displayName: row.display_name,
          message: row.filtered_message || '',
          timestamp: row.timestamp.toISOString(),
        }));

      respond(callback, { success: true, messages });
    } catch (error) {
      logger.error('Get chat history error', error);
      respond(callback, { success: false, error: error.message });
    }
  });
};
