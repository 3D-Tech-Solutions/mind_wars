/**
 * Authentication Service
 * Manages user authentication state, token storage, and session management
 * Security-First: JWT tokens stored securely, auto-login support
 * Alpha Mode: Uses local authentication without backend
 */

import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'local_auth_service.dart';
import '../models/models.dart';

class AuthService {
  final ApiService _apiService;
  final LocalAuthService? _localAuthService;
  final bool _isAlphaMode;
  
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _autoLoginKey = 'auto_login';
  
  User? _currentUser;
  
  AuthService({
    required ApiService apiService,
    LocalAuthService? localAuthService,
    bool isAlphaMode = true, // Default to alpha mode for testing
  })  : _apiService = apiService,
        _localAuthService = localAuthService,
        _isAlphaMode = isAlphaMode;
  
  /// Get current authenticated user
  User? get currentUser => _currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;
  
  /// Check if running in alpha mode
  bool get isAlphaMode => _isAlphaMode;

  /// Get the current auth token
  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      print('[AuthService] Returning stored auth token');
    } else {
      print('[AuthService] No auth token found');
    }
    return token;
  }

  /// Register a new user
  /// Validates email, password strength, and handles errors
  /// [2025-11-18 Feature] Enhanced with comprehensive logging
  Future<AuthResult> register({
    required String email,
    required String password,
  }) async {
    print('\n========== AUTH SERVICE REGISTRATION START ==========');
    print('[AuthService] Timestamp: ${DateTime.now().toIso8601String()}');
    print('[AuthService] Alpha mode: $_isAlphaMode');
    print('[AuthService] Has local auth service: ${_localAuthService != null}');
    print('[AuthService] Email: $email');
    print('[AuthService] Password length: ${password.length}');

    /// [2026-03-26 Bugfix] Capture the nullable dependency in a local variable.
    ///
    /// The current Android build toolchain is compiling with a Dart version
    /// that does not support promoting this private final field directly.
    /// Using a local variable keeps the null check explicit and release builds stable.
    final localAuthService = _localAuthService;

    // Use local auth in alpha mode - temporarily create a default username
    if (_isAlphaMode && localAuthService != null) {
      print('[AuthService] Using local authentication (alpha mode)');
      // Use email prefix as temporary username for local auth
      final tempUsername = email.split('@')[0];
      final result = await localAuthService.register(
        username: tempUsername,
        email: email,
        password: password,
      );
      if (result.success) {
        _currentUser = result.user;
        print('[AuthService] Local auth successful');
      } else {
        print('[AuthService] Local auth failed: ${result.error}');
      }
      print('========== AUTH SERVICE REGISTRATION END ==========\n');
      return result;
    }

    // Use API auth in production mode
    try {
      print('[AuthService] Using API authentication (production mode)');

      // Client-side validation before API call
      print('[AuthService] Running client-side validation...');
      final validationError = _validatePassword(password);
      if (validationError != null) {
        print('[AuthService] Validation failed: $validationError');
        print('========== AUTH SERVICE REGISTRATION FAILED ==========\n');
        return AuthResult(success: false, error: validationError);
      }
      if (!_isValidEmail(email)) {
        print('[AuthService] Validation failed: Invalid email');
        print('========== AUTH SERVICE REGISTRATION FAILED ==========\n');
        return AuthResult(success: false, error: 'Invalid email address');
      }
      print('[AuthService] Validation passed ✓');

      print('[AuthService] Calling API service register method...');
      // Call API (without username)
      final response = await _apiService.register(email, password);
      
      print('[AuthService] API call completed');
      print('[AuthService] Response keys: ${response.keys}');
      print('[AuthService] Has token: ${response['token'] != null}');
      print('[AuthService] Has user: ${response['user'] != null}');
      
      // Store token and user info
      if (response['token'] != null && response['user'] != null) {
        final token = response['token'] as String;
        final userData = response['user'] as Map<String, dynamic>;
        
        print('[AuthService] Token received (length: ${token.length})');
        print('[AuthService] User data keys: ${userData.keys}');
        print('[AuthService] Storing authentication data...');
        
        await _storeAuthData(token, userData);
        print('[AuthService] Auth data stored ✓');
        
        print('[AuthService] Creating User object from JSON...');
        _currentUser = User.fromJson(userData);
        print('[AuthService] User object created: ${_currentUser?.username}');
        
        print('[AuthService] Registration successful for: $email');
        print('========== AUTH SERVICE REGISTRATION SUCCESS ==========\n');
        return AuthResult(success: true, user: _currentUser);
      }
      
      print('[AuthService] ERROR: Response missing token or user data');
      print('[AuthService] Response: $response');
      print('========== AUTH SERVICE REGISTRATION FAILED ==========\n');
      return AuthResult(success: false, error: 'Registration failed - Invalid response from server');
    } catch (e, stackTrace) {
      print('\n========== AUTH SERVICE REGISTRATION EXCEPTION ==========');
      print('[AuthService] Exception type: ${e.runtimeType}');
      print('[AuthService] Exception message: $e');
      print('[AuthService] Stack trace:');
      print(stackTrace);
      
      final errorMessage = _handleError(e);
      print('[AuthService] Formatted error message: $errorMessage');
      print('========== AUTH SERVICE REGISTRATION EXCEPTION END ==========\n');
      
      return AuthResult(success: false, error: errorMessage);
    }
  }
  
  /// Login user with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
    bool autoLogin = false,
  }) async {
    /// [2026-03-26 Bugfix] Use a local promoted reference for local auth access.
    final localAuthService = _localAuthService;

    // Use local auth in alpha mode
    if (_isAlphaMode && localAuthService != null) {
      final result = await localAuthService.login(
        email: email,
        password: password,
        autoLogin: autoLogin,
      );
      if (result.success) {
        _currentUser = result.user;
      }
      return result;
    }
    
    // Use API auth in production mode
    try {
      print('[AuthService.login] Calling API login...');
      // Call API
      final response = await _apiService.login(email, password);

      print('[AuthService.login] API response keys: ${response.keys.toList()}');
      print('[AuthService.login] Response: $response');

      // Store token and user info
      if (response['token'] != null && response['user'] != null) {
        print('[AuthService.login] Response has token and user');
        final token = response['token'] as String;
        final userData = response['user'] as Map<String, dynamic>;

        print('[AuthService.login] User data keys: ${userData.keys.toList()}');
        print('[AuthService.login] Creating User from data...');

        await _storeAuthData(token, userData, autoLogin: autoLogin);
        _currentUser = User.fromJson(userData);

        print('[AuthService.login] ✓ Login successful, user: ${_currentUser?.username}');
        return AuthResult(success: true, user: _currentUser);
      }

      print('[AuthService.login] ✗ Response missing token or user. Keys: ${response.keys.toList()}');
      return AuthResult(success: false, error: 'Login failed - Invalid response');
    } catch (e, stackTrace) {
      print('[AuthService.login] ✗ Exception: $e');
      print('[AuthService.login] Stack trace: $stackTrace');
      return AuthResult(success: false, error: _handleError(e));
    }
  }
  
  /// Logout user and clear stored data
  Future<void> logout() async {
    /// [2026-03-26 Bugfix] Use a local promoted reference for local auth access.
    final localAuthService = _localAuthService;

    // Use local auth in alpha mode
    if (_isAlphaMode && localAuthService != null) {
      await localAuthService.logout();
      _currentUser = null;
      return;
    }
    
    // Use API auth in production mode
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with local logout even if API call fails
    }
    
    await _clearAuthData();
    _currentUser = null;
  }
  
  /// Request password reset email
  Future<AuthResult> requestPasswordReset(String email) async {
    // In alpha mode, simulate success
    if (_isAlphaMode) {
      // Validate email format
      if (!_isValidEmail(email)) {
        return AuthResult(success: false, error: 'Please enter a valid email address');
      }
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      return AuthResult(success: true);
    }
    
    // Use API in production mode
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return AuthResult(success: false, error: 'Please enter a valid email address');
      }
      
      await _apiService.requestPasswordReset(email);
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, error: _handleError(e));
    }
  }
  
  /// Attempt to restore session from stored token
  /// Used for auto-login on app launch
  Future<bool> restoreSession() async {
    /// [2026-03-26 Bugfix] Use a local promoted reference for local auth access.
    final localAuthService = _localAuthService;

    // Use local auth in alpha mode
    if (_isAlphaMode && localAuthService != null) {
      final restored = await localAuthService.restoreSession();
      if (restored) {
        _currentUser = localAuthService.currentUser;
      }
      return restored;
    }
    
    // Use API auth in production mode
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoLogin = prefs.getBool(_autoLoginKey) ?? false;
      
      if (!autoLogin) {
        return false;
      }
      
      final token = prefs.getString(_tokenKey);
      final userId = prefs.getString(_userIdKey);
      final username = prefs.getString(_usernameKey);
      final email = prefs.getString(_emailKey);
      
      if (token != null && userId != null) {
        _apiService.setAuthToken(token);
        _currentUser = User(
          id: userId,
          username: username ?? '',
          email: email ?? '',
        );
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get user's personal profile info (firstName, lastName, DOB, gender, bio, location)
  Future<Map<String, dynamic>> getPersonalProfile() async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _apiService.getPersonalProfile(currentUser.id);
      return response['data'] ?? {};
    } catch (e) {
      print('[AuthService.getPersonalProfile] Error: $e');
      rethrow;
    }
  }

  /// Update user's personal profile info
  Future<Map<String, dynamic>> updatePersonalProfile({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? bio,
    String? location,
  }) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _apiService.updatePersonalProfile(
        currentUser.id,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bio: bio,
        location: location,
      );
      return response['data'] ?? {};
    } catch (e) {
      print('[AuthService.updatePersonalProfile] Error: $e');
      rethrow;
    }
  }

  /// Upload custom avatar image for authenticated user
  Future<User> uploadAvatarImage(String imagePath) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _apiService.uploadAvatarImage(currentUser.id, imagePath);
      final userData = response['data'] as Map<String, dynamic>;

      // Update current user with new avatar URL
      _currentUser = User.fromJson(userData);
      return _currentUser!;
    } catch (e) {
      print('[AuthService.uploadAvatarImage] Error: $e');
      rethrow;
    }
  }

  /// [2026-03-26 Feature] Update the authenticated user's profile identity.
  ///
  /// Profile setup now flows through AuthService so alpha builds can persist the
  /// display name and avatar locally while backend builds continue to use the API.
  Future<User> updateProfile({
    String? username,
    String? displayName,
    String? avatar,
    String? avatarUrl,
  }) async {
    final currentUser = _currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    if (username == null && displayName == null && avatar == null && avatarUrl == null) {
      throw Exception('At least one field must be provided for update');
    }

    /// [2026-03-26 Bugfix] Use a local promoted reference for local auth access.
    final localAuthService = _localAuthService;

    if (_isAlphaMode && localAuthService != null) {
      final finalUsername = username ?? displayName ?? currentUser.username;
      final finalAvatar = avatar ?? currentUser.avatar ?? '';
      final updatedUser = await localAuthService.updateProfile(
        userId: currentUser.id,
        displayName: finalUsername,
        avatar: finalAvatar,
      );
      _currentUser = updatedUser;
      return updatedUser;
    }

    await _apiService.updateProfile(
      userId: currentUser.id,
      username: username,
      displayName: displayName,
      avatar: avatar,
      avatarUrl: avatarUrl,
    );

    // Update current user with the new values
    _currentUser = currentUser.copyWith(
      username: username?.trim() ?? currentUser.username,
      displayName: (username ?? displayName)?.trim() ?? currentUser.displayName,
      avatar: avatar ?? currentUser.avatar,
    );

    return _currentUser!;
  }
  
  /// Store authentication data securely
  Future<void> _storeAuthData(
    String token,
    Map<String, dynamic> userData, {
    bool autoLogin = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userData['id'] ?? '');
    // Backend sends 'displayName' instead of 'username'
    final username = userData['displayName'] ?? userData['username'] ?? '';
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, userData['email'] ?? '');
    await prefs.setBool(_autoLoginKey, autoLogin);

    _apiService.setAuthToken(token);
  }
  
  /// Clear stored authentication data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
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
  /// Requirements: 8+ chars, mixed case, numbers
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
  
  /// Handle and format errors
  /// [2025-11-18 Feature] Enhanced error handling with comprehensive pattern matching
  String _handleError(dynamic error) {
    print('[AuthService._handleError] Processing error');
    print('[AuthService._handleError] Error type: ${error.runtimeType}');
    print('[AuthService._handleError] Error string: $error');
    
    // Check for ApiException first
    if (error is ApiException) {
      print('[AuthService._handleError] ApiException detected');
      print('[AuthService._handleError] Status: ${error.statusCode}, Message: ${error.message}');
      return '${error.message} (Error ${error.statusCode})';
    }
    
    final errorString = error.toString();
    print('[AuthService._handleError] Error as string: $errorString');
    
    // Check for specific error patterns
    if (errorString.contains('duplicate')) {
      print('[AuthService._handleError] Detected: Duplicate entry');
      return 'Email already registered';
    } else if (errorString.contains('invalid')) {
      print('[AuthService._handleError] Detected: Invalid input');
      return 'Invalid email or password';
    } else if (errorString.contains('network') || errorString.contains('SocketException')) {
      print('[AuthService._handleError] Detected: Network error');
      return 'Network error. Please check your connection';
    } else if (errorString.contains('Connection refused')) {
      print('[AuthService._handleError] Detected: Connection refused');
      return 'Cannot connect to server at war.e-mothership.com:4000. Is the backend running?';
    } else if (errorString.contains('Failed host lookup')) {
      print('[AuthService._handleError] Detected: DNS lookup failed');
      return 'Cannot reach war.e-mothership.com. Please check your internet connection';
    } else if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
      print('[AuthService._handleError] Detected: Timeout');
      return 'Request timeout. Server took too long to respond';
    } else if (errorString.contains('FormatException')) {
      print('[AuthService._handleError] Detected: Format exception (likely JSON parsing)');
      return 'Invalid response from server. Please try again';
    }
    
    print('[AuthService._handleError] No specific pattern matched, returning full error');
    // Return detailed error for debugging
    return 'Error: $errorString';
  }
}
