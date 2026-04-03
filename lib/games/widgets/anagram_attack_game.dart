/**
 * Anagram Attack Game Widget
 * Solve anagrams faster than opponents
 */

import 'package:flutter/material.dart';
import 'dart:math';
import 'base_game_widget.dart';

class AnagramAttackGame extends BaseGameWidget {
  const AnagramAttackGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  @override
  State<AnagramAttackGame> createState() => _AnagramAttackGameState();
}

class _AnagramAttackGameState extends BaseGameState<AnagramAttackGame> {
  String? _targetWord;
  String? _scrambledWord;
  String _userAnswer = '';
  int _level = 1;
  late List<String> _words;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _level = 1;
    _words = [
      'LISTEN',
      'SILENT',
      'GARDEN',
      'DANGER',
      'MASTER',
      'STREAM',
      'CREATION',
      'REACTION',
      'TRIANGLE',
      'INTEGRAL',
      'HEART',
      'EARTH',
      'BELOW',
      'ELBOW',
      'ANGLE',
      'ANGEL',
      'NIGHT',
      'THING',
    ];
    _nextAnagram();
  }

  void _nextAnagram() {
    // Check level progression: 6 words per level
    // Level 1: Solve 6 anagrams, Level 2: 6 more, Level 3: 6 more
    if (_words.isEmpty || _level > 3) {
      completeGame();
      return;
    }

    _targetWord = _words.removeAt(Random().nextInt(_words.length));
    _scrambledWord = _scrambleWord(_targetWord!);
    _userAnswer = '';
    _controller.clear();
    setState(() {});
  }

  String _scrambleWord(String word) {
    final chars = word.split('');
    var attempts = 0;
    do {
      chars.shuffle(Random());
      attempts++;
    } while (chars.join() == word && attempts < 10 && word.length > 1);

    // Final check - if still not scrambled, manually swap
    if (chars.join() == word && word.length > 1) {
      final temp = chars[0];
      chars[0] = chars[1];
      chars[1] = temp;
    }
    return chars.join();
  }

  void _checkAnagram() {
    final cleanUserAnswer = _userAnswer.trim().toUpperCase();
    final cleanTargetWord = _targetWord!.trim().toUpperCase();

    if (cleanUserAnswer.length != cleanTargetWord.length) {
      showMessage(
          'Your answer has ${cleanUserAnswer.length} letters, but the word has ${cleanTargetWord.length} letters');
      return;
    }

    if (cleanUserAnswer == cleanTargetWord) {
      addScore(15);
      showMessage('Correct! +15 points', success: true);

      // Check if we've completed this level (6 words per level)
      final solvedInLevel = 18 - _words.length;
      if (solvedInLevel % 6 == 0 && _level < 3) {
        _level++;
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _nextAnagram();
        }
      });
    } else {
      showMessage('Try again! The word is ${cleanTargetWord.length} letters long');
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Unscramble This Word',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _scrambledWord ?? '',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_targetWord!.length} letters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        hintText: 'Type the unscrambled word...',
                        border: const OutlineInputBorder(),
                        helperText: 'Enter ${_targetWord!.length} letters',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        setState(() {
                          _userAnswer = value.toUpperCase();
                        });
                      },
                      onSubmitted: (value) => _checkAnagram(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _userAnswer.isEmpty ? null : _checkAnagram,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit Answer'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Words remaining: ${_words.length}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
