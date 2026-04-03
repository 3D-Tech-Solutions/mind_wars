/**
 * Pattern Memory Game Widget
 * Remember complex visual patterns and recreate them
 * 
 * Category: Memory
 * Players: 2-8
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class PatternMemoryGame extends BaseGameWidget {
  const PatternMemoryGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<PatternMemoryGame> createState() => _PatternMemoryGameState();
}

class _PatternMemoryGameState extends BaseGameState<PatternMemoryGame> {
  late int _level;
  late int _gridSize;
  late List<bool> _pattern;
  late List<bool> _userPattern;
  bool _showingPattern = true;
  int _viewTimeRemaining = 3;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _level = 1;
    _gridSize = 4; // 4x4 grid for level 1
    _generatePattern();
    _showPattern();
  }

  void _generatePattern() {
    // Scale grid size and pattern complexity by level
    if (_level == 1) {
      _gridSize = 4; // 4x4 grid
    } else if (_level == 2) {
      _gridSize = 4; // 4x4 grid
    } else {
      _gridSize = 5; // 5x5 grid for hard
    }

    final totalCells = _gridSize * _gridSize;
    // Scale fill count: level 1: 5, level 2: 7, level 3: 10
    final fillCount = _level == 1 ? 5 : _level == 2 ? 7 : 10;

    _pattern = List.filled(totalCells, false);
    _userPattern = List.filled(totalCells, false);

    final random = Random();
    final indices = List.generate(totalCells, (i) => i)..shuffle(random);

    for (var i = 0; i < fillCount; i++) {
      _pattern[indices[i]] = true;
    }
  }

  void _showPattern() async {
    setState(() {
      _showingPattern = true;
      _viewTimeRemaining = 3 + _level;
    });

    for (var i = 0; i < _viewTimeRemaining; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _viewTimeRemaining--;
        });
      }
    }

    if (mounted) {
      setState(() {
        _showingPattern = false;
      });
    }
  }

  void _toggleCell(int index) {
    if (!_showingPattern) {
      setState(() {
        _userPattern[index] = !_userPattern[index];
      });
    }
  }

  void _checkPattern() {
    int correct = 0;
    for (var i = 0; i < _pattern.length; i++) {
      if (_pattern[i] == _userPattern[i]) correct++;
    }

    final accuracy = (correct / _pattern.length * 100).round();
    
    if (accuracy == 100) {
      addScore(20 + _level * 5);
      showMessage('Perfect! +${20 + _level * 5} points', success: true);
      _level++;
      if (_level > 3) {
        completeGame();
      } else {
        _generatePattern();
        _showPattern();
      }
    } else if (accuracy >= 75) {
      addScore(10);
      showMessage('Good! $accuracy% accurate. +10 points', success: true);
      _generatePattern();
      _showPattern();
    } else {
      showMessage('Try again! Only $accuracy% accurate');
      setState(() {
        _userPattern = List.filled(_gridSize * _gridSize, false);
      });
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
                  const SizedBox(height: 8),
                  Text(
                    _showingPattern
                        ? 'Memorize the pattern! ($_viewTimeRemaining sec)'
                        : 'Recreate the pattern!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridSize,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _gridSize * _gridSize,
              itemBuilder: (context, index) {
                final shouldShow = _showingPattern ? _pattern[index] : _userPattern[index];
                
                return GestureDetector(
                  onTap: () => _toggleCell(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: shouldShow 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (!_showingPattern) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _checkPattern,
              icon: const Icon(Icons.check),
              label: const Text('Submit Pattern'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
