import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class RotationMasterEngine {
  static const int schemaVersion = 2;

  static const List<_ShapeTemplate> _easyShapes = [
    _ShapeTemplate('polyomino_2d', 2, [
      [0, 0],
      [1, 0],
      [2, 0],
      [0, 1],
      [0, 2],
    ]),
    _ShapeTemplate('polyomino_2d', 2, [
      [0, 0],
      [1, 0],
      [1, 1],
      [2, 1],
      [1, 2],
    ]),
    _ShapeTemplate('polyomino_2d', 2, [
      [0, 0],
      [1, 0],
      [2, 0],
      [2, 1],
      [3, 1],
    ]),
    _ShapeTemplate('polyomino_2d', 2, [
      [0, 0],
      [0, 1],
      [1, 1],
      [2, 1],
      [2, 2],
    ]),
  ];

  static const List<_ShapeTemplate> _mediumShapes = [
    _ShapeTemplate('shepard_3d', 3, [
      [0, 0, 0],
      [1, 0, 0],
      [2, 0, 0],
      [2, 1, 0],
      [2, 1, 1],
    ]),
    _ShapeTemplate('shepard_3d', 3, [
      [0, 0, 0],
      [1, 0, 0],
      [1, 1, 0],
      [1, 1, 1],
      [2, 1, 1],
    ]),
    _ShapeTemplate('shepard_3d', 3, [
      [0, 0, 0],
      [0, 1, 0],
      [1, 1, 0],
      [1, 1, 1],
      [1, 2, 1],
    ]),
    _ShapeTemplate('shepard_3d', 3, [
      [0, 0, 0],
      [1, 0, 0],
      [1, 0, 1],
      [1, 1, 1],
      [2, 1, 1],
    ]),
  ];

  static const List<_ShapeTemplate> _hardShapes = [
    _ShapeTemplate('embedded_3d', 3, [
      [0, 0, 0],
      [1, 0, 0],
      [2, 0, 0],
      [1, 1, 0],
      [1, 1, 1],
      [1, 2, 1],
    ]),
    _ShapeTemplate('embedded_3d', 3, [
      [0, 0, 0],
      [1, 0, 0],
      [1, 1, 0],
      [1, 1, 1],
      [2, 1, 1],
      [2, 2, 1],
    ]),
    _ShapeTemplate('hypercube_4d', 4, [
      [0, 0, 0, 0],
      [1, 0, 0, 0],
      [1, 1, 0, 0],
      [1, 1, 1, 0],
      [1, 1, 1, 1],
    ]),
    _ShapeTemplate('hypercube_4d', 4, [
      [0, 0, 0, 0],
      [0, 1, 0, 0],
      [1, 1, 0, 0],
      [1, 1, 1, 0],
      [1, 1, 1, 1],
    ]),
  ];

  static String buildBattleKey({
    required String battleSeed,
    required int gameIndex,
    required String difficulty,
    required String hintPolicy,
  }) {
    return 'rotation_master|$battleSeed|index:$gameIndex|difficulty:${_normalizeDifficulty(difficulty)}|hint:$hintPolicy|schema:$schemaVersion';
  }

  static Map<String, dynamic> generateChallengeSet({
    required String seed,
    required String difficulty,
    int? promptCount,
  }) {
    final normalizedDifficulty = _normalizeDifficulty(difficulty);
    final count = promptCount ?? _defaultPromptCount(normalizedDifficulty);
    final prompts = List<Map<String, dynamic>>.generate(
      count,
      (index) => generatePrompt(
        seed: seed,
        difficulty: normalizedDifficulty,
        roundIndex: index,
      ),
    );

    final challengeSet = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'type': 'rotation_master',
      'challengeKey': seed,
      'difficulty': normalizedDifficulty,
      'promptCount': count,
      'prompts': prompts,
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
    int? promptCount,
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
      promptCount: promptCount,
    );

    return {
      ...challengeSet,
      'battleSeed': battleSeed,
      'gameIndex': gameIndex,
      'hintPolicy': hintPolicy,
    };
  }

  static Map<String, dynamic> generatePrompt({
    required String seed,
    required String difficulty,
    required int roundIndex,
  }) {
    final normalizedDifficulty = _normalizeDifficulty(difficulty);
    final random = Random(
      _stableSeed('rotation_master|$seed|$normalizedDifficulty|$roundIndex'),
    );

    final config = _configForDifficulty(normalizedDifficulty);
    final shapeIndex = random.nextInt(config.shapes.length);
    final shape = config.shapes[shapeIndex];
    final answerOrder = _shuffledOrder(random, 4);
    final correctOptionIndex = answerOrder.indexOf(0);

    final targetRotationSteps = _buildRotationSteps(
      random: random,
      dimensions: shape.dimensions,
      stepCount: config.targetStepCount,
      allowedPlanes: config.allowedPlanes,
    );

    final targetSegments = _buildSegments(
      cells: shape.cells,
      dimensions: shape.dimensions,
      rotationSteps: targetRotationSteps,
      mirrorAxis: null,
    );

    final distractorMirrorAxes = List<int>.generate(
      3,
      (index) => index % shape.dimensions,
    );

    final optionBlueprints = <Map<String, dynamic>>[
      {
        'optionId': 'correct',
        'kind': 'correct',
        'mirrorAxis': null,
      },
      for (var i = 0; i < distractorMirrorAxes.length; i++)
        {
          'optionId': 'mirror_$i',
          'kind': 'mirror',
          'mirrorAxis': distractorMirrorAxes[i],
        },
    ];

    final orderedOptions = <Map<String, dynamic>>[];
    for (final blueprintIndex in answerOrder) {
      final blueprint = optionBlueprints[blueprintIndex];
      final optionRotationSteps = _buildRotationSteps(
        random: random,
        dimensions: shape.dimensions,
        stepCount: config.optionStepCount,
        allowedPlanes: config.allowedPlanes,
      );
      final segments = _buildSegments(
        cells: shape.cells,
        dimensions: shape.dimensions,
        rotationSteps: optionRotationSteps,
        mirrorAxis: blueprint['mirrorAxis'] as int?,
      );

      orderedOptions.add({
        'optionId': blueprint['optionId'],
        'kind': blueprint['kind'],
        'mirrorAxis': blueprint['mirrorAxis'],
        'rotationSteps': optionRotationSteps,
        'segments': segments['segments'],
        'viewBox': segments['viewBox'],
      });
    }

    final prompt = <String, dynamic>{
      'roundIndex': roundIndex,
      'mode': 'single_choice',
      'family': shape.family,
      'dimension': shape.dimensions,
      'shapeIndex': shapeIndex,
      'colorProfile': config.colorProfile,
      'targetRotationSteps': targetRotationSteps,
      'mirrorAxis': distractorMirrorAxes.first,
      'answerOrder': answerOrder,
      'correctOptionIndex': correctOptionIndex,
      'correctIndices': [correctOptionIndex],
      'baseCells': shape.cells,
      'target': {
        'segments': targetSegments['segments'],
        'viewBox': targetSegments['viewBox'],
      },
      'options': orderedOptions,
    };

    return {
      ...prompt,
      'canonicalChecksum': _checksumForMap(prompt),
    };
  }

  static String computeSubmissionHash(Map<String, dynamic> submission) {
    return _checksumForMap(submission);
  }

  static Map<String, dynamic> buildSubmissionPayload({
    required Map<String, dynamic> challengeSet,
    required List<Map<String, dynamic>> responses,
    required int totalTimeMs,
    required int score,
    int hintsUsed = 0,
  }) {
    final payload = <String, dynamic>{
      'challengeKey': challengeSet['challengeKey'],
      'challengeChecksum': challengeSet['canonicalChecksum'],
      'promptCount': challengeSet['promptCount'],
      'responses': responses,
      'totalTimeMs': totalTimeMs,
      'score': score,
      'hintsUsed': hintsUsed,
      'perfect': responses.every((response) => response['isCorrect'] == true),
    };

    return {
      ...payload,
      'submissionHash': computeSubmissionHash(payload),
    };
  }

  static _DifficultyConfig _configForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return const _DifficultyConfig(
          colorProfile: 'vivid',
          targetStepCount: 1,
          optionStepCount: 1,
          allowedPlanes: [
            [0, 1],
          ],
          shapes: _easyShapes,
        );
      case 'hard':
        return const _DifficultyConfig(
          colorProfile: 'mono',
          targetStepCount: 3,
          optionStepCount: 2,
          allowedPlanes: [
            [0, 1],
            [0, 2],
            [1, 2],
            [0, 3],
            [1, 3],
            [2, 3],
          ],
          shapes: _hardShapes,
        );
      case 'medium':
      default:
        return const _DifficultyConfig(
          colorProfile: 'mono',
          targetStepCount: 1,
          optionStepCount: 1,
          allowedPlanes: [
            [0, 2],
            [1, 2],
          ],
          shapes: _mediumShapes,
        );
    }
  }

  static String _normalizeDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'medium':
      case 'hard':
        return difficulty.toLowerCase();
      default:
        return 'medium';
    }
  }

  static int _defaultPromptCount(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 5;
      case 'hard':
        return 10;
      case 'medium':
      default:
        return 8;
    }
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

  static List<int> _shuffledOrder(Random random, int length) {
    final order = List<int>.generate(length, (index) => index);
    for (var i = order.length - 1; i > 0; i--) {
      final swapIndex = random.nextInt(i + 1);
      final temp = order[i];
      order[i] = order[swapIndex];
      order[swapIndex] = temp;
    }
    return order;
  }

  static List<Map<String, dynamic>> _buildRotationSteps({
    required Random random,
    required int dimensions,
    required int stepCount,
    required List<List<int>> allowedPlanes,
  }) {
    final validPlanes = allowedPlanes
        .where((plane) => plane[0] < dimensions && plane[1] < dimensions)
        .toList();

    return List<Map<String, dynamic>>.generate(stepCount, (_) {
      final plane = validPlanes[random.nextInt(validPlanes.length)];
      return {
        'plane': plane,
        'quarterTurns': random.nextInt(3) + 1,
      };
    });
  }

  static Map<String, dynamic> _buildSegments({
    required List<List<int>> cells,
    required int dimensions,
    required List<Map<String, dynamic>> rotationSteps,
    required int? mirrorAxis,
  }) {
    final centeredCells = _centerCells(cells, dimensions);
    final segments = <List<int>>[];

    for (final cell in centeredCells) {
      final vertices = _cellVertices(cell, dimensions);
      final transformedVertices = vertices
          .map(
            (vertex) => _applyTransforms(
              point: vertex,
              rotationSteps: rotationSteps,
              mirrorAxis: mirrorAxis,
            ),
          )
          .toList();

      for (final edge in _edgePairs(dimensions)) {
        final start = _projectPoint(transformedVertices[edge[0]]);
        final end = _projectPoint(transformedVertices[edge[1]]);
        segments.add(_normalizeSegment(start, end));
      }
    }

    segments.sort(_compareSegments);

    var minX = 1 << 30;
    var minY = 1 << 30;
    var maxX = -(1 << 30);
    var maxY = -(1 << 30);
    for (final segment in segments) {
      minX = min(minX, min(segment[0], segment[2]));
      minY = min(minY, min(segment[1], segment[3]));
      maxX = max(maxX, max(segment[0], segment[2]));
      maxY = max(maxY, max(segment[1], segment[3]));
    }

    final normalizedSegments = segments
        .map(
          (segment) => [
            segment[0] - minX,
            segment[1] - minY,
            segment[2] - minX,
            segment[3] - minY,
          ],
        )
        .toList();

    return {
      'segments': normalizedSegments,
      'viewBox': {
        'width': max(1, maxX - minX),
        'height': max(1, maxY - minY),
      },
    };
  }

  static List<List<int>> _centerCells(List<List<int>> cells, int dimensions) {
    final mins = List<int>.filled(dimensions, 1 << 30);
    final maxs = List<int>.filled(dimensions, -(1 << 30));

    for (final cell in cells) {
      for (var axis = 0; axis < dimensions; axis++) {
        mins[axis] = min(mins[axis], cell[axis]);
        maxs[axis] = max(maxs[axis], cell[axis]);
      }
    }

    return cells
        .map(
          (cell) => List<int>.generate(
            dimensions,
            (axis) => (cell[axis] * 2) - mins[axis] - maxs[axis],
          ),
        )
        .toList();
  }

  static List<List<int>> _cellVertices(List<int> cellCenter, int dimensions) {
    final vertexCount = 1 << dimensions;
    return List<List<int>>.generate(vertexCount, (index) {
      return List<int>.generate(dimensions, (axis) {
        final sign = ((index >> axis) & 1) == 0 ? -1 : 1;
        return (cellCenter[axis] * 2) + sign;
      });
    });
  }

  static List<List<int>> _edgePairs(int dimensions) {
    final pairs = <List<int>>[];
    final vertexCount = 1 << dimensions;
    for (var index = 0; index < vertexCount; index++) {
      for (var axis = 0; axis < dimensions; axis++) {
        final neighbor = index ^ (1 << axis);
        if (index < neighbor) {
          pairs.add([index, neighbor]);
        }
      }
    }
    return pairs;
  }

  static List<int> _applyTransforms({
    required List<int> point,
    required List<Map<String, dynamic>> rotationSteps,
    required int? mirrorAxis,
  }) {
    final transformed = List<int>.from(point);
    if (mirrorAxis != null && mirrorAxis < transformed.length) {
      transformed[mirrorAxis] = -transformed[mirrorAxis];
    }

    for (final step in rotationSteps) {
      final plane = (step['plane'] as List).cast<int>();
      final quarterTurns = (step['quarterTurns'] as int) % 4;
      for (var i = 0; i < quarterTurns; i++) {
        final a = transformed[plane[0]];
        final b = transformed[plane[1]];
        transformed[plane[0]] = -b;
        transformed[plane[1]] = a;
      }
    }

    return transformed;
  }

  static List<int> _projectPoint(List<int> point) {
    if (point.length == 2) {
      return [point[0] * 4, point[1] * 4];
    }

    if (point.length == 3) {
      return [
        (point[0] * 4) - (point[1] * 2),
        (point[2] * 4) + (point[1] * 2),
      ];
    }

    final x3 = (point[0] * 4) + (point[3] * 2);
    final y3 = (point[1] * 4) - (point[3] * 2);
    final z3 = point[2] * 4;
    return [
      (x3 * 2) - y3,
      (z3 * 2) + y3,
    ];
  }

  static List<int> _normalizeSegment(List<int> start, List<int> end) {
    if (_comparePoints(start, end) <= 0) {
      return [start[0], start[1], end[0], end[1]];
    }
    return [end[0], end[1], start[0], start[1]];
  }

  static int _comparePoints(List<int> a, List<int> b) {
    if (a[0] != b[0]) return a[0].compareTo(b[0]);
    return a[1].compareTo(b[1]);
  }

  static int _compareSegments(List<int> a, List<int> b) {
    for (var i = 0; i < 4; i++) {
      if (a[i] != b[i]) {
        return a[i].compareTo(b[i]);
      }
    }
    return 0;
  }

  static String _checksumForMap(Map<String, dynamic> map) {
    final canonical = _stableSerialize(map);
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static String _stableSerialize(dynamic value) {
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
    return jsonEncode(value.toString());
  }
}

class _DifficultyConfig {
  const _DifficultyConfig({
    required this.colorProfile,
    required this.targetStepCount,
    required this.optionStepCount,
    required this.allowedPlanes,
    required this.shapes,
  });

  final String colorProfile;
  final int targetStepCount;
  final int optionStepCount;
  final List<List<int>> allowedPlanes;
  final List<_ShapeTemplate> shapes;
}

class _ShapeTemplate {
  const _ShapeTemplate(this.family, this.dimensions, this.cells);

  final String family;
  final int dimensions;
  final List<List<int>> cells;
}
