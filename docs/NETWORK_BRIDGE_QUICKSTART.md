# Network Bridge Quick Start - ADB Reverse Port Forward

**Purpose:** Enable device-to-backend communication when device and host are on isolated networks

---

## ⚡ Quick Setup (30 seconds)

### 1. Ensure Backend is Running

```bash
cd /mnt/d/mind-wars/backend
docker-compose up -d
docker-compose ps  # Verify all services (postgres, redis, api, multiplayer)
```

### 2. Connect Device and Set Port Forward

```bash
# List connected devices
adb devices

# Set up reverse port forward (replace device ID if different)
adb -s 172.16.0.26:5555 reverse tcp:8080 tcp:4000

# Verify it worked
adb -s 172.16.0.26:5555 reverse --list
# Should show: host-XX tcp:8080 tcp:4000
```

### 3. Launch App

```bash
# Install if not already installed
adb -s 172.16.0.26:5555 install build/app/outputs/flutter-apk/app-alpha-release.apk

# Launch app (tap Mind Wars icon on device or use adb)
adb -s 172.16.0.26:5555 shell am start -n com.mindwars.app.alpha/.MainActivity
```

### 4. Test Connectivity

In the app:
- Login with alpha credentials
- Try to create a lobby
- Check if Socket.io connects successfully

---

## 🔧 If Port Forward Disconnects

The port forward is temporary. If the device disconnects or ADB restarts:

```bash
# Re-establish immediately
adb reverse tcp:8080 tcp:4000

# Verify
adb reverse --list
```

---

## 📱 Common Device IDs

| Device | ID |
|--------|-----|
| Emulator Primary | 127.0.0.1:5555 |
| Emulator Secondary | 127.0.0.1:5556 |
| Physical via USB | Look for serial like `12ABC34D56` |
| Physical via Network | IP like `172.16.0.26:5555` |

Use `adb devices` to see what's connected.

---

## ✅ Success Indicators

- ✅ Login screen shows no connection errors
- ✅ Can create and join lobbies without timeout
- ✅ Multiplayer events appear in real-time
- ✅ Chat messages send/receive instantly
- ✅ Games play normally with other players

---

## ❌ Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection refused" | Check port forward: `adb reverse --list` |
| Backend unreachable | Verify: `curl http://localhost:4000/health` |
| Device offline | Reconnect USB or network, re-setup port forward |
| Multiple devices | Use `-s DEVICE_ID` flag with all adb commands |

---

## Full Technical Details

See: `NETWORK_BRIDGE_IMPLEMENTATION.md`
