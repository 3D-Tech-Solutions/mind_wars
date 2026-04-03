/**
 * Puzzle Race Game Widget - Alpha Implementation
 * Complete sliding puzzles against the clock
 * 
 * Category: Spatial
 * Players: 2-4
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class PuzzleRaceGame extends BaseGameWidget {
  const PuzzleRaceGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<PuzzleRaceGame> createState() => _PuzzleRaceGameState();
}

class _PuzzleRaceGameState extends BaseGameState<PuzzleRaceGame> {
  late List<int> _tiles;
  int _gridSize = 3;
  int _emptyIndex = 8;
  int _moves = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    // Scale grid size and difficulty by level
    if (_level == 1) {
      _gridSize = 3; // 3x3 for level 1
    } else if (_level == 2) {
      _gridSize = 4; // 4x4 for level 2
    } else {
      _gridSize = 4; // 4x4 for level 3 (harder shuffle)
    }

    final totalTiles = _gridSize * _gridSize;
    _tiles = List.generate(totalTiles - 1, (i) => i + 1);
    _tiles.add(0); // 0 represents empty space

    // Shuffle with difficulty scaling
    // Level 1: 100 shuffles, Level 2: 120 shuffles, Level 3: 150 shuffles
    final shuffleCount = _level == 1 ? 100 : _level == 2 ? 120 : 150;

    // Shuffle by making random valid moves (ensures solvability)
    final random = Random();
    _emptyIndex = totalTiles - 1; // Reset empty position to bottom-right
    for (var i = 0; i < shuffleCount; i++) {
      final validMoves = _getValidMoves();
      if (validMoves.isNotEmpty) {
        final moveIndex = validMoves[random.nextInt(validMoves.length)];
        _tiles[_emptyIndex] = _tiles[moveIndex];
        _tiles[moveIndex] = 0;
        _emptyIndex = moveIndex;
      }
    }

    _moves = 0;
    setState(() {});
  }

  List<int> _getValidMoves() {
    final moves = <int>[];
    final row = _emptyIndex ~/ _gridSize;
    final col = _emptyIndex % _gridSize;
    
    if (row > 0) moves.add(_emptyIndex - _gridSize); // Up
    if (row < _gridSize - 1) moves.add(_emptyIndex + _gridSize); // Down
    if (col > 0) moves.add(_emptyIndex - 1); // Left
    if (col < _gridSize - 1) moves.add(_emptyIndex + 1); // Right
    
    return moves;
  }

  void _moveTile(int index) {
    if (_getValidMoves().contains(index)) {
      setState(() {
        _tiles[_emptyIndex] = _tiles[index];
        _tiles[index] = 0;
        _emptyIndex = index;
        _moves++;
      });
      
      if (_isPuzzleSolved()) {
        final points = 40 - _moves.clamp(0, 30);
        addScore(points);
        showMessage('Solved! +$points points', success: true);
        _level++;

        if (_level > 3) {
          completeGame();
        } else {
          _generatePuzzle();
        }
      }
    }
  }

  bool _isPuzzleSolved() {
    for (var i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) return false;
    }
    return _tiles.last == 0;
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
                    'Moves: $_moves',
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
                final tile = _tiles[index];
                
                return GestureDetector(
                  onTap: () => _moveTile(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tile == 0
                          ? Colors.grey[300]
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tile == 0 ? '' : tile.toString(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
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
