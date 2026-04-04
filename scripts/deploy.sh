#!/bin/bash

# Mind Wars APK Build and Deploy Script
# Automatically rebuilds the APK and deploys to all attached devices
# Features:
#   - Uninstalls all previous Mind Wars app versions
#   - Builds APK with specified flavor, host, and build type
#   - Installs on all connected devices
#   - Launches the app on each device
#   - Streams Flutter logs

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Flavor settings
FLAVOR="${1:-local}"
LOCAL_HOST="${2:-172.16.0.4}"
BUILD_TYPE="${3:-debug}"

# Map flavor to package name variants
PACKAGE_BASE="com.mindwars.app"
PACKAGE_VARIANTS=(
    "${PACKAGE_BASE}.${FLAVOR}.debug"  # e.g., com.mindwars.app.local.debug
    "${PACKAGE_BASE}.${FLAVOR}"         # e.g., com.mindwars.app.local
    "${PACKAGE_BASE}.debug"             # fallback
    "${PACKAGE_BASE}"                   # fallback
)

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Mind Wars APK Build & Deploy${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Flavor:${NC} $FLAVOR"
echo -e "${YELLOW}Local Host:${NC} $LOCAL_HOST"
echo -e "${YELLOW}Build Type:${NC} $BUILD_TYPE"
echo ""

# Step 1: Check for connected devices
echo -e "${BLUE}[1/5] Checking for connected devices...${NC}"
DEVICES=$(adb devices | grep -v "^List of attached devices" | grep "device$" | awk '{print $1}')
DEVICE_COUNT=$(echo "$DEVICES" | grep -c ".*" || true)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${RED}✗ No devices found!${NC}"
    echo "Please connect an Android device or start an emulator."
    exit 1
fi

echo -e "${GREEN}✓ Found $DEVICE_COUNT device(s):${NC}"
echo "$DEVICES" | while read device; do
    echo "  - $device"
done
echo ""

# Step 2: Uninstall previous versions
echo -e "${BLUE}[2/5] Uninstalling previous app versions...${NC}"
echo "$DEVICES" | while read device; do
    for pkg in "${PACKAGE_VARIANTS[@]}"; do
        if adb -s "$device" shell pm list packages | grep -q "^package:$pkg$"; then
            echo -e "${CYAN}  Uninstalling $pkg from $device...${NC}"
            adb -s "$device" uninstall "$pkg" > /dev/null 2>&1 || true
        fi
    done
done
echo -e "${GREEN}✓ Previous versions cleaned${NC}"
echo ""

# Step 3: Clean and build APK
echo -e "${BLUE}[3/5] Building APK...${NC}"
cd "$PROJECT_ROOT"
flutter clean > /dev/null 2>&1
flutter build apk \
    --flavor $FLAVOR \
    --dart-define=FLAVOR=$FLAVOR \
    --dart-define=LOCAL_HOST=$LOCAL_HOST \
    --$BUILD_TYPE 2>&1 | tail -10

# Determine correct APK path based on flutter build output structure
APK_PATH="$PROJECT_ROOT/build/app/outputs/apk/${FLAVOR}/${BUILD_TYPE}/app-${FLAVOR}-arm64-v8a-${BUILD_TYPE}.apk"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}✗ APK not found at expected path!${NC}"
    echo "  Expected: $APK_PATH"
    echo "  Available APKs:"
    find "$PROJECT_ROOT/build/app/outputs" -name "*.apk" -type f 2>/dev/null | head -10
    exit 1
fi

APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo -e "${GREEN}✓ APK built successfully${NC}"
echo -e "  Path: $APK_PATH"
echo -e "  Size: $APK_SIZE"
echo ""

# Step 4: Install on all devices
echo -e "${BLUE}[4/5] Installing APK on connected devices...${NC}"
FAILED_DEVICES=""

echo "$DEVICES" | while read device; do
    echo -e "${YELLOW}Installing on $device...${NC}"
    if adb -s "$device" install -r "$APK_PATH" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Installed on $device${NC}"
    else
        echo -e "${RED}✗ Failed to install on $device${NC}"
        FAILED_DEVICES="$FAILED_DEVICES $device"
    fi
done
echo ""

# Step 5: Launch app on all devices
echo -e "${BLUE}[5/5] Launching app on devices...${NC}"
PACKAGE_NAME="${PACKAGE_BASE}.${FLAVOR}.debug"

echo "$DEVICES" | while read device; do
    echo -e "${YELLOW}Launching on $device...${NC}"
    if adb -s "$device" shell am start -n "$PACKAGE_NAME/com.mindwars.app.MainActivity" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ App launched${NC}"
    else
        echo -e "${RED}✗ Failed to launch on $device${NC}"
    fi
done
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Deployment complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Watching device logs...${NC}"
echo "Press Ctrl+C to stop watching logs"
echo ""

# Optional: Show logs from all devices
adb logcat -s flutter 2>/dev/null || true
