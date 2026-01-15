#!/bin/bash

# [2025-11-17 Integration] ADB Network Bridge Setup Script
# This script configures the ADB reverse port forward for Mind Wars multiplayer testing
# Purpose: Tunnel device port 8080 to host port 4000 to work around network isolation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default device (can be overridden with first argument)
DEVICE="${1:-172.16.0.26:5555}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Mind Wars - ADB Network Bridge Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Check if device is connected
echo -e "${YELLOW}[1/4]${NC} Checking for connected devices..."
DEVICES=$(adb devices | grep -v "^List" | grep -v "^$" | awk '{print $1}')

if [ -z "$DEVICES" ]; then
    echo -e "${RED}✗ No devices found!${NC}"
    echo "  Please connect a device via USB or ensure network ADB is active"
    exit 1
fi

echo -e "${GREEN}✓ Found devices:${NC}"
echo "$DEVICES" | sed 's/^/  /'

# Check if specified device is in list
if ! echo "$DEVICES" | grep -q "^$DEVICE"; then
    echo -e "${YELLOW}⚠ Device $DEVICE not found in list${NC}"
    echo -e "${YELLOW}Available devices:${NC}"
    echo "$DEVICES" | sed 's/^/  /'
    read -p "Enter device ID (or press Enter for $DEVICE): " USER_DEVICE
    if [ -n "$USER_DEVICE" ]; then
        DEVICE="$USER_DEVICE"
    fi
fi

echo ""

# Step 2: Set up port forward
echo -e "${YELLOW}[2/4]${NC} Setting up ADB reverse port forward..."
echo "  Device: $DEVICE"
echo "  Mapping: device:8080 → host:4000"

if adb -s "$DEVICE" reverse tcp:8080 tcp:4000; then
    echo -e "${GREEN}✓ Port forward configured${NC}"
else
    echo -e "${RED}✗ Failed to configure port forward${NC}"
    exit 1
fi

echo ""

# Step 3: Verify port forward
echo -e "${YELLOW}[3/4]${NC} Verifying port forward..."
REVERSE_LIST=$(adb -s "$DEVICE" reverse --list)

if echo "$REVERSE_LIST" | grep -q "tcp:8080 tcp:4000"; then
    echo -e "${GREEN}✓ Port forward verified:${NC}"
    echo "$REVERSE_LIST" | grep "tcp:8080 tcp:4000" | sed 's/^/  /'
else
    echo -e "${RED}✗ Port forward verification failed${NC}"
    echo "  Expected to find: tcp:8080 tcp:4000"
    exit 1
fi

echo ""

# Step 4: Check backend connectivity
echo -e "${YELLOW}[4/4]${NC} Checking backend connectivity..."

if command -v curl &> /dev/null; then
    if curl -s http://localhost:4000/health > /dev/null 2>&1; then
        HEALTH=$(curl -s http://localhost:4000/health | grep -o '"status":"[^"]*"')
        echo -e "${GREEN}✓ Backend is running:${NC}"
        echo "  $HEALTH"
    else
        echo -e "${YELLOW}⚠ Backend health check failed${NC}"
        echo "  Is docker-compose running? Try: cd backend && docker-compose up -d"
    fi
else
    echo -e "${YELLOW}⚠ curl not found, skipping health check${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Network bridge setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Launch Mind Wars app on the device"
echo "  2. Try to login or create a lobby"
echo "  3. Monitor console for connection status"
echo ""
echo -e "${YELLOW}Note:${NC} Port forward will reset on device reboot or USB disconnect"
echo "      Re-run this script to restore: ${BLUE}./setup-network-bridge.sh${NC}"
echo ""
