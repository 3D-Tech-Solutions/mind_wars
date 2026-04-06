# Deploy Guide

Quick reference for building and installing Mind Wars APK.

## Quick Start

### Build APK (no device needed)
```bash
./deploy build
# or for release:
./deploy build release
```

### Install to Connected Device
```bash
./deploy install
# or reinstall release APK:
./deploy install release
```

### Build + Install in One Step
```bash
./deploy install-debug    # Build and install debug APK
./deploy install-release  # Build and install release APK
```

### Launch App on Device
```bash
./deploy launch
```

### View Last Build Info
```bash
./deploy info
```

## Workflow Examples

### Development: Iterate Without Rebuilding
Build once, then install to multiple devices:
```bash
./deploy build debug              # Build APK
# Connect first device
./deploy install debug            # Install to first device
# Connect second device
./deploy install debug            # Install to second device (no rebuild)
```

### Quick Test: Build and Install Immediately
```bash
./deploy install-debug            # One command, builds and installs
```

### Release Workflow
```bash
./deploy build release            # Build release APK
# Test on device
./deploy install-release          # Install to device
```

## What It Does

- **build** - Compiles APK without needing a device connected. Uses cached builds for faster rebuilds.
- **install** - Takes previously built APK and installs it to connected device via adb.
- **launch** - Starts the installed app on the device.
- **info** - Shows version, size, and build timestamp of last build.

## Requirements

- For `build`: Flutter SDK installed
- For `install` and `launch`: 
  - Device connected via USB
  - USB debugging enabled on device
  - `adb` (Android Debug Bridge) in PATH

## Device Setup

To enable USB debugging:
1. Open Settings → About Phone
2. Tap Build Number 7 times (until "Developer mode enabled" appears)
3. Go to Settings → Developer Options
4. Enable "USB Debugging"
5. Connect via USB and tap "Allow" on the device when prompted

## File Locations

- **APK**: `build/app/outputs/flutter-apk/app-local-{debug|release}.apk`
- **Build Info**: `.deploy/last_build.env`
- **Last APK Path**: `.deploy/last_apk_path.txt`

## Troubleshooting

### "No devices found"
- Connect device via USB
- Enable USB Debugging on device (Settings → Developer Options)
- Run `adb devices` to verify connection
- Trust the computer when prompted on device

### "APK not found"
- Run `./deploy build` first to create the APK
- Or check `.deploy/last_build.env` for path to previously built APK

### Build fails
- Ensure Flutter is installed: `flutter --version`
- Run `flutter clean` and try again
- Check that you're in the project root directory

### Install fails
- Ensure `adb` is in PATH: `adb version`
- Try `adb kill-server` then `adb devices` to reconnect
- Check device storage has space (min 500MB)
