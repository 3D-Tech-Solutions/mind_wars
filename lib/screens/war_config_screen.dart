import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/multiplayer_service.dart';
import '../games/game_catalog.dart';

class WarConfigScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;
  final String lobbyId;
  final int totalRounds;

  const WarConfigScreen({
    Key? key,
    required this.multiplayerService,
    required this.lobbyId,
    required this.totalRounds,
  }) : super(key: key);

  @override
  State<WarConfigScreen> createState() => _WarConfigScreenState();
}

class _WarConfigScreenState extends State<WarConfigScreen> {
  String _difficulty = 'medium';
  String _hintPolicy = 'enabled';
  bool _ranked = false;
  bool _useGamePack = true;
  String _selectedPack = 'Family Battle Pack';
  Set<String> _manualGameIds = {};
  bool _isSaving = false;

  // Game packs definition
  final Map<String, List<String>> gamePacks = {
    'Family Battle Pack': [
      'memory_match',
      'word_builder',
      'anagram_attack',
      'spot_difference',
      'color_rush'
    ],
    'Brain Boost Pack': [
      'sudoku_duel',
      'logic_grid',
      'code_breaker',
      'sequence_recall',
      'pattern_memory'
    ],
    'Speed Round Pack': [
      'color_rush',
      'spot_difference',
      'focus_finder',
      'sequence_recall',
      'rotation_master'
    ],
    'Language Master Pack': [
      'word_builder',
      'anagram_attack',
      'vocabulary_showdown',
      'path_finder',
      'puzzle_race'
    ],
    'Logic Challenge Pack': [
      'sudoku_duel',
      'logic_grid',
      'code_breaker',
      'path_finder',
      'puzzle_race'
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Mind War'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveConfig,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Difficulty selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Difficulty',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['easy', 'medium', 'hard'].map((level) {
                      final isSelected = _difficulty == level;
                      return ChoiceChip(
                        label: Text(level.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _difficulty = level);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hint policy selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hint Policy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Disabled: No hints (Pure leaderboard)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Text(
                    'Enabled: Hints allowed (Standard leaderboard)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Text(
                    'Assisted: Hints encouraged (Assisted leaderboard)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['disabled', 'enabled', 'assisted'].map((policy) {
                      final isSelected = _hintPolicy == policy;
                      return ChoiceChip(
                        label: Text(policy.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _hintPolicy = policy);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ranked toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ranked Match',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _ranked ? 'Scores will be saved to leaderboard' : 'Casual practice',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Switch(
                    value: _ranked,
                    onChanged: (value) => setState(() => _ranked = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Game pool selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Game Pool',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Pack selector
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Game Packs'),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Manual'),
                      ),
                    ],
                    selected: <bool>{_useGamePack},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() => _useGamePack = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_useGamePack)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select a preset pack:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        ...gamePacks.keys.map((packName) {
                          final isSelected = _selectedPack == packName;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                              child: ListTile(
                                title: Text(packName),
                                subtitle: Text(
                                  '${gamePacks[packName]!.length} games',
                                ),
                                trailing:
                                    isSelected ? const Icon(Icons.check) : null,
                                onTap: () {
                                  setState(() => _selectedPack = packName);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select games:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: GameCatalog.getAllGames().take(widget.totalRounds).map((game) {
                            final isSelected = _manualGameIds.contains(game.id);
                            return FilterChip(
                              label: Text(game.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _manualGameIds.add(game.id);
                                  } else {
                                    _manualGameIds.remove(game.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);

    try {
      final gamePack = _useGamePack ? _selectedPack : null;
      final manualGameIds =
          _useGamePack ? <String>[] : _manualGameIds.toList();

      await widget.multiplayerService.updateWarConfig(
        lobbyId: widget.lobbyId,
        difficulty: _difficulty,
        hintPolicy: _hintPolicy,
        ranked: _ranked,
        gamePack: gamePack,
        manualGameIds: manualGameIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('War configuration saved!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
