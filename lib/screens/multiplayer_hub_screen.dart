/**
 * Multiplayer Hub Screen
 * Entry point for multiplayer features - shows current Mind Wars and create/join actions.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/multiplayer_service.dart';
import '../utils/brand_animations.dart';
import '../utils/build_config.dart';
import '../widgets/build_version_badge.dart';

class MultiplayerHubScreen extends StatefulWidget {
  const MultiplayerHubScreen({Key? key}) : super(key: key);

  @override
  State<MultiplayerHubScreen> createState() => _MultiplayerHubScreenState();
}

class _MultiplayerHubScreenState extends State<MultiplayerHubScreen> {
  late final MultiplayerService _multiplayerService;
  late final AuthService _authService;

  bool _isConnecting = true;
  bool _isLoadingWars = false;
  bool _hasConnectionError = false;
  bool _showDebugPanel = false;
  String _statusMessage = 'Connecting to multiplayer server...';
  String? _warsError;
  List<GameLobby> _myLobbies = [];

  // Multi-war system state
  String? _currentUserId;
  bool get _isAtWarLimit => _myLobbies.length >= 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMultiplayer();
    });
  }

  Future<void> _initializeMultiplayer() async {
    _multiplayerService = Provider.of<MultiplayerService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setState(() {
        _statusMessage = 'User not signed in. Please log in again.';
        _hasConnectionError = true;
        _isConnecting = false;
      });
      return;
    }

    _currentUserId = currentUser.id;

    try {
      if (!_multiplayerService.isConnected) {
        final token = await _authService.getValidToken();
        await _multiplayerService.connect(
          BuildConfig.wsBaseUrl,
          currentUser.id,
          token: token,
        );
      }

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Connected as ${currentUser.username}';
        _hasConnectionError = false;
        _isConnecting = false;
      });

      await _loadMyWars();

      // Set up real-time socket listeners for multi-war updates
      _setupSocketListeners();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Unable to connect to multiplayer server';
        _hasConnectionError = true;
        _isConnecting = false;
      });
    }
  }

  void _setupSocketListeners() {
    // Listen for lobby updates
    _multiplayerService.on('lobby-updated', (data) {
      if (!mounted) return;
      try {
        final updatedLobby = GameLobby.fromJson(data as Map<String, dynamic>);
        setState(() {
          final index = _myLobbies.indexWhere((l) => l.id == updatedLobby.id);
          if (index >= 0) {
            _myLobbies[index] = updatedLobby;
          }
        });
      } catch (e) {
        print('Error parsing lobby-updated: $e');
      }
    });

    // Listen for lobby closure
    _multiplayerService.on('lobby-closed', (data) {
      if (!mounted) return;
      final lobbyId = data is Map ? data['lobbyId'] as String? : data as String?;
      if (lobbyId != null) {
        setState(() {
          _myLobbies.removeWhere((l) => l.id == lobbyId);
        });
      }
    });

    // Listen for game start
    _multiplayerService.on('game-started', (data) {
      if (!mounted) return;
      try {
        final updatedLobby = GameLobby.fromJson(data as Map<String, dynamic>);
        setState(() {
          final index = _myLobbies.indexWhere((l) => l.id == updatedLobby.id);
          if (index >= 0) {
            _myLobbies[index] = updatedLobby;
          }
        });
      } catch (e) {
        print('Error parsing game-started: $e');
      }
    });

    // Listen for player joins
    _multiplayerService.on('player-joined', (data) {
      if (!mounted) return;
      try {
        final updatedLobby = GameLobby.fromJson(data as Map<String, dynamic>);
        setState(() {
          final index = _myLobbies.indexWhere((l) => l.id == updatedLobby.id);
          if (index >= 0) {
            _myLobbies[index] = updatedLobby;
          }
        });
      } catch (e) {
        print('Error parsing player-joined: $e');
      }
    });

    // Listen for player leaves
    _multiplayerService.on('player-left', (data) {
      if (!mounted) return;
      try {
        final updatedLobby = GameLobby.fromJson(data as Map<String, dynamic>);
        setState(() {
          final index = _myLobbies.indexWhere((l) => l.id == updatedLobby.id);
          if (index >= 0) {
            _myLobbies[index] = updatedLobby;
          }
        });
      } catch (e) {
        print('Error parsing player-left: $e');
      }
    });

    // Listen for when current user leaves a lobby
    _multiplayerService.on('left-my-lobby', (data) {
      if (!mounted) return;
      final lobbyId = data is Map ? data['lobbyId'] as String? : data as String?;
      if (lobbyId != null) {
        setState(() {
          _myLobbies.removeWhere((l) => l.id == lobbyId);
        });
      }
    });
  }

  Future<void> _loadMyWars() async {
    if (_hasConnectionError) return;

    setState(() {
      _isLoadingWars = true;
      _warsError = null;
    });

    try {
      final lobbies = await _multiplayerService.getMyLobbies();
      if (!mounted) return;
      setState(() {
        _myLobbies = lobbies;
        _isLoadingWars = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _warsError = e.toString().replaceAll('Exception: ', '');
        _isLoadingWars = false;
      });
    }
  }

  Future<void> _resumeLobby(GameLobby lobby) async {
    try {
      await _multiplayerService.joinLobby(lobby.id);
      if (!mounted) return;

      // Route based on lobby status
      if (lobby.status == 'playing') {
        Navigator.pushNamed(context, '/game', arguments: lobby);
      } else {
        // waiting, completed, or other statuses → lobby screen
        Navigator.pushNamed(context, '/lobby');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open Mind War: $e')),
      );
    }
  }

  void _navigateToCreateLobby() {
    Navigator.pushNamed(context, '/create-lobby').then((_) => _loadMyWars());
  }

  void _navigateToJoinMindWar() {
    Navigator.pushNamed(context, '/join-mind-war').then((_) => _loadMyWars());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Wars'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoadingWars ? null : _loadMyWars,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Mind Wars',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Always show status card
                  _buildStatusCard(),
                  const SizedBox(height: 16),

                  // Main content area: wars list or empty state
                  Expanded(
                    child: _myLobbies.isNotEmpty
                        ? _buildWarsListSection()
                        : _buildEmptyState(),
                  ),

                  // War limit warning (if at 10 wars)
                  if (_isAtWarLimit)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade700, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Leave or close at least 1 Mind War to create or join another.',
                              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _myLobbies.isNotEmpty
                                ? 'You can be in up to 10 Mind Wars, but only one waiting planning lobby at a time.'
                                : 'Invite family and friends by sharing the Mind War code.',
                            style: TextStyle(fontSize: 12, color: Colors.amber.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Debug panel
                  if (_showDebugPanel) _buildDebugPanel(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDebugPanel = !_showDebugPanel;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Debug Info',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            _showDebugPanel ? Icons.expand_less : Icons.expand_more,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom actions (always visible)
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
          const BuildVersionBadge(),
        ],
      ),
    );
  }

  Widget _buildWarsListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'My Mind Wars (${_myLobbies.length})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Resume any active war you are part of.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildMyWarsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_isConnecting) {
      return const SizedBox.expand();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const Icon(
            Icons.psychology,
            size: 64,
            color: Color(0xFF6200EE),
          ),
          const SizedBox(height: 16),
          Text(
            'Mind Wars',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Compete asynchronously with friends, family, or new rivals.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildOptionCard(
            context,
            icon: Icons.add_circle_outline,
            title: 'Create Mind War',
            description: 'Start a new round set and invite players.',
            color: Colors.blue,
            onTap: _isConnecting || _hasConnectionError ? null : _navigateToCreateLobby,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            icon: Icons.link,
            title: 'Join Mind War',
            description: 'Enter a code to join an existing war.',
            color: Colors.green,
            onTap: _isConnecting || _hasConnectionError ? null : _navigateToJoinMindWar,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    if (_isConnecting) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            BrandAnimations.loadingSpinner(size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _statusMessage,
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
              ),
            ),
          ],
        ),
      );
    }

    final hasError = _hasConnectionError;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasError ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            hasError ? Icons.error_outline : Icons.check_circle,
            color: hasError ? Colors.red.shade700 : Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 12,
                color: hasError ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyWarsList() {
    if (_isLoadingWars) {
      return Center(child: BrandAnimations.loadingSpinner(size: 42));
    }

    if (_warsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_warsError!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadMyWars,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _myLobbies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildWarCard(_myLobbies[index]);
      },
    );
  }

  String _getStageLabel(GameLobby lobby) {
    switch (lobby.status) {
      case 'waiting':
        return 'Lobby';
      case 'playing':
        return 'Round ${lobby.currentRound}';
      case 'completed':
        return 'Complete';
      default:
        return lobby.status;
    }
  }

  Widget _buildWarCard(GameLobby lobby) {
    final isHost = lobby.hostId == _currentUserId;
    final statusColor = lobby.status == 'waiting' ? Colors.orange : Colors.green;
    final statusIcon = lobby.status == 'waiting' ? Icons.schedule : Icons.play_circle_filled;
    final playerCount = lobby.maxPlayers == null
        ? '${lobby.players.length}/open'
        : '${lobby.players.length}/${lobby.maxPlayers}';
    final stageLabel = _getStageLabel(lobby);

    // Determine CTA button text and color
    final ctaText = lobby.status == 'waiting'
        ? (isHost ? 'Open Lobby' : 'View Lobby')
        : 'Play Round';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Name, Ranked badge, Difficulty chip
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lobby.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (lobby.ranked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RANKED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ),
                          if (lobby.ranked) const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (lobby.difficulty ?? 'medium').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Status dot with icon
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Player count and stage/round progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$playerCount players',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  stageLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                ),
              ],
            ),
            if (lobby.status == 'playing')
              Text(
                'of ${lobby.numberOfRounds} rounds',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),

            const SizedBox(height: 12),

            // Lobby code (when waiting)
            if (lobby.status == 'waiting' && lobby.lobbyCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Code: ${lobby.lobbyCode}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ),

            const SizedBox(height: 12),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _resumeLobby(lobby),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  ctaText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final isDisabled = _isConnecting || _hasConnectionError || _isAtWarLimit;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isDisabled ? null : _navigateToJoinMindWar,
            icon: const Icon(Icons.link),
            label: const Text('Join'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isDisabled ? null : _navigateToCreateLobby,
            icon: const Icon(Icons.add),
            label: const Text('Create'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: onTap != null ? color : Colors.grey),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onTap != null ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: onTap != null ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: onTap != null ? color : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF00FF00),
          fontFamily: 'monospace',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '> Connection Status:',
              style: TextStyle(color: Colors.blue.shade400),
            ),
            Text('  Connected: ${_multiplayerService.isConnected}'),
            Text('  Connecting: $_isConnecting'),
            Text('  Error: $_hasConnectionError'),
            Text('  My Wars: ${_myLobbies.length}'),
            const SizedBox(height: 8),
            Text(
              '> Server Details:',
              style: TextStyle(color: Colors.blue.shade400),
            ),
            Text('  URL: ${BuildConfig.wsBaseUrl}'),
            Text('  User ID: ${_authService.currentUser?.id ?? "N/A"}'),
            const SizedBox(height: 8),
            Text(
              '> Status: $_statusMessage',
              style: TextStyle(
                color: _hasConnectionError ? Colors.red.shade300 : Colors.green.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
