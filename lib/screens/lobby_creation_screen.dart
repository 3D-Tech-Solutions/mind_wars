/**
 * Lobby Creation Screen - Feature 2.1
 * Allows users to create a new game lobby with configuration options
 */

import 'package:flutter/material.dart';
import '../services/multiplayer_service.dart';
import '../utils/brand_animations.dart';
import '../widgets/build_version_badge.dart';

class LobbyCreationScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;

  const LobbyCreationScreen({
    Key? key,
    required this.multiplayerService,
  }) : super(key: key);

  @override
  State<LobbyCreationScreen> createState() => _LobbyCreationScreenState();
}

class _LobbyCreationScreenState extends State<LobbyCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isCreating = false;
  String? _errorMessage;
  bool _isPlayerCapOpen = true;
  int _maxPlayers = 12;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createLobby() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final lobby = await widget.multiplayerService.createLobby(
        name: _nameController.text.trim(),
        maxPlayers: _isPlayerCapOpen ? null : _maxPlayers,
      );

      if (!mounted) return;

      // Navigate to lobby screen with the created lobby
      Navigator.of(context).pushReplacementNamed(
        '/lobby',
        arguments: lobby,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lobby'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Header
                  const Text(
                    'Create Your Game Lobby',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set up your lobby and invite family and friends to play',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lobby Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Mind War Name',
                      hintText: 'e.g., Smith Family Challenge',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      if (value.trim().length > 50) {
                        return 'Name must be less than 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Player Capacity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mind Wars need at least 2 players, but you can leave the upper limit open or set a cap.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Open Capacity'),
                            subtitle: const Text('Allow any number of players to join'),
                            value: _isPlayerCapOpen,
                            onChanged: (value) {
                              setState(() {
                                _isPlayerCapOpen = value;
                              });
                            },
                          ),
                          if (!_isPlayerCapOpen) ...[
                            Slider(
                              value: _maxPlayers.toDouble(),
                              min: 2,
                              max: 100,
                              divisions: 98,
                              label: _maxPlayers.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _maxPlayers = value.round();
                                });
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Cap: $_maxPlayers players',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
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

                  // Create Button
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createLobby,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isCreating
                        ? BrandAnimations.loadingSpinner(size: 20)
                        : const Text(
                            'Create Lobby',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Info Text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You\'ll get a code to share with other players to join',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BuildVersionBadge(),
        ],
      ),
    );
  }
}
