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
DEPLOY_STATE_DIR="$PROJECT_ROOT/.deploy"
mkdir -p "$DEPLOY_STATE_DIR"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

detect_local_host() {
    local ip
    ip=$(ip route get 8.8.8.8 2>/dev/null | awk '/src/ {print $7; exit}')
    if [ -z "$ip" ]; then
        ip=$(hostname -I | awk '{print $1}')
    fi
    echo "${ip:-172.16.0.4}"
}

read_pubspec_version() {
    local version_line
    version_line=$(grep -E '^version:' "$PROJECT_ROOT/pubspec.yaml" | head -1 | awk '{print $2}')
    if [ -z "$version_line" ]; then
        echo "1.0.0+1"
    else
        echo "$version_line"
    fi
}

next_build_number() {
    local counter_file="$DEPLOY_STATE_DIR/build_number_counter.txt"
    local pubspec_version="$1"
    local pubspec_build="${pubspec_version#*+}"
    local current_counter=0

    if [ -f "$counter_file" ]; then
        current_counter=$(cat "$counter_file" 2>/dev/null || echo "0")
    fi

    if ! [[ "$current_counter" =~ ^[0-9]+$ ]]; then
        current_counter=0
    fi

    if ! [[ "$pubspec_build" =~ ^[0-9]+$ ]]; then
        pubspec_build=1
    fi

    if [ "$current_counter" -lt "$pubspec_build" ]; then
        current_counter="$pubspec_build"
    else
        current_counter=$((current_counter + 1))
    fi

    printf '%s\n' "$current_counter" > "$counter_file"
    echo "$current_counter"
}


# Flavor settings
FLAVOR="${1:-local}"
LOCAL_HOST="${2:-}"
BUILD_TYPE="${3:-debug}"

if [ -z "$LOCAL_HOST" ] || [[ "$LOCAL_HOST" =~ ^(debug|release|profile)$ ]]; then
    BUILD_TYPE="${LOCAL_HOST:-$BUILD_TYPE}"
    LOCAL_HOST="$(detect_local_host)"
fi

if [ -z "$LOCAL_HOST" ]; then
    LOCAL_HOST="$(detect_local_host)"
fi

if [ -z "$BUILD_TYPE" ]; then
    BUILD_TYPE="debug"
fi

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

PUBSPEC_VERSION="$(read_pubspec_version)"
BASE_VERSION_NAME="${PUBSPEC_VERSION%%+*}"
BUILD_NUMBER="$(next_build_number "$PUBSPEC_VERSION")"
echo -e "${YELLOW}Version Name:${NC} $BASE_VERSION_NAME"
echo -e "${YELLOW}Build Number:${NC} $BUILD_NUMBER"
echo ""

# Step 1: Clean and build APK
echo -e "${BLUE}[1/6] Building APK...${NC}"
cd "$PROJECT_ROOT"
flutter clean > /dev/null 2>&1
flutter build apk \
    --flavor $FLAVOR \
    --dart-define=FLAVOR=$FLAVOR \
    --dart-define=LOCAL_HOST=$LOCAL_HOST \
    --build-name="$BASE_VERSION_NAME" \
    --build-number="$BUILD_NUMBER" \
    --$BUILD_TYPE 2>&1 | tail -10

# Determine correct APK path - flutter builds to flutter-apk directory
APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-${FLAVOR}-${BUILD_TYPE}.apk"

# Fallback to alternative path structure if not found
if [ ! -f "$APK_PATH" ]; then
    APK_PATH="$PROJECT_ROOT/build/app/outputs/apk/${FLAVOR}/${BUILD_TYPE}/app-${FLAVOR}-arm64-v8a-${BUILD_TYPE}.apk"
fi

if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}✗ APK not found!${NC}"
    echo "  Checked paths:"
    echo "    - $PROJECT_ROOT/build/app/outputs/flutter-apk/app-${FLAVOR}-${BUILD_TYPE}.apk"
    echo "    - $PROJECT_ROOT/build/app/outputs/apk/${FLAVOR}/${BUILD_TYPE}/app-${FLAVOR}-arm64-v8a-${BUILD_TYPE}.apk"
    echo "  Available APKs:"
    find "$PROJECT_ROOT/build/app/outputs" -name "*.apk" -type f 2>/dev/null | head -10
    exit 1
fi

APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo -e "${GREEN}✓ APK built successfully${NC}"
echo -e "  Path: $APK_PATH"
echo -e "  Size: $APK_SIZE"
echo -e "  Version: $BASE_VERSION_NAME+$BUILD_NUMBER"
printf '%s\n' "$APK_PATH" > "$DEPLOY_STATE_DIR/last_apk_path.txt"
printf '%s\n' "FLAVOR=$FLAVOR
LOCAL_HOST=$LOCAL_HOST
BUILD_TYPE=$BUILD_TYPE
APK_PATH=$APK_PATH
APK_SIZE=$APK_SIZE
VERSION_NAME=$BASE_VERSION_NAME
BUILD_NUMBER=$BUILD_NUMBER
BUILT_AT=$(date -Iseconds)" > "$DEPLOY_STATE_DIR/last_build.env"
echo ""

# Step 2: Check for connected devices
echo -e "${BLUE}[2/6] Checking for connected devices...${NC}"
mapfile -t DEVICES < <(adb devices | grep -v "^List of attached devices" | grep "device$" | awk '{print $1}')
DEVICE_COUNT=${#DEVICES[@]}

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No ADB devices detected. APK was built and recorded, but nothing was installed.${NC}"
    echo -e "${YELLOW}  Build record: $DEPLOY_STATE_DIR/last_build.env${NC}"
    exit 0
fi

echo -e "${GREEN}✓ Found $DEVICE_COUNT device(s):${NC}"
for device in "${DEVICES[@]}"; do
    echo "  - $device"
done
echo ""

if [ "$FLAVOR" = "local" ]; then
    echo -e "${BLUE}[2.5/6] LAN Connectivity Instructions for Local Build${NC}"
    echo -e "${YELLOW}For true LAN testing, ensure your Android devices are on the same WiFi network as this host.${NC}"
    echo -e "${YELLOW}Host IP: $LOCAL_HOST${NC}"
    echo -e "${YELLOW}Backend URLs:${NC}"
    echo -e "${YELLOW}  - API: http://$LOCAL_HOST:3000${NC}"
    echo -e "${YELLOW}  - WebSocket: http://$LOCAL_HOST:4001${NC}"
    echo -e "${YELLOW}The app will use these URLs when FLAVOR=local.${NC}"
    echo ""
fi

if [ "$DEVICE_COUNT" -lt 2 ]; then
    echo -e "${YELLOW}⚠ Only $DEVICE_COUNT device detected. Deployment will continue, but multiplayer testing still needs at least 2 devices.${NC}"
    echo ""
fi

# Step 3: Uninstall previous versions
echo -e "${BLUE}[3/6] Uninstalling previous app versions for Android user 0...${NC}"
for device in "${DEVICES[@]}"; do
    for pkg in "${PACKAGE_VARIANTS[@]}"; do
        if adb -s "$device" shell pm list packages --user 0 | grep -q "^package:$pkg$"; then
            echo -e "${CYAN}  Uninstalling $pkg from $device (user 0)...${NC}"
            adb -s "$device" shell pm uninstall --user 0 "$pkg" > /dev/null 2>&1 || true
        fi
    done
done
echo -e "${GREEN}✓ Previous versions cleaned${NC}"
echo ""

# Step 4: Install on all visible devices
echo -e "${BLUE}[4/6] Installing APK on visible devices...${NC}"
FAILED_DEVICES=()
SUCCESSFUL_DEVICES=()
INSTALL_REPORT="$DEPLOY_STATE_DIR/last_install_report.txt"
{
    echo "Built APK: $APK_PATH"
    echo "Built At: $(date -Iseconds)"
    echo "Flavor: $FLAVOR"
    echo "Build Type: $BUILD_TYPE"
    echo "Host: $LOCAL_HOST"
    echo "Version: $BASE_VERSION_NAME+$BUILD_NUMBER"
    echo ""
    echo "Install Results:"
} > "$INSTALL_REPORT"

for device in "${DEVICES[@]}"; do
    echo -e "${YELLOW}Installing on $device...${NC}"
    if adb -s "$device" install -r "$APK_PATH" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Installed on $device${NC}"
        SUCCESSFUL_DEVICES+=("$device")
        echo "SUCCESS $device" >> "$INSTALL_REPORT"
    else
        echo -e "${RED}✗ Failed to install on $device${NC}"
        FAILED_DEVICES+=("$device")
        echo "FAILED  $device" >> "$INSTALL_REPORT"
    fi
done
echo ""

# Step 5: Launch app on all devices
echo -e "${BLUE}[5/6] Launching app on devices...${NC}"
PACKAGE_NAME="${PACKAGE_BASE}.${FLAVOR}.debug"

for device in "${SUCCESSFUL_DEVICES[@]}"; do
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
echo -e "${YELLOW}Build record:${NC} $DEPLOY_STATE_DIR/last_build.env"
echo -e "${YELLOW}Install report:${NC} $INSTALL_REPORT"
echo ""

# Step 6: Open per-device log terminals
echo -e "${BLUE}[6/6] Opening per-device log terminals...${NC}"

if [ "${#SUCCESSFUL_DEVICES[@]}" -eq 0 ]; then
    echo -e "${RED}No successful installs. Skipping log streaming.${NC}"
    exit 1
fi

if command -v tmux &> /dev/null; then
    # Kill any existing mindwars-logs session
    tmux kill-session -t mindwars-logs 2>/dev/null || true

    # Create new session with first device's logs
    FIRST_DEVICE="${SUCCESSFUL_DEVICES[0]}"
    tmux new-session -d -s mindwars-logs -x 200 -y 50
    tmux send-keys -t mindwars-logs "adb -s $FIRST_DEVICE logcat -s flutter" Enter
    tmux set-option -t mindwars-logs -p pane-border-status top
    tmux set-option -t mindwars-logs pane-border-format "[#{pane_index}] Device: $FIRST_DEVICE"

    # Create additional panes for remaining devices
    for ((i = 1; i < ${#SUCCESSFUL_DEVICES[@]}; i++)); do
        DEVICE="${SUCCESSFUL_DEVICES[$i]}"
        tmux split-window -h -t mindwars-logs -p 50
        tmux send-keys -t mindwars-logs "adb -s $DEVICE logcat -s flutter" Enter
        tmux set-option -t mindwars-logs pane-border-format "[#{pane_index}] Device: $DEVICE"
        tmux select-layout -t mindwars-logs tiled
    done

    # Attach to session
    echo -e "${GREEN}✓ Log terminals opened in tmux session 'mindwars-logs'${NC}"
    echo -e "${YELLOW}Attached automatically to session...${NC}"
    echo ""
    echo -e "${CYAN}Controls:${NC}"
    echo -e "  Ctrl+B D      — detach from tmux"
    echo -e "  Ctrl+B Arrow  — switch panes"
    echo -e "  Ctrl+C (in a pane) — stop logcat for that device"
    echo ""
    tmux attach-session -t mindwars-logs
else
    # Fallback: launch logcat in background with labeled output
    echo -e "${YELLOW}⚠ tmux not found. Launching logs in background with device labels...${NC}"
    echo ""

    for device in "${SUCCESSFUL_DEVICES[@]}"; do
        adb -s "$device" logcat -s flutter 2>/dev/null | sed "s/^/[${device}] /" &
    done

    echo -e "${GREEN}✓ Device logs streaming in background${NC}"
    echo -e "${YELLOW}Each line is prefixed with [DEVICE_SERIAL] for identification${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop all streams${NC}"
    echo ""

    # Wait indefinitely for Ctrl+C
    wait
fi
