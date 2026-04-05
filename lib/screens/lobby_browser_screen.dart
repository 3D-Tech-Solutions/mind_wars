/**
 * Lobby Browser Screen - Feature 2.2
 * Allows users to join lobbies via code or browse public lobbies
 */

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/multiplayer_service.dart';
import '../utils/brand_animations.dart';

class LobbyBrowserScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;

  const LobbyBrowserScreen({
    Key? key,
    required this.multiplayerService,
  }) : super(key: key);

  @override
  State<LobbyBrowserScreen> createState() => _LobbyBrowserScreenState();
}

class _LobbyBrowserScreenState extends State<LobbyBrowserScreen> {
  final _codeController = TextEditingController();
  List<GameLobby> _publicLobbies = [];
  bool _isLoading = false;
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPublicLobbies();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadPublicLobbies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lobbies = await widget.multiplayerService.getAvailableLobbies(
        status: 'waiting',
        isPrivate: false,
      );

      if (!mounted) return;
      setState(() {
        _publicLobbies = lobbies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _joinLobbyByCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a lobby code';
      });
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      final lobby = await widget.multiplayerService.joinLobbyByCode(code);

      if (!mounted) return;

      // Navigate to lobby screen
      Navigator.of(context).pushReplacementNamed(
        '/lobby',
        arguments: lobby,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isJoining = false;
      });
    }
  }

  Future<void> _joinLobby(GameLobby lobby) async {
    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      final joinedLobby = await widget.multiplayerService.joinLobby(lobby.id);

      if (!mounted) return;

      // Navigate to lobby screen
      Navigator.of(context).pushReplacementNamed(
        '/lobby',
        arguments: joinedLobby,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isJoining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Lobby'),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header
            const Text(
              'Join a Game',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter a lobby code or browse public lobbies',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Join with Code Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.vpn_key, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Join with Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Lobby Code',
                        hintText: 'e.g., FAMILY42',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.tag),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _joinLobbyByCode(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isJoining ? null : _joinLobbyByCode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isJoining
                            ? BrandAnimations.loadingSpinner(size: 20)
                            : const Text('Join Lobby'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            // Divider
            const Divider(height: 32),

            // Public Lobbies Section
            Row(
              children: [
                const Icon(Icons.public, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Public Lobbies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadPublicLobbies,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Loading or Empty State
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: BrandAnimations.loadingSpinner(size: 64),
                ),
              )
            else if (_publicLobbies.isEmpty)
              Container(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: const [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No public lobbies available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your own or join with a code',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Lobby List
              ...(_publicLobbies.map((lobby) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          lobby.maxPlayers == null
                              ? '${lobby.players.length}/Open'
                              : '${lobby.players.length}/${lobby.maxPlayers}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        lobby.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        lobby.maxPlayers == null
                            ? '${lobby.players.length} players • ${lobby.numberOfRounds} rounds • Open lobby'
                            : '${lobby.players.length} of ${lobby.maxPlayers} players • ${lobby.numberOfRounds} rounds',
                      ),
                      trailing: ElevatedButton(
                        onPressed: lobby.canJoin && !_isJoining
                            ? () => _joinLobby(lobby)
                            : null,
                        child: Text(lobby.isFull ? 'Full' : 'Join'),
                      ),
                    ),
                  ))),
          ],
        ),
      ),
    );
  }
}
