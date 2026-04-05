# Phase 0/Gate 1 Test Checklist
## Core Lobby Flow Validation on Real Devices

**Date:** 2026-04-05  
**Objective:** Validate that two-device multiplayer lobby creation, joining, roster updates, chat, and presence work correctly  
**Success Criteria:** All items marked ✅ PASS without blockers  

---

## Pre-Test Setup (15 min)

### Server & Local Network
- [ ] Verify backend Docker stack is running
  - [ ] Command: `docker ps | grep mindwars` shows 3 containers (api, multiplayer, postgres)
  - [ ] Nginx gateway is responding: `curl -I http://localhost:4001/health` returns 200 (or connection accepted)
  - [ ] Logs available: `docker logs mindwars-multiplayer-1 -f` for real-time debugging

- [ ] Verify local network connectivity
  - [ ] Both devices are on same WiFi network
  - [ ] Both devices can ping gateway IP: `ping <gateway-ip>` (ask for IP if unknown)
  - [ ] No VPN or corporate firewall blocking port 4001

### Device Setup
**Device A (Primary - Galaxy S25):**
- [ ] APK installed and app version matches backend
  - [ ] Launch app → Settings (if available) → check version number
  - [ ] Note version: _______________
- [ ] Signed in with test account A
  - [ ] Username: _______________
  - [ ] Display name visible in profile
- [ ] App opened, Multiplayer Hub visible
  - [ ] "Create Mind War" button present
  - [ ] No error messages on screen

**Device B (Secondary - Galaxy S20):**
- [ ] APK installed with same version
  - [ ] Version matches Device A: _______________
- [ ] Signed in with test account B (different user)
  - [ ] Username: _______________
  - [ ] Display name visible in profile
- [ ] App opened, Multiplayer Hub visible
  - [ ] "Create Mind War" button present
  - [ ] No error messages on screen

### Logging & Observation Setup
- [ ] Terminal 1: Backend logs
  - Command: `docker logs mindwars-multiplayer-1 -f`
  - Watch for: "socket-connection", "lobby-created", "player-joined", errors
  
- [ ] Terminal 2: Deploy script (if needed for quick rebuild)
  - Keep deploy script accessible: `./scripts/deploy.sh`
  
- [ ] Notepad/document ready to log:
  - Lobby IDs
  - Join codes
  - Errors encountered
  - Timestamps of test steps

---

## Gate 1: Core Lobby Flow Testing (30-45 min)

### Section A: Create Lobby (Device A)

**Step 1: Tap "Create Mind War"**
- [ ] Device A: Open Multiplayer Hub
- [ ] Device A: Tap "Create Mind War" button
- [ ] Observe: Loading spinner appears briefly

**Expected Behavior:**
- Spinner visible for 1-3 seconds
- Screen transitions to Lobby Screen
- Lobby code visible (8-10 character alphanumeric)
- Device A username appears in "Host" position
- Roster shows "1/4" or similar

**If Stuck (No Go Transition):**
- [ ] Check backend logs for errors: `docker logs mindwars-multiplayer-1`
- [ ] Check device logs: `adb logcat | grep "mind_wars\|multiplayer\|socket"`
- [ ] Verify socket connection: Look for "socket connected" message in app or logs
- **BLOCKER:** If socket not connecting, stop and investigate nginx/backend connectivity

**Document:**
- Lobby ID (visible in header or as code): _______________
- Lobby Code (6-digit share code): _______________
- Roster display: _______________ / _______________
- Timestamp: _______________

---

### Section B: Join Lobby (Device B)

**Step 2: Enter Join Code on Device B**
- [ ] Device B: Open Multiplayer Hub
- [ ] Device B: Look for "Join by Code" or "Join Mind War" button
- [ ] Device B: Tap button, enter code from Section A
- [ ] Device B: Tap "Join"

**Expected Behavior:**
- Device B shows loading spinner
- Within 3 seconds, Device B transitions to Lobby Screen
- Device B roster shows "2/4" or "2/2"
- Device B shows Device A username as "Host"
- Device B shows Device B username in player list

**If Join Fails:**
- [ ] Error message visible? Note: _______________
- [ ] "Join code not found" → Device A lobby timed out (server side)
- [ ] "Already in a lobby" → Device B has stale lobby membership (clear cache if needed)
- [ ] Socket error → Network/backend issue (same as Section A)
- **BLOCKER:** If join fails with network error, investigate before proceeding

**Document:**
- Join successful? YES / NO
- Time to join: ___ seconds
- Roster on Device B: ___ / ___
- Timestamp: _______________

---

### Section C: Roster & Presence Verification (Both Devices)

**Step 3: Verify Roster State on Both Devices (Simultaneously)**
- [ ] Device A: Note roster display
  - Player count: ___ / ___
  - Usernames visible:
    1. _______________
    2. _______________
- [ ] Device B: Note roster display
  - Player count: ___ / ___
  - Usernames visible:
    1. _______________
    2. _______________

**Expected Behavior:**
- Both devices show exactly 2 players
- Device A shows itself as "Host" (or badge/indicator)
- Both devices show same usernames in same order
- No "Loading..." or "stale" indicators
- Display names (not usernames) are visible alongside avatar or username
- Avatar/profile picture visible for each player (if offline-cached)

**Roster Mismatch (Critical):**
- [ ] Device A shows 2/4, Device B shows 1/4?
  - **NO-GO:** Roster sync broken. Stop and debug.
- [ ] Usernames different between devices?
  - **NO-GO:** Player list diverged. Stop and debug.

**Document:**
- Rosters match? YES / NO
- Display names visible? YES / NO
- Avatars cached locally? YES / NO / N/A
- Timestamp: _______________

---

### Section D: Chat Test (Both Devices)

**Step 4: Send Chat Message from Device A → Device B**
- [ ] Device A: Locate chat input field
  - If not visible, look for chat icon/button to expand chat panel
- [ ] Device A: Type test message
  - Message: "Hello from Device A"
- [ ] Device A: Tap Send button
- [ ] Device B: Observe chat panel for incoming message

**Expected Behavior:**
- Message appears on Device A immediately (optimistic update)
- Within 2 seconds, message appears on Device B in chat panel
- Message shows Device A username or avatar
- Message shows timestamp
- No error toast on Device A

**Chat Failure Modes:**
- [ ] Message appears on A but not B after 5 seconds?
  - Check backend logs for chat event handling
  - **BLOCKER if silent failure** (no error shown)
- [ ] Error toast on Device A ("Failed to send")?
  - Network/socket issue, check connectivity
- [ ] Message appears as duplicate on A?
  - Optimistic + server response collision, log for review

**Document:**
- Message sent from A? YES / NO
- Message received on B? YES / NO
- Time to deliver: ___ seconds
- Any error messages? _______________
- Timestamp: _______________

---

**Step 5: Send Chat Message from Device B → Device A**
- [ ] Device B: Type test message
  - Message: "Hello from Device B"
- [ ] Device B: Tap Send button
- [ ] Device A: Observe chat panel for incoming message

**Expected Behavior:**
- Same as Step 4, reversed direction
- Message appears on Device B first, then Device A
- Within 2 seconds on Device A

**Document:**
- Message sent from B? YES / NO
- Message received on A? YES / NO
- Time to deliver: ___ seconds
- Timestamp: _______________

---

### Section E: Join/Leave Notifications (Both Devices)

**Step 6: Have Device B Leave Lobby**
- [ ] Device B: Look for "Leave" or "Exit Lobby" button
  - Usually in top-right or bottom action bar
- [ ] Device B: Tap "Leave"
- [ ] Device B: Observe transition (should return to Multiplayer Hub)
- [ ] Device A: Observe lobby roster for update

**Expected Behavior:**
- Device B transitions to hub within 1 second
- Device A roster immediately updates to "1/4" or "1/2"
- Device A shows join/leave notification in chat or roster area
  - Notification text: "Device B left the lobby" or similar
- Device A still shows Device A as Host
- Device A can no longer see Device B in roster

**No-Go Conditions:**
- [ ] Device B leaves but Device A roster still shows 2/4?
  - **NO-GO:** Presence not updating
- [ ] No notification shown on Device A?
  - Minor (chat feature) but note for review

**Document:**
- Device B left successfully? YES / NO
- Device A roster updated? YES / NO
- Notification shown? YES / NO
- Time to update: ___ seconds
- Timestamp: _______________

---

**Step 7: Have Device B Rejoin Lobby**
- [ ] Device B: From Multiplayer Hub, tap "Join by Code"
- [ ] Device B: Enter same code from Section B
- [ ] Device B: Tap "Join"

**Expected Behavior:**
- Device B joins within 3 seconds
- Device A roster updates back to "2/4"
- Device B shows both players in roster
- Chat history preserved (previous messages still visible)

**Document:**
- Rejoin successful? YES / NO
- Roster on both devices updated? YES / NO
- Chat history preserved? YES / NO
- Time to rejoin: ___ seconds
- Timestamp: _______________

---

### Section F: Long-Running Stability (5 min observation)

**Step 8: Observe Both Devices for Stability**
- [ ] Set both devices side-by-side
- [ ] Both in lobby, chat panel open
- [ ] Wait 5 minutes, observing:
  - No disconnect notifications
  - Roster remains correct
  - No UI freezes or crashes
  - No unexpected state changes

**Expected Behavior:**
- Both devices remain connected
- Roster and chat remain consistent
- No "Reconnecting..." messages
- App remains responsive

**Document:**
- Any disconnects? YES / NO
- UI freezes? YES / NO
- Unexpected state changes? YES / NO
- Notes: _______________
- Timestamp: _______________

---

## Gate 1 Summary

### Pass/Fail Decision

**Gate 1: PASS** if ALL of the following are true:
- ✅ Section A: Lobby created successfully on Device A
- ✅ Section B: Device B joined with code successfully
- ✅ Section C: Rosters match on both devices
- ✅ Section D: Chat messages deliver both directions within 2 seconds
- ✅ Section E: Leave/rejoin updates rosters correctly
- ✅ Section F: No disconnects or crashes during 5 min stability test

**Gate 1: NO-GO** if ANY of the following occur:
- ❌ Socket connection fails to establish
- ❌ Roster diverges between devices
- ❌ Chat fails silently (no error, no message delivery)
- ❌ Leave/rejoin doesn't update roster
- ❌ Unexpected disconnects or app crashes

---

## Debug Checklist (If Gate 1 Fails)

### Network Diagnosis
- [ ] Verify both devices on same WiFi: `adb shell ip route` shows same network
- [ ] Verify backend responding: `curl http://<backend-ip>:4001/health`
- [ ] Verify nginx DNS resolution: `docker exec mindwars-gateway nslookup eskienterprises-mindwars-multiplayer`

### Socket Connection Diagnosis
- [ ] Check if socket connects at all:
  - Device logs: `adb logcat | grep "socket"`
  - Backend logs: `docker logs mindwars-multiplayer-1 | grep "connection"`
- [ ] If "Connection refused": Multiplayer container not running or port not exposed
- [ ] If "Timeout": Firewall or routing issue

### Chat Failure Diagnosis
- [ ] Enable verbose logging:
  - Backend: `docker logs mindwars-multiplayer-1 -f | grep -i "chat\|message"`
- [ ] Check if message reaches backend:
  - Look for "chat event received" or similar in logs
- [ ] If message reaches backend but not other device:
  - Broadcasting issue, check socket.io emit logic

### Roster Sync Failure Diagnosis
- [ ] Check if "player-joined" event fires:
  - Backend logs: `docker logs mindwars-multiplayer-1 | grep "player-joined"`
- [ ] If event fires but UI doesn't update:
  - State management issue, check Flutter listener setup
- [ ] If event doesn't fire:
  - Backend handler not calling broadcast, check multiplayer handlers

---

## Next Steps After Gate 1

**If PASS:**
- [ ] Proceed to Gate 2: Lobby Administration (host controls, transfers, kicks)
- [ ] Log Gate 1 completion with timestamp: _______________

**If NO-GO:**
- [ ] Document specific failure point (Section A, B, C, D, E, or F)
- [ ] Run appropriate debug checklist above
- [ ] File issue with logs and device state
- [ ] Retry Gate 1 after fix

---

## Test Artifacts to Preserve

After test completion, collect:
- [ ] Device A logcat: `adb -s <device-a-serial> logcat -d > gate1_deviceA.log`
- [ ] Device B logcat: `adb -s <device-b-serial> logcat -d > gate1_deviceB.log`
- [ ] Backend multiplayer logs: `docker logs mindwars-multiplayer-1 > gate1_backend.log`
- [ ] Screenshots of both devices in lobby (roster visible)
- [ ] This checklist with all fields filled

**Archive location:** `/mnt/d/source/3D-Tech-Solutions/mind-wars/test_results/gate1/`

---

## Test Environment Info

**Device A (Galaxy S25):**
- Serial: _______________
- OS Version: _______________
- App Version: _______________
- Backend IP: _______________

**Device B (Galaxy S20):**
- Serial: _______________
- OS Version: _______________
- App Version: _______________
- Backend IP: _______________

**Backend:**
- Compose file: `/mnt/d/source/3D-Tech-Solutions/mind-wars/backend/docker-compose.yml`
- Nginx gateway port: 4001
- Multiplayer container: `mindwars-multiplayer-1`
- Test start time: _______________
- Test end time: _______________

---

## Contacts & Escalation

If Gate 1 fails with unclear errors:
1. Collect all logs (see Test Artifacts section)
2. Check nginx health: `curl -v http://localhost:4001/health`
3. Verify backend is processing events: `docker logs mindwars-multiplayer-1 -f` during test
4. If debugging locally, use deploy script to rebuild: `./scripts/deploy.sh`
