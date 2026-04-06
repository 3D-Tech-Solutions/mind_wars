# Mind Wars Deployment Guide

Complete instructions for deploying to emulators, physical devices, and building APKs.

---

## Prerequisites

### System Requirements
- **WSL2** with Linux (Ubuntu 20.04+)
- **Android SDK** installed at `~/Android/Sdk`
- **Flutter** installed and in PATH (`flutter --version`)
- **ADB** installed and in PATH (`adb --version`)
- **Docker** running with Mind Wars backend:
  ```bash
  docker ps | grep mindwars
  ```

### Verify Setup
```bash
# Check all required tools
flutter --version
adb --version
which adb
echo $ANDROID_SDK_ROOT

# Should output something like /home/xbyooki/Android/Sdk
# If empty, set it:
export ANDROID_SDK_ROOT=~/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH
```

---

## Part 1: Launch Android Emulator

### 1.1 List Available Emulators

```bash
~/Android/Sdk/cmdline-tools/bin/avdmanager list avd
```

Expected output:
```
Name: Pixel_5_API_33
Name: pixel_7_api_33
Name: Samsung_S24
```

### 1.2 Start Emulator (Background)

```bash
# Set environment variables
export ANDROID_SDK_ROOT=~/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Boot emulator in background
~/Android/Sdk/emulator/emulator -avd Pixel_5_API_33 -no-snapshot-load &

# Wait for boot to complete (takes 30-60 seconds)
sleep 30

# Verify emulator is online
adb devices -l
```

Expected output (after waiting):
```
List of devices attached
emulator-5554          device product:sdk_gphone64_x86_64 model:sdk_gphone64_x86_64 device:emu64x
```

### 1.3 Troubleshooting Emulator Boot

**Error: "FATAL | Broken AVD system path"**
```bash
# Fix the AVD config
sed -i 's|image.sysdir.1=Sdk/|image.sysdir.1=|' ~/.android/avd/Pixel_5_API_33.avd/config.ini

# Verify fix
grep "image.sysdir" ~/.android/avd/Pixel_5_API_33.avd/config.ini
# Should output: image.sysdir.1=system-images/android-33/google_apis_playstore/x86_64/
```

**Emulator stuck offline?**
```bash
# Kill and restart
pkill -f "emulator"
sleep 5
# Then restart following step 1.2
```

---

## Part 2: Connect Physical Android Devices

### 2.1 Connect via USB

1. **Enable Developer Mode on Android**
   - Settings → About Phone → Build Number (tap 7 times)
   - Settings → Developer Options → USB Debugging (Enable)
   - Settings → Developer Options → USB Configuration → File Transfer (MTP)

2. **Connect USB Cable** to Windows machine running WSL

3. **Verify Connection in WSL**
   ```bash
   adb devices -l
   ```
   
   Expected output:
   ```
   List of devices attached
   adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp  device  product:pa3qsqw model:SM_S938U
   ```

### 2.2 Multiple Devices

View all connected:
```bash
adb devices -l
```

Example with emulator + physical:
```
emulator-5554                    device  product:sdk_gphone64_x86_64
adb-R5CXC1XNPYJ-h58IGl._adb...   device  product:pa3qsqw model:SM_S938U
```

---

## Part 3: Deploy to Devices

### 3.1 Deploy to Emulator (Debug)

```bash
# Make sure you're in the project directory
cd /mnt/d/source/3D-Tech-Solutions/mind-wars

# Get your local IP (ask user or use: ipconfig on Windows)
# Example: 192.168.1.100

# Build and run on emulator with local flavor
flutter run \
  -d emulator-5554 \
  --dart-define=FLAVOR=local \
  --dart-define=LOCAL_HOST=192.168.1.100
```

This will:
- Compile the app
- Install on emulator
- Run the app
- Show live logs

### 3.2 Deploy to Physical Device (Debug)

```bash
# Find your device ID
adb devices -l
# Copy the device ID (e.g., adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp)

# Run on physical device
flutter run \
  -d adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp \
  --dart-define=FLAVOR=local \
  --dart-define=LOCAL_HOST=192.168.1.100
```

### 3.3 Deploy to Multiple Devices (Multi-Screen Testing)

**Terminal 1 (Emulator):**
```bash
flutter run -d emulator-5554 --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100
```

**Terminal 2 (Physical):**
```bash
flutter run -d adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100
```

Both apps will connect to the same backend and can test real-time socket communication.

### 3.4 Hot Reload During Development

Once running, in the terminal showing logs:
- Press `r` → Hot reload (code changes only)
- Press `R` → Full restart
- Press `q` → Quit

---

## Part 4: Build APK

### 4.1 Clean Build

```bash
cd /mnt/d/source/3D-Tech-Solutions/mind-wars

# Full clean (required before APK build)
flutter clean
rm -rf build .dart_tool pubspec.lock

# Restore dependencies
flutter pub get
```

### 4.2 Build APK (Release)

```bash
# For local testing flavor
flutter build apk \
  --flavor=alpha \
  --dart-define=FLAVOR=local \
  --dart-define=LOCAL_HOST=192.168.1.100

# OR for production flavor
flutter build apk \
  --flavor=production
```

Output location:
```
build/app/outputs/apk/alpha/release/app-alpha-release.apk
```

### 4.3 Install APK on Device

```bash
# On emulator
adb -s emulator-5554 install -r build/app/outputs/apk/alpha/release/app-alpha-release.apk

# On physical device
adb -s adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp install -r build/app/outputs/apk/alpha/release/app-alpha-release.apk
```

Flags:
- `-r` = Replace existing installation
- `-s` = Specific device

### 4.4 Known Build Issues

**Issue: "Undefined method" errors in compilation**

Root cause: Pre-existing incomplete implementations in `game_voting_screen.dart`, `war_config_screen.dart`, `chat_screen.dart`.

Workaround:
```bash
# Option 1: Use debug mode (faster, doesn't require full build)
flutter run -d emulator-5554 ...  # See Part 3

# Option 2: Complete cache clear
flutter clean
rm -rf ~/.flutter ~/.pub-cache build .dart_tool pubspec.lock
flutter pub cache repair
flutter pub get
flutter build apk ...  # Retry
```

---

## Part 5: Verify Backend Connectivity

### 5.1 Check Backend Status

```bash
# API Server
curl -s http://localhost:3000/health | jq '.'
# Should output: {"status":"healthy",...}

# Multiplayer Server
docker logs eskienterprises-mindwars-multiplayer | tail -20
# Should show: "listening on port 3001"

# Database
docker exec eskienterprises-postgres psql -U mindwars -d mindwars -c "SELECT COUNT(*) FROM lobbies;"
```

### 5.2 Get Local IP for --dart-define

On Windows:
```powershell
ipconfig
```

Look for "IPv4 Address" on your network interface (e.g., `192.168.1.100`)

**Not `169.254.x.x`** — that's WSL's internal bridge IP and won't work.

---

## Part 6: Complete Multi-Device Test Workflow

### Step-by-Step

1. **Ensure backend is running:**
   ```bash
   docker ps | grep mindwars
   # Both API and multiplayer servers should be "Up"
   ```

2. **Start emulator:**
   ```bash
   export ANDROID_SDK_ROOT=~/Android/Sdk
   export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH
   ~/Android/Sdk/emulator/emulator -avd Pixel_5_API_33 -no-snapshot-load &
   sleep 30
   ```

3. **Verify devices online:**
   ```bash
   adb devices -l
   ```

4. **Get your local IP** (Windows ipconfig)

5. **Deploy to both devices** (in separate terminals):
   
   Terminal 1:
   ```bash
   cd /mnt/d/source/3D-Tech-Solutions/mind-wars
   flutter run -d emulator-5554 --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100
   ```
   
   Terminal 2:
   ```bash
   cd /mnt/d/source/3D-Tech-Solutions/mind-wars
   flutter run -d adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100
   ```

6. **Test Multi-War Hub:**
   - Device A: Create lobby → See it in hub
   - Device B: Join using code → See both devices get real-time updates
   - Player count, stage labels, and status should update live

7. **Stop testing:**
   - Press `q` in each terminal
   - Kill emulator: `pkill -f emulator`

---

## Part 7: Debugging

### View Device Logs

```bash
# All devices
adb logcat

# Specific device
adb -s emulator-5554 logcat

# Filter by app
adb logcat | grep "mind_wars\|MultiplayerService"

# Clear logs
adb logcat -c
```

### Check Connected Devices

```bash
# List all
adb devices -l

# Get device name
adb -s emulator-5554 shell getprop ro.build.model

# Get Android version
adb -s emulator-5554 shell getprop ro.build.version.release
```

### Uninstall App

```bash
# From emulator
adb -s emulator-5554 uninstall com.mindwars.app.alpha

# From physical device
adb -s adb-R5CXC1XNPYJ-h58IGl._adb-tls-connect._tcp uninstall com.mindwars.app.alpha
```

---

## Quick Reference

### Common Commands

```bash
# Set env vars (do this once per terminal)
export ANDROID_SDK_ROOT=~/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Start emulator
~/Android/Sdk/emulator/emulator -avd Pixel_5_API_33 -no-snapshot-load &

# List devices
adb devices -l

# Deploy to emulator (debug)
flutter run -d emulator-5554 --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100

# Deploy to physical (debug)
flutter run -d <device-id> --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100

# Build APK
flutter build apk --flavor=alpha --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.1.100

# Install APK
adb -s <device-id> install -r build/app/outputs/apk/alpha/release/app-alpha-release.apk

# Kill emulator
pkill -f emulator

# View logs
adb logcat | grep "mind_wars"
```

---

## Troubleshooting Checklist

- [ ] Docker backend is running (`docker ps`)
- [ ] Emulator is online (`adb devices`)
- [ ] Your Windows machine has valid local IP (not `169.254.x.x`)
- [ ] USB cable connected to physical device (if testing physical)
- [ ] Developer Mode + USB Debugging enabled on physical device
- [ ] Correct `LOCAL_HOST` IP in `--dart-define` flags
- [ ] No other app using ports 3000, 3001, 4000, 4001
- [ ] Flutter version matches project requirements (`flutter --version`)

---

## Need Help?

Check logs for errors:
```bash
flutter run -d emulator-5554 --verbose 2>&1 | tee deployment.log
```

Review git history for recent changes:
```bash
git log --oneline -20
```
