/**
 * Spot the Difference Game Widget - Alpha Implementation
 * Find differences between similar patterns
 * 
 * Category: Attention
 * Players: 2-8
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class SpotDifferenceGame extends BaseGameWidget {
  const SpotDifferenceGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<SpotDifferenceGame> createState() => _SpotDifferenceGameState();
}

class _SpotDifferenceGameState extends BaseGameState<SpotDifferenceGame> {
  late List<bool> _pattern1;
  late List<bool> _pattern2;
  late List<int> _differences;
  late Set<int> _found;
  int _level = 1;
  final int _gridSize = 6;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    final random = Random();
    final totalCells = _gridSize * _gridSize;

    _pattern1 = List.generate(totalCells, (_) => random.nextBool());
    _pattern2 = List.from(_pattern1);

    // Scale differences by level
    final diffCount = _level == 1 ? 5 : _level == 2 ? 7 : 9;

    _differences = [];
    final available = List.generate(totalCells, (i) => i)..shuffle(random);

    for (var i = 0; i < diffCount; i++) {
      final index = available[i];
      _pattern2[index] = !_pattern2[index];
      _differences.add(index);
    }

    _found = {};
    setState(() {});
  }

  void _tapCell(int index) {
    if (_differences.contains(index) && !_found.contains(index)) {
      setState(() {
        _found.add(index);
      });
      
      addScore(10);
      showMessage('Found! ${_found.length}/${_differences.length}', success: true);
      
      if (_found.length == _differences.length) {
        _level++;
        if (_level > 3) {
          completeGame();
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _generatePuzzle();
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
                  const SizedBox(height: 8),
                  Text(
                    'Found: ${_found.length}/${_differences.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: _pattern1[index] ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) {
                      final isFound = _found.contains(index);
                      
                      return GestureDetector(
                        onTap: () => _tapCell(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _pattern2[index] ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                            border: isFound
                                ? Border.all(color: Colors.green, width: 3)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
