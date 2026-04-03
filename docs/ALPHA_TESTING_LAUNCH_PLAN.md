# Mind Wars Alpha Testing Launch Plan

**Status:** Ready to Launch  
**Date:** April 2, 2026  
**Scope:** Full alpha test with 15 games + backend + auth  
**Duration:** 2-4 weeks (depending on issue severity)

---

## Executive Summary

All core systems are in place for alpha testing:
- ✅ 15 playable games with 3-level difficulty progression
- ✅ Backend API with PostgreSQL + Redis
- ✅ User authentication (registration, login, JWT tokens)
- ✅ Flutter mobile app with game launcher
- ✅ Multiplayer server infrastructure (Socket.io)

**Ready to test:** Game mechanics, user flows, fairness, performance

**NOT yet ready:** Deterministic game generation (will be added during testing phase)

---

## Phase 1: Local Development Testing (Week 1)

### 1.1 Backend Setup

**Prerequisites:**
```bash
# Install Docker
docker --version

# Navigate to backend
cd backend/

# Copy env file
cp .env.example .env
# Update .env with appropriate passwords and JWT secret

# Start all services
docker-compose up -d

# Verify services are healthy
docker-compose ps
# All should show "healthy" or "up"

# Check logs
docker-compose logs -f api-server
docker-compose logs -f multiplayer-server
```

**Success Criteria:**
- [ ] PostgreSQL running and accessible
- [ ] Redis cache running and accessible  
- [ ] API server responds to `GET /health`
- [ ] Multiplayer server listening on port 3001
- [ ] No database connection errors in logs

### 1.2 Flutter App Setup

**Prerequisites:**
```bash
# Get dependencies
flutter pub get

# Update build configuration for alpha mode
# File: lib/utils/build_config.dart
# Set: isAlphaBuild = true
# Set: useLocalAuth = true (for local testing)

# Build APK for testing device
flutter build apk --debug

# Or run directly on device
flutter run
```

**Success Criteria:**
- [ ] App builds without errors
- [ ] Splash screen displays with "Alpha" banner
- [ ] Login/registration screens load
- [ ] No crashes on startup

### 1.3 Auth Flow Testing (Local Mode)

**Test Case 1.3.1: User Registration**

```
1. Launch app
2. Tap "Create Account"
3. Enter:
   - Username: test_user_001
   - Email: test@example.com
   - Password: TestPassword123
4. Tap "Register"

EXPECTED:
✓ Registration succeeds
✓ User saved locally (SQLite)
✓ Auto-login to home screen
✓ User profile shows correct username
```

**Test Case 1.3.2: Login After Restart**

```
1. Complete registration (Test 1.3.1)
2. Force close app
3. Relaunch app
4. Tap "Login"
5. Enter credentials from Test 1.3.1
6. Tap "Login"

EXPECTED:
✓ Login succeeds
✓ User taken to home screen
✓ Stored credentials work correctly
✓ No authentication errors
```

**Test Case 1.3.3: Invalid Credentials**

```
1. At login screen
2. Enter:
   - Email: test@example.com
   - Password: WrongPassword
3. Tap "Login"

EXPECTED:
✓ Error message displays: "Invalid email or password"
✓ User remains on login screen
✓ No crash
```

**Success Criteria:**
- [ ] All 3 test cases pass
- [ ] No auth-related crashes
- [ ] Clear error messages on failures

---

## Phase 2: Game Mechanics Testing (Week 1-2)

### 2.1 Single-Player Game Testing

**Test Each of 15 Games:**

#### Color Rush (Attention)
```
Test Case 2.1.1: Color Rush Level 1
1. From home, tap "Color Rush"
2. Game loads
3. See target color and 4×4 grid
4. Tap matching color

VERIFY:
✓ Correct tap awards points (+5 + combo bonus)
✓ Wrong tap resets combo
✓ Timer counts down (3 seconds)
✓ Next level available after level 1 complete
✓ 3-level progression works
✓ Game completes after level > 3
✓ Score increments properly
```

#### Focus Finder (Attention)
```
Test Case 2.1.2: Focus Finder Level 1
1. From home, tap "Focus Finder"
2. See 3 targets, 22 total items
3. Tap all 3 targets
4. Check level progression

VERIFY:
✓ Correct targets have visual feedback
✓ Item count increases per level (targets scale)
✓ All 22 items remain constant (balanced)
✓ Level 2: 4 targets found successfully
✓ Level 3: 5 targets found successfully
✓ Game completes after level > 3
```

#### Puzzle Race (Spatial)
```
Test Case 2.1.3: Puzzle Race Level 1-3
1. From home, tap "Puzzle Race"
2. See 3×3 grid
3. Solve puzzle (move tiles)

VERIFY:
✓ Level 1: 3×3 grid displays
✓ Level 2: 4×4 grid displays
✓ Level 3: 4×4 grid displays (harder shuffle)
✓ Grid size transitions are smooth
✓ Scoring: 40 - (moves × 1), min 10
✓ Game completes after level > 3
```

**Run for all 15 games:**
- Color Rush ✓
- Focus Finder ✓
- Logic Grid ✓
- Path Finder ✓
- Memory Match ✓
- Pattern Memory ✓
- Puzzle Race ✓
- Rotation Master ✓
- Sequence Recall ✓
- Spot Difference ✓
- Sudoku Duel ✓
- Code Breaker ✓
- Anagram Attack ✓
- Word Builder ✓
- Vocabulary Showdown ✓

**Success Criteria:**
- [ ] All 15 games launch without crashes
- [ ] Each game shows correct level number
- [ ] Difficulty clearly increases per level
- [ ] Scoring system works
- [ ] Game completes at expected threshold (level > 3)
- [ ] No UI glitches or layout issues

### 2.2 Game Balance Testing

**Test Case 2.2.1: Difficulty Progression**

For each game:
```
1. Play Level 1 (3-5 times)
2. Play Level 2 (3-5 times)
3. Play Level 3 (3-5 times)

SCORE: Easy, Medium, Hard (subjective)
TIME: Record completion times

EXPECTED:
- Level 1 feels noticeably easier than Level 2
- Level 2 feels noticeably easier than Level 3
- Difficulty increase is smooth (not sudden jump)
- None feel impossible or trivial
```

**Difficulty Feedback Form:**
```
Game: ___________________
Level 1: (1=trivial, 5=hard) ___
Level 2: (1=trivial, 5=hard) ___
Level 3: (1=trivial, 5=hard) ___
Overall Balance: (1=too easy, 3=just right, 5=too hard) ___
```

**Success Criteria:**
- [ ] No game feels broken at any level
- [ ] Clear progression from easy to hard
- [ ] Difficulty curve is smooth
- [ ] All games are within playable range (not impossible)

---

## Phase 3: Backend Integration Testing (Week 2)

### 3.1 Switch to Production Auth Mode

**Setup:**
```dart
// In lib/utils/build_config.dart:
const bool isAlphaBuild = true;
const bool useLocalAuth = false;  // Switch to API auth

// In lib/services/auth_service.dart:
// The API will now handle registration/login
```

**Test Case 3.1.1: Registration via Backend API**

```
1. Change build_config to useLocalAuth = false
2. Restart app
3. Tap "Create Account"
4. Enter user credentials
5. Tap "Register"

EXPECTED:
✓ Request sent to http://localhost:3000/api/auth/register
✓ User created in PostgreSQL
✓ JWT tokens returned
✓ User logged in automatically
✓ Tokens stored securely

VERIFY IN LOGS:
- Check api-server logs for: "User registered: email@example.com"
- Check database: SELECT * FROM users WHERE email = 'email@example.com';
```

**Test Case 3.1.2: Login via Backend API**

```
1. Register user (Test 3.1.1)
2. Force close app
3. Relaunch app
4. Tap "Login"
5. Enter credentials
6. Tap "Login"

EXPECTED:
✓ Request sent to http://localhost:3000/api/auth/login
✓ Password verified against hash
✓ JWT tokens returned
✓ User logged in
✓ Last login timestamp updated

VERIFY IN DATABASE:
SELECT last_login_at FROM users WHERE email = 'email@example.com';
```

**Test Case 3.1.3: Token Refresh**

```
1. Complete login (Test 3.1.2)
2. Wait 1 hour (or mock token expiry)
3. Trigger API call requiring auth

EXPECTED:
✓ Access token expired
✓ System automatically refreshes token
✓ New access token obtained
✓ API call succeeds with new token
✓ User experience unaffected
```

### 3.2 Game Session Recording

**Setup Database Schema:**
```sql
CREATE TABLE game_instances (
  id SERIAL PRIMARY KEY,
  game_type VARCHAR(50),
  level INTEGER,
  random_seed BIGINT,
  puzzle_hash VARCHAR(256),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE game_results (
  id SERIAL PRIMARY KEY,
  game_instance_id INTEGER REFERENCES game_instances(id),
  user_id INTEGER REFERENCES users(id),
  result VARCHAR(20),  -- 'solved', 'completed', etc.
  score INTEGER,
  time_seconds INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Test Case 3.2.1: Score Submission**

```
1. Login via backend
2. Play any game and complete it
3. System submits score to API

EXPECTED:
✓ POST /api/games/{gameInstanceId}/submit-score succeeds
✓ Score stored in game_results table
✓ Player leaderboard position updated
✓ No duplicate submissions

VERIFY:
SELECT * FROM game_results WHERE user_id = ? ORDER BY created_at DESC LIMIT 1;
```

**Success Criteria:**
- [ ] Backend auth works (register, login, refresh tokens)
- [ ] Game results stored in database
- [ ] Leaderboard updated correctly
- [ ] No data loss on submission
- [ ] API returns proper error handling for invalid requests

---

## Phase 4: Multiplayer Preparation (Week 2-3)

### 4.1 Mind War Session Creation

**Setup:**
```bash
# Backend multiplayer server should be running on port 3001
# Redis should be running for session storage
```

**Test Case 4.1.1: Create Mind War Lobby**

```
1. User 1 (Player A) creates Mind War
2. Selects:
   - Game type: Puzzle Race
   - Player count: 2
   - Visibility: Private
3. Receives lobby code: ABC123

EXPECTED:
✓ Lobby created in Redis
✓ Lobby code generated (6 alphanumeric)
✓ Lobby persists for 24 hours
✓ Mind War prepared to generate first game instance
```

**Test Case 4.1.2: Join Mind War Lobby**

```
1. User 2 (Player B) launches app
2. Taps "Join Mind War"
3. Enters lobby code: ABC123
4. Taps "Join"

EXPECTED:
✓ Joins existing lobby
✓ Sees Player A name in lobby
✓ Both players see "Ready" state
✓ Host can start Mind War
```

**Test Case 4.1.3: Generate First Game Instance**

```
1. Player A taps "Start Mind War"
2. System generates first game

EXPECTED:
✓ gameInstanceId created
✓ randomSeed assigned
✓ puzzleHash computed
✓ Both players receive same gameInstanceId
✓ Both players see identical puzzle
```

### 4.2 Deterministic Verification (During Multiplayer Testing)

**Test Case 4.2.1: Same Puzzle for All Players**

```
1. Player A and Player B in same Mind War
2. First game instance generated with seed: 12345
3. Both players play Puzzle Race Level 1
4. Both receive puzzle with 3×3 grid, shuffled with seed 12345

EXPECTED:
✓ Player A's grid layout == Player B's grid layout
✓ Player A's solution path == Player B's solution path
✓ Both can achieve same move efficiency
✓ Fair comparison on leaderboard

VERIFY:
- Take screenshots at game start
- Compare grid layouts side-by-side
- Both should be identical
```

---

## Phase 5: Performance & Stability Testing (Week 3-4)

### 5.1 Load Testing

**Test Case 5.1.1: Concurrent Game Play**

```
Scenario: 10 users playing games simultaneously
1. Launch 10 app instances (or use test runners)
2. All register/login
3. All play different games
4. Track response times, errors, database connections

METRICS:
✓ API response time < 200ms
✓ 0 timeout errors
✓ 0 database connection failures
✓ Game submission success rate = 100%
✓ Memory usage stable
```

### 5.2 Crash Testing

**Test Case 5.2.1: Interruption Recovery**

```
During game play:
1. Interrupt app (home button, kill task, network loss)
2. Relaunch app
3. Check if game state is preserved

EXPECTED:
✓ In-progress games resumable
✓ Submitted scores persist
✓ No data loss
✓ No crashes on resume
```

### 5.3 Battery & Performance

**Test Case 5.3.1: Battery Impact**

```
1. Play games for 1 hour continuously
2. Monitor:
   - Battery drain %
   - CPU usage
   - Memory leaks
   - Frame drops

EXPECTED:
✓ Battery drain < 15% per hour (normal game)
✓ CPU peaks < 80% during gameplay
✓ No memory leaks (memory stable)
✓ Frame rate consistent (no stuttering)
```

---

## Phase 6: Known Issues & Blockers

### Critical Issues (Must Fix Before Public Alpha)

#### 🚨 Deterministic Game Generation (CRITICAL)

**Status:** NOT IMPLEMENTED

**Impact:** Players in same Mind War get different puzzles → **UNFAIR COMPARISON**

**Examples:**
- Puzzle Race Level 1: Player A needs 15 moves, Player B needs 25 moves
- Focus Finder: Player A has easy target placement, Player B has hard placement

**Timeline:** 
- Implement seeded RNG: 3-5 days
- Test reproducibility: 2-3 days
- Total: ~1 week

**Workaround for Phase 1-5 Testing:**
- Test single-player games only (no Mind Wars)
- All players in Mind War should skip comparison testing
- Focus on game mechanics, not fairness

### High Priority Issues (Should Fix Before Wider Alpha)

#### JWT Token Handling
- [ ] Token refresh on expiry
- [ ] Secure token storage
- [ ] CORS headers properly configured

#### Error Handling
- [ ] Network error recovery
- [ ] Timeout handling
- [ ] Graceful degradation

#### Edge Cases
- [ ] User with no avatar
- [ ] Duplicate email registration
- [ ] Rapid successive API calls

---

## Testing Checklists

### Pre-Launch Checklist

```
BACKEND INFRASTRUCTURE:
[ ] PostgreSQL running, schema created
[ ] Redis running
[ ] API server starts without errors
[ ] Multiplayer server starts without errors
[ ] Health checks pass

FLUTTER APP:
[ ] APK builds successfully
[ ] App runs on test device
[ ] No crashes at startup
[ ] All screens load

AUTH SYSTEM:
[ ] Local auth works (alpha mode)
[ ] Backend auth works (production mode)
[ ] Token storage works
[ ] Session persistence works

GAMES:
[ ] All 15 games launch
[ ] Each game has proper UI
[ ] Difficulty levels exist (1, 2, 3)
[ ] Scoring works
[ ] Game completion triggers properly

BACKEND INTEGRATION:
[ ] Score submission works
[ ] Leaderboard updates
[ ] User data stored correctly
```

### Daily Test Execution

Each day during testing, run:

```bash
# 1. Backend health checks
curl http://localhost:3000/health
curl http://localhost:3001/health  # Multiplayer

# 2. Database integrity
psql -h localhost -U mindwars -d mindwars \
  -c "SELECT COUNT(*) FROM users; SELECT COUNT(*) FROM games;"

# 3. Game mechanics sanity (1 game per game type)
# - Launch app
# - Play Color Rush Level 1 (should complete in < 5 min)
# - Play Puzzle Race Level 1 (should complete in < 5 min)
# - Check score in database

# 4. Auth flow sanity
# - Register new user
# - Logout
# - Login with same credentials
# - Verify user data correct
```

---

## Success Criteria for Alpha Launch

**Alpha is ready for expanded testing when:**

```
✅ All 15 games play without crashes
✅ Auth system (local and API) works reliably
✅ Scores submit and persist to database
✅ No critical bugs in game mechanics
✅ Difficulty progression is balanced
✅ UI/UX is intuitive and responsive
✅ Performance metrics are acceptable
✅ Error messages are clear
```

**Alpha is NOT ready if:**

```
❌ Any game crashes consistently
❌ Auth system unreliable
❌ Scores don't persist
❌ Any difficulty level is impossible/trivial
❌ Performance degrades with multiple players
❌ Unclear error messages cause confusion
```

---

## Post-Launch (Phase 7) - Known Work

Once alpha is live with testers:

1. **Implement Deterministic Generation**
   - Add seeded RNG to all games
   - Add gameInstanceId + randomSeed from backend
   - Compute and verify puzzle hashes

2. **Enable Mind War Multiplayer**
   - Generate game instances for Mind Wars
   - Ensure all players in Mind War get same puzzle
   - Fair comparison on leaderboards

3. **Metrics Collection**
   - Track game popularity
   - Identify difficulty outliers
   - Monitor crash rates
   - Analyze user retention

4. **Refinement Based on Feedback**
   - Balance difficulty based on play data
   - Fix UI issues
   - Optimize performance bottlenecks
   - Enhance user experience

---

## Contacts & Escalation

**Issues During Testing:**

| Category | Contact | Response Time |
|----------|---------|----------------|
| Game Crash | Game Dev Team | 2-4 hours |
| Backend Error | Backend Team | 2-4 hours |
| Auth Issue | Security Team | 1-2 hours |
| UI/UX Bug | Frontend Team | 4-8 hours |

---

**Document Status:** Ready for Launch  
**Last Updated:** April 2, 2026  
**Next Phase:** Begin Phase 1 testing immediately

