/**
 * Connectivity Service - Diagnoses network connectivity to backend servers
 *
 * [2026-04-03 Feature] Added for alpha testing to help testers diagnose
 * connection issues before attempting multiplayer.
 *
 * Tests:
 * - API server health endpoint
 * - WebSocket server connectivity
 * - Network availability
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/build_config.dart';
import 'app_logger.dart';

class ConnectivityStatus {
  final bool apiHealthy;
  final bool wsConnectable;
  final bool networkAvailable;
  final String apiUrl;
  final String wsUrl;
  final String? apiError;
  final String? wsError;
  final DateTime testedAt;

  ConnectivityStatus({
    required this.apiHealthy,
    required this.wsConnectable,
    required this.networkAvailable,
    required this.apiUrl,
    required this.wsUrl,
    this.apiError,
    this.wsError,
    required this.testedAt,
  });

  bool get allHealthy => apiHealthy && wsConnectable && networkAvailable;

  String get summary {
    final parts = <String>[];
    if (apiHealthy) {
      parts.add('✓ API');
    } else {
      parts.add('✗ API');
    }
    if (wsConnectable) {
      parts.add('✓ WebSocket');
    } else {
      parts.add('✗ WebSocket');
    }
    if (networkAvailable) {
      parts.add('✓ Network');
    } else {
      parts.add('✗ Network');
    }
    return parts.join(' | ');
  }
}

class ConnectivityService {
  static const Duration _timeout = Duration(seconds: 5);

  /// Test connectivity to all backend services
  static Future<ConnectivityStatus> testConnectivity() async {
    final apiUrl = BuildConfig.apiBaseUrl;
    final wsUrl = BuildConfig.wsBaseUrl;

    AppLogger.info('Testing API: $apiUrl', source: 'connectivity');
    AppLogger.info('Testing WebSocket: $wsUrl', source: 'connectivity');

    // Test API health
    final (apiHealthy, apiError) = await _testApiHealth(apiUrl);

    // Test WebSocket connectivity
    final (wsConnectable, wsError) = await _testWebSocketConnectivity(wsUrl);

    AppLogger.info(
      'Connectivity test complete - API: ${apiHealthy ? '✓' : '✗'}, WebSocket: ${wsConnectable ? '✓' : '✗'}',
      source: 'connectivity',
    );

    return ConnectivityStatus(
      apiHealthy: apiHealthy,
      wsConnectable: wsConnectable,
      networkAvailable: apiHealthy || wsConnectable,
      apiUrl: apiUrl,
      wsUrl: wsUrl,
      apiError: apiError,
      wsError: wsError,
      testedAt: DateTime.now(),
    );
  }

  /// Test if API server is responding to health checks
  static Future<(bool, String?)> _testApiHealth(String apiUrl) async {
    try {
      final healthUrl = '$apiUrl/health';
      AppLogger.debug('Testing API health: $healthUrl', source: 'connectivity');

      final response = await http.get(
        Uri.parse(healthUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        AppLogger.info('API healthy: ${response.statusCode}', source: 'connectivity');
        return (true, null);
      } else {
        final error =
            'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        AppLogger.warning('API error: $error', source: 'connectivity');
        return (false, error);
      }
    } on TimeoutException {
      const error = 'Request timeout (5s) - server not responding';
      AppLogger.warning('API timeout: $error', source: 'connectivity');
      return (false, error);
    } catch (e) {
      AppLogger.error('API error: $e', source: 'connectivity', exception: e);
      return (false, e.toString());
    }
  }

  /// Test if WebSocket server is connectable
  static Future<(bool, String?)> _testWebSocketConnectivity(
      String wsUrl) async {
    late IO.Socket socket;
    final completer = Completer<(bool, String?)>();
    final timer = Timer(_timeout, () {
      if (!completer.isCompleted) {
        AppLogger.warning('WebSocket timeout', source: 'connectivity');
        completer.complete((false, 'Connection timeout (5s)'));
        socket.disconnect();
      }
    });

    try {
      AppLogger.debug('Connecting to WebSocket: $wsUrl', source: 'connectivity');
      socket = IO.io(wsUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': false,
        'reconnectionDelay': 0,
      });

      socket.onConnect((_) {
        AppLogger.info('WebSocket connected', source: 'connectivity');
        if (!completer.isCompleted) {
          completer.complete((true, null));
        }
        socket.disconnect();
      });

      socket.onConnectError((error) {
        AppLogger.warning('WebSocket error: $error', source: 'connectivity');
        if (!completer.isCompleted) {
          completer.complete((false, error.toString()));
        }
      });

      socket.onError((error) {
        AppLogger.warning('WebSocket error: $error', source: 'connectivity');
        if (!completer.isCompleted) {
          completer.complete((false, error.toString()));
        }
      });

      return await completer.future;
    } catch (e) {
      AppLogger.error('WebSocket exception: $e', source: 'connectivity', exception: e);
      return (false, e.toString());
    } finally {
      timer.cancel();
      try {
        socket.disconnect();
      } catch (_) {}
    }
  }
}
