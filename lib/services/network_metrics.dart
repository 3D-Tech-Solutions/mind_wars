import 'dart:collection';

/// Represents a single network request for debugging and metrics.
class NetworkRequestMetric {
  final String url;
  final String method;
  final int statusCode;
  final Duration duration;
  final DateTime timestamp;

  NetworkRequestMetric({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.duration,
    required this.timestamp,
  });
}

/// A singleton registry to track global network request metrics.
class NetworkMetrics {
  static final NetworkMetrics _instance = NetworkMetrics._internal();
  factory NetworkMetrics() => _instance;
  NetworkMetrics._internal();

  int totalRequests = 0;
  int successfulRequests = 0;
  int failedRequests = 0;
  Duration totalDuration = Duration.zero;

  final Queue<NetworkRequestMetric> _recentRequests = Queue<NetworkRequestMetric>();
  static const int _maxRecentRequests = 50; // Keep the last 50 requests

  /// Call this method from your ApiService or Http Interceptor
  void recordRequest(String url, String method, int statusCode, Duration duration) {
    totalRequests++;
    if (statusCode >= 200 && statusCode < 300) {
      successfulRequests++;
    } else {
      failedRequests++;
    }
    totalDuration += duration;

    _recentRequests.addFirst(
      NetworkRequestMetric(
        url: url,
        method: method,
        statusCode: statusCode,
        duration: duration,
        timestamp: DateTime.now(),
      ),
    );

    if (_recentRequests.length > _maxRecentRequests) {
      _recentRequests.removeLast();
    }
  }

  /// Formats the metrics into a readable string for the debug export.
  String getExportData() {
    final buffer = StringBuffer();
    buffer.writeln('Total Requests: $totalRequests');
    buffer.writeln('Successful: $successfulRequests');
    buffer.writeln('Failed: $failedRequests');
    
    final avgMs = totalRequests > 0 ? (totalDuration.inMilliseconds / totalRequests).round() : 0;
    buffer.writeln('Average Latency: ${avgMs}ms');
    buffer.writeln('\nRecent Requests (up to $_maxRecentRequests):');
    
    if (_recentRequests.isEmpty) {
      buffer.writeln('  No requests recorded yet.');
    } else {
      for (final req in _recentRequests) {
        final time = '${req.timestamp.hour.toString().padLeft(2, '0')}:${req.timestamp.minute.toString().padLeft(2, '0')}:${req.timestamp.second.toString().padLeft(2, '0')}';
        buffer.writeln('  [$time] ${req.method} ${req.statusCode} - ${req.duration.inMilliseconds}ms - ${req.url}');
      }
    }
    return buffer.toString();
  }
}