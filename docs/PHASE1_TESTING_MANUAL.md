# Phase 1 Testing Manual - Mind Wars Multiplayer

This document provides step-by-step instructions to manually test Phase 1 multiplayer functionality on your physical Android devices.

## Prerequisites

- 2+ Android devices (or emulators) connected via USB with ADB debugging enabled
- Backend services running: `cd backend && docker compose up -d`
- APK built and ready: `/build/app/outputs/flutter-apk/app-local-debug.apk`
- Network: Both devices on same WiFi (or connected to host machine via ADB)

## Environment Setup

### Terminal 1: Monitor Backend Logs
```bash
cd /mnt/d/source/3D-Tech-Solutions/mind-wars/backend
docker logs -f eskienterprises-mindwars-multiplayer 2>&1 | grep -E "create-lobby|join-lobby|player-joined"
```

This shows real-time multiplayer events from the backend.

### Terminal 2: Monitor Device 1 Logs  
```bash
adb logcat -s flutter 2>&1 | grep -E "\[MultiplayerService\]|\[createLobby\]|✓|✗|error"
```

Shows socket.io connection and lobby creation events from Device 1 (Galaxy S25).

### Terminal 3: Monitor Device 2 Logs
```bash
adb devices -l  # Find second device ID
adb -s <DEVICE_2_ID> logcat -s flutter 2>&1 | grep -E "\[MultiplayerService\]|\[joinLobby\]|✓|✗|error"
```

Shows socket.io connection and lobby joining events from Device 2.

### Terminal 4: Deployment & Manual App Control
```bash
cd /mnt/d/source/3D-Tech-Solutions/mind-wars
# This terminal is for running deploy commands and manually controlling the app
```

---

## Phase 1 Test Sequence

### **Test 1: Deploy & Login (5 minutes)**

#### On Terminal 4:
```bash
# Deploy the latest APK to all connected devices
bash scripts/deploy.sh local
```

Wait for both devices to finish deploying and launching the app.

#### On Each Device:
1. **Splash Screen** → Wait for "Backend health check passed ✓"
2. **Login** → Enter `tde8276@gmail.com` / `password123`
3. **Home Screen** → Look for "Multiplayer" button in navigation

**Expected Logs (Terminals 1-2):**
- Terminal 2: `[AuthService.login] ✓ Login successful, user: DigitalByooki`
- Terminal 1: `User authenticated: tde8276@gmail.com` (may see multiple times for multiple logins)

---

### **Test 2: Socket.io Connection (3 minutes)**

#### On Device 1 (Galaxy S25):
1. Tap **"Multiplayer"** button
2. **Expected**: Screen shows "Connected as DigitalByooki" (green status indicator)
3. **Observe Terminal 2** for connection logs

**Expected Logs:**
```
[MultiplayerService] Creating socket.io client...
[MultiplayerService] URL: http://172.16.0.4:4001
[MultiplayerService] Socket.io client created
[MultiplayerService] ✓✓✓ Connected to multiplayer server
[MultiplayerService] Socket ID: <socket_id>
```

**If you get error "Unable to connect to the multiplayer server":**
- Check Terminal 1: `docker ps | grep -E "nginx|multiplayer"`
- All containers should be "Up X minutes" with "(healthy)" status
- If unhealthy, restart: `docker compose restart`

---

### **Test 3: Create Lobby - Device 1 (5 minutes)**

#### On Device 1 (Galaxy S25):
1. Tap **"Create Mind War"**
2. Enter lobby name: **"Test Lobby 1"**
3. Tap **"Create Lobby"**
4. **Expected**: Screen displays a 5-6 character code (e.g., "A7K9X")

**Critical Logs to Watch:**

Terminal 2 (Device 1):
```
[createLobby] Starting lobby creation for: Test Lobby 1
[createLobby] ✓ Socket connected, emitting create-lobby event
[createLobby] ✓ Received ack response: {success: true, lobby: {id: ..., code: A7K9X, ...}}
[createLobby] ✓ Lobby created: A7K9X
```

Terminal 1 (Backend):
```
[create-lobby] Received event from <user_id>
[create-lobby] Parsed: name=Test Lobby 1, maxPlayers=10, totalRounds=3
[create-lobby] Generated code: A7K9X
[create-lobby] ✓ Lobby created: A7K9X by user <user_id>
[create-lobby] ✓ Callback invoked successfully
```

**Troubleshooting:**
- If error "Socket is not connected": Check socket connection in Test 2 first
- If error "Timeout waiting for server response": Backend multiplayer server may be down (check Terminal 1)
- If error appears but no backend logs: Authentication issue - token not being passed

---

### **Test 4: Copy Code & Switch to Device 2 (2 minutes)**

#### On Device 1:
1. **Copy** the lobby code (e.g., "A7K9X") - tap the code to copy or write it down
2. Switch to Device 2

#### On Device 2:
1. Tap **"Multiplayer"** button
2. **Expected**: Shows "Connected as DigitalByooki" (connected)

**Terminal 3 should show**:
```
[MultiplayerService] ✓✓✓ Connected to multiplayer server
[MultiplayerService] Socket ID: <different_from_device_1>
```

---

### **Test 5: Join Lobby - Device 2 (3 minutes)**

#### On Device 2:
1. Tap **"Join Mind War"**
2. Enter the code you copied from Device 1 (e.g., "A7K9X")
3. Tap **"Join Mind War"**
4. **Expected**: Screen shows the lobby name "Test Lobby 1"

**Critical Logs to Watch:**

Terminal 3 (Device 2):
```
[joinLobbyByCode] Starting join for code: A7K9X
[joinLobbyByCode] ✓ Socket connected, emitting join-lobby-by-code event
[joinLobbyByCode] ✓ Received ack response: {success: true, lobby: {...}}
```

Terminal 1 (Backend):
```
[join-lobby-by-code] Received join request from <user_id_device_2>
[join-lobby-by-code] ✓ Lobby created: A7K9X (player count now 2)
```

**Troubleshooting:**
- If error "Lobby not found": Code may be wrong or already expired
- If error "Lobby is full": Max players reached (default 10)
- If connection error: Socket.io not connected - restart Device 2's Multiplayer screen

---

### **Test 6: Verify Both Devices in Lobby (2 minutes)**

#### On Both Devices:
1. Both should show the same lobby: **"Test Lobby 1"**
2. Player count should show **2 players**

#### Optional: Check Real-Time Updates
On Device 1, tap the back button to exit lobby, then re-enter.
**Expected**: Device 2 receives "player-left" event and shows 1 player. When Device 1 rejoins, shows 2 players again.

**Backend should show**:
```
User <user_id_1> left lobby <lobby_id>
User <user_id_1> joined lobby <lobby_id>
```

---

## Quick Reference: Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| "Unable to connect to multiplayer" | Socket auth token not passed | Update latest APK from `bash scripts/deploy.sh local` |
| "HTTP 502 Bad Gateway" | Nginx can't reach multiplayer server | Check `docker ps` - restart backend: `docker compose restart` |
| "Authentication token required" | Old APK without token fix | Rebuild and deploy latest APK |
| "Socket is not connected" | Connection timeout or failed | Wait 10 seconds and try again, or restart Multiplayer screen |
| "Lobby not found" | Wrong code or expired | Check code spelling, try creating new lobby |
| Device offline | ADB connection lost | Run `adb kill-server && adb start-server` |

---

## Advanced Debugging

### Check Socket Connection Status
```bash
# On device, see if socket connected
adb logcat -s flutter -d | grep -A 5 "Socket connected status"
```

### Check Backend Health
```bash
# From host machine
curl http://172.16.0.4:3000/health  # REST API
curl http://172.16.0.4:4001/socket.io/  # Socket.io endpoint (should return 400, not 502)
```

### View Full Backend Logs
```bash
# Terminal 1 - unfiltered
docker logs -f eskienterprises-mindwars-multiplayer
```

### Capture Full Device Logs
```bash
# Clear old logs and capture 30 seconds
adb logcat -c
sleep 2
adb logcat -s flutter > device_logs.txt &
# ... perform test ...
sleep 30
pkill -f "adb logcat"
# Review logs: cat device_logs.txt | grep -E "\[MultiplayerService\]|\[createLobby\]"
```

---

## Summary: Expected Flow

```
Device 1                          Backend                        Device 2
─────────────────────────────────────────────────────────────────────────────
Open Multiplayer
  │
  └─→ Socket.io connect ──────→ [auth check] ──────→ ✓ Connected
      (passes JWT token)
         │
         ├─→ Tap "Create Lobby"
         │
         └─→ emit create-lobby ──→ [generate code] ──→ ack callback
             ("Test Lobby 1")     [insert to DB]      {code: A7K9X}
                 │
                 └─→ Show code: A7K9X
                     │
                     └─→ [Device 1 player shown in lobby]


                                                     Device 2
                                                     Open Multiplayer
                                                       │
                                                       └─→ Socket.io connect
                                                           (passes JWT token)
                                                              │
                                                              └─→ Tap "Join Mind War"
                                                              │
                                                              └─→ emit join-lobby-by-code
                                                                  ("A7K9X")
                                                                    │
                                                                    ↓
                                                    [find lobby in DB]
                                                    [add player]
                                                    [ack callback]
                                                    {"code": "A7K9X", "status": "waiting"}
                                                       │
                                                       └─→ Show lobby "Test Lobby 1"
                                                           + 2 players

Device 1 receives "player-joined" event
Shows: 2 players in lobby
```

---

## Next Steps (Phase 2)

Once Phase 1 is working:
- [ ] Start voting session for game selection
- [ ] Test game payload immutability
- [ ] Verify turn-based gameplay
- [ ] Test disconnect/reconnect scenarios
- [ ] Load testing with 3+ devices

