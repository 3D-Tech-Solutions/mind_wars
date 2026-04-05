const { v4: uuidv4 } = require('uuid');
const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');
const rotationMasterPayload = require('../utils/rotationMasterPayload');
const pathFinderPayload = require('../utils/pathFinderPayload');

const logger = createLogger('lobby-handlers');

// Generate short 5-6 character alphanumeric lobby code (e.g., "A7K9X")
function generateLobbyCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  const length = Math.random() > 0.5 ? 6 : 5;
  let code = '';
  for (let i = 0; i < length; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

function normalizeMaxPlayers(value) {
  if (value === null || value === undefined || value === 0 || value === '0') {
    return 0;
  }

  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 2) {
    throw new Error('Max players must be at least 2 when a cap is set');
  }

  return parsed;
}

function publicMaxPlayers(value) {
  return value && value > 0 ? value : null;
}

function serializePlayer(row) {
  return {
    id: row.id,
    username: row.username || row.display_name,
    displayName: row.display_name,
    avatar: row.avatar_url,
    avatarUrl: row.avatar_url,
    status: row.status || 'active',
    score: row.score || 0,
    streak: row.streak || 0,
    badges: row.badges || [],
    lastActive: (row.last_active || new Date()).toISOString(),
    level: row.level || 1,
  };
}

async function fetchLobbyPlayers(lobbyId) {
  const result = await query(
    `SELECT u.id,
            u.username,
            u.display_name,
            u.avatar_url,
            u.level,
            u.total_score AS score,
            u.current_streak AS streak,
            '[]'::json AS badges,
            COALESCE(lp.status, 'joined') AS status,
            lp.joined_at AS last_active
     FROM lobby_players lp
     JOIN users u ON u.id = lp.user_id
     WHERE lp.lobby_id = $1
     ORDER BY lp.joined_at ASC`,
    [lobbyId]
  );

  return result.rows.map(serializePlayer);
}

async function serializeLobby(lobby) {
  const players = await fetchLobbyPlayers(lobby.id);
  return {
    id: lobby.id,
    code: lobby.code,
    name: lobby.name,
    hostId: lobby.host_id,
    players,
    maxPlayers: publicMaxPlayers(lobby.max_players),
    playerCount: players.length,
    isPrivate: lobby.is_private,
    status: lobby.status,
    currentRound: lobby.current_round,
    totalRounds: lobby.total_rounds,
    votingPointsPerPlayer: lobby.voting_points_per_player,
    skipRule: lobby.skip_rule || 'majority',
    skipTimeLimitHours: lobby.skip_time_limit_hours || 24,
    createdAt: lobby.created_at,
    difficulty: lobby.difficulty || 'medium',
    hintPolicy: lobby.hint_policy || 'enabled',
    ranked: lobby.ranked || false,
    payloadLocked: lobby.payload_locked || false,
  };
}

async function getPlayerLobbyParticipation(userId, excludeLobbyId = null) {
  const planningResult = await query(
    `SELECT COUNT(*) AS planning_count
     FROM lobby_players lp
     JOIN lobbies l ON l.id = lp.lobby_id
     WHERE lp.user_id = $1
       AND l.status = 'waiting'
       AND ($2::uuid IS NULL OR l.id != $2)`,
    [userId, excludeLobbyId]
  );

  const activeWarsResult = await query(
    `SELECT COUNT(*) AS active_count
     FROM lobby_players lp
     JOIN lobbies l ON l.id = lp.lobby_id
     WHERE lp.user_id = $1
       AND l.status = 'playing'
       AND ($2::uuid IS NULL OR l.id != $2)`,
    [userId, excludeLobbyId]
  );

  return {
    planningCount: parseInt(planningResult.rows[0].planning_count, 10),
    activeCount: parseInt(activeWarsResult.rows[0].active_count, 10),
  };
}

async function getPreferredPlanningLobby(userId) {
  const result = await query(
    `SELECT l.*,
            (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) AS player_count
     FROM lobby_players lp
     JOIN lobbies l ON l.id = lp.lobby_id
     WHERE lp.user_id = $1
       AND l.status = 'waiting'
     ORDER BY
       (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) DESC,
       l.created_at DESC
     LIMIT 1`,
    [userId]
  );

  return result.rows[0] || null;
}

function emitSystemChatNotice(io, lobbyId, message) {
  io.to(`lobby:${lobbyId}`).emit('chat-message', {
    id: `system_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
    senderId: 'system',
    senderName: 'Mind Wars',
    message,
    timestamp: new Date().toISOString(),
  });
}

module.exports = (io, socket) => {
  // Create lobby
  socket.on('create-lobby', async (data, callback) => {
    try {
      logger.info(`[create-lobby] Received event from ${socket.userId}`);
      logger.info(`[create-lobby] Data: ${JSON.stringify(data)}`);
      logger.info(`[create-lobby] Callback function exists: ${typeof callback === 'function'}`);

      const {
        name,
        maxPlayers = 0,
        isPrivate = true,
        totalRounds = 3,
        votingPointsPerPlayer = 10
      } = data;
      const normalizedMaxPlayers = normalizeMaxPlayers(maxPlayers);

      logger.info(`[create-lobby] Parsed: name=${name}, maxPlayers=${normalizedMaxPlayers || 'open'}, totalRounds=${totalRounds}`);

      const lobbyId = uuidv4();
      const code = generateLobbyCode();
      logger.info(`[create-lobby] Generated code: ${code}, lobbyId: ${lobbyId}`);

      const participation = await getPlayerLobbyParticipation(socket.userId);
      if (participation.planningCount > 0) {
        const existingLobby = await getPreferredPlanningLobby(socket.userId);
        if (existingLobby) {
          socket.join(`lobby:${existingLobby.id}`);
          return callback({
            success: true,
            resumedExisting: true,
            message: 'Resuming your existing planning lobby.',
            lobby: await serializeLobby(existingLobby),
          });
        }

        return callback({
          success: false,
          error: 'You can only be in one planning lobby at a time. Leave your current waiting lobby before creating another.',
        });
      }

      if (participation.activeCount >= 10) {
        return callback({
          success: false,
          error: 'You are already in 10 active Mind Wars. Finish or leave one before creating another.',
        });
      }

      // Create lobby in database
      await query(
        `INSERT INTO lobbies (id, code, name, host_id, max_players, is_private, status,
                              current_round, total_rounds, voting_points_per_player, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, 'waiting', 1, $7, $8, NOW())`,
        [lobbyId, code, name, socket.userId, normalizedMaxPlayers, isPrivate, totalRounds, votingPointsPerPlayer]
      );

      // Add host as player
      await query(
        `INSERT INTO lobby_players (lobby_id, user_id, joined_at)
         VALUES ($1, $2, NOW())`,
        [lobbyId, socket.userId]
      );

      // Join lobby room
      socket.join(`lobby:${lobbyId}`);

      logger.info(`[create-lobby] ✓ Lobby created: ${code} by user ${socket.userId}`);

      const response = {
        success: true,
        lobby: await serializeLobby({
          id: lobbyId,
          code,
          name,
          host_id: socket.userId,
          max_players: normalizedMaxPlayers,
          is_private: isPrivate,
          status: 'waiting',
          current_round: 1,
          total_rounds: totalRounds,
          voting_points_per_player: votingPointsPerPlayer,
          skip_rule: 'majority',
          skip_time_limit_hours: 24,
          player_count: 1,
        })
      };

      logger.info(`[create-lobby] Sending callback response to client`);
      if (typeof callback === 'function') {
        callback(response);
        logger.info(`[create-lobby] ✓ Callback invoked successfully`);
      } else {
        logger.error(`[create-lobby] ✗ Callback is not a function!`);
      }
    } catch (error) {
      logger.error('[create-lobby] ✗ Error:', error);
      if (typeof callback === 'function') {
        callback({ success: false, error: error.message });
      }
    }
  });

  // Join lobby
  socket.on('join-lobby', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Check if lobby exists and has space
      const lobbyResult = await query(
        `SELECT l.*,
                (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) as player_count
         FROM lobbies l WHERE l.id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      const lobby = lobbyResult.rows[0];

      const existingPlayer = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (existingPlayer.rows.length > 0) {
        socket.join(`lobby:${lobbyId}`);
        return callback({
          success: true,
          message: 'Already in lobby',
          lobby: await serializeLobby(lobby),
        });
      }

      if (lobby.max_players > 0 && parseInt(lobby.player_count) >= lobby.max_players) {
        return callback({ success: false, error: 'Lobby is full' });
      }

      if (lobby.status !== 'waiting') {
        return callback({ success: false, error: 'Lobby has already started' });
      }

      const participation = await getPlayerLobbyParticipation(socket.userId);
      if (participation.planningCount > 0) {
        const existingLobby = await getPreferredPlanningLobby(socket.userId);
        if (existingLobby) {
          socket.join(`lobby:${existingLobby.id}`);
          return callback({
            success: true,
            resumedExisting: true,
            message: 'Resuming your existing planning lobby.',
            lobby: await serializeLobby(existingLobby),
          });
        }

        return callback({
          success: false,
          error: 'You can only be in one planning lobby at a time. Leave your current waiting lobby before joining another.',
        });
      }

      if (participation.activeCount >= 10) {
        return callback({
          success: false,
          error: 'You are already in 10 active Mind Wars. Finish or leave one before joining another.',
        });
      }

      // Add player to lobby
      await query(
        `INSERT INTO lobby_players (lobby_id, user_id, joined_at)
         VALUES ($1, $2, NOW())`,
        [lobbyId, socket.userId]
      );

      // Join lobby room
      socket.join(`lobby:${lobbyId}`);

      // Get user info
      const userResult = await query(
        `SELECT username, display_name, avatar_url, level FROM users WHERE id = $1`,
        [socket.userId]
      );

      const user = userResult.rows[0];

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-joined', {
        player: serializePlayer({
          id: socket.userId,
          username: user.username,
          display_name: user.display_name,
          avatar_url: user.avatar_url,
          level: user.level,
          status: 'active',
          score: 0,
          streak: 0,
          badges: [],
          last_active: new Date(),
        }),
        userId: socket.userId,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        level: user.level,
        timestamp: new Date().toISOString()
      });
      emitSystemChatNotice(io, lobbyId, `${user.display_name} joined the lobby.`);

      logger.info(`User ${socket.userId} joined lobby ${lobbyId}`);

      callback({
        success: true,
        lobby: await serializeLobby(lobby)
      });
    } catch (error) {
      logger.error('Join lobby error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Join lobby by code
  socket.on('join-lobby-by-code', async (data, callback) => {
    try {
      logger.info(`[join-lobby-by-code] Event received from socket ${socket.id}, user ${socket.userId}`);
      logger.info(`[join-lobby-by-code] Data: ${JSON.stringify(data)}`);
      logger.info(`[join-lobby-by-code] Callback function exists: ${typeof callback === 'function'}`);

      const { code } = data;
      logger.info(`[join-lobby-by-code] Attempting to join lobby with code: ${code}`);

      // Find lobby by code
      const lobbyResult = await query(
        `SELECT l.*,
                (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) as player_count
         FROM lobbies l WHERE l.code = $1`,
        [code.toUpperCase()]
      );

      logger.info(`[join-lobby-by-code] Query result: ${lobbyResult.rows.length} lobby(ies) found`);

      if (lobbyResult.rows.length === 0) {
        logger.warn(`[join-lobby-by-code] Lobby not found with code ${code}`);
        return callback({ success: false, error: 'Lobby not found with that code' });
      }

      const lobby = lobbyResult.rows[0];
      logger.info(`[join-lobby-by-code] Found lobby: id=${lobby.id}, name=${lobby.name}, status=${lobby.status}`);

      logger.info(`[join-lobby-by-code] Checking if user ${socket.userId} is already in lobby ${lobby.id}`);
      const existingPlayer = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobby.id, socket.userId]
      );

      if (existingPlayer.rows.length > 0) {
        logger.info(`[join-lobby-by-code] User already in lobby, just rejoining room`);
        socket.join(`lobby:${lobby.id}`);
        return callback({
          success: true,
          lobby: await serializeLobby(lobby)
        });
      }

      // Check if lobby exists and has space
      logger.info(`[join-lobby-by-code] Player count: ${parseInt(lobby.player_count)}, max: ${lobby.max_players}`);
      if (lobby.max_players > 0 && parseInt(lobby.player_count) >= lobby.max_players) {
        logger.warn(`[join-lobby-by-code] Lobby is full`);
        return callback({ success: false, error: 'Lobby is full' });
      }

      logger.info(`[join-lobby-by-code] Lobby status: ${lobby.status}`);
      if (lobby.status !== 'waiting') {
        logger.warn(`[join-lobby-by-code] Lobby has already started`);
        return callback({ success: false, error: 'Lobby has already started' });
      }

      const participation = await getPlayerLobbyParticipation(socket.userId);
      if (participation.planningCount > 0) {
        const existingLobby = await getPreferredPlanningLobby(socket.userId);
        if (existingLobby) {
          socket.join(`lobby:${existingLobby.id}`);
          return callback({
            success: true,
            resumedExisting: true,
            message: 'Resuming your existing planning lobby.',
            lobby: await serializeLobby(existingLobby),
          });
        }

        return callback({
          success: false,
          error: 'You can only be in one planning lobby at a time. Leave your current waiting lobby before joining another.',
        });
      }

      if (participation.activeCount >= 10) {
        return callback({
          success: false,
          error: 'You are already in 10 active Mind Wars. Finish or leave one before joining another.',
        });
      }

      // Add player to lobby
      logger.info(`[join-lobby-by-code] Adding player ${socket.userId} to lobby ${lobby.id}`);
      await query(
        `INSERT INTO lobby_players (lobby_id, user_id, joined_at)
         VALUES ($1, $2, NOW())`,
        [lobby.id, socket.userId]
      );
      logger.info(`[join-lobby-by-code] ✓ Player added to database`);

      // Join lobby room
      logger.info(`[join-lobby-by-code] Joining socket to room lobby:${lobby.id}`);
      socket.join(`lobby:${lobby.id}`);
      logger.info(`[join-lobby-by-code] ✓ Socket joined room`);

      // Get user info
      const userResult = await query(
        `SELECT username, display_name, avatar_url, level FROM users WHERE id = $1`,
        [socket.userId]
      );

      const user = userResult.rows[0];
      logger.info(`[join-lobby-by-code] Got user info: ${user.display_name}`);

      // Notify other players
      logger.info(`[join-lobby-by-code] Notifying other players in lobby:${lobby.id} about new player`);
      socket.to(`lobby:${lobby.id}`).emit('player-joined', {
        player: serializePlayer({
          id: socket.userId,
          username: user.username,
          display_name: user.display_name,
          avatar_url: user.avatar_url,
          level: user.level,
          status: 'active',
          score: 0,
          streak: 0,
          badges: [],
          last_active: new Date(),
        }),
        userId: socket.userId,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        level: user.level,
        timestamp: new Date().toISOString()
      });
      emitSystemChatNotice(io, lobby.id, `${user.display_name} joined the lobby.`);

      logger.info(`[join-lobby-by-code] ✓ User ${socket.userId} successfully joined lobby ${lobby.id} by code ${code}`);

      callback({
        success: true,
        lobby: await serializeLobby(lobby)
      });
    } catch (error) {
      logger.error('Join lobby by code error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Leave lobby
  socket.on('leave-lobby', async (data, callback) => {
    try {
      const { lobbyId } = data;

      const leavingUserResult = await query(
        `SELECT username, display_name, avatar_url FROM users WHERE id = $1`,
        [socket.userId]
      );
      const leavingUser = leavingUserResult.rows[0];

      // Remove player from lobby
      await query(
        `DELETE FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      // Leave lobby room
      socket.leave(`lobby:${lobbyId}`);

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-left', {
        playerId: socket.userId,
        userId: socket.userId,
        username: leavingUser?.username,
        displayName: leavingUser?.display_name,
        avatarUrl: leavingUser?.avatar_url,
        timestamp: new Date().toISOString()
      });
      emitSystemChatNotice(io, lobbyId, `${leavingUser?.display_name || leavingUser?.username || 'A player'} left the lobby.`);

      const remainingPlayersResult = await query(
        `SELECT user_id, joined_at
         FROM lobby_players
         WHERE lobby_id = $1
         ORDER BY joined_at ASC`,
        [lobbyId]
      );

      if (remainingPlayersResult.rows.length === 0) {
        await query(`DELETE FROM lobbies WHERE id = $1 AND status = 'waiting'`, [lobbyId]);
      } else {
        const lobbyResult = await query(
          `SELECT host_id, status FROM lobbies WHERE id = $1`,
          [lobbyId]
        );

        const lobby = lobbyResult.rows[0];
        if (lobby && lobby.status === 'waiting' && lobby.host_id === socket.userId) {
          const nextHostId = remainingPlayersResult.rows[0].user_id;
          await query(`UPDATE lobbies SET host_id = $1 WHERE id = $2`, [nextHostId, lobbyId]);

          io.to(`lobby:${lobbyId}`).emit('host-changed', {
            lobbyId,
            hostId: nextHostId,
            timestamp: new Date().toISOString()
          });
          emitSystemChatNotice(io, lobbyId, 'Host changed for this lobby.');
        }
      }

      logger.info(`User ${socket.userId} left lobby ${lobbyId}`);

      callback({ success: true, message: 'Left lobby successfully' });
    } catch (error) {
      logger.error('Leave lobby error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Kick player (host only)
  socket.on('kick-player', async (data, callback) => {
    try {
      const { lobbyId, userId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can kick players' });
      }

      const playerResult = await query(
        `SELECT username, display_name FROM users WHERE id = $1`,
        [userId]
      );
      const kickedUser = playerResult.rows[0];

      // Remove player
      await query(
        `DELETE FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, userId]
      );

      // Notify kicked player
      io.to(`user:${userId}`).emit('kicked-from-lobby', {
        lobbyId,
        reason: 'Kicked by host',
        timestamp: new Date().toISOString()
      });

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-kicked', {
        playerId: userId,
        userId,
        username: kickedUser?.username,
        displayName: kickedUser?.display_name,
        timestamp: new Date().toISOString()
      });

      logger.info(`User ${userId} kicked from lobby ${lobbyId} by host ${socket.userId}`);

      callback({ success: true, message: 'Player kicked successfully' });
    } catch (error) {
      logger.error('Kick player error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Transfer host (host only)
  socket.on('transfer-host', async (data, callback) => {
    try {
      const { lobbyId, newHostId } = data;

      // Verify requester is current host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can transfer host role' });
      }

      // Update host
      await query(
        `UPDATE lobbies SET host_id = $1 WHERE id = $2`,
        [newHostId, lobbyId]
      );

      const newHostResult = await query(
        `SELECT username, display_name FROM users WHERE id = $1`,
        [newHostId]
      );
      const newHost = newHostResult.rows[0];

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('host-transferred', {
        oldHostId: socket.userId,
        newHostId,
        newHostUsername: newHost?.display_name || newHost?.username || 'New host',
        timestamp: new Date().toISOString()
      });

      logger.info(`Host transferred in lobby ${lobbyId}: ${socket.userId} -> ${newHostId}`);

      callback({ success: true, message: 'Host transferred successfully' });
    } catch (error) {
      logger.error('Transfer host error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Close lobby (host only)
  socket.on('close-lobby', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can close lobby' });
      }

      // Update lobby status
      await query(
        `UPDATE lobbies SET status = 'closed' WHERE id = $1`,
        [lobbyId]
      );

      await query(
        `DELETE FROM lobby_players WHERE lobby_id = $1`,
        [lobbyId]
      );

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('lobby-closed', {
        lobbyId,
        timestamp: new Date().toISOString()
      });

      logger.info(`Lobby ${lobbyId} closed by host ${socket.userId}`);

      callback({ success: true, message: 'Lobby closed successfully' });
    } catch (error) {
      logger.error('Close lobby error', error);
      callback({ success: false, error: error.message });
    }
  });

  socket.on('list-my-lobbies', async (data, callback) => {
    try {
      const { limit = 20 } = data || {};
      const normalizedLimit = Math.min(Math.max(parseInt(limit, 10) || 20, 1), 100);

      const result = await query(
        `SELECT l.*,
                (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) AS player_count
         FROM lobby_players lp
         JOIN lobbies l ON l.id = lp.lobby_id
         WHERE lp.user_id = $1
           AND l.status IN ('waiting', 'playing')
         ORDER BY
           CASE l.status WHEN 'waiting' THEN 0 ELSE 1 END,
           l.created_at DESC
         LIMIT $2`,
        [socket.userId, normalizedLimit]
      );

      const lobbies = [];
      for (const lobby of result.rows) {
        lobbies.push(await serializeLobby(lobby));
      }

      callback({ success: true, lobbies });
    } catch (error) {
      logger.error('List my lobbies error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Update lobby settings (host only)
  socket.on('update-lobby-settings', async (settings, callback) => {
    try {
      const {
        lobbyId,
        maxPlayers,
        totalRounds,
        votingPointsPerPlayer,
        skipRule,
        skipTimeLimitHours
      } = settings;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can update settings' });
      }

      // Validate skip rule if provided
      if (skipRule && !['majority', 'unanimous', 'time_based'].includes(skipRule)) {
        return callback({ success: false, error: 'Invalid skip rule. Must be majority, unanimous, or time_based' });
      }

      // Validate skip time limit if provided
      if (skipTimeLimitHours !== undefined && (skipTimeLimitHours < 1 || skipTimeLimitHours > 72)) {
        return callback({ success: false, error: 'Skip time limit must be between 1 and 72 hours' });
      }

      if (Object.prototype.hasOwnProperty.call(settings, 'maxPlayers')) {
        const normalizedMaxPlayers = normalizeMaxPlayers(maxPlayers);
        const playerCountResult = await query(
          `SELECT COUNT(*) AS player_count FROM lobby_players WHERE lobby_id = $1`,
          [lobbyId]
        );
        const currentPlayerCount = parseInt(playerCountResult.rows[0].player_count, 10);
        if (normalizedMaxPlayers > 0 && normalizedMaxPlayers < currentPlayerCount) {
          return callback({ success: false, error: `Max players cannot be less than current player count (${currentPlayerCount})` });
        }
      }

      // Update settings
      const updates = [];
      const values = [];
      let paramCount = 1;

      if (Object.prototype.hasOwnProperty.call(settings, 'maxPlayers')) {
        updates.push(`max_players = $${paramCount++}`);
        values.push(normalizeMaxPlayers(maxPlayers));
      }

      if (totalRounds) {
        updates.push(`total_rounds = $${paramCount++}`);
        values.push(totalRounds);
      }

      if (votingPointsPerPlayer) {
        updates.push(`voting_points_per_player = $${paramCount++}`);
        values.push(votingPointsPerPlayer);
      }

      if (skipRule) {
        updates.push(`skip_rule = $${paramCount++}`);
        values.push(skipRule);
      }

      if (skipTimeLimitHours !== undefined) {
        updates.push(`skip_time_limit_hours = $${paramCount++}`);
        values.push(skipTimeLimitHours);
      }

      values.push(lobbyId);

      let updatedLobby = null;

      if (updates.length > 0) {
        await query(
          `UPDATE lobbies SET ${updates.join(', ')} WHERE id = $${paramCount}`,
          values
        );

        const updatedLobbyResult = await query(
          `SELECT l.*,
                  (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) AS player_count
           FROM lobbies l
           WHERE l.id = $1`,
          [lobbyId]
        );
        updatedLobby = updatedLobbyResult.rows[0];
      }

      // Notify all players
      socket.to(`lobby:${lobbyId}`).emit('lobby-settings-updated', {
        maxPlayers: Object.prototype.hasOwnProperty.call(settings, 'maxPlayers')
          ? publicMaxPlayers(normalizeMaxPlayers(maxPlayers))
          : undefined,
        totalRounds,
        votingPointsPerPlayer,
        skipRule,
        skipTimeLimitHours,
        timestamp: new Date().toISOString()
      });

      logger.info(`Lobby ${lobbyId} settings updated by host ${socket.userId}`, {
        skipRule,
        skipTimeLimitHours
      });

      callback({
        success: true,
        message: 'Settings updated successfully',
        lobby: updatedLobby ? {
          id: updatedLobby.id,
          code: updatedLobby.code,
          name: updatedLobby.name,
          hostId: updatedLobby.host_id,
          maxPlayers: publicMaxPlayers(updatedLobby.max_players),
          playerCount: parseInt(updatedLobby.player_count, 10),
          isPrivate: updatedLobby.is_private,
          status: updatedLobby.status,
          currentRound: updatedLobby.current_round,
          totalRounds: updatedLobby.total_rounds,
          votingPointsPerPlayer: updatedLobby.voting_points_per_player,
          skipRule: updatedLobby.skip_rule || 'majority',
          skipTimeLimitHours: updatedLobby.skip_time_limit_hours || 24,
        } : undefined,
      });
    } catch (error) {
      logger.error('Update lobby settings error', error);
      callback({ success: false, error: error.message });
    }
  });

  // List lobbies
  socket.on('list-lobbies', async (data, callback) => {
    try {
      const { status = 'waiting', limit = 20 } = data;

      const result = await query(
        `SELECT l.*, u.display_name as host_name,
                (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) as player_count
         FROM lobbies l
         JOIN users u ON l.host_id = u.id
         WHERE l.is_private = false AND l.status = $1
         ORDER BY l.created_at DESC
         LIMIT $2`,
        [status, limit]
      );

      const lobbies = result.rows.map(lobby => ({
        id: lobby.id,
        code: lobby.code,
        name: lobby.name,
        hostName: lobby.host_name,
        maxPlayers: publicMaxPlayers(lobby.max_players),
        playerCount: parseInt(lobby.player_count),
        status: lobby.status,
        createdAt: lobby.created_at,
        skipRule: lobby.skip_rule || 'majority',
        skipTimeLimitHours: lobby.skip_time_limit_hours || 24
      }));

      callback({ success: true, lobbies });
    } catch (error) {
      logger.error('List lobbies error', error);
      callback({ success: false, error: error.message });
    }
  });

  // ============================================================================
  // Phase 2: War Configuration & Immutable Payloads
  // ============================================================================

  // Update war configuration (host only)
  socket.on('update-war-config', async (data, callback) => {
    try {
      logger.info(`[update-war-config] Received from user ${socket.userId}`);
      const { lobbyId, difficulty, hintPolicy, ranked, gamePack, manualGameIds } = data;

      // Verify host ownership
      const lobbyResult = await query('SELECT host_id FROM lobbies WHERE id = $1', [lobbyId]);
      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }
      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can configure war' });
      }

      // Update lobby with config
      await query(
        `UPDATE lobbies SET difficulty = $1, hint_policy = $2, ranked = $3, game_pack = $4
         WHERE id = $5`,
        [difficulty, hintPolicy, ranked, gamePack, lobbyId]
      );

      logger.info(`[update-war-config] ✓ Config updated for lobby ${lobbyId}: difficulty=${difficulty}, hintPolicy=${hintPolicy}, ranked=${ranked}`);

      const config = {
        difficulty,
        hintPolicy,
        ranked,
        gamePack,
        manualGameIds: manualGameIds || []
      };

      // Broadcast to all players in lobby
      io.to(`lobby:${lobbyId}`).emit('war-config-updated', config);

      callback({ success: true, config });
    } catch (error) {
      logger.error('[update-war-config] Error:', error);
      callback({ success: false, error: error.message });
    }
  });

  // Set player ready state
  socket.on('set-player-ready', async (data, callback) => {
    try {
      logger.info(`[set-player-ready] User ${socket.userId} marked ready`);
      const { lobbyId } = data;

      // Mark player as ready
      await query(
        `UPDATE lobby_players SET is_ready = true, ready_at = NOW()
         WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      // Broadcast player ready state
      io.to(`lobby:${lobbyId}`).emit('player-ready', {
        userId: socket.userId,
        isReady: true,
        timestamp: new Date().toISOString()
      });

      // Check if all players are ready
      const allReadyResult = await query(
        `SELECT COUNT(*) as total,
                COUNT(CASE WHEN is_ready = true THEN 1 END) as ready
         FROM lobby_players WHERE lobby_id = $1`,
        [lobbyId]
      );

      const { total, ready } = allReadyResult.rows[0];
      logger.info(`[set-player-ready] Lobby ${lobbyId}: ${ready}/${total} players ready`);

      if (parseInt(ready) === parseInt(total) && parseInt(total) > 0) {
        logger.info(`[set-player-ready] All players ready! Generating immutable payload...`);
        await _generateImmutablePayload(lobbyId, io);
      }

      callback({ success: true });
    } catch (error) {
      logger.error('[set-player-ready] Error:', error);
      callback({ success: false, error: error.message });
    }
  });

  // ============================================================================
  // Helper Functions
  // ============================================================================

  // Simple hash function for deterministic seed generation
  function _hashFunction(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash);
  }

  // Generate immutable Mind War payload with deterministic game indices
  async function _generateImmutablePayload(lobbyId, io) {
    try {
      logger.info(`[_generateImmutablePayload] Starting for lobby ${lobbyId}`);

      // 1. Load lobby configuration
      const lobbyResult = await query(
        `SELECT id, total_rounds, difficulty, hint_policy, ranked FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        logger.error(`[_generateImmutablePayload] Lobby not found: ${lobbyId}`);
        return;
      }

      const lobby = lobbyResult.rows[0];
      const mindWarId = uuidv4();
      const baseSeed = mindWarId.replace(/-/g, '').substring(0, 16);

      logger.info(`[_generateImmutablePayload] Generated mindWarId: ${mindWarId}, baseSeed: ${baseSeed}`);

      // 2. Get top voted games (voting should have completed before this)
      const votesResult = await query(
        `SELECT game_id, SUM(points) as total_points
         FROM votes
         WHERE voting_id IN (
           SELECT id FROM voting_sessions WHERE lobby_id = $1
         )
         GROUP BY game_id
         ORDER BY total_points DESC
         LIMIT $2`,
        [lobbyId, lobby.total_rounds]
      );

      logger.info(`[_generateImmutablePayload] Found ${votesResult.rows.length} voted games`);

      // 3. Build game sequence with deterministic indices
      const gameSequence = votesResult.rows.map((vote, roundIndex) => {
        const gameIndex = _hashFunction(`${mindWarId}:round:${roundIndex}:${vote.game_id}`) % 1000000;
        const gameSlot = {
          roundNumber: roundIndex + 1,
          gameId: vote.game_id,
          difficulty: lobby.difficulty,
          hintPolicy: lobby.hint_policy,
          gameIndex,
          seed: `${baseSeed}_${roundIndex + 1}_${gameIndex}`
        };

        if (vote.game_id === 'rotation_master') {
          gameSlot.state = {
            challengeSet: rotationMasterPayload.generateBattleChallengeSet({
              battleSeed: gameSlot.seed,
              gameIndex,
              difficulty: lobby.difficulty,
              hintPolicy: lobby.hint_policy,
            }),
          };
        } else if (vote.game_id === 'path_finder') {
          gameSlot.state = {
            challengeSet: pathFinderPayload.generateBattleChallengeSet({
              battleSeed: gameSlot.seed,
              gameIndex,
              difficulty: lobby.difficulty,
              hintPolicy: lobby.hint_policy,
            }),
          };
        }

        return gameSlot;
      });

      logger.info(`[_generateImmutablePayload] Generated sequence: ${JSON.stringify(gameSequence)}`);

      // 4. Build immutable payload
      const payload = {
        mindWarId,
        lobbyId,
        gameSequence,
        difficulty: lobby.difficulty,
        hintPolicy: lobby.hint_policy,
        ranked: lobby.ranked,
        scoringModelVersion: '1.0',
        createdAt: new Date().toISOString()
      };

      // 5. Persist payload
      await query(
        `INSERT INTO mind_war_payloads (lobby_id, mind_war_id, game_sequence, difficulty, hint_policy, ranked, scoring_model_version)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [lobbyId, mindWarId, JSON.stringify(payload), lobby.difficulty, lobby.hint_policy, lobby.ranked]
      );

      // 6. Update lobby with payload lock
      await query(
        `UPDATE lobbies SET payload_locked = true, payload_locked_at = NOW(), mind_war_id = $1
         WHERE id = $2`,
        [mindWarId, lobbyId]
      );

      logger.info(`[_generateImmutablePayload] ✓ Payload locked for lobby ${lobbyId}, mindWarId: ${mindWarId}`);

      // 7. Broadcast to all clients
      io.to(`lobby:${lobbyId}`).emit('payload-locked', payload);

      logger.info(`[_generateImmutablePayload] ✓ Payload broadcast to all clients`);
    } catch (error) {
      logger.error('[_generateImmutablePayload] Error:', error);
    }
  }
};
