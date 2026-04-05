# Mind Wars: Local Alpha Testing Walkthrough & Device Pairing Guide

**Complete step-by-step guide for developers and QA**

**Estimated Time:** 30-45 minutes  
**Required:** Android device, Docker, Flutter SDK, ADB

---

## Table of Contents

1. [Prerequisites & Setup](#prerequisites--setup)
2. [Device Pairing & Connection](#device-pairing--connection)
3. [Backend Services Launch](#backend-services-launch)
4. [Flutter App Build & Deploy](#flutter-app-build--deploy)
5. [Multi-Device Testing](#multi-device-testing---backend-communication)
6. [Verification Checklist](#verification-checklist)
7. [Debug Panel Usage](#debug-panel-usage)
8. [Troubleshooting](#troubleshooting)
9. [Beta Readiness Assessment](#beta-readiness-assessment)

---

## Prerequisites & Setup

### System Requirements

**Check these before starting:**

```bash
# 1. Verify Flutter SDK
flutter --version
# Expected: Flutter X.X.X, Dart X.X.X, DevTools X.X.X

# 2. Verify Android SDK
flutter doctor
# Expected: All items should show ✓ (green checks)
# If any ✗ (red X), run: flutter doctor --android-licenses

# 3. Verify Docker
docker --version && docker-compose --version
# Expected: Docker 20.10+, Docker Compose 1.29+

# 4. Verify ADB (Android Debug Bridge)
adb version
# Expected: Android Debug Bridge version X.X.X

# 5. Verify Git
git --version
# Expected: git version 2.X.X+
```

**If any checks fail:**
```bash
# Install Android licenses
flutter doctor --android-licenses

# Update Flutter SDK
flutter upgrade

# Verify again
flutter doctor
```

### Clone/Navigate to Repository

```bash
# Navigate to project root
cd /mnt/d/source/3D-Tech-Solutions/mind-wars

# Verify structure
ls -la
# Should show: backend/, lib/, pubspec.yaml, docker-compose.yml, etc.

# Check git status
git status
# Expected: On branch main, working tree clean (or with expected changes)
```

---

## Device Pairing & Connection

### Option A: Physical Android Device (Wireless)

#### Step 1: Enable Developer Mode & USB Debugging

```
ON YOUR DEVICE:
1. Settings → About Phone → Find "Build Number" (usually at bottom)
2. Tap "Build Number" 7 times until "Developer options enabled" appears
3. Go back to Settings → Developer Options (should now be visible)
4. Enable: "USB Debugging"
5. Enable: "Wireless debugging" (Android 11+)
```

#### Step 2: Connect to Network

```
ON YOUR DEVICE:
1. Note device IP address:
   - Settings → About Phone → Status → IP Address
   - Example: 192.168.1.100

2. Get pairing code (Android 11+):
   - Settings → Developer Options → Wireless Debugging → "Pair new device"
   - Note the 6-digit code (valid for 10 minutes)
```

#### Step 3: Pair Device via ADB

```bash
# On your computer (in any terminal):

# For Android 11+ (Wireless pairing with code):
adb pair 192.168.1.100:5555 <6_DIGIT_CODE>
# Example: adb pair 192.168.1.100:5555 123456
# Expected output: "Successfully paired to 192.168.1.100:5555"

# For earlier Android versions (USB connection first):
# 1. Connect device via USB cable
# 2. Run: adb devices
# 3. Device should appear in list
# 4. Then: adb tcpip 5555
# 5. Get IP and: adb connect 192.168.1.100:5555
# 6. Disconnect USB cable
```

#### Step 4: Verify Connection

```bash
# List all connected devices
adb devices

# Expected output:
# List of attached devices
# 192.168.1.100:5555      device
# (If it says "unauthorized", click "Allow" on device)

# Verify connection is stable
adb shell getprop ro.build.version.release
# Expected: Android version (e.g., "13", "14")
```

---

### Option B: Android Emulator

#### Step 1: List Available Emulators

```bash
# See all emulator images
emulator -list-avds

# Expected output:
# Pixel_5_API_33
# Pixel_6_API_34
# etc.
```

#### Step 2: Start Emulator

```bash
# Start specific emulator (let it run in background)
emulator -avd Pixel_6_API_34 -no-snapshot &

# Or launch from Android Studio:
# Android Studio → Virtual Device Manager → Click play icon

# Wait for emulator to fully boot (usually 30-60 seconds)
# You'll see the home screen and lock screen

# Verify emulator is running
adb devices
# Expected: emulator-5554 or similar
```

#### Step 3: No Pairing Needed

Emulator is automatically available via ADB. Skip pairing steps.

---

## Backend Services Launch

### Step 1: Create Environment File

```bash
# Navigate to backend directory
cd /mnt/d/source/3D-Tech-Solutions/mind-wars/backend

# Create .env file for local development
cat > .env << 'EOF'
# Mind Wars Local Alpha Testing Environment
NODE_ENV=development
API_PORT=3000
API_HOST=0.0.0.0

# Database Configuration
POSTGRES_DB=mindwars
POSTGRES_USER=mindwars
POSTGRES_PASSWORD=mindwars_alpha_dev_password_12345
POSTGRES_PORT=5433

# Redis Configuration
REDIS_PORT=6380

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production_minimum_32_chars_12345
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# Server Configuration
CORS_ORIGIN=*
LOG_LEVEL=debug
BCRYPT_ROUNDS=12

# Multiplayer Configuration
MULTIPLAYER_PORT=3001
MULTIPLAYER_HOST=0.0.0.0
EOF

# Verify .env created
cat .env
# Should show all configuration variables above
```

### Step 2: Start Docker Services

```bash
# Start all services (PostgreSQL, Redis, API Server, Multiplayer Server)
docker-compose up -d

# Expected output:
# Creating eskienterprises-postgres ... done
# Creating eskienterprises-redis ... done
# Creating eskienterprises-mindwars-api ... done
# Creating eskienterprises-mindwars-multiplayer ... done

# Wait 10 seconds for services to initialize
sleep 10

# Verify all services are running
docker-compose ps

# Expected output (all should show "Up" or "healthy"):
# NAME                                    STATUS
# eskienterprises-postgres                Up (healthy)
# eskienterprises-redis                   Up (healthy)
# eskienterprises-mindwars-api            Up (healthy)
# eskienterprises-mindwars-multiplayer    Up (healthy)
```

### Step 3: Health Check

```bash
# Test API health endpoint
curl -s http://localhost:3000/health | jq .
# Expected: { "status": "ok" }

# Test database connectivity (from another terminal)
docker-compose exec postgres psql -U mindwars -d mindwars -c "SELECT version();"
# Expected: PostgreSQL version output

# Test Redis connectivity
docker-compose exec redis redis-cli ping
# Expected: PONG
```

### Step 4: View Logs (For Troubleshooting)

```bash
# Watch API server logs in real-time
docker-compose logs -f api-server
# Press Ctrl+C to stop watching

# Watch multiplayer server logs
docker-compose logs -f multiplayer-server

# View all logs
docker-compose logs | head -50
```

**Success Indicator:** All services show "healthy" or "Up" status.

---

## Flutter App Build & Deploy

### Step 1: Navigate to Flutter Project

```bash
# Go back to project root
cd /mnt/d/source/3D-Tech-Solutions/mind-wars

# Verify project structure
ls pubspec.yaml lib/main.dart
# Both files should exist
```

### Step 2: Configure for Alpha Testing

```bash
# Edit alpha configuration
cat lib/utils/build_config.dart
# Verify:
# - isAlphaBuild = true
# - useLocalAuth = true  (for local backend testing)
# - debugLogging = true
```

### Step 3: Get Flutter Dependencies

```bash
# Clean previous builds (recommended)
flutter clean

# Get all dependencies from pubspec.yaml
flutter pub get

# Expected: Shows "Done" and no errors
# If errors, run: flutter pub upgrade
```

### Step 4: Build Debug APK

```bash
# Build debug APK for testing
flutter build apk --debug

# Expected output:
# ...
# ✓ Built build/app/outputs/flutter-apk/app-debug.apk (xxx MB).

# Verify APK exists
ls -lh build/app/outputs/flutter-apk/app-debug.apk
# Should show file size (typically 100-200 MB)
```

### Step 5: Install on Device

```bash
# Install APK on connected device
flutter install

# Expected output:
# Installing and launching...
# Launching lib/main.dart on [DEVICE_NAME] in debug mode...
# 
# ✓ Built build/app/outputs/flutter-apk/app-debug.apk.
# Installing build/app/outputs/flutter-apk/app-debug.apk...     6.8s
# D/ConnectivityReceiver( xxxx): Connected to the network
# I/Choreographer(xxxx): Skipped xx frames!  The application may be doing too much work on its main thread.
# Application finished with exit code 0.
```

### Step 6: Verify App on Device

```
ON YOUR DEVICE:
1. App should launch automatically after installation
2. You should see:
   - "Mind Wars Alpha" banner at top
   - Loading spinner briefly
   - Login/Registration screen
   - Home button to skip to home (if logged in)
```

**If app doesn't launch automatically:**
```bash
# Launch app from command line
flutter run

# Or search for "Mind Wars" in app drawer on device and tap
```

---

## Multi-Device Testing - Backend Communication

**Purpose:** Verify that two devices can connect to the same backend and communicate through the multiplayer server.

**Estimated Time:** 20-30 minutes  
**Required:** 2 Android devices, same Wi-Fi network as development machine

---

### Prerequisites for Multi-Device Testing

#### Check Backend is Running

```bash
# From development machine, verify all services
docker-compose ps

# Expected output - all should show "Up" or "healthy":
# NAME                            STATUS
# eskienterprises-postgres        Up (healthy)
# eskienterprises-redis           Up (healthy)
# eskienterprises-mindwars-api    Up (healthy)
# eskienterprises-mindwars-multiplayer  Up (healthy)

# If any are not healthy:
docker-compose logs <service-name>
# Review logs and fix issues before proceeding
```

#### Identify Your Machine's IP Address

```bash
# Get your local network IP (not localhost)
hostname -I | awk '{print $2}'

# Example output: 172.16.0.4
# This is what you'll use for LOCAL_HOST in the flutter run command
```

#### Verify Network Connectivity from Devices

```bash
# On each device:
# 1. Open terminal/shell app
# 2. Or use adb shell from development machine

adb shell ping 172.16.0.4
# Expected: "bytes from 172.16.0.4: icmp_seq=1 ttl=XX time=XX ms"
# This confirms device can reach your development machine
```

---

### Step 1: Deploy App to First Device

```bash
# Connect first device via ADB
adb devices
# Should show: <DEVICE_1_ID>     device

# Deploy app with local backend configuration
# Replace 172.16.0.4 with YOUR machine's IP from above
flutter run \
  --dart-define=FLAVOR=local \
  --dart-define=LOCAL_HOST=172.16.0.4 \
  -d <DEVICE_1_ID>

# Expected: "Launching lib/main.dart..." → App installs and launches on Device 1
```

**Verify Device 1 is Running:**
```bash
# On device 1:
# 1. App should launch automatically
# 2. You should see the home screen
# 3. Tap the 🐛 debug icon (top right)
# 4. Check "Status" tab
#    - API Server should show ✓ (green)
#    - WebSocket Server should show ✓ (green)
```

### Step 2: Deploy App to Second Device

```bash
# Connect second device via ADB
adb devices
# Should show:
# <DEVICE_1_ID>     device
# <DEVICE_2_ID>     device

# Deploy app to second device (same configuration)
flutter run \
  --dart-define=FLAVOR=local \
  --dart-define=LOCAL_HOST=172.16.0.4 \
  -d <DEVICE_2_ID>

# Expected: App installs and launches on Device 2
```

**Verify Device 2 is Running:**
```bash
# Repeat the same checks as Device 1:
# 1. App launches on Device 2
# 2. Tap 🐛 debug icon
# 3. Verify API and WebSocket show ✓
```

---

### Step 3: Test Backend Communication

#### Test 3.1: User Registration on Device 1

```
ON DEVICE 1:
1. Tap "Create Account"
2. Fill in:
   - Username: tester_device_1
   - Email: device1@mindwars.local
   - Password: TestPassword123
3. Tap "Register"
4. Wait for home screen
```

**Verify in Backend:**

```bash
# From development machine, check database
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT id, email, display_name FROM users;"

# Expected output:
#  id |       email        |  display_name
# ----+--------------------+------------------
#   1 | device1@mindwars.local | tester_device_1

# Take note of the user ID (should be 1)
```

#### Test 3.2: User Registration on Device 2

```
ON DEVICE 2:
1. Tap "Create Account"
2. Fill in:
   - Username: tester_device_2
   - Email: device2@mindwars.local
   - Password: TestPassword456
3. Tap "Register"
4. Wait for home screen
```

**Verify Both Users Exist:**

```bash
# Check database again
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT id, email, display_name FROM users ORDER BY id;"

# Expected output:
#  id |       email        |  display_name
# ----+--------------------+------------------
#   1 | device1@mindwars.local | tester_device_1
#   2 | device2@mindwars.local | tester_device_2
```

#### Test 3.3: Multiplayer Connection Test

**On Device 1:**
```
1. Tap "Multiplayer"
2. Debug panel appears
3. Check Status tab:
   - API Server: ✓ (green)
   - WebSocket Server: ✓ (green)
4. Click "Continue" or close panel
5. Tap "Show Debug Panel" button (in info banner)
6. Click Logs tab
7. Look for: "Multiplayer server ready" or connection success message
```

**On Device 2:**
```
1. Same steps as Device 1
2. Both devices should show green ✓ for connectivity
```

---

### Step 4: Verify Backend Logs

**Check Multiplayer Server Logs:**

```bash
# See real-time multiplayer server activity
docker-compose logs -f multiplayer-server

# Expected to see connection events:
# info: Multiplayer server ready
# debug: Client connected: <socket-id>
# debug: Player joined: tester_device_1
```

**Check API Server Logs:**

```bash
# See API call activity
docker-compose logs -f api-server

# Expected to see auth and user endpoints being called:
# info: POST /auth/register
# info: User created: tester_device_1
```

---

### Step 5: Review Debug Logs on Devices

**On Each Device:**

```
1. Tap 🐛 debug icon (app bar)
2. Click "Logs" tab
3. Filter by "Error" (red button)
   - Should show NO red error entries
   - If any errors appear, note them for troubleshooting

4. Filter by "Info" (cyan button)
   - Should show successful API calls
   - Should show WebSocket connection events
   - Should show user registration confirmations
```

---

### Step 6: Test Persistence Across Restart

**On Device 1:**
```
1. Force close app (long-press home → swipe up)
2. Reopen app from app drawer
3. Should see Login screen (not Home)
4. Login with credentials:
   - Email: device1@mindwars.local
   - Password: TestPassword123
5. Should return to home screen
```

**Check Database:**

```bash
# Verify login was recorded
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT email, last_login_at FROM users WHERE email = 'device1@mindwars.local';"

# Expected: Shows recent timestamp in last_login_at
```

---

### Multi-Device Testing Checklist

- [ ] Device 1: App launches without errors
- [ ] Device 2: App launches without errors
- [ ] Device 1: Debug panel shows ✓ API and WebSocket
- [ ] Device 2: Debug panel shows ✓ API and WebSocket
- [ ] Device 1: User registration succeeds
- [ ] Device 2: User registration succeeds
- [ ] Database: Both users created (user IDs 1 and 2)
- [ ] Multiplayer: Device 1 connects to WebSocket
- [ ] Multiplayer: Device 2 connects to WebSocket
- [ ] Logs: No red error entries on either device
- [ ] Restart: Device 1 login persists user data
- [ ] Restart: Device 2 login persists user data

**If ALL checkmarks pass:** ✅ Backend communication working!

---

## Debug Panel Usage

### Accessing Debug Panel

**From Home Screen:**
```
1. Look for 🐛 icon in top-right of app bar
2. Only visible in alpha builds
3. Tap to open full debug panel
```

**Automatic on Multiplayer:**
```
1. Tap "Multiplayer" from home
2. Debug panel appears automatically
3. Shows connectivity test results
4. Tap "Continue" to dismiss
```

### Status Tab - Quick Health Check

```
Shows:
- API Server status (✓ = healthy, ✗ = unreachable)
- WebSocket Server status
- Network availability
- Server URLs being connected to
- Build configuration (flavor, type, API URL, WS URL)

Green ✓ = All systems operational
Red ✗ = Shows specific error message for diagnosis
```

### Logs Tab - Real-Time Activity

```
Displays:
- All app events as they happen
- Filterable by level:
  - Debug: Detailed internal events
  - Info: Key milestones (login, API calls)
  - Warning: Potential issues
  - Error: Failed operations (shows red)

Features:
- Timestamps (HH:MM:SS.mmm format)
- Source information (which component logged it)
- Exception details with stack traces
- Clear button to reset log list

Tips:
- Use Error filter to spot problems immediately
- Use Info filter to trace user actions
- Share logs with dev team for debugging
```

---

## Verification Checklist

### ✅ Phase 1: App Launch Verification (5 minutes)

```bash
# Verify app is running on device
adb shell pidof com.mindwars.app.alpha.debug
# Should return a PID (process ID number)

# View app logs
adb logcat | grep -E "(flutter|mindwars|AuthService)" | head -20
# Should show initialization logs without errors
```

**On Device:**
- [ ] App launches without crash
- [ ] "Alpha Build" banner visible at top
- [ ] No red error screens
- [ ] Login/Registration screen displays
- [ ] Buttons respond to taps

### ✅ Phase 2: Authentication Verification (10 minutes)

**Test Case 2.1: User Registration**

```bash
# Before test: Verify database is empty
docker-compose exec postgres psql -U mindwars -d mindwars -c "SELECT COUNT(*) FROM users;"
# Should return: count = 0

# On Device:
# 1. Tap "Create Account"
# 2. Fill in:
#    - Username: alpha_tester_001
#    - Email: alpha_test_001@mindwars.local
#    - Password: AlphaTest123456
# 3. Tap "Register"

# After registration (in terminal):
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT id, email, display_name FROM users;"

# Expected output:
#  id |            email             |  display_name
# ----+------------------------------+----------------
#   1 | alpha_test_001@mindwars.local | alpha_tester_001
```

**Verification:**
- [ ] Registration succeeds
- [ ] No error message
- [ ] User created in database
- [ ] Auto-login to home screen

**Test Case 2.2: Login After Restart**

```bash
# On Device:
# 1. Force close app (long-press home → swipe app up)
# 2. Relaunch app

# Should see login screen, NOT home screen
# 3. Enter same credentials:
#    - Email: alpha_test_001@mindwars.local
#    - Password: AlphaTest123456
# 4. Tap "Login"

# Verify in database:
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT last_login_at FROM users WHERE email = 'alpha_test_001@mindwars.local';"

# Expected: timestamp of login (recent)
```

**Verification:**
- [ ] Login succeeds
- [ ] Home screen displays after login
- [ ] Database shows updated last_login_at

**Test Case 2.3: Invalid Credentials**

```bash
# On Device:
# 1. At login screen
# 2. Enter:
#    - Email: alpha_test_001@mindwars.local
#    - Password: WrongPassword123
# 3. Tap "Login"

# Should see error message: "Invalid email or password"
```

**Verification:**
- [ ] Error message displays
- [ ] User stays on login screen
- [ ] No crash

### ✅ Phase 3: Game Mechanics Verification (20 minutes)

**Run this test for 3 sample games (choose any 3 of 15):**

#### Test Case 3.1: Color Rush

```bash
# On Device:
# 1. From home screen, tap "Color Rush" icon
# 2. Wait for game to load (should be < 2 seconds)
# 3. See target color and 4×4 grid

# In Terminal (to monitor):
adb logcat | grep -i "color" &
# Keep this running to see debug logs
```

**Game Play:**
- [ ] Game loads without crash
- [ ] Target color visible and clear
- [ ] 4×4 grid displays 16 color tiles
- [ ] Timer shows "3 seconds" (Level 1)
- [ ] Tap matching color → score increases
- [ ] Correct: +5 + combo bonus
- [ ] Wrong: combo resets, no score
- [ ] Timer counts down
- [ ] After completing Level 1 → Level 2 button appears
- [ ] Level 2 shows "2 seconds" (harder)
- [ ] After Level 3 → "Game Complete" message
- [ ] Total score displayed

**Verification:**
```bash
# Check score was stored in database
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT score FROM game_results WHERE user_id = 1 ORDER BY created_at DESC LIMIT 1;"

# Should show score > 0
```

- [ ] Score persists to database

#### Test Case 3.2: Focus Finder

```bash
# On Device:
# 1. From home, tap "Focus Finder"
# 2. See 3 target items in header
# 3. See 22 total items in 5-column grid
# 4. Tap all 3 targets

# Verify progression:
# Level 1: 3 targets (should find all 3)
# Tap "Next Level" → Level 2: 4 targets
# Tap "Next Level" → Level 3: 5 targets
# Game completes
```

**Verification:**
- [ ] Level 1: 3 targets found
- [ ] Level 2: 4 targets found (visibly harder)
- [ ] Level 3: 5 targets found (visibly hardest)
- [ ] Scores increase with successful finds
- [ ] Game completes after Level 3

#### Test Case 3.3: Puzzle Race

```bash
# On Device:
# 1. From home, tap "Puzzle Race"
# 2. See grid of numbered tiles
#    - Level 1: 3×3 grid (9 tiles)
#    - Level 2: 4×4 grid (16 tiles)
# 3. Solve by moving tiles
# 4. Tap "Next Level" after solving

# Note move count and score
# Score = 40 - moves (but minimum 10)
```

**Verification:**
- [ ] Level 1: 3×3 grid
- [ ] Level 2: 4×4 grid (grid expands)
- [ ] Can solve each level
- [ ] Scores decrease with more moves
- [ ] Game completes after Level 3

### ✅ Phase 4: Backend Integration Verification (10 minutes)

**Test Case 4.1: Database Persistence**

```bash
# Play any game and complete it on device

# Check game results saved
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT * FROM game_results ORDER BY created_at DESC LIMIT 1;"

# Expected output:
#  id | game_instance_id | user_id | result | score | time_seconds | created_at
# ----+------------------+---------+--------+-------+--------------+---------------------
#   1 |              | 1       | completed | 25 |        45 | 2026-04-02 10:30:00

# If no rows:
# - Scores not persisting (BLOCKER)
# - Check device logs: adb logcat | grep -i "submit"
```

**Verification:**
- [ ] Game results appear in database
- [ ] Score is correct
- [ ] User ID matches
- [ ] Timestamp is recent

**Test Case 4.2: User Profile Update**

```bash
# After playing games, verify user stats updated:

docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT display_name, level, total_score FROM users WHERE id = 1;"

# Expected: total_score increased from playing games
```

**Verification:**
- [ ] User total_score reflects games played
- [ ] Level may be updated (if implemented)

### ✅ Phase 5: Performance Verification (5 minutes)

```bash
# Monitor device performance during gameplay
adb shell dumpsys meminfo com.mindwars.app.alpha.debug | head -20

# Look for:
# - Native Heap: < 100 MB
# - Dalvik Heap: < 100 MB
# - Total: < 200 MB

# Check for crashes
adb logcat | grep -i "crash\|exception\|fatal"
# Should show nothing if no crashes
```

**Verification:**
- [ ] Memory usage < 200 MB during gameplay
- [ ] No crashes in logs
- [ ] No ANR (Application Not Responding) warnings
- [ ] Frame rate smooth (no stuttering)

### ✅ Phase 6: Shutdown & Cleanup

```bash
# Stop the app on device (optional)
adb shell am force-stop com.mindwars.app.alpha.debug

# Keep backend services running (for beta testing next)
# OR stop backend:
docker-compose down

# To reset everything (WARNING: deletes database):
docker-compose down -v
```

---

## Troubleshooting

### Issue: "Device not found" or "unauthorized"

**Solution:**

```bash
# Check if device appears in list
adb devices

# If shows "unauthorized":
# 1. On device: Long-press notification about USB debugging
# 2. Tap "Allow" or "Always allow from this computer"
# 3. On computer: adb kill-server && adb start-server
# 4. Try again: adb devices

# If still not found:
# 1. Verify pairing code (if wireless): adb pair <IP>:5555 <CODE>
# 2. Or use USB cable: adb connect <IP>:5555 after tcpip 5555
# 3. Check firewall isn't blocking port 5555
```

### Issue: "Multiplayer connection fails or times out"

**Solution - Using the Debug Panel:**

The alpha build includes a **Debug Panel** to diagnose connectivity issues:

```
ON YOUR DEVICE:
1. Tap "Multiplayer" button from home screen
2. Debug panel appears automatically showing:
   - API Server status (✓ or ✗)
   - WebSocket Server status (✓ or ✗)
   - Network availability
   - Server URLs being used
   - Real-time log stream
   
3. Check the Status tab:
   - Green ✓ = Server is reachable
   - Red ✗ = Server unreachable (shows error)
   
4. Check the Logs tab:
   - See all connection attempts in real-time
   - Filter by log level (Debug/Info/Warning/Error)
   - Look for specific error messages
```

**Common Issues & Fixes:**

```
Issue: "API Server" shows ✗
→ Backend API not running
→ Fix: docker-compose up -d api-server

Issue: "WebSocket Server" shows ✗
→ Multiplayer server not running
→ Fix: docker-compose up -d multiplayer-server

Issue: Both show ✓ but connection still fails
→ Check Logs tab for detailed error messages
→ Logs show exact failure point (connection refused, timeout, etc)
→ Share logs with dev team for debugging
```

### Issue: "App crashes on startup"

**Solution:**

```bash
# View crash logs
adb logcat | grep -i "exception\|crash\|fatal" | head -20

# Common causes:
# 1. Network unreachable → Check backend is running: curl http://localhost:3000/health
# 2. Database error → Check postgres: docker-compose logs postgres
# 3. Dependency error → Rebuild: flutter clean && flutter pub get && flutter build apk --debug

# If Flutter crash:
flutter run --verbose
# Shows detailed error information

# Clear app cache
adb shell pm clear com.mindwars.app.alpha.debug
# Then reinstall: flutter install
```

### Issue: "Backend services won't start"

**Solution:**

```bash
# Check Docker is running
docker ps
# If error, start Docker daemon

# View service logs
docker-compose logs

# Common issues:
# 1. Port already in use → Kill process or change port in .env
# 2. Database connection failed → Check .env credentials
# 3. Insufficient memory → Stop other containers: docker system prune

# Reset and rebuild
docker-compose down -v
docker-compose up -d --build
# Wait 30 seconds for services to initialize
docker-compose ps
```

### Issue: "Scores not saving to database"

**Solution:**

```bash
# Check database connection from app
adb logcat | grep -i "database\|postgres\|connection" | head -20

# Verify database is accessible
docker-compose exec postgres psql -U mindwars -d mindwars -c "\dt"
# Should show list of tables (users, game_results, etc.)

# Check if scores are being submitted
adb logcat | grep -i "submit.*score" | head -10

# If not submitting:
# - Check backend logs: docker-compose logs api-server
# - Verify API endpoint responding: curl -X POST http://localhost:3000/api/games/test/submit-score -H "Content-Type: application/json"
```

### Issue: "App runs but games won't load"

**Solution:**

```bash
# View detailed logs
adb logcat | grep -i "game\|widget\|load"

# Common issues:
# 1. Missing game assets → Check assets/ folder exists
# 2. Game widget error → Check lib/games/widgets/ folder
# 3. State management error → Check BaseGameWidget implementation

# Test single game in isolation:
# Edit lib/main.dart to launch specific game directly
# Then: flutter run

# Check assets are registered
cat pubspec.yaml | grep -A 20 "flutter:"
# Should see assets: and games listed
```

---

## Beta Readiness Assessment

### ✅ Prerequisites for Beta Testing

Before moving to beta (wider user testing), verify ALL of these:

```bash
# Automated Checks:

# 1. Database integrity
docker-compose exec postgres psql -U mindwars -d mindwars << 'EOF'
  SELECT COUNT(*) as user_count FROM users;
  SELECT COUNT(*) as result_count FROM game_results;
  SELECT SUM(score) as total_points FROM game_results;
EOF
# All should return numbers > 0 after testing

# 2. API health
curl -s http://localhost:3000/health && echo "✓ API healthy"

# 3. No lingering crashes
adb logcat | grep -i "crash" | wc -l
# Should return 0

# 4. Flutter build succeeds
flutter build apk --debug 2>&1 | grep "Built\|error"
# Should show "Built" with APK size
```

### Manual Verification Checklist

Before declaring ready for beta, manually verify:

#### Functional Tests
- [ ] All 15 games launch without crash
- [ ] Each game has 3 levels (L1, L2, L3)
- [ ] Each level is progressively harder
- [ ] Scoring system works (points increase)
- [ ] Game completion detected correctly
- [ ] Scores persist to database
- [ ] User can logout and login again with same account

#### Performance Tests
- [ ] App launch time < 3 seconds
- [ ] Game load time < 2 seconds
- [ ] Response to taps < 100ms
- [ ] No memory leaks (memory stable)
- [ ] No crashes during 1-hour continuous play
- [ ] Battery drain < 15% per hour

#### Data Integrity Tests
- [ ] 100% of submitted scores appear in database
- [ ] No duplicate scores
- [ ] No data loss on network interruption
- [ ] User profiles update correctly

#### Security Tests
- [ ] Invalid credentials rejected
- [ ] JWT tokens not exposed in logs
- [ ] Password hashed in database (not plain text)
- [ ] CORS headers prevent unauthorized access

### Go/No-Go Decision

**✅ READY FOR BETA when:**
```
✓ All 15 games crash-free (50+ plays minimum)
✓ All scores persist correctly (100% success)
✓ No critical bugs found
✓ All functional tests pass
✓ Performance acceptable
✓ All data integrity tests pass
```

**❌ NOT READY FOR BETA if:**
```
✗ Any game crashes frequently
✗ Scores occasionally don't save
✗ Critical bugs blocking gameplay
✗ Performance issues (freezes, lag)
✗ Any data loss incidents
```

### Report Template for Beta Approval

```markdown
# Mind Wars Alpha → Beta Readiness Report

**Date:** [Date]
**Tester:** [Name]
**Duration:** [Hours of testing]

## Test Results Summary

| Category | Status | Notes |
|----------|--------|-------|
| Games (15/15) | ✅ PASS | All launch, no crashes |
| Auth System | ✅ PASS | Register, login, logout all work |
| Database | ✅ PASS | 100% score persistence |
| Performance | ✅ PASS | No freezes, memory stable |
| Security | ✅ PASS | Passwords hashed, tokens secure |

## Bugs Found

| Severity | Description | Status |
|----------|-------------|--------|
| Critical | [None] | N/A |
| High | [None] | N/A |
| Medium | [None] | N/A |

## Recommendation

**Ready for Beta Testing:** YES ✅

**Conditions:** None

**Next Steps:**
1. Enable multiplayer Mind Wars (after deterministic generation)
2. Expand to 50-100 beta testers
3. Set up crash reporting
4. Create feedback survey

---

**Signed Off By:** [QA Lead]
**Date:** [Date]
**Confidence Level:** [High/Medium/Low]
```

---

## Command Reference (Quick Copy-Paste)

### Complete Setup (All Commands in Order)

```bash
# 1. Navigate to project
cd /mnt/d/source/3D-Tech-Solutions/mind-wars

# 2. Check prerequisites
flutter --version && docker --version && adb version

# 3. Pair device (adjust IP and code as needed)
adb pair 192.168.1.100:5555 123456
adb devices

# 4. Setup backend
cd backend
cat > .env << 'EOF'
NODE_ENV=development
API_PORT=3000
POSTGRES_PASSWORD=mindwars_alpha_dev_password_12345
POSTGRES_PORT=5433
REDIS_PORT=6380
JWT_SECRET=your_super_secret_jwt_key_change_this_12345
EOF

docker-compose up -d
sleep 10
docker-compose ps
curl http://localhost:3000/health

# 5. Build & deploy app
cd ..
flutter clean
flutter pub get
flutter build apk --debug
flutter install

# 6. Run verification tests
adb logcat | grep flutter &
# Then test on device (see Verification Checklist above)

# 7. Monitor game submission
docker-compose exec postgres psql -U mindwars -d mindwars \
  -c "SELECT * FROM game_results ORDER BY created_at DESC;"

# 8. Cleanup (optional)
docker-compose down
```

---

## Success Summary

**When you can check all these boxes, you're ready for beta:**

```
✅ Device paired and connected (adb devices shows device)
✅ Backend services healthy (docker-compose ps shows all "healthy")
✅ App builds and installs without errors (flutter install succeeds)
✅ App launches on device (no crash)
✅ Can register and login (user appears in database)
✅ Can play all 15 games (each loads and is playable)
✅ Scores save to database (queries return results)
✅ 3-level progression works (each game has L1, L2, L3)
✅ Difficulty increases per level (L3 visibly harder than L1)
✅ No crashes during 1+ hour of gameplay
✅ Performance acceptable (no major freezes)
✅ All verification tests pass
```

---

**Document Status:** Complete walkthrough ready  
**Last Updated:** April 2, 2026  
**Next Phase:** Beta Testing (when all checkboxes above are complete)
