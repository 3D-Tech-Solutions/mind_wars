#!/bin/bash

# Mind Wars Deployment Helper Script
# Usage: ./scripts/deploy.sh [COMMAND] [OPTIONS]
# Supports: build, install, quick-install, start-emulator, deploy, verify, list-devices

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Setup Android SDK environment
export ANDROID_SDK_ROOT=~/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Configuration
FLAVOR="local"
BUILD_TYPE="debug"
API_HOST="172.16.0.4"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="$PROJECT_ROOT/.deploy"

# Helper functions
print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Verify environment
verify_environment() {
    print_header "Verifying Environment"

    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not installed"
        return 1
    fi
    print_success "Flutter found: $(flutter --version | head -1)"

    # Check ADB
    if ! command -v adb &> /dev/null; then
        print_error "ADB not installed"
        return 1
    fi
    print_success "ADB found"

    # Check Android SDK
    if [ ! -d "$ANDROID_SDK_ROOT" ]; then
        print_error "Android SDK not found at $ANDROID_SDK_ROOT"
        return 1
    fi
    print_success "Android SDK found at $ANDROID_SDK_ROOT"

    # Check Docker backend
    if docker ps 2>/dev/null | grep -q "mindwars"; then
        print_success "Docker backend running"
    else
        print_warning "Docker backend not running"
    fi

    return 0
}

# List devices
list_devices() {
    print_header "Connected Devices"
    adb devices -l
}

# Start emulator
start_emulator() {
    local avd_name=${1:-"Pixel_5_API_33"}

    print_header "Starting Emulator: $avd_name"

    if adb devices -l | grep -q "emulator-5554"; then
        print_warning "Emulator already running"
        return 0
    fi

    print_info "Launching emulator..."
    ~/Android/Sdk/emulator/emulator -avd "$avd_name" -no-snapshot-load > /tmp/emulator.log 2>&1 &
    local emulator_pid=$!
    echo $emulator_pid > /tmp/emulator.pid

    print_info "Waiting for emulator to boot (60 seconds)..."

    for i in {1..60}; do
        if adb devices -l | grep -q "emulator-5554.*device"; then
            print_success "Emulator ready!"
            sleep 5
            return 0
        fi
        echo -n "."
        sleep 1
    done

    print_error "Emulator failed to boot"
    return 1
}

# Build APK (no device needed)
build_apk() {
    local build_type=${1:-$BUILD_TYPE}

    if [ "$build_type" != "debug" ] && [ "$build_type" != "release" ]; then
        print_error "Invalid build type: $build_type (must be 'debug' or 'release')"
        return 1
    fi

    print_header "Building $FLAVOR APK ($build_type)"
    print_info "Using API host: $API_HOST"

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

    print_info "Build #${build_number} (v${app_version})"

    flutter build apk \
        --flavor=$FLAVOR \
        --dart-define=FLAVOR=$FLAVOR \
        --dart-define=LOCAL_HOST=$API_HOST \
        --dart-define=APP_VERSION=$app_version \
        --dart-define=BUILD_NUMBER=$build_number \
        $([ "$build_type" = "debug" ] && echo "--debug" || echo "--release")

    # Find and verify built APK
    local apk_path="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-$FLAVOR-$build_type.apk"

    if [ ! -f "$apk_path" ]; then
        print_error "APK build failed"
        return 1
    fi

    # Save build info
    local size=$(du -h "$apk_path" | cut -f1)

    mkdir -p "$DEPLOY_DIR"
    cat > "$DEPLOY_DIR/last_build.env" << EOF
FLAVOR=$FLAVOR
LOCAL_HOST=$API_HOST
BUILD_TYPE=$build_type
APK_PATH=$apk_path
APK_SIZE=$size
VERSION_NAME=$app_version
BUILD_NUMBER=$build_number
BUILT_AT=$(date -u +%Y-%m-%dT%H:%M:%S%z)
EOF

    echo "$apk_path" > "$DEPLOY_DIR/last_apk_path.txt"

    print_success "APK built: $apk_path (${size})"
    print_info "Run './scripts/deploy.sh install' to install to device"
}

# Install APK to connected device
install_apk() {
    local build_type=${1:-$BUILD_TYPE}

    # Find the APK
    local apk_path="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-$FLAVOR-$build_type.apk"

    if [ ! -f "$apk_path" ]; then
        print_error "APK not found: $apk_path"
        print_info "Run './scripts/deploy.sh build $build_type' first"
        return 1
    fi

    # Check if device is connected
    local devices
    devices=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

    if [ "$devices" -eq 0 ]; then
        print_error "No devices found. Connect a device via USB and enable USB debugging."
        return 1
    fi

    print_header "Installing APK to device"
    print_info "APK: $apk_path"

    adb install -r "$apk_path"

    print_success "APK installed successfully"
    print_info "Run './scripts/deploy.sh launch' to launch the app"
}

# Build and install in one step
quick_install() {
    local build_type=${1:-$BUILD_TYPE}
    print_info "Building and installing $build_type APK..."
    build_apk "$build_type" && install_apk "$build_type"
}

# Launch app on connected device
launch_app() {
    # Check if device is connected
    local devices
    devices=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)

    if [ "$devices" -eq 0 ]; then
        print_error "No devices found. Connect a device via USB and enable USB debugging."
        return 1
    fi

    print_header "Launching app on device"
    local package_name="com.mindwars.app.$FLAVOR"

    adb shell am start -n "$package_name/com.mindwars.app.MainActivity"
    print_success "App launched"
}

# Show build info
show_build_info() {
    if [ -f "$DEPLOY_DIR/last_build.env" ]; then
        print_header "Last Build Info"
        cat "$DEPLOY_DIR/last_build.env" | sed 's/^/  /'
    else
        print_warning "No build info found. Run './scripts/deploy.sh build' first."
    fi
}

# Deploy to device (legacy - uses flutter run)
deploy() {
    local device_id=$1
    local local_host=${2:-"192.168.1.100"}

    if [ -z "$device_id" ]; then
        print_error "Device ID required"
        return 1
    fi

    print_header "Deploying to: $device_id"
    print_info "Local Host: $local_host"

    flutter run -d "$device_id" --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=$local_host
}

# Show usage
show_usage() {
    cat << EOF
${BLUE}Mind Wars Deployment Helper${NC}

${YELLOW}BUILD & INSTALL COMMANDS:${NC}
  build [debug|release]      Build APK without device connected
  install [debug|release]    Install last built APK to connected device
  quick-install [type]       Build and install in one step
  launch                     Launch the installed app on device
  info                       Show last build information

${YELLOW}DEVICE MANAGEMENT:${NC}
  verify                     Verify Flutter, ADB, Android SDK
  list-devices              List connected devices
  start-emulator [avd]      Start Android emulator (default: Pixel_5_API_33)

${YELLOW}LEGACY:${NC}
  deploy <id> [host]        Deploy using 'flutter run' (hot reload)

${YELLOW}HELP:${NC}
  help                       Show this help message

${YELLOW}EXAMPLES:${NC}
  # Build without device
  ./scripts/deploy.sh build debug
  ./scripts/deploy.sh build release

  # Install to device
  ./scripts/deploy.sh install debug
  ./scripts/deploy.sh install release

  # Build and install (one command)
  ./scripts/deploy.sh quick-install debug
  ./scripts/deploy.sh quick-install release

  # Launch and manage devices
  ./scripts/deploy.sh launch
  ./scripts/deploy.sh list-devices
  ./scripts/deploy.sh start-emulator

  # Environment setup
  ./scripts/deploy.sh verify

${YELLOW}WORKFLOW:${NC}
  # Development: Build once, install to multiple devices
  ./scripts/deploy.sh build debug        # Build once
  # ... connect first device ...
  ./scripts/deploy.sh install debug      # Install to first device
  # ... connect second device ...
  ./scripts/deploy.sh install debug      # Install to second device (no rebuild)

  # Quick test: One command build + install
  ./scripts/deploy.sh quick-install debug

  # Launch the app
  ./scripts/deploy.sh launch

See .deploy/DEPLOY_GUIDE.md for detailed instructions.
EOF
}

# Main
case "${1:-help}" in
    build)
        build_apk "$2"
        ;;
    install)
        install_apk "$2"
        ;;
    quick-install)
        quick_install "$2"
        ;;
    launch)
        launch_app
        ;;
    info)
        show_build_info
        ;;
    verify)
        verify_environment
        ;;
    list-devices)
        list_devices
        ;;
    start-emulator)
        start_emulator "${2:-Pixel_5_API_33}"
        ;;
    deploy)
        deploy "$2" "$3"
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
