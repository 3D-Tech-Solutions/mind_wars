# Mind Wars Alpha Testing - Quick Start Guide

**🎮 Get up and running in 15 minutes**

---

## Prerequisites

- Docker & Docker Compose installed
- Flutter SDK installed  
- An Android device or emulator
- Git

---

## Step 1: Start Backend Services (5 minutes)

```bash
# Navigate to backend directory
cd backend/

# Create/update .env file
cat > .env << 'EOF'
NODE_ENV=development
API_PORT=3000
API_HOST=0.0.0.0
POSTGRES_DB=mindwars
POSTGRES_USER=mindwars
POSTGRES_PASSWORD=mindwars_dev_password_12345
POSTGRES_PORT=5433
REDIS_PORT=6380
JWT_SECRET=your_jwt_secret_change_this_in_production_very_long_random_string_12345
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d
CORS_ORIGIN=*
LOG_LEVEL=info
BCRYPT_ROUNDS=12
EOF

# Start all services (PostgreSQL, Redis, API, Multiplayer)
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 10

# Check status
docker-compose ps

# Verify API is responding
curl http://localhost:3000/health
# Should see: {"status":"ok"}
```

**Troubleshooting:**

If services don't start:
```bash
# Check logs
docker-compose logs api-server
docker-compose logs postgres

# Reset everything
docker-compose down -v
docker-compose up -d
```

---

## Step 2: Prepare Flutter App (3 minutes)

```bash
# Navigate to app root
cd ..  # Go back to project root

# Get dependencies
flutter pub get

# Update to alpha testing mode
# Edit lib/utils/build_config.dart:
# Set: isAlphaBuild = true
# Set: useLocalAuth = true

# Build APK
flutter build apk --debug

# Or run on device/emulator directly
flutter run
```

**Device Connection:**

```bash
# For physical device:
adb connect YOUR_DEVICE_IP:5555
adb devices
flutter run

# For emulator:
emulator -avd YourEmulatorName &
flutter run
```

---

## Step 3: Test Login & Games (7 minutes)

### Launch App

1. **App starts** → Shows "Alpha Build" banner at top ✓
2. **Tap "Create Account"**
3. **Fill in:**
   - Username: `tester_001`
   - Email: `tester@example.com`
   - Password: `TestPassword123`
4. **Tap "Register"**
   - Should auto-login and go to home screen ✓

### Play a Game

1. **From home screen, tap "Color Rush"**
2. **See a target color and 4×4 grid**
3. **Tap the matching color**
   - Correct tap → Score increases (+5 + combo)
   - Wrong tap → Combo resets
   - Timer counts down (3 seconds)
4. **Advance to Level 2** (easier than Level 1? No, should be harder)
5. **Game shows "Complete!"** after Level 3
   - Total score should display ✓

### Verify Database

```bash
# From another terminal:

# Connect to database
psql -h localhost -U mindwars -d mindwars -p 5433

# Check user was created
SELECT id, email, display_name FROM users;

# Check game results were stored
SELECT * FROM game_results;

# Verify score submission
SELECT SUM(score) as total_score FROM game_results WHERE user_id = 1;
```

---

## Testing Checklist (One Check = ~5 minutes)

### Basic Functionality
- [ ] **App launches** without crashing
- [ ] **Alpha banner visible** at top of screen
- [ ] **Registration works** (new user created)
- [ ] **Login works** (can logout and login again)
- [ ] **Home screen displays** all 15 game icons

### Game Mechanics (Test 3 Games)
- [ ] **Color Rush** 
  - [ ] Level 1 playable
  - [ ] Level 2 is harder than Level 1
  - [ ] Level 3 is harder than Level 2
  - [ ] Scores increase properly
  
- [ ] **Puzzle Race**
  - [ ] 3×3 grid at Level 1
  - [ ] 4×4 grid at Level 2+
  - [ ] Solvable (not impossible)
  - [ ] Scores decrease with more moves

- [ ] **Focus Finder**
  - [ ] 3 targets at Level 1
  - [ ] 4 targets at Level 2
  - [ ] 5 targets at Level 3
  - [ ] All items found → advance level

### Data Persistence
- [ ] **Scores saved** to database
- [ ] **User profile persists** after logout/login
- [ ] **Game history appears** in user stats (if implemented)

### Error Handling
- [ ] **Invalid credentials** → Clear error message
- [ ] **Network timeout** → Shows retry option (not crash)
- [ ] **Game crash** → App recovers (no data loss)

---

## Common Commands for Testers

### View Backend Logs
```bash
# API Server
docker-compose logs -f api-server

# Multiplayer Server  
docker-compose logs -f multiplayer-server

# Database
docker-compose logs -f postgres
```

### Stop/Start Services
```bash
# Stop everything (keep data)
docker-compose down

# Start everything again
docker-compose up -d

# Fully reset (WARNING: deletes data)
docker-compose down -v
docker-compose up -d
```

### Quick Database Query
```bash
# Count all users
psql -h localhost -U mindwars -d mindwars -p 5433 -c "SELECT COUNT(*) FROM users;"

# View recent game results
psql -h localhost -U mindwars -d mindwars -p 5433 -c "SELECT * FROM game_results ORDER BY created_at DESC LIMIT 10;"

# Clear all test data (WARNING!)
psql -h localhost -U mindwars -d mindwars -p 5433 -c "DELETE FROM game_results; DELETE FROM users;"
```

### Rebuild and Redeploy App
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --debug

# Reinstall on device
adb uninstall com.mindwars.app.alpha.debug
flutter install
```

---

## Issue Reporting Template

When you find a bug, report it like this:

```
ISSUE TITLE: [GAME_NAME] [BUG_TYPE] Brief description

PRIORITY: (Critical/High/Medium/Low)
STATUS: Reproducible/Intermittent/Once only

STEPS TO REPRODUCE:
1. Open app
2. Register user
3. Play [GAME_NAME]
4. [Specific action that causes issue]

EXPECTED: [What should happen]
ACTUAL: [What actually happened]

DEVICE: 
- Model: [Phone model]
- OS: [Android/iOS version]
- App Version: [Build version]

LOGS:
[Copy relevant logs from flutter console or docker-compose logs]

SCREENSHOT: [Attach if applicable]
```

---

## Performance Baseline (Track These)

Each test session, note:

```
Date: _____________
Tester: ____________

PERFORMANCE METRICS:
- Avg game launch time: _____ seconds
- Avg game completion time: _____ seconds
- Battery drain (1 hour): _____ %
- Memory usage peak: _____ MB
- Crashes encountered: _____ (list games)

USER EXPERIENCE:
- UI responsiveness: (Smooth/Laggy/Choppy)
- Button feedback: (Instant/Delayed)
- Game difficulty balance: (Too Easy/Just Right/Too Hard)

ISSUES FOUND:
- Issue 1: [Description]
- Issue 2: [Description]
```

---

## Expected vs. Actual Behavior

### ✅ What Should Work

1. **Auth System**
   - Register new account
   - Login with email/password
   - Auto-logout after inactivity
   - Password reset via email (if implemented)

2. **Games**
   - All 15 games launch
   - Clear difficulty progression (L1 → L2 → L3)
   - Scores submitted to backend
   - Game completion detected

3. **UI**
   - No crashes
   - Responsive to taps
   - Clear error messages
   - Proper screen transitions

4. **Backend**
   - Scores persist in database
   - User data correct
   - Response times < 500ms
   - Handles multiple concurrent players

### ⚠️ Known Issues (Expected in Alpha)

1. **Not yet implemented:**
   - Multiplayer Mind Wars (coming Phase 4)
   - Deterministic puzzle generation (coming Phase 5)
   - Leaderboard display
   - Achievement badges
   - Social features

2. **UI Quirks:**
   - Alpha banner can't be dismissed
   - Some animations may stutter
   - Layout might not be perfect on all devices

3. **Performance:**
   - First game load might be slow (< 2 seconds)
   - Occasional delays on slow network

---

## When to Escalate

**Stop testing and escalate immediately if:**

- 🛑 App crashes on startup
- 🛑 Cannot register account
- 🛑 Cannot login
- 🛑 Scores don't save
- 🛑 Backend services won't start
- 🛑 All games crash consistently

**High priority:**
- Game unplayable (impossible or trivial difficulty)
- Major UI bugs (can't navigate)
- Severe performance issues (freezes)

**Medium priority:**
- Minor UI glitches
- Typos or unclear messages
- Occasional animation stuttering

---

## Success Indicators for Alpha

**Alpha is **READY** when:**
- ✅ All 15 games playable without crashes
- ✅ User can register, login, logout
- ✅ Scores persist in database
- ✅ Game difficulty clearly increases per level
- ✅ Performance is acceptable (no major freezes)
- ✅ No critical bugs blocking gameplay

**Alpha is **NOT READY** if:**
- ❌ Any game crashes
- ❌ Auth broken
- ❌ Scores don't save
- ❌ Severe performance issues

---

## Support Contacts

- **Bug Reports:** github.com/3D-Tech-Solutions/mind-wars/issues
- **Slack Channel:** #mind-wars-alpha-testing
- **Quick Help:** Message @GameDevTeam on Slack

---

## Tips for Great Testing

1. **Test on real device** (not just emulator)
2. **Try all 15 games**, not just favorites
3. **Report reproducible bugs** with clear steps
4. **Test edge cases** (fast clicks, network loss, etc.)
5. **Play for 30+ minutes** to catch intermittent issues
6. **Try multiple user accounts** to test isolation
7. **Take screenshots** of UI issues
8. **Note performance** (battery, heat, lag)

---

**Happy testing! 🎮**

Questions? Check the full [ALPHA_TESTING_LAUNCH_PLAN.md](docs/ALPHA_TESTING_LAUNCH_PLAN.md)
