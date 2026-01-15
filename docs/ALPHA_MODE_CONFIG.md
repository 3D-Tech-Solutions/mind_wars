# Alpha Mode Configuration Checklist

This checklist helps developers switch between alpha mode (local auth) and production mode (API auth).

## 🔄 Switching from Alpha to Production

When your backend is ready and you want to switch to production mode:

### 1. Update Configuration Flag

**File:** `lib/main.dart`

```dart
// Change this line:
const bool kAlphaMode = true;  // ❌ Alpha mode

// To this:
const bool kAlphaMode = false; // ✅ Production mode
```

### 2. Configure API Endpoint

**File:** `lib/main.dart` (in `_initializeServices` method)

```dart
_apiService = ApiService(
  baseUrl: 'https://api.mindwars.app', // Update to your production API
);
```

### 3. Test Production Mode

Run these checks:

- [ ] Registration calls `/auth/register` endpoint
- [ ] Login calls `/auth/login` endpoint
- [ ] JWT tokens are stored and used
- [ ] API errors are handled gracefully
- [ ] Auto-login works with tokens
- [ ] Logout clears tokens

### 4. Update App Branding

- [ ] Remove "Alpha" from app title
- [ ] Remove alpha mode indicators from screens
- [ ] Update app icons (if different for alpha)
- [ ] Update version numbers

### 5. Data Migration (Optional)

If you want to migrate local accounts to the server:

```dart
// Example migration code
final offlineService = OfflineService();
final database = await offlineService.database;
final localAuthService = LocalAuthService(database: database);

// Get all unsynced users
final unsyncedUsers = await localAuthService.getUnsyncedUsers();

// For each user, create account on server
for (final user in unsyncedUsers) {
  try {
    // Create account on server
    await apiService.register(
      user['username'],
      user['email'],
      // Note: Password hashes can't be migrated - users need to reset
    );
    
    // Mark as synced
    await localAuthService.markUserAsSynced(user['id']);
  } catch (e) {
    print('Failed to migrate user ${user['id']}: $e');
  }
}
```

**Important:** Password hashes cannot be migrated directly. Users will need to:
- Reset their passwords via email
- Or re-register with the same credentials

## 🔙 Switching Back to Alpha Mode

Need to go back to alpha mode for testing?

### 1. Update Configuration

```dart
const bool kAlphaMode = true; // Back to alpha mode
```

### 2. Clean Test Data (Optional)

```dart
// Clear local users for fresh testing
final db = await offlineService.database;
await db.delete('local_users');
```

## 📋 Pre-Production Checklist

Before switching to production mode, ensure:

### Backend Requirements

- [ ] API endpoints are implemented and tested
  - `POST /auth/register`
  - `POST /auth/login`
  - `POST /auth/logout`
  - `GET /auth/me` (validate token)
  - `POST /auth/refresh` (refresh token)
- [ ] Server-side validation is working
- [ ] JWT token generation and validation
- [ ] Password hashing on server (bcrypt/argon2)
- [ ] Rate limiting for auth endpoints
- [ ] Email verification system (optional)
- [ ] Password reset flow (optional)

### Security

- [ ] HTTPS is enabled and enforced
- [ ] CORS is properly configured
- [ ] SQL injection protection
- [ ] XSS protection
- [ ] Rate limiting implemented
- [ ] Input validation on server
- [ ] JWT secret is secure and rotated
- [ ] Passwords are hashed with salt

### Testing

- [ ] All existing tests pass
- [ ] API integration tests pass
- [ ] Production mode tests pass
- [ ] Load testing completed
- [ ] Security audit completed

### Documentation

- [ ] API documentation is complete
- [ ] Error codes are documented
- [ ] Rate limits are documented
- [ ] Update README with production setup
- [ ] Update user documentation

## 🔧 Hybrid Mode (Optional)

You can support both modes simultaneously:

```dart
// Example hybrid implementation
Future<AuthResult> register({
  required String username,
  required String email,
  required String password,
}) async {
  if (kAlphaMode && _localAuthService != null) {
    // Try local auth first
    final localResult = await _localAuthService!.register(...);
    
    // Optionally also create on server in background
    if (localResult.success && await _isServerAvailable()) {
      _syncUserToServer(localResult.user!);
    }
    
    return localResult;
  } else {
    // Production mode - use API
    return await _registerViaAPI(...);
  }
}
```

## 📝 Environment Variables

Consider using environment variables for configuration:

```dart
// Example using flutter_dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

const bool kAlphaMode = bool.fromEnvironment(
  'ALPHA_MODE',
  defaultValue: true,
);

final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.mindwars.app';
```

This allows different configurations per build:

```bash
# Alpha build
flutter build apk --dart-define=ALPHA_MODE=true

# Production build
flutter build apk --dart-define=ALPHA_MODE=false
```

## 🚨 Common Issues

### Issue: API calls fail in production mode

**Solution:**
- Check API endpoint URL
- Verify network connectivity
- Check API server logs
- Verify CORS headers
- Check JWT token format

### Issue: Users can't login after switching modes

**Solution:**
- Clear app data for fresh start
- Users may need to re-register in production mode
- Local accounts don't automatically sync

### Issue: Auto-login doesn't work

**Solution:**
- Verify SharedPreferences keys are correct
- Check JWT token expiration
- Verify token refresh logic

## 📚 Additional Resources

- [ALPHA_AUTH_SETUP.md](ALPHA_AUTH_SETUP.md) - Technical documentation
- [ALPHA_TESTING_QUICKSTART.md](ALPHA_TESTING_QUICKSTART.md) - User guide
- [API Documentation](docs/api/) - API reference (when available)

## ✅ Final Verification

After switching modes, verify:

- [ ] App builds successfully
- [ ] Registration works
- [ ] Login works
- [ ] Logout works
- [ ] Auto-login works
- [ ] Error handling works
- [ ] No console errors
- [ ] No crashes
- [ ] UI updates correctly
- [ ] Performance is acceptable

---

**Note:** Always test thoroughly in a staging environment before deploying to production!
