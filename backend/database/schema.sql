-- Mind Wars Database Schema
-- PostgreSQL 15+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    avatar_url TEXT,
    level INTEGER DEFAULT 1,
    total_score INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    games_played INTEGER DEFAULT 0,
    games_won INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMP,
    last_played_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_total_score ON users(total_score DESC);

-- Lobbies table
CREATE TABLE IF NOT EXISTS lobbies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    host_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    max_players INTEGER NOT NULL DEFAULT 10,
    is_private BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'waiting', -- waiting, playing, completed, closed
    current_round INTEGER DEFAULT 1,
    total_rounds INTEGER DEFAULT 3,
    voting_points_per_player INTEGER DEFAULT 10,
    skip_rule VARCHAR(20) DEFAULT 'majority', -- majority, unanimous, time_based
    skip_time_limit_hours INTEGER DEFAULT 24, -- For time_based skip rule
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE INDEX idx_lobbies_code ON lobbies(code);
CREATE INDEX idx_lobbies_status ON lobbies(status);
CREATE INDEX idx_lobbies_host_id ON lobbies(host_id);

-- Lobby players table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS lobby_players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(lobby_id, user_id)
);

CREATE INDEX idx_lobby_players_lobby_id ON lobby_players(lobby_id);
CREATE INDEX idx_lobby_players_user_id ON lobby_players(user_id);

-- Game results table
CREATE TABLE IF NOT EXISTS game_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id VARCHAR(50) NOT NULL,
    score INTEGER NOT NULL DEFAULT 0,
    time_taken INTEGER, -- milliseconds
    hints_used INTEGER DEFAULT 0,
    perfect BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_game_results_lobby_id ON game_results(lobby_id);
CREATE INDEX idx_game_results_user_id ON game_results(user_id);
CREATE INDEX idx_game_results_created_at ON game_results(created_at DESC);

-- Badges table
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50), -- first_victory, streak, games_played, category_mastery, social
    icon TEXT,
    criteria JSONB, -- Flexible criteria storage
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- User badges table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

CREATE INDEX idx_user_badges_user_id ON user_badges(user_id);
CREATE INDEX idx_user_badges_badge_id ON user_badges(badge_id);

-- Voting sessions table
CREATE TABLE IF NOT EXISTS voting_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'active', -- active, completed, cancelled
    points_per_player INTEGER DEFAULT 10,
    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMP
);

CREATE INDEX idx_voting_sessions_lobby_id ON voting_sessions(lobby_id);

-- Votes table
CREATE TABLE IF NOT EXISTS votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    voting_id UUID NOT NULL REFERENCES voting_sessions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id VARCHAR(50) NOT NULL,
    points INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(voting_id, user_id, game_id)
);

CREATE INDEX idx_votes_voting_id ON votes(voting_id);
CREATE INDEX idx_votes_user_id ON votes(user_id);

-- Leaderboards view (weekly)
CREATE OR REPLACE VIEW weekly_leaderboard AS
SELECT
    u.id,
    u.display_name,
    u.avatar_url,
    u.level,
    SUM(gr.score) as weekly_score,
    COUNT(gr.id) as games_played,
    ROW_NUMBER() OVER (ORDER BY SUM(gr.score) DESC) as rank
FROM users u
JOIN game_results gr ON u.id = gr.user_id
WHERE gr.created_at >= date_trunc('week', CURRENT_DATE)
GROUP BY u.id, u.display_name, u.avatar_url, u.level
ORDER BY weekly_score DESC;

-- Leaderboards view (all-time)
CREATE OR REPLACE VIEW alltime_leaderboard AS
SELECT
    id,
    display_name,
    avatar_url,
    level,
    total_score,
    games_played,
    games_won,
    ROW_NUMBER() OVER (ORDER BY total_score DESC) as rank
FROM users
WHERE total_score > 0
ORDER BY total_score DESC;

-- Function to update user stats
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users
    SET
        games_played = games_played + 1,
        total_score = total_score + NEW.score,
        last_played_at = NEW.created_at
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update user stats when game result is added
CREATE TRIGGER trigger_update_user_stats
AFTER INSERT ON game_results
FOR EACH ROW
EXECUTE FUNCTION update_user_stats();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Chat messages table
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    filtered_message TEXT,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    flagged_for_review BOOLEAN DEFAULT false,
    flagged_reason VARCHAR(255)
);

CREATE INDEX idx_chat_messages_lobby_id ON chat_messages(lobby_id);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp DESC);
CREATE INDEX idx_chat_messages_flagged ON chat_messages(flagged_for_review);
CREATE INDEX idx_chat_messages_flagged_reason ON chat_messages(flagged_reason) WHERE flagged_for_review = true;

-- Emoji reactions table
CREATE TABLE IF NOT EXISTS emoji_reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    emoji VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_emoji_reactions_lobby_id ON emoji_reactions(lobby_id);
CREATE INDEX idx_emoji_reactions_timestamp ON emoji_reactions(timestamp DESC);

-- Vote-to-skip sessions (Selection Phase only)
CREATE TABLE IF NOT EXISTS vote_to_skip_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    battle_number INTEGER NOT NULL,
    player_id_to_skip UUID NOT NULL REFERENCES users(id),
    initiated_by UUID NOT NULL REFERENCES users(id),
    skip_rule VARCHAR(20) NOT NULL, -- 'majority', 'unanimous', 'time_based'
    votes_required INTEGER NOT NULL,
    votes_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active', -- active, executed, cancelled
    phase VARCHAR(20) DEFAULT 'selection', -- Always 'selection' for MVP
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    executed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    time_limit_hours INTEGER -- For time-based skip rule
);

CREATE INDEX idx_vote_to_skip_sessions_lobby_id ON vote_to_skip_sessions(lobby_id);
CREATE INDEX idx_vote_to_skip_sessions_status ON vote_to_skip_sessions(status);
CREATE INDEX idx_vote_to_skip_sessions_battle ON vote_to_skip_sessions(battle_number);

-- Individual skip votes
CREATE TABLE IF NOT EXISTS vote_to_skip_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES vote_to_skip_sessions(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id),
    voted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(session_id, voter_id)
);

CREATE INDEX idx_vote_to_skip_votes_session_id ON vote_to_skip_votes(session_id);
CREATE INDEX idx_vote_to_skip_votes_voter_id ON vote_to_skip_votes(voter_id);

-- ============================================================================
-- Phase 2 Extensions: Mind War Configuration & Immutable Payloads
-- ============================================================================

-- Extend lobbies table with Phase 2 configuration fields
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS difficulty VARCHAR(10) DEFAULT 'medium';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS hint_policy VARCHAR(20) DEFAULT 'enabled';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS ranked BOOLEAN DEFAULT false;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS game_pack VARCHAR(50) DEFAULT NULL;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS mind_war_id UUID DEFAULT NULL;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS scoring_model_version VARCHAR(20) DEFAULT '1.0';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS payload_locked BOOLEAN DEFAULT false;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS payload_locked_at TIMESTAMPTZ DEFAULT NULL;

-- Create indices on Phase 2 fields
CREATE INDEX IF NOT EXISTS idx_lobbies_mind_war_id ON lobbies(mind_war_id);
CREATE INDEX IF NOT EXISTS idx_lobbies_payload_locked ON lobbies(payload_locked);

-- Extend lobby_players table with ready state tracking
ALTER TABLE lobby_players ADD COLUMN IF NOT EXISTS is_ready BOOLEAN DEFAULT false;
ALTER TABLE lobby_players ADD COLUMN IF NOT EXISTS ready_at TIMESTAMPTZ DEFAULT NULL;

-- Index ready state for fast queries
CREATE INDEX IF NOT EXISTS idx_lobby_players_is_ready ON lobby_players(lobby_id, is_ready);

-- Immutable Mind War Payloads table
-- Stores the locked game sequence with deterministic indices for pixel-perfect cloned gameplay
CREATE TABLE IF NOT EXISTS mind_war_payloads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lobby_id UUID NOT NULL UNIQUE REFERENCES lobbies(id) ON DELETE CASCADE,
    mind_war_id UUID NOT NULL UNIQUE,

    -- Full game sequence as JSONB for flexible schema evolution
    -- Structure: [{roundNumber, gameId, difficulty, hintPolicy, gameIndex, seed}, ...]
    -- gameIndex: unique integer seed for deterministic game state generation
    -- seed: string seed derived from mind_war_id + round + gameIndex
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

-- Create indices for fast payload lookups
CREATE INDEX IF NOT EXISTS idx_mind_war_payloads_lobby_id ON mind_war_payloads(lobby_id);
CREATE INDEX IF NOT EXISTS idx_mind_war_payloads_mind_war_id ON mind_war_payloads(mind_war_id);
CREATE INDEX IF NOT EXISTS idx_mind_war_payloads_ranked ON mind_war_payloads(ranked);
