/**
 * App Logger Service - Centralized logging for alpha debugging
 *
 * [2026-04-03 Feature] Captures all app logs and makes them accessible
 * in the debug panel for easy troubleshooting.
 *
 * Usage:
 *   AppLogger.info('message');
 *   AppLogger.error('error message', exception);
 *   AppLogger.debug('debug info');
 *   AppLogger.warning('warning message');
 */

import 'dart:async';
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final String? source;
  final Object? exception;
  final StackTrace? stackTrace;

  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
    this.source,
    this.exception,
    this.stackTrace,
  });

  String get formattedTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';

  String get levelName => level.toString().split('.').last.toUpperCase();

  String get formatted {
    final sourceStr = source != null ? ' [$source]' : '';
    return '[$formattedTime] $levelName$sourceStr: $message';
  }

  String get fullText {
    final buffer = StringBuffer(formatted);
    if (exception != null) {
      buffer.writeln('\nException: $exception');
    }
    if (stackTrace != null) {
      buffer.writeln('\nStackTrace:\n$stackTrace');
    }
    return buffer.toString();
  }
}

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  static final List<LogEntry> _logs = [];
  static final StreamController<LogEntry> _logStream =
      StreamController<LogEntry>.broadcast();
  static const int _maxLogs = 1000;
  static bool _alphaMode = false;

  AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  /// Initialize the logger
  static void init({required bool alphaMode}) {
    _alphaMode = alphaMode;
    if (alphaMode) {
      debugPrint('[AppLogger] Initialized for alpha mode');
    }
  }

  /// Get all logs
  static List<LogEntry> getLogs() => List.unmodifiable(_logs);

  /// Get logs filtered by level
  static List<LogEntry> getLogsByLevel(LogLevel level) =>
      _logs.where((log) => log.level == level).toList();

  /// Get recent logs (last N entries)
  static List<LogEntry> getRecentLogs({int count = 100}) =>
      _logs.length > count ? _logs.sublist(_logs.length - count) : _logs;

  /// Clear all logs
  static void clearLogs() {
    _logs.clear();
    info('Logs cleared');
  }

  /// Stream of new log entries (for real-time display)
  static Stream<LogEntry> get logStream => _logStream.stream;

  /// Log an info message
  static void info(String message, {String? source}) {
    _addLog(LogEntry(
      message: message,
      level: LogLevel.info,
      timestamp: DateTime.now(),
      source: source,
    ));
  }

  /// Log a debug message
  static void debug(String message, {String? source}) {
    if (!_alphaMode) return; // Only log debug in alpha mode
    _addLog(LogEntry(
      message: message,
      level: LogLevel.debug,
      timestamp: DateTime.now(),
      source: source,
    ));
  }

  /// Log a warning
  static void warning(String message, {String? source, Object? exception}) {
    _addLog(LogEntry(
      message: message,
      level: LogLevel.warning,
      timestamp: DateTime.now(),
      source: source,
      exception: exception,
    ));
  }

  /// Log an error
  static void error(
    String message, {
    String? source,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _addLog(LogEntry(
      message: message,
      level: LogLevel.error,
      timestamp: DateTime.now(),
      source: source,
      exception: exception,
      stackTrace: stackTrace,
    ));
  }

  static void _addLog(LogEntry entry) {
    _logs.add(entry);

    // Keep only recent logs to avoid memory issues
    if (_logs.length > _maxLogs) {
      _logs.removeRange(0, _logs.length - _maxLogs);
    }

    // Print to console
    debugPrint(entry.formatted);

    // Broadcast to listeners
    _logStream.add(entry);
  }

  /// Export logs as text
  static String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('=== Mind Wars Debug Logs ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total entries: ${_logs.length}');
    buffer.writeln('');
    for (final log in _logs) {
      buffer.writeln(log.formatted);
    }
    return buffer.toString();
  }

  /// Dispose resources
  static void dispose() {
    _logStream.close();
  }
}

/// Convenience extension for logging
extension StringLogging on String {
  void logInfo({String? source}) => AppLogger.info(this, source: source);
  void logDebug({String? source}) => AppLogger.debug(this, source: source);
  void logWarning({String? source}) => AppLogger.warning(this, source: source);
  void logError({String? source, Object? exception}) =>
      AppLogger.error(this, source: source, exception: exception);
}
