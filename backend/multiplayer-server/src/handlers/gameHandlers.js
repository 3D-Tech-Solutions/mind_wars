const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');
const rotationMasterPayload = require('../utils/rotationMasterPayload');

const logger = createLogger('game-handlers');

module.exports = (io, socket) => {
  // Start game (host only) - loads immutable payload
  socket.on('start-game', async (data, callback) => {
    try {
      logger.info(`[start-game] Received from user ${socket.userId}`);
      const { lobbyId } = data;

      // 1. Verify requester is host
      const lobbyResult = await query(
        `SELECT id, host_id, status, payload_locked FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        logger.error(`[start-game] Lobby not found: ${lobbyId}`);
        return callback({ success: false, error: 'Lobby not found' });
      }

      const lobby = lobbyResult.rows[0];

      if (lobby.host_id !== socket.userId) {
        logger.warn(`[start-game] Non-host tried to start: ${socket.userId}`);
        return callback({ success: false, error: 'Only host can start game' });
      }

      if (lobby.status !== 'waiting') {
        logger.warn(`[start-game] Game already started, status: ${lobby.status}`);
        return callback({ success: false, error: 'Game already started' });
      }

      if (!lobby.payload_locked) {
        logger.warn(`[start-game] Payload not locked yet`);
        return callback({ success: false, error: 'Payload not locked. All players must be ready.' });
      }

      // 2. Load immutable payload
      const payloadResult = await query(
        `SELECT game_sequence, mind_war_id FROM mind_war_payloads WHERE lobby_id = $1`,
        [lobbyId]
      );

      if (payloadResult.rows.length === 0) {
        logger.error(`[start-game] Payload not found for lobby: ${lobbyId}`);
        return callback({ success: false, error: 'Payload not found' });
      }

      const payload = payloadResult.rows[0];
      const gameSequence = JSON.parse(payload.game_sequence).gameSequence || [];

      if (gameSequence.length === 0) {
        logger.error(`[start-game] Empty game sequence for lobby: ${lobbyId}`);
        return callback({ success: false, error: 'No games selected' });
      }

      const firstGameSlot = gameSequence[0];
      logger.info(`[start-game] Starting first game: ${firstGameSlot.gameId}, index: ${firstGameSlot.gameIndex}`);

      // 3. Update lobby status
      await query(
        `UPDATE lobbies SET status = 'playing', started_at = NOW() WHERE id = $1`,
        [lobbyId]
      );

      // 4. Build Game object with deterministic index and seed
      const game = {
        id: firstGameSlot.gameId,
        mindWarId: payload.mind_war_id,
        lobbyId,
        roundNumber: firstGameSlot.roundNumber,
        difficulty: firstGameSlot.difficulty,
        hintPolicy: firstGameSlot.hintPolicy,
        gameIndex: firstGameSlot.gameIndex,  // Deterministic index for this game instance
        seed: firstGameSlot.seed,             // Seed for pseudo-random game generation
        currentTurn: 1,
        currentPlayerId: socket.userId,       // Host goes first
        state: firstGameSlot.state || {},
        completed: false
      };

      logger.info(`[start-game] ✓ Game object created for round ${game.roundNumber}: ${game.gameId} (index: ${game.gameIndex})`);

      // 5. Broadcast game-started with full Game object (not just lobbyId)
      io.to(`lobby:${lobbyId}`).emit('game-started', {
        game,
        timestamp: new Date().toISOString()
      });

      logger.info(`[start-game] ✓ game-started broadcast to all players in lobby ${lobbyId}`);

      callback({ success: true, game });
    } catch (error) {
      logger.error('[start-game] Error:', error);
      callback({ success: false, error: error.message });
    }
  });

  // Make turn - records move and flips turn
  socket.on('make-turn', async (data, callback) => {
    try {
      logger.info(`[make-turn] Received from user ${socket.userId}`);
      const { lobbyId, gameId, roundNumber, turnData } = data;

      // 1. Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        logger.warn(`[make-turn] Player not in lobby: user ${socket.userId}, lobby ${lobbyId}`);
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // 2. Get current game state (from payload)
      const payloadResult = await query(
        `SELECT game_sequence FROM mind_war_payloads WHERE lobby_id = $1`,
        [lobbyId]
      );

      if (payloadResult.rows.length === 0) {
        logger.error(`[make-turn] Payload not found for lobby: ${lobbyId}`);
        return callback({ success: false, error: 'Game payload not found' });
      }

      const payload = JSON.parse(payloadResult.rows[0].game_sequence);
      const gameSequence = payload.gameSequence || [];
      const currentGameSlot = gameSequence.find(g => g.roundNumber === roundNumber);

      if (!currentGameSlot) {
        logger.error(`[make-turn] Game slot not found for round: ${roundNumber}`);
        return callback({ success: false, error: 'Game slot not found' });
      }

      // 3. Get the other player (for turn flipping)
      const playersResult = await query(
        `SELECT user_id FROM lobby_players WHERE lobby_id = $1 AND user_id != $2`,
        [lobbyId, socket.userId]
      );

      const otherPlayerId = playersResult.rows.length > 0 ? playersResult.rows[0].user_id : null;

      logger.info(`[make-turn] Turn flipping from ${socket.userId} to ${otherPlayerId}`);

      // 4. Build updated game state with flipped turn
      const updatedGameState = {
        currentTurn: 2,  // Next turn
        currentPlayerId: otherPlayerId,
        lastMoveBy: socket.userId,
        lastMoveData: turnData,
        timestamp: new Date().toISOString()
      };

      // 5. Notify all players about the move
      socket.to(`lobby:${lobbyId}`).emit('turn-made', {
        lobbyId,
        gameId,
        roundNumber,
        userId: socket.userId,
        turnData,
        updatedGameState,
        timestamp: new Date().toISOString()
      });

      logger.info(`[make-turn] ✓ Turn made and broadcast for game ${gameId} in lobby ${lobbyId}`);

      callback({ success: true, updatedGameState });
    } catch (error) {
      logger.error('[make-turn] Error:', error);
      callback({ success: false, error: error.message });
    }
  });

  // Submit game result - persists score and checks for round/game completion
  socket.on('submit-game-result', async (data, callback) => {
    try {
      logger.info(`[submit-game-result] Received from user ${socket.userId}`);
      const { lobbyId, gameId, roundNumber, score, timeTaken, hintsUsed, perfect, gameData } = data;

      // 1. Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        logger.warn(`[submit-game-result] Player not in lobby`);
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // 2. Load lobby to get metadata
      const lobbyResult = await query(
        `SELECT id, mind_war_id, total_rounds FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      const lobby = lobbyResult.rows[0];

      let validatedScore = score;
      let validatedTimeTaken = timeTaken;
      let validatedHintsUsed = hintsUsed || 0;
      let validatedPerfect = perfect || false;

      if (gameId === 'rotation_master') {
        const payloadResult = await query(
          `SELECT game_sequence FROM mind_war_payloads WHERE lobby_id = $1`,
          [lobbyId]
        );

        if (payloadResult.rows.length === 0) {
          return callback({ success: false, error: 'Game payload not found' });
        }

        const payload = JSON.parse(payloadResult.rows[0].game_sequence);
        const currentGameSlot = (payload.gameSequence || []).find((slot) => slot.roundNumber === roundNumber);

        if (!currentGameSlot || !currentGameSlot.state || !currentGameSlot.state.challengeSet) {
          return callback({ success: false, error: 'Rotation Master payload missing challenge set' });
        }

        const verification = rotationMasterPayload.verifySubmission({
          challengeSet: currentGameSlot.state.challengeSet,
          submission: gameData,
        });

        if (!verification.valid) {
          logger.warn(`[submit-game-result] Rotation Master verification failed: ${verification.error}`);
          return callback({ success: false, error: verification.error });
        }

        validatedScore = verification.validatedScore;
        validatedTimeTaken = verification.totalTimeMs;
        validatedHintsUsed = verification.hintsUsed;
        validatedPerfect = verification.perfect;
      }

      // 3. Insert game result
      await query(
        `INSERT INTO game_results (lobby_id, user_id, game_id, score, time_taken, hints_used, perfect, session_type, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'mind_war', NOW())`,
        [
          lobbyId,
          socket.userId,
          gameId,
          validatedScore,
          validatedTimeTaken,
          validatedHintsUsed,
          validatedPerfect,
        ]
      );

      logger.info(`[submit-game-result] ✓ Result saved: ${socket.userId} scored ${validatedScore} on ${gameId}`);

      // 4. Check if both players have submitted (simplistic - would need better tracking)
      // For MVP, just notify other players
      socket.to(`lobby:${lobbyId}`).emit('game-result-submitted', {
        userId: socket.userId,
        gameId,
        roundNumber,
        score: validatedScore,
        timeTaken: validatedTimeTaken,
        hintsUsed: validatedHintsUsed,
        perfect: validatedPerfect,
        timestamp: new Date().toISOString()
      });

      // 5. TODO: Implement round completion detection
      // - Check if all players submitted for this round
      // - If yes, emit 'round-complete' with scores
      // - If all rounds done, emit 'game-ended'

      callback({ success: true, message: 'Result submitted successfully' });
    } catch (error) {
      logger.error('[submit-game-result] Error:', error);
      callback({ success: false, error: error.message });
    }
  });
};
