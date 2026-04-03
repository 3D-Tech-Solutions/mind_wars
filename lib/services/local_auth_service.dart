/**
 * Local Authentication Service
 * Handles local-only authentication for alpha testing
 * Stores user credentials in local SQLite database
 * Will be synced with cloud backend when available
 */

import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/models.dart';

class LocalAuthService {
  final Database database;
  static const String _currentUserIdKey = 'local_current_user_id';
  static const String _autoLoginKey = 'local_auto_login';
  
  User? _currentUser;
  
  LocalAuthService({required this.database});
  
  /// Get current authenticated user
  User? get currentUser => _currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;
  
  /// Hash password for secure storage
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  /// Register a new user locally
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      final validationError = _validateRegistration(username, email, password);
      if (validationError != null) {
        return AuthResult(success: false, error: validationError);
      }
      
      // Check if email already exists
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult(success: false, error: 'Email already registered');
      }
      
      // Check if username already exists
      final existingUsername = await _getUserByUsername(username);
      if (existingUsername != null) {
        return AuthResult(success: false, error: 'Username already taken');
      }
      
      // Create new user
      final userId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final passwordHash = _hashPassword(password);
      
      await database.insert('local_users', {
        'id': userId,
        'username': username,
        'email': email,
        'display_name': username,
        'avatar': null,
        'password_hash': passwordHash,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      });
      
      // Create user object
      _currentUser = User(
        id: userId,
        username: username,
        email: email,
        displayName: username,
        createdAt: DateTime.now(),
      );
      
      // Store current user
      await _storeCurrentUser(userId, autoLogin: true);
      
      return AuthResult(success: true, user: _currentUser);
    } catch (e) {
      return AuthResult(success: false, error: 'Registration failed: $e');
    }
  }
  
  /// Login user with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
    bool autoLogin = false,
  }) async {
    try {
      // Get user by email
      final user = await _getUserByEmail(email);
      if (user == null) {
        return AuthResult(success: false, error: 'Invalid email or password');
      }
      
      // Verify password
      final passwordHash = _hashPassword(password);
      if (user['password_hash'] != passwordHash) {
        return AuthResult(success: false, error: 'Invalid email or password');
      }
      
      // Create user object
      _currentUser = _mapLocalUser(user);
      
      // Store current user
      await _storeCurrentUser(user['id'], autoLogin: autoLogin);
      
      return AuthResult(success: true, user: _currentUser);
    } catch (e) {
      return AuthResult(success: false, error: 'Login failed: $e');
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
    await _clearCurrentUser();
  }
  
  /// Restore session from stored user
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoLogin = prefs.getBool(_autoLoginKey) ?? false;
      
      if (!autoLogin) {
        return false;
      }
      
      final userId = prefs.getString(_currentUserIdKey);
      if (userId == null) {
        return false;
      }
      
      // Get user from database
      final results = await database.query(
        'local_users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      if (results.isEmpty) {
        return false;
      }
      
      final user = results.first;
      _currentUser = _mapLocalUser(user);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// [2026-03-26 Feature] Persist display name and avatar for local alpha users.
  ///
  /// Alpha mode skips the backend entirely, so profile setup has to update the
  /// local user record and in-memory auth state directly.
  Future<User> updateProfile({
    required String userId,
    required String displayName,
    required String avatar,
  }) async {
    final trimmedDisplayName = displayName.trim();

    await database.update(
      'local_users',
      {
        'display_name': trimmedDisplayName,
        'avatar': avatar,
        'synced': 0,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    final results = await database.query(
      'local_users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) {
      throw Exception('Local user not found');
    }

    final updatedUser = _mapLocalUser(results.first);
    _currentUser = updatedUser;
    return updatedUser;
  }
  
  /// Get user by email
  Future<Map<String, dynamic>?> _getUserByEmail(String email) async {
    final results = await database.query(
      'local_users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    return results.isEmpty ? null : results.first;
  }
  
  /// Get user by username
  Future<Map<String, dynamic>?> _getUserByUsername(String username) async {
    final results = await database.query(
      'local_users',
      where: 'username = ?',
      whereArgs: [username],
    );
    
    return results.isEmpty ? null : results.first;
  }
  
  /// Store current user ID
  Future<void> _storeCurrentUser(String userId, {bool autoLogin = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserIdKey, userId);
    await prefs.setBool(_autoLoginKey, autoLogin);
  }
  
  /// Clear current user
  Future<void> _clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_autoLoginKey);
  }
  
  /// Validate registration inputs
  String? _validateRegistration(String username, String email, String password) {
    if (username.isEmpty || username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      return passwordError;
    }
    
    return null;
  }
  
  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  /// Validate password strength
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  /// Get all unsynced users (for cloud sync later)
  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final results = await database.query(
      'local_users',
      where: 'synced = ?',
      whereArgs: [0],
    );
    
    return results;
  }
  
  /// Mark user as synced
  Future<void> markUserAsSynced(String userId) async {
    await database.update(
      'local_users',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// [2026-03-26 Maintenance] Normalize SQLite rows into the shared User model.
  ///
  /// Keeping the mapping in one place avoids profile field drift between local
  /// registration, login, and session restore paths.
  User _mapLocalUser(Map<String, dynamic> user) {
    final username = user['username'] as String;
    final storedDisplayName = user['display_name'] as String?;

    return User(
      id: user['id'] as String,
      username: username,
      email: user['email'] as String,
      displayName: storedDisplayName == null || storedDisplayName.trim().isEmpty
          ? username
          : storedDisplayName,
      avatar: user['avatar'] as String?,
      createdAt: DateTime.parse(user['created_at'] as String),
    );
  }
}
