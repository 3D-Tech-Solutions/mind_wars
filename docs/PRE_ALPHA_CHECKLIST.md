---
name: Pre-Alpha Readiness Checklist
description: Comprehensive checklist for shipping Mind Wars pre-alpha build (ready for closed internal testing with family and friends)
type: project
---

# Mind Wars: Pre-Alpha Readiness Checklist

**Goal:** Prepare Mind Wars for closed pre-alpha testing with 10-20 internal testers (family, close friends). The app should be feature-complete for core gameplay, stable enough for daily play, and ready for feedback on game balance and UX.

**Timeline:** Estimated 8-12 weeks (depends on team size and current progress)

**Success Criteria:**
- ✅ All 15 games playable and balanced
- ✅ 2+ devices can play together via LAN multiplayer
- ✅ Authentication works (signup, login, profile)
- ✅ At least one Mind War round can be completed end-to-end
- ✅ Scores visible and leaderboard functional
- ✅ No critical crashes in 1 hour of gameplay
- ✅ iOS and Android builds run on physical devices
- ✅ Testers can give feedback (in-app or external form)

---

## Section 1: Infrastructure & Backend Setup

### 1.1 Backend API Server Setup

**Epic:** Backend REST API Foundation
- **Description:** Stand up the API server (Node.js Express) with basic routes, database connection, and error handling
- **Effort:** 8 points
- **Dependencies:** None (start here)

**Checklist:**
- [ ] Node.js/Express server running on port 3000
- [ ] PostgreSQL database connection working
- [ ] Basic error handling middleware in place
- [ ] CORS enabled for local development
- [ ] Logging system configured (console or file-based)
- [ ] Environment variables (.env) set up
- [ ] Health check endpoint `/health` returns 200
- [ ] Documentation: API endpoint reference (POSTMAN collection or similar)

---

### 1.2 Multiplayer Server (Socket.io) Setup

**Epic:** Multiplayer WebSocket Infrastructure
- **Description:** Stand up Socket.io server for real-time multiplayer communication
- **Effort:** 5 points
- **Dependencies:** 1.1 (API server exists)

**Checklist:**
- [ ] Socket.io server running on port 4001
- [ ] WebSocket connection works from Flutter client
- [ ] Basic event handlers in place (connect, disconnect, join-lobby)
- [ ] JWT authentication on socket connection
- [ ] Error handling for dropped connections
- [ ] Auto-reconnect logic on client side
- [ ] Testing: Two devices can connect and communicate
- [ ] Logging: Socket events logged for debugging

---

### 1.3 Database Schema & Migrations

**Epic:** Database Foundation
- **Description:** Create PostgreSQL schema for all core entities
- **Effort:** 13 points
- **Dependencies:** 1.1 (API server exists)

**Checklist:**

**Core Tables:**
- [ ] `users` table (id, email, password_hash, display_name, avatar_url, created_at)
- [ ] `user_profiles` table (user_id, bio, location, preferences, linked_parent_id for child accounts)
- [ ] `mind_wars` table (id, name, host_id, status, created_at, started_at, ended_at)
- [ ] `mind_war_players` table (mind_war_id, player_id, joined_at, status, total_score)
- [ ] `mind_war_rounds` table (mind_war_id, round_number, status, created_at)
- [ ] `game_instances` table (id, mind_war_id, round_number, game_type, seed, challenge_payload)
- [ ] `game_scores` table (id, player_id, game_instance_id, score, time_taken, completed_at)
- [ ] `chat_messages` table (id, mind_war_id, player_id, content, created_at)
- [ ] `leaderboards` table (id, player_id, total_score, weekly_score, rank, updated_at)
- [ ] `parental_consents` table (id, parent_id, child_id, status, verified_at) — for child accounts

**Migrations:**
- [ ] Migration 001: Core schema (users, mind_wars, players)
- [ ] Migration 002: Games (game_instances, game_scores)
- [ ] Migration 003: Chat (chat_messages)
- [ ] Migration 004: Leaderboards & progression
- [ ] Migration 005: Parental consent & child accounts
- [ ] Migration script runs successfully on fresh database
- [ ] Rollback tested for each migration

**Indexes:**
- [ ] Index on `users.email` (for login)
- [ ] Index on `mind_wars.host_id` and `status` (for lobby queries)
- [ ] Index on `game_scores.player_id` and `created_at` (for leaderboards)
- [ ] Index on `chat_messages.mind_war_id` and `created_at` (for chat history)

---

### 1.4 Environment & Local Development Setup

**Epic:** Developer Environment
- **Description:** Document and automate local development setup
- **Effort:** 5 points
- **Dependencies:** 1.1, 1.2, 1.3

**Checklist:**
- [ ] Docker Compose file for PostgreSQL + Redis + API + Socket.io
- [ ] `.env.example` with all required variables
- [ ] `docker-compose up` starts all services
- [ ] Services health check: `curl http://localhost:3000/health` returns 200
- [ ] Flutter can connect to local backend (IP or hostname)
- [ ] Hot-reload works for backend (nodemon or similar)
- [ ] Database can be reset with `npm run db:reset`
- [ ] README in `/backend` with setup instructions
- [ ] Tested on macOS, Windows, Linux (or document which platforms are supported)

---

## Section 2: Authentication & User Management

### 2.1 User Registration (Signup)

**Epic:** User Registration with Email Verification
- **Description:** Build signup flow with password validation, email verification, and profile creation
- **Effort:** 8 points
- **Dependencies:** 1.3 (database), 1.1 (API)

**Backend:**
- [ ] `POST /auth/register` endpoint
  - [ ] Validates email format and uniqueness
  - [ ] Validates password (min 8 chars, 1 upper, 1 lower, 1 digit)
  - [ ] Validates display_name (2-50 chars, alphanumeric + spaces)
  - [ ] Hashes password (bcrypt, salt rounds 10+)
  - [ ] Creates user in database
  - [ ] Returns JWT access token + refresh token
  - [ ] Returns 400 on validation error, 409 on duplicate email
- [ ] Email verification flow (optional for pre-alpha, but recommended)
  - [ ] Send verification email with link/code
  - [ ] `POST /auth/verify-email` with token
  - [ ] Mark user as verified in database
- [ ] Error handling: email already registered, weak password, etc.

**Frontend:**
- [ ] Registration screen with email, password, password confirm, display_name fields
- [ ] Real-time validation feedback (password strength indicator, email format)
- [ ] Submit button disabled until all fields valid
- [ ] Loading spinner while submitting
- [ ] Error messages for failures (network, validation, server errors)
- [ ] Success: Navigate to profile setup or home screen
- [ ] Link to login screen ("Already have an account?")

**Testing:**
- [ ] Happy path: Register with valid email + password
- [ ] Reject: Duplicate email
- [ ] Reject: Weak password
- [ ] Reject: Invalid email format
- [ ] Verify: User created in database with hashed password
- [ ] Verify: Tokens returned and valid

---

### 2.2 User Login

**Epic:** User Login with JWT Authentication
- **Description:** Build login flow with email/password, token refresh, and session management
- **Effort:** 6 points
- **Dependencies:** 2.1 (registration exists)

**Backend:**
- [ ] `POST /auth/login` endpoint
  - [ ] Validates email + password
  - [ ] Compares password hash (bcrypt.compare)
  - [ ] Returns JWT access token (15 min expiry) + refresh token (7 days)
  - [ ] Sets refresh token in secure httpOnly cookie (if using cookies)
  - [ ] Returns 401 on invalid credentials
- [ ] `POST /auth/refresh` endpoint
  - [ ] Takes refresh token
  - [ ] Returns new access token
  - [ ] Validates refresh token hasn't expired
- [ ] `POST /auth/logout` endpoint
  - [ ] Invalidates refresh token (optional: add to blacklist)
  - [ ] Returns 200

**Frontend:**
- [ ] Login screen with email, password fields
- [ ] "Forgot password?" link (can be disabled for pre-alpha)
- [ ] Submit button with loading state
- [ ] Error messages: invalid credentials, network error
- [ ] Success: Store tokens (secure storage, not localStorage), navigate to home
- [ ] Auto-refresh: When access token expires, use refresh token to get new one
- [ ] Auto-logout: If refresh token invalid, clear tokens and navigate to login

**Testing:**
- [ ] Happy path: Login with valid email + password
- [ ] Reject: Wrong password
- [ ] Reject: Non-existent email
- [ ] Verify: Tokens returned and valid (can decode JWT)
- [ ] Refresh: Use refresh token to get new access token
- [ ] Logout: Tokens invalidated

---

### 2.3 User Profile & Avatar

**Epic:** User Profile Setup
- **Description:** Allow users to create/edit profile, choose avatar, set preferences
- **Effort:** 8 points
- **Dependencies:** 2.1 (registration)

**Backend:**
- [ ] `GET /users/:id` endpoint (get profile)
- [ ] `PUT /users/:id` endpoint (update profile)
  - [ ] Can update: display_name, bio, location, avatar_url
  - [ ] Authorization: Only user can update their own profile
  - [ ] Returns 403 if unauthorized
- [ ] `POST /users/avatar/upload` (optional: use URL for pre-alpha)
  - [ ] Accept image file, store on server or S3
  - [ ] Return avatar_url
- [ ] Avatar selection: Pre-generated set of avatars (10-20 options) to choose from

**Frontend:**
- [ ] Profile setup screen (first-time after signup)
  - [ ] Display name (pre-filled from signup)
  - [ ] Avatar picker (show grid of options, allow selection)
  - [ ] Bio text field (optional)
  - [ ] Save button
- [ ] Profile view screen (see own profile)
  - [ ] Display avatar, name, bio, location
  - [ ] Edit button → Edit profile screen
- [ ] Edit profile screen
  - [ ] All fields editable
  - [ ] Save + Cancel buttons
  - [ ] Success notification

**Testing:**
- [ ] Create profile with avatar selection
- [ ] Edit profile and verify changes saved
- [ ] View profile and see all data
- [ ] Unauthorized user cannot edit another user's profile

---

### 2.4 Child Account Registration (COPPA)

**Epic:** Parental Consent & Child Accounts
- **Description:** Implement age verification, parental consent flow, child account linking
- **Effort:** 13 points (split across phases, start with Phase 1)
- **Dependencies:** 2.1 (registration)

**Phase 1 (Pre-Alpha MVP):**
- [ ] Age verification at signup
  - [ ] Ask for birthday during registration
  - [ ] Calculate age
  - [ ] If < 13: Show "need parent approval" message
- [ ] Parental consent flow
  - [ ] Ask for parent email
  - [ ] Send consent email with verification link
  - [ ] Parent clicks link, sees consent form
  - [ ] Parent verifies email (code or link)
  - [ ] Parent checks "I approve this account"
  - [ ] Child account created on approval
- [ ] Database
  - [ ] `birthday` field in users table (encrypted)
  - [ ] `account_type` field (independent, parent, child)
  - [ ] `parent_id` field (for child accounts)
  - [ ] `parental_consent_verified` field
- [ ] Parental consent audit log
  - [ ] Record when consent verified
  - [ ] Record parent IP, email, timestamp

**Phase 2 (Beta):**
- [ ] Parental dashboard (separate doc/phase)
- [ ] Child-mode restrictions
- [ ] Enhanced profanity filter

**Testing:**
- [ ] Register as adult (13+): Skip parental consent
- [ ] Register as child (<13): Require parental consent
- [ ] Parent receives consent email
- [ ] Parent approves: Child account created
- [ ] Parent declines: Child account blocked

---

## Section 3: Frontend Core Screens & Navigation

### 3.1 App Navigation & State Management

**Epic:** App Navigation & State Management
- **Description:** Set up Provider patterns, navigation, and app-level state
- **Effort:** 8 points
- **Dependencies:** 2.1 (auth exists)

**Checklist:**
- [ ] Navigation setup (GoRouter or Navigator)
  - [ ] Auth routes (login, register, splash)
  - [ ] Home routes (lobby, home, profile)
  - [ ] Game routes (game screen)
  - [ ] Deep linking support (optional)
- [ ] AppState provider
  - [ ] Current user (logged in, profile)
  - [ ] Auth tokens (access, refresh)
  - [ ] Current mind war (if playing)
- [ ] Auth provider
  - [ ] Login / logout / refresh token logic
  - [ ] Persist tokens to secure storage
- [ ] Splash screen
  - [ ] Check if user logged in
  - [ ] Route to login or home
- [ ] Navigation based on auth state
  - [ ] Logged out → Login/Register screens
  - [ ] Logged in → Home/Lobby screens

**Testing:**
- [ ] Fresh app: Shows splash, then login
- [ ] After login: Navigate to home
- [ ] After logout: Navigate to login
- [ ] Refresh app while logged in: User still logged in

---

### 3.2 Home Screen / Dashboard

**Epic:** Home Screen (After Login)
- **Description:** Main hub showing mind wars, current games, quick stats
- **Effort:** 8 points
- **Dependencies:** 3.1 (navigation), 2.3 (profile)

**Checklist:**
- [ ] Header
  - [ ] User avatar + display name (tap to go to profile)
  - [ ] Logout button
- [ ] Active Mind Wars section
  - [ ] List of ongoing mind wars (with other players)
  - [ ] Show: Players, game count, current round
  - [ ] Tap to join/continue playing
- [ ] Completed Mind Wars section
  - [ ] Historical results
  - [ ] Final scores and rankings
- [ ] Quick Stats
  - [ ] Total games played
  - [ ] Current rank
  - [ ] This week's score
- [ ] Create Mind War button
  - [ ] Takes to mind war creation screen
- [ ] Leaderboard button
  - [ ] Shows weekly/all-time rankings

**Testing:**
- [ ] Home screen loads and shows data
- [ ] Tap on mind war: Go to that mind war
- [ ] Tap create: Go to creation screen
- [ ] Tap leaderboard: Go to leaderboard

---

### 3.3 Mind War Lobby Screen

**Epic:** Lobby Management
- **Description:** Create, join, manage lobbies. Invite players, configure settings, start game
- **Effort:** 13 points
- **Dependencies:** 3.1 (navigation), 1.2 (socket.io)

**Create Lobby:**
- [ ] Create Mind War screen
  - [ ] Name field
  - [ ] Max players dropdown (2-10)
  - [ ] Game selection (vote-to-skip, admin picks, both)
  - [ ] Difficulty level (easy, medium, hard)
  - [ ] Create button
  - [ ] Creates mind war in DB, shows lobby code

**Join Lobby:**
- [ ] Join Mind War screen
  - [ ] Lobby code input (or scan QR)
  - [ ] Join button
  - [ ] Enters Socket.io room for that lobby

**Lobby Screen (Inside):**
- [ ] Header: Lobby code, host name
- [ ] Players section
  - [ ] List of joined players with status (ready/not ready)
  - [ ] Show player avatars + names
  - [ ] Checkmark next to player's own name
- [ ] Settings section (host only)
  - [ ] Max players
  - [ ] Game selection method
  - [ ] Difficulty
  - [ ] Change settings button
- [ ] Chat (Activity Hub)
  - [ ] Chat icon in top right
  - [ ] Shows messages and game event notifications
- [ ] Start Game button (host only)
  - [ ] Only enabled if 2+ players ready
  - [ ] Disables when game starts
- [ ] Leave Lobby button

**Real-Time Updates (Socket.io):**
- [ ] When player joins: All players see updated list
- [ ] When player leaves: Remove from list
- [ ] When host changes settings: All see updated settings
- [ ] When host starts game: All navigate to game screen
- [ ] Show typing indicators (optional)

**Testing:**
- [ ] Create lobby: Appears in DB, code generated
- [ ] Join lobby: Socket room joined, player appears in list
- [ ] Multiple players: All see each other
- [ ] Chat: Messages appear to all players
- [ ] Start game: All navigate to game screen

---

### 3.4 Game Screen (Main Gameplay)

**Epic:** Game Rendering & Interaction
- **Description:** Display active game, render game-specific UI, handle player input, submit scores
- **Effort:** 21 points (varies by game complexity)
- **Dependencies:** 4.X (games implemented), 3.3 (lobby)

**Generic Game Screen:**
- [ ] Game title + timer (countdown to game end)
- [ ] Game-specific UI (varies per game)
- [ ] Score display (live scoring)
- [ ] Pause button (optional)
- [ ] Chat icon (top right) → Activity Hub

**Submit Score:**
- [ ] When game ends: Automatically submit score
  - [ ] Send to backend: `POST /games/:instance_id/submit` with score
  - [ ] Server validates (sealed payload check)
  - [ ] Returns: score confirmation, rank update
- [ ] Handle network failure
  - [ ] Retry with exponential backoff
  - [ ] Show "waiting to sync" indicator
  - [ ] Store score locally if offline

**Post-Game:**
- [ ] Show score achieved
- [ ] Show rank in this game (1st, 2nd, etc.)
- [ ] Show all players' scores
- [ ] "Continue to next game" button

**Testing:**
- [ ] Game renders correctly
- [ ] Game tracks score during play
- [ ] Score submitted on game end
- [ ] Score appears in leaderboard immediately after

---

### 3.5 Leaderboard Screen

**Epic:** Leaderboard & Rankings
- **Description:** Show weekly and all-time rankings
- **Effort:** 8 points
- **Dependencies:** 3.2 (home screen)

**Checklist:**
- [ ] Tabs: This Week / All Time
- [ ] Leaderboard list
  - [ ] Rank #1, #2, etc.
  - [ ] Player avatar + name
  - [ ] Total score
  - [ ] Highlight current player
- [ ] Pagination or infinite scroll (if many players)
- [ ] Refresh button
- [ ] Search by player name (optional)

**Testing:**
- [ ] Leaderboard loads and shows correct ranking
- [ ] Current player highlighted
- [ ] Switching tabs shows different data

---

### 3.6 Profile Screen

**Epic:** User Profile View
- **Description:** Show user's profile, stats, badges, settings
- **Effort:** 8 points
- **Dependencies:** 2.3 (profile)

**Checklist:**
- [ ] Profile header
  - [ ] Avatar (large)
  - [ ] Display name
  - [ ] Bio + location
  - [ ] Edit button (only if own profile)
- [ ] Stats
  - [ ] Games played
  - [ ] Win rate
  - [ ] Highest score
  - [ ] Current streak
- [ ] Badges/Achievements (optional for pre-alpha)
  - [ ] Show earned badges
- [ ] Settings (if own profile)
  - [ ] Edit profile button
  - [ ] Notification preferences
  - [ ] Privacy settings
  - [ ] Logout button

**Testing:**
- [ ] Profile loads and shows all data
- [ ] Can edit own profile
- [ ] Cannot edit other user's profile

---

## Section 4: Games Implementation

### 4.1 Game Infrastructure

**Epic:** Game Catalog & Challenge Generation
- **Description:** Implement sealed payload generation, scoring validation, game catalog
- **Effort:** 13 points
- **Dependencies:** 1.3 (database)

**Backend:**
- [ ] Game catalog registry (list of all games, metadata)
- [ ] Sealed payload generation
  - [ ] Function to generate challenges given seed + difficulty
  - [ ] Deterministic: Same seed = same challenge
  - [ ] All games support this
- [ ] Challenge storage
  - [ ] `game_instances` table stores payload + seed
- [ ] Score validation
  - [ ] Verify challenge was solved correctly (game-specific)
  - [ ] Validate score range (not impossible high)
  - [ ] Log all scores with audit trail

**Frontend:**
- [ ] Game registry on client
  - [ ] Map of game_type → game component
- [ ] Challenge receipt
  - [ ] Receive sealed payload from backend
  - [ ] Render game with challenge data
- [ ] Score submission
  - [ ] Collect final score + gameplay data
  - [ ] Send to backend
  - [ ] Handle network retry

**Testing:**
- [ ] Generate challenge with seed, verify deterministic
- [ ] All 15 games can be instantiated with payload
- [ ] Score validation catches invalid scores

---

### 4.2-4.16 Implement Each Game

**Epic:** All 15 Games (Group into Epics by Category)

**Memory Games (3 games, 21 points total):**
- **4.2 Memory Match** (8 pts)
  - [ ] Card grid generation (seed-based positions)
  - [ ] Flip animation
  - [ ] Match detection
  - [ ] Scoring: pairs × time bonus
  - [ ] 3 difficulty levels
  - [ ] Testing: Play a full game, verify score
  
- **4.3 Sequence Recall** (8 pts)
  - [ ] Color sequence generation
  - [ ] Playback animation
  - [ ] Player reproduction (tap buttons)
  - [ ] Sequence extension logic
  - [ ] Scoring: length × speed
  - [ ] Testing: Reach sequence of 8+, verify score

- **4.4 Pattern Memory** (5 pts)
  - [ ] Grid generation (4×4, 5×5, 6×6)
  - [ ] Pattern display (2-3 sec)
  - [ ] Pattern reproduction (tap tiles)
  - [ ] Multiple patterns per game
  - [ ] Scoring: correct/total × time
  - [ ] Testing: Complete all patterns

**Logic Games (3 games, 34 points total):**
- **4.5 Sudoku Duel** (13 pts)
  - [ ] Sudoku generation with seeding (use library)
  - [ ] Grid UI with input validation
  - [ ] Conflict detection (invalid entries highlight)
  - [ ] Hint system (reveal random cell)
  - [ ] Time tracking
  - [ ] Scoring: cells_correct / 81 × time_bonus
  - [ ] Testing: Solve easy, medium, hard puzzles

- **4.6 Logic Grid** (13 pts)
  - [ ] Grid puzzle generation (3×3, 4×4, 5×5)
  - [ ] Clue parsing
  - [ ] Grid UI (tap to mark X/checkmark)
  - [ ] Constraint checking (hidden)
  - [ ] Scoring: correct_cells / total × time_bonus
  - [ ] Testing: Complete a logic grid

- **4.7 Code Breaker** (8 pts)
  - [ ] Code generation (random peg sequence)
  - [ ] Guess rendering
  - [ ] Feedback generation (black/white pegs)
  - [ ] Guess tracking UI
  - [ ] Scoring: (10 - guesses) × 200
  - [ ] Testing: Crack code in 4-6 guesses

**Attention Games (3 games, 21 points total):**
- **4.8 Spot the Difference** (8 pts)
  - [ ] Image pair loading
  - [ ] Difference highlight on tap
  - [ ] Difference detection validation
  - [ ] Wrong tap penalty
  - [ ] Progress tracking
  - [ ] Scoring: diffs_found × time_bonus - penalties
  - [ ] Testing: Find all differences in time

- **4.9 Color Rush** (8 pts)
  - [ ] Word-color mismatch generation
  - [ ] Color option display
  - [ ] Tap detection
  - [ ] Speed escalation
  - [ ] Streak tracking + multiplier
  - [ ] Scoring: correct × speed_multiplier
  - [ ] Testing: Reach speed level 3+

- **4.10 Focus Finder** (5 pts)
  - [ ] Scene loading with hidden objects
  - [ ] Tap detection (within bounds of target)
  - [ ] Hint system (show quadrant)
  - [ ] Progress tracking
  - [ ] Scoring: targets_found × 200 + time_bonus
  - [ ] Testing: Find all targets

**Spatial Games (3 games, 26 points total):**
- **4.11 Puzzle Race** (8 pts)
  - [ ] Piece generation (seed-based)
  - [ ] Drag-and-drop UI
  - [ ] Snap-to-grid logic
  - [ ] Piece rotation (optional)
  - [ ] Progress display
  - [ ] Scoring: (placed / total) × 1000 + time_bonus
  - [ ] Testing: Complete 20-piece puzzle

- **4.12 Rotation Master** (13 pts)
  - [ ] 3D object rendering (Three.js or similar)
  - [ ] Touch rotation controls (two-finger drag)
  - [ ] Rotation validation (tolerance ±5°)
  - [ ] Server-side validation of rotation
  - [ ] Scoring: accuracy % × speed_bonus
  - [ ] Testing: Complete 5 rotation challenges

- **4.13 Path Finder** (5 pts)
  - [ ] Maze generation (seed-based)
  - [ ] Pathfinding UI (tap adjacent cells)
  - [ ] Shortest path calculation (A*)
  - [ ] Efficiency scoring
  - [ ] Progress display
  - [ ] Scoring: (optimal_steps / actual_steps) × 1000 + time_bonus
  - [ ] Testing: Complete 20×20 maze

**Language Games (3 games, 21 points total):**
- **4.14 Word Builder** (8 pts)
  - [ ] Letter set generation (seed-based)
  - [ ] Dictionary validation (60,000+ words)
  - [ ] Word input UI
  - [ ] Duplicate prevention
  - [ ] 3-minute timer
  - [ ] Scoring: sum_of_word_lengths × unique_words × 10
  - [ ] Testing: Find 10+ words

- **4.15 Anagram Attack** (8 pts)
  - [ ] Anagram generation (seed-based)
  - [ ] Answer input UI
  - [ ] Hint system (reveal letters, -50 pts)
  - [ ] 10 anagrams per game
  - [ ] 60-second timer
  - [ ] Scoring: (10 - skipped) × 100 + accuracy_bonus
  - [ ] Testing: Solve 8+ anagrams

- **4.16 Vocabulary Showdown** (5 pts)
  - [ ] Question generation from bank (seed-based)
  - [ ] 4 multiple-choice options
  - [ ] 20-second timer per question
  - [ ] 10 questions per game
  - [ ] Scoring: correct_answers × 100 + time_bonus
  - [ ] Testing: Answer 8+ questions correctly

---

### 4.17 Game Testing & Balance

**Epic:** Game QA & Balance
- **Description:** Test all 15 games for balance, fairness, fun factor
- **Effort:** 13 points
- **Dependencies:** 4.2-4.16 (all games)

**Checklist:**
- [ ] Each game: Play 10 rounds
  - [ ] Score range is reasonable (not too easy, not impossible)
  - [ ] Time limits allow completion (with slight pressure)
  - [ ] Difficulty progression makes sense (easy → hard)
- [ ] Multiplayer fairness: Same seed = same score possible for all
- [ ] No critical bugs (crashes, infinite loops, input lag)
- [ ] UI responsive on 5"-12" screens
- [ ] Scoring math verified (manual calculation vs. game calc)

**Documentation:**
- [ ] Each game: Tested and approved for balance
- [ ] Known issues: Logged (if any)
- [ ] Leaderboard: Shows scores correctly

---

## Section 5: Multiplayer & Real-Time Features

### 5.1 Real-Time Lobby Updates

**Epic:** Socket.io Lobby Events
- **Description:** Players join/leave, settings change, game starts — all in real-time
- **Effort:** 8 points
- **Dependencies:** 1.2 (socket.io), 3.3 (lobby screen)

**Backend Events:**
- [ ] `join-lobby` → broadcast updated player list
- [ ] `leave-lobby` → broadcast updated player list
- [ ] `player-ready` → broadcast updated ready statuses
- [ ] `update-settings` → broadcast new settings
- [ ] `start-game` → broadcast to all players
- [ ] Error handling: Player not in room, invalid lobby, etc.

**Frontend:**
- [ ] Listen to socket events in lobby
- [ ] Update UI in real-time (players, settings, ready status)
- [ ] Navigation on game start

**Testing:**
- [ ] 2 devices: Create lobby on Device 1, join on Device 2
- [ ] Both see each other
- [ ] Settings change on Device 1, Device 2 sees update
- [ ] Device 1 starts game, Device 2 navigates automatically

---

### 5.2 Real-Time Game Events

**Epic:** Socket.io Game Events
- **Description:** During game, broadcast score updates, game completions, rankings
- **Effort:** 8 points
- **Dependencies:** 1.2 (socket.io), 4.X (games)

**Events:**
- [ ] `game-started` → broadcast to all (which game, seed, start time)
- [ ] `game-completed` → broadcast when player finishes (player name, score, rank)
- [ ] `game-result` → broadcast final leaderboard after game
- [ ] `game-error` → broadcast if game submission fails

**Frontend:**
- [ ] Listen to game events
- [ ] Display "Player X finished with 1st place" in activity hub
- [ ] Update visible leaderboard in real-time

**Testing:**
- [ ] Device 1 & 2: Both in same mind war
- [ ] Device 1 completes game first: Device 2 sees "Player 1 finished"
- [ ] Device 2 completes: Shows ranking immediately

---

### 5.3 Activity Hub Chat (Real-Time Messages)

**Epic:** Socket.io Chat Messages
- **Description:** Player messages + game events + system notifications in one feed
- **Effort:** 5 points
- **Dependencies:** 1.2 (socket.io), already implemented in Phase 1

**Backend:**
- [ ] `chat:message` event
  - [ ] Type: player_message, game_event, system_event
  - [ ] Validate message (not empty, length < 500)
  - [ ] Broadcast to mind war room
  - [ ] Store in database (optional for pre-alpha)
- [ ] Game completion → auto-emit system_event
  - [ ] "🎮 Emma finished Logic Duel - 2:14 • 1st place"

**Frontend:**
- [ ] ChatProvider subscribes to mind-war events
- [ ] Messages appear in Activity Hub in real-time
- [ ] Player can send message from chat sheet

**Testing:**
- [ ] Send message: Appears on both devices
- [ ] Finish game: Completion event appears in chat
- [ ] Chat icon shows unread badge when closed

---

## Section 6: Progression & Social Features

### 6.1 Leaderboard & Scoring

**Epic:** Leaderboard & Score Tracking
- **Description:** Track weekly and all-time scores, calculate rankings
- **Effort:** 8 points
- **Dependencies:** 1.3 (database), 4.X (games)

**Backend:**
- [ ] Calculate scores (aggregate from game_scores table)
- [ ] Weekly leaderboard (scores from last 7 days)
- [ ] All-time leaderboard (total lifetime score)
- [ ] Rank calculation (rank = position in sorted score list)
- [ ] `GET /leaderboard/weekly` endpoint
- [ ] `GET /leaderboard/all-time` endpoint

**Frontend:**
- [ ] Fetch leaderboard on screen load
- [ ] Render list with rank, player, score
- [ ] Highlight current player
- [ ] Refresh button

**Database:**
- [ ] Leaderboards table or materialized view
- [ ] Updated after each game completes
- [ ] Indexes for performance

**Testing:**
- [ ] Play 3 games: Scores appear in leaderboard
- [ ] Weekly leaderboard shows only this week
- [ ] Rank updates correctly

---

### 6.2 Basic Progression System (Optional for Pre-Alpha)

**Epic:** Levels & Badges (Optional)
- **Description:** Unlock badges and levels as you play
- **Effort:** 8 points (optional)
- **Dependencies:** 6.1 (scoring), 4.X (games)

**Pre-Alpha MVP:**
- [ ] Level system (based on total score)
  - [ ] Level 1: 0 points
  - [ ] Level 2: 5,000 points
  - [ ] Level 3: 10,000 points
  - [ ] Etc.
- [ ] Simple badges (can be text, images optional)
  - [ ] "First Win" - complete first mind war
  - [ ] "Hot Streak 3" - win 3 games in a row
  - [ ] "Century Club" - 100 points in one game

**Backend:**
- [ ] Calculate level from total score
- [ ] Award badges on game completion
- [ ] Store awarded badges in user profile

**Frontend:**
- [ ] Show level on profile
- [ ] Show badges on profile (grid of earned badges)

**Testing:**
- [ ] Earn first win: Badge appears
- [ ] Play 3 games: Levels update based on score

---

## Section 7: Testing & QA

### 7.1 Manual Testing Plan

**Epic:** Manual QA Testing
- **Description:** Systematic testing on real devices
- **Effort:** 13 points
- **Dependencies:** All previous sections

**Test Scenarios:**

**Onboarding Flow:**
- [ ] Signup → Login → Profile setup → Home screen
- [ ] Each step works, no crashes
- [ ] Can go back and edit profile

**Multiplayer Flow:**
- [ ] Device A: Create lobby
- [ ] Device B: Join lobby with code
- [ ] Both see each other
- [ ] Host: Start game
- [ ] Both devices launch same game
- [ ] Both complete: Scores recorded, rankings updated

**Each Game (Test 1 round on each):**
- [ ] Load successfully
- [ ] Game is playable (no input lag, clear instructions)
- [ ] Can complete in time limit
- [ ] Score submitted successfully
- [ ] Score appears in leaderboard

**Chat/Activity Hub:**
- [ ] Open chat from game screen
- [ ] Send message: Appears on both devices
- [ ] Complete game: Completion event appears in chat
- [ ] Chat icon shows unread count when closed

**Offline Handling (Optional for Pre-Alpha):**
- [ ] Turn off wifi: Continue playing local game
- [ ] Turn on wifi: Score syncs to server
- [ ] Network error: Shows retry UI

**Error Handling:**
- [ ] Bad password on login: Shows error
- [ ] Invalid lobby code: Shows error
- [ ] Network timeout: Shows retry option
- [ ] Game crash: App doesn't close entirely

**Test Environments:**
- [ ] iPhone (iOS 14+)
- [ ] Android (8+)
- [ ] 5" and 6.5" screens (different aspect ratios)
- [ ] Landscape + Portrait

**Documentation:**
- [ ] Test results logged
- [ ] Bugs logged in issue tracker
- [ ] No critical bugs remaining (crashes, data loss)

---

### 7.2 Automated Testing (Optional for Pre-Alpha)

**Epic:** Unit & Integration Tests
- **Description:** Automated test coverage for critical paths
- **Effort:** 13 points (optional)
- **Dependencies:** All previous sections

**Backend Tests:**
- [ ] Auth: Login, register, refresh token
- [ ] Games: Scoring calculation for each game
- [ ] Leaderboard: Rank calculation
- [ ] Socket events: Broadcast on join/start/complete

**Frontend Tests:**
- [ ] Navigation: Login → Home → Lobby → Game
- [ ] State management: User logged in/out
- [ ] Widgets: Lobby screen, game screen, leaderboard

**Coverage Target:** 70%+ for critical paths

---

### 7.3 Performance Testing (Optional)

**Epic:** Performance Baseline
- **Description:** Measure and document performance metrics
- **Effort:** 5 points (optional)
- **Dependencies:** 7.1 (manual testing)

**Metrics:**
- [ ] App startup time: < 3 seconds
- [ ] Game load time: < 2 seconds
- [ ] Lobby updates: < 500ms latency
- [ ] Memory usage: < 200MB (check for leaks)
- [ ] Battery: Note drain over 1 hour of play

**Document baseline:**
- [ ] Screenshot of metrics
- [ ] Known issues (e.g., "Game load takes 3 sec on slow devices")

---

## Section 8: Deployment & Builds

### 8.1 iOS Build

**Epic:** iOS App Build & Deployment
- **Description:** Create release-ready iOS app
- **Effort:** 8 points
- **Dependencies:** All game/backend work

**Checklist:**
- [ ] Xcode project configured
- [ ] Signing certificates obtained (Apple Developer account)
- [ ] Provisioning profiles set up
- [ ] App icon added (1024×1024 and variants)
- [ ] Launch screen designed
- [ ] `flutter build ios --release` succeeds
- [ ] `.ipa` file generated
- [ ] Can install on real iPhone (via Xcode or TestFlight)
- [ ] App launches and connects to backend
- [ ] All 15 games load on device
- [ ] Portrait + landscape work

**Documentation:**
- [ ] iOS build instructions in README
- [ ] Known issues on iOS (if any)

---

### 8.2 Android Build

**Epic:** Android APK & Deployment
- **Description:** Create release-ready Android app
- **Effort:** 8 points
- **Dependencies:** All game/backend work

**Checklist:**
- [ ] Android project configured
- [ ] Signing keystore created
- [ ] `flutter build apk --release` succeeds
- [ ] `.apk` file generated (or `.aab` for Play Store)
- [ ] Can install on real Android device (adb install)
- [ ] App launches and connects to backend
- [ ] All 15 games load on device
- [ ] Portrait + landscape work
- [ ] Tested on Android 8, 10, 12+

**Documentation:**
- [ ] Android build instructions in README
- [ ] Known issues on Android (if any)

---

### 8.3 Backend Deployment to Staging

**Epic:** Backend Staging Deployment
- **Description:** Deploy backend to staging environment (not production)
- **Effort:** 5 points
- **Dependencies:** 1.1, 1.2, 1.3

**Checklist:**
- [ ] Staging server set up (AWS EC2, Heroku, DigitalOcean, etc.)
- [ ] Database provisioned on staging
- [ ] Environment variables configured (.env on staging)
- [ ] API deployed to staging (`git push`, build, start service)
- [ ] Socket.io deployed to staging
- [ ] Database migrations run on staging
- [ ] Health check: `curl https://staging-api.mindwars.com/health` returns 200
- [ ] Flutter app can connect to staging backend
- [ ] Full flow tested on staging (signup → play → leaderboard)

**Documentation:**
- [ ] Staging deployment instructions
- [ ] Known staging-only issues (if any)

---

### 8.4 Distribute to Testers

**Epic:** Tester Distribution
- **Description:** Get build into hands of internal testers
- **Effort:** 5 points
- **Dependencies:** 8.1, 8.2, 8.3

**Methods:**
- [ ] iOS: TestFlight (invite testers via email)
  - [ ] Create TestFlight build
  - [ ] Invite testers
  - [ ] Testers install via TestFlight app
- [ ] Android: Google Play Internal Testing
  - [ ] Create internal test track
  - [ ] Invite testers via Google account
  - [ ] Testers download from Play Store
- [ ] Alternative: Ad-hoc distribution
  - [ ] Email `.apk` to Android testers
  - [ ] Use AltStore or similar for iOS (more complex)

**Tester Documentation:**
- [ ] Test plan (what to test, how to report issues)
- [ ] Known issues (bugs we know about)
- [ ] Feedback form or issue tracker link

---

## Section 9: Documentation

### 9.1 Game Rules & Onboarding

**Epic:** In-App Game Tutorials
- **Description:** Explain how to play each game
- **Effort:** 8 points
- **Dependencies:** 4.2-4.16 (games)

**Checklist:**
- [ ] Each game has a help screen
  - [ ] Show how to play (1-2 screenshots)
  - [ ] Explain scoring
  - [ ] Show example
- [ ] Tutorial on first game play (optional skip)
- [ ] Help button in-game (tap for rules)

**Testing:**
- [ ] Can access help for each game
- [ ] Instructions are clear to a new player

---

### 9.2 Code Documentation

**Epic:** Code Cleanup & Docs
- **Description:** Document critical functions, organize code
- **Effort:** 8 points
- **Dependencies:** All coding complete

**Checklist:**
- [ ] Game scoring functions documented
- [ ] API endpoints documented (comments or external doc)
- [ ] Database schema documented
- [ ] Socket.io events documented
- [ ] Flutter providers documented
- [ ] Critical algorithms have comments (e.g., Sudoku validation)
- [ ] File organization is logical (no random directories)

**Testing:**
- [ ] Another developer can understand the codebase without asking

---

### 9.3 README & Setup Guides

**Epic:** Documentation for Developers & Testers
- **Description:** Write setup guides, API docs, testing instructions
- **Effort:** 5 points
- **Dependencies:** 8.1, 8.2, 8.3

**Checklist:**
- [ ] Backend README
  - [ ] Prerequisites (Node, PostgreSQL, etc.)
  - [ ] Setup (`npm install`, `docker-compose up`)
  - [ ] Running tests
  - [ ] API endpoint reference
- [ ] Frontend README
  - [ ] Prerequisites (Flutter, Android Studio, Xcode)
  - [ ] Setup (`flutter pub get`)
  - [ ] Running on simulator/device
  - [ ] Building APK/IPA
- [ ] Testing guide
  - [ ] How to report bugs
  - [ ] What to test
  - [ ] Known issues
- [ ] Architecture docs
  - [ ] System overview
  - [ ] Database schema
  - [ ] API design

---

## Summary: Quick Reference by Effort

### Quick Wins (1-5 points, High Priority)
- 1.4 Environment setup
- 2.2 Login endpoint
- 3.1 Navigation
- 3.2 Home screen
- 5.1 Lobby updates
- 5.3 Chat messages
- 8.4 Distribute to testers
- 9.3 README

### Medium Effort (5-13 points, Must Do)
- 1.1 API server
- 1.2 Socket.io
- 1.3 Database schema
- 2.1 Registration
- 2.3 Profile
- 3.3 Lobby screen
- 3.4 Game screen
- 3.5 Leaderboard
- 3.6 Profile screen
- 4.1 Game infrastructure
- 4.2-4.16 Games (mixed efforts)
- 6.1 Leaderboards
- 7.1 Manual testing
- 8.1 iOS build
- 8.2 Android build
- 9.1 Game tutorials
- 9.2 Code docs

### Large Effort (13+ points, Optional/Phased)
- 2.4 Child accounts (COPPA)
- 4.17 Game balance testing
- 5.2 Game events
- 6.2 Progression system
- 7.2 Automated testing
- 7.3 Performance testing
- 8.3 Staging deployment

---

## Kanban Setup Recommendations

**Columns:**
1. **Backlog** — All tasks here initially
2. **Ready** — Tasks with dependencies met, ready to start
3. **In Progress** — Currently being worked on
4. **Testing** — Waiting for QA
5. **Done** — Completed and verified

**Labels/Tags:**
- `frontend` `backend` `database` `devops`
- `blocked` `critical` `optional` (for pre-alpha)
- `epic-1` `epic-2` etc. (group by feature epic)

**Card Structure:**
```
[Game Screen] 21 pts
Backend: 5 pts
- [ ] Game rendering
- [ ] Score submission
- [ ] Offline handling

Frontend: 13 pts
- [ ] Game UI layout
- [ ] Input handling
- [ ] Post-game screen

QA: 3 pts
- [ ] Tested on iOS
- [ ] Tested on Android
- [ ] No critical bugs

Dependencies: 4.X (games must be done)
Blocked by: None
```

---

## Success Criteria for Pre-Alpha

Before launching pre-alpha testing, all of the following must be true:

✅ **Core Gameplay**
- [ ] All 15 games fully implemented and tested
- [ ] Scores calculated correctly per game design
- [ ] No crashes during 1 hour continuous play
- [ ] UI responsive on 5"-12" screens

✅ **Multiplayer**
- [ ] Two devices can join same lobby via code/QR
- [ ] Both devices sync game state in real-time
- [ ] Scores recorded and leaderboard updates immediately
- [ ] Chat/Activity Hub shows game completions

✅ **Authentication & Progression**
- [ ] Signup/login works on both iOS and Android
- [ ] Profile can be created and edited
- [ ] Leaderboard shows current and historical scores
- [ ] Games saved to history

✅ **Stability**
- [ ] No memory leaks (check over 30 min play)
- [ ] No crashes on network disconnect/reconnect
- [ ] Database doesn't get corrupted
- [ ] Failed API calls retry and recover

✅ **Deployment**
- [ ] iOS app builds and installs via TestFlight
- [ ] Android APK builds and installs
- [ ] Testers can download and play without dev setup
- [ ] Backend accessible to testers (staging URL)

✅ **Documentation**
- [ ] Testers know what to test (test plan provided)
- [ ] Developers can run the code locally (README updated)
- [ ] Known issues documented (don't surprise testers)
- [ ] Feedback channel set up (GitHub issues, form, etc.)

---

**Document Version:** 1.0  
**Last Updated:** April 6, 2026  
**Owner:** Product / Engineering  
**Status:** Ready for Kanban setup

