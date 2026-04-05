/**
 * API Service - RESTful API client for potential web version
 * API-First: RESTful design with server-side validation
 * Security-First: All game logic validated server-side
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;

  ApiService({required this.baseUrl});

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Get common headers
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // ============== Health Check ==============

  /// Check backend health/connectivity
  /// Returns true if backend is reachable and healthy
  /// Note: health endpoint is at the root, not under /api
  Future<bool> healthCheck() async {
    try {
      // Extract base URL without /api suffix for health check
      final healthUrl = baseUrl.replaceAll('/api', '');
      print('[API] Performing health check on $healthUrl/health');
      final response = await http.get(
        Uri.parse('$healthUrl/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      print('[API] Health check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('[API] Health check failed: $e');
      return false;
    }
  }

  // ============== Authentication ==============

  /// Register a new user
  Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    // [2026-04-04 Refactor] Simplified registration - username/displayName now set during profile setup
    try {
      final url = '$baseUrl/auth/register';
      print('[API] Attempting registration for: $email at $url');
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      print('[API] Registration response status: ${response.statusCode}');
      print('[API] Registration response body: ${response.body}');
      
      final data = _handleResponse(response);
      
      // [2025-11-17 Bugfix] Normalize response format - backend returns {success, data: {user, accessToken}}
      // but app expects {token, user}
      if (data['success'] == true && data['data'] != null) {
        final responseData = data['data'];
        return {
          'token': responseData['accessToken'],  // Map accessToken to token
          'refreshToken': responseData['refreshToken'],
          'user': responseData['user'],
        };
      }
      
      return data;
    } catch (e) {
      print('[API] Registration error: $e');
      rethrow;
    }
  }

  /// Check if username is available
  /// If userId is provided, excludes that user from the check (for edit-profile scenarios)
  /// Returns {'available': true/false, 'username': suggested_username_if_taken}
  Future<Map<String, dynamic>> checkUsernameAvailability(String username, {String? userId}) async {
    try {
      final url = '$baseUrl/auth/check-username';
      print('[API] Checking username availability: $username${userId != null ? ' (excluding $userId)' : ''}');
      final body = <String, dynamic>{'username': username};
      if (userId != null) body['userId'] = userId;

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('[API] Username check response: $data');
        return {
          'available': data['available'] ?? false,
          'username': data['username'] ?? username,
        };
      } else {
        print('[API] Username check failed with status ${response.statusCode}');
        return {'available': false, 'username': username};
      }
    } catch (e) {
      print('[API] Username availability check error: $e');
      return {'available': false, 'username': username};
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    // [2025-11-17 Bugfix] Updated to normalize backend response format
    print('[API.login] Starting login for: $email');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('[API.login] Response status: ${response.statusCode}');
    print('[API.login] Response body: ${response.body}');

    final data = _handleResponse(response);

    print('[API.login] Parsed response data keys: ${data.keys.toList()}');
    print('[API.login] Full parsed response: $data');

    // [2025-11-17 Bugfix] Normalize response format - backend returns {success, data: {user, accessToken}}
    // but app expects {token, user}
    if (data['success'] == true && data['data'] != null) {
      print('[API.login] Response has success:true and data object');
      final responseData = data['data'];
      final token = responseData['accessToken'];
      setAuthToken(token);
      final normalizedResponse = {
        'token': token,
        'refreshToken': responseData['refreshToken'],
        'user': responseData['user'],
      };
      print('[API.login] Normalized response: ${normalizedResponse.keys.toList()}');
      return normalizedResponse;
    }

    print('[API.login] Response does not match normalized format, returning as-is');
    if (data['token'] != null) {
      setAuthToken(data['token']);
    }

    return data;
  }

  /// Logout user
  Future<void> logout() async {
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: _headers,
    );
    _authToken = null;
  }

  /// Request password reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/request-password-reset'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    );

    return _handleResponse(response);
  }

  // ============== Lobbies ==============

  /// Get available lobbies
  Future<List<GameLobby>> getLobbies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/lobbies'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return (data['lobbies'] as List)
        .map((l) => GameLobby.fromJson(l))
        .toList();
  }

  /// Create lobby
  Future<GameLobby> createLobby(String name, {int? maxPlayers}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lobbies'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'maxPlayers': maxPlayers,
      }),
    );

    final data = _handleResponse(response);
    return GameLobby.fromJson(data['lobby']);
  }

  /// Get lobby details
  Future<GameLobby> getLobby(String lobbyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lobbies/$lobbyId'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return GameLobby.fromJson(data['lobby']);
  }

  // ============== Games ==============

  /// Get available games
  Future<List<Map<String, dynamic>>> getGames() async {
    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data['games']);
  }

  /// Submit game result (with server-side validation)
  Future<Map<String, dynamic>> submitGameResult(
    String gameId,
    String lobbyId,
    Map<String, dynamic> gameData,
  ) async {
    // Security-First: Server validates all game logic
    final response = await http.post(
      Uri.parse('$baseUrl/games/$gameId/submit'),
      headers: _headers,
      body: jsonEncode({
        'lobbyId': lobbyId,
        'gameData': gameData,
      }),
    );

    return _handleResponse(response);
  }

  /// Validate game move (server-side validation)
  Future<Map<String, dynamic>> validateMove(
    String gameId,
    Map<String, dynamic> moveData,
  ) async {
    // Security-First: Server is authoritative source
    final response = await http.post(
      Uri.parse('$baseUrl/games/$gameId/validate-move'),
      headers: _headers,
      body: jsonEncode(moveData),
    );

    return _handleResponse(response);
  }

  // ============== Leaderboard ==============

  /// Get weekly leaderboard
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/weekly'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return (data['entries'] as List)
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();
  }

  /// Get all-time leaderboard
  Future<List<LeaderboardEntry>> getAllTimeLeaderboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/all-time'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return (data['entries'] as List)
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();
  }

  // ============== User Profile ==============

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers,
      body: jsonEncode(updates),
    );

    return _handleResponse(response);
  }

  /// Update profile (convenience method for profile setup/edit)
  /// Supports: username (unique), displayName (non-unique), avatar, avatarUrl
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? username,
    String? displayName,
    String? avatar,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    // Send both fields independently - backend handles them separately
    if (username != null) updates['username'] = username;
    if (displayName != null) updates['displayName'] = displayName;
    if (avatar != null) updates['avatar'] = avatar;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    return updateUserProfile(userId, updates);
  }

  /// Upload custom avatar image
  /// Returns the updated user object with new avatarUrl
  Future<Map<String, dynamic>> uploadAvatarImage(
    String userId,
    String imagePath,
  ) async {
    try {
      print('[API] Uploading avatar image for user: $userId');
      print('[API] Image path: $imagePath');

      // Create multipart request
      final uri = Uri.parse('$baseUrl/users/$userId/avatar');
      final request = http.MultipartRequest('POST', uri);

      // Add auth header
      request.headers.addAll(_headers);

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('avatar', imagePath),
      );

      // Send request
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      print('[API] Avatar upload response status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('[API] Avatar upload error: $e');
      rethrow;
    }
  }

  /// Get user progress
  Future<UserProgress> getUserProgress(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/progress'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return UserProgress.fromJson(data['progress']);
  }

  // ============== Personal Profile Info ==============

  /// Get user personal profile (firstName, lastName, DOB, gender, bio, location)
  Future<Map<String, dynamic>> getPersonalProfile(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  /// Update user personal profile
  Future<Map<String, dynamic>> updatePersonalProfile(
    String userId, {
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? bio,
    String? location,
  }) async {
    final updates = <String, dynamic>{};
    if (firstName != null) updates['firstName'] = firstName;
    if (lastName != null) updates['lastName'] = lastName;
    if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth;
    if (gender != null) updates['gender'] = gender;
    if (bio != null) updates['bio'] = bio;
    if (location != null) updates['location'] = location;

    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: _headers,
      body: jsonEncode(updates),
    );

    return _handleResponse(response);
  }

  // ============== Sync (Offline-First) ==============

  /// Sync offline game
  Future<Map<String, dynamic>> syncOfflineGame(
    String userId,
    OfflineGameData gameData,
  ) async {
    // Server-side validation prevents cheating
    final response = await http.post(
      Uri.parse('$baseUrl/sync/game'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'gameData': gameData.toJson(),
      }),
    );

    return _handleResponse(response);
  }

  /// Sync user progress
  Future<Map<String, dynamic>> syncUserProgress(
    String userId,
    UserProgress progress,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sync/progress'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'progress': progress.toJson(),
      }),
    );

    return _handleResponse(response);
  }

  /// Batch sync multiple games
  Future<Map<String, dynamic>> batchSyncGames(
    String userId,
    List<OfflineGameData> games,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sync/batch'),
      headers: _headers,
      body: jsonEncode({
        'userId': userId,
        'games': games.map((g) => g.toJson()).toList(),
      }),
    );

    return _handleResponse(response);
  }

  // ============== Analytics (Data-Driven) ==============

  /// Track event for analytics
  Future<void> trackEvent(
    String eventName,
    Map<String, dynamic> properties,
  ) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/analytics/track'),
        headers: _headers,
        body: jsonEncode({
          'event': eventName,
          'properties': properties,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      // Don't fail on analytics errors
      print('Analytics error: $e');
    }
  }

  /// Get A/B test variant
  Future<String> getABTestVariant(String testName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ab-test/$testName'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return data['variant'];
  }

  // ============== Notifications ==============

  /// Register FCM token
  Future<void> registerPushToken(String token, String platform) async {
    await http.post(
      Uri.parse('$baseUrl/notifications/register'),
      headers: _headers,
      body: jsonEncode({
        'token': token,
        'platform': platform, // 'ios' or 'android'
      }),
    );
  }

  /// Get user notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data['notifications']);
  }

  // ============== Helper Methods ==============

  /// Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Handle API response
  /// [2025-11-18 Feature] Enhanced with detailed logging for error diagnosis
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('[API._handleResponse] Processing response with status ${response.statusCode}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[API._handleResponse] Success status code, decoding JSON');
      try {
        final decoded = jsonDecode(response.body);
        print('[API._handleResponse] JSON decoded successfully: ${decoded.keys}');
        return decoded;
      } catch (e) {
        print('[API._handleResponse] JSON decode error: $e');
        print('[API._handleResponse] Raw body: ${response.body}');
        rethrow;
      }
    } else if (response.statusCode == 401) {
      print('[API._handleResponse] 401 Unauthorized - clearing auth token');
      _authToken = null;
      throw ApiException('Unauthorized - Please log in again', 401);
    } else if (response.statusCode == 403) {
      print('[API._handleResponse] 403 Forbidden');
      throw ApiException('Access forbidden', 403);
    } else if (response.statusCode == 404) {
      print('[API._handleResponse] 404 Not Found');
      throw ApiException('Resource not found - Check API endpoint', 404);
    } else if (response.statusCode >= 500) {
      print('[API._handleResponse] ${response.statusCode} Server Error');
      print('[API._handleResponse] Response body: ${response.body}');
      throw ApiException('Server error - Please try again later', response.statusCode);
    } else {
      print('[API._handleResponse] Error status ${response.statusCode}');
      print('[API._handleResponse] Response body: ${response.body}');
      
      try {
        final error = jsonDecode(response.body);
        print('[API._handleResponse] Error JSON: $error');
        final message = error['message'] ?? error['error'] ?? 'Unknown error';
        print('[API._handleResponse] Error message: $message');
        throw ApiException(message, response.statusCode);
      } catch (e) {
        if (e is ApiException) rethrow;
        print('[API._handleResponse] Could not parse error JSON: $e');
        throw ApiException('Request failed: ${response.body}', response.statusCode);
      }
    }
  }

  /// Check if authenticated
  bool get isAuthenticated => _authToken != null;
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
