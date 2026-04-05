/**
 * Avatar Cache Service
 * Offline-first avatar caching for Mind Wars gameplay
 *
 * Strategy:
 * 1. Download avatar image on first use
 * 2. Store locally with checksum in filename
 * 3. Validate checksum on load (skip redownload if match)
 * 4. Return local path for instant display during games
 * 5. Auto-cleanup old versions when checksum changes
 */

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AvatarCacheService {
  static const String _cacheDir = 'avatars';

  /// Get local cache path for an avatar
  /// Returns path if cached and valid, null if not cached
  Future<String?> getCachedAvatarPath(
    String userId,
    String? checksum,
  ) async {
    if (userId.isEmpty || checksum == null || checksum.isEmpty) {
      return null;
    }

    try {
      final cacheDir = await _getAvatarCacheDir();
      final filename = _buildCacheFilename(userId, checksum);
      final file = File('${cacheDir.path}/$filename');

      if (await file.exists()) {
        print('[AvatarCache] Cache hit: $filename');
        return file.path;
      }

      print('[AvatarCache] Cache miss for $userId (expected: $filename)');
      return null;
    } catch (e) {
      print('[AvatarCache] Error checking cache: $e');
      return null;
    }
  }

  /// Download and cache an avatar image
  /// Returns local file path on success, null on failure
  Future<String?> downloadAndCacheAvatar(
    String userId,
    String avatarUrl,
    String? checksum,
  ) async {
    if (userId.isEmpty || avatarUrl.isEmpty) {
      return null;
    }

    try {
      print('[AvatarCache] Downloading avatar: $avatarUrl');

      // Check if already cached
      if (checksum != null && checksum.isNotEmpty) {
        final cached = await getCachedAvatarPath(userId, checksum);
        if (cached != null) {
          print('[AvatarCache] Avatar already cached');
          return cached;
        }
      }

      // Download image
      final response = await http.get(Uri.parse(avatarUrl)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode != 200) {
        print('[AvatarCache] Download failed: ${response.statusCode}');
        return null;
      }

      // Save to cache
      final cacheDir = await _getAvatarCacheDir();
      final filename = _buildCacheFilename(userId, checksum);
      final file = File('${cacheDir.path}/$filename');

      await file.writeAsBytes(response.bodyBytes);
      print('[AvatarCache] Cached avatar: $filename (${response.bodyBytes.length} bytes)');

      // Cleanup old versions of this user's avatar
      await _cleanupOldAvatars(userId, filename);

      return file.path;
    } catch (e) {
      print('[AvatarCache] Error downloading avatar: $e');
      return null;
    }
  }

  /// Preload avatar cache (called on app startup)
  /// Ensures frequently-used avatars are cached
  Future<void> preloadAvatars(List<Map<String, String?>> avatars) async {
    print('[AvatarCache] Preloading ${avatars.length} avatars...');
    int cached = 0;

    for (final avatar in avatars) {
      final userId = avatar['userId'];
      final url = avatar['url'];
      final checksum = avatar['checksum'];

      if (userId == null || url == null) continue;

      // Check if already cached
      final cached_path = await getCachedAvatarPath(userId, checksum);
      if (cached_path != null) {
        cached++;
        continue;
      }

      // Download in background without blocking
      unawaited(downloadAndCacheAvatar(userId, url, checksum));
    }

    print('[AvatarCache] Preload complete: $cached already cached');
  }

  /// Clear all avatar cache
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getAvatarCacheDir();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('[AvatarCache] Cache cleared');
      }
    } catch (e) {
      print('[AvatarCache] Error clearing cache: $e');
    }
  }

  /// Get cache directory, creating if needed
  Future<Directory> _getAvatarCacheDir() async {
    final appCacheDir = await getApplicationCacheDirectory();
    final avatarCacheDir = Directory('${appCacheDir.path}/$_cacheDir');

    if (!await avatarCacheDir.exists()) {
      await avatarCacheDir.create(recursive: true);
    }

    return avatarCacheDir;
  }

  /// Build cache filename from userId and checksum
  String _buildCacheFilename(String userId, String? checksum) {
    if (checksum == null || checksum.isEmpty) {
      return '${userId}_no-checksum.jpg';
    }
    return '${userId}_$checksum.jpg';
  }

  /// Cleanup old avatar versions for a user
  /// Keeps only the most recent version (current checksum)
  Future<void> _cleanupOldAvatars(String userId, String currentFilename) async {
    try {
      final cacheDir = await _getAvatarCacheDir();
      final files = cacheDir.listSync();

      for (final file in files) {
        if (file is File) {
          final filename = file.path.split('/').last;
          // Delete if filename starts with userId but doesn't match current
          if (filename.startsWith('$userId\_') && filename != currentFilename) {
            await file.delete();
            print('[AvatarCache] Cleaned up old avatar: $filename');
          }
        }
      }
    } catch (e) {
      print('[AvatarCache] Error cleaning up old avatars: $e');
    }
  }
}

/// Extension to allow unawaited calls
void unawaited(Future<void> future) {}
