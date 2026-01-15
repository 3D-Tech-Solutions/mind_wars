# Quick Build Reference

## Alpha Builds

### Build Locally

**Android APK:**
```bash
# Using the build script (recommended)
./build-alpha.sh android

# Using Flutter directly
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
```

**iOS:**
```bash
# Using the build script (recommended)
./build-alpha.sh ios

# Using Flutter directly
flutter build ios --release --no-codesign --dart-define=FLAVOR=alpha
```

### Build via GitHub Actions

1. Go to repository on GitHub
2. Click **Actions** tab
3. Select **"Build Alpha APK"** workflow
4. Click **"Run workflow"**
5. Download from artifacts when complete

### Output Locations

**Android:**
- Using script: `build/app/outputs/flutter-apk/mind-wars-v{version}-alpha.apk`
- Direct build: `build/app/outputs/flutter-apk/app-alpha-release.apk`

**iOS:**
- `build/ios/iphoneos/Runner.app`

## Production Builds

**Android:**
```bash
flutter build apk --flavor production --release
```

**iOS:**
```bash
flutter build ios --release
```

## Development Builds

**Run on device/emulator:**
```bash
# Default
flutter run

# With alpha flavor
flutter run --flavor alpha --dart-define=FLAVOR=alpha

# With production flavor
flutter run --flavor production --dart-define=FLAVOR=production
```

## Build Variants

| Build Type | Android Package ID | Version Suffix |
|-----------|-------------------|----------------|
| Production | `com.mindwars.app` | None |
| Alpha | `com.mindwars.app.alpha` | `-alpha` |
| Debug | `com.mindwars.app.debug` | None |

## Troubleshooting

**Clean build:**
```bash
flutter clean
flutter pub get
```

**Check Flutter setup:**
```bash
flutter doctor
flutter doctor -v
```

**Analyze code:**
```bash
flutter analyze
```

**Run tests:**
```bash
flutter test
```
