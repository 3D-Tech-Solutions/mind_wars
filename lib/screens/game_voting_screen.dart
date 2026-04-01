/**
 * Game Voting Screen - Feature 3.2.2
 * Allows players to vote on games using a point allocation system
 * with blind voting, search/filter, and random allocation support
 *
 * Integrated with vote-to-skip feature for Selection Phase
 */

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../games/game_catalog.dart';
import '../services/voting_service.dart';
import '../services/multiplayer_service.dart';
import '../widgets/vote_to_skip_widgets.dart';
import '../utils/brand_animations.dart';

class GameVotingScreen extends StatefulWidget {
  final String lobbyId;
  final String playerId;
  final VotingService votingService;
  final MultiplayerService multiplayerService;

  const GameVotingScreen({
    Key? key,
    required this.lobbyId,
    required this.playerId,
    required this.votingService,
    required this.multiplayerService,
  }) : super(key: key);

  @override
  State<GameVotingScreen> createState() => _GameVotingScreenState();
}

class _GameVotingScreenState extends State<GameVotingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, int> _localVotes = {};
  bool _isSubmitting = false;
  String _searchQuery = '';
  CognitiveCategory? _filterCategory;
  final TextEditingController _searchController = TextEditingController();

  // Vote-to-skip state
  VoteToSkipSession? _activeSkipSession;
  final Map<String, DateTime> _playerLastVoteTime = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadExistingVotes();
    _setupVotingListeners();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadExistingVotes() {
    final votes = widget.votingService.getPlayerVotes(widget.playerId);
    setState(() {
      _localVotes = Map.from(votes);
    });
  }

  void _setupVotingListeners() {
    // Listen for voting updates from Socket.io (Feature 3.2.3)
    widget.multiplayerService.onVotingUpdate((data) {
      if (mounted && data['lobbyId'] == widget.lobbyId) {
        setState(() {
          // Refresh voting session state
          // Track when players vote
          if (data['playerId'] != null) {
            _playerLastVoteTime[data['playerId']] = DateTime.now();
          }
        });
      }
    });

    // Listen for skip vote initiated
    widget.multiplayerService.onSkipVoteInitiated((data) {
      if (mounted && data['lobbyId'] == widget.lobbyId) {
        setState(() {
          _activeSkipSession = VoteToSkipSession.fromJson(data['session']);
        });
        _showSkipVoteDialog();
      }
    });

    // Listen for skip vote updates
    widget.multiplayerService.onSkipVoteUpdated((data) {
      if (mounted && data['lobbyId'] == widget.lobbyId) {
        setState(() {
          if (data['session'] != null) {
            _activeSkipSession = VoteToSkipSession.fromJson(data['session']);
          }
        });
      }
    });

    // Listen for skip vote executed
    widget.multiplayerService.onSkipVoteExecuted((data) {
      if (mounted && data['lobbyId'] == widget.lobbyId) {
        setState(() {
          _activeSkipSession = null;
        });
        _showSkipExecutedNotification(data['playerNameSkipped'] ?? 'Player');
      }
    });

    // Listen for time-based skip executed
    widget.multiplayerService.onTimeSkipExecuted((data) {
      if (mounted && data['lobbyId'] == widget.lobbyId) {
        _showSkipExecutedNotification(
          data['playerNameSkipped'] ?? 'Player',
          isTimeBased: true,
        );
      }
    });
  }

  VotingSession? get _session => widget.votingService.currentSession;

  int get _remainingPoints =>
      widget.votingService.getRemainingPoints(widget.playerId);

  int _getTotalAllocatedPoints() {
    return _localVotes.values.fold(0, (sum, points) => sum + points);
  }

  List<GameTemplate> _getFilteredGames() {
    final availableGames = _session!.availableGames
        .map((id) => GameCatalog.getGameById(id))
        .where((game) => game != null)
        .cast<GameTemplate>()
        .toList();

    var filtered = availableGames;

    // Apply category filter
    if (_filterCategory != null) {
      filtered = filtered
          .where((game) => game.category == _filterCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((game) {
        return game.name.toLowerCase().contains(query) ||
            game.category.toString().toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  // ========== Vote-to-Skip Methods ==========

  void _showSkipVoteDialog() {
    if (_activeSkipSession == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return VoteToSkipDialog(
            session: _activeSkipSession!,
            currentUserId: widget.playerId,
            onVoteToSkip: (sessionId) async {
              try {
                await widget.multiplayerService.castSkipVote(sessionId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vote cast successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error casting vote: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onCancelVote: (sessionId) async {
              try {
                await widget.multiplayerService.cancelSkipVote(sessionId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vote cancelled'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cancelling vote: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            onDismiss: () {
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  Future<void> _initiateSkipVote(String playerIdToSkip, String playerNameToSkip) async {
    try {
      final session = await widget.multiplayerService.initiateSkipVote(
        lobbyId: widget.lobbyId,
        battleNumber: _session?.currentRound ?? 1,
        playerIdToSkip: playerIdToSkip,
      );

      setState(() {
        _activeSkipSession = session;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Skip vote initiated for $playerNameToSkip'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initiating skip vote: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSkipExecutedNotification(String playerName, {bool isTimeBased = false}) {
    if (!mounted) return;

    final message = isTimeBased
        ? '$playerName was auto-skipped (time limit reached)'
        : '$playerName was skipped by vote';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Get AFK player info (player who hasn't voted for configurable hours)
  /// Returns null if no AFK player detected or skip already active
  Map<String, String>? _getAfkPlayerToSkip() {
    // Don't show button if skip session already active
    if (_activeSkipSession != null) return null;

    // Get current lobby from multiplayer service
    final lobby = widget.multiplayerService.currentLobby;
    if (lobby == null) return null;

    // Get lobby skip time configuration (hours of inactivity before AFK)
    final skipTimeLimitHours = lobby.skipTimeLimitHours ?? 24;
    final now = DateTime.now();

    // Check each player in the lobby
    for (final player in lobby.players) {
      // Skip self (can't initiate skip for yourself)
      if (player.id == widget.playerId) continue;

      // Check if player has any votes in current session
      final playerVotes = widget.votingService.getPlayerVotes(player.id);
      final hasVoted = playerVotes.isNotEmpty;

      // If player hasn't voted at all, they're AFK
      if (!hasVoted) {
        // Check if voting session has been active long enough
        final votingStartTime = _session?.createdAt;
        if (votingStartTime != null) {
          final hoursSinceVotingStarted = now.difference(votingStartTime).inHours;

          // Only show skip button if voting has been open for configured time
          if (hoursSinceVotingStarted >= skipTimeLimitHours) {
            return {
              'id': player.id,
              'name': player.displayName ?? 'Player',
            };
          }
        }
      } else {
        // Player has voted - check last vote time
        final lastVoteTime = _playerLastVoteTime[player.id];
        if (lastVoteTime != null) {
          final hoursSinceLastVote = now.difference(lastVoteTime).inHours;

          // If player hasn't updated votes in configured time, they might be AFK
          // (This handles cases where player voted but left before finalizing)
          if (hoursSinceLastVote >= skipTimeLimitHours) {
            return {
              'id': player.id,
              'name': player.displayName ?? 'Player',
            };
          }
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vote for Games'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text('No active voting session'),
        ),
      );
    }

    final afkPlayer = _getAfkPlayerToSkip();

    return Scaffold(
      appBar: AppBar(
        title: Text('Vote for Games - Round ${_session!.currentRound}'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Voting header with points info
          _buildVotingHeader(),
          // Search and filter bar
          _buildSearchAndFilter(),
          // Games list
          Expanded(
            child: _buildGamesList(),
          ),
          // Bottom action buttons
          _buildBottomActions(),
        ],
      ),
      // Vote-to-skip FAB (shown when AFK player detected)
      floatingActionButton: afkPlayer != null
          ? VoteToSkipButton(
              playerNameToSkip: afkPlayer['name']!,
              enabled: true,
              onPressed: () {
                _initiateSkipVote(afkPlayer['id']!, afkPlayer['name']!);
              },
            )
          : null,
    );
  }

  Widget _buildVotingHeader() {
    final totalPoints = _session!.pointsPerPlayer;
    final usedPoints = _getTotalAllocatedPoints();
    final remaining = totalPoints - usedPoints;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Points display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Points',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$remaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Allocated',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$usedPoints / $totalPoints',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usedPoints / totalPoints,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                usedPoints == totalPoints ? Colors.greenAccent : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Round info
          Text(
            'Round ${_session!.currentRound} of ${_session!.totalRounds} • Select ${_session!.gamesPerRound} game${_session!.gamesPerRound > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (_session!.blindVoting)
            const SizedBox(height: 4),
          if (_session!.blindVoting)
            const Text(
              '🔒 Blind Voting - Votes are hidden',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search games by name or type...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('🧠 Memory', CognitiveCategory.memory),
                const SizedBox(width: 8),
                _buildFilterChip('🧩 Logic', CognitiveCategory.logic),
                const SizedBox(width: 8),
                _buildFilterChip('👁️ Attention', CognitiveCategory.attention),
                const SizedBox(width: 8),
                _buildFilterChip('🗺️ Spatial', CognitiveCategory.spatial),
                const SizedBox(width: 8),
                _buildFilterChip('📚 Language', CognitiveCategory.language),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CognitiveCategory? category) {
    final isSelected = _filterCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterCategory = selected ? category : null;
        });
      },
      selectedColor: Colors.deepPurple.shade100,
      checkmarkColor: Colors.deepPurple,
    );
  }

  Widget _buildGamesList() {
    final filteredGames = _getFilteredGames();

    if (filteredGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No games found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        return _buildGameCard(game);
      },
    );
  }

  Widget _buildGameCard(GameTemplate game) {
    final categoryInfo = GameCatalog.getCategoryInfo(game.category);
    final currentVotes = _localVotes[game.id] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: currentVotes > 0
            ? BorderSide(color: Colors.deepPurple, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showVoteAllocationDialog(game),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Game icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCategoryColor(game.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    game.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Game info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          categoryInfo['icon']!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          categoryInfo['name']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Current votes indicator
              if (currentVotes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$currentVotes pts',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.add_circle_outline,
                  color: Colors.grey,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoteAllocationDialog(GameTemplate game) {
    final currentVotes = _localVotes[game.id] ?? 0;
    int selectedPoints = currentVotes > 0 ? currentVotes : 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              game.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How many points do you want to allocate?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selectedPoints > 0
                          ? () {
                              setDialogState(() {
                                selectedPoints = (selectedPoints - 1).clamp(0, 999);
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle),
                      iconSize: 40,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$selectedPoints',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedPoints = (selectedPoints + 1).clamp(0, 999);
                        });
                      },
                      icon: const Icon(Icons.add_circle),
                      iconSize: 40,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Available: $_remainingPoints points',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            actions: [
              if (currentVotes > 0)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateVotes(game.id, 0);
                  },
                  child: const Text(
                    'Remove All',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedPoints <= _remainingPoints + currentVotes
                    ? () {
                        Navigator.pop(context);
                        _updateVotes(game.id, selectedPoints);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _updateVotes(String gameId, int newPoints) {
    setState(() {
      if (newPoints == 0) {
        _localVotes.remove(gameId);
      } else {
        _localVotes[gameId] = newPoints;
      }
    });
    _animationController.forward(from: 0);
  }

  Widget _buildBottomActions() {
    final canSubmit = _getTotalAllocatedPoints() > 0 && !_isSubmitting;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Choose for me button
            if (_remainingPoints > 0)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _allocateRandomly,
                  icon: const Icon(Icons.casino),
                  label: const Text('Choose for me'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_remainingPoints > 0)
              const SizedBox(height: 12),
            // Submit button
            if (_getTotalAllocatedPoints() == 0)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Allocate at least 1 point to continue',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSubmit ? _submitVotes : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? BrandAnimations.loadingSpinner(size: 24)
                    : Text(
                        widget.votingService.allPlayersVoted
                            ? 'Waiting for Others...'
                            : 'Confirm Votes',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _allocateRandomly() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final allocations = widget.votingService.allocatePointsRandomly(widget.playerId);
      
      setState(() {
        // Merge random allocations with existing votes
        for (var entry in allocations.entries) {
          _localVotes[entry.key] = (_localVotes[entry.key] ?? 0) + entry.value;
        }
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Randomly allocated ${allocations.length} game(s)!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitVotes() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate vote changes and submit to server
      final currentServerVotes = widget.votingService.getPlayerVotes(widget.playerId);
      
      // Remove votes that were decreased
      for (var gameId in currentServerVotes.keys) {
        final currentPoints = currentServerVotes[gameId]!;
        final newPoints = _localVotes[gameId] ?? 0;
        if (newPoints < currentPoints) {
          widget.votingService.removeVote(
            playerId: widget.playerId,
            gameId: gameId,
            points: currentPoints - newPoints,
          );
        }
      }
      
      // Add new votes or increased votes
      for (var entry in _localVotes.entries) {
        final currentPoints = currentServerVotes[entry.key] ?? 0;
        if (entry.value > currentPoints) {
          widget.votingService.castVote(
            playerId: widget.playerId,
            gameId: entry.key,
            points: entry.value - currentPoints,
          );
        }
      }

      // Emit voting update via Socket.io (Feature 3.2.3)
      widget.multiplayerService.emitVoteUpdate(
        widget.lobbyId,
        widget.playerId,
        _localVotes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votes submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Check if all players have voted
        if (widget.votingService.allPlayersVoted) {
          _showAllVotedDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting votes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showAllVotedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('All Votes In!'),
        content: const Text(
          'All players have voted. The host can now end voting and start the games.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(CognitiveCategory category) {
    switch (category) {
      case CognitiveCategory.memory:
        return Colors.blue.shade300;
      case CognitiveCategory.logic:
        return Colors.purple.shade300;
      case CognitiveCategory.attention:
        return Colors.orange.shade300;
      case CognitiveCategory.spatial:
        return Colors.green.shade300;
      case CognitiveCategory.language:
        return Colors.pink.shade300;
    }
  }
}
