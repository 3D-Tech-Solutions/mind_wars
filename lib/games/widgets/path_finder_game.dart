import 'dart:math';

import 'package:flutter/material.dart';

import '../path_finder/path_finder_engine.dart';
import 'base_game_widget.dart';

class PathFinderGame extends BaseGameWidget {
  const PathFinderGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
    this.seed = 'offline_path_finder_practice_v1',
    this.difficulty = 'medium',
    this.challengeSet,
    this.onSubmissionReady,
  }) : super(
          key: key,
          onGameComplete: onGameComplete,
          onScoreUpdate: onScoreUpdate,
        );

  final String seed;
  final String difficulty;
  final Map<String, dynamic>? challengeSet;
  final ValueChanged<Map<String, dynamic>>? onSubmissionReady;

  @override
  State<PathFinderGame> createState() => _PathFinderGameState();
}

class _PathFinderGameState extends BaseGameState<PathFinderGame> {
  late final Map<String, dynamic> _challengeSet;
  late final Point<int> _startCell;
  late final Point<int> _goalCell;
  late final Set<Point<int>> _wallCells;
  late final Set<Point<int>> _allCargoCells;
  late final int _optimalMoveCount;
  late final DateTime _startedAt;

  late Point<int> _playerCell;
  late Set<Point<int>> _remainingCargoCells;
  final List<String> _moves = <String>[];
  int _hintsUsed = 0;

  @override
  void initState() {
    super.initState();
    _challengeSet = widget.challengeSet ??
        PathFinderEngine.generateChallengeSet(
          seed: widget.seed,
          difficulty: widget.difficulty,
        );
    _startCell = _pointFromMap(
      Map<String, dynamic>.from((_challengeSet['startCell'] as Map).cast<String, dynamic>()),
    );
    _goalCell = _pointFromMap(
      Map<String, dynamic>.from((_challengeSet['goalCell'] as Map).cast<String, dynamic>()),
    );
    _wallCells = ((_challengeSet['wallCells'] as List?) ?? const [])
        .map(
          (cell) => _pointFromMap(
            Map<String, dynamic>.from((cell as Map).cast<String, dynamic>()),
          ),
        )
        .toSet();
    _allCargoCells = ((_challengeSet['cargoCells'] as List?) ?? const [])
        .map(
          (cell) => _pointFromMap(
            Map<String, dynamic>.from((cell as Map).cast<String, dynamic>()),
          ),
        )
        .toSet();
    _remainingCargoCells = {..._allCargoCells};
    _playerCell = _startCell;
    _optimalMoveCount = (_challengeSet['optimalMoveCount'] as num?)?.toInt() ?? 0;
    _startedAt = DateTime.now();
  }

  void _move(String direction) {
    if (isCompleted) {
      return;
    }

    final delta = _directionOffset(direction);
    if (delta == null) {
      return;
    }

    final next = Point<int>(_playerCell.x + delta.x, _playerCell.y + delta.y);
    if (!_isInside(next) || _wallCells.contains(next)) {
      showMessage('Blocked. Find a different route.');
      return;
    }

    setState(() {
      _playerCell = next;
      _moves.add(direction);
      if (_remainingCargoCells.remove(next)) {
        final progressScore = max(0, score) + 15;
        updateScore(progressScore);
      }
    });

    if (_playerCell == _goalCell && _remainingCargoCells.isEmpty) {
      _finishRun();
    } else if (_playerCell == _goalCell) {
      showMessage('The exit is locked until you collect every cargo crate.');
    }
  }

  void _useHint() {
    if (isCompleted) {
      return;
    }

    _hintsUsed += 1;
    final remaining = _remainingCargoCells.length;
    showMessage(
      remaining == 0
          ? 'Head for the exit. You have all cargo.'
          : 'Cargo remaining: $remaining. Try clearing the nearest corridor first.',
    );
  }

  void _finishRun() {
    final totalTimeMs = DateTime.now().difference(_startedAt).inMilliseconds;
    final submission = PathFinderEngine.buildSubmissionPayload(
      challengeSet: _challengeSet,
      moves: _moves,
      totalTimeMs: totalTimeMs,
      hintsUsed: _hintsUsed,
    );
    final finalScore = (submission['score'] as num?)?.toInt() ?? 0;
    updateScore(finalScore);
    widget.onSubmissionReady?.call(submission);
    completeGame();
  }

  @override
  Widget buildGame(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatChip(label: 'Cargo', value: '${_allCargoCells.length - _remainingCargoCells.length}/${_allCargoCells.length}'),
                  _StatChip(label: 'Steps', value: '${_moves.length}'),
                  _StatChip(label: 'Optimal', value: '$_optimalMoveCount'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Collect every cargo crate, then reach the exit using the sealed maze payload.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: PathFinderEngine.gridWidth,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: PathFinderEngine.gridWidth * PathFinderEngine.gridHeight,
                  itemBuilder: (context, index) {
                    final x = index % PathFinderEngine.gridWidth;
                    final y = index ~/ PathFinderEngine.gridWidth;
                    final cell = Point<int>(x, y);
                    final isPlayer = cell == _playerCell;
                    final isWall = _wallCells.contains(cell);
                    final isGoal = cell == _goalCell;
                    final hasCargo = _remainingCargoCells.contains(cell);
                    final isStart = cell == _startCell;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _cellColor(
                          colorScheme: colorScheme,
                          isWall: isWall,
                          isGoal: isGoal,
                          isStart: isStart,
                          hasCargo: hasCargo,
                          isPlayer: isPlayer,
                        ),
                        border: Border.all(
                          color: isPlayer
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: isPlayer ? 2 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isPlayer
                              ? 'P'
                              : hasCargo
                                  ? 'C'
                                  : isGoal
                                      ? 'E'
                                      : isStart
                                          ? 'S'
                                          : '',
                          style: TextStyle(
                            color: isWall
                                ? colorScheme.onInverseSurface
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _useHint,
            icon: const Icon(Icons.assistant_navigation),
            label: Text('Hint ($_hintsUsed used)'),
          ),
          const SizedBox(height: 8),
          _Controls(
            onMove: _move,
          ),
        ],
      ),
    );
  }

  Color _cellColor({
    required ColorScheme colorScheme,
    required bool isWall,
    required bool isGoal,
    required bool isStart,
    required bool hasCargo,
    required bool isPlayer,
  }) {
    if (isPlayer) {
      return colorScheme.primaryContainer;
    }
    if (isWall) {
      return colorScheme.inverseSurface;
    }
    if (hasCargo) {
      return colorScheme.tertiaryContainer;
    }
    if (isGoal) {
      return colorScheme.secondaryContainer;
    }
    if (isStart) {
      return colorScheme.surfaceContainerLow;
    }
    return colorScheme.surface;
  }

  Point<int>? _directionOffset(String move) {
    switch (move) {
      case 'up':
        return const Point<int>(0, -1);
      case 'down':
        return const Point<int>(0, 1);
      case 'left':
        return const Point<int>(-1, 0);
      case 'right':
        return const Point<int>(1, 0);
      default:
        return null;
    }
  }

  bool _isInside(Point<int> point) {
    return point.x >= 0 &&
        point.x < PathFinderEngine.gridWidth &&
        point.y >= 0 &&
        point.y < PathFinderEngine.gridHeight;
  }

  Point<int> _pointFromMap(Map<String, dynamic> map) {
    return Point<int>(
      (map['x'] as num).toInt(),
      (map['y'] as num).toInt(),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
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
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.onMove,
  });

  final ValueChanged<String> onMove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () => onMove('up'),
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: () => onMove('left'),
              icon: const Icon(Icons.keyboard_arrow_left),
            ),
            const SizedBox(width: 32),
            IconButton.filled(
              onPressed: () => onMove('right'),
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ],
        ),
        IconButton.filled(
          onPressed: () => onMove('down'),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }
}
