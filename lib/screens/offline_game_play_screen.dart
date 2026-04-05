/**
 * Offline Game Play Screen - Refactored
 * Allows alpha testers to play games in offline/practice mode
 * Uses modular game widgets for cleaner architecture
 */

import 'package:flutter/material.dart';
import '../games/game_catalog.dart';
import '../games/widgets/game_widgets.dart';

class OfflineGamePlayScreen extends StatefulWidget {
  final GameTemplate gameTemplate;

  const OfflineGamePlayScreen({
    Key? key,
    required this.gameTemplate,
  }) : super(key: key);

  @override
  State<OfflineGamePlayScreen> createState() => _OfflineGamePlayScreenState();
}

class _OfflineGamePlayScreenState extends State<OfflineGamePlayScreen> {
  late DateTime _startTime;
  int _score = 0;
  int _hintsUsed = 0;
  bool _gameCompleted = false;
  bool _gameStarted = false;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTemplate.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _showHint,
            tooltip: 'Get Hint',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showRules,
            tooltip: 'Game Rules',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score Header
            _buildScoreHeader(context),
            const Divider(height: 1),
            // Game Content
            Expanded(
              child: _buildGameContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHeader(BuildContext context) {
    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.timer,
            'Time',
            '$minutes:${seconds.toString().padLeft(2, '0')}',
          ),
          _buildStatItem(
            context,
            Icons.stars,
            'Score',
            _score.toString(),
          ),
          _buildStatItem(
            context,
            Icons.lightbulb,
            'Hints',
            _hintsUsed.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildGameContent(BuildContext context) {
    if (_gameCompleted) {
      return _buildCompletionScreen(context);
    }

    if (!_gameStarted) {
      return _buildStartScreen(context);
    }

    if (_countdown > 0) {
      return _buildCountdownScreen(context);
    }

    // Build the appropriate game widget
    return _buildGameWidget(context);
  }

  Widget _buildGameWidget(BuildContext context) {
    switch (widget.gameTemplate.id) {
      // Memory Games
      case 'memory_match':
        return MemoryMatchGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'sequence_recall':
        return SequenceRecallGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'pattern_memory':
        return PatternMemoryGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      
      // Logic Games
      case 'code_breaker':
        return CodeBreakerGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'sudoku_duel':
        return SudokuDuelGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'logic_grid':
        return LogicGridGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      
      // Attention Games
      case 'spot_difference':
        return SpotDifferenceGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'color_rush':
        return ColorRushGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'focus_finder':
        return FocusFinderGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      
      // Spatial Games
      case 'puzzle_race':
        return PuzzleRaceGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'rotation_master':
        return RotationMasterGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
          seed: '${widget.gameTemplate.id}_single_player_v1',
          difficulty: 'medium',
        );
      case 'path_finder':
        return PathFinderGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
          seed: '${widget.gameTemplate.id}_single_player_v1',
          difficulty: 'medium',
        );
      
      // Language Games
      case 'word_builder':
        return WordBuilderGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'anagram_attack':
        return AnagramAttackGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      case 'vocabulary_showdown':
        return VocabularyShowdownGame(
          onGameComplete: _onGameComplete,
          onScoreUpdate: _onScoreUpdate,
        );
      
      default:
        return _buildGenericGame(context);
    }
  }

  void _onScoreUpdate(int newScore) {
    setState(() {
      _score = newScore;
    });
  }

  void _onGameComplete(int finalScore) {
    setState(() {
      _score = finalScore;
      _gameCompleted = true;
    });
  }

  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.gameTemplate.icon,
              style: const TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 32),
            Text(
              widget.gameTemplate.name,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.gameTemplate.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.gameTemplate.rules,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow, size: 32),
              label: const Text('START GAME', style: TextStyle(fontSize: 20)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get Ready!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _countdown.toString(),
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _countdown = 3;
    });

    _runCountdown();
  }

  void _runCountdown() async {
    for (int i = 3; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown = i - 1;
        });
      }
    }
  }

  Widget _buildGenericGame(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.gameTemplate.icon,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              widget.gameTemplate.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This game is coming soon!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try these playable games: Memory Match, Word Builder, Sequence Recall, Anagram Attack, or Code Breaker.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Game Selection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'You completed ${widget.gameTemplate.name}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildResultRow(context, 'Final Score', _score.toString()),
                    const Divider(height: 24),
                    _buildResultRow(
                      context,
                      'Time',
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                    ),
                    const Divider(height: 24),
                    _buildResultRow(context, 'Hints Used', _hintsUsed.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.replay),
              label: const Text('Play Again'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Games'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  void _showHint() {
    setState(() {
      _hintsUsed++;
      _score = _score > 5 ? _score - 5 : 0; // Penalty for using hint
    });

    String hintText = 'Hint: ';
    switch (widget.gameTemplate.id) {
      case 'memory_match':
        hintText += 'Try to remember the positions of matching pairs!';
        break;
      case 'word_builder':
        hintText += 'Look for common word patterns like -ING, -ED, or -ER';
        break;
      case 'sequence_recall':
        hintText += 'Break the sequence into smaller chunks to remember it better';
        break;
      case 'anagram_attack':
        hintText += 'Try rearranging common letter combinations like TH, ER, or ING';
        break;
      case 'code_breaker':
        hintText += 'Use the feedback from previous guesses to narrow down possibilities';
        break;
      default:
        hintText += 'Take your time and think carefully about each move';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lightbulb, size: 48, color: Colors.amber),
        title: const Text('Hint'),
        content: Text(hintText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.gameTemplate.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(widget.gameTemplate.description),
              const SizedBox(height: 16),
              Text(
                'How to Play',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(widget.gameTemplate.rules),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
