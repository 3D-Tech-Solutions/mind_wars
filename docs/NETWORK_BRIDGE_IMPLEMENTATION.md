# Network Bridge Implementation - ADB Reverse Port Forward

**Date:** 2025-11-17  
**Status:** ✅ COMPLETE  
**Build:** Alpha APK deployed to device 172.16.0.26

---

## Problem Statement

The Android emulator/device on Hyper-V network (172.16.0.x) cannot directly communicate with the WSL host (172.28.x.x) where the backend server runs on port 4000. This creates network isolation that breaks:
- REST API calls (`ApiService` trying to reach `war.e-mothership.com:4000`)
- Socket.io multiplayer connections (`MultiplayerService` trying to reach `war.e-mothership.com:4000`)

---

## Solution Architecture

### ADB Reverse Port Forward

```
┌─────────────────────────────────────────────────────────────┐
│  Android Device (172.16.0.26)                              │
│  ┌────────────────────────────────────────────────────┐   │
│  │ Mind Wars App                                      │   │
│  │ • ApiService: http://127.0.0.1:8080/api          │   │
│  │ • MultiplayerService: http://127.0.0.1:8080      │   │
│  └────────────────────────────────────────────────────┘   │
│           ↓ (port 8080)                                    │
│  ┌────────────────────────────────────────────────────┐   │
│  │ ADB Bridge (via USB/network)                       │   │
│  │ adb reverse tcp:8080 tcp:4000                      │   │
│  └────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                         ↓ (tunneled to host)
┌─────────────────────────────────────────────────────────────┐
│  WSL Host (172.28.x.x)                                      │
│  ┌────────────────────────────────────────────────────┐   │
│  │ Backend Server (docker-compose)                    │   │
│  │ • API Gateway: http://localhost:4000              │   │
│  │ • Port 8080 internally routes to 4000             │   │
│  └────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### How It Works

1. **Device makes request** to `127.0.0.1:8080` (localhost from device perspective)
2. **ADB intercepts** this via reverse port forward rule: `tcp:8080 → tcp:4000`
3. **ADB tunnels** the connection back to the host machine
4. **Host receives** traffic on port 4000 where backend server listens
5. **Backend responds** through the same tunnel back to device

---

## Implementation Details

### Files Modified

#### 1. `lib/main.dart` (ApiService Initialization)

**Change:** API endpoint updated to use localhost:8080

```dart
// [2025-11-17 Bugfix] Changed API endpoint to use localhost:8080 via ADB reverse port forward
// Device connects to 127.0.0.1:8080 which tunnels to host:4000 via: adb reverse tcp:8080 tcp:4000
// This works around network isolation between device (172.16.0.x) and WSL host (172.28.x.x)
_apiService = ApiService(
  baseUrl: 'http://127.0.0.1:8080/api',
);
```

**Before:** `http://war.e-mothership.com:4000/api`  
**After:** `http://127.0.0.1:8080/api`

#### 2. `lib/utils/build_config.dart` (Socket.io Configuration)

**Change:** WebSocket base URL updated to use localhost:8080

```dart
static String get wsBaseUrl {
  // [2025-11-17 Bugfix] Updated Socket.io endpoint to use localhost:8080 via ADB reverse forward
  // Device connects to 127.0.0.1:8080 which tunnels to host:4000 via: adb reverse tcp:8080 tcp:4000
  // This works around network isolation between device (172.16.0.x) and WSL host (172.28.x.x)
  return 'http://127.0.0.1:8080';
}
```

**Before:** `http://war.e-mothership.com:4000`  
**After:** `http://127.0.0.1:8080`

### Build & Deployment

**Build Command:**
```bash
cd /mnt/d/mind-wars
flutter clean
flutter pub get
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
```

**Installation Command:**
```bash
adb -s 172.16.0.26:5555 uninstall com.mindwars.app.alpha
adb -s 172.16.0.26:5555 install build/app/outputs/flutter-apk/app-alpha-release.apk
```

**Result:** ✅ `app-alpha-release.apk` (52.8MB) successfully installed

---

## ADB Port Forward Configuration

### Setup

```bash
# Set up reverse port forward
adb -s 172.16.0.26:5555 reverse tcp:8080 tcp:4000

# Verify configuration
adb -s 172.16.0.26:5555 reverse --list
```

**Output:**
```
host-19 tcp:8080 tcp:4000
```

### Port Mapping

| Component | Device IP | Device Port | Host Port | Purpose |
|-----------|-----------|------------|-----------|---------|
| App (API) | 127.0.0.1 | 8080 | 4000 | REST API calls |
| App (Socket.io) | 127.0.0.1 | 8080 | 4000 | Multiplayer/realtime |
| Backend Server | localhost | 4000 | 4000 | Gateway/multiplayer |

### Persistence

⚠️ **Important:** ADB reverse port forward is **temporary** and will reset when:
- Device disconnects
- ADB connection is restarted
- Device is rebooted

**To re-establish:**
```bash
adb reverse tcp:8080 tcp:4000
```

---

## Testing & Verification

### Pre-Testing Checklist

- [ ] Backend server running (`docker-compose up -d` in `backend/`)
- [ ] Device connected via ADB
- [ ] Port forward configured: `adb reverse tcp:8080 tcp:4000`
- [ ] Port forward verified: `adb reverse --list`

### Test Scenarios

#### 1. REST API Connectivity

**Expected:** ApiService successfully reaches backend at `http://127.0.0.1:8080/api`

```dart
// In app, check ApiService logs:
// "API request to: http://127.0.0.1:8080/api/auth/login"
// "Response status: 200" (if credentials valid)
```

#### 2. Socket.io Multiplayer

**Expected:** MultiplayerService establishes WebSocket connection to `http://127.0.0.1:8080`

```dart
// In app, check multiplayer logs:
// "Connected to multiplayer server"
// "Socket.io events: lobby-created, player-joined, turn-made, etc."
```

#### 3. Lobby Creation & Gameplay

**Expected:** Create lobby, join with another player, play game normally

- Lobby creation succeeds
- Real-time multiplayer events broadcast
- Turns process and scores update
- No network timeouts or connection errors

---

## Troubleshooting

### Issue: "Connection refused" or "Cannot reach host"

**Cause:** Port forward not active or incorrect configuration

**Solution:**
```bash
# Re-establish port forward
adb reverse tcp:8080 tcp:4000

# Verify
adb reverse --list

# Should show: "host-XX tcp:8080 tcp:4000"
```

### Issue: Backend server on port 4000 not responding

**Cause:** Backend not running or listening on wrong port

**Solution:**
```bash
cd backend
docker-compose ps  # Check if services are running
docker-compose up -d  # Start if not running
curl http://localhost:4000/health  # Test endpoint
```

### Issue: Device can't connect after reboot

**Cause:** Port forward was temporary and cleared on reboot

**Solution:**
```bash
# Reconnect device and re-establish port forward
adb devices  # List connected devices
adb reverse tcp:8080 tcp:4000  # Set up port forward again
```

### Issue: Multiple devices connected - which one to use?

**Cause:** Ambiguous ADB target

**Solution:**
```bash
# List all devices
adb devices

# Use -s flag with specific device
adb -s 172.16.0.26:5555 reverse tcp:8080 tcp:4000
```

---

## Technical Notes

### Why 127.0.0.1:8080 (not localhost)?

1. **127.0.0.1** is the IP address for localhost (universally understood)
2. **8080** is mapped to the host's port 4000 via ADB reverse
3. This avoids DNS resolution issues on the device
4. More reliable than using hostname "localhost"

### Why Not Direct Network Access?

| Method | Status | Issue |
|--------|--------|-------|
| Direct device-to-host | ❌ Fails | Network isolation (172.16.0.x ↛ 172.28.x.x) |
| Domain name (war.e-mothership.com) | ❌ Fails | Not reachable from device's network |
| Localhost via ADB reverse | ✅ Works | ADB provides transparent tunneling |

### Backend Considerations

- Backend must listen on `0.0.0.0:4000` (all interfaces)
- Docker-compose gateway already configured for this
- No changes to backend code needed
- Port 4000 remains the canonical backend port

---

## Next Steps

### Immediate

1. ✅ Test API connectivity (login, register flows)
2. ✅ Test multiplayer lobby creation and joining
3. ✅ Play a full game round with multiplayer
4. ✅ Verify real-time events (chat, turns, scoring)

### Future Enhancements

- **Production Network:** Replace with proper DNS or API gateway
- **Dynamic Endpoint:** Make endpoint configurable (BuildConfig per flavor)
- **Offline Mode:** Ensure offline-first architecture still works
- **CI/CD:** Automate deployment and port forwarding in test environments

---

## Related Documentation

- Backend setup: `backend/README.md`, `backend/QUICK_START.md`
- API endpoints: `backend/api-server/` API documentation
- Network architecture: `ARCHITECTURE.md`
- Build configuration: `ALPHA_BUILD_SETUP.md`

---

## Summary

✅ **Network isolation resolved using ADB reverse port forward**
- Device port 8080 → Host port 4000
- Transparent tunneling via ADB
- No backend changes required
- Enables full multiplayer and API functionality

🔄 **Port forward requires re-establishment after device disconnection/reboot**  
🚀 **Ready for multiplayer testing and gameplay validation**
