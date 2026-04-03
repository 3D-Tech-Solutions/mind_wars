/**
 * Color Rush Game Widget
 * Match colors under time pressure
 * 
 * Category: Attention
 * Players: 2-10
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class ColorRushGame extends BaseGameWidget {
  const ColorRushGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<ColorRushGame> createState() => _ColorRushGameState();
}

class _ColorRushGameState extends BaseGameState<ColorRushGame> {
  late Color _targetColor;
  late List<Color> _colorGrid;
  late int _level;
  int _combo = 0;
  int _timeRemaining = 3;
  bool _timerActive = false;

  final List<Color> _baseColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _level = 1;
    _combo = 0;
    _generateRound();
  }

  void _generateRound() {
    final random = Random();
    _targetColor = _baseColors[random.nextInt(_baseColors.length)];

    final gridSize = 16;
    // Ensure exactly 2 instances of the target color
    final nonTargetColors = _baseColors.where((c) => c != _targetColor).toList();
    final List<Color> gridColors = [];
    gridColors.addAll(List.filled(2, _targetColor));
    for (int i = 0; i < gridSize - 2; i++) {
      gridColors.add(nonTargetColors[random.nextInt(nonTargetColors.length)]);
    }
    gridColors.shuffle(random);
    _colorGrid = gridColors;

    setState(() {
      // Scale time pressure by level: Level 1: 3s, Level 2: 2s, Level 3: 1s
      _timeRemaining = _level == 1 ? 3 : _level == 2 ? 2 : 1;
      _timerActive = true;
    });

    _startTimer();
  }

  void _startTimer() async {
    while (_timeRemaining > 0 && _timerActive) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_timerActive) {
        break;
      }
      setState(() {
        _timeRemaining--;
      });

      if (_timeRemaining == 0) {
        _timerActive = false;
        _handleTimeout();
        break;
      }
    }
  }

  void _selectColor(Color selectedColor) {
    _timerActive = false;
    
    // Compare color values to avoid issues with different Color object constructions.
    // Assumption: selectedColor and _targetColor are from _baseColors, but this is future-proof.
    if (selectedColor.value == _targetColor.value) {
      _combo++;
      final points = 5 + (_combo * 2);
      addScore(points);
      showMessage('Correct! +$points points (${_combo}x combo)', success: true);
      _level++;

      if (_level > 3) {
        completeGame();
      } else {
        _generateRound();
      }
    } else {
      _combo = 0;
      showMessage('Wrong color! Combo reset');
      _generateRound();
    }
  }

  void _handleTimeout() {
    _combo = 0;
    showMessage('Time\'s up! Combo reset');
    _generateRound();
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
                    'Combo: ${_combo}x',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _combo > 0 ? Colors.orange : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: $_timeRemaining sec',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Find this color:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _targetColor,
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _colorGrid.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _selectColor(_colorGrid[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colorGrid[index],
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(12),
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
