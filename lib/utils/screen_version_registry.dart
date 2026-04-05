import 'package:flutter/material.dart';

/// Metadata for individual screen version tracking
class ScreenVersion {
  final String name;
  final String version;
  final String lastUpdated;
  final String description;

  const ScreenVersion({
    required this.name,
    required this.version,
    required this.lastUpdated,
    this.description = '',
  });
}

/// Global registry to track screen versions and observe route changes.
class ScreenVersionRegistry extends NavigatorObserver {
  // Singleton pattern
  static final ScreenVersionRegistry _instance = ScreenVersionRegistry._internal();
  factory ScreenVersionRegistry() => _instance;
  ScreenVersionRegistry._internal();

  final Map<String, ScreenVersion> _registry = {};
  
  /// Observable for the current active route name
  final ValueNotifier<String?> currentRoute = ValueNotifier<String?>(null);

  /// Register metadata for a specific route path
  void register(String routeName, ScreenVersion versionInfo) {
    _registry[routeName] = versionInfo;
  }

  /// Retrieve version metadata for a route
  ScreenVersion? getVersion(String? routeName) {
    if (routeName == null) return null;
    return _registry[routeName];
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _updateRoute(previousRoute);
  }
  
  void _updateRoute(Route<dynamic>? route) {
    // Skip dialogs/bottom sheets which often don't have named routes
    if (route is PageRoute && route.settings.name != null) {
      currentRoute.value = route.settings.name;
    }
  }
}