-- Migration 003: Split username (unique) from display_name (editable, non-unique)
--
-- Purpose:
--   Previously, 'display_name' was the unique identifier (like a username).
--   Now we split this into:
--   - 'username': unique identifier, rarely changed (locked after initial setup)
--   - 'display_name': editable, non-unique display name shown in competitive contexts
--
-- Usage in UI:
--   - Leaderboards, Mind Wars, chat: Show "DisplayName (username)" if displayName differs from username
--   - Otherwise: Show just the username
--   - Edit Profile: Separate fields for username (read-only) and displayName (editable)

-- Step 1: Add username column (nullable during migration)
ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(20);

-- Step 2: Copy existing display_name values to username
UPDATE users SET username = display_name WHERE username IS NULL;

-- Step 3: Make username NOT NULL and add unique constraint
ALTER TABLE users ALTER COLUMN username SET NOT NULL;
ALTER TABLE users ADD CONSTRAINT users_username_key UNIQUE(LOWER(username));

-- Step 4: Change display_name to be non-unique and allow NULL
ALTER TABLE users ALTER COLUMN display_name DROP NOT NULL;
ALTER TABLE users ALTER COLUMN display_name SET DEFAULT '';

-- Step 5: Create index on username for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON users(LOWER(username));

-- Step 6: Verify migration
SELECT COUNT(*) as total_users,
       COUNT(username) as users_with_username,
       COUNT(DISTINCT username) as unique_usernames
FROM users;
