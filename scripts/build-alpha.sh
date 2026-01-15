#!/bin/bash
# Build script for creating alpha builds locally

set -e

echo "🏗️  Mind Wars - Alpha Build Script"
echo "=================================="
echo ""

# Get version from pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //' | tr -d ' ')
echo "📦 Version: $VERSION-alpha"
echo ""

# Function to build Android alpha
build_android() {
    echo "🤖 Building Android Alpha APK..."
    flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
    
    # Rename the APK with version
    OUTPUT_DIR="build/app/outputs/flutter-apk"
    mv "$OUTPUT_DIR/app-alpha-release.apk" "$OUTPUT_DIR/mind-wars-v${VERSION}-alpha.apk"
    
    echo "✅ Android Alpha APK built successfully!"
    echo "📍 Location: $OUTPUT_DIR/mind-wars-v${VERSION}-alpha.apk"
    echo ""
}

# Function to build iOS alpha
build_ios() {
    echo "🍎 Building iOS Alpha..."
    
    # Check if on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "❌ iOS builds require macOS"
        return 1
    fi
    
    flutter build ios --release --no-codesign --dart-define=FLAVOR=alpha
    
    echo "✅ iOS Alpha built successfully!"
    echo "📍 Location: build/ios/iphoneos/Runner.app"
    echo ""
    echo "ℹ️  Note: For device testing, you need to:"
    echo "   1. Open ios/Runner.xcworkspace in Xcode"
    echo "   2. Configure signing with your Apple Developer account"
    echo "   3. Archive and distribute via TestFlight or Ad-Hoc"
    echo ""
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    echo "Usage: ./build-alpha.sh [android|ios|both]"
    echo ""
    echo "Options:"
    echo "  android  - Build Android APK only"
    echo "  ios      - Build iOS app only (macOS required)"
    echo "  both     - Build both platforms"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get
echo ""

# Build based on argument
case "$1" in
    android)
        build_android
        ;;
    ios)
        build_ios
        ;;
    both)
        build_android
        build_ios
        ;;
    *)
        echo "❌ Invalid option: $1"
        echo "Usage: ./build-alpha.sh [android|ios|both]"
        exit 1
        ;;
esac

echo "🎉 Alpha build complete!"
echo ""
echo "📱 To install on your device:"
echo "   Android: Transfer the APK to your device and install"
echo "            (Enable 'Install from unknown sources' in settings)"
echo "   iOS: Use Xcode to sign and install, or distribute via TestFlight"
