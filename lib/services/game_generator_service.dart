import 'dart:math';
import 'package:mind_wars/games/rotation_master/rotation_master_engine.dart';
import 'package:mind_wars/games/path_finder/path_finder_engine.dart';

/// Game Generator Service
///
/// Generates deterministic game state from gameIndex + seed.
/// All players use the same gameIndex and seed to produce identical game states,
/// enabling pixel-perfect cloned gameplay across all mind war participants.
class GameGeneratorService {
  /// Generate a game state from its metadata
  /// Returns a map containing game-specific state that can be used by the UI
  static Map<String, dynamic> generateGameState({
    required String gameId,
    required int gameIndex,
    required String seed,
    required String difficulty,
    required String hintPolicy,
  }) {
    final random = Random(seed.hashCode + gameIndex);

    switch (gameId) {
      case 'memory_match':
        return _generateMemoryMatch(random, difficulty, hintPolicy, gameIndex);
      case 'sequence_recall':
        return _generateSequenceRecall(random, difficulty, hintPolicy, gameIndex);
      case 'pattern_memory':
        return _generatePatternMemory(random, difficulty, hintPolicy, gameIndex);

      case 'sudoku_duel':
        return _generateSudokuDuel(random, difficulty, hintPolicy, gameIndex);
      case 'logic_grid':
        return _generateLogicGrid(random, difficulty, hintPolicy, gameIndex);
      case 'code_breaker':
        return _generateCodeBreaker(random, difficulty, hintPolicy, gameIndex);

      case 'spot_difference':
        return _generateSpotDifference(random, difficulty, hintPolicy, gameIndex);
      case 'color_rush':
        return _generateColorRush(random, difficulty, hintPolicy, gameIndex);
      case 'focus_finder':
        return _generateFocusFinder(random, difficulty, hintPolicy, gameIndex);

      case 'puzzle_race':
        return _generatePuzzleRace(random, difficulty, hintPolicy, gameIndex);
      case 'rotation_master':
        return _generateRotationMaster(seed, difficulty, hintPolicy, gameIndex);
      case 'path_finder':
        return _generatePathFinder(seed, difficulty, hintPolicy, gameIndex);

      case 'word_builder':
        return _generateWordBuilder(random, difficulty, hintPolicy, gameIndex);
      case 'anagram_attack':
        return _generateAnagramAttack(random, difficulty, hintPolicy, gameIndex);
      case 'vocabulary_showdown':
        return _generateVocabularyShowdown(random, difficulty, hintPolicy, gameIndex);

      default:
        return _generatePlaceholder(gameId, difficulty, hintPolicy, gameIndex);
    }
  }

  // ============================================================================
  // Memory Games
  // ============================================================================

  static Map<String, dynamic> _generateMemoryMatch(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final cardCount = difficulty == 'easy' ? 12 : difficulty == 'medium' ? 16 : 20;
    final pairs = cardCount ~/ 2;

    // Generate card pairs using seeded random
    final cardIds = List<int>.generate(pairs, (i) => i);
    cardIds.addAll(cardIds); // Duplicate for pairs
    cardIds.shuffle(random);

    return {
      'type': 'memory_match',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'cardCount': cardCount,
      'pairs': pairs,
      'cards': cardIds,
      'flipped': List<bool>.filled(cardCount, false),
      'matched': List<bool>.filled(cardCount, false),
      'moves': 0,
      'matches': 0,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateSequenceRecall(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final sequenceLength = difficulty == 'easy' ? 5 : difficulty == 'medium' ? 8 : 12;
    final sequence = List<int>.generate(
      sequenceLength,
      (_) => random.nextInt(9),
    );

    return {
      'type': 'sequence_recall',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'sequence': sequence,
      'displayedCount': 0,
      'playerSequence': <int>[],
      'round': 1,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generatePatternMemory(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final patternSize = difficulty == 'easy' ? 3 : difficulty == 'medium' ? 4 : 5;
    final pattern = List<List<int>>.generate(
      patternSize,
      (_) => List<int>.generate(patternSize, (_) => random.nextInt(2)),
    );

    return {
      'type': 'pattern_memory',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'patternSize': patternSize,
      'pattern': pattern,
      'revealed': false,
      'revealTime': 3000,
      'playerPattern': <List<int>>[],
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // ============================================================================
  // Logic Games
  // ============================================================================

  static Map<String, dynamic> _generateSudokuDuel(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    // For Phase 2, return a placeholder with basic grid
    final emptyCount = difficulty == 'easy' ? 20 : difficulty == 'medium' ? 40 : 55;

    return {
      'type': 'sudoku_duel',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'emptyCount': emptyCount,
      'grid': List<List<int>>.filled(9, List<int>.filled(9, 0)),
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateLogicGrid(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    return {
      'type': 'logic_grid',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateCodeBreaker(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final codeLength = difficulty == 'easy' ? 4 : difficulty == 'medium' ? 5 : 6;
    final code = List<int>.generate(codeLength, (_) => random.nextInt(10));

    return {
      'type': 'code_breaker',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'codeLength': codeLength,
      'code': code,
      'guesses': <List<int>>[],
      'feedback': <Map<String, dynamic>>[],
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // ============================================================================
  // Attention Games
  // ============================================================================

  static Map<String, dynamic> _generateSpotDifference(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final differenceCount = difficulty == 'easy' ? 3 : difficulty == 'medium' ? 5 : 7;

    return {
      'type': 'spot_difference',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'differenceCount': differenceCount,
      'foundCount': 0,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateColorRush(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    return {
      'type': 'color_rush',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateFocusFinder(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    return {
      'type': 'focus_finder',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // ============================================================================
  // Spatial Games
  // ============================================================================

  static Map<String, dynamic> _generatePuzzleRace(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    return {
      'type': 'puzzle_race',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateRotationMaster(
    String battleSeed,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final challengeSet = RotationMasterEngine.generateBattleChallengeSet(
      battleSeed: battleSeed,
      gameIndex: gameIndex,
      difficulty: difficulty,
      hintPolicy: hintPolicy,
    );

    return {
      'type': 'rotation_master',
      'gameIndex': gameIndex,
      'seed': battleSeed,
      'difficulty': difficulty,
      'hintPolicy': hintPolicy,
      'challengeSet': challengeSet,
      'currentPromptIndex': 0,
      'selectedIndices': <int>[],
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generatePathFinder(
    String battleSeed,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    return PathFinderEngine.generateBattleChallenge(
      battleSeed: battleSeed,
      gameIndex: gameIndex,
      difficulty: difficulty,
      hintPolicy: hintPolicy,
    );
  }

  // ============================================================================
  // Language Games
  // ============================================================================

  static Map<String, dynamic> _generateWordBuilder(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final timeLimit = difficulty == 'easy' ? 120 : difficulty == 'medium' ? 90 : 60;

    return {
      'type': 'word_builder',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
      'words': <String>[],
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateAnagramAttack(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final roundCount = difficulty == 'easy' ? 5 : difficulty == 'medium' ? 8 : 10;

    return {
      'type': 'anagram_attack',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'roundCount': roundCount,
      'currentRound': 0,
      'solutions': <String>[],
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Map<String, dynamic> _generateVocabularyShowdown(
    Random random,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    final questionCount = difficulty == 'easy' ? 5 : difficulty == 'medium' ? 10 : 15;

    return {
      'type': 'vocabulary_showdown',
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'questionCount': questionCount,
      'currentQuestion': 0,
      'correctAnswers': 0,
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // ============================================================================
  // Placeholder
  // ============================================================================

  static Map<String, dynamic> _generatePlaceholder(
    String gameId,
    String difficulty,
    String hintPolicy,
    int gameIndex,
  ) {
    return {
      'type': gameId,
      'gameIndex': gameIndex,
      'difficulty': difficulty,
      'hintPolicy': hintPolicy,
      'status': 'coming_soon',
      'startTime': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
