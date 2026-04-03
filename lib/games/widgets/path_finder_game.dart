/**
 * Path Finder Game Widget - Alpha Implementation
 * Navigate mazes and find optimal paths
 * 
 * Category: Spatial
 * Players: 2-6
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class PathFinderGame extends BaseGameWidget {
  const PathFinderGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<PathFinderGame> createState() => _PathFinderGameState();
}

class _PathFinderGameState extends BaseGameState<PathFinderGame> {
  late List<List<int>> _maze;
  late int _playerRow;
  late int _playerCol;
  late int _exitRow;
  late int _exitCol;
  int _moves = 0;
  int _level = 1;
  final int _gridSize = 8;

  @override
  void initState() {
    super.initState();
    _generateMaze();
  }

  void _generateMaze() {
    final random = Random();
    const maxAttempts = 100;
    int attempts = 0;
    bool solvable = false;

    // Scale difficulty by level: more walls per level
    final wallCount = _level == 1 ? 16 : _level == 2 ? 24 : 32;

    while (!solvable && attempts < maxAttempts) {
      // Generate empty maze
      _maze = List.generate(_gridSize, (_) => List.filled(_gridSize, 0));

      // Add random walls scaled by difficulty
      final addedWalls = <String>{};
      while (addedWalls.length < wallCount) {
        final row = random.nextInt(_gridSize);
        final col = random.nextInt(_gridSize);
        final key = '$row,$col';
        // Avoid start and end positions
        if ((row != 0 || col != 0) && (row != _gridSize - 1 || col != _gridSize - 1)) {
          addedWalls.add(key);
        }
      }

      for (var wallPos in addedWalls) {
        final parts = wallPos.split(',');
        final row = int.parse(parts[0]);
        final col = int.parse(parts[1]);
        _maze[row][col] = 1;
      }

      // Set start and end
      _playerRow = 0;
      _playerCol = 0;
      _exitRow = _gridSize - 1;
      _exitCol = _gridSize - 1;
      _maze[_playerRow][_playerCol] = 0;
      _maze[_exitRow][_exitCol] = 0;
      _moves = 0;

      solvable = _hasPathBFS();
      attempts++;
    }

    // If not solvable after maxAttempts, fallback to empty maze
    if (!solvable) {
      _maze = List.generate(_gridSize, (_) => List.filled(_gridSize, 0));
      _playerRow = 0;
      _playerCol = 0;
      _exitRow = _gridSize - 1;
      _exitCol = _gridSize - 1;
      _moves = 0;
    }

    setState(() {});
  }

  // BFS to check if a path exists from start to exit
  bool _hasPathBFS() {
    final visited = List.generate(_gridSize, (_) => List.filled(_gridSize, false));
    final queue = <List<int>>[];
    queue.add([_playerRow, _playerCol]);
    visited[_playerRow][_playerCol] = true;

    final directions = [
      [0, 1],
      [1, 0],
      [0, -1],
      [-1, 0],
    ];

    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      final row = pos[0];
      final col = pos[1];

      if (row == _exitRow && col == _exitCol) {
        return true;
      }

      for (final dir in directions) {
        final newRow = row + dir[0];
        final newCol = col + dir[1];
        if (newRow >= 0 &&
            newRow < _gridSize &&
            newCol >= 0 &&
            newCol < _gridSize &&
            _maze[newRow][newCol] == 0 &&
            !visited[newRow][newCol]) {
          visited[newRow][newCol] = true;
          queue.add([newRow, newCol]);
        }
      }
    }
    return false;
  }
  void _movePlayer(int dRow, int dCol) {
    final newRow = _playerRow + dRow;
    final newCol = _playerCol + dCol;
    
    if (newRow >= 0 && newRow < _gridSize && newCol >= 0 && newCol < _gridSize) {
      if (_maze[newRow][newCol] == 0) {
        setState(() {
          _playerRow = newRow;
          _playerCol = newCol;
          _moves++;
        });
        
        if (_playerRow == _exitRow && _playerCol == _exitCol) {
          final points = 30 - _moves.clamp(0, 20);
          addScore(points);
          showMessage('Maze complete! +$points points', success: true);
          _level++;

          if (_level > 3) {
            completeGame();
          } else {
            _generateMaze();
          }
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
                    'Moves: $_moves',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridSize,
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _gridSize * _gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ _gridSize;
                final col = index % _gridSize;
                final isPlayer = row == _playerRow && col == _playerCol;
                final isExit = row == _exitRow && col == _exitCol;
                final isWall = _maze[row][col] == 1;
                
                return Container(
                  decoration: BoxDecoration(
                    color: isPlayer
                        ? Colors.blue
                        : isExit
                            ? Colors.green
                            : isWall
                                ? Colors.grey[800]
                                : Colors.grey[200],
                  ),
                  child: Center(
                    child: Text(
                      isPlayer ? '🎯' : isExit ? '🏁' : '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton.filled(
                    onPressed: () => _movePlayer(-1, 0),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: () => _movePlayer(0, -1),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 48),
                      IconButton.filled(
                        onPressed: () => _movePlayer(0, 1),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  IconButton.filled(
                    onPressed: () => _movePlayer(1, 0),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
