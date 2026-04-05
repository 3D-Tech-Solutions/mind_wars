import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/games/path_finder/path_finder_engine.dart';
import 'package:mind_wars/services/game_generator_service.dart';

void main() {
  group('PathFinderEngine', () {
    test('generates identical challenge sets from the same seed', () {
      final first = PathFinderEngine.generateChallengeSet(
        seed: 'shared-path-seed',
        difficulty: 'hard',
      );
      final second = PathFinderEngine.generateChallengeSet(
        seed: 'shared-path-seed',
        difficulty: 'hard',
      );

      expect(first, equals(second));
      expect(first['canonicalChecksum'], isA<String>());
    });

    test('battle challenge set changes when deterministic index changes', () {
      final first = PathFinderEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 4,
        difficulty: 'medium',
        hintPolicy: 'disabled',
      );
      final second = PathFinderEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 5,
        difficulty: 'medium',
        hintPolicy: 'disabled',
      );

      expect(first, isNot(equals(second)));
    });

    test('challenge payload stores quantized drawable geometry', () {
      final challengeSet = PathFinderEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 7,
        difficulty: 'hard',
        hintPolicy: 'enabled',
      );

      expect(challengeSet['gridWidth'], equals(16));
      expect(challengeSet['gridHeight'], equals(16));
      expect(challengeSet['wallCells'], isNotEmpty);
      expect(challengeSet['cargoCells'], isNotEmpty);
      expect(challengeSet['optimalMoveCount'], greaterThan(0));
      expect(challengeSet['drawable']['walls'], equals(challengeSet['wallCells']));
    });

    test('submission payload includes a canonical replay hash', () {
      final challengeSet = PathFinderEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 2,
        difficulty: 'easy',
        hintPolicy: 'disabled',
      );

      final optimalPath = (challengeSet['optimalPathCells'] as List)
          .map((cell) => Map<String, dynamic>.from((cell as Map).cast<String, dynamic>()))
          .toList();
      final moves = <String>[];
      for (var i = 1; i < optimalPath.length; i++) {
        final previous = optimalPath[i - 1];
        final current = optimalPath[i];
        final dx = (current['x'] as num).toInt() - (previous['x'] as num).toInt();
        final dy = (current['y'] as num).toInt() - (previous['y'] as num).toInt();
        if (dx == 1) {
          moves.add('right');
        } else if (dx == -1) {
          moves.add('left');
        } else if (dy == 1) {
          moves.add('down');
        } else if (dy == -1) {
          moves.add('up');
        }
      }

      final submission = PathFinderEngine.buildSubmissionPayload(
        challengeSet: challengeSet,
        moves: moves,
        totalTimeMs: 32000,
      );

      expect(submission['completed'], isTrue);
      expect(submission['invalidMove'], isFalse);
      expect(submission['submissionHash'], isA<String>());
      expect(submission['challengeChecksum'], equals(challengeSet['canonicalChecksum']));
    });
  });

  group('Path Finder integration', () {
    test('game generator service returns deterministic challenge sets', () {
      final first = GameGeneratorService.generateGameState(
        gameId: 'path_finder',
        gameIndex: 9,
        seed: 'mind-war-seed',
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );
      final second = GameGeneratorService.generateGameState(
        gameId: 'path_finder',
        gameIndex: 9,
        seed: 'mind-war-seed',
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );

      expect(first['challengeSet'], equals(second['challengeSet']));
    });
  });
}
