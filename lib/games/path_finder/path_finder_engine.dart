import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PathFinderEngine {
  static const int schemaVersion = 2;
  static const int gridWidth = 16;
  static const int gridHeight = 16;

  static String buildBattleKey({
    required String battleSeed,
    required int gameIndex,
    required String difficulty,
    required String hintPolicy,
  }) {
    return 'path_finder|$battleSeed|index:$gameIndex|difficulty:${_normalizeDifficulty(difficulty)}|hint:$hintPolicy|schema:$schemaVersion';
  }

  static Map<String, dynamic> generateChallengeSet({
    required String seed,
    required String difficulty,
  }) {
    final normalizedDifficulty = _normalizeDifficulty(difficulty);
    final config = _configForDifficulty(normalizedDifficulty);
    final random = _SeededRandom(
      _stableSeed('path_finder|$seed|$normalizedDifficulty|schema:$schemaVersion'),
    );

    final grid = List<List<int>>.generate(
      gridHeight,
      (_) => List<int>.filled(gridWidth, 0),
    );

    final startCell = _generateStartCell(random);
    final goalCell = _generateGoalCell(random, startCell);
    grid[startCell.y][startCell.x] = 2;
    grid[goalCell.y][goalCell.x] = 3;

    final cargoCells = _generateCargoCells(
      random: random,
      grid: grid,
      startCell: startCell,
      goalCell: goalCell,
      cargoCount: config.cargoCount,
    );

    for (final cargoCell in cargoCells) {
      grid[cargoCell.y][cargoCell.x] = 4;
    }

    _generateWallCells(
      random: random,
      grid: grid,
      startCell: startCell,
      goalCell: goalCell,
      cargoCells: cargoCells,
      wallCount: config.wallCount,
    );

    if (config.carvePassages > 0) {
      _carvePassages(
        random: random,
        grid: grid,
        protectedCells: {startCell, goalCell, ...cargoCells},
        carveCount: config.carvePassages,
      );
    }

    final wallCells = _collectCells(grid, 1);
    final solution = _solveRoute(
      grid: grid,
      startCell: startCell,
      goalCell: goalCell,
      cargoCells: cargoCells,
    );

    if (!solution.solvable) {
      throw StateError('Path Finder challenge generation failed to produce a solvable maze');
    }

    final challengeSet = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'type': 'path_finder',
      'challengeKey': seed,
      'difficulty': normalizedDifficulty,
      'gridWidth': gridWidth,
      'gridHeight': gridHeight,
      'startCell': _pointToMap(startCell),
      'goalCell': _pointToMap(goalCell),
      'cargoCells': cargoCells.map(_pointToMap).toList(),
      'wallCells': wallCells.map(_pointToMap).toList(),
      'cargoCount': cargoCells.length,
      'wallCount': wallCells.length,
      'optimalMoveCount': solution.path.length > 1 ? solution.path.length - 1 : 0,
      'optimalPathCells': solution.path.map(_pointToMap).toList(),
      'drawable': {
        'viewBox': {
          'width': gridWidth,
          'height': gridHeight,
        },
        'cellSize': 1,
        'walls': wallCells.map(_pointToMap).toList(),
        'cargo': cargoCells.map(_pointToMap).toList(),
        'start': _pointToMap(startCell),
        'goal': _pointToMap(goalCell),
      },
    };

    return {
      ...challengeSet,
      'canonicalChecksum': _checksumForMap(challengeSet),
    };
  }

  static Map<String, dynamic> generateBattleChallengeSet({
    required String battleSeed,
    required int gameIndex,
    required String difficulty,
    required String hintPolicy,
  }) {
    final challengeKey = buildBattleKey(
      battleSeed: battleSeed,
      gameIndex: gameIndex,
      difficulty: difficulty,
      hintPolicy: hintPolicy,
    );

    final challengeSet = generateChallengeSet(
      seed: challengeKey,
      difficulty: difficulty,
    );

    return {
      ...challengeSet,
      'battleSeed': battleSeed,
      'gameIndex': gameIndex,
      'hintPolicy': hintPolicy,
    };
  }

  static String computeSubmissionHash(Map<String, dynamic> submission) {
    return _checksumForMap(submission);
  }

  static Map<String, dynamic> replaySubmission({
    required Map<String, dynamic> challengeSet,
    required List<String> moves,
  }) {
    final startCell = _pointFromMap(
      Map<String, dynamic>.from(
        (challengeSet['startCell'] as Map).cast<String, dynamic>(),
      ),
    );
    final goalCell = _pointFromMap(
      Map<String, dynamic>.from(
        (challengeSet['goalCell'] as Map).cast<String, dynamic>(),
      ),
    );
    final wallCells = ((challengeSet['wallCells'] as List?) ?? const [])
        .map(
          (cell) => _pointFromMap(
            Map<String, dynamic>.from((cell as Map).cast<String, dynamic>()),
          ),
        )
        .toSet();
    final cargoCells = ((challengeSet['cargoCells'] as List?) ?? const [])
        .map(
          (cell) => _pointFromMap(
            Map<String, dynamic>.from((cell as Map).cast<String, dynamic>()),
          ),
        )
        .toList();

    final cargoIndexByKey = <String, int>{};
    for (var i = 0; i < cargoCells.length; i++) {
      cargoIndexByKey[_pointKey(cargoCells[i])] = i;
    }

    var player = startCell;
    var invalidMove = false;
    var collectedMask = 0;
    final visitedCells = <Map<String, int>>[_pointToMap(startCell)];

    for (final move in moves) {
      final direction = _directionOffset(move);
      if (direction == null) {
        invalidMove = true;
        break;
      }

      final next = Point<int>(player.x + direction.x, player.y + direction.y);
      if (!_isInside(next) || wallCells.contains(next)) {
        invalidMove = true;
        break;
      }

      player = next;
      final cargoIndex = cargoIndexByKey[_pointKey(player)];
      if (cargoIndex != null) {
        collectedMask |= (1 << cargoIndex);
      }
      visitedCells.add(_pointToMap(player));
    }

    final allCargoCollectedMask = cargoCells.isEmpty ? 0 : (1 << cargoCells.length) - 1;
    final completed = !invalidMove &&
        collectedMask == allCargoCollectedMask &&
        player == goalCell;

    return {
      'finalCell': _pointToMap(player),
      'visitedCells': visitedCells,
      'moveCount': moves.length,
      'collectedCargoCount': _bitCount(collectedMask),
      'cargoMask': collectedMask,
      'completed': completed,
      'invalidMove': invalidMove,
    };
  }

  static int computeScore({
    required Map<String, dynamic> challengeSet,
    required Map<String, dynamic> replay,
    int hintsUsed = 0,
  }) {
    final optimalMoveCount = (challengeSet['optimalMoveCount'] as num?)?.toInt() ?? 0;
    final moveCount = (replay['moveCount'] as num?)?.toInt() ?? 0;
    final cargoCount = (challengeSet['cargoCount'] as num?)?.toInt() ?? 0;

    if (replay['completed'] != true) {
      return 0;
    }

    final overflowMoves = max(0, moveCount - optimalMoveCount);
    final baseScore = 120 + (cargoCount * 10);
    final score = baseScore - (overflowMoves * 2) - (hintsUsed * 8);
    return max(25, score);
  }

  static Map<String, dynamic> buildSubmissionPayload({
    required Map<String, dynamic> challengeSet,
    required List<String> moves,
    required int totalTimeMs,
    int hintsUsed = 0,
  }) {
    final replay = replaySubmission(
      challengeSet: challengeSet,
      moves: moves,
    );
    final optimalMoveCount = (challengeSet['optimalMoveCount'] as num?)?.toInt() ?? 0;
    final score = computeScore(
      challengeSet: challengeSet,
      replay: replay,
      hintsUsed: hintsUsed,
    );

    final payload = <String, dynamic>{
      'challengeKey': challengeSet['challengeKey'],
      'challengeChecksum': challengeSet['canonicalChecksum'],
      'moveCount': moves.length,
      'moves': moves,
      'finalCell': replay['finalCell'],
      'collectedCargoCount': replay['collectedCargoCount'],
      'completed': replay['completed'],
      'invalidMove': replay['invalidMove'],
      'totalTimeMs': totalTimeMs,
      'hintsUsed': hintsUsed,
      'score': score,
      'perfect': replay['completed'] == true &&
          hintsUsed == 0 &&
          moves.length == optimalMoveCount,
    };

    return {
      ...payload,
      'submissionHash': computeSubmissionHash(payload),
    };
  }

  static _PathFinderConfig _configForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const _PathFinderConfig(wallCount: 22, cargoCount: 2);
      case 'hard':
        return const _PathFinderConfig(wallCount: 40, cargoCount: 4);
      case 'elite':
        return const _PathFinderConfig(
          wallCount: 48,
          cargoCount: 5,
          carvePassages: 3,
        );
      case 'medium':
      default:
        return const _PathFinderConfig(wallCount: 30, cargoCount: 3);
    }
  }

  static String _normalizeDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'medium':
      case 'hard':
      case 'elite':
        return difficulty.toLowerCase();
      default:
        return 'medium';
    }
  }

  static Point<int> _generateStartCell(_SeededRandom random) {
    return Point<int>(
      random.nextInt(gridWidth ~/ 2),
      random.nextInt(gridHeight ~/ 2),
    );
  }

  static Point<int> _generateGoalCell(
    _SeededRandom random,
    Point<int> startCell,
  ) {
    Point<int> goalCell;
    do {
      goalCell = Point<int>(
        (gridWidth ~/ 2) + random.nextInt(gridWidth ~/ 2),
        (gridHeight ~/ 2) + random.nextInt(gridHeight ~/ 2),
      );
    } while (_manhattanDistance(startCell, goalCell) < gridWidth ~/ 2);
    return goalCell;
  }

  static List<Point<int>> _generateCargoCells({
    required _SeededRandom random,
    required List<List<int>> grid,
    required Point<int> startCell,
    required Point<int> goalCell,
    required int cargoCount,
  }) {
    final cargoCells = <Point<int>>[];

    for (final candidate in _shuffledCells(random)) {
      if (cargoCells.length >= cargoCount) {
        break;
      }
      if (grid[candidate.y][candidate.x] != 0) {
        continue;
      }
      if (_manhattanDistance(candidate, startCell) < 3 ||
          _manhattanDistance(candidate, goalCell) < 3) {
        continue;
      }
      cargoCells.add(candidate);
      grid[candidate.y][candidate.x] = 4;
    }

    for (final cargoCell in cargoCells) {
      grid[cargoCell.y][cargoCell.x] = 0;
    }

    return cargoCells;
  }

  static void _generateWallCells({
    required _SeededRandom random,
    required List<List<int>> grid,
    required Point<int> startCell,
    required Point<int> goalCell,
    required List<Point<int>> cargoCells,
    required int wallCount,
  }) {
    var wallsPlaced = 0;
    final protectedCells = <Point<int>>{startCell, goalCell, ...cargoCells};

    for (final candidate in _shuffledCells(random)) {
      if (wallsPlaced >= wallCount) {
        break;
      }
      if (grid[candidate.y][candidate.x] != 0 || protectedCells.contains(candidate)) {
        continue;
      }

      grid[candidate.y][candidate.x] = 1;
      final solution = _solveRoute(
        grid: grid,
        startCell: startCell,
        goalCell: goalCell,
        cargoCells: cargoCells,
      );

      if (solution.solvable) {
        wallsPlaced++;
      } else {
        grid[candidate.y][candidate.x] = 0;
      }
    }
  }

  static void _carvePassages({
    required _SeededRandom random,
    required List<List<int>> grid,
    required Set<Point<int>> protectedCells,
    required int carveCount,
  }) {
    for (var index = 0; index < carveCount; index++) {
      final origin = Point<int>(
        2 + random.nextInt(gridWidth - 4),
        2 + random.nextInt(gridHeight - 4),
      );
      final isHorizontal = random.nextBool();
      final length = 3 + random.nextInt(4);

      for (var delta = 0; delta < length; delta++) {
        final x = isHorizontal ? origin.x + delta : origin.x;
        final y = isHorizontal ? origin.y : origin.y + delta;
        final point = Point<int>(x, y);
        if (!_isInside(point) || protectedCells.contains(point)) {
          continue;
        }
        grid[y][x] = 0;
      }
    }
  }

  static _SolvedRoute _solveRoute({
    required List<List<int>> grid,
    required Point<int> startCell,
    required Point<int> goalCell,
    required List<Point<int>> cargoCells,
  }) {
    final cargoIndexByKey = <String, int>{};
    for (var i = 0; i < cargoCells.length; i++) {
      cargoIndexByKey[_pointKey(cargoCells[i])] = i;
    }

    final targetMask = cargoCells.isEmpty ? 0 : (1 << cargoCells.length) - 1;
    final queue = <_RouteState>[
      _RouteState(startCell, 0),
    ];
    final visited = <String>{_stateKey(startCell, 0)};
    final parent = <String, String>{};
    final stateLookup = <String, _RouteState>{
      _stateKey(startCell, 0): _RouteState(startCell, 0),
    };

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current.position == goalCell && current.cargoMask == targetMask) {
        final path = <Point<int>>[];
        var cursor = _stateKey(current.position, current.cargoMask);
        while (true) {
          final state = stateLookup[cursor]!;
          path.insert(0, state.position);
          if (!parent.containsKey(cursor)) {
            break;
          }
          cursor = parent[cursor]!;
        }
        return _SolvedRoute(true, path);
      }

      for (final direction in _directions) {
        final nextPoint = Point<int>(
          current.position.x + direction.x,
          current.position.y + direction.y,
        );
        if (!_isInside(nextPoint) || grid[nextPoint.y][nextPoint.x] == 1) {
          continue;
        }

        var nextMask = current.cargoMask;
        final cargoIndex = cargoIndexByKey[_pointKey(nextPoint)];
        if (cargoIndex != null) {
          nextMask |= (1 << cargoIndex);
        }

        final nextKey = _stateKey(nextPoint, nextMask);
        if (visited.add(nextKey)) {
          parent[nextKey] = _stateKey(current.position, current.cargoMask);
          final nextState = _RouteState(nextPoint, nextMask);
          stateLookup[nextKey] = nextState;
          queue.add(nextState);
        }
      }
    }

    return const _SolvedRoute(false, <Point<int>>[]);
  }

  static List<Point<int>> _collectCells(List<List<int>> grid, int cellType) {
    final cells = <Point<int>>[];
    for (var y = 0; y < grid.length; y++) {
      for (var x = 0; x < grid[y].length; x++) {
        if (grid[y][x] == cellType) {
          cells.add(Point<int>(x, y));
        }
      }
    }
    return cells;
  }

  static Iterable<Point<int>> _shuffledCells(_SeededRandom random) sync* {
    final cells = <Point<int>>[
      for (var y = 0; y < gridHeight; y++)
        for (var x = 0; x < gridWidth; x++) Point<int>(x, y),
    ];

    for (var i = cells.length - 1; i > 0; i--) {
      final swapIndex = random.nextInt(i + 1);
      final temp = cells[i];
      cells[i] = cells[swapIndex];
      cells[swapIndex] = temp;
    }

    for (final cell in cells) {
      yield cell;
    }
  }

  static Map<String, int> _pointToMap(Point<int> point) => {
        'x': point.x,
        'y': point.y,
      };

  static Point<int> _pointFromMap(Map<String, dynamic> map) {
    return Point<int>(
      (map['x'] as num).toInt(),
      (map['y'] as num).toInt(),
    );
  }

  static String _pointKey(Point<int> point) => '${point.x}:${point.y}';

  static String _stateKey(Point<int> point, int cargoMask) {
    return '${point.x}:${point.y}:$cargoMask';
  }

  static bool _isInside(Point<int> point) {
    return point.x >= 0 &&
        point.x < gridWidth &&
        point.y >= 0 &&
        point.y < gridHeight;
  }

  static int _manhattanDistance(Point<int> a, Point<int> b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  static Point<int>? _directionOffset(String move) {
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

  static int _bitCount(int value) {
    var working = value;
    var count = 0;
    while (working > 0) {
      count += working & 1;
      working >>= 1;
    }
    return count;
  }

  static int _stableSeed(String input) {
    const int offset = 0x811C9DC5;
    const int prime = 0x01000193;
    var hash = offset;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * prime) & 0x7fffffff;
    }
    return hash;
  }

  static String _checksumForMap(Map<String, dynamic> payload) {
    final serialized = _stableSerialize(payload);
    return sha256.convert(utf8.encode(serialized)).toString();
  }

  static String _stableSerialize(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is bool || value is num) {
      return value.toString();
    }
    if (value is String) {
      return jsonEncode(value);
    }
    if (value is List) {
      return '[${value.map(_stableSerialize).join(',')}]';
    }
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return '{${keys.map((key) => '${jsonEncode(key)}:${_stableSerialize(value[key])}').join(',')}}';
    }
    throw ArgumentError('Unsupported value for serialization: $value');
  }
}

class _SeededRandom {
  _SeededRandom(int seed) : _state = seed == 0 ? 1 : seed;

  int _state;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'Must be positive');
    }
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return ((_state / 0x80000000) * max).floor();
  }

  bool nextBool() => nextInt(2) == 0;
}

class _PathFinderConfig {
  const _PathFinderConfig({
    required this.wallCount,
    required this.cargoCount,
    this.carvePassages = 0,
  });

  final int wallCount;
  final int cargoCount;
  final int carvePassages;
}

class _RouteState {
  const _RouteState(this.position, this.cargoMask);

  final Point<int> position;
  final int cargoMask;
}

class _SolvedRoute {
  const _SolvedRoute(this.solvable, this.path);

  final bool solvable;
  final List<Point<int>> path;
}

const List<Point<int>> _directions = <Point<int>>[
  Point<int>(0, -1),
  Point<int>(0, 1),
  Point<int>(-1, 0),
  Point<int>(1, 0),
];
