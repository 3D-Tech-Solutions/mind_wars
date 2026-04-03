/**
 * Sequence Recall Game Widget
 * Remember and reproduce increasingly long sequences
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class SequenceRecallGame extends BaseGameWidget {
  const SequenceRecallGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<SequenceRecallGame> createState() => _SequenceRecallGameState();
}

class _SequenceRecallGameState extends BaseGameState<SequenceRecallGame> {
  late List<int> _sequence;
  late List<int> _userSequence;
  bool _sequenceShowing = false;
  int _level = 1;
  int? _currentFlashingButton;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    // Auto-show sequence after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showSequence();
      }
    });
  }

  void _initializeGame() {
    _level = 1;
    _sequence = [];
    _userSequence = [];
    _sequenceShowing = false;
    _currentFlashingButton = null;
    _generateSequence();
  }

  void _generateSequence() {
    _sequence = List.generate(
      3 + _level,
      (index) => Random().nextInt(4),
    );
    _userSequence = [];
  }

  Future<void> showSequence() async {
    setState(() {
      _sequenceShowing = true;
      _userSequence = [];
      _currentFlashingButton = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    for (var i = 0; i < _sequence.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentFlashingButton = _sequence[i];
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      setState(() {
        _currentFlashingButton = null;
      });

      await Future.delayed(const Duration(milliseconds: 300));
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      setState(() {
        _sequenceShowing = false;
      });
    }
  }

  void _onButtonTap(int index) {
    setState(() {
      _userSequence.add(index);

      // Check if correct so far
      if (_userSequence.length <= _sequence.length) {
        if (_userSequence[_userSequence.length - 1] !=
            _sequence[_userSequence.length - 1]) {
          // Wrong!
          showMessage('Wrong sequence! Try again');
          _userSequence = [];
          return;
        }

        // Check if complete
        if (_userSequence.length == _sequence.length) {
          addScore(10 * _level);
          _level = _level + 1;

          if (_level > 3) {
            showMessage('Game Complete! You won!', success: true);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) completeGame();
            });
          } else {
            showMessage('Correct! Moving to level $_level', success: true);
            _generateSequence();
            showSequence();
          }
        }
      }
    });
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
                    _sequenceShowing
                        ? 'Watch the sequence...'
                        : 'Repeat the sequence',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final colors = [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                ];

                final isFlashing = _currentFlashingButton == index;

                return Card(
                  color: colors[index],
                  elevation: isFlashing ? 12 : 4,
                  child: InkWell(
                    onTap: _sequenceShowing ? null : () => _onButtonTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isFlashing
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                        boxShadow: isFlashing
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            fontSize: isFlashing ? 56 : 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (!_sequenceShowing)
            FilledButton.icon(
              onPressed: showSequence,
              icon: const Icon(Icons.visibility),
              label: const Text('Show Sequence Again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
        ],
      ),
    );
  }
}
