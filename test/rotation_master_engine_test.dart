import 'package:flutter_test/flutter_test.dart';
import 'package:mind_wars/games/rotation_master/rotation_master_engine.dart';
import 'package:mind_wars/services/game_content_generator.dart';
import 'package:mind_wars/services/game_generator_service.dart';

void main() {
  group('RotationMasterEngine', () {
    test('generates identical prompt sets from the same seed', () {
      final a = RotationMasterEngine.generateChallengeSet(
        seed: 'shared-seed',
        difficulty: 'hard',
      );
      final b = RotationMasterEngine.generateChallengeSet(
        seed: 'shared-seed',
        difficulty: 'hard',
      );

      expect(a, equals(b));
    });

    test('generates different prompt sets from different seeds', () {
      final a = RotationMasterEngine.generateChallengeSet(
        seed: 'seed-a',
        difficulty: 'medium',
      );
      final b = RotationMasterEngine.generateChallengeSet(
        seed: 'seed-b',
        difficulty: 'medium',
      );

      expect(a, isNot(equals(b)));
    });

    test('medium and hard prompts expose mirrored distractors', () {
      final medium = RotationMasterEngine.generatePrompt(
        seed: 'medium-seed',
        difficulty: 'medium',
        roundIndex: 0,
      );
      final hard = RotationMasterEngine.generatePrompt(
        seed: 'hard-seed',
        difficulty: 'hard',
        roundIndex: 1,
      );

      expect(medium['mode'], equals('single_choice'));
      expect(hard['mode'], equals('single_choice'));
      expect(medium['correctIndices'], hasLength(1));
      expect(hard['correctIndices'], hasLength(1));

      final mediumOptions =
          (medium['options'] as List).cast<Map<String, dynamic>>();
      final hardOptions = (hard['options'] as List).cast<Map<String, dynamic>>();

      expect(
        mediumOptions.where((option) => option['kind'] == 'mirror').length,
        equals(3),
      );
      expect(
        hardOptions.where((option) => option['kind'] == 'mirror').length,
        equals(3),
      );
    });

    test('hard prompt emits discrete geometry and checksum', () {
      final prompt = RotationMasterEngine.generatePrompt(
        seed: 'force-4d-seed',
        difficulty: 'hard',
        roundIndex: 1,
      );

      expect(prompt['dimension'], anyOf(equals(3), equals(4)));
      expect((prompt['target']['segments'] as List), isNotEmpty);
      expect(prompt['shapeIndex'], isA<int>());
      expect(prompt['targetRotationSteps'], isNotEmpty);
      expect(prompt['answerOrder'], hasLength(4));
      expect(prompt['canonicalChecksum'], isA<String>());
    });

    test('battle challenge set is stable for same seed and index', () {
      final first = RotationMasterEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 4,
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );
      final second = RotationMasterEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 4,
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );

      expect(first, equals(second));
      expect(first['challengeKey'], contains('index:4'));
    });

    test('battle challenge set changes when deterministic index changes', () {
      final first = RotationMasterEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 4,
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );
      final second = RotationMasterEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 5,
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );

      expect(first, isNot(equals(second)));
    });
  });

  group('Rotation Master integration', () {
    test('content generator stores prompt payload rather than rotation count', () {
      final generator = GameContentGenerator();
      final puzzle = generator.generatePuzzle(
        gameType: 'rotation_master',
        difficulty: Difficulty.medium,
      );

      expect(puzzle.data['prompts'], isNotNull);
      expect(puzzle.data.containsKey('rotationCount'), isFalse);
      expect(puzzle.solution['correctIndicesByPrompt'], isNotEmpty);
    });

    test('game generator service returns deterministic challenge sets', () {
      final first = GameGeneratorService.generateGameState(
        gameId: 'rotation_master',
        gameIndex: 2,
        seed: 'mind-war-seed',
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );
      final second = GameGeneratorService.generateGameState(
        gameId: 'rotation_master',
        gameIndex: 2,
        seed: 'mind-war-seed',
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );

      expect(first['challengeSet'], equals(second['challengeSet']));
    });

    test('game generator service uses incoming seed as part of battle identity', () {
      final first = GameGeneratorService.generateGameState(
        gameId: 'rotation_master',
        gameIndex: 2,
        seed: 'mind-war-seed-a',
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );
      final second = GameGeneratorService.generateGameState(
        gameId: 'rotation_master',
        gameIndex: 2,
        seed: 'mind-war-seed-b',
        difficulty: 'hard',
        hintPolicy: 'disabled',
      );

      expect(first['challengeSet'], isNot(equals(second['challengeSet'])));
    });

    test('submission payload includes canonical hash', () {
      final challengeSet = RotationMasterEngine.generateBattleChallengeSet(
        battleSeed: 'mind-war-seed',
        gameIndex: 2,
        difficulty: 'medium',
        hintPolicy: 'disabled',
      );

      final submission = RotationMasterEngine.buildSubmissionPayload(
        challengeSet: challengeSet,
        responses: const [
          {
            'roundIndex': 0,
            'promptChecksum': 'abc',
            'selectedOptionIndex': 1,
            'correctOptionIndex': 1,
            'isCorrect': true,
            'responseTimeMs': 1500,
          },
        ],
        totalTimeMs: 1500,
        score: 17,
      );

      expect(submission['submissionHash'], isA<String>());
      expect(submission['challengeChecksum'], equals(challengeSet['canonicalChecksum']));
    });
  });
}
