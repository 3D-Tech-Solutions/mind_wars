/**
 * Focus Finder Game Widget - Alpha Implementation
 * Locate specific items in cluttered scenes
 * 
 * Category: Attention
 * Players: 2-6
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class FocusFinderGame extends BaseGameWidget {
  const FocusFinderGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<FocusFinderGame> createState() => _FocusFinderGameState();
}

class _FocusFinderGameState extends BaseGameState<FocusFinderGame> {
  late List<String> _allItems;
  late List<String> _targets;
  late Set<String> _found;
  int _level = 1;

  final List<String> _itemPool = [
    '⭐', '🎯', '🎨', '🎭', '🎪', '🎸', '🎹', '🎺',
    '🏀', '⚽', '🏈', '⚾', '🎾', '🏐', '🏓', '🏸',
    '🍎', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🍑',
  ];

  @override
  void initState() {
    super.initState();
    _generateScene();
  }

  void _generateScene() {
    final random = Random();

    // Scale difficulty: more targets and fewer distractors per level
    final targetCount = 2 + _level; // Level 1: 3, Level 2: 4, Level 3: 5
    final distractorCount = 20 - _level; // Level 1: 19, Level 2: 18, Level 3: 17

    // Select targets
    final shuffled = List<String>.from(_itemPool)..shuffle(random);
    _targets = shuffled.take(targetCount).toList();

    // Create scene with targets and distractors
    _allItems = [];
    for (var target in _targets) {
      _allItems.add(target);
    }

    // Add more distractors, ensuring no overlap with targets
    final distractorPool = List<String>.from(_itemPool)
      ..removeWhere((item) => _targets.contains(item));
    distractorPool.shuffle(random);
    final distractors = distractorPool.take(distractorCount).toList();
    _allItems.addAll(distractors);
    _allItems.shuffle(random);

    _found = {};
    setState(() {});
  }

  void _tapItem(String item) {
    if (_targets.contains(item) && !_found.contains(item)) {
      setState(() {
        _found.add(item);
      });
      
      addScore(15);
      showMessage('Found! ${_found.length}/${_targets.length}', success: true);
      
      if (_found.length == _targets.length) {
        _level++;
        if (_level > 3) {
          completeGame();
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _generateScene();
          });
        }
      }
    }
  }

  @override
  Widget buildGame(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Level $_level',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Find these items:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _targets.map((item) {
                      final found = _found.contains(item);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: found ? Colors.green[100] : null,
                            border: Border.all(
                              color: found ? Colors.green : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 32,
                              decoration: found ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _allItems.length,
              itemBuilder: (context, index) {
                final item = _allItems[index];
                
                return GestureDetector(
                  onTap: () => _tapItem(item),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
