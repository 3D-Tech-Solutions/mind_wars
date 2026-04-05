import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Path Finder Puzzle Generation Engine
///
/// Generates deterministic mazes using strict RNG sequence:
/// 1. Start/end node placement
/// 2. Cargo box placement
/// 3. Wall placement
/// 4. Topological elements (for Elite difficulty)
///
/// All players use same seed + gameIndex to generate pixel-perfect identical mazes.
class PathFinderEngine {
  static const int gridWidth = 16;
  static const int gridHeight = 16;

  /// Generate a complete Path Finder puzzle instance
  static Map<String, dynamic> generateBattleChallenge({
    required String battleSeed,
    required int gameIndex,
    required String difficulty,
    required String hintPolicy,
  }) {
    final random = Random(battleSeed.hashCode + gameIndex);

    // Initialize grid: 0 = empty, 1 = wall, 2 = player, 3 = goal, 4 = cargo
    final grid = List<List<int>>.generate(
      gridHeight,
      (_) => List<int>.filled(gridWidth, 0),
    );

    // Phase 1: Place start and end nodes (strict RNG sequence)
    final startPos = _generateStartAndEndNodes(random, grid);
    final endPos = startPos['end'] as Point<int>;
    final playerStart = startPos['start'] as Point<int>;

    grid[playerStart.y][playerStart.x] = 2; // Player start
    grid[endPos.y][endPos.x] = 3; // Goal

    // Phase 2: Place cargo boxes
    final cargoCount = _getCargoCountForDifficulty(difficulty);
    final cargoPositions = _generateCargoBoxPlacement(random, grid, cargoCount);
    for (final cargo in cargoPositions) {
      grid[cargo.y][cargo.x] = 4;
    }

    // Phase 3: Place walls
    final wallCount = _getWallCountForDifficulty(difficulty);
    _generateWallPlacement(random, grid, wallCount);

    // Phase 4: Add topological elements for Elite difficulty
    if (difficulty == 'elite') {
      _generateTopologicalElements(random, grid);
    }

    // Validate maze solvability with BFS
    final bfsResult = _validateMazeWithBFS(grid, playerStart, endPos);
    if (!(bfsResult['solvable'] as bool)) {
      // If not solvable, recursively regenerate (in practice, should rarely happen)
      return generateBattleChallenge(
        battleSeed: battleSeed,
        gameIndex: gameIndex + 1,
        difficulty: difficulty,
        hintPolicy: hintPolicy,
      );
    }

    // Score maze fitness against difficulty thresholds
    final fitness = _scorePathFinderFitness(
      grid,
      playerStart,
      endPos,
      difficulty,
      bfsResult,
    );

    // Generate maze hash for anti-cheat verification
    final mazeHash = _generateMazeHash(grid);

    // Calculate optimal path length and corners
    final optimalPath = bfsResult['path'] as List<Point<int>>;
    final cornerCount = _countCorners(optimalPath);

    return {
      'type': 'path_finder',
      'gameIndex': gameIndex,
      'seed': battleSeed,
      'difficulty': difficulty,
      'hintPolicy': hintPolicy,
      'grid': _serializeGrid(grid),
      'playerStart': {'x': playerStart.x, 'y': playerStart.y},
      'goal': {'x': endPos.x, 'y': endPos.y},
      'cargoBoxes': cargoPositions.map((p) => {'x': p.x, 'y': p.y}).toList(),
      'wallCount': wallCount,
      'cargoCount': cargoCount,
      'mazeHash': mazeHash,
      'optimalPathLength': optimalPath.length,
      'optimalCornerCount': cornerCount,
      'fitnessScore': fitness['score'],
      'fitnessMetrics': fitness['metrics'],
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Phase 1: Generate start and end node positions
  static Map<String, dynamic> _generateStartAndEndNodes(
    Random random,
    List<List<int>> grid,
  ) {
    Point<int>? startPos;
    Point<int>? endPos;

    // Place start node in top-left quadrant
    startPos = Point<int>(
      random.nextInt(gridWidth ~/ 2),
      random.nextInt(gridHeight ~/ 2),
    );

    // Ensure end node is far from start (bottom-right quadrant)
    do {
      endPos = Point<int>(
        gridWidth ~/ 2 + random.nextInt(gridWidth ~/ 2),
        gridHeight ~/ 2 + random.nextInt(gridHeight ~/ 2),
      );
    } while (_manhattanDistance(startPos, endPos) < gridWidth ~/ 2);

    return {
      'start': startPos,
      'end': endPos,
    };
  }

  /// Phase 2: Generate cargo box placements
  static List<Point<int>> _generateCargoBoxPlacement(
    Random random,
    List<List<int>> grid,
    int cargoCount,
  ) {
    final positions = <Point<int>>[];
    int attempts = 0;
    const maxAttempts = 100;

    while (positions.length < cargoCount && attempts < maxAttempts) {
      final x = random.nextInt(gridWidth);
      final y = random.nextInt(gridHeight);

      // Don't place on walls, player, or goal
      if (grid[y][x] == 0 &&
          !positions.contains(Point<int>(x, y))) {
        positions.add(Point<int>(x, y));
      }
      attempts++;
    }

    return positions;
  }

  /// Phase 3: Generate wall placements
  static void _generateWallPlacement(
    Random random,
    List<List<int>> grid,
    int wallCount,
  ) {
    int wallsPlaced = 0;
    int attempts = 0;
    const maxAttempts = 500;

    while (wallsPlaced < wallCount && attempts < maxAttempts) {
      final x = random.nextInt(gridWidth);
      final y = random.nextInt(gridHeight);

      // Don't place on start, goal, or existing wall
      if (grid[y][x] == 0) {
        grid[y][x] = 1; // Place wall
        wallsPlaced++;
      }
      attempts++;
    }
  }

  /// Phase 4: Generate topological elements (corridors, chambers)
  static void _generateTopologicalElements(
    Random random,
    List<List<int>> grid,
  ) {
    // For Elite difficulty: Create wider corridors and larger chambers
    // This makes the maze more strategically challenging

    for (int i = 0; i < 3; i++) {
      // Create wider passages (2-3 cells wide)
      final startX = random.nextInt(gridWidth - 4) + 2;
      final startY = random.nextInt(gridHeight - 4) + 2;

      final direction = random.nextInt(2); // 0=horizontal, 1=vertical
      final length = 4 + random.nextInt(4);

      if (direction == 0) {
        // Horizontal corridor
        for (int x = startX; x < startX + length && x < gridWidth; x++) {
          if (grid[startY][x] != 2 && grid[startY][x] != 3) {
            grid[startY][x] = 0;
          }
        }
      } else {
        // Vertical corridor
        for (int y = startY; y < startY + length && y < gridHeight; y++) {
          if (grid[y][startX] != 2 && grid[y][startX] != 3) {
            grid[y][startX] = 0;
          }
        }
      }
    }
  }

  /// Validate maze with BFS to ensure solvability
  static Map<String, dynamic> _validateMazeWithBFS(
    List<List<int>> grid,
    Point<int> start,
    Point<int> goal,
  ) {
    final queue = <Point<int>>[start];
    final visited = <Point<int>>{start};
    final parent = <Point<int>, Point<int>>{};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (current == goal) {
        // Reconstruct path
        final path = <Point<int>>[goal];
        Point<int>? p = goal;
        while (parent.containsKey(p)) {
          p = parent[p];
          path.insert(0, p!);
        }

        return {
          'solvable': true,
          'path': path,
          'pathLength': path.length,
        };
      }

      // Check all 4 adjacent cells
      for (final direction in [
        Point<int>(0, 1),
        Point<int>(0, -1),
        Point<int>(1, 0),
        Point<int>(-1, 0),
      ]) {
        final next = Point<int>(
          current.x + direction.x,
          current.y + direction.y,
        );

        if (_isValidCell(next, grid) && !visited.contains(next)) {
          visited.add(next);
          parent[next] = current;
          queue.add(next);
        }
      }
    }

    return {
      'solvable': false,
      'path': [],
      'pathLength': 0,
    };
  }

  /// Score maze fitness based on difficulty-specific metrics
  static Map<String, dynamic> _scorePathFinderFitness(
    List<List<int>> grid,
    Point<int> start,
    Point<int> goal,
    String difficulty,
    Map<String, dynamic> bfsResult,
  ) {
    final optimalPath = bfsResult['path'] as List<Point<int>>;
    final pathLength = optimalPath.length;
    final cornerCount = _countCorners(optimalPath);
    final emptySpaces = _countEmptySpaces(grid);
    final cargoDensity = _calculateCargoDensity(grid);

    // Fitness thresholds by difficulty
    final thresholds = <String, Map<String, dynamic>>{
      'easy': {
        'pathLength': {'min': 20, 'max': 30},
        'corners': {'min': 5, 'max': 12},
        'emptySpaces': {'min': 180, 'max': 220},
        'cargoDensity': {'min': 0.02, 'max': 0.06},
      },
      'medium': {
        'pathLength': {'min': 35, 'max': 50},
        'corners': {'min': 12, 'max': 25},
        'emptySpaces': {'min': 160, 'max': 200},
        'cargoDensity': {'min': 0.04, 'max': 0.08},
      },
      'hard': {
        'pathLength': {'min': 50, 'max': 70},
        'corners': {'min': 25, 'max': 40},
        'emptySpaces': {'min': 140, 'max': 180},
        'cargoDensity': {'min': 0.06, 'max': 0.10},
      },
      'elite': {
        'pathLength': {'min': 70, 'max': 100},
        'corners': {'min': 40, 'max': 60},
        'emptySpaces': {'min': 120, 'max': 160},
        'cargoDensity': {'min': 0.08, 'max': 0.12},
      },
    };

    final threshold = thresholds[difficulty] ?? thresholds['medium']!;

    // Calculate individual metric scores (0-100)
    double scoreMetric(
      int actual,
      Map<String, dynamic> range,
    ) {
      final min = range['min'] as int;
      final max = range['max'] as int;

      if (actual < min) return (50 - ((min - actual) ~/ 2)).toDouble();
      if (actual > max) return (50 - ((actual - max) ~/ 2)).toDouble();
      return 100.0;
    }

    double scoreMetricDouble(
      double actual,
      Map<String, dynamic> range,
    ) {
      final min = range['min'] as double;
      final max = range['max'] as double;

      if (actual < min) return 50 - (50 * ((min - actual) / min));
      if (actual > max) return 50 - (50 * ((actual - max) / max));
      return 100;
    }

    final pathScore = scoreMetric(pathLength, threshold['pathLength']!);
    final cornerScore = scoreMetric(cornerCount, threshold['corners']!);
    final spaceScore = scoreMetric(emptySpaces, threshold['emptySpaces']!);
    final cargoScore = scoreMetricDouble(cargoDensity, threshold['cargoDensity']!);

    // Weighted average fitness score
    final overallScore =
        (pathScore * 0.3 + cornerScore * 0.3 + spaceScore * 0.2 + cargoScore * 0.2)
            .toStringAsFixed(1);

    return {
      'score': double.parse(overallScore),
      'metrics': {
        'pathLength': pathLength,
        'cornerCount': cornerCount,
        'emptySpaces': emptySpaces,
        'cargoDensity': cargoDensity.toStringAsFixed(3),
        'pathScore': double.parse(pathScore.toStringAsFixed(1)),
        'cornerScore': double.parse(cornerScore.toStringAsFixed(1)),
        'spaceScore': double.parse(spaceScore.toStringAsFixed(1)),
        'cargoScore': double.parse(cargoScore.toStringAsFixed(1)),
      },
    };
  }

  /// Generate deterministic hash of maze for anti-cheat verification
  static String _generateMazeHash(List<List<int>> grid) {
    final serialized = _serializeGrid(grid).toString();
    return sha256.convert(utf8.encode(serialized)).toString();
  }

  /// Verify client-submitted path hash against server-expected hash
  static bool verifyMazeHash(String clientHash, String serverHash) {
    return clientHash == serverHash;
  }

  /// Validate client path against optimal BFS solution for anti-cheat
  static Map<String, dynamic> validateClientPath(
    List<Point<int>> clientPath,
    List<List<int>> grid,
    Point<int> start,
    Point<int> goal,
  ) {
    final bfsResult = _validateMazeWithBFS(grid, start, goal);
    final optimalPath = bfsResult['path'] as List<Point<int>>;
    final optimalLength = optimalPath.length;
    final clientLength = clientPath.length;

    // Path efficiency: ratio of optimal to actual path length
    final pathEfficiency = (optimalLength / clientLength).toStringAsFixed(3);

    // Detect cheating: path much longer than optimal suggests possible tampering
    final isSuspicious = clientLength > optimalLength * 2.5;

    return {
      'valid': clientPath.first == start && clientPath.last == goal,
      'pathEfficiency': double.parse(pathEfficiency),
      'optimalLength': optimalLength,
      'clientLength': clientLength,
      'suspicious': isSuspicious,
      'lengthDifference': clientLength - optimalLength,
    };
  }

  // ========== Helper Methods ==========

  static int _getWallCountForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 16;
      case 'medium':
        return 24;
      case 'hard':
        return 32;
      case 'elite':
        return 40;
      default:
        return 24;
    }
  }

  static int _getCargoCountForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 2;
      case 'medium':
        return 3;
      case 'hard':
        return 4;
      case 'elite':
        return 5;
      default:
        return 3;
    }
  }

  static int _manhattanDistance(Point<int> a, Point<int> b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  static bool _isValidCell(Point<int> pos, List<List<int>> grid) {
    if (pos.x < 0 || pos.x >= gridWidth || pos.y < 0 || pos.y >= gridHeight) {
      return false;
    }
    // Valid if not a wall (can be empty, cargo, player, or goal)
    return grid[pos.y][pos.x] != 1;
  }

  static int _countCorners(List<Point<int>> path) {
    if (path.length < 3) return 0;

    int corners = 0;
    for (int i = 1; i < path.length - 1; i++) {
      final prev = path[i - 1];
      final current = path[i];
      final next = path[i + 1];

      final dx1 = current.x - prev.x;
      final dy1 = current.y - prev.y;
      final dx2 = next.x - current.x;
      final dy2 = next.y - current.y;

      // Corner occurs when direction changes
      if ((dx1 != 0 && dy2 != 0) || (dy1 != 0 && dx2 != 0)) {
        corners++;
      }
    }

    return corners;
  }

  static int _countEmptySpaces(List<List<int>> grid) {
    int count = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell == 0) count++;
      }
    }
    return count;
  }

  static double _calculateCargoDensity(List<List<int>> grid) {
    int cargoCount = 0;
    int totalCells = 0;

    for (final row in grid) {
      for (final cell in row) {
        totalCells++;
        if (cell == 4) cargoCount++;
      }
    }

    return totalCells > 0 ? cargoCount / totalCells : 0.0;
  }

  static List<List<int>> _serializeGrid(List<List<int>> grid) {
    return grid.map((row) => List<int>.from(row)).toList();
  }
}
