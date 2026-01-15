# Registration Fix - Testing Guide

**Status**: ✅ Code fixed and committed (ad3ed8c) | ⚠️ Awaiting successful build

---

## What Was Fixed

### Backend/Frontend API Mismatch
- **Issue**: Backend expected `displayName`, app sent `username`
- **Fix**: Changed API payload to send `displayName`
- **Issue**: Backend returned `{success, data: {accessToken}}`, app expected `{token, user}`
- **Fix**: Added response normalization in ApiService

### Files Changed
1. `lib/services/api_service.dart` - Fixed register() and login() methods
2. `lib/models/models.dart` - Made User.fromJson() handle backend fields

---

## Testing Checklist

### Prerequisites
```bash
# Ensure backend is running
curl http://localhost:4000/health
# Should return: {"status":"healthy",...}

# Ensure devices connected
adb devices
# Should show both devices connected

# Ensure port forwards active
adb -s 172.16.0.26:5555 reverse --list
adb -s 172.16.0.6:5555 reverse --list
# Should show: tcp:8080 tcp:4000
```

### Build & Deploy (When SDK Fixed)
```bash
# Option 1: Release build (smaller, optimized)
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha

# Option 2: Debug build (faster compile, includes logs)
flutter build apk --flavor alpha --debug --dart-define=FLAVOR=alpha

# Install on both devices
adb -s 172.16.0.26:5555 install -r build/app/outputs/flutter-apk/app-alpha-*.apk
adb -s 172.16.0.6:5555 install -r build/app/outputs/flutter-apk/app-alpha-*.apk
```

### Manual Testing
1. **Open app on Device 1 (172.16.0.26:5555)**
   - Tap "Create Account"
   - Enter username: `AlphaUser1`
   - Enter email: `alphauser1@test.com`
   - Enter password: `Test1234`
   - Confirm password: `Test1234`
   - Tap "Create Account" button
   - ✅ Should succeed and navigate to onboarding

2. **Open app on Device 2 (172.16.0.6:5555)**
   - Tap "Create Account"
   - Enter username: `AlphaUser2`
   - Enter email: `alphauser2@test.com`
   - Enter password: `Test1234`
   - Confirm password: `Test1234`
   - Tap "Create Account" button
   - ✅ Should succeed and navigate to onboarding

3. **Test Duplicate Email (Device 1)**
   - Logout if needed
   - Try to register with `alphauser1@test.com` again
   - ✅ Should show error: "Email already registered"

4. **Test Login (Device 1)**
   - Go to Login screen
   - Enter email: `alphauser1@test.com`
   - Enter password: `Test1234`
   - ✅ Should login successfully

### Debug Logging (If Issues Occur)
```bash
# Watch logs during registration attempt
adb -s 172.16.0.26:5555 logcat -c  # Clear logs first
adb -s 172.16.0.26:5555 logcat | grep -E "\[Registration\]|\[AuthService\]|\[API\]"

# Expected log sequence on success:
# [Registration] Starting registration for: alphauser1@test.com
# [Registration] Username: AlphaUser1
# [AuthService] Starting registration for: alphauser1@test.com
# [AuthService] Validation passed, calling API register method
# [API] Attempting registration for: alphauser1@test.com at http://localhost:8080/api/auth/register
# [API] Registration response status: 201
# [API] Registration response body: {"success":true,"data":{...}}
# [AuthService] API returned: success=true
# [AuthService] Storing auth data and creating user object
# [AuthService] Registration successful for: alphauser1@test.com
# [Registration] Result: success=true, error=null
# [Registration] Registration successful, navigating to onboarding
```

### Backend Validation
```bash
# Test registration endpoint directly (use unique email each time)
curl -X POST http://localhost:4000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"displayName":"TestUser","email":"test$(date +%s)@example.com","password":"Test1234"}'

# Expected response:
# {"success":true,"data":{"user":{...},"accessToken":"...","refreshToken":"..."}}
```

---

## Known Issues

### ⚠️ Current Build Blocker
**Issue**: Flutter SDK Kotlin compilation error in FlutterPlugin.kt
```
Unresolved reference: filePermissions
Unresolved reference: user
Unresolved reference: read
Unresolved reference: write
```

**Potential Solutions**:
1. **Flutter SDK repair**: 
   ```bash
   flutter doctor -v
   flutter clean
   flutter pub get
   ```

2. **Use different Flutter channel**:
   ```bash
   flutter channel stable
   flutter upgrade
   ```

3. **Gradle cache clear**:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   rm -rf build/
   ```

4. **Last resort - Reinstall Flutter**:
   - Download fresh Flutter SDK
   - Update PATH
   - Run `flutter doctor`

---

## Expected Behavior After Fix

### Successful Registration Flow
```
1. User fills form with valid credentials
2. App validates locally (email format, password strength)
3. App sends POST to http://localhost:8080/api/auth/register
   Body: {"displayName": "...", "email": "...", "password": "..."}
4. Backend validates and creates user in PostgreSQL
5. Backend returns JWT tokens and user data
6. App normalizes response format
7. App stores token in SharedPreferences
8. App sets currentUser in AuthService
9. App navigates to /onboarding
10. ✅ User is logged in!
```

### Error Handling
- **Duplicate email**: Shows "Email already registered"
- **Network error**: Shows "Network error. Please check your connection"
- **Weak password**: Form validation prevents submission
- **Invalid email**: Form validation prevents submission

---

## Multiplayer Testing (After Registration Works)

Once both users are registered:

1. **Device 1**: Create a lobby
2. **Device 2**: Join the lobby
3. Play a game together
4. Test real-time chat
5. Test turn-based gameplay
6. Verify score synchronization

---

## Quick Reference Commands

```bash
# Backend health check
curl http://localhost:4000/health

# Check device connections
adb devices

# Check port forwards
adb reverse --list

# View app logs
adb logcat | grep -i flutter

# Install APK
adb install -r app-alpha-release.apk

# Launch app
adb shell am start -n com.mindwars.app.alpha/com.mindwars.app.MainActivity

# Uninstall app
adb uninstall com.mindwars.app.alpha
```

---

**Next Step**: Resolve Flutter SDK build issue, then follow testing checklist above.
