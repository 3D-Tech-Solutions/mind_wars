-- Migration: Add Phase 2 ready state columns to lobby_players
-- Date: 2026-04-05
-- Purpose: Support player ready state for immutable payload generation

-- Add columns to lobby_players table
ALTER TABLE lobby_players ADD COLUMN IF NOT EXISTS is_ready BOOLEAN DEFAULT false;
ALTER TABLE lobby_players ADD COLUMN IF NOT EXISTS ready_at TIMESTAMP;
ALTER TABLE lobby_players ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'joined';

-- Add index for status queries
CREATE INDEX IF NOT EXISTS idx_lobby_players_status ON lobby_players(status);

-- Verify columns exist
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'lobby_players'
ORDER BY ordinal_position;
