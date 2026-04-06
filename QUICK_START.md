# Quick Start Deployment

**tl;dr** — Get the app running on devices in 10 minutes.

## Prerequisites (One-time Setup)

```bash
# Verify all tools are installed
./scripts/deploy.sh verify

# Should show:
# ✓ Flutter found
# ✓ ADB found  
# ✓ Android SDK found
# ✓ Docker backend running
```

## Option A: Debug Build (Recommended for Testing)

### 1. Start Emulator
```bash
./scripts/deploy.sh start-emulator
# Waits ~60 seconds for boot
```

### 2. Deploy to Emulator
```bash
./scripts/deploy.sh deploy emulator-5554 192.168.1.100
# Replace 192.168.1.100 with your Windows IP (ipconfig on Windows)
```

### 3. Deploy to Physical Device

```bash
# List all connected devices
./scripts/deploy.sh list-devices

# Deploy to your physical device
./scripts/deploy.sh deploy adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp 192.168.1.100
```

### 4. Test Multi-Device (2 Terminals)

**Terminal 1:**
```bash
./scripts/deploy.sh deploy emulator-5554 192.168.1.100
```

**Terminal 2:**
```bash
./scripts/deploy.sh deploy adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp 192.168.1.100
```

Both apps will connect to the same backend. Test creating a lobby on one device and joining on the other.

---

## Option B: Release APK Build

### 1. Build APK
```bash
flutter build apk --flavor=alpha --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100
```

Output: `build/app/outputs/apk/alpha/release/app-alpha-release.apk`

### 2. Install on Device
```bash
adb -s emulator-5554 install -r build/app/outputs/apk/alpha/release/app-alpha-release.apk
```

---

## Finding Your Local IP

On Windows (host machine):
```powershell
ipconfig
```

Look for "IPv4 Address" (e.g., `192.168.1.100`) — NOT `169.254.x.x`

---

## Hot Reload (Debug Only)

While your app is running via `flutter run`:
- Press `r` → hot reload (code changes only)
- Press `R` → full restart
- Press `q` → quit

---

## Troubleshooting

### Emulator won't boot
```bash
pkill -f emulator
sleep 5
./scripts/deploy.sh start-emulator
```

### Device not showing
```bash
./scripts/deploy.sh list-devices

# If still missing, on physical device:
# - Settings → Developer Options → USB Debugging (enable)
# - Reconnect USB cable
```

### "Undefined method" errors during build
```bash
flutter clean
rm -rf .dart_tool pubspec.lock build
flutter pub get
flutter run -d <device-id> ...
```

### Backend connection issues
```bash
# Check backend is running
docker ps | grep mindwars

# Check API is healthy
curl http://localhost:3000/health
```

---

## Complete Workflow Example

```bash
# 1. Verify setup
./scripts/deploy.sh verify

# 2. Start emulator
./scripts/deploy.sh start-emulator

# 3. Check devices
./scripts/deploy.sh list-devices

# 4. Deploy (replace IP with your actual IP)
./scripts/deploy.sh deploy emulator-5554 192.168.1.100

# 5. App launches!
# Press 'r' to hot reload during development
# Press 'q' to quit
```

---

## Key Commands Reference

| What | Command |
|------|---------|
| Verify setup | `./scripts/deploy.sh verify` |
| List devices | `./scripts/deploy.sh list-devices` |
| Start emulator | `./scripts/deploy.sh start-emulator` |
| Deploy to device | `./scripts/deploy.sh deploy <device-id> <ip>` |
| Hot reload | Press `r` during `flutter run` |
| Full restart | Press `R` during `flutter run` |
| Stop running | Press `q` during `flutter run` |
| Build APK | `flutter build apk --flavor=alpha --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=<ip>` |
| Install APK | `adb -s <device-id> install -r build/app/outputs/apk/alpha/release/app-alpha-release.apk` |

---

**See DEPLOYMENT_GUIDE.md for comprehensive instructions.**
