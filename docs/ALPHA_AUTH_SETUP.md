# Alpha Testing Authentication Setup

## Overview

During alpha testing, Mind Wars uses **local authentication** that stores user credentials entirely on the device. This allows you to test the app without requiring a backend server, while still experiencing the full authentication flow.

## How It Works

### Local Authentication Mode

When `kAlphaMode = true` in `lib/main.dart` (which is the default):

1. **User Registration**: Creates accounts stored in a local SQLite database
2. **User Login**: Authenticates against locally stored credentials
3. **Auto-Login**: Remembers users on the device (if enabled)
4. **Password Security**: Passwords are hashed using SHA-256 before storage
5. **Data Persistence**: All user data stays on the device

### Database Structure

The local authentication system uses a SQLite table:

```sql
CREATE TABLE local_users (
  id TEXT PRIMARY KEY,              -- Generated: 'local_<timestamp>'
  username TEXT NOT NULL UNIQUE,    -- User's chosen username
  email TEXT NOT NULL UNIQUE,       -- User's email address
  password_hash TEXT NOT NULL,      -- SHA-256 hashed password
  created_at TEXT NOT NULL,         -- Account creation timestamp
  synced INTEGER DEFAULT 0          -- Cloud sync status (for future)
)
```

### Features Enabled in Alpha Mode

✅ **Create Account**: Register with username, email, and password  
✅ **Login**: Sign in with email and password  
✅ **Remember Me**: Auto-login on app restart  
✅ **Logout**: Clear session and return to login  
✅ **Password Validation**: Same security requirements as production  
✅ **Duplicate Prevention**: Email and username uniqueness checks  

### Alpha Mode Indicators

Users will see visual indicators that they're in alpha mode:

- **Splash Screen**: "ALPHA VERSION" badge
- **Login Screen**: Blue info banner explaining local authentication
- **Registration Screen**: Blue info banner about local storage and future sync
- **App Title**: Shows "Mind Wars Alpha" instead of "Mind Wars"

## Testing the Authentication Flow

### Creating a New Account

1. Launch the app
2. On the login screen, tap **"Create New Account"**
3. Fill in:
   - Username (min 3 characters)
   - Email (valid format)
   - Password (min 8 chars, uppercase, lowercase, number)
   - Confirm Password (must match)
4. Tap **"Create Account"**
5. You'll be logged in and redirected to the home screen

### Logging In

1. On the login screen, enter your email and password
2. (Optional) Check **"Remember me"** for auto-login
3. Tap **"Login"**
4. You'll be redirected to the home screen

### Auto-Login

If you enabled "Remember me":
1. Close the app completely
2. Reopen the app
3. You'll automatically be logged in (no login screen)

### Multiple Accounts

You can create multiple accounts on the same device:
- Each account has a unique email
- Each account has a unique username
- Switch between accounts by logging out and logging back in

## Switching to Production Mode

When the backend server is ready:

1. Set `kAlphaMode = false` in `lib/main.dart`
2. Configure the API endpoint in `ApiService`
3. The app will switch to server-based authentication
4. Local accounts can be synced to the server (future feature)

## Migration Path

The local authentication system is designed to support future cloud sync:

1. **Sync Flag**: Each local user has a `synced` flag (currently 0)
2. **User IDs**: Local IDs are prefixed with `local_` to distinguish them
3. **Future Sync**: When backend is ready, unsynced users can be uploaded
4. **Conflict Resolution**: Server IDs will replace local IDs after sync

## Security Notes

### Alpha Mode Security

- ✅ Passwords are hashed (SHA-256) before storage
- ✅ No plaintext passwords in database
- ✅ Client-side validation enforces password strength
- ✅ Email and username uniqueness enforced
- ⚠️  Data is stored unencrypted on device (standard SQLite)
- ⚠️  No server-side validation (local only)

### Production Mode Security

When you switch to production mode (`kAlphaMode = false`):
- ✅ JWT tokens for authentication
- ✅ Server-side validation
- ✅ Encrypted communication (HTTPS)
- ✅ Token refresh and expiration
- ✅ Backend security measures

## Troubleshooting

### Cannot Login After Creating Account

- Verify you're using the exact email and password
- Check that password meets requirements (8+ chars, uppercase, lowercase, number)
- Try logging out and logging back in

### Forgot Password

In alpha mode, there's no password recovery since there's no backend. If you forget your password:

**Option 1: Create a new account** (different email)  
**Option 2: Clear app data** (loses all local accounts)  
**Option 3: Reinstall the app** (loses all local accounts)

### Clear All Local Accounts

To reset and remove all local accounts:

```dart
// Add this to your test code or debug menu
final offlineService = Provider.of<OfflineService>(context, listen: false);
final db = await offlineService.database;
await db.delete('local_users');
```

Or uninstall and reinstall the app.

### Database Errors

If you encounter database errors:
1. Close the app completely
2. Clear app cache/data (device settings)
3. Reopen the app (database will be recreated)

## Developer Information

### Implementation Files

- `lib/services/local_auth_service.dart` - Local authentication logic
- `lib/services/auth_service.dart` - Unified auth service (local + API)
- `lib/services/offline_service.dart` - SQLite database management
- `lib/main.dart` - App initialization with alpha mode flag

### Testing

Run the included tests:

```bash
flutter test test/auth_service_test.dart
```

### Configuration

Toggle between alpha and production mode:

```dart
// lib/main.dart
const bool kAlphaMode = true;  // Alpha mode (local auth)
const bool kAlphaMode = false; // Production mode (API auth)
```

## Future Enhancements

Planned features for cloud backend integration:

- [ ] Sync local accounts to cloud
- [ ] Merge duplicate accounts
- [ ] Password reset via email
- [ ] OAuth social login (Google, Apple)
- [ ] Multi-device sync
- [ ] Account deletion and GDPR compliance
- [ ] Email verification
- [ ] Two-factor authentication

## Support

For issues or questions about alpha testing:
- Create a GitHub issue with the `alpha-testing` label
- Include device info and steps to reproduce
- Attach relevant error messages or screenshots

---

**Note**: Alpha mode is for testing purposes only. When the backend is ready, switch to production mode for a fully featured, secure authentication system.
