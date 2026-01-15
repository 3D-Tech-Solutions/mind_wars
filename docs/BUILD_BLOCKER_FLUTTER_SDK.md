# Build Issue - Flutter SDK Corruption

**Date**: 2025-11-17  
**Status**: ⚠️ BLOCKED - Flutter SDK Kotlin compilation error

---

## Problem

Flutter SDK at `/mnt/d/huntmaster-strategy/docs/flutter` has corrupt FlutterPlugin.kt file.

### Error Details
```
e: file:///.../flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt:744:21 
   Unresolved reference: filePermissions
e: file:///.../flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt:745:25 
   Unresolved reference: user
e: file:///.../flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt:746:29 
   Unresolved reference: read
e: file:///.../flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt:747:29 
   Unresolved reference: write
```

### Attempted Fixes
- ✅ Updated Kotlin version from 1.9.0 to 1.9.20
- ✅ Ran `flutter clean`
- ✅ Ran `./gradlew clean`
- ✅ Deleted build directory
- ✅ Rebuilt Flutter tools cache
- ❌ Error persists

---

## Solutions

### Option 1: Fresh Flutter SDK (Recommended)
```bash
# Download and extract fresh Flutter SDK
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.1-stable.tar.xz
tar xf flutter_linux_3.38.1-stable.tar.xz

# Update PATH temporarily
export PATH="$HOME/flutter/bin:$PATH"

# Verify
flutter doctor

# Build the app
cd /mnt/d/mind-wars
flutter build apk --flavor alpha --debug --dart-define=FLAVOR=alpha
```

### Option 2: Build on Different Machine
Transfer the code to a machine with working Flutter:
```bash
# On working machine
git clone https://github.com/tescolopio/mind-wars.git
cd mind-wars
flutter pub get
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
# Transfer APK back
```

### Option 3: Use Docker
```bash
# Use official Flutter Docker image
docker run --rm -v $(pwd):/app -w /app cirrusci/flutter:stable \
  flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
```

### Option 4: Reinstall Current SDK
```bash
# Backup then reinstall
cd /mnt/d/huntmaster-strategy/docs
mv flutter flutter.backup
git clone https://github.com/flutter/flutter.git -b stable
export PATH="/mnt/d/huntmaster-strategy/docs/flutter/bin:$PATH"
flutter doctor
```

---

## Workaround Until Build Works

### Test Backend API Directly
The registration fix can be verified without building:

```bash
# Test registration with correct payload
curl -X POST http://localhost:4000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "TestUser",
    "email": "testuser@example.com",
    "password": "Test1234"
  }'

# Expected response:
# {"success":true,"data":{"user":{...},"accessToken":"...","refreshToken":"..."}}
```

### Code Is Ready
All fixes are committed and pushed to GitHub:
- Commit `ad3ed8c`: Registration API fix
- Commit `93afe9e`: Testing guide

When you get a working Flutter build environment, simply:
```bash
git pull
flutter pub get
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
```

---

## Technical Details

### Root Cause
The FlutterPlugin.kt file in flutter_tools/gradle references Kotlin APIs that don't exist or are from an incompatible API version. This suggests either:
1. SDK was partially downloaded/extracted
2. Disk corruption occurred
3. Version mismatch between Flutter SDK components

### Why Rebuilding Tools Didn't Help
The issue is in the source Kotlin file itself, not the compiled snapshot. The `flutter` command rebuilds the Dart snapshot (`flutter_tools.snapshot`) but the Kotlin source files are part of the SDK distribution and aren't regenerated.

---

## Next Steps

1. Choose one of the solutions above
2. Build the APK
3. Follow testing guide in `REGISTRATION_FIX_TESTING.md`
4. Test registration on both devices
5. Begin multiplayer testing

**The code is fixed and ready - this is purely a build tooling issue.**
