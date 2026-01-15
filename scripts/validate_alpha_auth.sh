#!/bin/bash

# Alpha Testing Authentication - Validation Script
# This script checks if all components are in place

echo "🔍 Validating Alpha Testing Authentication Implementation..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check counters
PASS=0
FAIL=0

# Function to check file existence
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $1 (missing)"
        ((FAIL++))
    fi
}

# Function to check if string exists in file
check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $3"
        ((FAIL++))
    fi
}

echo "📁 Checking Core Files..."
check_file "lib/services/local_auth_service.dart"
check_file "lib/services/auth_service.dart"
check_file "lib/services/offline_service.dart"
check_file "lib/main.dart"

echo ""
echo "📱 Checking UI Updates..."
check_file "lib/screens/login_screen.dart"
check_file "lib/screens/registration_screen.dart"
check_file "lib/screens/splash_screen.dart"

echo ""
echo "🧪 Checking Tests..."
check_file "test/local_auth_service_test.dart"
check_file "test/alpha_auth_integration_test.dart"

echo ""
echo "📚 Checking Documentation..."
check_file "ALPHA_AUTH_SETUP.md"
check_file "ALPHA_TESTING_QUICKSTART.md"
check_file "ALPHA_MODE_CONFIG.md"

echo ""
echo "🔧 Checking Configuration..."
check_content "pubspec.yaml" "crypto:" "crypto package added"
check_content "pubspec.yaml" "sqflite_common_ffi:" "sqflite_common_ffi package added"
check_content "lib/main.dart" "kAlphaMode" "kAlphaMode constant defined"
check_content "lib/main.dart" "LocalAuthService" "LocalAuthService imported"

echo ""
echo "💾 Checking Database Schema..."
check_content "lib/services/offline_service.dart" "local_users" "local_users table added"
check_content "lib/services/offline_service.dart" "password_hash" "password_hash column exists"
check_content "lib/services/offline_service.dart" "idx_local_users_email" "Email index created"

echo ""
echo "🎨 Checking UI Indicators..."
check_content "lib/screens/login_screen.dart" "kAlphaMode" "Login screen has alpha indicator"
check_content "lib/screens/registration_screen.dart" "kAlphaMode" "Registration screen has alpha indicator"
check_content "lib/screens/splash_screen.dart" "ALPHA VERSION" "Splash screen has alpha badge"

echo ""
echo "🔐 Checking Security Features..."
check_content "lib/services/local_auth_service.dart" "sha256" "Password hashing implemented"
check_content "lib/services/local_auth_service.dart" "_validatePassword" "Password validation exists"
check_content "lib/services/local_auth_service.dart" "_isValidEmail" "Email validation exists"

echo ""
echo "🔄 Checking Auth Service Integration..."
check_content "lib/services/auth_service.dart" "isAlphaMode" "Alpha mode flag exists"
check_content "lib/services/auth_service.dart" "_localAuthService" "LocalAuthService integrated"
check_content "lib/services/auth_service.dart" "if (_isAlphaMode" "Alpha mode routing exists"

echo ""
echo "✨ Checking Test Coverage..."
check_content "test/local_auth_service_test.dart" "register - creates new user" "Registration tests exist"
check_content "test/local_auth_service_test.dart" "login - succeeds with correct credentials" "Login tests exist"
check_content "test/alpha_auth_integration_test.dart" "alpha mode flag is set correctly" "Integration tests exist"

echo ""
echo "════════════════════════════════════════════════"
echo -e "Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "✅ Alpha testing authentication is fully implemented"
    echo "📖 See ALPHA_TESTING_QUICKSTART.md to get started"
    echo "🔧 See ALPHA_MODE_CONFIG.md for configuration"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    echo "❌ Please review the missing components above"
    exit 1
fi
