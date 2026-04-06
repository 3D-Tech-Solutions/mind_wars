/// Notification preferences for Activity Hub
/// Allows users to control which events trigger notifications

class NotificationPreferences {
  bool notifyOnGameCompletion;
  bool notifyOnAdminChanges;
  bool notifyOnPlayerJoined;
  bool notifyOnChatMessage;

  bool muteDuringHours;
  String muteStart; // Format: "HH:MM" (e.g., "22:00")
  String muteEnd; // Format: "HH:MM" (e.g., "08:00")

  NotificationPreferences({
    this.notifyOnGameCompletion = true,
    this.notifyOnAdminChanges = true,
    this.notifyOnPlayerJoined = false,
    this.notifyOnChatMessage = true,
    this.muteDuringHours = true,
    this.muteStart = "22:00",
    this.muteEnd = "08:00",
  });

  Map<String, dynamic> toJson() => {
        'notify_on_game_completion': notifyOnGameCompletion,
        'notify_on_admin_changes': notifyOnAdminChanges,
        'notify_on_player_joined': notifyOnPlayerJoined,
        'notify_on_chat_message': notifyOnChatMessage,
        'mute_during_hours': muteDuringHours,
        'mute_start': muteStart,
        'mute_end': muteEnd,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      notifyOnGameCompletion: json['notify_on_game_completion'] ?? true,
      notifyOnAdminChanges: json['notify_on_admin_changes'] ?? true,
      notifyOnPlayerJoined: json['notify_on_player_joined'] ?? false,
      notifyOnChatMessage: json['notify_on_chat_message'] ?? true,
      muteDuringHours: json['mute_during_hours'] ?? true,
      muteStart: json['mute_start'] ?? "22:00",
      muteEnd: json['mute_end'] ?? "08:00",
    );
  }

  /// Check if we're currently in quiet hours
  bool isInQuietHours() {
    if (!muteDuringHours) return false;

    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final currentTime = hour * 100 + minute; // Convert to HHMM format

    final startParts = muteStart.split(':');
    final startTime = int.parse(startParts[0]) * 100 + int.parse(startParts[1]);

    final endParts = muteEnd.split(':');
    final endTime = int.parse(endParts[0]) * 100 + int.parse(endParts[1]);

    // Handle case where quiet hours span midnight (e.g., 22:00 to 08:00)
    if (startTime > endTime) {
      return currentTime >= startTime || currentTime < endTime;
    }

    return currentTime >= startTime && currentTime < endTime;
  }
}
