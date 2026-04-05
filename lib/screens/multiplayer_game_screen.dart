import 'package:flutter/material.dart';
import '../games/widgets/game_widgets.dart';
import '../models/models.dart';
import '../services/multiplayer_service.dart';
import '../services/game_generator_service.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final MultiplayerService multiplayerService;
  final String currentUserId;
  final Game game;

  const MultiplayerGameScreen({
    Key? key,
    required this.multiplayerService,
    required this.currentUserId,
    required this.game,
  }) : super(key: key);

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  late Map<String, dynamic> _gameState;
  String? _currentPlayerId;
  Map<String, int> _playerScores = {};
  bool _isSubmitting = false;
  bool _localGameCompleted = false;
  Map<String, dynamic>? _rotationMasterSubmission;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _setupListeners();
  }

  void _initializeGame() {
    // Generate deterministic game state from gameIndex + seed
    final generatedState = GameGeneratorService.generateGameState(
      gameId: widget.game.id,
      gameIndex: widget.game.gameIndex ?? 0,
      seed: widget.game.seed ?? 'default_seed',
      difficulty: widget.game.difficulty ?? 'medium',
      hintPolicy: widget.game.hintPolicy ?? 'enabled',
    );
    _gameState = {
      ...generatedState,
      ...widget.game.state,
    };

    _currentPlayerId = widget.game.currentPlayerId;
    final existingScore = (_gameState['score'] as num?)?.toInt() ?? 0;
    _playerScores = {
      widget.currentUserId: existingScore,
    };
    _localGameCompleted = _gameState['completed'] == true;
  }

  void _setupListeners() {
    // Listen for turn changes
    widget.multiplayerService.on('turn-made', (data) {
      if (!mounted) return;
      setState(() {
        _currentPlayerId = data['updatedGameState']['currentPlayerId'];
        _gameState = {..._gameState, ...data['updatedGameState']};
      });
    });

    // Listen for round completion
    widget.multiplayerService.on('round-complete', (data) {
      if (!mounted) return;
      _showRoundResultsDialog(data);
    });

    // Listen for game ended
    widget.multiplayerService.on('game-ended', (data) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        '/game-results',
        arguments: data,
      );
    });
  }

  Future<void> _submitTurn() async {
    if (_isSubmitting || _currentPlayerId != widget.currentUserId) return;
    if (widget.game.id == 'rotation_master' && !_localGameCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish the puzzle before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.game.id == 'rotation_master') {
        final submission = _rotationMasterSubmission;
        if (submission == null) {
          throw Exception('Rotation Master submission is missing');
        }

        await widget.multiplayerService.submitGameResult(
          lobbyId: widget.game.lobbyId ?? '',
          gameId: widget.game.id,
          roundNumber: widget.game.roundNumber ?? 1,
          score: (submission['score'] as num?)?.toInt() ?? 0,
          timeTaken: (submission['totalTimeMs'] as num?)?.toInt() ?? 0,
          hintsUsed: (submission['hintsUsed'] as num?)?.toInt() ?? 0,
          perfect: submission['perfect'] == true,
          gameData: submission,
        );
      } else {
        await widget.multiplayerService.makeTurn({
          'lobbyId': widget.game.lobbyId,
          'gameId': widget.game.id,
          'roundNumber': widget.game.roundNumber ?? 1,
          'turnData': {
            ..._gameState,
            'completed': _localGameCompleted,
          },
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.game.id == 'rotation_master'
                  ? 'Result submitted!'
                  : 'Turn submitted!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showRoundResultsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Round Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scores:'),
            const SizedBox(height: 16),
            Text('You: ${data['playerScores'][widget.currentUserId] ?? 0}'),
            Text(
              'Opponent: ${data['playerScores'].values.firstWhere(
                    (score) => true,
                    orElse: () => 0,
                  )}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Next Round'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(BuildContext context) {
    switch (widget.game.id) {
      case 'rotation_master':
        return RotationMasterGame(
          onGameComplete: _onRotationMasterComplete,
          onScoreUpdate: _onRotationMasterScoreUpdate,
          seed: widget.game.seed ?? 'default_seed',
          difficulty: widget.game.difficulty ?? 'medium',
          challengeSet: (_gameState['challengeSet'] as Map?)?.cast<String, dynamic>(),
          onSubmissionReady: _onRotationMasterSubmissionReady,
        );
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.games, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                widget.game.id.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Difficulty: ${widget.game.difficulty}',
                style: const TextStyle(color: Colors.grey),
              ),
              if (widget.game.hintPolicy != 'disabled')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Hints: ${widget.game.hintPolicy}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Game implementation coming soon',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
    }
  }

  void _onRotationMasterScoreUpdate(int score) {
    if (!mounted) return;
    setState(() {
      _gameState = {
        ..._gameState,
        'score': score,
      };
      _playerScores = {
        ..._playerScores,
        widget.currentUserId: score,
      };
    });
  }

  void _onRotationMasterComplete(int finalScore) {
    if (!mounted) return;
    setState(() {
      _localGameCompleted = true;
      _gameState = {
        ..._gameState,
        'score': finalScore,
        'completed': true,
        'completedAt': DateTime.now().toIso8601String(),
      };
      _playerScores = {
        ..._playerScores,
        widget.currentUserId: finalScore,
      };
    });
  }

  void _onRotationMasterSubmissionReady(Map<String, dynamic> submission) {
    if (!mounted) return;
    setState(() {
      _rotationMasterSubmission = submission;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isYourTurn = _currentPlayerId == widget.currentUserId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Game?'),
            content: const Text('Are you sure? This will disconnect you.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Leave'),
              ),
            ],
          ),
        );

        if ((confirm ?? false) && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.game.id,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Round ${widget.game.roundNumber ?? 1}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            // Ranked badge
            if (widget.game.ranked ?? false)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Chip(
                    label: const Text('Ranked'),
                    backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Score header
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Your Score'),
                      Text(
                        '${_playerScores[widget.currentUserId] ?? 0}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text('vs', style: TextStyle(fontSize: 20)),
                  Column(
                    children: [
                      const Text("Opponent's Score"),
                      Text(
                        '${_playerScores.values.firstWhere(
                          (s) => true,
                          orElse: () => 0,
                        )}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Turn indicator
            Container(
              padding: const EdgeInsets.all(16),
              color: isYourTurn
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isYourTurn ? Icons.check_circle : Icons.timer,
                    color: isYourTurn ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isYourTurn
                        ? 'Your Turn - Submit your answer'
                        : 'Waiting for opponent...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isYourTurn ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Game content area
            Expanded(
              child: _buildGameContent(context),
            ),

            // Submit button
            if (isYourTurn)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ||
                          (widget.game.id == 'rotation_master' &&
                              !_localGameCompleted)
                      ? null
                      : _submitTurn,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    widget.game.id == 'rotation_master'
                        ? 'Submit Result'
                        : 'Submit Turn',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Waiting for opponent...'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
