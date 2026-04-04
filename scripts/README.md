# Mind Wars Deployment Scripts

## deploy.sh - Smart Build, Deploy & Clean

Automated script to rebuild the APK and deploy to all connected Android devices with automatic cleanup of previous versions.

### What It Does

The script automatically:
1. ✅ Detects all connected Android devices
2. ✅ **Uninstalls all previous app versions** (prevents version conflicts)
3. ✅ Cleans and rebuilds APK with specified flavor
4. ✅ Installs fresh APK on all connected devices
5. ✅ Launches the app on each device
6. ✅ Streams Flutter logs for real-time debugging

### Usage

```bash
# Default: local flavor, 172.16.0.4 host, debug build
./scripts/deploy.sh

# Custom flavor and host
./scripts/deploy.sh alpha 192.168.1.100 debug

# Production flavor (empty host)
./scripts/deploy.sh production "" release

# Local dev with custom network IP
./scripts/deploy.sh local 192.168.1.50 debug
```

### Parameters

1. **Flavor** (default: `local`)
   - `local` - Development with local Docker backend (192.168.x.x or LAN IP)
   - `alpha` - Alpha testing build (uses hosted alpha API)
   - `production` - Production build (uses production API)

2. **Local Host** (default: `172.16.0.4`)
   - IP address for local flavor (e.g., your dev machine's LAN IP)
   - Leave empty string `""` for non-local flavors
   - For Android emulator: uses 10.0.2.2 automatically if not specified

3. **Build Type** (default: `debug`)
   - `debug` - Debug build (faster compilation, logging enabled)
   - `release` - Release build (optimized, smaller APK)

### Examples

```bash
# Local testing on LAN (default)
./scripts/deploy.sh local 172.16.0.4 debug

# Local testing with custom IP
./scripts/deploy.sh local 192.168.1.100 debug

# Alpha testing build
./scripts/deploy.sh alpha "" debug

# Production release build
./scripts/deploy.sh production "" release
```

### Output

The script provides:
- 🟦 Colored progress indicators (blue for steps, green for success, red for errors)
- 📱 List of detected devices
- 🧹 Cleanup status of previous app versions
- 📦 APK path and file size
- 📲 Installation and launch status per device
- 📋 Live Flutter logs from all connected devices

### Requirements

- Android devices connected via USB or emulator running
- `flutter` CLI in PATH
- `adb` (Android Debug Bridge) in PATH
- Write permissions in project directory

### Troubleshooting

**No devices found?**
```bash
# Check device connection
adb devices
# If empty, restart adb
adb kill-server && adb devices
```

**Install fails on some devices?**
- Script will continue and report which devices failed
- Check device storage (uninstall other apps to free space)
- Try manual uninstall: `adb uninstall com.mindwars.app.local.debug`

**Logs not showing?**
- Device logs can be viewed separately: `adb logcat -s flutter`
- Press Ctrl+C to stop log streaming
