/**
 * Lobby Creation Screen - Feature 2.1
 * Allows users to create a new game lobby with configuration options
 */

import 'package:flutter/material.dart';
import '../services/multiplayer_service.dart';
import '../utils/brand_animations.dart';

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

  int _maxPlayers = 4;
  bool _isPrivate = true;
  int _numberOfRounds = 3;
  int _votingPointsPerPlayer = 10;
  bool _isCreating = false;
  String? _errorMessage;

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
        maxPlayers: _maxPlayers,
        isPrivate: _isPrivate,
        numberOfRounds: _numberOfRounds,
        votingPointsPerPlayer: _votingPointsPerPlayer,
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
      body: SafeArea(
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
                  labelText: 'Lobby Name',
                  hintText: 'e.g., Smith Family Game Night',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a lobby name';
                  }
                  if (value.trim().length < 3) {
                    return 'Lobby name must be at least 3 characters';
                  }
                  if (value.trim().length > 50) {
                    return 'Lobby name must be less than 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Max Players Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Max Players',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$_maxPlayers',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _maxPlayers.toDouble(),
                        min: 2,
                        max: 10,
                        divisions: 8,
                        label: '$_maxPlayers players',
                        onChanged: (value) {
                          setState(() {
                            _maxPlayers = value.toInt();
                          });
                        },
                      ),
                      const Text(
                        '2-10 players',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Privacy Toggle
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Private Lobby',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _isPrivate
                        ? 'Only players with the code can join'
                        : 'Anyone can see and join this lobby',
                  ),
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                  secondary: Icon(
                    _isPrivate ? Icons.lock : Icons.public,
                    color: _isPrivate ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Number of Rounds
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.repeat, color: Colors.purple),
                          const SizedBox(width: 8),
                          const Text(
                            'Number of Rounds',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$_numberOfRounds',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _numberOfRounds.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_numberOfRounds rounds',
                        onChanged: (value) {
                          setState(() {
                            _numberOfRounds = value.toInt();
                          });
                        },
                      ),
                      const Text(
                        '1-10 rounds',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Voting Points
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.how_to_vote, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Voting Points per Player',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$_votingPointsPerPlayer',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _votingPointsPerPlayer.toDouble(),
                        min: 5,
                        max: 20,
                        divisions: 15,
                        label: '$_votingPointsPerPlayer points',
                        onChanged: (value) {
                          setState(() {
                            _votingPointsPerPlayer = value.toInt();
                          });
                        },
                      ),
                      const Text(
                        '5-20 points for voting on games',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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
                        _isPrivate
                            ? 'You\'ll receive a shareable code to invite players'
                            : 'Your lobby will be visible to all players',
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
    );
  }
}
