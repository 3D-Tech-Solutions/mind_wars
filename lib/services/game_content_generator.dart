/**
 * Game Content Generator - Feature 3.6
 * Generates 12+ puzzles across 5 cognitive categories
 * Supports offline play with local generation
 */

import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../games/rotation_master/rotation_master_engine.dart';

/// Difficulty levels for puzzles
enum Difficulty { easy, medium, hard }

/// Base puzzle class
abstract class Puzzle {
  final String id;
  final String gameType;
  final CognitiveCategory category;
  final Difficulty difficulty;
  final Map<String, dynamic> data;
  final Map<String, dynamic> solution;
  final int maxScore;
  final int timeLimit; // seconds

  Puzzle({
    required this.id,
    required this.gameType,
    required this.category,
    required this.difficulty,
    required this.data,
    required this.solution,
    required this.maxScore,
    required this.timeLimit,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameType': gameType,
        'category': category.toString(),
        'difficulty': difficulty.toString(),
        'data': data,
        'solution': solution,
        'maxScore': maxScore,
        'timeLimit': timeLimit,
      };
}

/// Game Content Generator Service
class GameContentGenerator {
  final Random _random = Random();
  final Uuid _uuid = Uuid();

  /// Generate unique ID for puzzles
  String _generatePuzzleId(String type) {
    return '${type}_${_uuid.v4()}';
  }

  /// Generate puzzle for a specific game type and difficulty - Feature 3.6.1
  Puzzle generatePuzzle({
    required String gameType,
    required Difficulty difficulty,
  }) {
    switch (gameType) {
      // Memory Games
      case 'memory_match':
        return _generateMemoryMatch(difficulty);
      case 'sequence_recall':
        return _generateSequenceRecall(difficulty);
      case 'pattern_memory':
        return _generatePatternMemory(difficulty);

      // Logic Games
      case 'sudoku_duel':
        return _generateSudoku(difficulty);
      case 'logic_grid':
        return _generateLogicGrid(difficulty);
      case 'code_breaker':
        return _generateCodeBreaker(difficulty);

      // Attention Games
      case 'spot_difference':
        return _generateSpotDifference(difficulty);
      case 'color_rush':
        return _generateColorRush(difficulty);
      case 'focus_finder':
        return _generateFocusFinder(difficulty);

      // Spatial Games
      case 'puzzle_race':
        return _generatePuzzleRace(difficulty);
      case 'rotation_master':
        return _generateRotationMaster(difficulty);
      case 'path_finder':
        return _generatePathFinder(difficulty);

      // Language Games
      case 'word_builder':
        return _generateWordBuilder(difficulty);
      case 'anagram_attack':
        return _generateAnagramAttack(difficulty);
      case 'vocabulary_showdown':
        return _generateVocabularyShowdown(difficulty);

      default:
        throw Exception('Unknown game type: $gameType');
    }
  }

  /// Generate multiple puzzles for a game type
  List<Puzzle> generatePuzzleSet({
    required String gameType,
    int count = 3,
  }) {
    final puzzles = <Puzzle>[];
    final difficulties = [Difficulty.easy, Difficulty.medium, Difficulty.hard];

    for (var i = 0; i < count; i++) {
      final difficulty = difficulties[i % difficulties.length];
      puzzles.add(generatePuzzle(gameType: gameType, difficulty: difficulty));
    }

    return puzzles;
  }

  /// Generate all 12+ games with 3 difficulty levels each
  Map<String, List<Puzzle>> generateAllContent() {
    final allGames = [
      'memory_match',
      'sequence_recall',
      'pattern_memory',
      'sudoku_duel',
      'logic_grid',
      'code_breaker',
      'spot_difference',
      'color_rush',
      'focus_finder',
      'puzzle_race',
      'rotation_master',
      'path_finder',
      'word_builder',
      'anagram_attack',
      'vocabulary_showdown',
    ];

    final content = <String, List<Puzzle>>{};

    for (var gameType in allGames) {
      content[gameType] = generatePuzzleSet(gameType: gameType, count: 3);
    }

    return content;
  }

  // MEMORY GAMES

  Puzzle _generateMemoryMatch(Difficulty difficulty) {
    final pairCount = _getPairCount(difficulty);
    final symbols = ['🍎', '🍌', '🍇', '🍊', '🍓', '🍑', '🍒', '🍍', '🥝', '🥥'];
    final selectedSymbols = symbols.take(pairCount).toList();
    final cards = [...selectedSymbols, ...selectedSymbols];
    cards.shuffle(_random);

    return _MemoryMatchPuzzle(
      id: _generatePuzzleId('memory_match'),
      difficulty: difficulty,
      cards: cards,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 120),
    );
  }

  Puzzle _generateSequenceRecall(Difficulty difficulty) {
    final length = difficulty == Difficulty.easy
        ? 4
        : difficulty == Difficulty.medium
            ? 6
            : 8;
    final sequence = List.generate(length, (_) => _random.nextInt(9) + 1);

    return _SequenceRecallPuzzle(
      id: _generatePuzzleId('sequence_recall'),
      difficulty: difficulty,
      sequence: sequence,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 60),
    );
  }

  Puzzle _generatePatternMemory(Difficulty difficulty) {
    final gridSize = difficulty == Difficulty.easy ? 3 : difficulty == Difficulty.medium ? 4 : 5;
    final fillCount = (gridSize * gridSize * 0.4).round();
    final pattern = List.generate(gridSize * gridSize, (i) => false);

    // Randomly fill cells
    final indices = List.generate(gridSize * gridSize, (i) => i)..shuffle(_random);
    for (var i = 0; i < fillCount; i++) {
      pattern[indices[i]] = true;
    }

    return _PatternMemoryPuzzle(
      id: _generatePuzzleId('pattern_memory'),
      difficulty: difficulty,
      gridSize: gridSize,
      pattern: pattern,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 90),
    );
  }

  // LOGIC GAMES

  Puzzle _generateSudoku(Difficulty difficulty) {
    // Simplified Sudoku generation (4x4 for easy, 6x6 for medium, 9x9 for hard)
    final size = difficulty == Difficulty.easy ? 4 : difficulty == Difficulty.medium ? 6 : 9;

    return _SudokuPuzzle(
      id: _generatePuzzleId('sudoku_duel'),
      difficulty: difficulty,
      size: size,
      clues: {},
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 300),
    );
  }

  Puzzle _generateLogicGrid(Difficulty difficulty) {
    final categories = ['Colors', 'Numbers', 'Letters'];
    final itemsPerCategory = difficulty == Difficulty.easy ? 3 : difficulty == Difficulty.medium ? 4 : 5;

    return _LogicGridPuzzle(
      id: _generatePuzzleId('logic_grid'),
      difficulty: difficulty,
      categories: categories,
      itemsPerCategory: itemsPerCategory,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 180),
    );
  }

  Puzzle _generateCodeBreaker(Difficulty difficulty) {
    final codeLength = difficulty == Difficulty.easy ? 3 : difficulty == Difficulty.medium ? 4 : 5;
    final code = List.generate(codeLength, (_) => _random.nextInt(6) + 1);

    return _CodeBreakerPuzzle(
      id: _generatePuzzleId('code_breaker'),
      difficulty: difficulty,
      code: code,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 180),
    );
  }

  // ATTENTION GAMES

  Puzzle _generateSpotDifference(Difficulty difficulty) {
    final differenceCount = difficulty == Difficulty.easy ? 3 : difficulty == Difficulty.medium ? 5 : 7;

    return _SpotDifferencePuzzle(
      id: _generatePuzzleId('spot_difference'),
      difficulty: difficulty,
      differenceCount: differenceCount,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 120),
    );
  }

  Puzzle _generateColorRush(Difficulty difficulty) {
    final sequenceLength = difficulty == Difficulty.easy ? 5 : difficulty == Difficulty.medium ? 8 : 12;
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];
    final sequence = List.generate(sequenceLength, (_) => colors[_random.nextInt(colors.length)]);

    return _ColorRushPuzzle(
      id: _generatePuzzleId('color_rush'),
      difficulty: difficulty,
      sequence: sequence,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 60),
    );
  }

  Puzzle _generateFocusFinder(Difficulty difficulty) {
    final targetCount = difficulty == Difficulty.easy ? 3 : difficulty == Difficulty.medium ? 5 : 8;
    final distractorCount = difficulty == Difficulty.easy ? 10 : difficulty == Difficulty.medium ? 20 : 30;

    return _FocusFinderPuzzle(
      id: _generatePuzzleId('focus_finder'),
      difficulty: difficulty,
      targetCount: targetCount,
      distractorCount: distractorCount,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 90),
    );
  }

  // SPATIAL GAMES

  Puzzle _generatePuzzleRace(Difficulty difficulty) {
    final pieceCount = difficulty == Difficulty.easy ? 9 : difficulty == Difficulty.medium ? 16 : 25;

    return _PuzzleRacePuzzle(
      id: _generatePuzzleId('puzzle_race'),
      difficulty: difficulty,
      pieceCount: pieceCount,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 180),
    );
  }

  Puzzle _generateRotationMaster(Difficulty difficulty) {
    final difficultyName = difficulty == Difficulty.easy
        ? 'easy'
        : difficulty == Difficulty.medium
            ? 'medium'
            : 'hard';
    final challengeSet = RotationMasterEngine.generateChallengeSet(
      seed: _generatePuzzleId('rotation_master_seed'),
      difficulty: difficultyName,
    );

    return _RotationMasterPuzzle(
      id: _generatePuzzleId('rotation_master'),
      difficulty: difficulty,
      challengeSet: challengeSet,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 90),
    );
  }

  Puzzle _generatePathFinder(Difficulty difficulty) {
    final gridSize = difficulty == Difficulty.easy ? 5 : difficulty == Difficulty.medium ? 7 : 10;

    return _PathFinderPuzzle(
      id: _generatePuzzleId('path_finder'),
      difficulty: difficulty,
      gridSize: gridSize,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 120),
    );
  }

  // LANGUAGE GAMES

  Puzzle _generateWordBuilder(Difficulty difficulty) {
    final letterCount = difficulty == Difficulty.easy ? 6 : difficulty == Difficulty.medium ? 8 : 10;
    final letters = 'AEIOURSTLNBCDFGHJKMPQVWXYZ';
    final selectedLetters =
        List.generate(letterCount, (_) => letters[_random.nextInt(letters.length)]).join();

    return _WordBuilderPuzzle(
      id: _generatePuzzleId('word_builder'),
      difficulty: difficulty,
      letters: selectedLetters,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 120),
    );
  }

  Puzzle _generateAnagramAttack(Difficulty difficulty) {
    final words = difficulty == Difficulty.easy
        ? ['HELLO', 'WORLD', 'HAPPY']
        : difficulty == Difficulty.medium
            ? ['PUZZLE', 'MASTER', 'CHALLENGE']
            : ['COGNITIVE', 'STRATEGIC', 'COMPETITIVE'];

    final word = words[_random.nextInt(words.length)];
    final scrambled = (word.split('')..shuffle(_random)).join();

    return _AnagramAttackPuzzle(
      id: _generatePuzzleId('anagram_attack'),
      difficulty: difficulty,
      scrambledWord: scrambled,
      solution: word,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 60),
    );
  }

  Puzzle _generateVocabularyShowdown(Difficulty difficulty) {
    final questionCount = difficulty == Difficulty.easy ? 5 : difficulty == Difficulty.medium ? 8 : 12;

    return _VocabularyShowdownPuzzle(
      id: _generatePuzzleId('vocabulary_showdown'),
      difficulty: difficulty,
      questionCount: questionCount,
      maxScore: _getMaxScore(difficulty),
      timeLimit: _getTimeLimit(difficulty, 120),
    );
  }

  // Helper methods

  int _getPairCount(Difficulty difficulty) {
    return difficulty == Difficulty.easy ? 4 : difficulty == Difficulty.medium ? 6 : 8;
  }

  int _getMaxScore(Difficulty difficulty) {
    return difficulty == Difficulty.easy ? 100 : difficulty == Difficulty.medium ? 200 : 300;
  }

  int _getTimeLimit(Difficulty difficulty, int baseTime) {
    return difficulty == Difficulty.easy
        ? (baseTime * 1.5).round()
        : difficulty == Difficulty.medium
            ? baseTime
            : (baseTime * 0.7).round();
  }
}

// Concrete Puzzle Implementations

class _MemoryMatchPuzzle extends Puzzle {
  _MemoryMatchPuzzle({
    required Difficulty difficulty,
    required List<String> cards,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'memory_match',
          category: CognitiveCategory.memory,
          difficulty: difficulty,
          data: {'cards': cards},
          solution: {'pairs': cards.length ~/ 2},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _SequenceRecallPuzzle extends Puzzle {
  _SequenceRecallPuzzle({
    required Difficulty difficulty,
    required List<int> sequence,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'sequence_recall',
          category: CognitiveCategory.memory,
          difficulty: difficulty,
          data: {'sequence': sequence},
          solution: {'sequence': sequence},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _PatternMemoryPuzzle extends Puzzle {
  _PatternMemoryPuzzle({
    required Difficulty difficulty,
    required int gridSize,
    required List<bool> pattern,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'pattern_memory',
          category: CognitiveCategory.memory,
          difficulty: difficulty,
          data: {'gridSize': gridSize, 'pattern': pattern},
          solution: {'pattern': pattern},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _SudokuPuzzle extends Puzzle {
  _SudokuPuzzle({
    required Difficulty difficulty,
    required int size,
    required Map<String, int> clues,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'sudoku_duel',
          category: CognitiveCategory.logic,
          difficulty: difficulty,
          data: {'size': size, 'clues': clues},
          solution: {'grid': []},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _LogicGridPuzzle extends Puzzle {
  _LogicGridPuzzle({
    required Difficulty difficulty,
    required List<String> categories,
    required int itemsPerCategory,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'logic_grid',
          category: CognitiveCategory.logic,
          difficulty: difficulty,
          data: {'categories': categories, 'itemsPerCategory': itemsPerCategory},
          solution: {'matches': {}},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _CodeBreakerPuzzle extends Puzzle {
  _CodeBreakerPuzzle({
    required Difficulty difficulty,
    required List<int> code,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'code_breaker',
          category: CognitiveCategory.logic,
          difficulty: difficulty,
          data: {'codeLength': code.length},
          solution: {'code': code},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _SpotDifferencePuzzle extends Puzzle {
  _SpotDifferencePuzzle({
    required Difficulty difficulty,
    required int differenceCount,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'spot_difference',
          category: CognitiveCategory.attention,
          difficulty: difficulty,
          data: {'differenceCount': differenceCount},
          solution: {'differences': []},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _ColorRushPuzzle extends Puzzle {
  _ColorRushPuzzle({
    required Difficulty difficulty,
    required List<String> sequence,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'color_rush',
          category: CognitiveCategory.attention,
          difficulty: difficulty,
          data: {'sequence': sequence},
          solution: {'sequence': sequence},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _FocusFinderPuzzle extends Puzzle {
  _FocusFinderPuzzle({
    required Difficulty difficulty,
    required int targetCount,
    required int distractorCount,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'focus_finder',
          category: CognitiveCategory.attention,
          difficulty: difficulty,
          data: {'targetCount': targetCount, 'distractorCount': distractorCount},
          solution: {'targets': []},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _PuzzleRacePuzzle extends Puzzle {
  _PuzzleRacePuzzle({
    required Difficulty difficulty,
    required int pieceCount,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'puzzle_race',
          category: CognitiveCategory.spatial,
          difficulty: difficulty,
          data: {'pieceCount': pieceCount},
          solution: {'completed': true},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _RotationMasterPuzzle extends Puzzle {
  _RotationMasterPuzzle({
    required Difficulty difficulty,
    required Map<String, dynamic> challengeSet,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'rotation_master',
          category: CognitiveCategory.spatial,
          difficulty: difficulty,
          data: challengeSet,
          solution: {
            'correctIndicesByPrompt': (challengeSet['prompts'] as List)
                .map((prompt) => prompt['correctIndices'])
                .toList(),
          },
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _PathFinderPuzzle extends Puzzle {
  _PathFinderPuzzle({
    required Difficulty difficulty,
    required int gridSize,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'path_finder',
          category: CognitiveCategory.spatial,
          difficulty: difficulty,
          data: {'gridSize': gridSize},
          solution: {'path': []},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _WordBuilderPuzzle extends Puzzle {
  _WordBuilderPuzzle({
    required Difficulty difficulty,
    required String letters,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'word_builder',
          category: CognitiveCategory.language,
          difficulty: difficulty,
          data: {'letters': letters},
          solution: {'possibleWords': []},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _AnagramAttackPuzzle extends Puzzle {
  _AnagramAttackPuzzle({
    required Difficulty difficulty,
    required String scrambledWord,
    required String solution,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'anagram_attack',
          category: CognitiveCategory.language,
          difficulty: difficulty,
          data: {'scrambledWord': scrambledWord},
          solution: {'word': solution},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}

class _VocabularyShowdownPuzzle extends Puzzle {
  _VocabularyShowdownPuzzle({
    required Difficulty difficulty,
    required int questionCount,
    required int maxScore,
    required int timeLimit,
    required String id,
  }) : super(
          id: id,
          gameType: 'vocabulary_showdown',
          category: CognitiveCategory.language,
          difficulty: difficulty,
          data: {'questionCount': questionCount},
          solution: {'answers': []},
          maxScore: maxScore,
          timeLimit: timeLimit,
        );
}
