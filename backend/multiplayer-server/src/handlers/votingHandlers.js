const { v4: uuidv4 } = require('uuid');
const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');

const logger = createLogger('voting-handlers');

module.exports = (io, socket) => {
  // Start voting (host only)
  socket.on('start-voting', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id, voting_points_per_player FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      const lobby = lobbyResult.rows[0];

      if (lobby.host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can start voting' });
      }

      const votingId = uuidv4();

      // Create voting session
      await query(
        `INSERT INTO voting_sessions (id, lobby_id, status, points_per_player, started_at)
         VALUES ($1, $2, 'active', $3, NOW())`,
        [votingId, lobbyId, lobby.voting_points_per_player]
      );

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('voting-started', {
        votingId,
        pointsPerPlayer: lobby.voting_points_per_player,
        timestamp: new Date().toISOString()
      });

      logger.info(`Voting started in lobby ${lobbyId} by host ${socket.userId}`);

      callback({
        success: true,
        votingId,
        pointsPerPlayer: lobby.voting_points_per_player
      });
    } catch (error) {
      logger.error('Start voting error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Vote for game
  socket.on('vote-game', async (data, callback) => {
    try {
      const { lobbyId, votingId, gameId, points } = data;

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Verify voting session is active
      const votingResult = await query(
        `SELECT status, points_per_player FROM voting_sessions WHERE id = $1 AND lobby_id = $2`,
        [votingId, lobbyId]
      );

      if (votingResult.rows.length === 0) {
        return callback({ success: false, error: 'Voting session not found' });
      }

      if (votingResult.rows[0].status !== 'active') {
        return callback({ success: false, error: 'Voting session is not active' });
      }

      // Check if user has already voted for this game
      const existingVote = await query(
        `SELECT points FROM votes WHERE voting_id = $1 AND user_id = $2 AND game_id = $3`,
        [votingId, socket.userId, gameId]
      );

      if (existingVote.rows.length > 0) {
        // Update existing vote
        await query(
          `UPDATE votes SET points = $1 WHERE voting_id = $2 AND user_id = $3 AND game_id = $4`,
          [points, votingId, socket.userId, gameId]
        );
      } else {
        // Insert new vote
        await query(
          `INSERT INTO votes (voting_id, user_id, game_id, points, created_at)
           VALUES ($1, $2, $3, $4, NOW())`,
          [votingId, socket.userId, gameId, points]
        );
      }

      // Get total votes for this game
      const totalResult = await query(
        `SELECT SUM(points) as total FROM votes WHERE voting_id = $1 AND game_id = $2`,
        [votingId, gameId]
      );

      const totalVotes = parseInt(totalResult.rows[0].total) || 0;

      // Notify all players
      socket.to(`lobby:${lobbyId}`).emit('vote-cast', {
        userId: socket.userId,
        gameId,
        points,
        totalVotes,
        timestamp: new Date().toISOString()
      });

      logger.info(`Vote cast in lobby ${lobbyId} by user ${socket.userId}: ${points} points for ${gameId}`);

      callback({ success: true, totalVotes });
    } catch (error) {
      logger.error('Vote game error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Remove vote
  socket.on('remove-vote', async (data, callback) => {
    try {
      const { lobbyId, votingId, gameId } = data;

      // Delete vote
      await query(
        `DELETE FROM votes WHERE voting_id = $1 AND user_id = $2 AND game_id = $3`,
        [votingId, socket.userId, gameId]
      );

      // Get updated total
      const totalResult = await query(
        `SELECT SUM(points) as total FROM votes WHERE voting_id = $1 AND game_id = $2`,
        [votingId, gameId]
      );

      const totalVotes = parseInt(totalResult.rows[0].total) || 0;

      // Notify all players
      socket.to(`lobby:${lobbyId}`).emit('vote-removed', {
        userId: socket.userId,
        gameId,
        totalVotes,
        timestamp: new Date().toISOString()
      });

      logger.info(`Vote removed in lobby ${lobbyId} by user ${socket.userId} for ${gameId}`);

      callback({ success: true, totalVotes });
    } catch (error) {
      logger.error('Remove vote error', error);
      callback({ success: false, error: error.message });
    }
  });

  // End voting (host only)
  socket.on('end-voting', async (data, callback) => {
    try {
      const { lobbyId, votingId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can end voting' });
      }

      // Update voting session
      await query(
        `UPDATE voting_sessions SET status = 'completed', ended_at = NOW() WHERE id = $1`,
        [votingId]
      );

      // Get voting results
      const results = await query(
        `SELECT game_id, SUM(points) as total_votes
         FROM votes WHERE voting_id = $1
         GROUP BY game_id
         ORDER BY total_votes DESC`,
        [votingId]
      );

      const votingResults = results.rows.map(r => ({
        gameId: r.game_id,
        totalVotes: parseInt(r.total_votes)
      }));

      // Get the top-ranked game for auto-start
      const selectedGameId = votingResults.length > 0 ? votingResults[0].gameId : null;

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('voting-ended', {
        votingId,
        results: votingResults,
        selectedGameId,  // Top-ranked game ID for automatic game start
        timestamp: new Date().toISOString()
      });

      logger.info(`Voting ended in lobby ${lobbyId} by host ${socket.userId}. Selected game: ${selectedGameId}`);

      callback({ success: true, results: votingResults });
    } catch (error) {
      logger.error('End voting error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Initiate vote-to-skip session (Selection Phase only)
  socket.on('initiate-skip-vote', async (data, callback) => {
    try {
      const { lobbyId, battleNumber, playerIdToSkip } = data;

      // Verify requester is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Cannot vote to skip yourself
      if (playerIdToSkip === socket.userId) {
        return callback({ success: false, error: 'Cannot skip yourself' });
      }

      // Get lobby configuration
      const lobbyResult = await query(
        `SELECT skip_rule, skip_time_limit_hours FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      const lobby = lobbyResult.rows[0];

      // Check if active skip session already exists for this player
      const existingSession = await query(
        `SELECT id FROM vote_to_skip_sessions
         WHERE lobby_id = $1 AND battle_number = $2 AND player_id_to_skip = $3 AND status = 'active'`,
        [lobbyId, battleNumber, playerIdToSkip]
      );

      if (existingSession.rows.length > 0) {
        return callback({ success: false, error: 'Skip vote already in progress for this player' });
      }

      // Count active players (excluding player to skip)
      const activePlayersResult = await query(
        `SELECT user_id FROM lobby_players WHERE lobby_id = $1 AND user_id != $2`,
        [lobbyId, playerIdToSkip]
      );

      const activePlayers = activePlayersResult.rows;
      const eligibleVoters = activePlayers.length;

      // Calculate votes required based on skip rule
      let votesRequired;
      if (lobby.skip_rule === 'majority') {
        votesRequired = Math.floor(eligibleVoters / 2) + 1; // strict majority
      } else if (lobby.skip_rule === 'unanimous') {
        votesRequired = eligibleVoters; // 100%
      } else if (lobby.skip_rule === 'time_based') {
        votesRequired = 0; // No votes needed for time-based
      }

      // For majority/unanimous, need at least 3 total players (2 eligible voters)
      if ((lobby.skip_rule === 'majority' || lobby.skip_rule === 'unanimous') && eligibleVoters < 2) {
        return callback({
          success: false,
          error: 'Need at least 3 players for voting-based skip rules'
        });
      }

      const sessionId = uuidv4();

      // Create skip session
      await query(
        `INSERT INTO vote_to_skip_sessions
         (id, lobby_id, battle_number, player_id_to_skip, initiated_by, skip_rule, votes_required, phase, time_limit_hours)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'selection', $8)`,
        [sessionId, lobbyId, battleNumber, playerIdToSkip, socket.userId, lobby.skip_rule, votesRequired, lobby.skip_time_limit_hours]
      );

      // Initiator automatically votes to skip
      await query(
        `INSERT INTO vote_to_skip_votes (session_id, voter_id)
         VALUES ($1, $2)`,
        [sessionId, socket.userId]
      );

      // Update votes count
      await query(
        `UPDATE vote_to_skip_sessions SET votes_count = 1 WHERE id = $1`,
        [sessionId]
      );

      // Get player names
      const playerNamesResult = await query(
        `SELECT id, display_name FROM users WHERE id IN (SELECT unnest($1::uuid[]))`,
        [[playerIdToSkip, socket.userId]]
      );

      const playerNames = {};
      playerNamesResult.rows.forEach(row => {
        playerNames[row.id] = row.display_name;
      });

      // Broadcast skip vote initiated
      io.to(`lobby:${lobbyId}`).emit('skip-vote-initiated', {
        sessionId,
        battleNumber,
        playerIdToSkip,
        playerNameToSkip: playerNames[playerIdToSkip],
        initiatedBy: socket.userId,
        initiatorName: playerNames[socket.userId],
        skipRule: lobby.skip_rule,
        votesRequired,
        votesCount: 1,
        timeLimitHours: lobby.skip_time_limit_hours,
        timestamp: new Date().toISOString()
      });

      logger.info(`Skip vote initiated in lobby ${lobbyId} for player ${playerIdToSkip} by ${socket.userId}`);

      callback({ success: true, sessionId });
    } catch (error) {
      logger.error('Initiate skip vote error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Cast skip vote
  socket.on('cast-skip-vote', async (data, callback) => {
    try {
      const { sessionId } = data;

      // Get session details
      const sessionResult = await query(
        `SELECT lobby_id, player_id_to_skip, skip_rule, votes_required, votes_count, status, battle_number
         FROM vote_to_skip_sessions WHERE id = $1`,
        [sessionId]
      );

      if (sessionResult.rows.length === 0) {
        return callback({ success: false, error: 'Skip session not found' });
      }

      const session = sessionResult.rows[0];

      if (session.status !== 'active') {
        return callback({ success: false, error: 'Skip session is not active' });
      }

      // Verify voter is in lobby and not the player being skipped
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [session.lobby_id, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      if (socket.userId === session.player_id_to_skip) {
        return callback({ success: false, error: 'Cannot vote to skip yourself' });
      }

      // Check if already voted
      const existingVote = await query(
        `SELECT id FROM vote_to_skip_votes WHERE session_id = $1 AND voter_id = $2`,
        [sessionId, socket.userId]
      );

      if (existingVote.rows.length > 0) {
        return callback({ success: false, error: 'Already voted' });
      }

      // Cast vote
      await query(
        `INSERT INTO vote_to_skip_votes (session_id, voter_id) VALUES ($1, $2)`,
        [sessionId, socket.userId]
      );

      // Update votes count
      const updatedSession = await query(
        `UPDATE vote_to_skip_sessions
         SET votes_count = votes_count + 1
         WHERE id = $1
         RETURNING votes_count`,
        [sessionId]
      );

      const newVotesCount = updatedSession.rows[0].votes_count;

      // Broadcast vote update
      io.to(`lobby:${session.lobby_id}`).emit('skip-vote-updated', {
        sessionId,
        votesCount: newVotesCount,
        votesRequired: session.votes_required,
        voterId: socket.userId,
        timestamp: new Date().toISOString()
      });

      logger.info(`Skip vote cast in session ${sessionId} by ${socket.userId} (${newVotesCount}/${session.votes_required})`);

      // Check if majority reached
      if (newVotesCount >= session.votes_required) {
        await executeSkip(io, session, sessionId);
        return;
      }

      callback({ success: true, votesCount: newVotesCount });
    } catch (error) {
      logger.error('Cast skip vote error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Cancel skip vote
  socket.on('cancel-skip-vote', async (data, callback) => {
    try {
      const { sessionId } = data;

      // Get session details
      const sessionResult = await query(
        `SELECT lobby_id, status FROM vote_to_skip_sessions WHERE id = $1`,
        [sessionId]
      );

      if (sessionResult.rows.length === 0) {
        return callback({ success: false, error: 'Skip session not found' });
      }

      const session = sessionResult.rows[0];

      if (session.status !== 'active') {
        return callback({ success: false, error: 'Skip session is not active' });
      }

      // Remove vote
      const deleteResult = await query(
        `DELETE FROM vote_to_skip_votes WHERE session_id = $1 AND voter_id = $2 RETURNING id`,
        [sessionId, socket.userId]
      );

      if (deleteResult.rows.length === 0) {
        return callback({ success: false, error: 'No vote to cancel' });
      }

      // Update votes count
      const updatedSession = await query(
        `UPDATE vote_to_skip_sessions
         SET votes_count = votes_count - 1
         WHERE id = $1
         RETURNING votes_count`,
        [sessionId]
      );

      const newVotesCount = updatedSession.rows[0].votes_count;

      // Broadcast vote update
      io.to(`lobby:${session.lobby_id}`).emit('skip-vote-updated', {
        sessionId,
        votesCount: newVotesCount,
        voterId: socket.userId,
        cancelled: true,
        timestamp: new Date().toISOString()
      });

      logger.info(`Skip vote cancelled in session ${sessionId} by ${socket.userId}`);

      callback({ success: true, votesCount: newVotesCount });
    } catch (error) {
      logger.error('Cancel skip vote error', error);
      callback({ success: false, error: error.message });
    }
  });
};

// Helper function to execute skip
async function executeSkip(io, session, sessionId) {
  try {
    // Mark session as executed
    await query(
      `UPDATE vote_to_skip_sessions
       SET status = 'executed', executed_at = NOW()
       WHERE id = $1`,
      [sessionId]
    );

    // Get player name
    const playerResult = await query(
      `SELECT display_name FROM users WHERE id = $1`,
      [session.player_id_to_skip]
    );

    const playerName = playerResult.rows[0]?.display_name || 'Player';

    // Broadcast skip executed
    io.to(`lobby:${session.lobby_id}`).emit('skip-vote-executed', {
      sessionId,
      battleNumber: session.battle_number,
      playerIdSkipped: session.player_id_to_skip,
      playerNameSkipped: playerName,
      timestamp: new Date().toISOString()
    });

    // Note: The actual forfeiting of voting points will be handled by the voting service
    // when it tallies votes for the battle. It will check for executed skip sessions.

    logger.info(`Skip executed for player ${session.player_id_to_skip} in lobby ${session.lobby_id}`);
  } catch (error) {
    logger.error('Execute skip error', error);
  }
}
