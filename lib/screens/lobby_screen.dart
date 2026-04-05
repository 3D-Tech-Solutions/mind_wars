/**
 * Lobby Screen - Features 2.3 & 2.4
 * Main lobby view with player list, host controls, and presence tracking
 */

import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/multiplayer_service.dart';
import 'chat_screen.dart';
import '../services/voting_service.dart';
import '../widgets/branded_avatar.dart';
import 'game_voting_screen.dart';
import 'lobby_settings_screen.dart';
import 'war_config_screen.dart';
import '../utils/brand_animations.dart';
import '../widgets/build_version_badge.dart';

class LobbyScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;
  final String currentUserId;

  const LobbyScreen({
    Key? key,
    required this.multiplayerService,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  GameLobby? _lobby;
  bool _isLoading = true;
  bool _skipLeaveLobbyConfirmation = false;
  final Map<String, bool> _typingPlayers = {};
  late final TextEditingController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = TextEditingController();

    try {
      _lobby = widget.multiplayerService.currentLobby;
      _setupEventListeners();
      _isLoading = false;

      // Start heartbeat for presence tracking
      widget.multiplayerService.startHeartbeat();
    } catch (e) {
      // Show error message and navigate away gracefully
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to initialize lobby: $e'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _setupEventListeners() {
    // Player joined
    widget.multiplayerService.on('player-joined', (data) {
      if (!mounted) return;
      setState(() {
        final player = Player.fromJson(data['player']);
        _lobby = _lobby?.copyWith(
          players: [...(_lobby?.players ?? []), player],
        );
      });
      _showSnackBar('${data['player']['username']} joined the lobby');
    });

    // Player left
    widget.multiplayerService.on('player-left', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = _lobby?.copyWith(
          players: _lobby?.players
              .where((p) => p.id != data['playerId'])
              .toList() ?? [],
        );
      });
      _showSnackBar('${data['username']} left the lobby');
    });

    // Player kicked
    widget.multiplayerService.on('player-kicked', (data) {
      if (!mounted) return;
      if (data['playerId'] == widget.currentUserId) {
        _showSnackBar('You were kicked from the lobby');
        Navigator.of(context).pop();
      } else {
        setState(() {
          _lobby = _lobby?.copyWith(
            players: _lobby?.players
                .where((p) => p.id != data['playerId'])
                .toList() ?? [],
          );
        });
        _showSnackBar('${data['username']} was kicked');
      }
    });

    // Host transferred
    widget.multiplayerService.on('host-transferred', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = _lobby?.copyWith(hostId: data['newHostId']);
      });
      _showSnackBar('${data['newHostUsername']} is now the host');
    });

    // Lobby closed
    widget.multiplayerService.on('lobby-closed', (data) {
      if (!mounted) return;
      _showSnackBar('The lobby has been closed');
      Navigator.of(context).pop();
    });

    // Lobby updated
    widget.multiplayerService.on('lobby-updated', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = GameLobby.fromJson(data['lobby']);
      });
    });

    // Player status changed
    widget.multiplayerService.on('player-status-changed', (data) {
      if (!mounted) return;
      setState(() {
        final playerId = data['playerId'];
        final status = PlayerStatus.values.firstWhere(
          (e) => e.toString() == data['status'],
          orElse: () => PlayerStatus.active,
        );
        
        final players = _lobby?.players.map((p) {
          if (p.id == playerId) {
            return Player(
              id: p.id,
              username: p.username,
              displayName: p.displayName,
              avatar: p.avatar,
              status: status,
              score: p.score,
              streak: p.streak,
              badges: p.badges,
              lastActive: DateTime.now(),
            );
          }
          return p;
        }).toList() ?? [];
        
        _lobby = _lobby?.copyWith(players: players);
      });
    });

    // Typing indicator
    widget.multiplayerService.on('player-typing', (data) {
      if (!mounted) return;
      setState(() {
        _typingPlayers[data['playerId']] = data['isTyping'];
      });
    });

    // Game started
    widget.multiplayerService.on('game-started', (data) {
      if (!mounted) return;
      final gameData = data['game'];
      if (gameData == null) {
        _showSnackBar('Game start failed: no game data');
        return;
      }
      final game = Game.fromJson(gameData);
      Navigator.of(context).pushNamed('/game', arguments: game);
    });

    // Phase 2: War configuration updated
    widget.multiplayerService.on('war-config-updated', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = _lobby?.copyWith(
          difficulty: data['difficulty'],
          hintPolicy: data['hintPolicy'],
          ranked: data['ranked'],
        );
      });
      _showSnackBar('War configuration updated');
    });

    // Phase 2: Player marked ready
    widget.multiplayerService.on('player-ready', (data) {
      if (!mounted) return;
      _showSnackBar('${data['userId']?.substring(0, 8)} is ready');
    });

    // Phase 2: Payload locked (all players ready)
    widget.multiplayerService.on('payload-locked', (data) {
      if (!mounted) return;
      setState(() {
        _lobby = _lobby?.copyWith(payloadLocked: true);
      });
      _showSnackBar('All players ready! Mind War locked and ready to start.');
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _copyLobbyCode() async {
    if (_lobby?.lobbyCode != null) {
      await Clipboard.setData(ClipboardData(text: _lobby!.lobbyCode!));
      _showSnackBar('Lobby code copied to clipboard');
    }
  }

  Future<void> _configureWar() async {
    final lobby = _lobby;
    if (lobby == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WarConfigScreen(
          multiplayerService: widget.multiplayerService,
          lobbyId: lobby.id,
          totalRounds: lobby.numberOfRounds,
        ),
      ),
    );
  }

  Future<void> _startVoting() async {
    final lobby = _lobby;
    if (lobby == null) return;

    try {
      // 1. Start voting session on backend
      await widget.multiplayerService.startVotingSession(
        pointsPerPlayer: lobby.votingPointsPerPlayer,
        totalRounds: lobby.numberOfRounds,
        gamesPerRound: 1,
      );

      // 2. Open voting screen
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameVotingScreen(
            lobbyId: lobby.id,
            playerId: widget.currentUserId,
            votingService: VotingService(),
            multiplayerService: widget.multiplayerService,
          ),
        ),
      );
    } catch (e) {
      _showSnackBar('Error starting voting: $e');
    }
  }

  Future<void> _startGame() async {
    final lobby = _lobby;
    if (lobby == null) {
      _showSnackBar('No lobby found');
      return;
    }

    if (!lobby.payloadLocked) {
      _showSnackBar('Not all players are ready');
      return;
    }

    try {
      await widget.multiplayerService.startGame(lobby.id);
    } catch (e) {
      _showSnackBar('Error starting game: $e');
    }
  }

  Future<void> _kickPlayer(Player player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kick Player'),
        content: Text('Are you sure you want to kick ${player.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Kick'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.multiplayerService.kickPlayer(player.id);
      } catch (e) {
        _showSnackBar('Failed to kick player: ${e.toString()}');
      }
    }
  }

  Future<void> _transferHost(Player player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Host'),
        content: Text('Make ${player.username} the new host?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.multiplayerService.transferHost(player.id);
      } catch (e) {
        _showSnackBar('Failed to transfer host: ${e.toString()}');
      }
    }
  }

  Future<void> _closeLobby() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Lobby'),
        content: const Text(
          'Are you sure you want to close this lobby? All players will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.multiplayerService.closeLobby();
        if (!mounted) return;
        // Return to multiplayer hub - pop the lobby screen
        Navigator.of(context).pop();
      } catch (e) {
        _showSnackBar('Failed to close lobby: ${e.toString()}');
      }
    }
  }

  Future<void> _leaveLobby() async {
    // Show confirmation dialog unless user checked "Do Not Ask Again"
    if (!_skipLeaveLobbyConfirmation && _lobby != null) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool dontAskAgain = false;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Leave "${_lobby!.name}"?'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Are you sure you want to leave this Mind War?'),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() => dontAskAgain = !dontAskAgain);
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: dontAskAgain,
                            onChanged: (val) {
                              setState(() => dontAskAgain = val ?? false);
                            },
                          ),
                          const Text('Do not ask again'),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Leave'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (shouldLeave != true) return; // User canceled
    }

    // Actually leave the lobby
    try {
      await widget.multiplayerService.leaveLobby();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to leave lobby: ${e.toString()}');
    }
  }

  Future<void> _navigateToSettings() async {
    final lobby = _lobby;
    if (lobby == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LobbySettingsScreen(
          lobby: lobby,
          onSave: (maxPlayers, totalRounds, votingPoints, skipRule, skipTimeLimitHours) {
            widget.multiplayerService.updateLobbySettings(
              maxPlayers: maxPlayers,
              numberOfRounds: totalRounds,
              votingPointsPerPlayer: votingPoints,
              skipRule: skipRule,
              skipTimeLimitHours: skipTimeLimitHours,
            );
          },
        ),
      ),
    );
  }

  void _navigateToChat() {
    if (_lobby == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          lobbyId: _lobby!.id,
          currentUserId: widget.currentUserId,
          multiplayerService: widget.multiplayerService,
        ),
      ),
    );
  }

  Widget _buildPlayerStatusIcon(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.active:
        return const Icon(Icons.circle, color: Colors.green, size: 12);
      case PlayerStatus.idle:
        return const Icon(Icons.circle, color: Colors.orange, size: 12);
      case PlayerStatus.disconnected:
        return const Icon(Icons.circle, color: Colors.grey, size: 12);
    }
  }

  String _getPlayerStatusText(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.active:
        return 'Active';
      case PlayerStatus.idle:
        return 'Idle';
      case PlayerStatus.disconnected:
        return 'Disconnected';
    }
  }

  // Theme colors for admin view
  static const Color _void = Color(0xFF090A12);
  static const Color _cyan = Color(0xFF00D4FF);
  static const Color _coral = Color(0xFFE94560);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _surface = Color(0xFF141523);
  static const Color _surfaceAlt = Color(0xFF1C1E2E);

  Widget _buildAdminView() {
    return Scaffold(
      backgroundColor: _void,
      appBar: AppBar(
        title: Text('⚔ ${_lobby!.name}'),
        backgroundColor: _void,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () => _showSnackBar('View Invites'),
            tooltip: 'Invites',
          ),
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () => _showSnackBar('View Team Stats'),
            tooltip: 'Team Stats',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Hexagonal background pattern
          _buildHexagonBackground(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Admin action bar
                _buildAdminActionBar(),
                const SizedBox(height: 16),
                // Player roster
                _buildPlayerRoster(),
                const SizedBox(height: 16),
                // Chat log (expanded)
                Expanded(
                  child: _buildChatLog(),
                ),
                const SizedBox(height: 12),
                // Chat input
                _buildChatInput(),
                const SizedBox(height: 8),
                // Footer status bar
                _buildFooterStatusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: HexagonalGridPainter(
          cellSize: 48,
          strokeColor: _cyan.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildAdminActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.star, size: 18),
              label: const Text('START MIND WAR'),
              onPressed: _startVoting,
              style: ElevatedButton.styleFrom(
                backgroundColor: _cyan,
                foregroundColor: _void,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.close, size: 18),
              label: const Text('CLOSE LOBBY'),
              onPressed: _closeLobby,
              style: ElevatedButton.styleFrom(
                backgroundColor: _coral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRoster() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _lobby!.players.length,
        itemBuilder: (context, index) {
          final player = _lobby!.players[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildPlayerRosterCard(player),
          );
        },
      ),
    );
  }

  Widget _buildPlayerRosterCard(Player player) {
    final isActive = player.status == PlayerStatus.active;
    final borderColor = isActive ? _cyan : Colors.grey[600]!;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: BrandedAvatar(user: player, size: 60),
          ),
          const SizedBox(height: 6),
          Text(
            player.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          if (isActive)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 12, color: _cyan),
                SizedBox(width: 2),
                Text('Active', style: TextStyle(fontSize: 9, color: _cyan)),
              ],
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
                SizedBox(width: 2),
                Text('Waiting', style: TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChatLog() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _surfaceAlt.withOpacity(0.5),
        border: Border.all(color: _cyan.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Placeholder chat log
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildSystemMessage('💬 Lobby opened by ${_lobby!.players.firstWhere((p) => p.id == _lobby!.hostId, orElse: () => _lobby!.players.first).username}'),
                const SizedBox(height: 8),
                _buildSystemMessage('✓ War configuration locked'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.hexagon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: _cyan.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: _cyan.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: _cyan),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _cyan,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, size: 18),
              color: _void,
              onPressed: () {
                if (_chatController.text.isNotEmpty) {
                  _showSnackBar('Message sent: ${_chatController.text}');
                  _chatController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterStatusBar() {
    final maxPlayers = _lobby!.maxPlayers ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _cyan.withOpacity(0.2))),
      ),
      child: Text(
        'Lobby Status: Active | Max Players: ${maxPlayers > 0 ? maxPlayers : 'Unlimited'} | Admin: You',
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _lobby == null) {
      return Scaffold(
        body: Center(child: BrandAnimations.loadingSpinner(size: 64)),
      );
    }

    final isHost = _lobby!.isHost(widget.currentUserId);

    if (isHost) {
      return _buildAdminView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_lobby!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: _navigateToChat,
            tooltip: 'Open Chat',
          ),
          if (isHost)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'settings':
                    _navigateToSettings();
                    break;
                  case 'close':
                    _closeLobby();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Lobby Settings'),
                ),
                const PopupMenuItem(
                  value: 'close',
                  child: Text('Close Lobby'),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
            // Lobby Info Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_lobby!.lobbyCode != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.vpn_key, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _lobby!.lobbyCode!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _copyLobbyCode,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy Code'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.people, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              '${_lobby!.players.length}/${_lobby!.maxPlayers}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Players', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.repeat, color: Colors.purple),
                            const SizedBox(height: 4),
                            Text(
                              '${_lobby!.numberOfRounds}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Rounds', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.how_to_vote, color: Colors.orange),
                            const SizedBox(height: 4),
                            Text(
                              '${_lobby!.votingPointsPerPlayer}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Points', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Players List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _lobby!.players.length,
                itemBuilder: (context, index) {
                  final player = _lobby!.players[index];
                  final isCurrentHost = player.id == _lobby!.hostId;
                  final isTyping = _typingPlayers[player.id] == true;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          BrandedAvatar(
                            avatar: player.avatar,
                            fallbackLabel: player.username[0].toUpperCase(),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: _buildPlayerStatusIcon(player.status),
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              player.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isCurrentHost) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'HOST',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        isTyping
                            ? 'typing...'
                            : _getPlayerStatusText(player.status),
                        style: TextStyle(
                          color: isTyping ? Colors.blue : null,
                          fontStyle: isTyping ? FontStyle.italic : null,
                        ),
                      ),
                      trailing: isHost && player.id != widget.currentUserId
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                switch (value) {
                                  case 'kick':
                                    _kickPlayer(player);
                                    break;
                                  case 'transfer':
                                    _transferHost(player);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'transfer',
                                  child: Text('Make Host'),
                                ),
                                const PopupMenuItem(
                                  value: 'kick',
                                  child: Text('Kick Player'),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (!isHost)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _leaveLobby,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Leave Lobby'),
                      ),
                    ),
                  if (isHost) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _closeLobby,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Close Lobby'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _configureWar,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Config War'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _lobby!.players.length >= 2
                            ? _startVoting
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Start Vote'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_lobby?.payloadLocked ?? false)
                            ? _startGame
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Play!'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
            ),
          ),
          const BuildVersionBadge(),
        ],
      ),
    );
  }
}

/// Hexagonal grid background painter for admin view
class HexagonalGridPainter extends CustomPainter {
  final double cellSize;
  final Color strokeColor;

  HexagonalGridPainter({
    required this.cellSize,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Draw hexagonal grid pattern
    for (double y = 0; y < height; y += cellSize * 0.75) {
      for (double x = 0; x < width; x += cellSize) {
        final offsetX = (y / (cellSize * 0.75)).toInt() % 2 == 1 ? cellSize / 2 : 0;
        _drawHexagon(canvas, paint, x + offsetX, y, cellSize / 2);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, double x, double y, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * 3.14159 / 180;
      final px = x + radius * Math.cos(angle);
      final py = y + radius * Math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexagonalGridPainter oldDelegate) => false;
}
