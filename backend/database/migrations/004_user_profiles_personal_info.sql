-- Migration 004: User Personal Profile Information
--
-- Purpose:
--   Separate personal/demographic information from gaming identity.
--   Gaming identity (username, displayName, avatar) stays in users table.
--   Personal info (name, age, gender, bio, location) goes in user_profiles.
--
-- This enables:
--   - Privacy controls (can delete/null personal info independently)
--   - Cleaner schema (personal fields don't bloat users table)
--   - Flexible extension (add new personal fields without altering users)

CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,

  -- Personal information
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  date_of_birth DATE,
  gender VARCHAR(50),  -- M, F, Other, Prefer not to say, etc.

  -- Optional fields
  bio TEXT,  -- Short about/bio section
  location VARCHAR(255),  -- City, Region, Country

  -- Timestamps
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create index for faster lookups by user_id
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);

-- Trigger to auto-update the updated_at timestamp
CREATE TRIGGER trigger_user_profiles_updated_at BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create a profile entry for each existing user (empty/null values)
INSERT INTO user_profiles (user_id, first_name, last_name, date_of_birth, gender, bio, location, created_at, updated_at)
SELECT id, NULL, NULL, NULL, NULL, NULL, NULL, NOW(), NOW()
FROM users
ON CONFLICT (user_id) DO NOTHING;

-- Verify migration
SELECT COUNT(*) as total_profiles FROM user_profiles;
