#!/bin/bash

# Mind Wars Deploy Script
# Supports building APK without device, then installing to device when ready
#
# Usage:
#   ./deploy.sh build [release|debug]    - Build APK (no device needed)
#   ./deploy.sh install [release|debug]  - Install last built APK to connected device
#   ./deploy.sh install-release          - Shorthand: build and install release
#   ./deploy.sh install-debug            - Shorthand: build and install debug
#   ./deploy.sh launch                   - Launch app on connected device

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEPLOY_DIR="$SCRIPT_DIR"

# Default values
FLAVOR="local"
BUILD_TYPE="debug"
API_HOST="172.16.0.4"  # Default for dev machine
WS_HOST="172.16.0.4"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

save_build_info() {
    local apk_path=$1
    local build_type=$2
    local version=$3
    local build_number=$4
    local size=$(du -h "$apk_path" | cut -f1)

    cat > "$DEPLOY_DIR/last_build.env" << EOF
FLAVOR=$FLAVOR
LOCAL_HOST=$API_HOST
BUILD_TYPE=$build_type
APK_PATH=$apk_path
APK_SIZE=$size
VERSION_NAME=$version
BUILD_NUMBER=$build_number
BUILT_AT=$(date -u +%Y-%m-%dT%H:%M:%S%z)
EOF

    echo "$apk_path" > "$DEPLOY_DIR/last_apk_path.txt"
    log_info "Build info saved to $DEPLOY_DIR/last_build.env"
}

find_apk() {
    local build_type=$1
    local apk_pattern="app-$FLAVOR-$build_type.apk"
    local apk_path="$PROJECT_ROOT/build/app/outputs/flutter-apk/$apk_pattern"

    if [ ! -f "$apk_path" ]; then
        log_error "APK not found: $apk_path"
        log_info "You may need to build first: $0 build $build_type"
        return 1
    fi

    echo "$apk_path"
}

cmd_build() {
    local build_type=${1:-$BUILD_TYPE}

    if [ "$build_type" != "debug" ] && [ "$build_type" != "release" ]; then
        log_error "Invalid build type: $build_type (must be 'debug' or 'release')"
        return 1
    fi

    BUILD_TYPE=$build_type
    local build_mode="$([ "$build_type" = "debug" ] && echo "debug" || echo "release")"

    log_info "Building $FLAVOR flavor APK ($build_type)..."
    log_info "Using API host: $API_HOST"

    cd "$PROJECT_ROOT"

    # Auto-increment build number
    local counter_file="$DEPLOY_DIR/build_number_counter.txt"
    if [ ! -f "$counter_file" ]; then echo "1" > "$counter_file"; fi
    local build_number
    build_number=$(cat "$counter_file" | tr -d '[:space:]')
    build_number=$((build_number + 1))
    echo "$build_number" > "$counter_file"

    local app_version
    app_version=$(grep "^version:" "$PROJECT_ROOT/pubspec.yaml" | sed 's/version: //' | cut -d'+' -f1)

    # Keep pubspec in sync with counter
    sed -i "s/^version: .*/version: ${app_version}+${build_number}/" "$PROJECT_ROOT/pubspec.yaml"

    log_info "Build #${build_number} (v${app_version})"

    # Build the APK
    flutter build apk \
        --flavor=$FLAVOR \
        --dart-define=FLAVOR=$FLAVOR \
        --dart-define=LOCAL_HOST=$API_HOST \
        --dart-define=APP_VERSION=$app_version \
        --dart-define=BUILD_NUMBER=$build_number \
        --$build_mode

    # Find the built APK
    local apk_path
    apk_path=$(find_apk "$build_type") || return 1

    # Save build info
    save_build_info "$apk_path" "$build_type" "$app_version" "$build_number"

    log_success "APK built: $apk_path"
    log_info "Run '$0 install' to install to connected device"
}

cmd_install() {
    local build_type=${1:-$BUILD_TYPE}

    if [ "$build_type" != "debug" ] && [ "$build_type" != "release" ]; then
        log_error "Invalid build type: $build_type (must be 'debug' or 'release')"
        return 1
    fi

    # Find the APK
    local apk_path
    apk_path=$(find_apk "$build_type") || return 1

    # Check if device is connected
    local devices
    devices=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

    if [ "$devices" -eq 0 ]; then
        log_error "No devices found. Connect a device via USB and enable USB debugging."
        return 1
    fi

    log_info "Installing APK to device: $apk_path"
    adb install -r "$apk_path"

    log_success "APK installed successfully"
    log_info "Run '$0 launch' to launch the app"
}

cmd_launch() {
    # Check if device is connected
    local devices
    devices=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

    if [ "$devices" -eq 0 ]; then
        log_error "No devices found. Connect a device via USB and enable USB debugging."
        return 1
    fi

    log_info "Launching Mind Wars on connected device..."

    # Query the installed package name (varies by flavor)
    local package_name="com.mindwars.app.$FLAVOR"

    adb shell am start -n "$package_name/com.mindwars.app.MainActivity"

    log_success "App launched"
}

cmd_info() {
    if [ -f "$DEPLOY_DIR/last_build.env" ]; then
        log_info "Last build info:"
        cat "$DEPLOY_DIR/last_build.env" | sed 's/^/  /'
    else
        log_warning "No build info found. Run '$0 build' first."
    fi
}

show_help() {
    cat << EOF
${BLUE}Mind Wars Deploy Script${NC}

${GREEN}USAGE:${NC}
  $0 <command> [options]

${GREEN}COMMANDS:${NC}
  build [release|debug]      Build APK without needing a device connected
                             (default: debug)

  install [release|debug]    Install last built APK to connected device
                             (default: debug)

  install-release            Build release APK and install to device
  install-debug              Build debug APK and install to device (shorthand)

  launch                     Launch the installed app on connected device

  info                       Show last build information

  help                       Show this help message

${GREEN}EXAMPLES:${NC}
  # Build debug APK (no device needed)
  $0 build debug

  # Build release APK
  $0 build release

  # Install previously built debug APK to connected device
  $0 install debug

  # Build and install in one command (debug)
  $0 install-debug

  # Build and install in one command (release)
  $0 install-release

  # Launch the app
  $0 launch

${GREEN}WORKFLOW:${NC}
  # Development workflow (multiple installs from one build)
  $0 build debug          # Build once
  # ... connect first device ...
  $0 install debug        # Install to first device
  # ... connect second device ...
  $0 install debug        # Install to second device

  # Or build and install immediately
  $0 install-debug        # Build and install in one step

${YELLOW}NOTE:${NC}
  - Device must be connected via USB for install and launch commands
  - USB debugging must be enabled on the device
  - APK builds are cached, so subsequent builds are faster
  - Build info is saved in .deploy/last_build.env

EOF
}

# Main script
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    build)
        cmd_build "$2"
        ;;
    install)
        cmd_install "$2"
        ;;
    install-debug)
        log_info "Building and installing debug APK..."
        cmd_build "debug" && cmd_install "debug"
        ;;
    install-release)
        log_info "Building and installing release APK..."
        cmd_build "release" && cmd_install "release"
        ;;
    launch)
        cmd_launch
        ;;
    info)
        cmd_info
        ;;
    help)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
