-- Migration 002: Cognitive Metrics & Data Monetization Schema
-- Adds comprehensive telemetry tables for:
--   - Session type tracking (solo, vs_friends, vs_random, vs_mixed)
--   - Granular in-game event telemetry
--   - Per-session computed performance metrics
--   - Cognitive profile fingerprints
--   - Personal high scores per game/session type
--   - Time-series performance history for trend charts
--   - Regional benchmarks for comparison data
--   - Tiered data consent for monetization

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Extend game_results
-- ─────────────────────────────────────────────────────────────────────────────

-- Make lobby_id nullable to support solo training sessions (no lobby required)
ALTER TABLE game_results
    ALTER COLUMN lobby_id DROP NOT NULL;

-- Tag every result with how it was played
ALTER TABLE game_results
    ADD COLUMN IF NOT EXISTS session_type VARCHAR(20) NOT NULL DEFAULT 'vs_random';
    -- solo_training | vs_friends | vs_random | vs_mixed

COMMENT ON COLUMN game_results.session_type IS
    'How the game was played: solo_training | vs_friends | vs_random | vs_mixed';

CREATE INDEX IF NOT EXISTS idx_game_results_session_type
    ON game_results(user_id, session_type, created_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. game_events — raw in-game telemetry per move/event
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_events (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_result_id UUID NOT NULL REFERENCES game_results(id) ON DELETE CASCADE,
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Event classification
    event_type     VARCHAR(50) NOT NULL,
    -- move_start | move_end | hint_requested | hint_shown | erratic_input
    -- hesitation_spike | self_report | abandon | level_fail | level_complete

    -- Flexible per-event payload (game-specific data)
    -- Examples:
    --   move_end:        {"move_id": "...", "correct": true, "duration_ms": 1240}
    --   hint_shown:      {"hint_type": "highlight", "post_solve_ms": 3200}
    --   erratic_input:   {"tap_count": 7, "window_ms": 500}
    --   self_report:     {"rsme_score": 6}
    --   hesitation_spike:{"duration_ms": 4800, "expected_avg_ms": 1200}
    payload        JSONB NOT NULL DEFAULT '{}',

    occurred_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_game_events_result    ON game_events(game_result_id);
CREATE INDEX idx_game_events_user_type ON game_events(user_id, event_type);
CREATE INDEX idx_game_events_time      ON game_events(occurred_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. game_performance_metrics — computed summary written when a game ends
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_performance_metrics (
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_result_id        UUID UNIQUE NOT NULL REFERENCES game_results(id) ON DELETE CASCADE,
    user_id               UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id               VARCHAR(50) NOT NULL,
    session_type          VARCHAR(20) NOT NULL,

    -- ── Execution quality ──────────────────────────────────────────────────
    -- Ratio: 1.0 = optimal, higher = more detours taken
    path_efficiency         NUMERIC(6,3),  -- moves / BFS shortest path (spatial games)
    -- Ratio: 1.0 = every tap correct
    scanning_efficiency     NUMERIC(6,3),  -- correct_taps / total_taps (attention games)
    -- Ratio: 1.0 = solved in minimum logical steps
    deduction_efficiency    NUMERIC(6,3),  -- actual_steps / min_logical_steps (logic games)
    -- Higher = richer vocabulary used
    word_rarity_score       NUMERIC(8,3),  -- avg dictionary rarity score (language games)

    -- ── Behavioural signals ────────────────────────────────────────────────
    erratic_input_count     INTEGER DEFAULT 0,    -- rapid repeated taps detected
    hesitation_spike_count  INTEGER DEFAULT 0,    -- moves >2x player's avg time
    stuck_index             INTEGER DEFAULT 0,    -- consecutive fails on same config
    time_to_first_move_ms   INTEGER,              -- decision latency at game start
    total_moves             INTEGER DEFAULT 0,

    -- ── Hint telemetry ─────────────────────────────────────────────────────
    hints_requested         INTEGER DEFAULT 0,
    hints_used              INTEGER DEFAULT 0,
    post_hint_velocity_ms   INTEGER,   -- avg time-to-solve after a hint was shown
    pure_play               BOOLEAN DEFAULT true,  -- true = zero hints used

    -- ── Self-reported mental effort (RSME 1–9, optional) ──────────────────
    -- 1=very low effort, 5=moderate, 9=extreme effort
    -- "Mental Efficiency" = high score + low effort
    self_reported_effort    SMALLINT CHECK (self_reported_effort BETWEEN 1 AND 9),

    -- ── Outcome ────────────────────────────────────────────────────────────
    score                   INTEGER NOT NULL DEFAULT 0,
    time_taken_ms           INTEGER,
    completed               BOOLEAN DEFAULT true,
    abandoned               BOOLEAN DEFAULT false,

    created_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_gpm_user_game
    ON game_performance_metrics(user_id, game_id, created_at DESC);
CREATE INDEX idx_gpm_session_type
    ON game_performance_metrics(user_id, session_type, created_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. cognitive_profiles — materialized cognitive fingerprint per user
--    Recomputed by a scheduled job after each session batch
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cognitive_profiles (
    user_id           UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,

    -- ── 6-dimension scores (0–100, normalised vs global population) ────────
    memory_score      NUMERIC(5,2) DEFAULT 0,
    logic_score       NUMERIC(5,2) DEFAULT 0,
    attention_score   NUMERIC(5,2) DEFAULT 0,
    spatial_score     NUMERIC(5,2) DEFAULT 0,
    language_score    NUMERIC(5,2) DEFAULT 0,
    speed_score       NUMERIC(5,2) DEFAULT 0,

    -- ── Per-session-type breakdowns (same 6 dims, stored as JSONB) ─────────
    -- e.g. {"memory": 72, "logic": 58, "attention": 61, ...}
    solo_profile        JSONB DEFAULT '{}',
    vs_friends_profile  JSONB DEFAULT '{}',
    vs_random_profile   JSONB DEFAULT '{}',

    -- ── Global & regional rankings ─────────────────────────────────────────
    global_rank         INTEGER,
    global_percentile   NUMERIC(5,2),   -- e.g. 88.4 = top 11.6%
    country_code        VARCHAR(3),     -- ISO 3166-1 alpha-3
    country_rank        INTEGER,
    region_code         VARCHAR(10),    -- ISO 3166-2 (country-subdivision)
    region_rank         INTEGER,

    -- ── Mind Wars competitive record ───────────────────────────────────────
    mind_wars_played    INTEGER DEFAULT 0,
    mind_wars_won       INTEGER DEFAULT 0,
    win_rate            NUMERIC(5,3) DEFAULT 0,  -- 0.000–1.000

    -- ── Solo training record ───────────────────────────────────────────────
    solo_sessions       INTEGER DEFAULT 0,
    solo_avg_score      NUMERIC(8,2) DEFAULT 0,

    -- ── Improvement indicators ─────────────────────────────────────────────
    -- Positive = improving, negative = declining, null = insufficient data
    improvement_slope_30d  NUMERIC(7,4),   -- score trend over last 30 days
    improvement_slope_90d  NUMERIC(7,4),   -- score trend over last 90 days

    sessions_since_last_calc INTEGER DEFAULT 0,
    last_calculated_at    TIMESTAMP
);

COMMENT ON TABLE cognitive_profiles IS
    'Materialised cognitive fingerprint per user. Recomputed by scheduled job.
     Scores 0-100 are normalised against the current global player population.
     Per-session-type JSONB fields enable solo vs competitive comparisons.';

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. game_high_scores — personal bests per game per session type
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_high_scores (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id      VARCHAR(50) NOT NULL,
    session_type VARCHAR(20) NOT NULL,  -- track PB separately per mode

    high_score   INTEGER NOT NULL,
    time_taken_ms INTEGER,             -- time achieved on the PB run
    pure_play    BOOLEAN DEFAULT true, -- was the PB set without hints?
    achieved_at  TIMESTAMP NOT NULL DEFAULT NOW(),

    UNIQUE (user_id, game_id, session_type)
);

CREATE INDEX idx_high_scores_game
    ON game_high_scores(game_id, high_score DESC);  -- for per-game leaderboards

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. session_performance_history — time-series for trend charts
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS session_performance_history (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_type        VARCHAR(20) NOT NULL,
    game_id             VARCHAR(50),          -- NULL = overall session aggregate
    cognitive_category  VARCHAR(20),          -- memory | logic | attention | spatial | language | speed
    score               NUMERIC(5,2),
    global_percentile   NUMERIC(5,2),
    recorded_at         TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sph_user_time
    ON session_performance_history(user_id, recorded_at DESC);
CREATE INDEX idx_sph_user_category
    ON session_performance_history(user_id, cognitive_category, session_type, recorded_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- 7. regional_benchmarks — daily aggregate snapshots for comparison data
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS regional_benchmarks (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    region_code         VARCHAR(10) NOT NULL,   -- ISO 3166-2, or 'GLOBAL'
    game_id             VARCHAR(50),            -- NULL = all games combined
    cognitive_category  VARCHAR(20),            -- NULL = all categories combined

    avg_score           NUMERIC(5,2),
    median_score        NUMERIC(5,2),
    p10_score           NUMERIC(5,2),           -- bottom 10%
    p90_score           NUMERIC(5,2),           -- top 10%
    sample_count        INTEGER,

    -- Breakdown by session type for research value
    solo_avg_score      NUMERIC(5,2),
    competitive_avg_score NUMERIC(5,2),

    benchmark_date      DATE NOT NULL DEFAULT CURRENT_DATE,

    UNIQUE (region_code, game_id, cognitive_category, benchmark_date)
);

CREATE INDEX idx_benchmarks_region_date
    ON regional_benchmarks(region_code, benchmark_date DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- 8. data_consent — tiered explicit consent for data monetization
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TYPE IF NOT EXISTS data_consent_tier AS ENUM (
    'tier_1',  -- service only (implicit, no sharing)
    'tier_2',  -- anonymised aggregate → academic / research
    'tier_3',  -- individual anonymised profile → HR / wellness
    'tier_4'   -- linked named profile → clinical / longitudinal (compensated)
);

CREATE TABLE IF NOT EXISTS data_consent (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tier             data_consent_tier NOT NULL,
    consented        BOOLEAN NOT NULL DEFAULT false,

    -- Semver linked to the legal text shown at consent time
    -- Allows re-prompting if consent text changes
    consent_version  VARCHAR(20) NOT NULL DEFAULT '1.0.0',

    consented_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    revoked_at       TIMESTAMP,    -- set when user withdraws consent

    UNIQUE (user_id, tier)
);

CREATE INDEX idx_data_consent_user
    ON data_consent(user_id);

-- Default all existing users to tier_1 (no sharing) — explicit action required
-- to upgrade. This is the safe/compliant default.
INSERT INTO data_consent (user_id, tier, consented, consent_version)
SELECT id, 'tier_1', true, '1.0.0'
FROM users
ON CONFLICT (user_id, tier) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────────
-- 9. Update update_user_stats() trigger to also upsert game_high_scores
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update aggregate counters on users table
    UPDATE users
    SET
        games_played   = games_played + 1,
        total_score    = total_score + NEW.score,
        last_played_at = NEW.created_at
    WHERE id = NEW.user_id;

    -- Upsert personal high score for this game + session type
    INSERT INTO game_high_scores (user_id, game_id, session_type, high_score, time_taken_ms, achieved_at)
    VALUES (NEW.user_id, NEW.game_id, NEW.session_type, NEW.score, NEW.time_taken, NEW.created_at)
    ON CONFLICT (user_id, game_id, session_type)
    DO UPDATE SET
        high_score    = GREATEST(game_high_scores.high_score, EXCLUDED.high_score),
        time_taken_ms = CASE
                            WHEN EXCLUDED.high_score > game_high_scores.high_score
                            THEN EXCLUDED.time_taken_ms
                            ELSE game_high_scores.time_taken_ms
                        END,
        achieved_at   = CASE
                            WHEN EXCLUDED.high_score > game_high_scores.high_score
                            THEN EXCLUDED.achieved_at
                            ELSE game_high_scores.achieved_at
                        END;

    -- Initialise cognitive_profiles row if this is the user's first game
    INSERT INTO cognitive_profiles (user_id)
    VALUES (NEW.user_id)
    ON CONFLICT (user_id) DO UPDATE
        SET sessions_since_last_calc = cognitive_profiles.sessions_since_last_calc + 1;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
