-- Migration 005: Phase 2 Mind War Configuration & Immutable Payload
--
-- Purpose:
--   Support Phase 2 multiplayer features: war configuration (difficulty, hints, ranked status),
--   player ready states, and immutable game payloads with deterministic game indices.
--
-- Changes:
--   1. Extend lobbies table with configuration fields
--   2. Extend lobby_players with ready state tracking
--   3. Create mind_war_payloads table to store immutable battle configurations
--
-- Why immutable payloads:
--   - Ensures all players have identical game state (no race conditions)
--   - Enables offline-first: payload cached locally at game start
--   - Supports deterministic game generation: gameIndex + seed produce identical puzzles
--   - Allows server-side validation for ranked leaderboards

-- 1. Extend lobbies table
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS difficulty VARCHAR(10) DEFAULT 'medium';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS hint_policy VARCHAR(20) DEFAULT 'enabled';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS ranked BOOLEAN DEFAULT false;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS game_pack VARCHAR(50) DEFAULT NULL;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS mind_war_id UUID DEFAULT NULL;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS scoring_model_version VARCHAR(20) DEFAULT '1.0';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS payload_locked BOOLEAN DEFAULT false;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS payload_locked_at TIMESTAMPTZ DEFAULT NULL;

-- Create index on mind_war_id for fast lookups
CREATE INDEX IF NOT EXISTS idx_lobbies_mind_war_id ON lobbies(mind_war_id);

-- 2. Extend lobby_players table
ALTER TABLE lobby_players ADD COLUMN IF NOT EXISTS is_ready BOOLEAN DEFAULT false;
ALTER TABLE lobby_players ADD COLUMN IF NOT EXISTS ready_at TIMESTAMPTZ DEFAULT NULL;

-- Create index on ready state for quick queries
CREATE INDEX IF NOT EXISTS idx_lobby_players_is_ready ON lobby_players(lobby_id, is_ready);

-- 3. Create mind_war_payloads table
CREATE TABLE IF NOT EXISTS mind_war_payloads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lobby_id UUID NOT NULL UNIQUE REFERENCES lobbies(id) ON DELETE CASCADE,
  mind_war_id UUID NOT NULL UNIQUE,

  -- Full game sequence as JSONB for flexible schema evolution
  -- Structure: [{roundNumber, gameId, difficulty, hintPolicy, gameIndex, seed}, ...]
  game_sequence JSONB NOT NULL,

  -- Convenience columns for queries (denormalized from game_sequence for performance)
  difficulty VARCHAR(10) NOT NULL,
  hint_policy VARCHAR(20) NOT NULL,
  ranked BOOLEAN NOT NULL,
  scoring_model_version VARCHAR(20) NOT NULL DEFAULT '1.0',

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  locked_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indices for fast lookups
CREATE INDEX IF NOT EXISTS idx_mind_war_payloads_lobby_id ON mind_war_payloads(lobby_id);
CREATE INDEX IF NOT EXISTS idx_mind_war_payloads_mind_war_id ON mind_war_payloads(mind_war_id);
CREATE INDEX IF NOT EXISTS idx_mind_war_payloads_ranked ON mind_war_payloads(ranked);

-- Verify migration
SELECT '✓ Phase 2 schema migration complete' AS status;
SELECT
  COUNT(*) as total_lobbies,
  COUNT(CASE WHEN mind_war_id IS NOT NULL THEN 1 END) as lobbies_with_payloads
FROM lobbies;
