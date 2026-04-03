/**
 * Offline Service - Handles offline gameplay and automatic sync
 * Offline-First: All games playable without connectivity
 * Uses SQLite for local storage with sync queue
 */

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class OfflineService {
  static Database? _database;
  /// [2026-03-26 Maintenance] Increment the local schema version for profile fields.
  ///
  /// Alpha profile setup now persists display names and avatar asset paths for
  /// locally authenticated users, so the SQLite schema needs to evolve safely.
  static const int _databaseVersion = 2;
  bool _syncInProgress = false;

  /// Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize SQLite database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mind_wars.db');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        // Offline games table
        await db.execute('''
          CREATE TABLE offline_games (
            id TEXT PRIMARY KEY,
            game_type TEXT NOT NULL,
            category TEXT NOT NULL,
            state TEXT NOT NULL,
            score INTEGER DEFAULT 0,
            completed INTEGER DEFAULT 0,
            timestamp TEXT NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');

        // User progress table
        await db.execute('''
          CREATE TABLE user_progress (
            user_id TEXT PRIMARY KEY,
            level INTEGER DEFAULT 1,
            total_score INTEGER DEFAULT 0,
            games_played INTEGER DEFAULT 0,
            current_streak INTEGER DEFAULT 0,
            longest_streak INTEGER DEFAULT 0,
            badges TEXT,
            last_played_date TEXT NOT NULL
          )
        ''');

        // Sync queue table for failed API calls
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint TEXT NOT NULL,
            method TEXT NOT NULL,
            payload TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            last_attempt TEXT
          )
        ''');

        // Game cache for offline play
        await db.execute('''
          CREATE TABLE game_cache (
            game_id TEXT PRIMARY KEY,
            game_data TEXT NOT NULL,
            cached_at TEXT NOT NULL
          )
        ''');

        // Turn queue table for offline turns
        await db.execute('''
          CREATE TABLE turn_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            lobby_id TEXT NOT NULL,
            player_id TEXT NOT NULL,
            game_id TEXT NOT NULL,
            turn_data TEXT NOT NULL,
            created_at TEXT NOT NULL,
            synced INTEGER DEFAULT 0,
            retry_count INTEGER DEFAULT 0
          )
        ''');
        
        // Local users table for alpha testing
        await db.execute('''
          CREATE TABLE local_users (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL UNIQUE,
            display_name TEXT,
            avatar TEXT,
            password_hash TEXT NOT NULL,
            created_at TEXT NOT NULL,
            synced INTEGER DEFAULT 0
          )
        ''');
        
        // Create indexes for performance
        await db.execute('CREATE INDEX idx_turn_queue_lobby ON turn_queue(lobby_id)');
        await db.execute('CREATE INDEX idx_turn_queue_synced ON turn_queue(synced)');
        await db.execute('CREATE INDEX idx_sync_queue_retry ON sync_queue(retry_count)');
        await db.execute('CREATE INDEX idx_local_users_email ON local_users(email)');
        await db.execute('CREATE INDEX idx_local_users_username ON local_users(username)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        /// [2026-03-26 Maintenance] Migrate existing alpha installs in place.
        ///
        /// Devices that already registered users on schema version 1 should keep
        /// those accounts while gaining the new profile personalization fields.
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE local_users ADD COLUMN display_name TEXT');
          await db.execute('ALTER TABLE local_users ADD COLUMN avatar TEXT');
        }
      },
    );
  }

  /// Save offline game data
  Future<void> saveOfflineGame(OfflineGameData gameData) async {
    final db = await database;
    
    await db.insert(
      'offline_games',
      {
        'id': gameData.id,
        'game_type': gameData.gameType,
        'category': gameData.category.toString(),
        'state': jsonEncode(gameData.state),
        'score': gameData.score,
        'completed': gameData.completed ? 1 : 0,
        'timestamp': gameData.timestamp.toIso8601String(),
        'synced': gameData.synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all offline games
  Future<List<OfflineGameData>> getOfflineGames() async {
    final db = await database;
    final maps = await db.query('offline_games', orderBy: 'timestamp DESC');

    return maps.map((map) => OfflineGameData(
      id: map['id'] as String,
      gameType: map['game_type'] as String,
      category: CognitiveCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
      ),
      state: jsonDecode(map['state'] as String),
      score: map['score'] as int,
      completed: (map['completed'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      synced: (map['synced'] as int) == 1,
    )).toList();
  }

  /// Get unsynced offline games
  Future<List<OfflineGameData>> getUnsyncedGames() async {
    final db = await database;
    final maps = await db.query(
      'offline_games',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => OfflineGameData(
      id: map['id'] as String,
      gameType: map['game_type'] as String,
      category: CognitiveCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
      ),
      state: jsonDecode(map['state'] as String),
      score: map['score'] as int,
      completed: (map['completed'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      synced: (map['synced'] as int) == 1,
    )).toList();
  }

  /// Mark game as synced
  Future<void> markGameAsSynced(String gameId) async {
    final db = await database;
    await db.update(
      'offline_games',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }

  /// Save user progress offline
  Future<void> saveUserProgress(UserProgress progress) async {
    final db = await database;
    
    await db.insert(
      'user_progress',
      {
        'user_id': progress.userId,
        'level': progress.level,
        'total_score': progress.totalScore,
        'games_played': progress.gamesPlayed,
        'current_streak': progress.currentStreak,
        'longest_streak': progress.longestStreak,
        'badges': jsonEncode(progress.badges.map((b) => b.toJson()).toList()),
        'last_played_date': progress.lastPlayedDate.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user progress
  Future<UserProgress?> getUserProgress(String userId) async {
    final db = await database;
    final maps = await db.query(
      'user_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return UserProgress(
      userId: map['user_id'] as String,
      level: map['level'] as int,
      totalScore: map['total_score'] as int,
      gamesPlayed: map['games_played'] as int,
      currentStreak: map['current_streak'] as int,
      longestStreak: map['longest_streak'] as int,
      badges: (jsonDecode(map['badges'] as String) as List)
          .map((b) => Badge.fromJson(b))
          .toList(),
      lastPlayedDate: DateTime.parse(map['last_played_date'] as String),
    );
  }

  /// Add to sync queue (for automatic retry logic)
  Future<void> addToSyncQueue(
    String endpoint,
    String method,
    Map<String, dynamic> payload,
  ) async {
    final db = await database;
    
    await db.insert('sync_queue', {
      'endpoint': endpoint,
      'method': method,
      'payload': jsonEncode(payload),
      'retry_count': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Process sync queue with automatic retry logic
  Future<void> processSyncQueue(String apiEndpoint) async {
    final db = await database;
    final items = await db.query(
      'sync_queue',
      where: 'retry_count < ?',
      whereArgs: [5], // Max 5 retries
      orderBy: 'created_at ASC',
    );

    for (var item in items) {
      final id = item['id'] as int;
      final endpoint = item['endpoint'] as String;
      final method = item['method'] as String;
      final payload = jsonDecode(item['payload'] as String);
      final retryCount = item['retry_count'] as int;

      try {
        final response = await _makeApiCall(
          '$apiEndpoint$endpoint',
          method,
          payload,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success - remove from queue
          await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
          print('Synced queue item $id');
        } else {
          // Failed - increment retry count
          await db.update(
            'sync_queue',
            {
              'retry_count': retryCount + 1,
              'last_attempt': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [id],
          );
          print('Failed to sync item $id, retry count: ${retryCount + 1}');
        }
      } catch (error) {
        // Network error - increment retry count
        await db.update(
          'sync_queue',
          {
            'retry_count': retryCount + 1,
            'last_attempt': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        print('Error syncing item $id: $error');
      }
    }
  }

  /// Sync offline data with server (automatic sync on reconnect)
  Future<void> syncWithServer(String apiEndpoint, String userId) async {
    if (_syncInProgress) {
      print('Sync already in progress');
      return;
    }

    _syncInProgress = true;

    try {
      // First, process any queued API calls
      await processSyncQueue(apiEndpoint);

      // Sync unsynced games
      final unsyncedGames = await getUnsyncedGames();
      
      if (unsyncedGames.isEmpty) {
        print('No games to sync');
        _syncInProgress = false;
        return;
      }

      print('Syncing ${unsyncedGames.length} games...');

      for (var game in unsyncedGames) {
        try {
          // Server-side validation for scoring (Security-First)
          final response = await http.post(
            Uri.parse('$apiEndpoint/sync/game'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'gameData': game.toJson(),
            }),
          );

          if (response.statusCode == 200) {
            // Server wins for scoring (Conflict resolution)
            final serverResponse = jsonDecode(response.body);
            if (serverResponse['validated'] == true) {
              await markGameAsSynced(game.id);
              print('Synced game ${game.id}');
            } else {
              print('Server rejected game ${game.id}: ${serverResponse['reason']}');
            }
          } else {
            // Add to sync queue for retry
            await addToSyncQueue('/sync/game', 'POST', {
              'userId': userId,
              'gameData': game.toJson(),
            });
            print('Failed to sync game ${game.id}, added to queue');
          }
        } catch (error) {
          // Add to sync queue for automatic retry
          await addToSyncQueue('/sync/game', 'POST', {
            'userId': userId,
            'gameData': game.toJson(),
          });
          print('Error syncing game ${game.id}: $error');
        }
      }

      // Sync user progress
      final progress = await getUserProgress(userId);
      if (progress != null) {
        try {
          await http.post(
            Uri.parse('$apiEndpoint/sync/progress'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'progress': progress.toJson(),
            }),
          );
          print('User progress synced');
        } catch (error) {
          // Add to sync queue
          await addToSyncQueue('/sync/progress', 'POST', {
            'userId': userId,
            'progress': progress.toJson(),
          });
          print('Error syncing user progress: $error');
        }
      }

      _syncInProgress = false;
    } catch (error) {
      print('Error during sync: $error');
      _syncInProgress = false;
      rethrow;
    }
  }

  /// Make API call helper
  Future<http.Response> _makeApiCall(
    String url,
    String method,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(payload);

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(uri, headers: headers, body: body);
      case 'PUT':
        return await http.put(uri, headers: headers, body: body);
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  /// Cache game data for offline play
  Future<void> cacheGameData(String gameId, Map<String, dynamic> gameData) async {
    final db = await database;
    
    await db.insert(
      'game_cache',
      {
        'game_id': gameId,
        'game_data': jsonEncode(gameData),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get cached game data
  Future<Map<String, dynamic>?> getCachedGameData(String gameId) async {
    final db = await database;
    final maps = await db.query(
      'game_cache',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );

    if (maps.isEmpty) return null;

    return jsonDecode(maps.first['game_data'] as String);
  }

  /// Create offline puzzle
  Future<OfflineGameData> createOfflinePuzzle(
    String gameType,
    CognitiveCategory category,
    int difficulty,
  ) async {
    final gameData = OfflineGameData(
      id: 'offline_${DateTime.now().millisecondsSinceEpoch}_${_generateId()}',
      gameType: gameType,
      category: category,
      state: _generatePuzzleState(gameType, difficulty),
      score: 0,
      completed: false,
      timestamp: DateTime.now(),
      synced: false,
    );

    await saveOfflineGame(gameData);
    return gameData;
  }

  /// Generate puzzle state
  Map<String, dynamic> _generatePuzzleState(String gameType, int difficulty) {
    return {
      'gameType': gameType,
      'difficulty': difficulty,
      'moves': [],
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Generate random ID
  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var id = '';
    var num = random;
    
    for (var i = 0; i < 9; i++) {
      id += chars[num % chars.length];
      num = num ~/ chars.length;
    }
    
    return id;
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    final db = await database;
    await db.delete('offline_games');
    await db.delete('user_progress');
    await db.delete('sync_queue');
    await db.delete('game_cache');
  }

  /// Check if sync is in progress
  bool get isSyncInProgress => _syncInProgress;

  /// Get sync queue size
  Future<int> getSyncQueueSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM sync_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ===== Turn Queue Management =====

  /// Queue a turn for later sync (when offline)
  Future<void> queueTurn({
    required String lobbyId,
    required String playerId,
    required String gameId,
    required Map<String, dynamic> turnData,
  }) async {
    final db = await database;
    
    await db.insert('turn_queue', {
      'lobby_id': lobbyId,
      'player_id': playerId,
      'game_id': gameId,
      'turn_data': jsonEncode(turnData),
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
      'retry_count': 0,
    });
    
    print('Turn queued for lobby $lobbyId');
  }

  /// Get all unsynced turns for a lobby
  Future<List<QueuedTurn>> getUnsyncedTurns(String lobbyId) async {
    final db = await database;
    final maps = await db.query(
      'turn_queue',
      where: 'lobby_id = ? AND synced = ?',
      whereArgs: [lobbyId, 0],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => QueuedTurn(
      id: map['id'] as int,
      lobbyId: map['lobby_id'] as String,
      playerId: map['player_id'] as String,
      gameId: map['game_id'] as String,
      turnData: jsonDecode(map['turn_data'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      synced: (map['synced'] as int) == 1,
      retryCount: map['retry_count'] as int,
    )).toList();
  }

  /// Get all unsynced turns across all lobbies
  Future<List<QueuedTurn>> getAllUnsyncedTurns() async {
    final db = await database;
    final maps = await db.query(
      'turn_queue',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => QueuedTurn(
      id: map['id'] as int,
      lobbyId: map['lobby_id'] as String,
      playerId: map['player_id'] as String,
      gameId: map['game_id'] as String,
      turnData: jsonDecode(map['turn_data'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      synced: (map['synced'] as int) == 1,
      retryCount: map['retry_count'] as int,
    )).toList();
  }

  /// Mark turn as synced
  Future<void> markTurnAsSynced(int turnId) async {
    final db = await database;
    await db.update(
      'turn_queue',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [turnId],
    );
  }

  /// Increment turn retry count
  Future<void> incrementTurnRetryCount(int turnId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE turn_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [turnId],
    );
  }

  /// Sync all queued turns with server
  Future<SyncResult> syncQueuedTurns(String apiEndpoint) async {
    final unsyncedTurns = await getAllUnsyncedTurns();
    
    if (unsyncedTurns.isEmpty) {
      return SyncResult(
        success: true,
        syncedCount: 0,
        failedCount: 0,
        message: 'No turns to sync',
      );
    }

    int syncedCount = 0;
    int failedCount = 0;
    List<String> errors = [];

    for (var turn in unsyncedTurns) {
      // Skip if max retries reached
      if (turn.retryCount >= 5) {
        errors.add('Turn ${turn.id} exceeded max retries');
        failedCount++;
        continue;
      }

      try {
        final response = await http.post(
          Uri.parse('$apiEndpoint/games/${turn.gameId}/submit-turn'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'lobbyId': turn.lobbyId,
            'playerId': turn.playerId,
            'turnData': turn.turnData,
            'timestamp': turn.createdAt.toIso8601String(),
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          await markTurnAsSynced(turn.id);
          syncedCount++;
          print('Synced turn ${turn.id}');
        } else {
          await incrementTurnRetryCount(turn.id);
          errors.add('Turn ${turn.id} failed: ${response.statusCode}');
          failedCount++;
        }
      } catch (error) {
        await incrementTurnRetryCount(turn.id);
        errors.add('Turn ${turn.id} error: $error');
        failedCount++;
      }
    }

    return SyncResult(
      success: failedCount == 0,
      syncedCount: syncedCount,
      failedCount: failedCount,
      message: errors.isEmpty 
          ? 'All turns synced successfully'
          : errors.join(', '),
    );
  }

  /// Get turn queue size for a lobby
  Future<int> getTurnQueueSize(String lobbyId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM turn_queue WHERE lobby_id = ? AND synced = 0',
      [lobbyId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total pending items (turns + sync queue)
  Future<int> getTotalPendingItems() async {
    final syncQueue = await getSyncQueueSize();
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM turn_queue WHERE synced = 0',
    );
    final turnQueue = Sqflite.firstIntValue(result) ?? 0;
    return syncQueue + turnQueue;
  }

  /// Clear synced turns (cleanup old data)
  Future<void> clearSyncedTurns({int daysOld = 7}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    await db.delete(
      'turn_queue',
      where: 'synced = 1 AND created_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }
}

/// Queued turn model
class QueuedTurn {
  final int id;
  final String lobbyId;
  final String playerId;
  final String gameId;
  final Map<String, dynamic> turnData;
  final DateTime createdAt;
  final bool synced;
  final int retryCount;

  QueuedTurn({
    required this.id,
    required this.lobbyId,
    required this.playerId,
    required this.gameId,
    required this.turnData,
    required this.createdAt,
    required this.synced,
    required this.retryCount,
  });
}

/// Sync result model
class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String message;

  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    required this.message,
  });
}
