/**
 * Multiplayer Service - Handles async multiplayer functionality
 * Supports async Mind Wars with a minimum of 2 players and an optional open-ended player cap
 */

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/models.dart';
import '../utils/build_config.dart';

class MultiplayerService {
  IO.Socket? _socket;
  GameLobby? _currentLobby;
  final Map<String, List<Function>> _listeners = {};

  /// [2025-11-16 Integration] Initialize multiplayer service with gateway URL
  /// Uses BuildConfig to get the correct server URL based on build flavor
  MultiplayerService({String? serverUrl}) {
    final resolvedUrl = serverUrl ?? BuildConfig.wsBaseUrl;
    print('[MultiplayerService] Configured default server URL: $resolvedUrl');
  }

  /// Check if socket is connected
  bool get isConnected {
    if (_socket == null) {
      print('[isConnected] Socket is null');
      return false;
    }
    final connected = _socket!.connected;
    print('[isConnected] Socket.connected = $connected');
    return connected;
  }

  /// Connect to the multiplayer server
  Future<void> connect(String serverUrl, String playerId, {String? token}) async {
    print('[MultiplayerService] Connecting to $serverUrl with playerId: $playerId');
    print('[MultiplayerService] Token provided: ${token != null}');

    final completer = Completer<void>();
    print('[MultiplayerService] Creating socket.io client...');
    print('[MultiplayerService] URL: $serverUrl');
    print('[MultiplayerService] Player ID: $playerId');

    _socket = IO.io(serverUrl, <String, dynamic>{
      'auth': {
        'token': token,
        'playerId': playerId,
      },
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    print('[MultiplayerService] Socket.io client created');
    print('[MultiplayerService] Socket initialized: ${_socket != null}');

    _socket!.onConnect((_) {
      print('[MultiplayerService] ✓✓✓ Connected to multiplayer server');
      print('[MultiplayerService] Socket ID: ${_socket!.id}');
      print('[MultiplayerService] Socket connected: ${_socket!.connected}');
      _setupEventListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.onConnectError((data) {
      print('[MultiplayerService] ✗✗✗ Connect ERROR event fired: $data');
      if (!completer.isCompleted) {
        completer.completeError(Exception('Failed to connect: $data'));
      }
    });

    // Catch any socket-level errors
    _socket!.on('error', (data) {
      print('[MultiplayerService] ✗✗✗ SOCKET ERROR event: $data');
    });

    _socket!.onDisconnect((_) {
      print('[MultiplayerService] Disconnected from server');
    });

    _socket!.connect();
    print('[MultiplayerService] Called socket.connect()');

    // Wait for connection with timeout
    print('[MultiplayerService] Waiting for connection...');
    try {
      await completer.future.timeout(Duration(seconds: 10), onTimeout: () {
        print('[MultiplayerService] ✗ Connection timeout after 10 seconds');
        print('[MultiplayerService] Socket connected status: ${_socket?.connected}');
        throw Exception('Connection timeout');
      });
    } catch (e) {
      print('[MultiplayerService] ✗ Connection failed: $e');
      throw Exception('Failed to connect to multiplayer server: $e');
    }
  }

  /// Disconnect from the multiplayer server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentLobby = null;
  }

  /// Create a new game lobby with enhanced options
  Future<GameLobby> createLobby({
    required String name,
    int? maxPlayers,
    bool isPrivate = true,
    int numberOfRounds = 3,
    int votingPointsPerPlayer = 10,
  }) async {
    print('[createLobby] Starting lobby creation for: $name');

    if (_socket == null) {
      print('[createLobby] ✗ Socket is null - not connected to server');
      throw Exception('Not connected to server');
    }

    if (!_socket!.connected) {
      print('[createLobby] ✗ Socket not connected. Status: ${_socket!.connected}');
      throw Exception('Socket is not connected to server');
    }

    print('[createLobby] ✓ Socket connected, emitting create-lobby event');

    if (maxPlayers != null && maxPlayers < 2) {
      throw Exception('Max players must be at least 2 when a cap is set');
    }

    if (numberOfRounds < 1 || numberOfRounds > 10) {
      throw Exception('Number of rounds must be between 1 and 10');
    }

    if (votingPointsPerPlayer < 1 || votingPointsPerPlayer > 20) {
      throw Exception('Voting points must be between 1 and 20');
    }

    final completer = Completer<GameLobby>();
    Future.delayed(Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        print('[createLobby] ✗ Timeout waiting for server response');
        completer.completeError(Exception('Request timeout - server did not respond'));
      }
    });

    print('[createLobby] Emitting create-lobby with: name=$name, maxPlayers=${maxPlayers ?? 'open'}, totalRounds=$numberOfRounds');

    _socket!.emitWithAck('create-lobby', {
      'name': name,
      'maxPlayers': maxPlayers,
      'isPrivate': isPrivate,
      'totalRounds': numberOfRounds,
      'votingPointsPerPlayer': votingPointsPerPlayer,
    }, ack: (data) {
      print('[createLobby] ✓ Received ack response: $data');

      if (!completer.isCompleted) {
        if (data != null && data is Map && data['success'] == true) {
          try {
            final lobby = GameLobby.fromJson(data['lobby']);
            _currentLobby = lobby;
            print('[createLobby] ✓ Lobby created: ${lobby.id}, code: ${lobby.lobbyCode}');
            completer.complete(lobby);
          } catch (e) {
            print('[createLobby] ✗ Error parsing lobby response: $e');
            completer.completeError(Exception('Failed to parse lobby: $e'));
          }
        } else {
          final error = data != null && data is Map ? data['error'] ?? 'Unknown error' : 'Invalid response format';
          print('[createLobby] ✗ Error from server: $error');
          completer.completeError(Exception(error));
        }
      }
    });

    return completer.future;
  }

  /// Join an existing lobby by ID
  Future<GameLobby> joinLobby(String lobbyId) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<GameLobby>();

    _socket!.emitWithAck('join-lobby', {
      'lobbyId': lobbyId,
    }, ack: (data) {
      if (data['success']) {
        final lobby = GameLobby.fromJson(data['lobby']);
        _currentLobby = lobby;
        completer.complete(lobby);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Join a lobby by code (for private lobbies)
  Future<GameLobby> joinLobbyByCode(String lobbyCode) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<GameLobby>();

    _socket!.emitWithAck('join-lobby-by-code', {
      'code': lobbyCode.toUpperCase(),
    }, ack: (data) {
      if (data['success']) {
        final lobby = GameLobby.fromJson(data['lobby']);
        _currentLobby = lobby;
        completer.complete(lobby);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Leave current lobby
  Future<void> leaveLobby() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();
    final leftLobbyId = _currentLobby!.id; // Capture lobby ID before clearing

    _socket!.emitWithAck('leave-lobby', {
      'lobbyId': leftLobbyId,
    }, ack: (data) {
      if (data['success']) {
        _currentLobby = null;
        // Emit event to hub that user left this lobby
        _emit('left-my-lobby', {'lobbyId': leftLobbyId});
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Start a game in the current lobby
  /// Start game - loads immutable payload and sends to all players
  Future<void> startGame(String lobbyId) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('start-game', {
      'lobbyId': lobbyId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Make a turn in the current game
  Future<void> makeTurn(Map<String, dynamic> turnData) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a game');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('make-turn', {
      'lobbyId': _currentLobby!.id,
      'turnData': turnData,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Submit a completed game result for server-side validation
  Future<void> submitGameResult({
    required String lobbyId,
    required String gameId,
    required int roundNumber,
    required int score,
    required int timeTaken,
    int hintsUsed = 0,
    bool perfect = false,
    Map<String, dynamic>? gameData,
  }) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('submit-game-result', {
      'lobbyId': lobbyId,
      'gameId': gameId,
      'roundNumber': roundNumber,
      'score': score,
      'timeTaken': timeTaken,
      'hintsUsed': hintsUsed,
      'perfect': perfect,
      if (gameData != null) 'gameData': gameData,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Send a chat message
  Future<void> sendMessage(String message) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('chat-message', {
      'lobbyId': _currentLobby!.id,
      'message': message,
    }, ack: (data) {
      if (data is Map && data['success'] == true) {
        completer.complete();
      } else {
        completer.completeError(Exception((data is Map ? data['error'] : null) ?? 'Failed to send message'));
      }
    });

    return completer.future;
  }

  /// Send an emoji reaction
  Future<void> sendReaction(String messageId, String emoji) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('emoji-reaction', {
      'lobbyId': _currentLobby!.id,
      'messageId': messageId,
      'emoji': emoji,
    }, ack: (data) {
      if (data is Map && data['success'] == true) {
        completer.complete();
      } else {
        completer.completeError(Exception((data is Map ? data['error'] : null) ?? 'Failed to send reaction'));
      }
    });

    return completer.future;
  }

  Future<List<ChatMessage>> fetchChatHistory({
    required String lobbyId,
    int limit = 50,
  }) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<List<ChatMessage>>();

    _socket!.emitWithAck('get-chat-history', {
      'lobbyId': lobbyId,
      'limit': limit,
    }, ack: (data) {
      if (data is Map && data['success'] == true) {
        final messages = (data['messages'] as List? ?? const [])
            .map((message) => ChatMessage.fromJson(Map<String, dynamic>.from((message as Map).cast<String, dynamic>())))
            .toList();
        completer.complete(messages);
      } else {
        completer.completeError(Exception((data is Map ? data['error'] : null) ?? 'Failed to load chat history'));
      }
    });

    return completer.future;
  }

  /// Vote to skip current turn/game
  Future<VoteToSkipSession> voteToSkip() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a game');
    }

    final completer = Completer<VoteToSkipSession>();

    _socket!.emitWithAck('vote-skip', {
      'lobbyId': _currentLobby!.id,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(VoteToSkipSession.fromJson(data['voteStatus']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Start a voting session for game selection
  Future<VotingSession> startVotingSession({
    required int pointsPerPlayer,
    required int totalRounds,
    required int gamesPerRound,
    List<String>? availableGames,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<VotingSession>();

    _socket!.emitWithAck('start-voting', {
      'lobbyId': _currentLobby!.id,
      'pointsPerPlayer': pointsPerPlayer,
      'totalRounds': totalRounds,
      'gamesPerRound': gamesPerRound,
      'availableGames': availableGames,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(VotingSession.fromJson(data['votingSession']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Cast a vote for a game
  Future<void> voteForGame({
    required String gameId,
    required int points,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('vote-game', {
      'lobbyId': _currentLobby!.id,
      'gameId': gameId,
      'points': points,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Remove vote from a game
  Future<void> removeGameVote({
    required String gameId,
    int? points,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('remove-vote', {
      'lobbyId': _currentLobby!.id,
      'gameId': gameId,
      'points': points,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// End voting for current round
  Future<List<String>> endVotingRound() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<List<String>>();

    _socket!.emitWithAck('end-voting', {
      'lobbyId': _currentLobby!.id,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(List<String>.from(data['selectedGames']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Get list of available lobbies
  Future<List<GameLobby>> getAvailableLobbies({
    String status = 'waiting',
    bool? isPrivate,
  }) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<List<GameLobby>>();

    _socket!.emitWithAck('list-lobbies', {
      'status': status,
      'isPrivate': isPrivate,
    }, ack: (data) {
      if (data['success']) {
        final lobbies = (data['lobbies'] as List)
            .map((l) => GameLobby.fromJson(l))
            .toList();
        completer.complete(lobbies);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  Future<List<GameLobby>> getMyLobbies({int limit = 20}) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<List<GameLobby>>();

    _socket!.emitWithAck('list-my-lobbies', {
      'limit': limit,
    }, ack: (data) {
      if (data['success']) {
        final lobbies = (data['lobbies'] as List)
            .map((l) => GameLobby.fromJson(l))
            .toList();
        completer.complete(lobbies);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Kick a player from the lobby (host only)
  Future<void> kickPlayer(String playerId) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('kick-player', {
      'lobbyId': _currentLobby!.id,
      'playerId': playerId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Transfer host role to another player
  Future<void> transferHost(String newHostId) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('transfer-host', {
      'lobbyId': _currentLobby!.id,
      'newHostId': newHostId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Close the lobby (host only)
  Future<void> closeLobby() async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<void>();
    final closedLobbyId = _currentLobby!.id; // Capture ID before clearing

    _socket!.emitWithAck('close-lobby', {
      'lobbyId': closedLobbyId,
    }, ack: (data) {
      if (data['success']) {
        _currentLobby = null;
        // Emit event so hub removes the closed lobby
        _emit('lobby-closed', {'lobbyId': closedLobbyId});
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }
  
  /// Update lobby settings (host only)
  Future<GameLobby> updateLobbySettings({
    String? name,
    int? maxPlayers,
    bool updateMaxPlayers = false,
    bool? isPrivate,
    int? numberOfRounds,
    int? votingPointsPerPlayer,
    SkipRule? skipRule,
    int? skipTimeLimitHours,
  }) async {
    if (_socket == null || _currentLobby == null) {
      throw Exception('Not in a lobby');
    }

    final completer = Completer<GameLobby>();

    final settings = <String, dynamic>{
      'lobbyId': _currentLobby!.id,
    };

    if (name != null) settings['name'] = name;
    if (updateMaxPlayers) settings['maxPlayers'] = maxPlayers;
    if (isPrivate != null) settings['isPrivate'] = isPrivate;
    if (numberOfRounds != null) settings['totalRounds'] = numberOfRounds;
    if (votingPointsPerPlayer != null) settings['votingPointsPerPlayer'] = votingPointsPerPlayer;
    if (skipRule != null) settings['skipRule'] = skipRule.value;
    if (skipTimeLimitHours != null) settings['skipTimeLimitHours'] = skipTimeLimitHours;

    _socket!.emitWithAck('update-lobby-settings', settings, ack: (data) {
      if (data['success']) {
        final lobby = GameLobby.fromJson(data['lobby']);
        _currentLobby = lobby;
        completer.complete(lobby);
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Subscribe to events
  void on(String event, Function callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
  }

  /// Unsubscribe from events
  void off(String event, Function callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
    }
  }

  /// Setup internal event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    _socket!.on('player-joined', (data) {
      _emit('player-joined', data);
    });

    _socket!.on('player-left', (data) {
      _emit('player-left', data);
    });
    
    _socket!.on('player-kicked', (data) {
      _emit('player-kicked', data);
    });
    
    _socket!.on('host-transferred', (data) {
      _emit('host-transferred', data);
    });

    _socket!.on('host-changed', (data) {
      _emit('host-changed', data);
    });
    
    _socket!.on('lobby-closed', (data) {
      _emit('lobby-closed', data);
      _currentLobby = null;
    });
    
    _socket!.on('lobby-updated', (data) {
      _emit('lobby-updated', data);
    });
    
    _socket!.on('player-status-changed', (data) {
      _emit('player-status-changed', data);
    });
    
    _socket!.on('player-typing', (data) {
      _emit('player-typing', data);
    });

    _socket!.on('game-started', (data) {
      _emit('game-started', data);
    });

    _socket!.on('turn-made', (data) {
      _emit('turn-made', data);
    });

    _socket!.on('game-ended', (data) {
      _emit('game-ended', data);
    });

    _socket!.on('chat-message', (data) {
      _emit('chat-message', data);
    });

    _socket!.on('emoji-reaction', (data) {
      _emit('emoji-reaction', data);
    });

    _socket!.on('vote-skip-update', (data) {
      _emit('vote-skip-update', data);
    });

    _socket!.on('voting-started', (data) {
      _emit('voting-started', data);
    });

    _socket!.on('vote-cast', (data) {
      _emit('vote-cast', data);
    });

    _socket!.on('voting-update', (data) {
      _emit('voting-update', data);
    });

    _socket!.on('voting-ended', (data) {
      _emit('voting-ended', data);
    });

    _socket!.on('skip-vote-initiated', (data) {
      _emit('skip-vote-initiated', data);
    });

    _socket!.on('skip-vote-updated', (data) {
      _emit('skip-vote-updated', data);
    });

    _socket!.on('skip-vote-executed', (data) {
      _emit('skip-vote-executed', data);
    });

    _socket!.on('time-skip-executed', (data) {
      _emit('time-skip-executed', data);
    });

    _socket!.on('disconnect', (_) {
      _emit('disconnected', {});
    });

    _socket!.on('reconnect', (_) {
      _emit('reconnected', {});
    });
  }
  
  /// Update player status (for presence tracking)
  void updatePlayerStatus(PlayerStatus status) {
    if (_socket == null || _currentLobby == null) {
      return;
    }

    _socket!.emit('update-player-status', {
      'lobbyId': _currentLobby!.id,
      'status': status.toString(),
    });
  }
  
  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_socket == null || _currentLobby == null) {
      return;
    }

    _socket!.emit('typing-indicator', {
      'lobbyId': _currentLobby!.id,
      'isTyping': isTyping,
    });
  }
  
  /// Start heartbeat for presence tracking
  void startHeartbeat() {
    if (_socket == null) return;
    
    // Send heartbeat every 30 seconds to maintain presence
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 30));
      if (_socket?.connected == true && _currentLobby != null) {
        _socket!.emit('heartbeat', {
          'lobbyId': _currentLobby!.id,
        });
        return true;
      }
      return false;
    });
  }
  
  /// Emit voting update - Feature 3.2.3
  void emitVoteUpdate(String lobbyId, String playerId, Map<String, int> votes) {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    _socket!.emit('voting-update', {
      'lobbyId': lobbyId,
      'playerId': playerId,
      'votes': votes,
    });
  }
  
  /// Listen for voting updates - Feature 3.2.3
  void onVotingUpdate(Function(Map<String, dynamic>) callback) {
    on('voting-update', callback);
  }
  
  /// Listen for voting started - Feature 3.2.3
  void onVotingStarted(Function(Map<String, dynamic>) callback) {
    on('voting-started', callback);
  }
  
  /// Listen for voting ended - Feature 3.2.3
  void onVotingEnded(Function(Map<String, dynamic>) callback) {
    on('voting-ended', callback);
  }
  
  /// Listen for vote cast - Feature 3.2.3
  void onVoteCast(Function(Map<String, dynamic>) callback) {
    on('vote-cast', callback);
  }

  // ========== Vote-to-Skip Methods ==========

  /// Initiate a vote-to-skip session for a player during Selection Phase
  Future<VoteToSkipSession> initiateSkipVote({
    required String lobbyId,
    required int battleNumber,
    required String playerIdToSkip,
  }) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<VoteToSkipSession>();

    _socket!.emitWithAck('initiate-skip-vote', {
      'lobbyId': lobbyId,
      'battleNumber': battleNumber,
      'playerIdToSkip': playerIdToSkip,
    }, ack: (data) {
      if (data['success']) {
        completer.complete(VoteToSkipSession.fromJson(data['session']));
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Cast a vote in an active skip session
  Future<void> castSkipVote(String sessionId) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('cast-skip-vote', {
      'sessionId': sessionId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Cancel a vote in an active skip session
  Future<void> cancelSkipVote(String sessionId) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('cancel-skip-vote', {
      'sessionId': sessionId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Listen for skip vote initiated events
  void onSkipVoteInitiated(Function(Map<String, dynamic>) callback) {
    on('skip-vote-initiated', callback);
  }

  /// Listen for skip vote update events
  void onSkipVoteUpdated(Function(Map<String, dynamic>) callback) {
    on('skip-vote-updated', callback);
  }

  /// Listen for skip vote executed events
  void onSkipVoteExecuted(Function(Map<String, dynamic>) callback) {
    on('skip-vote-executed', callback);
  }

  /// Listen for time-based skip executed events
  void onTimeSkipExecuted(Function(Map<String, dynamic>) callback) {
    on('time-skip-executed', callback);
  }

  /// Emit events to listeners
  void _emit(String event, dynamic data) {
    if (_listeners.containsKey(event)) {
      for (var callback in _listeners[event]!) {
        callback(data);
      }
    }
  }

  /// Get current lobby
  GameLobby? get currentLobby => _currentLobby;

  // ============================================================================
  // Phase 2: War Configuration & Immutable Payloads
  // ============================================================================

  /// Update war configuration (difficulty, hints, ranked, game pool)
  Future<void> updateWarConfig({
    required String lobbyId,
    required String difficulty,
    required String hintPolicy,
    required bool ranked,
    String? gamePack,
    List<String>? manualGameIds,
  }) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('update-war-config', {
      'lobbyId': lobbyId,
      'difficulty': difficulty,
      'hintPolicy': hintPolicy,
      'ranked': ranked,
      'gamePack': gamePack,
      'manualGameIds': manualGameIds ?? [],
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Mark player as ready to start the game
  Future<void> setPlayerReady(String lobbyId) async {
    if (_socket == null) {
      throw Exception('Not connected to server');
    }

    final completer = Completer<void>();

    _socket!.emitWithAck('set-player-ready', {
      'lobbyId': lobbyId,
    }, ack: (data) {
      if (data['success']) {
        completer.complete();
      } else {
        completer.completeError(Exception(data['error']));
      }
    });

    return completer.future;
  }

  /// Listen for war configuration updates
  void onWarConfigUpdated(Function(Map<String, dynamic>) callback) {
    on('war-config-updated', callback);
  }

  /// Listen for player ready state changes
  void onPlayerReady(Function(Map<String, dynamic>) callback) {
    on('player-ready', callback);
  }

  /// Listen for payload lock (immutable payload generated)
  void onPayloadLocked(Function(Map<String, dynamic>) callback) {
    on('payload-locked', callback);
  }

  /// Listen for game start event
  void onGameStarted(Function(Map<String, dynamic>) callback) {
    on('game-started', callback);
  }

  /// Listen for round completion
  void onRoundComplete(Function(Map<String, dynamic>) callback) {
    on('round-complete', callback);
  }

  /// Listen for game ended
  void onGameEnded(Function(Map<String, dynamic>) callback) {
    on('game-ended', callback);
  }
}
