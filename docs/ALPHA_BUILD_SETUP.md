# Alpha Build Setup Summary

## ✅ What Has Been Set Up

This document summarizes the alpha build configuration for Mind Wars.

### 🔧 Configuration Files

#### Android Configuration
- **File**: `android/app/build.gradle`
- **Changes**: 
  - Added `alpha` product flavor
  - Application ID: `com.mindwars.app.alpha`
  - Version suffix: `-alpha`
  - Can install alongside production build

#### Build Utilities
- **File**: `lib/utils/build_config.dart`
- **Purpose**: Runtime detection of build variant
- **Features**:
  - Detect alpha vs production at runtime
  - Configure API endpoints per flavor
  - Feature flags based on build type
  - Debug logging helpers

### 🚀 Build Tools

#### Local Build Script
- **File**: `build-alpha.sh`
- **Usage**: `./build-alpha.sh [android|ios|both]`
- **Features**:
  - Automated alpha builds
  - Version-based APK naming
  - Cross-platform support
  - Installation instructions

#### GitHub Actions Workflows
1. **Android Alpha Build** (`.github/workflows/build-alpha.yml`)
   - Triggers: Manual or push to main/develop
   - Outputs: APK artifact
   - Retention: 30 days

2. **iOS Alpha Build** (`.github/workflows/build-alpha-ios.yml`)
   - Triggers: Manual only
   - Outputs: iOS archive
   - Note: Requires signing for device installation

### 📚 Documentation

1. **README.md** - Updated with alpha build section
2. **ALPHA_TESTING.md** - Comprehensive testing guide
3. **BUILD_GUIDE.md** - Quick build reference
4. **`.github/workflows/README.md`** - Workflow documentation

## 🎯 How to Use

### For Developers

**Build locally:**
```bash
./build-alpha.sh android
```

**Run on device:**
```bash
flutter run --flavor alpha --dart-define=FLAVOR=alpha
```

### For Testers

**Download from GitHub:**
1. Go to repository Actions tab
2. Find latest "Build Alpha APK" run
3. Download `mind-wars-alpha-apk` artifact
4. Extract and install APK on device

**Install APK:**
1. Enable "Install from unknown sources"
2. Transfer APK to device
3. Tap to install
4. Launch "Mind Wars Alpha"

### For CI/CD

**Trigger build:**
1. Go to Actions → Build Alpha APK
2. Click "Run workflow"
3. Select branch
4. Wait for completion
5. Download from artifacts

## 📦 Build Outputs

### Android
- **Filename**: `mind-wars-v{version}-alpha.apk`
- **Location**: `build/app/outputs/flutter-apk/`
- **Size**: ~20-30 MB (varies)
- **Target**: Android 8.0+ (API 26+)

### iOS
- **Filename**: `Runner.xcarchive`
- **Location**: `ios/build/`
- **Target**: iOS 14.0+
- **Note**: Requires signing for devices

## 🔑 Key Features

### ✨ Benefits
- ✅ Can install alongside production
- ✅ Clear version identification
- ✅ Automated build process
- ✅ 30-day artifact retention
- ✅ Runtime flavor detection
- ✅ Feature flags support

### 🎨 Distinguishing Features
- Different app ID/bundle ID
- "-alpha" version suffix
- Separate app icon possible (future)
- Debug logging enabled
- Alpha API endpoints configured

## 📋 Testing Checklist

When testing alpha builds:
- [ ] Install succeeds on device
- [ ] App launches without crashes
- [ ] Version shows "-alpha" suffix
- [ ] Can install alongside production
- [ ] Core features work correctly
- [ ] Multiplayer connects properly
- [ ] Offline mode functions
- [ ] No signing/permission issues

## 🔄 Build Variants Summary

| Variant | Package ID | Version | Use Case |
|---------|-----------|---------|----------|
| Production | `com.mindwars.app` | `1.0.0` | Release to stores |
| Alpha | `com.mindwars.app.alpha` | `1.0.0-alpha` | Internal testing |
| Debug | `com.mindwars.app.debug` | `1.0.0` | Development |

## 🚦 Next Steps

To start using alpha builds:

1. **For immediate testing:**
   ```bash
   ./build-alpha.sh android
   ```

2. **For automated builds:**
   - Push to `main` or `develop` branch
   - Or manually trigger workflow

3. **For distribution:**
   - Download APK from GitHub Actions
   - Share with testers
   - Install on devices

4. **For iOS testing:**
   - Set up Apple Developer account
   - Configure code signing
   - Use TestFlight for distribution

## 📞 Support

For issues or questions:
- Check `ALPHA_TESTING.md` for detailed guide
- Check `BUILD_GUIDE.md` for quick reference
- Check `.github/workflows/README.md` for CI/CD help
- Open GitHub issue for bugs
- Contact team for other questions

---

**Status**: ✅ **Ready for Alpha Testing**

All components are configured and ready to create alpha builds for testing on personal devices!
