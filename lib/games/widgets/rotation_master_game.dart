/**
 * Rotation Master Game Widget - Alpha Implementation
 * Identify rotated shapes and objects
 * 
 * Category: Spatial
 * Players: 2-8
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class RotationMasterGame extends BaseGameWidget {
  const RotationMasterGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<RotationMasterGame> createState() => _RotationMasterGameState();
}

class _RotationMasterGameState extends BaseGameState<RotationMasterGame> {
  late String _targetShape;
  late double _targetRotation;
  late int _correctOption;
  late List<double> _options;
  int _streak = 0;
  int _level = 1;

  final List<String> _shapes = ['F', 'R', 'P', 'L', 'Z', 'N', 'G', 'J'];

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    final random = Random();
    _targetShape = _shapes[random.nextInt(_shapes.length)];
    _targetRotation = (random.nextInt(4) * 90).toDouble();

    // Generate all possible rotations
    List<double> allRotations = [0, 90, 180, 270];
    // Remove the target rotation to get distractors
    List<double> distractors = List.from(allRotations)..remove(_targetRotation);
    // Shuffle distractors and pick three
    distractors.shuffle(random);
    List<double> options = distractors.take(3).toList();
    // Insert the correct answer at a random position
    _correctOption = random.nextInt(4);
    options.insert(_correctOption, _targetRotation);
    _options = options;
    setState(() {});
  }

  void _selectOption(int optionIndex) {
    if (optionIndex == _correctOption) {
      _streak++;
      final points = 10 + (_streak * 2);
      addScore(points);
      showMessage('Correct! +$points points (${_streak}x streak)', success: true);
      _level++;

      if (_level > 3) {
        completeGame();
      } else {
        _generateRound();
      }
    } else {
      _streak = 0;
      showMessage('Wrong! Streak reset');
      _generateRound();
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
                    'Streak: ${_streak}x',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _streak > 0 ? Colors.green : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Find the matching rotation:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Transform.rotate(
                angle: _targetRotation * pi / 180,
                child: Text(
                  _targetShape,
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _selectOption(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: _options[index] * pi / 180,
                        child: Text(
                          _targetShape,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
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
