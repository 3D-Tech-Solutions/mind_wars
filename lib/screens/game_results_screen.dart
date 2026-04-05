import 'package:flutter/material.dart';

class GameResultsScreen extends StatelessWidget {
  final Map<String, dynamic>? results;

  const GameResultsScreen({
    Key? key,
    this.results,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In Phase 2, we'll have full results. For now, placeholder.
    final resultsData = results ?? {};
    final winnerId = resultsData['winnerId'] as String?;
    final winnerName = resultsData['winnerName'] as String?;
    final scores = resultsData['playerScores'] as Map<String, int>? ?? {};
    final ranked = resultsData['ranked'] as bool? ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  if (winnerName != null)
                    Column(
                      children: [
                        const Text(
                          'Game Complete!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$winnerName Wins!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        Text(
                          'Game Complete!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Score breakdown
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Final Scores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (scores.isNotEmpty)
                        ...scores.entries.map((entry) {
                          final isWinner = winnerId == entry.key;
                          return Card(
                            color: isWinner
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key.substring(0, 8),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (isWinner)
                                        const Chip(
                                          label: Text('Winner'),
                                          backgroundColor: Colors.blue,
                                        ),
                                    ],
                                  ),
                                  Text(
                                    '${entry.value}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList()
                      else
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No score data available'),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (ranked)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                SizedBox(width: 8),
                                Text('Ranked Match - Scores recorded'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst || route.settings.name == '/lobby',
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
