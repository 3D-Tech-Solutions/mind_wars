import 'dart:math';

import 'package:flutter/material.dart';

import '../rotation_master/rotation_master_engine.dart';
import 'base_game_widget.dart';

class RotationMasterGame extends BaseGameWidget {
  const RotationMasterGame({
    Key? key,
    required OnGameComplete onGameComplete,
    required OnScoreUpdate onScoreUpdate,
    this.seed = 'offline_rotation_master_practice_v1',
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
  State<RotationMasterGame> createState() => _RotationMasterGameState();
}

class _RotationMasterGameState extends BaseGameState<RotationMasterGame> {
  late final Map<String, dynamic> _challengeSet;
  late final List<Map<String, dynamic>> _prompts;
  int _promptIndex = 0;
  int _streak = 0;
  final Set<int> _selectedIndices = <int>{};
  final List<Map<String, dynamic>> _responses = <Map<String, dynamic>>[];
  late final DateTime _gameStartedAt;
  late DateTime _promptStartedAt;

  Map<String, dynamic> get _prompt => _prompts[_promptIndex];
  int get _correctOptionIndex => _prompt['correctOptionIndex'] as int;

  @override
  void initState() {
    super.initState();
    _challengeSet = widget.challengeSet ??
        RotationMasterEngine.generateChallengeSet(
          seed: widget.seed,
          difficulty: widget.difficulty,
          promptCount: 6,
        );
    _prompts = (_challengeSet['prompts'] as List)
        .map((prompt) => Map<String, dynamic>.from(prompt as Map))
        .toList();
    _gameStartedAt = DateTime.now();
    _promptStartedAt = _gameStartedAt;
  }

  void _onOptionTapped(int index) {
    _selectedIndices
      ..clear()
      ..add(index);
    _submitAnswer();
  }

  void _submitAnswer() {
    if (_selectedIndices.isEmpty) {
      return;
    }

    final selectedOptionIndex = _selectedIndices.first;
    final isCorrect = selectedOptionIndex == _correctOptionIndex;
    final responseTimeMs = DateTime.now().difference(_promptStartedAt).inMilliseconds;
    final promptChecksum = _prompt['canonicalChecksum'] as String;

    if (isCorrect) {
      _streak++;
      final points = 12 + (_streak * 3) + (_prompt['dimension'] as int);
      addScore(points);
      showMessage('Correct! +$points points', success: true);
    } else {
      _streak = 0;
      showMessage('Not quite. That set included a mirrored distractor.');
    }

    _responses.add({
      'roundIndex': _promptIndex,
      'promptChecksum': promptChecksum,
      'selectedOptionIndex': selectedOptionIndex,
      'correctOptionIndex': _correctOptionIndex,
      'isCorrect': isCorrect,
      'responseTimeMs': responseTimeMs,
    });

    if (_promptIndex >= _prompts.length - 1) {
      final totalTimeMs = DateTime.now().difference(_gameStartedAt).inMilliseconds;
      final submission = RotationMasterEngine.buildSubmissionPayload(
        challengeSet: _challengeSet,
        responses: _responses,
        totalTimeMs: totalTimeMs,
        score: score,
      );
      widget.onSubmissionReady?.call(submission);
      completeGame();
      return;
    }

    setState(() {
      _promptIndex++;
      _selectedIndices.clear();
      _promptStartedAt = DateTime.now();
    });
  }

  @override
  Widget buildGame(BuildContext context) {
    final options = (_prompt['options'] as List).cast<Map<String, dynamic>>();
    final colorScheme = Theme.of(context).colorScheme;
    final progress = '${_promptIndex + 1}/${_prompts.length}';

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
                  _HeaderStat(label: 'Round', value: progress),
                  _HeaderStat(label: 'Streak', value: '$_streak'),
                  _HeaderStat(
                    label: 'Shape',
                    value: '${_prompt['dimension']}D',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the one option that is the same shape in a new orientation',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_prompt['family']}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _ShapePanel(
                      segments: (_prompt['target']['segments'] as List)
                          .map((segment) => (segment as List).cast<int>())
                          .toList(),
                      viewBox: Map<String, int>.from(
                        (_prompt['target']['viewBox'] as Map).cast<String, int>(),
                      ),
                      strokeColor: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 4,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = _selectedIndices.contains(index);
                return GestureDetector(
                  onTap: () => _onOptionTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: isSelected ? 3 : 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _ShapePanel(
                            segments: (option['segments'] as List)
                                .map((segment) => (segment as List).cast<int>())
                                .toList(),
                            viewBox: Map<String, int>.from(
                              (option['viewBox'] as Map).cast<String, int>(),
                            ),
                            strokeColor: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSecondaryContainer,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: isSelected
                                ? colorScheme.primary
                                : colorScheme.surface,
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _ShapePanel extends StatelessWidget {
  const _ShapePanel({
    required this.segments,
    required this.viewBox,
    required this.strokeColor,
  });

  final List<List<int>> segments;
  final Map<String, int> viewBox;
  final Color strokeColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapePainter(
        segments: segments,
        viewBox: viewBox,
        strokeColor: strokeColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ShapePainter extends CustomPainter {
  const _ShapePainter({
    required this.segments,
    required this.viewBox,
    required this.strokeColor,
  });

  final List<List<int>> segments;
  final Map<String, int> viewBox;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final width = max(1, viewBox['width'] ?? 1).toDouble();
    final height = max(1, viewBox['height'] ?? 1).toDouble();
    final scale = min(size.width / width, size.height / height) * 0.82;
    final offsetX = (size.width - (width * scale)) / 2;
    final offsetY = (size.height - (height * scale)) / 2;

    for (final segment in segments) {
      final start = Offset(
        offsetX + (segment[0] * scale),
        offsetY + (segment[1] * scale),
      );
      final end = Offset(
        offsetX + (segment[2] * scale),
        offsetY + (segment[3] * scale),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.viewBox != viewBox ||
        oldDelegate.strokeColor != strokeColor;
  }
}
