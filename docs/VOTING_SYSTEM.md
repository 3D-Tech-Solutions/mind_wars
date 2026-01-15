# Game Voting System

## Overview
The game voting system allows players to democratically select which games will be played during a session. Each player receives a configurable number of voting points that they can allocate across available games.

## Features
- **Blind Voting**: Vote totals are hidden during voting to prevent bias (default mode)
- **Search & Filter**: Search games by name or filter by cognitive category
- **Popup-based Allocation**: Tap games to open a dialog for point allocation
- **Random Selection**: "Choose for me" button for automatic random allocation
- **Configurable Points**: The group leader can set how many voting points each player receives
- **Multi-Round Support**: Voting can span multiple rounds, with games selected for each round
- **Flexible Allocation**: Players can distribute their points across multiple games or focus on favorites
- **Real-Time Updates**: All players receive voting updates in real-time via Socket.io
- **Democratic Selection**: The games with the most votes win each round
- **Minimum Game Requirement**: At least 3 games must be available to ensure meaningful voting choices

## How It Works

### 1. Starting a Voting Session
The lobby host/leader starts a voting session by specifying:
- **Points Per Player**: How many voting points each player receives (e.g., 10 points)
- **Total Rounds**: Number of rounds in the match (e.g., 3 rounds)
- **Games Per Round**: Number of games to select per round (e.g., 2 games)
- **Available Games** (optional): Specific games to vote on (minimum 3), or defaults to all games suitable for the player count
- **Blind Voting** (optional): If true (default), vote totals are hidden until voting ends

**Match Structure**: A match consists of X rounds, with each round selecting Y games to play. For example:
- 3 rounds × 2 games per round = 6 total games in the match
- 4 rounds × 3 games per round = 12 total games in the match

**Note**: The system requires at least 3 games to be available for voting. This ensures users have meaningful choices to spend their points based on their game preferences.

```dart
final votingService = VotingService();

final session = votingService.createVotingSession(
  lobbyId: 'lobby123',
  pointsPerPlayer: 10,
  totalRounds: 3,          // 3 rounds in the match
  gamesPerRound: 2,        // 2 games selected per round = 6 total games
  playerIds: ['player1', 'player2', 'player3'],
  availableGames: ['memory_match', 'sudoku_duel', 'word_builder', 'puzzle_race'], // optional, min 3 games
  blindVoting: true,       // optional, defaults to true
);
```

### 2. Casting Votes
Players allocate their points to games they want to play:

```dart
// Player 1 votes for Memory Match with 5 points
votingService.castVote(
  playerId: 'player1',
  gameId: 'memory_match',
  points: 5,
);

// Player 1 votes for Sudoku Duel with 3 points
votingService.castVote(
  playerId: 'player1',
  gameId: 'sudoku_duel',
  points: 3,
);
// Player 1 now has 2 points remaining
```

Players can vote multiple times for the same game to allocate more points:

```dart
// Add 2 more points to Memory Match
votingService.castVote(
  playerId: 'player1',
  gameId: 'memory_match',
  points: 2,
);
// Memory Match now has 7 points from player1
```

### 3. Removing Votes
Players can change their minds and remove votes:

```dart
// Remove 3 points from Memory Match
votingService.removeVote(
  playerId: 'player1',
  gameId: 'memory_match',
  points: 3,
);

// Remove all votes from a game
votingService.removeVote(
  playerId: 'player1',
  gameId: 'sudoku_duel',
);
```

### 4. Random Allocation (New!)
Players can use the "Choose for me" feature to randomly allocate their remaining points:

```dart
// Randomly allocate remaining points across minimum number of games
final allocations = votingService.allocatePointsRandomly('player1');
// Returns: {'memory_match': 4, 'sudoku_duel': 6}
// All remaining points are distributed across gamesPerRound games
// Each game receives at least 1 point
```

This feature is perfect for:
- Players who are undecided or don't have strong preferences
- Quick voting when time is limited
- Exploring new game combinations

### 5. Checking Vote Status
Query the current state of voting:

```dart
// Get remaining points for a player
final remaining = votingService.getRemainingPoints('player1');

// Get a player's current votes
final votes = votingService.getPlayerVotes('player1');
// Returns: {'memory_match': 4, 'sudoku_duel': 3}

// Get current vote totals across all players (only visible if not blind voting)
final results = votingService.getCurrentResults();
// Returns: {'memory_match': 15, 'sudoku_duel': 8, 'word_builder': 7}

// Check if all players have voted
final allVoted = votingService.allPlayersVoted;
```

**Note**: In blind voting mode (default), individual players cannot see total vote counts during voting. They only see their own allocations.

### 6. Ending a Round
Once voting is complete, the host ends the round:

```dart
// End voting and get the winning games
final selectedGames = votingService.endVotingRound();
// Returns: ['memory_match', 'sudoku_duel'] (top N games with most votes)

// The session automatically moves to the next round
// Points are reset for all players
```

### 7. Multi-Round Progression
After each round:
- The top N games (based on gamesPerRound) are added to the selected games list for that round
- The round counter increments
- All votes are cleared
- Points are reset for all players
- Players vote again for the next round

```dart
// After 3 rounds with 2 games per round, 6 games are selected
final selectedGames = votingService.selectedGames;
// Returns flattened list: ['memory_match', 'sudoku_duel', 'word_builder', 'puzzle_race', 'color_rush', 'anagram_attack']

// Get games organized by round
final gamesByRound = votingService.selectedGamesByRound;
// Returns: [
//   ['memory_match', 'sudoku_duel'],      // Round 1
//   ['word_builder', 'puzzle_race'],       // Round 2
//   ['color_rush', 'anagram_attack']       // Round 3
// ]

// Session is marked as completed
final isCompleted = votingService.currentSession!.completed;
// Returns: true

// Total games in match
final totalGames = votingService.currentSession!.totalGames;
// Returns: 6 (3 rounds × 2 games per round)
```

## User Interface Features

The voting screen provides an intuitive interface for players:

### Search & Filter
- **Search Bar**: Type to search games by name or category
- **Category Filters**: Quick filter chips for each cognitive category:
  - 🧠 Memory
  - 🧩 Logic
  - 👁️ Attention
  - 🗺️ Spatial
  - 📚 Language

### Voting Interface
- **Game Cards**: 
  - Tap any game card to open the vote allocation dialog
  - Cards show game icon, name, and category
  - Highlighted border when you've allocated points
- **Vote Allocation Dialog**:
  - Shows game name and current point allocation
  - +/- buttons to adjust points
  - Displays available points
  - "Remove All" button to clear votes for that game
  - "Confirm" to apply changes

### Points Display
- Large display of remaining points
- Progress bar showing allocation status
- Total allocated / total available
- Blind voting indicator (🔒) when enabled

### Quick Actions
- **"Choose for me"**: Randomly allocates remaining points
- **"Confirm Votes"**: Submits all votes to the server
- Disabled states when no points allocated or submission in progress

### Visual Feedback
- Real-time point updates as you allocate
- Success/error messages via snackbar
- Loading indicators during submission
- "All Votes In" dialog when all players have voted

## Multiplayer Integration

The voting system integrates with the multiplayer service for real-time collaboration:

```dart
final multiplayerService = MultiplayerService();

// Host starts voting session
await multiplayerService.startVotingSession(
  pointsPerPlayer: 10,
  totalRounds: 3,
  gamesPerRound: 2,
  availableGames: ['game1', 'game2', 'game3', 'game4'],
);

// Players cast votes
await multiplayerService.voteForGame(
  gameId: 'game1',
  points: 5,
);

// Players remove votes
await multiplayerService.removeGameVote(
  gameId: 'game1',
  points: 2,
);

// Host ends voting round
final selectedGames = await multiplayerService.endVotingRound();
// Returns list of selected games for the round: ['game1', 'game2']
```

### Socket.io Events

**Client → Server:**
- `start-voting` - Host starts a voting session
- `vote-game` - Player casts a vote
- `remove-vote` - Player removes a vote
- `end-voting` - Host ends the current voting round

**Server → Client:**
- `voting-started` - Voting session has begun
- `vote-cast` - A player cast a vote (real-time update)
- `voting-update` - Vote totals updated
- `voting-ended` - Voting round completed, game selected

### Listening to Events

```dart
// Listen for voting events
multiplayerService.on('voting-started', (data) {
  print('Voting started: ${data['votingSession']}');
});

multiplayerService.on('vote-cast', (data) {
  print('Player ${data['playerId']} voted for ${data['gameId']}');
});

multiplayerService.on('voting-update', (data) {
  print('Current results: ${data['results']}');
});

multiplayerService.on('voting-ended', (data) {
  print('Games selected: ${data['selectedGames']}');
});
```

## Example User Flow

1. **Setup Phase**
   - Lobby host creates a voting session with 10 points per player for 3 rounds, 2 games per round
   - Total games in match: 6 (3 rounds × 2 games)
   - Available games: Memory Match, Sudoku Duel, Word Builder, Puzzle Race
   - Blind voting enabled (default)

2. **Round 1 - Voting (Blind)**
   - Player 1 uses search to find "Memory", allocates 6 points via popup, then searches "Sudoku" and allocates 4 points
   - Player 2 uses category filter (🧠 Memory), taps Memory Match, allocates 8 points, then finds Word Builder and allocates 2 points
   - Player 3 clicks "Choose for me" button - randomly allocates 5 points to Sudoku Duel, 5 points to Word Builder
   - **Note**: During voting, players only see their own allocations, not others' votes
   - **Result**: After host ends voting → Memory Match (14 points), Sudoku Duel (9 points)

3. **Round 2 - Voting (Blind)**
   - Player 1: Searches "Word", allocates 7 points → Word Builder, then 3 points → Puzzle Race
   - Player 2: Filters by 📚 Language category, allocates 6 points → Word Builder, then 4 points → Puzzle Race
   - Player 3: Uses "Choose for me" → 10 points randomly allocated to Puzzle Race
   - **Result**: Top 2 games selected → Puzzle Race (17 points), Word Builder (13 points)

4. **Round 3 - Voting (Blind)**
   - Player 1: Taps Memory Match, allocates 5 points, taps Sudoku Duel, allocates 5 points
   - Player 2: Opens Memory Match popup, sets to 7 points, opens Sudoku popup, sets to 3 points
   - Player 3: Allocates 4 points → Memory Match, then clicks "Choose for me" (6 points left) → 6 points randomly to Puzzle Race
   - **Result**: Top 2 games selected → Memory Match (16 points), Sudoku Duel (14 points)

5. **Game Session**
   - **Round 1**: Memory Match, Sudoku Duel
   - **Round 2**: Puzzle Race, Word Builder
   - **Round 3**: Memory Match, Sudoku Duel
   - Total: 6 games across 3 rounds
   - Session complete!

## Best Practices

1. **Blind Voting Benefits**
   - Prevents bandwagon effect (voting for popular choices)
   - Ensures authentic preferences
   - Creates suspense and excitement
   - Recommended for competitive or fair selection

2. **Point Allocation**
   - Give enough points to allow meaningful distribution (10-20 points recommended)
   - More points = more granular voting options

3. **Games Per Round**
   - Consider session length: 2-3 games per round works well
   - More games per round = longer play sessions but more variety

3. **Round Count**
   - Match round count to desired session length
   - 3-5 rounds works well for most play sessions
   - Total match length = rounds × games per round

4. **Game Selection**
   - Limit available games to those suitable for your player count
   - Consider player preferences and skill levels
   - Ensure at least 3 games (minimum requirement)
   - Ideally, have more games available than gamesPerRound to allow for variety

5. **Time Management**
   - Set reasonable voting time limits on the server side
   - Auto-end voting after timeout or when all players have used their points

5. **Tie Breaking**
   - In case of ties, consider: random selection, host choice, or additional tie-breaker round
   - Current implementation: first game with max votes wins (deterministic)

## Error Handling

The voting service includes comprehensive error handling:

```dart
try {
  votingService.castVote(
    playerId: 'player1',
    gameId: 'invalid_game',
    points: 5,
  );
} catch (e) {
  print('Error: $e');
  // Error: Game not available for voting
}
```

Common errors:
- `No active voting session` - Voting hasn't started
- `Voting is closed` - Round has ended
- `Not enough points` - Trying to vote with more points than available
- `Game not available for voting` - Invalid game ID
- `Player not in voting session` - Player not part of the lobby

## Testing

The voting system includes comprehensive tests covering:
- Session creation and validation
- Vote casting and removal
- Round progression
- Multi-round scenarios
- Edge cases and error conditions
- Model serialization
- Blind voting functionality
- Random allocation algorithm

Run tests:
```bash
flutter test test/voting_service_test.dart
```

## Recently Added Features

### ✅ Blind Voting (v1.1)
- Hide vote totals during voting to prevent bias
- Optional parameter (defaults to true)
- Visual indicator in UI

### ✅ Search & Filter (v1.1)
- Search games by name or cognitive category
- Category filter chips for quick filtering
- Real-time filtering as user types

### ✅ Popup-based Voting (v1.1)
- Tap games to open allocation dialog
- Direct point input with +/- controls
- Shows available points
- "Remove All" option

### ✅ Random Allocation (v1.1)
- "Choose for me" button for quick voting
- Distributes points across minimum required games
- Ensures at least 1 point per game

## Future Enhancements

Potential improvements to the voting system:
- **Ranked Choice Voting**: Players rank games instead of allocating points
- **Weighted Voting**: Host/veteran players get more voting power
- **Veto System**: Allow vetoing of games with super-majority
- **Vote History**: Track voting patterns and preferences
- **Smart Recommendations**: Suggest games based on past voting behavior
