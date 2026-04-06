#!/bin/bash

# Mind Wars Deployment Helper Script
# Usage: ./scripts/deploy.sh [COMMAND] [OPTIONS]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Setup Android SDK environment
export ANDROID_SDK_ROOT=~/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

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

# Deploy to device
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

${YELLOW}Usage:${NC}
  ./scripts/deploy.sh [COMMAND] [OPTIONS]

${YELLOW}Commands:${NC}
  verify              Verify environment
  list-devices        List connected devices
  start-emulator      Start Android emulator
  deploy <id>         Deploy to device
  help                Show this help message

${YELLOW}Examples:${NC}
  ./scripts/deploy.sh verify
  ./scripts/deploy.sh list-devices
  ./scripts/deploy.sh start-emulator
  ./scripts/deploy.sh deploy emulator-5554

See DEPLOYMENT_GUIDE.md for detailed instructions.
EOF
}

# Main
case "${1:-help}" in
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
