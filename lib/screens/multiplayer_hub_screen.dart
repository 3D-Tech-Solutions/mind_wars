/**
 * Multiplayer Hub Screen
 * Entry point for multiplayer features - allows creating or joining Mind Wars
 * Handles WebSocket connection initialization
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/multiplayer_service.dart';
import '../services/auth_service.dart';
import '../utils/brand_animations.dart';
import '../utils/build_config.dart';

class MultiplayerHubScreen extends StatefulWidget {
  const MultiplayerHubScreen({Key? key}) : super(key: key);

  @override
  State<MultiplayerHubScreen> createState() => _MultiplayerHubScreenState();
}

class _MultiplayerHubScreenState extends State<MultiplayerHubScreen> {
  late final MultiplayerService _multiplayerService;
  late final AuthService _authService;
  bool _isConnecting = true;
  bool _hasConnectionError = false;
  String _statusMessage = 'Connecting to multiplayer server...';
  bool _showDebugPanel = false;

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

    try {
      if (!_multiplayerService.isConnected) {
        // Get JWT token from auth service
        final token = await _authService.getValidToken();
        print('[MultiplayerHubScreen] Got token for socket.io: ${token != null}');

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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Unable to connect to multiplayer server';
        _hasConnectionError = true;
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 40),
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
                'Compete with friends and family',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Connection Status
              if (_isConnecting)
                Container(
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_hasConnectionError)
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
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Create Mind War Card
              _buildOptionCard(
                context,
                icon: Icons.add_circle_outline,
                title: 'Create Mind War',
                description: 'Start a new game and invite others',
                color: Colors.blue,
                onTap: _isConnecting || _hasConnectionError
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/create-lobby');
                      },
              ),

              const SizedBox(height: 16),

              // Join Mind War Card
              _buildOptionCard(
                context,
                icon: Icons.link,
                title: 'Join Mind War',
                description: 'Enter a code to join an existing game',
                color: Colors.green,
                onTap: _isConnecting || _hasConnectionError
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/join-mind-war');
                      },
              ),

              const Spacer(),

              // Info Text
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
                        'Invite family and friends by sharing the game code.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Debug Panel Toggle
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

              // Debug Panel Content
              if (_showDebugPanel) ...[
                const SizedBox(height: 8),
                Container(
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
                            color: _hasConnectionError
                                ? Colors.red.shade300
                                : Colors.green.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
}
