/// Build configuration utilities
/// 
/// This file helps identify which build variant is running
/// and provides build-specific configurations.

import 'package:flutter/foundation.dart';

class BuildConfig {
  // Build flavor detection
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  // Build type
  static bool get isProduction => flavor == 'production';
  static bool get isAlpha => flavor == 'alpha';
  /// [2026-03-31 Integration] Local dev flavor for testing against a locally
  /// running Docker backend (docker-compose up in backend/).
  /// Run with: flutter run --dart-define=FLAVOR=local
  static bool get isLocal => flavor == 'local';
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;

  // App identification
  static String get appName {
    if (isAlpha) return 'Mind Wars Alpha';
    if (isLocal) return 'Mind Wars (Local)';
    return 'Mind Wars';
  }

  static String get packageName {
    const basePackage = 'com.mindwars.app';
    if (isAlpha) return '$basePackage.alpha';
    return basePackage;
  }

  // Build information
  static String get buildType {
    if (isLocal) return 'Local Dev';
    if (isAlpha) return 'Alpha';
    if (isDebug) return 'Debug';
    return 'Production';
  }

  static String get versionSuffix {
    if (isAlpha) return '-alpha';
    if (isLocal) return '-local';
    return '';
  }

  // Feature flags based on build type
  static bool get enableDebugLogging => isDebug || isAlpha || isLocal;
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => isProduction || isAlpha;
  
  // API endpoints can be configured per flavor
  /// [2026-03-31 Integration] Added 'local' flavor pointing at the Docker
  /// Compose stack.
  ///
  /// Usage:
  ///   Physical device:  --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=192.168.x.x
  ///   Android emulator: --dart-define=FLAVOR=local  (uses 10.0.2.2 automatically)
  ///   iOS simulator:    --dart-define=FLAVOR=local  (uses localhost automatically)
  static const String _localHostOverride = String.fromEnvironment(
    'LOCAL_HOST',
    defaultValue: '',
  );

  static String get _localApiHost {
    if (_localHostOverride.isNotEmpty) return _localHostOverride;
    // Android emulator routes 10.0.2.2 → host machine localhost
    // iOS Simulator and desktop can use localhost directly
    return '10.0.2.2';
  }

  static String get apiBaseUrl {
    if (isLocal) {
      // Nginx gateway exposes both REST and Socket.io on port 4000.
      // For direct API access without nginx: http://$_localApiHost:3000
      return 'http://$_localApiHost:3000';
    }
    if (isAlpha) {
      return 'https://api-alpha.mindwars.app';
    }
    return 'https://api.mindwars.app';
  }

  static String get wsBaseUrl {
    if (isLocal) {
      return 'http://$_localApiHost:3001';
    }
    // [2025-11-18 Feature] Updated Socket.io endpoint to use public domain
    // Uses war.e-mothership.com:4000 for WebSocket connections
    // Direct access without ADB port forwarding
    return 'http://war.e-mothership.com:4000';
  }

  // Display build information
  static String get buildInfo {
    final buffer = StringBuffer();
    buffer.writeln('Build Type: $buildType');
    buffer.writeln('App Name: $appName');
    buffer.writeln('Package: $packageName');
    buffer.writeln('API URL: $apiBaseUrl');
    buffer.writeln('WS URL: $wsBaseUrl');
    buffer.writeln('Debug Mode: ${isDebug ? "Yes" : "No"}');
    buffer.writeln('Release Mode: ${isRelease ? "Yes" : "No"}');
    return buffer.toString();
  }

  // Print build info to console (useful for debugging)
  static void printBuildInfo() {
    if (enableDebugLogging) {
      debugPrint('=== Mind Wars Build Info ===');
      debugPrint(buildInfo);
      debugPrint('===========================');
    }
  }
}
