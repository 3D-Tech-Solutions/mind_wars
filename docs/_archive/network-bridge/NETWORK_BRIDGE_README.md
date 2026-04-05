# ADB Network Bridge - Mind Wars Multiplayer

## 🎯 Purpose

Enables multiplayer functionality for Mind Wars when device and backend are on isolated networks using ADB reverse port forward. Routes device port 8080 to host port 4000 transparently via ADB bridge.

## 🚀 Quick Start (30 seconds)

```bash
# 1. Start backend (if not already running)
cd backend && docker-compose up -d && cd ..

# 2. Set up network bridge (automated)
./setup-network-bridge.sh

# 3. Launch app on device
# Tap Mind Wars Alpha icon
```

Done! ✅ Your device can now communicate with the backend.

## 📋 What's Included

### Configuration

- ✅ `lib/main.dart` - Updated API endpoint to `http://127.0.0.1:8080/api`
- ✅ `lib/utils/build_config.dart` - Updated WebSocket to `http://127.0.0.1:8080`
- ✅ `app-alpha-release.apk` - Built with new configuration

### Automation

- ✅ `setup-network-bridge.sh` - One-command setup (detects devices, sets up port forward, verifies backend)

### Documentation

- `NETWORK_BRIDGE_IMPLEMENTATION.md` - Complete technical guide with troubleshooting
- `NETWORK_BRIDGE_QUICKSTART.md` - Quick reference
- `NETWORK_BRIDGE_VERIFICATION.md` - Implementation verification checklist
- `NETWORK_BRIDGE_SUMMARY.md` - Overview and next steps
- `NETWORK_BRIDGE_DEPLOYMENT_MANIFEST.md` - Deployment details

## 🔧 How It Works

```
Device App (127.0.0.1:8080)
    ↓ (ADB tunnel)
Host Backend (localhost:4000)
```

Your device thinks it's talking to localhost:8080. ADB transparently tunnels that to the host's port 4000 where the backend listens.

## 📱 Setup for Different Devices

### Default Device (172.16.0.26:5555)
```bash
./setup-network-bridge.sh
```

### Alternate Device (172.16.0.6:5555)
```bash
./setup-network-bridge.sh 172.16.0.6:5555
```

### List All Connected Devices
```bash
adb devices
```

## ⚡ After Device Reboot or Disconnect

The port forward clears automatically. Re-establish it:

```bash
./setup-network-bridge.sh
```

That's it! The script handles everything.

## ✅ Success Indicators

- ✅ No "Connection refused" errors
- ✅ Can login without timeout
- ✅ Can create and join lobbies
- ✅ Multiplayer events sync in real-time
- ✅ Chat messages appear instantly
- ✅ Games play normally

## ❌ Troubleshooting

### Connection Errors
```bash
# Re-run setup script
./setup-network-bridge.sh

# Or manually verify
adb -s 172.16.0.26:5555 reverse --list
# Should show: host-XX tcp:8080 tcp:4000
```

### Backend Not Responding
```bash
# Check backend health
curl http://localhost:4000/health

# Should return: {"status":"healthy",...}

# If not running, start it
cd backend && docker-compose up -d
```

### Device Offline
```bash
# Reconnect device and re-setup
./setup-network-bridge.sh
```

## 🎮 Testing Flow

1. **Setup** - Run `./setup-network-bridge.sh` ✅
2. **Launch** - Open app on device ✅
3. **Login** - Use credentials (no network errors expected)
4. **Lobby** - Create or join a lobby
5. **Multiplayer** - Play with another device/emulator
6. **Verify** - Real-time events work, scores sync

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| `NETWORK_BRIDGE_IMPLEMENTATION.md` | Technical details & troubleshooting |
| `NETWORK_BRIDGE_QUICKSTART.md` | Quick reference |
| `setup-network-bridge.sh` | Automated setup script |

## 🔄 Common Commands

```bash
# Verify port forward
adb -s 172.16.0.26:5555 reverse --list

# Check backend
curl http://localhost:4000/health

# List devices
adb devices

# Re-setup after disconnect
./setup-network-bridge.sh
```

## 📝 Technical Notes

- **Device Address:** 127.0.0.1 (localhost from device)
- **Device Port:** 8080 (tunneled to host)
- **Host Port:** 4000 (backend listens here)
- **Protocol:** ADB reverse port forward (TCP)
- **Latency:** Minimal (USB/network depending on connection)
- **Persistence:** Temporary (clears on device reboot/disconnect)

## 🎯 Next Steps

1. ✅ Run setup: `./setup-network-bridge.sh`
2. ✅ Launch app
3. ✅ Test login and lobby creation
4. ✅ Play multiplayer games
5. ✅ Report any issues

## 🚀 Ready!

Your Mind Wars multiplayer environment is now set up and ready for testing. Enjoy!

---

For detailed technical information, see: `NETWORK_BRIDGE_IMPLEMENTATION.md`
