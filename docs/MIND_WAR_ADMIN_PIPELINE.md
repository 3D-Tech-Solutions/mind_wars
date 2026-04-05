# Mind War Admin Pipeline Specification

**Version:** 1.0  
**Date:** 2026-04-04  
**Status:** Planning

## Overview

The Mind War Admin Pipeline manages the full lifecycle of creating, configuring, and managing Mind Wars (sealed async multiplayer competitions). This document defines the screens, flows, and business logic required to support the admin (host) and participant workflows.

---

## 1. Core Concepts

### 1.1 Mind War Lifecycle

```
Host Creates Lobby
    ↓
Host Invites Players
    ↓
Players Join (via code/link)
    ↓
Host Configures Mind War (game type, difficulty, hint policy)
    ↓
Host Starts Mind War (immutable battle payload locked)
    ↓
Players Take Turns (async turntaking)
    ↓
Scores Validated Server-Side
    ↓
Results Displayed & Ranked (if eligible)
```

### 1.2 Admin Responsibilities

The Mind War **admin** (lobby host) has these capabilities:

- Create a lobby
- Configure Mind War settings (game type, difficulty, hint policy, scoring rules)
- Invite other players
- Manage lobby membership (accept/reject join requests)
- Kick players before game starts
- Lock configuration and start the Mind War
- View in-progress and completed results
- Close or archive the Mind War

### 1.3 Participant Responsibilities

**Players** (non-admin members):

- Join a Mind War (via code or invite link)
- Accept Mind War configuration
- Complete their turns (when it's their turn)
- View results and leaderboard
- Access chat/reactions

---

## 2. Admin Screens Specification

### 2.1 Lobby Creation Screen

**Route:** `/create-lobby`  
**Screen:** `LobbyCreationScreen` (exists)  
**Admin Action:** Host creates initial lobby

#### Fields:
- **Lobby Name** (text input)
  - Min 3 characters, max 50
  - Example: "Smith Family Mind War", "Team Building Challenge"
- **Max Players** (slider 2-10)
  - Minimum 2 (host already counts as 1)
  - Maximum 10 per API spec
- **Visibility**
  - Radio: Private (invite-only) / Public (anyone can search and join)
  - Default: Private (aligns with product philosophy)
- **Number of Rounds** (slider 1-10)
  - How many game rounds to play
  - Default: 3
- **Voting Points Per Player** (slider 5-20)
  - Points each player gets to vote on games per round
  - Default: 10

#### Output on Create:
- `GameLobby` object created with `status: 'waiting'`
- Generate shareable lobby code (e.g., "FAMILY42")
- Navigate to **Lobby Management Screen**

---

### 2.2 Lobby Management Screen

**Route:** `/lobby`  
**Screen:** `LobbyScreen` (exists, needs enhancement for admin pipeline)  
**Admin Actions:** Manage players, configure Mind War, start game

#### Sections:

##### A. Lobby Info Card
- Lobby name
- Lobby code (copyable)
- Player count indicator (X / Max)
- Status badge (Waiting, In Progress, Completed)

##### B. Player List
- Show all players in lobby
- Indicate host with crown icon
- Show player status (Accepted, Pending, AFK)
- **Host-only actions:**
  - Kick player button (before game starts)
  - Transfer host button (optional, advanced feature)

##### C. Invite Players Section (Host Only)
- Display invite code prominently
- "Copy Code" button
- "Generate New Code" button (optional)
- Note: "Send this code to invite friends to join"

##### D. Mind War Configuration Panel (Host Only)
- **Game Type Selector**
  - Dropdown or grid of available games
  - Show game icon, name, category
  - Default: First game in catalog
- **Difficulty**
  - Radio or dropdown: Easy / Medium / Hard
  - Show impact on scoring
  - Default: Medium
- **Hint Policy**
  - Radio: Disabled / Enabled / Custom
  - If Enabled: show hint budget UI
  - Default: Enabled
- **Ranked Eligibility Toggle**
  - Switch: This Mind War contributes to leaderboards
  - Show warning: "Ranked games must use locked rules"
  - Default: Off (enable manually)
- **Skip Rule Configuration** (Vote-to-Skip)
  - Dropdown: Majority / Unanimous / Time-Based
  - If Time-Based: input hours threshold
  - Default: Majority

##### E. Action Buttons (Bottom)
- **Host Only:**
  - "Lock & Start Mind War" (disabled until min 2 players accepted)
  - "Configure More" → opens advanced settings modal
- **All Players:**
  - "Chat" button
  - "Ready" / "Not Ready" toggle

---

### 2.3 Advanced Mind War Configuration Modal (Host Only)

**Route:** (modal from 2.2)  
**Screen:** `MindWarConfigurationModal`  
**Purpose:** Allow fine-tuning of competitive rules

#### Fields:
- **Guess/Attempt Cap** (if applicable to game)
  - Input number or "Unlimited"
- **Hint Types Allowed** (checkboxes)
  - Example: Vocabulary game might have "Definition", "Example", "Part of Speech" hints
  - Show/hide based on selected game
- **Scoring Bonus/Penalty**
  - Speed bonus toggle
  - Perfect round bonus toggle
  - Hint penalty UI (e.g., "−5 points per hint")
- **Time Model**
  - Toggle: "Include time in score" / "Time as tiebreaker only"
  - Show impact on final ranking
- **Attempt Power/Weighting**
  - Example: Vocab game might weight accuracy vs. speed differently
  - Sliders per metric

#### Validation:
- Must match one of the game's supported config profiles
- Server validates against `GameCapabilities` for that game

#### Output:
- Immutable configuration locked when "Lock & Start" is clicked

---

### 2.4 Mind War Start Confirmation Modal

**Route:** (modal from 2.2)  
**Screen:** `StartMindWarConfirmationModal`  
**Purpose:** Final checkpoint before locking rules and distributing payload

#### Shows:
- Summary of Mind War config:
  - Game: [Game Name]
  - Difficulty: [Level]
  - Hint Policy: [Policy]
  - Ranked: Yes/No
  - Player Count: X players
- Warning: "Once started, these rules cannot be changed"
- "Start Mind War" button (destructive)
- "Review Configuration" button

#### On Confirm:
1. Lock configuration (immutable)
2. Distribute battle payload to all players
3. Transition lobby `status: 'in-progress'`
4. Navigate to **Turn Management Screen**

---

### 2.5 Turn Management Screen (In-Progress)

**Route:** `/game` or similar  
**Screen:** `TurnManagementScreen`  
**Purpose:** Show who's up, track progress, manage turn order

#### Sections:

##### A. Round & Turn Indicator
- "Round 1 of 3"
- Turn order: "It's [Player Name]'s turn"
- Progress bar (X turns completed / X total)

##### B. Game Selection / Voting (if enabled)
- If using vote-to-skip: show active voting session
- If using game voting: show available games to vote on
- Current vote tally

##### C. Turn Queue
- List all players in turn order
- Show status (Completed, In Progress, Pending, Skipped)
- ETA for each player (if time policy allows)

##### D. Actions
- "View Leaderboard" button
- "Chat" button
- "Skip This Round" button (if current player)
- "Vote to Skip [Player]" button (if vote-to-skip enabled)

##### E. Host Controls (If Admin)
- "Emergency Pause" button (pause all activity)
- "Manually Skip [Player]" button (with confirmation)
- "Close Mind War" button

---

### 2.6 Results & Ranking Screen (Post-Game)

**Route:** `/mind-war-results/{mindWarId}`  
**Screen:** `MindWarResultsScreen`  
**Purpose:** Display final standings and persisted leaderboard routing

#### Sections:

##### A. Final Standings
- Ranked list: 1st, 2nd, 3rd, ...
- Per player: Final Score, Efficiency Metric (game-specific), Time
- Medal icons for top 3

##### B. Individual Performance Cards
- Expandable card per player
- Show: Score, mistakes, time, hints used
- Hint breakdown (e.g., "3 definitions, 1 example")

##### C. Leaderboard Messages
- If ranked: "Scores submitted to leaderboards"
  - Show which leaderboards (Global / Regional / National)
  - Link to view leaderboard impact
- If unranked: "This Mind War was not ranked"
- If mixed eligibility: "Player X's result is ranked; Player Y used hints so they're in assisted leaderboard"

##### D. Host Actions
- "Download Results (CSV)" button
- "Archive Mind War" button
- "Start New Mind War" button

---

## 3. Data Models

### 3.1 Enhanced GameLobby Model

```dart
class GameLobby {
  String id;
  String name;
  String hostId;
  List<Player> players;
  int maxPlayers;
  String status; // 'waiting', 'in-progress', 'completed'
  
  // New for Mind War pipeline:
  MindWarConfiguration? configuration; // Null until locked
  bool isPrivate;
  String? lobbyCode; // e.g., "FAMILY42"
  int numberOfRounds;
  int votingPointsPerPlayer;
  SkipRule skipRule;
  int skipTimeLimitHours;
  
  DateTime createdAt;
  DateTime? startedAt; // When Mind War was locked and started
  DateTime? completedAt;
  
  // Results
  List<MindWarResult>? finalResults;
  Map<String, int>? finalScores; // playerId -> score
}
```

### 3.2 MindWarConfiguration Model

```dart
class MindWarConfiguration {
  String gameType; // e.g., "code_breaker", "vocabulary_showdown"
  Difficulty difficulty; // Easy, Medium, Hard
  HintPolicy hintPolicy; // Disabled, Enabled, Custom
  ScoringConfiguration scoringConfig;
  bool isRanked;
  int? guessCap; // Null = unlimited
  bool includeTimeInScore;
  TimeModel timeModel;
  Map<String, dynamic> gameSpecificConfig; // Per-game rules
  
  DateTime lockedAt; // When configuration became immutable
  String payloadVersion; // Version for validation replay
}
```

### 3.3 MindWarResult Model

```dart
class MindWarResult {
  String mindWarId;
  String playerId;
  String playerUsername;
  int placement; // 1st, 2nd, etc.
  int finalScore;
  Map<String, dynamic> gameMetrics; // efficiency, time, mistakes, etc.
  bool isRanked;
  LeaderboardBuckets buckets; // which leaderboards this result routes to
  DateTime completedAt;
  Map<String, dynamic> turnLog; // Turn-by-turn events for validation
}
```

---

## 4. Admin Workflow Walkthrough

### Happy Path: Family Creates a Mind War

1. **Dad (host)** opens app home → taps "Multiplayer" → **Multiplayer Dashboard** (new feature)
2. **Dashboard** shows two buttons:
   - "Create a Mind War"
   - "Join Existing Lobby"
3. **Dad** taps "Create a Mind War" → **Lobby Creation Screen**
4. **Dad** fills in:
   - Name: "Smith Family Challenge"
   - Max players: 4
   - Visibility: Private
   - Rounds: 3
   - Voting Points: 10
5. **Creates Lobby** → **Lobby Management Screen**
6. **Dad** sees:
   - Lobby code: "FAMILY42"
   - Player list: dad + (empty slots)
   - "Copy Code" button → shares via SMS/WhatsApp
7. **Mom, Alice, Bob** receive code and join via `LobbyBrowserScreen` → "FAMILY42" → **Lobby Management Screen**
8. **Dad** (in host panel) sees players joining in real-time
9. **Dad** opens **Mind War Configuration Card**:
   - Selects "Vocabulary Showdown"
   - Difficulty: Medium
   - Hint Policy: Enabled
   - Ranked: OFF (family game, not for leaderboards)
10. **Dad** reviews → clicks "Lock & Start Mind War"
11. **Confirmation Modal** shows config summary
12. **DAD** confirms → payload locked & distributed
13. All players transition to **Turn Management Screen**
14. **Players** take turns, submit answers, see live leaderboard
15. After all rounds → **Results Screen** with final standings

---

## 5. Implementation Roadmap

### Phase 1: Core Admin Flow (This Sprint)
- [ ] Enhance `LobbyCreationScreen` (add mind war specific config)
- [ ] Enhance `LobbyManagementScreen` with host controls
- [ ] Create `MindWarConfigurationModal`
- [ ] Create `StartMindWarConfirmationModal`
- [ ] Add routes to `main.dart`
- [ ] Connect API calls for config locking & payload distribution

### Phase 2: Turn Management & Results (Next Sprint)
- [ ] Create `TurnManagementScreen`
- [ ] Create `MindWarResultsScreen`
- [ ] Implement turn validation & scoring
- [ ] Implement leaderboard routing

### Phase 3: Advanced Features (Future)
- [ ] Emergency pause/resume
- [ ] Manual player removal/skip
- [ ] Results export (CSV)
- [ ] Mind War archive/history
- [ ] Admin analytics dashboard

---

## 6. User Story Mapping

Based on `BETA_TESTING_USER_STORIES.md` Wave 1:

**Story**: "Hosts can create a lobby and invite others"  
**Maps to**: Sections 2.1 - 2.2 (Lobby Creation + Management)

**Story**: "Invited testers can join without ambiguity"  
**Maps to**: Lobby code flow + join feedback

**Story**: "All players see accurate membership and readiness state"  
**Maps to**: Section 2.2 (Player List + Status Indicators)

**Story**: "The group can move from social setup into a playable session"  
**Maps to**: Section 2.4 (Start Confirmation → Turn Management)

---

## 7. Success Metrics

- Admin can create a Mind War in < 60 seconds
- Invite code is successfully shared and joined in < 5 attempts
- All players see consistent configuration across devices
- Ranked eligibility is clear and prevents scoring errors
- No ambiguity in turn order or submission deadlines
