# Alpha Testing Guide

This guide explains how to build, install, and test alpha versions of Mind Wars.

**📖 NEW**: See **[ALPHA_USER_STORIES.md](ALPHA_USER_STORIES.md)** for comprehensive user stories, testing workflows, Epics, Features, and Tasks specifically designed for Alpha testing without backend servers.

## What is an Alpha Build?

An alpha build is a pre-release version of the app that:
- Can be installed on your personal device for testing
- Has a different app ID so it won't conflict with production versions
- Is marked with an `-alpha` suffix in the version number
- Allows you to provide feedback on new features before they're released

## Quick Start

### For Android Users

1. **Download the APK:**
   - **Method 1 (Recommended for testers):** Download from GitHub Releases page
     - Go to the repository's Releases page
     - Find the latest alpha pre-release
     - Download the `mind-wars-v{version}-alpha.apk` file
   - **Method 2:** Download from GitHub Actions artifacts
     - Go to Actions tab, click on a completed workflow run
     - Download from the "Artifacts" section
   - **Method 3:** Build locally using `./build-alpha.sh android`

2. **Install on your device:**
   - Transfer the APK to your Android device
   - Enable "Install from unknown sources" in Settings → Security
   - Tap the APK file to install
   - Accept the installation prompt

3. **Start testing:**
   - Launch "Mind Wars Alpha" from your app drawer
   - Test features and note any issues
   - Provide feedback via GitHub issues or team channels

### For iOS Users

1. **Prerequisites:**
   - macOS computer with Xcode installed
   - Apple Developer account (for device testing)
   - iOS device connected via USB

2. **Build and install:**
   ```bash
   ./build-alpha.sh ios
   ```
   
3. **Sign and deploy:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select your development team in Signing & Capabilities
   - Select your connected device as the target
   - Click Run (▶️) to install on your device

4. **Alternative - TestFlight distribution:**
   - Archive the app in Xcode (Product → Archive)
   - Upload to App Store Connect
   - Add testers in TestFlight
   - Testers receive invitation to install via TestFlight app

## Building Alpha Versions

### Using the Build Script

The easiest way to build alpha versions locally:

```bash
# Build Android APK
./build-alpha.sh android

# Build iOS app (macOS only)
./build-alpha.sh ios

# Build both
./build-alpha.sh both
```

### Using Flutter Commands Directly

**Android:**
```bash
flutter build apk --flavor alpha --release
```

**iOS:**
```bash
flutter build ios --release --no-codesign
```

### Using GitHub Actions

**For quick distribution to testers (creates a Release):**

1. Navigate to the repository on GitHub
2. Click the **Actions** tab
3. Select **"Build Alpha APK"** workflow
4. Click **"Run workflow"** button
5. Set "Create a pre-release for testers" to **true**
6. Click **"Run workflow"** to start
7. Wait for the build to complete (~5-10 minutes)
8. Go to the **Releases** page to find the new alpha pre-release
9. Share the release URL with alpha testers

**For internal testing (artifacts only):**

1. Navigate to the repository on GitHub
2. Click the **Actions** tab
3. Select **"Build Alpha APK"** workflow
4. Click **"Run workflow"** button
5. Keep "Create a pre-release for testers" as **false** (default)
6. Wait for the build to complete (~5-10 minutes)
7. Download the APK from the workflow artifacts section

**Automatic builds:**
- Alpha APKs are automatically built (as artifacts) when code is pushed to `main` or `develop` branches
- These automatic builds do NOT create releases - use manual trigger for that

## Alpha vs Production Builds

| Feature | Production | Alpha |
|---------|-----------|-------|
| Package ID (Android) | `com.mindwars.app` | `com.mindwars.app.alpha` |
| Bundle ID (iOS) | `com.mindwars.app` | `com.mindwars.app.alpha` |
| Version | `1.0.0` | `1.0.0-alpha` |
| Install alongside prod | ❌ No | ✅ Yes |
| App name | Mind Wars | Mind Wars Alpha |

## Testing Checklist

When testing an alpha build, please check:

- [ ] App launches successfully
- [ ] User registration and login work
- [ ] Lobby creation and joining function
- [ ] Game selection and voting work
- [ ] Games load and are playable
- [ ] Multiplayer synchronization works
- [ ] Offline mode functions properly
- [ ] Chat and emoji reactions work
- [ ] Leaderboards display correctly
- [ ] Profile and progression update properly
- [ ] No crashes or errors occur during normal use

## Reporting Issues

When you find a bug or issue:

1. **Check if it's already reported** in GitHub Issues
2. **Create a new issue** with:
   - Clear title describing the problem
   - Steps to reproduce the issue
   - Expected vs actual behavior
   - Screenshots or videos if applicable
   - Device and OS version
   - Alpha build version number

3. **Use the label** `alpha-testing` for issues found during alpha testing

## Version Information

To check which alpha version you're running:
- Android: Settings → Apps → Mind Wars Alpha → Version
- iOS: Settings → General → iPhone Storage → Mind Wars Alpha → Version

The version will be in the format: `1.0.0-alpha+1`

## Automated Builds

Alpha builds are automatically generated when:
- Code is pushed to `main` or `develop` branches (artifacts only, retained 30 days)
- A workflow is manually triggered via GitHub Actions
  - With "Create pre-release" option: Creates a public pre-release on the Releases page
  - Without "Create pre-release" option: Only uploads as workflow artifact

**For Alpha Testers:**
- Check the Releases page for the latest alpha pre-release
- Each pre-release includes:
  - Direct APK download
  - Build notes and version information
  - Installation instructions
  - Link to full testing documentation

Artifacts are retained for 30 days and can be downloaded from the Actions page.

## Troubleshooting

### Android: "App not installed"
- Ensure "Install from unknown sources" is enabled
- Try uninstalling any existing version first
- Check that you have enough storage space

### iOS: "Untrusted Developer"
- Go to Settings → General → Device Management
- Trust the developer certificate
- Try launching the app again

### Build failures
- Ensure Flutter is properly installed: `flutter doctor`
- Clear build cache: `flutter clean`
- Update dependencies: `flutter pub get`
- Check for specific error messages in build output

## Distribution via TestFlight (iOS)

For broader iOS alpha testing:

1. **Set up App Store Connect:**
   - Create app record in App Store Connect
   - Configure TestFlight settings

2. **Archive and upload:**
   ```bash
   # Build release version
   flutter build ios --release
   
   # Open Xcode
   open ios/Runner.xcworkspace
   
   # Archive: Product → Archive
   # Distribute: Distribute App → TestFlight
   ```

3. **Add testers:**
   - In App Store Connect → TestFlight
   - Add internal testers (up to 100)
   - Add external testers (up to 10,000)

4. **Testers install:**
   - Receive email invitation
   - Install TestFlight app
   - Install Mind Wars alpha via TestFlight

## Feedback Channels

- **GitHub Issues:** For bugs and feature requests
- **Team Chat:** For quick questions and discussions
- **Email:** For detailed feedback and suggestions

Thank you for alpha testing Mind Wars! Your feedback helps us build a better game. 🎮🧠
