/**
 * Core type definitions for Mind Wars
 */

/// Player status enum
enum PlayerStatus { active, idle, disconnected }

/// User model - represents authenticated user
///
/// username: Unique identifier (3-20 chars, set during profile setup)
/// displayName: Non-unique display name (optional, editable, shown in competitive contexts)
///
/// Display logic:
/// - If displayName differs from username: show "DisplayName (username)"
/// - Otherwise: show just username
class User {
  final String id;
  final String username;        // Unique identifier
  final String email;
  final String? displayName;     // Non-unique, editable display name
  final String? avatar;
  final String? avatarUrl;       // URL for uploaded custom avatar
  final String? avatarChecksum;  // MD5 checksum for cache validation
  final DateTime? createdAt;
  final int? level;
  final int? totalScore;
  final int? currentStreak;
  final int? longestStreak;
  final int? gamesPlayed;
  final int? gamesWon;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatar,
    this.avatarUrl,
    this.avatarChecksum,
    this.createdAt,
    this.level,
    this.totalScore,
    this.currentStreak,
    this.longestStreak,
    this.gamesPlayed,
    this.gamesWon,
  });

  /// Get display name for competitive contexts (Mind Wars, leaderboards, etc.)
  /// Shows "DisplayName (username)" if displayName differs from username
  String getCompetitiveDisplayName() {
    final display = displayName?.trim() ?? '';
    if (display.isNotEmpty && display != username) {
      return '$display ($username)';
    }
    return username;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'displayName': displayName,
        'avatar': avatar,
        'avatarUrl': avatarUrl,
        'avatarChecksum': avatarChecksum,
        'createdAt': createdAt?.toIso8601String(),
        'level': level,
        'totalScore': totalScore,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
      };
  
  factory User.fromJson(Map<String, dynamic> json) {
    // Debug: print response structure
    print('[User.fromJson] Parsing user data with keys: ${json.keys.toList()}');

    final id = json['id']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';
    final username = json['username']?.toString() ??
                    json['displayName']?.toString() ??
                    '';

    // Parse optional integer fields
    int? level;
    try {
      if (json['level'] != null) {
        level = int.parse(json['level'].toString());
      }
    } catch (e) {
      print('[User.fromJson] Error parsing level: $e');
    }

    int? totalScore;
    try {
      if (json['totalScore'] != null) {
        totalScore = int.parse(json['totalScore'].toString());
      }
    } catch (e) {
      print('[User.fromJson] Error parsing totalScore: $e');
    }

    int? currentStreak;
    try {
      if (json['currentStreak'] != null) {
        currentStreak = int.parse(json['currentStreak'].toString());
      }
    } catch (e) {
      print('[User.fromJson] Error parsing currentStreak: $e');
    }

    int? longestStreak;
    try {
      if (json['longestStreak'] != null) {
        longestStreak = int.parse(json['longestStreak'].toString());
      }
    } catch (e) {
      print('[User.fromJson] Error parsing longestStreak: $e');
    }

    int? gamesPlayed;
    try {
      if (json['gamesPlayed'] != null) {
        gamesPlayed = int.parse(json['gamesPlayed'].toString());
      }
    } catch (e) {
      print('[User.fromJson] Error parsing gamesPlayed: $e');
    }

    int? gamesWon;
    try {
      if (json['gamesWon'] != null) {
        gamesWon = int.parse(json['gamesWon'].toString());
      }
    } catch (e) {
      print('[User.fromJson] Error parsing gamesWon: $e');
    }

    DateTime? createdAt;
    try {
      if (json['createdAt'] != null) {
        createdAt = DateTime.parse(json['createdAt'].toString());
      }
    } catch (e) {
      print('[User.fromJson] Error parsing createdAt: $e');
    }

    print('[User.fromJson] Parsed - id: $id, email: $email, username: $username, level: $level, totalScore: $totalScore');

    return User(
      id: id,
      username: username,
      email: email,
      displayName: json['displayName']?.toString(),
      avatar: json['avatar']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      avatarChecksum: json['avatarChecksum']?.toString(),
      createdAt: createdAt,
      level: level,
      totalScore: totalScore,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
    );
  }
  
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatar,
    String? avatarUrl,
    String? avatarChecksum,
    DateTime? createdAt,
    int? level,
    int? totalScore,
    int? currentStreak,
    int? longestStreak,
    int? gamesPlayed,
    int? gamesWon,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarChecksum: avatarChecksum ?? this.avatarChecksum,
      createdAt: createdAt ?? this.createdAt,
      level: level ?? this.level,
      totalScore: totalScore ?? this.totalScore,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
    );
  }
}

/// Cognitive category enum
enum CognitiveCategory { memory, logic, attention, spatial, language }

/// Player model
class Player {
  final String id;
  final String username;
  final String? displayName;  // Non-unique, editable display name
  final String? avatar;
  final PlayerStatus status;
  final int score;
  final int streak;
  final List<Badge> badges;
  final DateTime lastActive;

  Player({
    required this.id,
    required this.username,
    this.displayName,
    this.avatar,
    required this.status,
    required this.score,
    required this.streak,
    required this.badges,
    required this.lastActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'avatar': avatar,
        'status': status.toString(),
        'score': score,
        'streak': streak,
        'badges': badges.map((b) => b.toJson()).toList(),
        'lastActive': lastActive.toIso8601String(),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        username: json['username'],
        displayName: json['displayName'],
        avatar: json['avatar'],
        status: PlayerStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => PlayerStatus.active,
        ),
        score: json['score'] ?? 0,
        streak: json['streak'] ?? 0,
        badges: (json['badges'] as List?)
                ?.map((b) => Badge.fromJson(b))
                .toList() ??
            [],
        lastActive: DateTime.parse(json['lastActive']),
      );
}

/// Badge model
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'earnedAt': earnedAt.toIso8601String(),
      };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        earnedAt: DateTime.parse(json['earnedAt']),
      );
}

/// Game lobby model
class GameLobby {
  final String id;
  final String name;
  final String hostId;
  final List<Player> players;
  final int maxPlayers;
  final Game? currentGame;
  final String status; // 'waiting', 'in-progress', 'completed'
  final DateTime createdAt;
  final String? lobbyCode; // Shareable lobby code (e.g., "FAMILY42")
  final bool isPrivate; // Private lobbies require code to join
  final int numberOfRounds; // Number of rounds to play
  final int votingPointsPerPlayer; // Points each player gets for voting
  final SkipRule skipRule; // Vote-to-skip rule (majority, unanimous, time_based)
  final int skipTimeLimitHours; // Time limit for time-based skip rule

  // Phase 2: War Configuration fields
  final String? difficulty;  // 'easy' | 'medium' | 'hard'
  final String? hintPolicy;  // 'disabled' | 'enabled' | 'assisted'
  final bool ranked;         // Ranked vs casual
  final bool payloadLocked;  // Is the immutable payload locked?

  GameLobby({
    required this.id,
    required this.name,
    required this.hostId,
    required this.players,
    required this.maxPlayers,
    this.currentGame,
    required this.status,
    required this.createdAt,
    this.lobbyCode,
    this.isPrivate = true,
    this.numberOfRounds = 3,
    this.votingPointsPerPlayer = 10,
    this.skipRule = SkipRule.majority,
    this.skipTimeLimitHours = 24,
    this.difficulty,
    this.hintPolicy,
    this.ranked = false,
    this.payloadLocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hostId': hostId,
        'players': players.map((p) => p.toJson()).toList(),
        'maxPlayers': maxPlayers,
        'currentGame': currentGame?.toJson(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'lobbyCode': lobbyCode,
        'isPrivate': isPrivate,
        'numberOfRounds': numberOfRounds,
        'votingPointsPerPlayer': votingPointsPerPlayer,
        'skipRule': skipRule.value,
        'skipTimeLimitHours': skipTimeLimitHours,
        'difficulty': difficulty,
        'hintPolicy': hintPolicy,
        'ranked': ranked,
        'payloadLocked': payloadLocked,
      };

  factory GameLobby.fromJson(Map<String, dynamic> json) => GameLobby(
        id: json['id'],
        name: json['name'],
        hostId: json['hostId'],
        players: (json['players'] as List?)
            ?.map((p) => Player.fromJson(p))
            .toList() ?? [],
        maxPlayers: json['maxPlayers'],
        currentGame: json['currentGame'] != null
            ? Game.fromJson(json['currentGame'])
            : null,
        status: json['status'],
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
        lobbyCode: json['code'] ?? json['lobbyCode'],
        isPrivate: json['isPrivate'] ?? true,
        numberOfRounds: json['totalRounds'] ?? json['numberOfRounds'] ?? 3,
        votingPointsPerPlayer: json['votingPointsPerPlayer'] ?? 10,
        skipRule: json['skipRule'] != null
            ? SkipRuleExtension.fromString(json['skipRule'])
            : SkipRule.majority,
        skipTimeLimitHours: json['skipTimeLimitHours'] ?? 24,
        difficulty: json['difficulty'],
        hintPolicy: json['hintPolicy'],
        ranked: json['ranked'] ?? false,
        payloadLocked: json['payloadLocked'] ?? false,
      );
  
  /// Create a copy of this lobby with updated values
  GameLobby copyWith({
    String? id,
    String? name,
    String? hostId,
    List<Player>? players,
    int? maxPlayers,
    Game? currentGame,
    String? status,
    DateTime? createdAt,
    String? lobbyCode,
    bool? isPrivate,
    int? numberOfRounds,
    int? votingPointsPerPlayer,
    SkipRule? skipRule,
    int? skipTimeLimitHours,
    String? difficulty,
    String? hintPolicy,
    bool? ranked,
    bool? payloadLocked,
  }) {
    return GameLobby(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      players: players ?? this.players,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentGame: currentGame ?? this.currentGame,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lobbyCode: lobbyCode ?? this.lobbyCode,
      isPrivate: isPrivate ?? this.isPrivate,
      numberOfRounds: numberOfRounds ?? this.numberOfRounds,
      votingPointsPerPlayer: votingPointsPerPlayer ?? this.votingPointsPerPlayer,
      skipRule: skipRule ?? this.skipRule,
      skipTimeLimitHours: skipTimeLimitHours ?? this.skipTimeLimitHours,
      difficulty: difficulty ?? this.difficulty,
      hintPolicy: hintPolicy ?? this.hintPolicy,
      ranked: ranked ?? this.ranked,
      payloadLocked: payloadLocked ?? this.payloadLocked,
    );
  }
  
  /// Check if current user is the host
  bool isHost(String userId) => hostId == userId;
  
  /// Check if lobby is full
  bool get isFull => players.length >= maxPlayers;
  
  /// Check if lobby can be joined
  bool get canJoin => status == 'waiting' && !isFull;
}

/// Game model
class Game {
  final String id;
  final String name;
  final CognitiveCategory category;
  final String description;
  final int minPlayers;
  final int maxPlayers;
  final int currentTurn;
  final String currentPlayerId;
  final Map<String, dynamic> state;
  final bool completed;

  // Phase 2 fields
  final String? mindWarId;           // Immutable payload ID
  final String? lobbyId;             // Parent lobby
  final int? roundNumber;            // Current round in sequence
  final int? gameIndex;              // Deterministic seed for game state
  final String? seed;                // Seed for pseudo-random generation
  final String? difficulty;          // Game difficulty level
  final String? hintPolicy;          // Hint availability
  final bool? ranked;                // Is this a ranked match?

  Game({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.minPlayers,
    required this.maxPlayers,
    required this.currentTurn,
    required this.currentPlayerId,
    required this.state,
    required this.completed,
    this.mindWarId,
    this.lobbyId,
    this.roundNumber,
    this.gameIndex,
    this.seed,
    this.difficulty,
    this.hintPolicy,
    this.ranked,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.toString(),
        'description': description,
        'minPlayers': minPlayers,
        'maxPlayers': maxPlayers,
        'currentTurn': currentTurn,
        'currentPlayerId': currentPlayerId,
        'state': state,
        'completed': completed,
        'mindWarId': mindWarId,
        'lobbyId': lobbyId,
        'roundNumber': roundNumber,
        'gameIndex': gameIndex,
        'seed': seed,
        'difficulty': difficulty,
        'hintPolicy': hintPolicy,
        'ranked': ranked,
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'],
        name: json['name'],
        category: CognitiveCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
          orElse: () => CognitiveCategory.logic,
        ),
        description: json['description'],
        minPlayers: json['minPlayers'] ?? 2,
        maxPlayers: json['maxPlayers'] ?? 2,
        currentTurn: json['currentTurn'] ?? 1,
        currentPlayerId: json['currentPlayerId'] ?? '',
        state: json['state'] ?? {},
        completed: json['completed'] ?? false,
        mindWarId: json['mindWarId'],
        lobbyId: json['lobbyId'],
        roundNumber: json['roundNumber'],
        gameIndex: json['gameIndex'],
        seed: json['seed'],
        difficulty: json['difficulty'],
        hintPolicy: json['hintPolicy'],
        ranked: json['ranked'],
      );
}

/// Chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String? emoji;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.emoji,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'emoji': emoji,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
        emoji: json['emoji'],
      );
}

/// Leaderboard entry model
class LeaderboardEntry {
  final String playerId;
  final String username;
  final int totalScore;
  final int gamesPlayed;
  final int wins;
  final int rank;
  final DateTime weekStartDate;

  LeaderboardEntry({
    required this.playerId,
    required this.username,
    required this.totalScore,
    required this.gamesPlayed,
    required this.wins,
    required this.rank,
    required this.weekStartDate,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'username': username,
        'totalScore': totalScore,
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'rank': rank,
        'weekStartDate': weekStartDate.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        playerId: json['playerId'],
        username: json['username'],
        totalScore: json['totalScore'],
        gamesPlayed: json['gamesPlayed'],
        wins: json['wins'],
        rank: json['rank'],
        weekStartDate: DateTime.parse(json['weekStartDate']),
      );
}

/// Offline game data model
class OfflineGameData {
  final String id;
  final String gameType;
  final CognitiveCategory category;
  final Map<String, dynamic> state;
  final int score;
  final bool completed;
  final DateTime timestamp;
  final bool synced;

  OfflineGameData({
    required this.id,
    required this.gameType,
    required this.category,
    required this.state,
    required this.score,
    required this.completed,
    required this.timestamp,
    required this.synced,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameType': gameType,
        'category': category.toString(),
        'state': state,
        'score': score,
        'completed': completed,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory OfflineGameData.fromJson(Map<String, dynamic> json) =>
      OfflineGameData(
        id: json['id'],
        gameType: json['gameType'],
        category: CognitiveCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
        ),
        state: json['state'],
        score: json['score'],
        completed: json['completed'],
        timestamp: DateTime.parse(json['timestamp']),
        synced: json['synced'],
      );
}

/// User progress model
class UserProgress {
  final String userId;
  final int level;
  final int totalScore;
  final int gamesPlayed;
  final int currentStreak;
  final int longestStreak;
  final List<Badge> badges;
  final DateTime lastPlayedDate;

  UserProgress({
    required this.userId,
    required this.level,
    required this.totalScore,
    required this.gamesPlayed,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
    required this.lastPlayedDate,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'level': level,
        'totalScore': totalScore,
        'gamesPlayed': gamesPlayed,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'badges': badges.map((b) => b.toJson()).toList(),
        'lastPlayedDate': lastPlayedDate.toIso8601String(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        userId: json['userId'],
        level: json['level'],
        totalScore: json['totalScore'],
        gamesPlayed: json['gamesPlayed'],
        currentStreak: json['currentStreak'],
        longestStreak: json['longestStreak'],
        badges: (json['badges'] as List)
            .map((b) => Badge.fromJson(b))
            .toList(),
        lastPlayedDate: DateTime.parse(json['lastPlayedDate']),
      );
}

/// Skip rule enum for vote-to-skip configuration
enum SkipRule {
  majority,    // 50% + 1 of eligible voters
  unanimous,   // 100% of eligible voters
  timeBased,   // Auto-skip after X hours
}

extension SkipRuleExtension on SkipRule {
  String get value {
    switch (this) {
      case SkipRule.majority:
        return 'majority';
      case SkipRule.unanimous:
        return 'unanimous';
      case SkipRule.timeBased:
        return 'time_based';
    }
  }

  String get displayName {
    switch (this) {
      case SkipRule.majority:
        return 'Majority (50%+1)';
      case SkipRule.unanimous:
        return 'Unanimous (100%)';
      case SkipRule.timeBased:
        return 'Time-Based';
    }
  }

  static SkipRule fromString(String value) {
    switch (value) {
      case 'majority':
        return SkipRule.majority;
      case 'unanimous':
        return SkipRule.unanimous;
      case 'time_based':
        return SkipRule.timeBased;
      default:
        return SkipRule.majority;
    }
  }
}

/// Vote-to-skip session model (Selection Phase only)
class VoteToSkipSession {
  final String id;
  final String lobbyId;
  final int battleNumber;
  final String playerIdToSkip;
  final String playerNameToSkip;
  final String initiatedBy;
  final String initiatorName;
  final SkipRule skipRule;
  final int votesRequired;
  final int votesCount;
  final Map<String, bool> votes; // userId → voted
  final String status; // 'active', 'executed', 'cancelled'
  final String phase; // Always 'selection' for MVP
  final DateTime createdAt;
  final DateTime? executedAt;
  final DateTime? cancelledAt;
  final int? timeLimitHours;

  VoteToSkipSession({
    required this.id,
    required this.lobbyId,
    required this.battleNumber,
    required this.playerIdToSkip,
    required this.playerNameToSkip,
    required this.initiatedBy,
    required this.initiatorName,
    required this.skipRule,
    required this.votesRequired,
    required this.votesCount,
    required this.votes,
    required this.status,
    required this.phase,
    required this.createdAt,
    this.executedAt,
    this.cancelledAt,
    this.timeLimitHours,
  });

  bool get isExecuted => status == 'executed';
  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';
  int get votesRemaining => votesRequired - votesCount;
  bool get majorityReached => votesCount >= votesRequired;

  // Check if time-based skip has expired
  bool get isTimeExpired {
    if (skipRule != SkipRule.timeBased || timeLimitHours == null) {
      return false;
    }
    final expiryTime = createdAt.add(Duration(hours: timeLimitHours!));
    return DateTime.now().isAfter(expiryTime);
  }

  Duration get timeRemaining {
    if (skipRule != SkipRule.timeBased || timeLimitHours == null) {
      return Duration.zero;
    }
    final expiryTime = createdAt.add(Duration(hours: timeLimitHours!));
    return expiryTime.difference(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lobbyId': lobbyId,
        'battleNumber': battleNumber,
        'playerIdToSkip': playerIdToSkip,
        'playerNameToSkip': playerNameToSkip,
        'initiatedBy': initiatedBy,
        'initiatorName': initiatorName,
        'skipRule': skipRule.value,
        'votesRequired': votesRequired,
        'votesCount': votesCount,
        'votes': votes,
        'status': status,
        'phase': phase,
        'createdAt': createdAt.toIso8601String(),
        'executedAt': executedAt?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
        'timeLimitHours': timeLimitHours,
      };

  factory VoteToSkipSession.fromJson(Map<String, dynamic> json) {
    return VoteToSkipSession(
      id: json['id'] as String? ?? json['sessionId'] as String,
      lobbyId: json['lobbyId'] as String,
      battleNumber: json['battleNumber'] as int,
      playerIdToSkip: json['playerIdToSkip'] as String,
      playerNameToSkip: json['playerNameToSkip'] as String,
      initiatedBy: json['initiatedBy'] as String,
      initiatorName: json['initiatorName'] as String,
      skipRule: SkipRuleExtension.fromString(json['skipRule'] as String),
      votesRequired: json['votesRequired'] as int,
      votesCount: json['votesCount'] as int,
      votes: Map<String, bool>.from(json['votes'] as Map? ?? {}),
      status: json['status'] as String? ?? 'active',
      phase: json['phase'] as String? ?? 'selection',
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['timestamp'] as String),
      executedAt: json['executedAt'] != null ? DateTime.parse(json['executedAt'] as String) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt'] as String) : null,
      timeLimitHours: json['timeLimitHours'] as int?,
    );
  }

  VoteToSkipSession copyWith({
    String? id,
    String? lobbyId,
    int? battleNumber,
    String? playerIdToSkip,
    String? playerNameToSkip,
    String? initiatedBy,
    String? initiatorName,
    SkipRule? skipRule,
    int? votesRequired,
    int? votesCount,
    Map<String, bool>? votes,
    String? status,
    String? phase,
    DateTime? createdAt,
    DateTime? executedAt,
    DateTime? cancelledAt,
    int? timeLimitHours,
  }) {
    return VoteToSkipSession(
      id: id ?? this.id,
      lobbyId: lobbyId ?? this.lobbyId,
      battleNumber: battleNumber ?? this.battleNumber,
      playerIdToSkip: playerIdToSkip ?? this.playerIdToSkip,
      playerNameToSkip: playerNameToSkip ?? this.playerNameToSkip,
      initiatedBy: initiatedBy ?? this.initiatedBy,
      initiatorName: initiatorName ?? this.initiatorName,
      skipRule: skipRule ?? this.skipRule,
      votesRequired: votesRequired ?? this.votesRequired,
      votesCount: votesCount ?? this.votesCount,
      votes: votes ?? this.votes,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      createdAt: createdAt ?? this.createdAt,
      executedAt: executedAt ?? this.executedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      timeLimitHours: timeLimitHours ?? this.timeLimitHours,
    );
  }
}

/// Game vote model - represents a player's vote for a game
class GameVote {
  final String playerId;
  final String gameId;
  final int points;
  final DateTime timestamp;

  GameVote({
    required this.playerId,
    required this.gameId,
    required this.points,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'gameId': gameId,
        'points': points,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GameVote.fromJson(Map<String, dynamic> json) => GameVote(
        playerId: json['playerId'],
        gameId: json['gameId'],
        points: json['points'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Voting session model - manages voting for games across multiple rounds
class VotingSession {
  final String id;
  final String lobbyId;
  final int pointsPerPlayer;
  final int totalRounds;
  final int gamesPerRound;
  final int currentRound;
  final List<String> availableGames;
  final Map<String, Map<String, int>> votes; // playerId -> gameId -> points
  final Map<String, int> remainingPoints; // playerId -> remaining points
  final List<List<String>> selectedGames; // Games selected for each round (rounds -> games)
  final bool completed;
  final DateTime createdAt;
  final bool blindVoting; // If true, vote totals are hidden until voting ends

  VotingSession({
    required this.id,
    required this.lobbyId,
    required this.pointsPerPlayer,
    required this.totalRounds,
    required this.gamesPerRound,
    required this.currentRound,
    required this.availableGames,
    required this.votes,
    required this.remainingPoints,
    required this.selectedGames,
    required this.completed,
    required this.createdAt,
    this.blindVoting = true, // Default to blind voting
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'lobbyId': lobbyId,
        'pointsPerPlayer': pointsPerPlayer,
        'totalRounds': totalRounds,
        'gamesPerRound': gamesPerRound,
        'currentRound': currentRound,
        'availableGames': availableGames,
        'votes': votes,
        'remainingPoints': remainingPoints,
        'selectedGames': selectedGames,
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
        'blindVoting': blindVoting,
      };

  factory VotingSession.fromJson(Map<String, dynamic> json) => VotingSession(
        id: json['id'],
        lobbyId: json['lobbyId'],
        pointsPerPlayer: json['pointsPerPlayer'],
        totalRounds: json['totalRounds'],
        gamesPerRound: json['gamesPerRound'],
        currentRound: json['currentRound'],
        availableGames: List<String>.from(json['availableGames']),
        votes: (json['votes'] as Map<String, dynamic>).map(
          (playerId, playerVotes) => MapEntry(
            playerId,
            Map<String, int>.from(playerVotes as Map),
          ),
        ),
        remainingPoints: Map<String, int>.from(json['remainingPoints']),
        selectedGames: (json['selectedGames'] as List)
            .map((round) => List<String>.from(round))
            .toList(),
        completed: json['completed'],
        createdAt: DateTime.parse(json['createdAt']),
        blindVoting: json['blindVoting'] ?? true, // Default to blind voting
      );

  /// Calculate total points for each game
  Map<String, int> calculateGameTotals() {
    final totals = <String, int>{};
    for (var playerVotes in votes.values) {
      for (var entry in playerVotes.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + entry.value;
      }
    }
    return totals;
  }

  /// Get the top N games with most points for the round
  /// Returns list of game IDs sorted by points (highest first)
  List<String> getTopGames(int count) {
    final totals = calculateGameTotals();
    if (totals.isEmpty) return [];
    
    // Sort games by points (descending)
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Return top N games
    return sortedEntries
        .take(count)
        .map((e) => e.key)
        .toList();
  }

  /// Get the winning game (game with most points) - for backward compatibility
  String? getWinningGame() {
    final winners = getTopGames(1);
    return winners.isEmpty ? null : winners.first;
  }

  /// Check if all players have used their points
  bool get allPlayersVoted {
    return remainingPoints.values.every((points) => points == 0);
  }

  /// Check if voting is open for current round
  bool get isVotingOpen {
    return !completed && currentRound <= totalRounds;
  }

  /// Get total number of games in the match
  int get totalGames => totalRounds * gamesPerRound;

  /// Get all selected games flattened
  List<String> get allSelectedGames {
    return selectedGames.expand((round) => round).toList();
  }
}

/// Turn data model - Feature 3.3
class Turn {
  final String id;
  final String gameId;
  final String playerId;
  final String playerName;
  final int turnNumber;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool validated;
  final int? score;

  Turn({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.playerName,
    required this.turnNumber,
    required this.data,
    required this.timestamp,
    this.validated = false,
    this.score,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'playerId': playerId,
        'playerName': playerName,
        'turnNumber': turnNumber,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'validated': validated,
        'score': score,
      };

  factory Turn.fromJson(Map<String, dynamic> json) => Turn(
        id: json['id'],
        gameId: json['gameId'],
        playerId: json['playerId'],
        playerName: json['playerName'],
        turnNumber: json['turnNumber'],
        data: json['data'],
        timestamp: DateTime.parse(json['timestamp']),
        validated: json['validated'] ?? false,
        score: json['score'],
      );
}

/// Turn notification model - Feature 3.3.4
class TurnNotification {
  final String id;
  final String gameId;
  final String gameName;
  final String playerId;
  final String playerName;
  final String message;
  final DateTime timestamp;
  final bool read;

  TurnNotification({
    required this.id,
    required this.gameId,
    required this.gameName,
    required this.playerId,
    required this.playerName,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'gameName': gameName,
        'playerId': playerId,
        'playerName': playerName,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };

  factory TurnNotification.fromJson(Map<String, dynamic> json) =>
      TurnNotification(
        id: json['id'],
        gameId: json['gameId'],
        gameName: json['gameName'],
        playerId: json['playerId'],
        playerName: json['playerName'],
        message: json['message'],
        timestamp: DateTime.parse(json['timestamp']),
        read: json['read'] ?? false,
      );
}

/// Game state snapshot - Feature 3.5
class GameStateSnapshot {
  final String id;
  final String gameId;
  final String lobbyId;
  final Map<String, dynamic> state;
  final int version;
  final DateTime timestamp;
  final bool synced;

  GameStateSnapshot({
    required this.id,
    required this.gameId,
    required this.lobbyId,
    required this.state,
    required this.version,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'lobbyId': lobbyId,
        'state': state,
        'version': version,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced,
      };

  factory GameStateSnapshot.fromJson(Map<String, dynamic> json) =>
      GameStateSnapshot(
        id: json['id'],
        gameId: json['gameId'],
        lobbyId: json['lobbyId'],
        state: json['state'],
        version: json['version'],
        timestamp: DateTime.parse(json['timestamp']),
        synced: json['synced'] ?? false,
      );
}

/// Score record model - Feature 3.4
class ScoreRecord {
  final String id;
  final String gameId;
  final String playerId;
  final int baseScore;
  final int timeBonus;
  final int accuracyBonus;
  final double streakMultiplier;
  final int finalScore;
  final DateTime timestamp;
  final bool validated;

  ScoreRecord({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.baseScore,
    required this.timeBonus,
    required this.accuracyBonus,
    required this.streakMultiplier,
    required this.finalScore,
    required this.timestamp,
    this.validated = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameId': gameId,
        'playerId': playerId,
        'baseScore': baseScore,
        'timeBonus': timeBonus,
        'accuracyBonus': accuracyBonus,
        'streakMultiplier': streakMultiplier,
        'finalScore': finalScore,
        'timestamp': timestamp.toIso8601String(),
        'validated': validated,
      };

  factory ScoreRecord.fromJson(Map<String, dynamic> json) => ScoreRecord(
        id: json['id'],
        gameId: json['gameId'],
        playerId: json['playerId'],
        baseScore: json['baseScore'],
        timeBonus: json['timeBonus'],
        accuracyBonus: json['accuracyBonus'],
        streakMultiplier: json['streakMultiplier'].toDouble(),
        finalScore: json['finalScore'],
        timestamp: DateTime.parse(json['timestamp']),
        validated: json['validated'] ?? false,
      );
}

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.error,
  });
}

// ============================================================================
// Phase 2: War Configuration, Voting, & Immutable Payloads
// ============================================================================

/// War configuration model
class WarConfig {
  final String difficulty;        // 'easy' | 'medium' | 'hard'
  final String hintPolicy;        // 'disabled' | 'enabled' | 'assisted'
  final bool ranked;              // Ranked vs casual
  final String? gamePack;         // Preset pack name or null for manual
  final List<String> manualGameIds; // Selected games if manual selection

  WarConfig({
    required this.difficulty,
    required this.hintPolicy,
    required this.ranked,
    this.gamePack,
    this.manualGameIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'difficulty': difficulty,
    'hintPolicy': hintPolicy,
    'ranked': ranked,
    'gamePack': gamePack,
    'manualGameIds': manualGameIds,
  };

  factory WarConfig.fromJson(Map<String, dynamic> json) => WarConfig(
    difficulty: json['difficulty'] ?? 'medium',
    hintPolicy: json['hintPolicy'] ?? 'enabled',
    ranked: json['ranked'] ?? false,
    gamePack: json['gamePack'],
    manualGameIds: List<String>.from(json['manualGameIds'] ?? []),
  );
}

/// Individual game slot in the immutable sequence
class GameSlot {
  final int roundNumber;
  final String gameId;
  final String difficulty;
  final String hintPolicy;
  final int gameIndex;            // Deterministic index for this round's game
  final String seed;              // Seed for pseudo-random generation

  GameSlot({
    required this.roundNumber,
    required this.gameId,
    required this.difficulty,
    required this.hintPolicy,
    required this.gameIndex,
    required this.seed,
  });

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'gameId': gameId,
    'difficulty': difficulty,
    'hintPolicy': hintPolicy,
    'gameIndex': gameIndex,
    'seed': seed,
  };

  factory GameSlot.fromJson(Map<String, dynamic> json) => GameSlot(
    roundNumber: json['roundNumber'] ?? 1,
    gameId: json['gameId'] ?? '',
    difficulty: json['difficulty'] ?? 'medium',
    hintPolicy: json['hintPolicy'] ?? 'enabled',
    gameIndex: json['gameIndex'] ?? 0,
    seed: json['seed'] ?? '',
  );
}

/// Immutable Mind War Payload - locked before game starts
/// All players receive and cache this to ensure identical gameplay
class MindWarPayload {
  final String mindWarId;
  final String lobbyId;
  final List<GameSlot> gameSequence;
  final String difficulty;
  final String hintPolicy;
  final bool ranked;
  final String scoringModelVersion;
  final String createdAt;

  MindWarPayload({
    required this.mindWarId,
    required this.lobbyId,
    required this.gameSequence,
    required this.difficulty,
    required this.hintPolicy,
    required this.ranked,
    required this.scoringModelVersion,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'mindWarId': mindWarId,
    'lobbyId': lobbyId,
    'gameSequence': gameSequence.map((g) => g.toJson()).toList(),
    'difficulty': difficulty,
    'hintPolicy': hintPolicy,
    'ranked': ranked,
    'scoringModelVersion': scoringModelVersion,
    'createdAt': createdAt,
  };

  factory MindWarPayload.fromJson(Map<String, dynamic> json) => MindWarPayload(
    mindWarId: json['mindWarId'] ?? '',
    lobbyId: json['lobbyId'] ?? '',
    gameSequence: (json['gameSequence'] as List?)
        ?.map((g) => GameSlot.fromJson(g as Map<String, dynamic>))
        .toList() ?? [],
    difficulty: json['difficulty'] ?? 'medium',
    hintPolicy: json['hintPolicy'] ?? 'enabled',
    ranked: json['ranked'] ?? false,
    scoringModelVersion: json['scoringModelVersion'] ?? '1.0',
    createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
  );
}
