/// Chat message model for Mind War Activity Hub
/// Supports three message types: player_message, game_event, system_event

class ChatMessage {
  final String id;
  final String type; // 'player_message', 'game_event', 'system_event'
  final String? subtype; // For system events
  final String mindWarId;
  final DateTime timestamp;
  final String playerId;
  final String displayName;

  // For player messages
  final String? content;

  // For game events
  final String? gameName;
  final int? score;
  final String? timeTaken;
  final int? rank;
  final int? totalPlayers;
  final bool newPersonalBest;

  // For system events
  final String? adminId;
  final String? adminName;
  final String? settingName;
  final dynamic oldValue;
  final dynamic newValue;
  final List<String>? playerNames;

  ChatMessage({
    required this.id,
    required this.type,
    this.subtype,
    required this.mindWarId,
    required this.timestamp,
    required this.playerId,
    required this.displayName,
    this.content,
    this.gameName,
    this.score,
    this.timeTaken,
    this.rank,
    this.totalPlayers,
    this.newPersonalBest = false,
    this.adminId,
    this.adminName,
    this.settingName,
    this.oldValue,
    this.newValue,
    this.playerNames,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      type: json['type'],
      subtype: json['subtype'],
      mindWarId: json['mind_war_id'],
      timestamp: DateTime.parse(json['timestamp']),
      playerId: json['player_id'],
      displayName: json['display_name'],
      content: json['content'],
      gameName: json['game_name'],
      score: json['score'],
      timeTaken: json['time_taken'],
      rank: json['rank'],
      totalPlayers: json['total_players'],
      newPersonalBest: json['newPersonalBest'] ?? false,
      adminId: json['admin_id'],
      adminName: json['admin_name'],
      settingName: json['setting_name'],
      oldValue: json['old_value'],
      newValue: json['new_value'],
      playerNames: List<String>.from(json['players'] ?? []),
    );
  }

  /// Format game event as human-readable string
  /// Example: "🎮 Emma finished Logic Duel - 2:14 • Personal best! 🔥 • 2nd place"
  String formatAsGameEvent() {
    if (type != 'game_event') return '';

    final rankStr = rank == 1
        ? "🥇 1st place"
        : rank == 2
            ? "🥈 2nd place"
            : rank == 3
                ? "🥉 3rd place"
                : "🎯 ${_ordinalize(rank ?? 0)} place";

    final pb = newPersonalBest ? "• Personal best! 🔥" : "";

    final parts = ["🎮 $displayName finished $gameName - $timeTaken"];
    if (pb.isNotEmpty) parts.add(pb);
    parts.add(rankStr);

    return parts.join(" ");
  }

  /// Format system event as human-readable string
  String formatAsSystemEvent() {
    if (type != 'system_event') return '';

    switch (subtype) {
      case 'admin_setting_changed':
        return "⚙️ $adminName updated $settingName: $oldValue → $newValue";
      case 'player_joined':
        return "➕ $displayName joined the mind war";
      case 'mind_war_started':
        return "🚀 Mind War Round 1 started! Players: ${playerNames?.join(', ')}";
      case 'mind_war_ended':
        return "🏆 Mind War ended! Winner: $displayName";
      default:
        return "";
    }
  }

  String _ordinalize(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) return "${number}th";
    return switch (number % 10) {
      1 => "${number}st",
      2 => "${number}nd",
      3 => "${number}rd",
      _ => "${number}th",
    };
  }
}
