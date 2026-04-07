/// Sealed Payload Validator
///
/// Handles signature validation and persistence of sealed payloads.
/// Ensures clients cannot tamper with game challenges.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../games/contracts/deterministic_game_contract.dart';
import 'app_logger.dart';

class SealedPayloadValidator {
  /// Secret key for HMAC validation (provided by app configuration)
  /// In production, this should come from build config or API
  final String _hmacSecret;

  SealedPayloadValidator({required String hmacSecret}) : _hmacSecret = hmacSecret;

  /// Validate a sealed payload signature
  ///
  /// Returns true if signature is valid and payload hasn't been tampered with.
  /// Returns false if signature is invalid or payload has expired.
  bool validateSignature(SealedPayload payload) {
    // Check expiration first
    if (payload.isExpired) {
      AppLogger.warning('Sealed payload expired: ${payload.gameId}');
      return false;
    }

    // Compute expected signature
    final expectedSignature = _computeSignature(
      gameId: payload.gameId,
      seed: payload.seed,
      config: payload.config,
      schemaVersion: payload.schemaVersion,
    );

    // Constant-time comparison to prevent timing attacks
    final isValid = _constantTimeEquals(
      payload.signature,
      expectedSignature,
    );

    if (!isValid) {
      AppLogger.warning(
        'Invalid signature for sealed payload: ${payload.gameId}',
      );
    }

    return isValid;
  }

  /// Compute the HMAC signature for payload verification
  ///
  /// This is what the server sends, and what the client uses to verify.
  /// Format: HMAC-SHA256(secret, gameId|seed|config|schemaVersion)
  String _computeSignature({
    required String gameId,
    required String seed,
    required Map<String, dynamic> config,
    required int schemaVersion,
  }) {
    // Create canonical string representation
    final configJson = jsonEncode(config);
    final message = '$gameId|$seed|$configJson|$schemaVersion';

    // Compute HMAC-SHA256
    final hmac = Hmac(sha256, utf8.encode(_hmacSecret));
    final digest = hmac.convert(utf8.encode(message));

    // Return as base64 for easy transmission
    return base64Encode(digest.bytes);
  }

  /// Constant-time string comparison to prevent timing attacks
  ///
  /// Returns true if both strings are equal.
  /// Takes the same amount of time regardless of where they differ.
  bool _constantTimeEquals(String a, String b) {
    // Ensure both strings are the same length to prevent early exit
    if (a.length != b.length) {
      return false;
    }

    var result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  /// Validate that metrics are within plausible bounds
  ///
  /// This is a client-side sanity check before submission.
  /// Server does the authoritative validation.
  bool validateMetricsBounds(GameMetrics metrics) {
    try {
      final accuracy = metrics.metrics['accuracy'];
      final timeMs = metrics.metrics['timeMs'];
      final mistakes = metrics.metrics['mistakes'];

      // Validate accuracy is 0-1
      if (accuracy is! num || accuracy < 0 || accuracy > 1) {
        AppLogger.warning('Invalid accuracy metric: $accuracy');
        return false;
      }

      // Validate timeMs is positive
      if (timeMs is! int || timeMs < 0) {
        AppLogger.warning('Invalid timeMs metric: $timeMs');
        return false;
      }

      // Validate mistakes is non-negative
      if (mistakes is! int || mistakes < 0) {
        AppLogger.warning('Invalid mistakes metric: $mistakes');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Error validating metric bounds: $e');
      return false;
    }
  }
}

/// Extension for SealedPayload to support localStorage
extension SealedPayloadPersistence on SealedPayload {
  /// Key for storing in local database
  String get storageKey => 'sealed_payload_$gameId';

  /// Create from stored JSON
  static SealedPayload? fromStorageJson(Map<String, dynamic> json) {
    try {
      return SealedPayload.fromJson(json);
    } catch (e) {
      AppLogger.error('Failed to deserialize sealed payload: $e');
      return null;
    }
  }
}
