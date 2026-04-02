/**
 * Logic Grid Game Widget - Alpha Implementation
 * Simple deduction puzzle
 * 
 * Category: Logic
 * Players: 2-6
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class LogicGridGame extends BaseGameWidget {
  const LogicGridGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<LogicGridGame> createState() => _LogicGridGameState();
}

class _LogicGridGameState extends BaseGameState<LogicGridGame> {
  late Map<String, String> _solution;
  late Map<String, String?> _userAnswers;
  late List<String> _clues;
  int _level = 1;

  final List<String> _people = ['Anna', 'Bob', 'Carol'];
  final List<String> _colors = ['Red', 'Blue', 'Green'];

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    final random = Random();
    final shuffledColors = List.from(_colors)..shuffle(random);

    _solution = {};
    for (var i = 0; i < _people.length; i++) {
      _solution[_people[i]] = shuffledColors[i];
    }

    _userAnswers = {for (var person in _people) person: null};

    // Generate clues based on level difficulty
    _clues = ['Match each person with their color:'];

    // Level 1: 3 positive clues (direct answers)
    // Level 2: Mix of positive and negative clues
    // Level 3+: Mostly negative clues (harder deduction)

    if (_level == 1) {
      // Level 1: Give all positive clues directly
      for (var person in _people) {
        _clues.add('✓ $person has ${_solution[person]}');
      }
    } else if (_level == 2) {
      // Level 2: Mix - give 2 positive clues and add negative clues
      final positivePeople = _people.take(2).toList();
      for (var person in positivePeople) {
        _clues.add('✓ $person has ${_solution[person]}');
      }
      // Add negative clues to narrow down the remaining person
      final remainingPerson = _people.last;
      for (var color in _colors) {
        if (_solution[remainingPerson] != color) {
          _clues.add('✗ $remainingPerson does NOT have $color');
        }
      }
    } else {
      // Level 3+: Use strategic negative clues that uniquely determine the solution
      // Strategy: For each person, provide at least one negative clue
      for (var person in _people) {
        var cluesForPerson = 0;
        for (var color in _colors) {
          if (_solution[person] != color && cluesForPerson < 2) {
            _clues.add('✗ $person does NOT have $color');
            cluesForPerson++;
          }
        }
      }
      // Add one positive clue to ensure solvability
      final firstPerson = _people.first;
      _clues.add('✓ $firstPerson has ${_solution[firstPerson]}');
    }

    setState(() {});
  }

  void _setAnswer(String person, String color) {
    setState(() {
      _userAnswers[person] = color;
    });
  }

  void _checkAnswers() {
    bool allCorrect = true;
    for (var person in _people) {
      if (_userAnswers[person] != _solution[person]) {
        allCorrect = false;
        break;
      }
    }
    
    if (allCorrect) {
      addScore(40);
      showMessage('Correct! +40 points', success: true);
      _level++;
      
      if (_level > 3) {
        completeGame();
      } else {
        _generatePuzzle();
      }
    } else {
      showMessage('Not quite right. Try again!');
    }
  }

  @override
  Widget buildGame(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
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
                      'Clues:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._clues.map((clue) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('• $clue'),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ..._people.map((person) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((color) {
                          final isSelected = _userAnswers[person] == color;
                          return FilterChip(
                            label: Text(color),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _setAnswer(person, color);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _checkAnswers,
              icon: const Icon(Icons.check),
              label: const Text('Check Solution'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
