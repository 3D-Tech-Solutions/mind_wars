import 'package:flutter/material.dart';
import 'package:mind_wars/models/chat_message.dart';
import 'package:mind_wars/models/notification_preferences.dart';
import 'package:mind_wars/services/multiplayer_service.dart';

/// Provider for managing Activity Hub state and Socket.io subscriptions
class ChatProvider extends ChangeNotifier {
  final MultiplayerService multiplayerService;

  // Messages per mind war (chronological order)
  final Map<String, List<ChatMessage>> _messages = {};

  // Unread counts per mind war
  final Map<String, int> _unreadCounts = {};

  // Notification preferences
  late NotificationPreferences _notificationPrefs;

  // Currently subscribed mind war (for unsubscription on dispose)
  String? _activeSubscription;

  ChatProvider({required this.multiplayerService}) {
    _notificationPrefs = NotificationPreferences();
  }

  /// Get all messages for a mind war (chronological)
  List<ChatMessage> getMessages(String mindWarId) {
    return _messages[mindWarId] ?? [];
  }

  /// Get unread count for a mind war
  int getUnreadCount(String mindWarId) {
    return _unreadCounts[mindWarId] ?? 0;
  }

  /// Add a message to the feed (from WebSocket)
  void addMessage(String mindWarId, ChatMessage msg) {
    _messages.putIfAbsent(mindWarId, () => []).add(msg);
    _incrementUnreadCount(mindWarId);

    // Check if should notify
    if (shouldNotify(msg)) {
      // TODO: Show toast/banner notification
    }

    notifyListeners();
  }

  /// Clear unread count when user opens chat
  void clearUnreadCount(String mindWarId) {
    _unreadCounts[mindWarId] = 0;
    notifyListeners();
  }

  /// Send a player message
  Future<void> sendMessage({
    required String mindWarId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    multiplayerService.emit('chat:message', {
      'mind_war_id': mindWarId,
      'content': content.trim(),
    });
  }

  /// Subscribe to a mind war's chat
  void subscribeToChatForMindWar(String mindWarId) {
    // Unsubscribe from previous if any
    if (_activeSubscription != null && _activeSubscription != mindWarId) {
      unsubscribeFromChat();
    }

    _activeSubscription = mindWarId;
    clearUnreadCount(mindWarId);

    // Listen for chat messages
    multiplayerService.on('chat:message', (data) {
      try {
        final msg = ChatMessage.fromJson(data as Map<String, dynamic>);
        addMessage(mindWarId, msg);
      } catch (e) {
        print('Error parsing chat message: $e');
      }
    });

    notifyListeners();
  }

  /// Unsubscribe from chat
  void unsubscribeFromChat() {
    if (_activeSubscription != null) {
      multiplayerService.off('chat:message');
      _activeSubscription = null;
      notifyListeners();
    }
  }

  /// Check if should notify for this event
  bool shouldNotify(ChatMessage msg) {
    if (_notificationPrefs.isInQuietHours()) {
      return false;
    }

    switch (msg.type) {
      case 'player_message':
        return _notificationPrefs.notifyOnChatMessage;
      case 'game_event':
        return _notificationPrefs.notifyOnGameCompletion;
      case 'system_event':
        if (msg.subtype == 'admin_setting_changed') {
          return _notificationPrefs.notifyOnAdminChanges;
        }
        if (msg.subtype == 'player_joined') {
          return _notificationPrefs.notifyOnPlayerJoined;
        }
        break;
    }
    return true;
  }

  /// Get current notification preferences
  NotificationPreferences get notificationPrefs => _notificationPrefs;

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
    NotificationPreferences prefs,
  ) async {
    _notificationPrefs = prefs;
    // TODO: Save to backend API
    notifyListeners();
  }

  /// Clear all messages for a mind war (when it's deleted)
  void clearMessagesForMindWar(String mindWarId) {
    _messages.remove(mindWarId);
    _unreadCounts.remove(mindWarId);
    notifyListeners();
  }

  void _incrementUnreadCount(String mindWarId) {
    _unreadCounts[mindWarId] = (_unreadCounts[mindWarId] ?? 0) + 1;
  }

  @override
  void dispose() {
    unsubscribeFromChat();
    super.dispose();
  }
}
