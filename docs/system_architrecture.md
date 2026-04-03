---
name: Complete Mind Wars System Architecture
description: End-to-end user journeys, screen flows, data models, and backend architecture
type: project
---

# Mind Wars: Complete System Architecture

## Table of Contents
1. [User Onboarding & Authentication](#1-user-onboarding--authentication)
2. [Home Dashboard & Social Hub](#2-home-dashboard--social-hub)
3. [Mind War Creation & Setup](#3-mind-war-creation--setup)
4. [Mind War Administration & Lobby](#4-mind-war-administration--lobby)
5. [Game Selection & Difficulty](#5-game-selection--difficulty)
6. [Gameplay & Round Progression](#6-gameplay--round-progression)
7. [Results & Scoring](#7-results--scoring)
8. [Leaderboards & Rankings](#8-leaderboards--rankings)
9. [Social Features](#9-social-features)
10. [Data Models & Backend](#10-data-models--backend)
11. [Implementation Priority](#11-implementation-priority)

---

## 1. User Onboarding & Authentication

### 1.1 Authentication Modes

**ALPHA MODE** (Local Development):
- No backend dependency
- SQLite-based auth in `LocalAuthService`
- Instant login/register for testing
- Data stays on device
- Toggled by `FLAVOR=alpha` env var

**PRODUCTION MODE** (Live):
- JWT-based backend auth
- Backend: `war.e-mothership.com:3000/api`
- Email validation, password policy
- Token refresh system (15m access, 7d refresh)
- User registration with display name

### 1.2 Auth Endpoints (Backend)

```
POST /api/auth/register
  Body: { email, password, displayName }
  Return: { accessToken, refreshToken, user }

POST /api/auth/login
  Body: { email, password }
  Return: { accessToken, refreshToken, user }

POST /api/auth/refresh
  Body: { refreshToken }
  Return: { accessToken }

POST /api/auth/logout
  Body: { refreshToken }
  Return: { success }

GET /api/auth/me
  Headers: { Authorization: "Bearer {token}" }
  Return: { user }
```

### 1.3 Auth Screen Flow

```
SplashScreen (auto-detect auth state)
    ↓
    ├─ [Logged In] → HomeScreen
    └─ [Not Logged In]
        ↓
        LoginScreen / RegistrationScreen
            ↓
        OnboardingScreen (first-time users)
            ↓
        ProfileSetupScreen (customize name, avatar)
            ↓
        HomeScreen
```

### 1.4 Registration & Password Policy

**Requirements:**
- Email: Valid format, unique in database
- Password: Min 8 chars, 1 uppercase, 1 lowercase, 1 digit
- Display Name: 2-50 characters, alphanumeric + spaces

**Validation:**
- Frontend: Real-time validation feedback
- Backend: Re-validate all inputs (never trust client)
- Database: Email unique constraint prevents duplicates

---

## 2. Home Dashboard & Social Hub

### 2.1 HomeScreen (After Auth)

**Top Section:**
```
┌─────────────────────────────┐
│ Welcome, [Username]!        │  ← Personalized greeting
│ Level 5 • 2,450 points      │  ← User stats summary
│ 12-game win streak 🔥       │  ← Current achievements
└─────────────────────────────┘
```

**Main Actions (Grid):**
```
┌──────────────────────────────────┐
│ [🎮 Play Solo]  [⚔️  Mind War]   │  ← Primary CTAs
│ [👥 Browse Wars] [🏆 Rankings]  │
└──────────────────────────────────┘
```

**Content Sections:**
```
Recent Activity:
  - "You won 'Memory Match' vs 3 players"
  - "Challenge from Alice: Accept/Decline"
  - "Round 2 Results: You're in 2nd place"

Recommended Games:
  - 3 games based on category preferences
  
Quick Stats:
  - This Week: 8 games, 3 wins
  - Streak: 12 games
  - Favorite Category: Memory (45% of plays)
```

### 2.2 User Profile Screen

**Profile Info:**
- Avatar (emoji or image URL)
- Display name
- Level + total score
- Member since date
- Bio (optional)

**Statistics Tab:**
- Total games played
- Win rate
- Longest streak
- Average score by category
- Favorite game

**Badges/Achievements Tab:**
- Earned badges with unlock dates
- Progress on nearly-earned badges
- Category mastery badges

**Settings Tab:**
- Notification preferences
- Game difficulty default
- Sound/music settings
- Privacy settings (public/private profile)
- Log out button

### 2.3 User Model (Extended)

```dart
class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl; // URL or emoji
  final int level;
  final int totalScore;
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;
  final DateTime? lastLoginAt;
  final List<Badge> badges;
  final UserPreferences preferences;
}

class UserPreferences {
  final bool publicProfile;
  final bool allowChallenges;
  final DifficultyLevel preferredDifficulty; // Easy/Medium/Hard default
  final bool soundEnabled;
  final bool musicEnabled;
  final Map<CognitiveCategory, bool> categoryPreferences;
}
```

---

## 3. Mind War Creation & Setup

### 3.1 Mind War Creation Flow

```
HomeScreen
    ↓ [⚔️ Mind War button]
    ↓
MindWarCreationScreen
    ↓
[Step 1] Basic Settings
  - Name: "Family Game Night"
  - Max Players: 4
  - Number of Rounds: 3
  - Lobby Visibility: Private / Public
    ↓
[Step 2] Selection Methods
  - Game Selection Method: Admin / Random / Democratic
  - Game Selection Scope: Mind War Level / Round Level
  
  - Difficulty Selection Method: Admin / Random / Democratic
  - Difficulty Selection Scope: Mind War Level / Round Level
  
  - Games-Per-Round Method: Admin / Random / Democratic
  - Games-Per-Round Scope: Mind War Level / Round Level
    ↓
[Step 3] Game Count (if admin method)
  - "How many games per round?" → 3 (default)
    ↓
[Step 4] Randomization Options
  - Shuffle games within round? Yes / No
  - Allow duplicate games in same round? No (locked)
  - Prevent game repeats across entire war? Yes / No
    ↓
[Step 5] Review & Create
  - Show summary of all settings
  - [Create Mind War] button
    ↓
LobbyScreen (admin/waiting for players)
```

### 3.2 Mind War Configuration Model

```dart
class MindWarConfig {
  // Basic
  final String name;
  final int maxPlayers;
  final int numberOfRounds;
  final bool isPrivate;
  
  // Selection Methods & Scopes
  final SelectionMethod gameSelectionMethod;
  final SelectionScope gameSelectionScope;
  
  final SelectionMethod difficultySelectionMethod;
  final SelectionScope difficultySelectionScope;
  
  final SelectionMethod gamesPerRoundSelectionMethod;
  final SelectionScope gamesPerRoundSelectionScope;
  
  // Admin choices (if applicable)
  final List<String>? adminSelectedGameIds;
  final DifficultyLevel? adminSelectedDifficulty;
  final int? gamesPerRoundAdminChoice;
  
  // Random config (if applicable)
  final int gamesPerRoundRandomMin;
  final int gamesPerRoundRandomMax;
  
  // Randomization flags
  final bool gameShufflePerRound;
  final bool preventGameRepeatsInRound; // Always true
  final bool preventGameRepeatsAcrossWar;
}
```

### 3.3 Backend: Mind War Creation

```
POST /api/mind-wars
  Headers: { Authorization: "Bearer {token}" }
  Body: { 
    name, 
    maxPlayers, 
    numberOfRounds,
    isPrivate,
    gameSelectionMethod,
    gameSelectionScope,
    difficultySelectionMethod,
    difficultySelectionScope,
    gamesPerRoundSelectionMethod,
    gamesPerRoundSelectionScope,
    adminSelectedGameIds?, // if admin method
    adminSelectedDifficulty?, // if admin method
    gamesPerRoundAdminChoice?, // if admin method
    gamesPerRoundRandomMin?, // if random method
    gamesPerRoundRandomMax?, // if random method
    gameShufflePerRound,
    preventGameRepeatsAcrossWar
  }
  Return: { 
    mindWarId, 
    lobbyCode,
    status: 'waiting',
    players: [host],
    currentRound: 1
  }
```

---

## 4. Mind War Administration & Lobby

### 4.1 Lobby Screen (Main Hub During War)

```
┌─────────────────────────────────────┐
│ Family Game Night          [👤 4/6] │
│ Lobby Code: SMARTMIND47             │
│ Round 1 of 3                        │
│ Status: Waiting for players         │
└─────────────────────────────────────┘

Players List:
┌─────────────────────────────────────┐
│ 👤 You (Host) - Ready               │
│ 👤 Alice - Ready                    │
│ 👤 Bob - Ready                      │
│ 👤 Charlie - Away (2 min)           │
│ ⏳ 2 empty slots                     │
└─────────────────────────────────────┘

Settings Panel (Host Only):
┌─────────────────────────────────────┐
│ Selection Methods:                  │
│ Games: Admin selection              │
│ Difficulty: Admin selection         │
│ Count: 3 games/round                │
│                                     │
│ [⚙️ Edit Settings] (if not started) │
│ [💬 Lobby Chat]                     │
│ [📋 Invite Link] SMARTMIND47        │
│ [▶️ Start War] (if ready)           │
│ [❌ Cancel]                         │
└─────────────────────────────────────┘

Chat Box:
┌─────────────────────────────────────┐
│ Alice: Ready to play!               │
│ Bob: Let's go!                      │
│ You: Starting in 30 seconds...      │
│ [Type message...] [Send]            │
└─────────────────────────────────────┘
```

### 4.2 Lobby Features

**Player Management:**
- Join/leave/kick players
- Player status: Ready/Away/Disconnected
- Accept/deny player requests (private lobbies)
- Host reassignment if host leaves

**Chat:**
- Text messaging in real-time
- Emoji support
- Message history (last 50 messages)
- System messages ("Alice joined", "Game starting in 30s")
- No profanity (filtered server-side)

**Lobby Settings (Host Only):**
- Edit selection methods before game starts
- Edit randomization options
- Set time limits for voting phases
- Adjust max players
- View all configured settings

**Ready System:**
- Players click "Ready" to confirm participation
- Host can start war once min players ready
- Auto-start timer (30s countdown once all ready)
- Disconnected players: 2-minute grace period before kick

**Sharing:**
- Public lobbies: Listed in LobbyBrowserScreen
- Private lobbies: Share code (SMARTMIND47)
- Direct invite: Send link to friends
- Copy lobby code button

### 4.3 Lobby Data Model

```dart
class GameLobby {
  final String id;
  final String code; // Memorable code: SMARTMIND47
  final String name;
  final String hostId;
  final List<Player> players;
  final int maxPlayers;
  final bool isPrivate;
  final String status; // 'waiting', 'setup', 'playing', 'completed'
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  
  // Mind War Configuration
  final MindWarConfig config;
  
  // Round Tracking
  final int numberOfRounds;
  final int currentRound;
  final List<MindWarRound> completedRounds;
  final MindWarRound? currentRoundData;
  
  // Real-time
  final Map<String, PlayerLobbyState> playerStates; // per player
}

class PlayerLobbyState {
  final String playerId;
  final bool isReady;
  final PlayerStatus status; // active, idle, disconnected
  final DateTime lastActivity;
  final int cumulativeScore;
}
```

### 4.4 Backend: Lobby Endpoints

```
WebSocket Events (Socket.io):

create-lobby
  Data: { name, maxPlayers, isPrivate, config }
  Emit: 'lobby-created' to creator
  Broadcast: None (private creation)

join-lobby
  Data: { lobbyCode }
  Emit: 'lobby-joined' to joiner
  Broadcast: 'player-joined' to all in lobby

set-ready
  Data: { lobbyId, ready: true/false }
  Broadcast: 'player-ready' to all in lobby

start-game
  Data: { lobbyId }
  Emit: Validation (host only)
  Broadcast: 'game-started' to all players
  Trigger: Setup phase for Round 1

player-disconnected
  Broadcast: 'player-disconnected' to all
  Grace period: 2 minutes before auto-kick
  Emit: 'player-kicked' after grace period

kick-player
  Data: { lobbyId, playerId } (host only)
  Broadcast: 'player-kicked' to all

update-lobby-settings
  Data: { lobbyId, newSettings } (host only)
  Broadcast: 'settings-updated' to all
  Restriction: Can't change after game started
```

---

## 5. Game Selection & Difficulty

### 5.1 Selection Phase (Round Setup)

After all players ready → System enters **Setup Phase**:

```
Setup Phase for Round N
├─ [If gameSelectionMethod = ADMIN]
│   └─ AdminGameSelectionScreen (host only)
│       ├─ Browse 12 games by category
│       ├─ Select N games (no duplicates in round)
│       ├─ Confirm selection
│       └─ Broadcast to all players
│
├─ [If gameSelectionMethod = RANDOM]
│   └─ System randomly picks N games
│       └─ Show spinner + announce selections
│
├─ [If gameSelectionMethod = DEMOCRATIC]
│   └─ VotingScreen
│       ├─ Each player gets V voting points
│       ├─ Allocate points to games
│       ├─ Blind voting (results hidden)
│       ├─ Countdown timer (default 60s)
│       ├─ Tally votes after timeout
│       └─ Top N games by points selected
│
├─ [If difficultySelectionMethod = ADMIN]
│   └─ AdminDifficultyScreen (host only)
│       ├─ Select Easy / Medium / Hard
│       └─ Broadcast to all
│
├─ [If difficultySelectionMethod = RANDOM]
│   └─ System picks random difficulty
│       └─ Announce selection
│
├─ [If difficultySelectionMethod = DEMOCRATIC]
│   └─ VotingScreen
│       ├─ Vote Easy / Medium / Hard
│       ├─ Blind voting
│       ├─ Tally after timeout
│       └─ Announce winner
│
└─ [Finalize]
    ├─ All players shown: Games + Difficulty for this round
    ├─ Countdown: "Starting in 10s..."
    └─ Round starts when countdown hits 0
```

### 5.2 Game Selection Screen

**For Admin Selection:**
```
┌─────────────────────────────────────┐
│ Select 3 Games for Round 1           │
│                                     │
│ Filter: [All ▼] [Memory] [Logic]... │
│ Search: [___________]               │
│                                     │
│ ┌─ Selected (2/3) ───────────────┐  │
│ │ [X] Memory Match               │  │
│ │ [X] Sudoku Duel                │  │
│ └────────────────────────────────┘  │
│                                     │
│ Available Games:                    │
│ [🃏 Memory Match      ] → (selected)│
│ [🔢 Sequence Recall   ]             │
│ [🎨 Pattern Memory    ]             │
│ [🔢 Sudoku Duel       ] → (selected)│
│ [🧮 Logic Grid        ]             │
│ [🔐 Code Breaker      ]             │
│ ...                                 │
│                                     │
│ [Select 1 more game]                │
│ [Confirm & Broadcast]               │
└─────────────────────────────────────┘
```

**For Democratic (Voting):**
```
┌─────────────────────────────────────┐
│ Vote for Games (Round 1)        55s  │
│ You have: 30 voting points          │
│                                     │
│ ┌─ Your Votes ──────────────────┐  │
│ │ Memory Match:  [+-] 10 points │  │
│ │ Sudoku Duel:   [+-] 8 points  │  │
│ │ Pattern Memory:[+-] 5 points  │  │
│ │ Code Breaker:  [+-] 7 points  │  │
│ │ Remaining: 0 points           │  │
│ └────────────────────────────────┘  │
│                                     │
│ [Submit Vote]                       │
│                                     │
│ Status: Waiting for 2 more players  │
└─────────────────────────────────────┘
```

### 5.3 Difficulty Selection

**For Admin Selection:**
```
┌─────────────────────────────────────┐
│ Select Difficulty (Round 1)          │
│                                     │
│ [Easy]     [Medium]    [Hard]       │
│   ✓                                 │
│ • Shorter time limits               │
│ • Simpler puzzle variants           │
│ • Reduced challenge scope           │
│                                     │
│ [Confirm & Broadcast]               │
└─────────────────────────────────────┘
```

**For Democratic (Voting):**
```
┌─────────────────────────────────────┐
│ Vote Difficulty (Round 1)       42s  │
│ You have: 10 voting points          │
│                                     │
│ Easy:   [_________] 0 points        │
│ Medium: [______________] 7 points   │
│ Hard:   [_____] 3 points            │
│                                     │
│ [Submit Vote]                       │
│ Status: 3/4 players voted           │
└─────────────────────────────────────┘
```

### 5.4 Voting Data Model

```dart
class VotingSession {
  final String id;
  final String mindWarId;
  final int roundNumber;
  final VotingType type; // 'game_selection', 'difficulty', 'game_count'
  final int totalPoints; // points each player gets
  final int pointsRemaining; // per player, calculated
  final DateTime startedAt;
  final DateTime expiresAt;
  final bool isBlind; // votes hidden until complete
  final String status; // 'active', 'completed', 'cancelled'
  
  final Map<String, Map<String, int>> votes; // playerId → { optionId → points }
  final List<String>? winningOptions; // results after tally
}

class VotingResult {
  final Map<String, int> tallies; // optionId → totalPoints
  final List<String> winners; // Top N options by points
  final DateTime tallyTime;
}
```

### 5.5 Backend: Selection/Voting Endpoints

```
WebSocket Events:

init-game-selection
  Data: { lobbyId, roundNumber, gameSelectionMethod }
  Emit: 'selection-started' to all players

submit-game-votes
  Data: { lobbyId, roundNumber, votes: { gameId → points } }
  Broadcast: 'player-voted' to all
  Validate: Total points ≤ allowance

finalize-game-selection
  Trigger: Timeout or all voted
  Broadcast: 'games-selected' with gameIds
  Result: Tally votes, select top N

init-difficulty-voting
  Data: { lobbyId, roundNumber }
  Emit: 'difficulty-voting-started' to all

submit-difficulty-vote
  Data: { lobbyId, roundNumber, difficulty, points }
  Broadcast: 'player-voted'

finalize-difficulty-selection
  Broadcast: 'difficulty-selected' with level

announce-round-setup
  Broadcast to all:
    - Selected games
    - Selected difficulty
    - Game count for round
    - Countdown to game start
```

---

## 6. Gameplay & Round Progression

### 6.1 Game Instance Creation

**Before First Game Starts:**

1. Tally votes (if democratic) or use admin selection
2. Create game instances:
   ```
   For each selected game:
     - gameId = "game_{mindWarId}_{roundNumber}_{gameIndex}_{timestamp}"
     - seed = SHA256(mindWarId + roundNumber + gameIndex)
     - difficulty = selectedDifficulty
     - difficulty parameters applied to game state
     - all players get identical game state
   ```

3. Broadcast to all players:
   ```
   {
     roundNumber: 1,
     gameNumber: 1,
     totalGamesInRound: 3,
     game: {
       id: "game_...",
       name: "Memory Match",
       difficulty: "hard",
       seed: "abc123...",
       initialState: { /* cards, positions, rules */ }
     },
     timeLimit: 180000, // ms
     startTime: "2026-04-03T14:30:00Z"
   }
   ```

### 6.2 During Gameplay

**All Players Playing Same Game:**
```
GamePlayScreen
├─ Game UI (identical for all players)
├─ Timer (shared across all)
├─ Real-time stats (optional: shared moves? TBD)
├─ Submit game result when complete
│   └─ Send: { gameId, playerId, score, timeTaken, moves[] }
└─ Wait for other players to finish
```

**Game Completion Logic:**
- Player submits game result with score
- Backend validates score (security: no client-side manipulation)
- Score stored immediately in `game_results`
- Player sees "Waiting for others..."
- Once all players finish OR timeout (30 min):
  - Advance to next game in round
  - OR show round summary if round complete

### 6.3 Round Progression

```
Round 1 Setup
    ↓
[Game 1] All 4 players play Memory Match
    ↓ All complete
    ↓
[Game 2] All 4 players play Sudoku
    ↓ All complete
    ↓
[Game 3] All 4 players play Logic Grid
    ↓ All complete
    ↓
Round 1 Summary
├─ Scores this round:
│   Alice: 450
│   You: 380
│   Bob: 420
│   Charlie: 390
├─ Cumulative standings:
│   Alice: 450 (1st)
│   Bob: 420 (2nd)
│   Charlie: 390 (3rd)
│   You: 380 (4th)
└─ [Next Round] button (if more rounds)
    ↓
Round 2 Setup (if needed)
    ↓
[Repeat for Round 2...]
    ↓
[All Rounds Complete]
    ↓
Final War Summary
```

### 6.4 Game State Model

```dart
class GameInstance {
  final String id;
  final String mindWarId;
  final int roundNumber;
  final int gameIndexInRound;
  
  final String gameTemplateId; // memory_match, sudoku_duel, etc
  final String gameName;
  final CognitiveCategory category;
  final DifficultyLevel difficulty;
  
  final String seed; // For deterministic RNG
  final Map<String, dynamic> initialState; // Game-specific state
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  
  final Map<String, GamePlayerResult> playerResults;
}

class GamePlayerResult {
  final String playerId;
  final int score;
  final int timeTaken; // milliseconds
  final List<dynamic> moves; // Game-specific move history
  final DateTime startedAt;
  final DateTime completedAt;
  final bool validated; // Security: server-side validation
}
```

### 6.5 Backend: Game Submission

```
POST /api/mind-wars/{mindWarId}/rounds/{roundNumber}/games/{gameId}/submit
  Headers: { Authorization: "Bearer {token}" }
  Body: {
    playerId,
    score,
    timeTaken,
    moves: [ /* game-specific */ ],
    seed, // For verification
    difficulty
  }
  
  Server:
    1. Validate score based on moves (prevent cheating)
    2. Apply difficulty multiplier (if applicable)
    3. Store result in game_results
    4. Check if all players done → Advance to next game or round
    5. Return: { success, nextGameOrRound }
```

---

## 7. Results & Scoring

### 7.1 Score Calculation

**Base Score** (game-specific):
- Memory Match: (pairs_matched × 10) - (time_bonus_reduction)
- Sudoku: (cells_correct × 5) + (time_bonus)
- Logic Grid: (deductions_correct × 15) + (speed_bonus)
- etc.

**Difficulty Multiplier** (Optional - TBD):
- Easy: 0.75x
- Medium: 1.0x
- Hard: 1.5x

**Final Score** = BaseScore × DifficultyMultiplier

**Score Storage:**
```dart
class GameResult {
  final String id;
  final String mindWarId;
  final String gameId;
  final String playerId;
  final int roundNumber;
  final int gameIndexInRound;
  
  final String gameType; // memory_match, sudoku_duel
  final DifficultyLevel difficulty;
  
  final int baseScore;
  final double? difficultyMultiplier;
  final int finalScore;
  
  final int timeTaken;
  final List<dynamic> moves;
  
  final DateTime submittedAt;
  final bool verified; // Server-validated
}
```

### 7.2 Round Summary Screen

```
┌─────────────────────────────────┐
│ Round 1 Complete!               │
│                                 │
│ This Round Scores:              │
│ 🥇 Alice: 1,280 pts             │
│ 🥈 Bob: 1,150 pts               │
│ 🥉 Charlie: 1,050 pts           │
│ 4️⃣ You: 950 pts                 │
│                                 │
│ Cumulative Standings:           │
│ 🥇 Alice: 1,280 (1st)           │
│ 🥈 Bob: 1,150 (2nd)             │
│ 🥉 Charlie: 1,050 (3rd)         │
│ 4️⃣ You: 950 (4th)               │
│                                 │
│ Games Played This Round:        │
│ ✓ Memory Match (Hard)           │
│ ✓ Sudoku Duel (Hard)            │
│ ✓ Logic Grid (Hard)             │
│                                 │
│ Next: 1 of 3 rounds remaining   │
│                                 │
│ [Next Round]                    │
└─────────────────────────────────┘
```

### 7.3 Final War Summary

```
┌─────────────────────────────────┐
│ Family Game Night - COMPLETE    │
│                                 │
│ 🏆 Final Winners 🏆              │
│ 🥇 Alice: 3,280 pts (3 rounds)   │
│ 🥈 Bob: 3,050 pts               │
│ 🥉 Charlie: 2,980 pts           │
│ 4️⃣ You: 2,750 pts               │
│                                 │
│ Stats:                          │
│ • 9 games total (3 per round)   │
│ • Played: 2026-04-03 2:30 PM    │
│ • Duration: 47 minutes          │
│ • Average score: 1,015 pts      │
│ • Your best: Logic Grid (420)   │
│                                 │
│ Achievements Earned:            │
│ ✨ Consistent Player (3+ games) │
│ ✨ Logic Master (+150 points)   │
│                                 │
│ [View Full Report]  [Share War] │
│ [Play Again] [Return Home]      │
└─────────────────────────────────┘
```

### 7.4 Score Validation (Anti-Cheat)

**Server-side validation before score acceptance:**

```javascript
validateScore(gameId, submission) {
  1. Check timestamp: submission.timeTaken matches (endTime - startTime)
  2. Verify moves: replay move sequence, validate against game rules
  3. Recalculate score: independently compute expected score from moves
  4. Compare: submission.score ≈ calculatedScore (within ±1%)
  5. Check difficulty: difficulty matches war configuration
  6. Check player: playerId is in war lobbies players
  7. Check timing: submission within 30 minutes of game end
  8. Return: { valid, finalScore, reason (if invalid) }
}
```

**Security Measures:**
- Never trust client-submitted scores
- Replay move history to verify validity
- Rate limit score submissions (prevent spam)
- Flag suspicious patterns (impossible scores, instant completion, etc.)
- Audit log all score submissions

---

## 8. Leaderboards & Rankings

### 8.1 Weekly Leaderboard

**Updated:** Monday-Sunday UTC

```
Weekly Rankings
┌──────────────────────────────────┐
│ This Week (Apr 1-7)              │
│ 📊 Players Updated: 15 mins ago   │
├──────────────────────────────────┤
│ 🥇 Alice           2,450 pts (8G) │
│ 🥈 Bob             2,180 pts (7G) │
│ 🥉 Charlie         1,950 pts (6G) │
│ 4️⃣ Dana            1,820 pts (7G) │
│ 5️⃣ You             1,650 pts (5G) │
│ 6️⃣ Frank           1,480 pts (4G) │
│        [Show More...]            │
├──────────────────────────────────┤
│ Your Stats This Week:            │
│ Position: 5th of 47 players      │
│ Score: 1,650 points              │
│ Games Played: 5                  │
│ Average: 330 pts/game            │
└──────────────────────────────────┘
```

### 8.2 All-Time Leaderboard

```
All-Time Rankings
┌──────────────────────────────────┐
│ Lifetime Rankings                │
│ 📊 Last Updated: 3 mins ago      │
├──────────────────────────────────┤
│ 🥇 Alice           45,230 pts     │
│    Level 28 • 234 games • 89W    │
│ 🥈 Bob             42,180 pts     │
│    Level 27 • 198 games • 78W    │
│ 🥉 Charlie         38,950 pts     │
│    Level 25 • 156 games • 62W    │
│ 4️⃣ You             28,450 pts     │
│    Level 19 • 87 games • 34W    │
│        [Show More...]            │
├──────────────────────────────────┤
│ Your Lifetime Stats:             │
│ Position: 4th of 256 players     │
│ Total Points: 28,450             │
│ Level: 19                        │
│ Games: 87 played, 34 won         │
│ Average: 327 pts/game            │
│ Streak: 8 games                  │
└──────────────────────────────────┘
```

### 8.3 Backend: Leaderboard Endpoints

```
GET /api/leaderboards/weekly
  Params: { limit: 100, offset: 0 }
  Cache: 5 minutes
  Return: [
    {
      rank: 1,
      userId: "...",
      displayName: "Alice",
      avatarUrl: "...",
      weeklyScore: 2450,
      gamesPlayed: 8,
      wins: 3,
      averageScore: 306,
      bestScore: 520
    },
    ...
  ]

GET /api/leaderboards/all-time
  Params: { limit: 100, offset: 0 }
  Cache: 10 minutes
  Return: [
    {
      rank: 1,
      userId: "...",
      displayName: "Alice",
      avatarUrl: "...",
      totalScore: 45230,
      level: 28,
      gamesPlayed: 234,
      wins: 89,
      winRate: 38%,
      averageScore: 193,
      longestStreak: 18,
      currentStreak: 8
    },
    ...
  ]

GET /api/leaderboards/user/{userId}
  Return: { rank, stats } (user's position in both boards)
```

### 8.4 Leaderboard Data Model

```dart
class LeaderboardEntry {
  final int rank;
  final String playerId;
  final String username;
  final String? avatarUrl;
  final int totalScore;
  final int gamesPlayed;
  final int wins;
  final int level;
  final double winRate;
  final int longestStreak;
  final int currentStreak;
  final DateTime weekStartDate; // For weekly
}
```

---

## 9. Social Features

### 9.1 Friends System

**Currently Missing - Needs Implementation:**

```dart
class Friend {
  final String userId;
  final String username;
  final String? avatarUrl;
  final FriendshipStatus status; // pending, accepted, blocked
  final DateTime addedAt;
  final bool canInvite; // host allows direct invites
}

enum FriendshipStatus { pending, accepted, blocked }
```

**Screens Needed:**
- `FriendsListScreen` - View friends, pending, blocked
- `AddFriendScreen` - Search users, send friend requests
- `FriendProfileScreen` - View friend stats, invite to war

**Social Features:**
- Send friend requests
- Accept/decline requests
- Block users
- View friend stats
- Quick invite to mind war
- See friend activity log

### 9.2 Challenges System

**Challenge Type 1: Direct Challenge**
```
User A → Challenge User B to specific game
  "Beat my Memory Match score (450 pts)!"
  - B accepts
  - Both play identical game (same seed, difficulty)
  - Scores compared
  - Winner gets points
```

**Challenge Type 2: Category Challenge**
```
"Prove your Logic skills! - 3 logic games in 10 min"
  - Challenger sets rules
  - Defender accepts
  - Both play same 3 logic games at same difficulty
  - Final score determines winner
```

**Challenge Type 3: Skill Rating Challenge**
```
"1v1 Ranked Match"
  - Elo-style rating system
  - Win/loss affects rating
  - Tracks head-to-head record
```

**Challenge Notifications:**
```
┌─────────────────────────────┐
│ 🎮 Alice challenged you!    │
│ "Beat my score in Sudoku"   │
│ Your score: 380 pts         │
│ Target: 450 pts             │
│                             │
│ [Accept Challenge]          │
│ [Decline]                   │
│ [View All Challenges]       │
└─────────────────────────────┘
```

### 9.3 Activity Feed

**Features:**
- Real-time activity stream
- Follows/unfollows options
- Activity notifications
- Activity types:
  - "Alice won against you in a challenge"
  - "Bob set a new high score in Memory Match"
  - "Charlie earned a new badge"
  - "Alice started a new Mind War"

**Activity Model:**
```dart
class Activity {
  final String id;
  final String playerId;
  final String message;
  final ActivityType type;
  final String? relatedUserId;
  final String? relatedGameId;
  final String? relatedWarId;
  final DateTime timestamp;
  final bool read;
}

enum ActivityType {
  challengeIssued,
  challengeAccepted,
  challengeWon,
  gameWon,
  newBadge,
  warStarted,
  warWon,
  scoreRecord
}
```

### 9.4 Notifications

**Push Notifications:**
- Friend request received
- Challenge issued
- Challenge accepted
- War invitation
- Friend achievement unlocked
- Leaderboard milestone reached

**In-App Notifications:**
- Bell icon with unread count
- Tappable notification center
- Mark as read/archive options
- Settings: enable/disable by type

---

## 10. Data Models & Backend

### 10.1 Complete Data Model Hierarchy

```
User
├── UserPreferences
├── Profile (stats, badges)
├── GameResults (many)
└── Progression (level, streaks)

GameLobby (Mind War)
├── MindWarConfig
├── Players (many)
├── MindWarRound (many)
│   ├── GameInstance (many)
│   │   └── GamePlayerResult (per player)
│   └── RoundScores
├── VotingSession (many)
│   └── Votes (many, per player)
└── ChatMessage (many)

GameTemplate (Static)
└── 12 games × 5 categories

LeaderboardEntry
├── Weekly aggregation
└── All-time aggregation

Badge (Achievement)
└── UserBadges (many, earned dates)

Challenge
├── Issuer
├── Defender
└── Result (if completed)

Activity
└── Feed entry (many per user)

Friend
└── Relationship (pending/accepted/blocked)
```

### 10.2 Database Schema (PostgreSQL)

**Existing Tables (to extend):**
- `users` - Add: lastWarId, currentStreak, longestStreak
- `lobbies` - Rename to `mind_wars`, add config fields
- `lobby_players` → `mind_war_players`
- `game_results` - Add: difficulty_level, mind_war_id, round_number
- `chat_messages` - Already exists

**New Tables Needed:**
```sql
-- Mind War Rounds
CREATE TABLE mind_war_rounds (
  id UUID PRIMARY KEY,
  mind_war_id UUID NOT NULL REFERENCES mind_wars(id),
  round_number INT NOT NULL,
  selected_game_ids TEXT[] NOT NULL, -- Array of game IDs
  selected_difficulty VARCHAR(20),
  games_in_round INT,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  UNIQUE(mind_war_id, round_number)
);

-- Game Instances
CREATE TABLE game_instances (
  id UUID PRIMARY KEY,
  mind_war_id UUID NOT NULL REFERENCES mind_wars(id),
  round_number INT NOT NULL,
  game_index INT NOT NULL,
  game_template_id VARCHAR(50) NOT NULL,
  difficulty VARCHAR(20),
  seed VARCHAR(255) NOT NULL, -- For deterministic RNG
  initial_state JSONB,
  created_at TIMESTAMP,
  started_at TIMESTAMP,
  completed_at TIMESTAMP
);

-- Voting Sessions
CREATE TABLE voting_sessions (
  id UUID PRIMARY KEY,
  mind_war_id UUID NOT NULL REFERENCES mind_wars(id),
  round_number INT,
  voting_type VARCHAR(50), -- 'game', 'difficulty', 'game_count'
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  total_points INT,
  status VARCHAR(20) -- 'active', 'completed'
);

-- Friends
CREATE TABLE friendships (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  friend_id UUID NOT NULL REFERENCES users(id),
  status VARCHAR(20), -- 'pending', 'accepted', 'blocked'
  created_at TIMESTAMP,
  UNIQUE(user_id, friend_id)
);

-- Challenges
CREATE TABLE challenges (
  id UUID PRIMARY KEY,
  challenger_id UUID NOT NULL REFERENCES users(id),
  defender_id UUID NOT NULL REFERENCES users(id),
  challenge_type VARCHAR(50), -- 'direct', 'category', 'ranked'
  game_id VARCHAR(50), -- For direct game challenges
  status VARCHAR(20), -- 'pending', 'accepted', 'completed'
  created_at TIMESTAMP,
  completed_at TIMESTAMP,
  winner_id UUID REFERENCES users(id)
);

-- Activity Feed
CREATE TABLE activities (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  activity_type VARCHAR(50),
  message TEXT,
  related_user_id UUID REFERENCES users(id),
  related_game_id VARCHAR(50),
  related_war_id UUID REFERENCES mind_wars(id),
  created_at TIMESTAMP,
  read BOOLEAN DEFAULT false
);

-- Notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  type VARCHAR(50),
  title VARCHAR(255),
  body TEXT,
  related_id UUID,
  created_at TIMESTAMP,
  read BOOLEAN DEFAULT false,
  sent_at TIMESTAMP
);
```

### 10.3 Backend API Structure

```
/api
├── /auth
│   ├── POST /register
│   ├── POST /login
│   ├── POST /refresh
│   ├── POST /logout
│   └── GET /me
│
├── /users
│   ├── GET /:id
│   ├── GET /:id/progress
│   ├── PATCH /:id
│   ├── GET /:id/stats
│   └── GET /:id/recent-games
│
├── /mind-wars
│   ├── POST / (create)
│   ├── GET / (list public)
│   ├── GET /:id
│   ├── POST /:id/join
│   ├── POST /:id/leave
│   ├── POST /:id/start
│   ├── POST /:id/settings (host)
│   ├── /rounds/:roundNumber
│   │   ├── POST /setup (init round)
│   │   ├── POST /games/:gameId/submit (player result)
│   │   └── GET /summary
│   └── GET /:id/results
│
├── /leaderboards
│   ├── GET /weekly
│   ├── GET /all-time
│   └── GET /user/:userId
│
├── /games
│   ├── GET / (list all games)
│   ├── GET /:id (game template)
│   └── POST /:id/validate (move validation)
│
├── /voting
│   ├── POST /:id/vote
│   ├── GET /:id/results
│   └── POST /:id/tally
│
├── /friends
│   ├── GET /
│   ├── POST / (add friend)
│   ├── PATCH /:id (accept/block)
│   └── DELETE /:id (remove)
│
├── /challenges
│   ├── POST / (issue)
│   ├── GET / (list for user)
│   ├── POST /:id/accept
│   ├── POST /:id/decline
│   └── POST /:id/complete
│
├── /activity
│   ├── GET / (feed)
│   ├── PATCH /:id/read
│   └── DELETE /:id
│
└── /notifications
    ├── GET /
    ├── PATCH /:id/read
    └── DELETE /:id
```

---

## 11. Implementation Priority

### Phase 1: Core Gameplay Loop (Weeks 1-4)
- [x] Auth (done)
- [x] Screens (mostly done)
- [x] Games (done)
- [ ] Mind War creation (config model done, UI needs work)
- [ ] Lobby management (basic done, needs polish)
- [ ] Game selection/voting (models done, voting UI TBD)
- [ ] Game instance creation & seeding
- [ ] Game submission & validation
- [ ] Round progression
- [ ] Score calculation & storage
- [ ] Round/War summaries

### Phase 2: Leaderboards & Social (Weeks 5-6)
- [x] Leaderboard data model (done)
- [ ] Leaderboard UI screens
- [ ] Friends system (add, accept, block)
- [ ] Friend profiles
- [ ] Activity feed
- [ ] Challenge system (direct, category, ranked)
- [ ] Notifications center

### Phase 3: Advanced Social (Weeks 7-8)
- [ ] Tournaments/seasons
- [ ] Teams/guilds
- [ ] Advanced rating systems (Elo, Glicko)
- [ ] Match history & replay
- [ ] Game statistics (per game type)
- [ ] Skill progression tracking

### Phase 4: Polish & Monetization (Weeks 9+)
- [ ] Premium features
- [ ] Battle pass system
- [ ] In-game purchases
- [ ] Analytics & telemetry
- [ ] Admin tools
- [ ] Moderation system
- [ ] Performance optimization

---

## Key Architectural Principles

1. **Identical Game Instances**: All players in a round play the exact same game
2. **Server-Side Validation**: All scores verified, no client-side trust
3. **Flexible Selection**: Admins, random, or democratic voting for games/difficulty/count
4. **Real-Time Communication**: WebSocket for lobbies, voting, game state
5. **Fairness**: No player disadvantage, equal opportunities, transparent scoring
6. **Scalability**: Stateless API servers, cached leaderboards, efficient queries
7. **Progressive Features**: MVP → Core → Advanced, phased rollout
