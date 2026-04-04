# Mind Wars Deployment Scripts

## deploy.sh - Quick Build & Deploy

Automated script to rebuild the APK and deploy to all connected Android devices.

### Usage

```bash
# Default: local flavor, 172.16.0.4 host, debug build
./scripts/deploy.sh

# Custom flavor and host
./scripts/deploy.sh alpha 192.168.1.100 debug

# Production flavor
./scripts/deploy.sh production "" release
```

### Parameters

1. **Flavor** (default: `local`)
   - `local` - Development with local backend
   - `alpha` - Alpha testing build
   - `production` - Production build

2. **Local Host** (default: `172.16.0.4`)
   - IP address of your dev machine (for local flavor)
   - Leave empty for non-local flavors

3. **Build Type** (default: `debug`)
   - `debug` - Debug build (faster)
   - `release` - Release build (optimized)

### What It Does

1. ✅ Checks for connected devices
2. ✅ Cleans previous build artifacts
3. ✅ Builds APK with specified flavor
4. ✅ Installs on all connected devices
5. ✅ Launches the app on each device
6. ✅ Streams Flutter logs from devices

### Examples

```bash
# Build for local testing on all devices
./scripts/deploy.sh local 172.16.0.4 debug

# Build alpha version
./scripts/deploy.sh alpha "" debug

# Build release for production
./scripts/deploy.sh production "" release
```

### Requirements

- Android devices connected via USB or emulator running
- `flutter` in PATH
- `adb` in PATH
- Write permissions in project directory

### Output

The script shows:
- Color-coded progress indicators
- Connected devices and install status
- APK path and file size
- Live Flutter logs from devices
- Real-time installation feedback
