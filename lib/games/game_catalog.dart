/**
 * Game Catalog - 12+ games across 5 cognitive categories
 * Mobile-First: Designed for 5" touch screens
 *
 * [2026-04-03 Clarification] All games are fully multiplayer.
 * In a Mind War, any number of players (2-10+) each play the SAME game
 * independently and simultaneously, then scores are compared.
 * Games scale to any number of competitors - no player limits.
 */

import '../models/models.dart';

class GameTemplate {
  final String id;
  final String name;
  final CognitiveCategory category;
  final String description;
  final String icon;
  final String rules;

  GameTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.rules,
  });
}

class GameCatalog {
  static final List<GameTemplate> _games = [
    // MEMORY GAMES (3)
    GameTemplate(
      id: 'memory_match',
      name: 'Memory Match',
      category: CognitiveCategory.memory,
      description: 'Match pairs of cards by remembering positions',
      icon: '🃏',
      rules: 'Flip two cards and match pairs. Your matches and speed determine your score in the Mind War.',
    ),
    GameTemplate(
      id: 'sequence_recall',
      name: 'Sequence Recall',
      category: CognitiveCategory.memory,
      description: 'Remember and reproduce increasingly long sequences',
      icon: '🔢',
      rules: 'Watch the sequence, then reproduce it. Sequences get longer each round. Score based on length and accuracy.',
    ),
    GameTemplate(
      id: 'pattern_memory',
      name: 'Pattern Memory',
      category: CognitiveCategory.memory,
      description: 'Recreate complex visual patterns from memory',
      icon: '🎨',
      rules: 'Study the pattern briefly, then recreate it. Accuracy and speed determine your score.',
    ),

    // LOGIC GAMES (3)
    GameTemplate(
      id: 'sudoku_duel',
      name: 'Sudoku Duel',
      category: CognitiveCategory.logic,
      description: 'Solve Sudoku puzzles with speed and accuracy',
      icon: '🔢',
      rules: 'Complete the Sudoku puzzle. Speed and correctness determine your score in the Mind War.',
    ),
    GameTemplate(
      id: 'logic_grid',
      name: 'Logic Grid',
      category: CognitiveCategory.logic,
      description: 'Solve logic puzzles using deduction',
      icon: '🧮',
      rules: 'Use clues to deduce the correct arrangement. Score based on puzzle completion and time.',
    ),
    GameTemplate(
      id: 'code_breaker',
      name: 'Code Breaker',
      category: CognitiveCategory.logic,
      description: 'Deduce secret codes using logical reasoning',
      icon: '🔐',
      rules: 'Guess the secret code. Feedback on each guess helps you narrow down the solution. Score based on guesses and time.',
    ),

    // ATTENTION GAMES (3)
    GameTemplate(
      id: 'spot_difference',
      name: 'Spot the Difference',
      category: CognitiveCategory.attention,
      description: 'Find differences between similar images quickly',
      icon: '👀',
      rules: 'Find all differences between two images. Score based on accuracy and speed.',
    ),
    GameTemplate(
      id: 'color_rush',
      name: 'Color Rush',
      category: CognitiveCategory.attention,
      description: 'Match colors under time pressure',
      icon: '🌈',
      rules: 'Quickly identify and match colors shown. Your speed and accuracy determine your score.',
    ),
    GameTemplate(
      id: 'focus_finder',
      name: 'Focus Finder',
      category: CognitiveCategory.attention,
      description: 'Locate specific items in cluttered scenes',
      icon: '🔍',
      rules: 'Find target items quickly. Score based on finds and response time.',
    ),

    // SPATIAL GAMES (3)
    GameTemplate(
      id: 'puzzle_race',
      name: 'Puzzle Race',
      category: CognitiveCategory.spatial,
      description: 'Complete jigsaw puzzles against the clock',
      icon: '🧩',
      rules: 'Assemble the puzzle pieces. Score based on completion time and accuracy.',
    ),
    GameTemplate(
      id: 'rotation_master',
      name: 'Rotation Master',
      category: CognitiveCategory.spatial,
      description: 'Identify rotated shapes and objects',
      icon: '🔄',
      rules: 'Match objects with their rotated counterparts. Score based on correct matches and speed.',
    ),
    GameTemplate(
      id: 'path_finder',
      name: 'Path Finder',
      category: CognitiveCategory.spatial,
      description: 'Navigate mazes and find optimal paths',
      icon: '🗺️',
      rules: 'Find the shortest path through the maze. Score based on path efficiency and time.',
    ),

    // LANGUAGE GAMES (3)
    GameTemplate(
      id: 'word_builder',
      name: 'Word Builder',
      category: CognitiveCategory.language,
      description: 'Create words from letter tiles for points',
      icon: '📝',
      rules: 'Form words from available letters. Score based on word length and letter value.',
    ),
    GameTemplate(
      id: 'anagram_attack',
      name: 'Anagram Attack',
      category: CognitiveCategory.language,
      description: 'Solve anagrams quickly',
      icon: '🔤',
      rules: 'Unscramble words as quickly as possible. Score based on speed and accuracy.',
    ),
    GameTemplate(
      id: 'vocabulary_showdown',
      name: 'Vocabulary Showdown',
      category: CognitiveCategory.language,
      description: 'Test vocabulary knowledge in rapid-fire questions',
      icon: '📚',
      rules: 'Answer vocabulary questions correctly. Score based on correct answers and response time.',
    ),
  ];

  /// Get all available games
  static List<GameTemplate> getAllGames() => List.unmodifiable(_games);

  /// Get games by category
  static List<GameTemplate> getGamesByCategory(CognitiveCategory category) {
    return _games.where((game) => game.category == category).toList();
  }

  /// Get game by ID
  static GameTemplate? getGameById(String id) {
    try {
      return _games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get games suitable for player count
  /// All games support any number of players (2-10+)
  static List<GameTemplate> getGamesForPlayerCount(int playerCount) {
    return _games;  // All games support any player count
  }

  /// Get random game for player count
  static GameTemplate? getRandomGame(int playerCount) {
    final suitable = getGamesForPlayerCount(playerCount);
    if (suitable.isEmpty) return null;
    
    final random = DateTime.now().millisecondsSinceEpoch % suitable.length;
    return suitable[random];
  }

  /// Get all categories
  static List<CognitiveCategory> getAllCategories() {
    return CognitiveCategory.values;
  }

  /// Get category info
  static Map<String, String> getCategoryInfo(CognitiveCategory category) {
    const categoryInfo = {
      'memory': {
        'name': 'Memory',
        'icon': '🧠',
        'description': 'Test your recall and recognition abilities',
      },
      'logic': {
        'name': 'Logic',
        'icon': '🧩',
        'description': 'Challenge your reasoning and problem-solving skills',
      },
      'attention': {
        'name': 'Attention',
        'icon': '👁️',
        'description': 'Sharpen your focus and visual processing',
      },
      'spatial': {
        'name': 'Spatial',
        'icon': '🗺️',
        'description': 'Develop your spatial awareness and visualization',
      },
      'language': {
        'name': 'Language',
        'icon': '📚',
        'description': 'Enhance your verbal and linguistic abilities',
      },
    };
    
    return Map<String, String>.from(
      categoryInfo[category.toString().split('.').last]!,
    );
  }

  /// Create game instance from template
  static Game? createGameInstance(
    String templateId,
    String lobbyId,
    List<String> players,
  ) {
    final template = getGameById(templateId);
    if (template == null) return null;

    return Game(
      id: 'game_${DateTime.now().millisecondsSinceEpoch}_${_generateId()}',
      name: template.name,
      category: template.category,
      description: template.description,
      minPlayers: 2,  // Minimum 2 players for multiplayer
      maxPlayers: 10,  // Maximum 10 players per lobby
      currentTurn: 0,
      currentPlayerId: players.first,
      state: _initializeGameState(template.id, players),
      completed: false,
    );
  }

  /// Initialize game-specific state
  static Map<String, dynamic> _initializeGameState(
    String gameId,
    List<String> players,
  ) {
    final scores = <String, int>{};
    for (var player in players) {
      scores[player] = 0;
    }

    return {
      'gameId': gameId,
      'players': players,
      'scores': scores,
      'startTime': DateTime.now().millisecondsSinceEpoch,
      'moves': [],
    };
  }

  /// Generate random ID
  static String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var id = '';
    var num = random;
    
    for (var i = 0; i < 9; i++) {
      id += chars[num % chars.length];
      num = num ~/ chars.length;
    }
    
    return id;
  }
}
