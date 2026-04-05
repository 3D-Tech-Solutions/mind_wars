# Vote-to-Skip Feature: Complete Walkthroughs (CORRECTED)

**Feature**: Vote-to-Skip (Skip AFK Player During Selection Phase)
**Minimum Players**: 3 (for Majority skip rule)
**Purpose**: Keep Battles moving when a player doesn't vote for game selection
**Context**: Used during **Selection Phase** only (NOT during gameplay)

---

## Mind Wars Terminology Reference (CORRECTED)

| Term | Definition | Example |
|------|------------|---------|
| **Mind War** | The entire multiplayer session from start to completion | "Family Gaming Night" with 4 players across 5 Battles |
| **Big Brain** | Admin/orchestrator who configures the Mind War rules | Alice creates lobby and sets skip rules to "Majority" |
| **Lobby** | The waiting room where players gather before the War begins | Status: `waiting` → `in-progress` → `completed` |
| **Battle** | One competition cycle: Selection → Play → Results | Battle 1 of 5 |
| **Selection Phase** | Democratic voting/point-allocation to choose games for a Battle | Each player distributes 10 points across available games |
| **Play Phase** | All players complete selected games simultaneously/asynchronously | Everyone plays Memory Match at their own pace (hours/days) |
| **Game** | A single cognitive puzzle instance | Memory Match, Sudoku Duel, Word Builder |
| **Vote-to-Skip** | Vote to skip an AFK player's point allocation during Selection Phase | 2 of 3 players vote → Carol's 10 points forfeited for this Battle |
| **Skip Rules** | Big Brain's configuration for how skips work | Majority, Unanimous, or Time-Based |

---

## Big Brain Configuration (War Setup)

Before the Mind War begins, the **Big Brain** configures:

### 1. Battle Structure
```
├─ Battle Count: Fixed number (e.g., 5 Battles) OR Continuous
└─ Games per Battle: Fixed (e.g., 3 games), Pattern (4→3→2), OR Random
```

### 2. Game Selection Method
```
├─ Point Assignment (default: 10 points per player to distribute)
├─ Set Games (Big Brain pre-selects all games)
├─ Random Selection (system picks)
└─ Ranked Choice Voting
```

### 3. Skip Rules for Selection Phase ⚠️ CRITICAL
```
┌────────────────────────────────────────────────────────────┐
│  Big Brain chooses ONE of three skip rules:               │
├────────────────────────────────────────────────────────────┤
│  1. MAJORITY                                               │
│     - Requires: 50% + 1 of active players                  │
│     - Example: 3 players = 2 votes needed                  │
│     - Example: 5 players = 3 votes needed                  │
│     - Minimum players: 3 (for voting to work)              │
│                                                            │
│  2. UNANIMOUS                                              │
│     - Requires: 100% agreement                             │
│     - Example: 3 players = 3 votes needed                  │
│     - Example: 5 players = 5 votes needed                  │
│     - Harder to achieve, slower Battles                    │
│                                                            │
│  3. TIME-BASED                                             │
│     - Auto-skip after X hours (e.g., 24 hours)             │
│     - No voting needed                                     │
│     - Timer starts when Selection Phase begins             │
│     - Automatic, no player intervention                    │
└────────────────────────────────────────────────────────────┘
```

---

## Scenario 1: 2-Player Mind War (Vote-to-Skip NOT Available)

**Players**: Alice (Big Brain), Bob
**Configuration**:
- 3 Battles
- 2 games per Battle
- Point Assignment (10 points per player)
- Skip Rule: Majority (but won't work with only 2 players)

**Duration**: ~1-3 days (asynchronous play)

### Complete Flow

```
═══════════════════════════════════════════════════════════════
PHASE 1: LOBBY SETUP
═══════════════════════════════════════════════════════════════

Step 1: Alice (Big Brain) Creates Mind War
├─ War Name: "Quick Mind War"
├─ Max Players: 2
├─ Battle Count: 3
├─ Games Per Battle: 2
├─ Selection Method: Point Assignment (10 points per player)
├─ Skip Rule: Majority (50%+1)  ⚠️ Won't work with 2 players
├─ Privacy: Private
└─ Lobby Code Generated: "SWIFT42"

Step 2: Bob Joins
├─ Enters code: "SWIFT42"
├─ Joins lobby successfully
└─ Alice sees: "Bob joined the lobby"

Step 3: Lobby Status
├─ Players: Alice (Big Brain), Bob
├─ Status: 'waiting'
├─ Ready to start: ✅ (minimum 2 players)
└─ Vote-to-Skip Available: ❌ (needs minimum 3 players for Majority rule)


═══════════════════════════════════════════════════════════════
BATTLE 1: SELECTION PHASE
═══════════════════════════════════════════════════════════════

Step 4: Alice Starts Battle 1 Selection
├─ Button: "Start Battle 1"
├─ System creates Selection Phase:
│  ├─ Battle: 1 of 3
│  ├─ Each player gets: 10 points to distribute
│  └─ Available games: All MVP games (Memory Match, Sudoku, etc.)
└─ Both players navigate to Selection Screen

Step 5: Players Distribute Points (Selection Phase)

Alice's Point Distribution (10 points total):
├─ Memory Match: 6 points
├─ Sudoku Duel: 4 points
└─ Remaining: 0 points ✅

Bob's Point Distribution (10 points total):
├─ Memory Match: 8 points
├─ Word Builder: 2 points
└─ Remaining: 0 points ✅

Step 6: Alice Ends Selection Phase
├─ Button: "End Selection"
├─ System tallies points:
│  ├─ Memory Match: 6 + 8 = 14 points (1st place) ✅
│  ├─ Sudoku Duel: 4 + 0 = 4 points (2nd place) ✅
│  └─ Word Builder: 0 + 2 = 2 points (3rd place) ❌
└─ Selected games for Battle 1: [Memory Match, Sudoku Duel]


═══════════════════════════════════════════════════════════════
BATTLE 1: PLAY PHASE (SIMULTANEOUS/ASYNC)
═══════════════════════════════════════════════════════════════

Step 7: Play Game 1 - Memory Match (Simultaneous)
├─ Lobby Status: 'waiting' → 'in-progress'
├─ ⚠️ NOT turn-based! Both players play independently
│
├─ Alice's Play Session (Monday 3pm):
│  ├─ Starts Memory Match puzzle
│  ├─ Flips cards to find matches
│  ├─ Completes game in 8 minutes
│  ├─ Final Score: 850 points
│  ├─ Accuracy: 92%
│  └─ Submits result to server
│
└─ Bob's Play Session (Tuesday 9am - 18 hours later):
   ├─ Starts same Memory Match puzzle variant
   ├─ Flips cards to find matches
   ├─ Completes game in 6 minutes
   ├─ Final Score: 920 points
   ├─ Accuracy: 95%
   └─ Submits result to server

💡 NOTE: No turns, no waiting for each other, fully asynchronous!

Step 8: Play Game 2 - Sudoku Duel (Simultaneous)
├─ Alice completes (Monday 8pm): 760 points
└─ Bob completes (Tuesday 11am): 810 points


═══════════════════════════════════════════════════════════════
BATTLE 1: RESULTS PHASE
═══════════════════════════════════════════════════════════════

Step 9: Battle 1 Scores Tallied
├─ Alice's Total: 850 + 760 = 1,610 points
├─ Bob's Total: 920 + 810 = 1,730 points
├─ Winner: Bob 🏆
└─ System: "Battle 2 Selection Phase starting..."


═══════════════════════════════════════════════════════════════
BATTLE 2: SELECTION PHASE - AFK SCENARIO
═══════════════════════════════════════════════════════════════

Step 10: Battle 2 Selection Begins
├─ Alice distributes points immediately:
│  ├─ Word Builder: 7 points
│  └─ Puzzle Race: 3 points
│
└─ Bob: [AFK - hasn't voted after 20 hours] ⏰

Step 11: Vote-to-Skip Attempt
├─ Alice wants to skip Bob's vote
├─ ❌ Vote-to-Skip Button: DISABLED
├─ Reason: "Requires 3+ players for Majority vote"
├─ Message: "Waiting for Bob to vote OR time-based auto-skip..."
└─ ⏰ Must wait for Bob to return OR timeout

Step 12: Resolution Options
├─ Option A: Bob returns and votes → Battle continues
├─ Option B: Time-based auto-skip (if configured by Big Brain)
│  └─ After 24 hours: Bob's 10 points forfeited
└─ Option C: Big Brain manually forces Battle start


═══════════════════════════════════════════════════════════════
KEY TAKEAWAY: 2-Player Limitations
═══════════════════════════════════════════════════════════════

❌ Vote-to-Skip NOT Available with Majority Rule
   - Only 1 other player (cannot have majority)
   - Cannot vote yourself out
   - Stuck waiting for AFK player

✅ Alternative: Time-Based Skip Rule
   - Big Brain should configure Time-Based for 2-player wars
   - Auto-skip after X hours (e.g., 24h)
   - No voting needed
   - Better UX for small groups

⏰ Recommendation for 2-Player Wars
   Big Brain Configuration:
   └─ Skip Rule: Time-Based (24 hours)
      └─ Prevents indefinite waiting
```

---

## Scenario 2: 3-Player Mind War (Vote-to-Skip AVAILABLE)

**Players**: Alice (Big Brain), Bob, Carol
**Configuration**:
- 3 Battles
- 2 games per Battle
- Point Assignment (10 points per player)
- Skip Rule: **Majority (50%+1)**

**Duration**: ~2-4 days (asynchronous play)

### Complete Flow

```
═══════════════════════════════════════════════════════════════
PHASE 1: LOBBY SETUP
═══════════════════════════════════════════════════════════════

Step 1: Alice (Big Brain) Creates Mind War
├─ War Name: "Friends Mind War"
├─ Max Players: 4
├─ Battle Count: 3
├─ Games Per Battle: 2
├─ Selection Method: Point Assignment (10 pts/player)
├─ Skip Rule: Majority (50%+1) ✅
├─ Privacy: Private
└─ Lobby Code: "BRAIN99"

Step 2: Bob & Carol Join
├─ Bob enters "BRAIN99" → Joins
├─ Carol enters "BRAIN99" → Joins
└─ All 3 players in lobby

Step 3: Lobby Status
├─ Players: Alice (Big Brain), Bob, Carol
├─ Status: 'waiting'
├─ Ready to start: ✅
└─ Vote-to-Skip Available: ✅ (3 players = majority voting possible)


═══════════════════════════════════════════════════════════════
BATTLE 1: SELECTION PHASE (Normal Flow)
═══════════════════════════════════════════════════════════════

Step 4: Alice Starts Battle 1 Selection
├─ All 3 players get 10 points each
└─ Navigate to Game Selection Screen

Step 5: Players Distribute Points

Alice's Distribution (10 points):
├─ Memory Match: 5 points
└─ Sudoku Duel: 5 points

Bob's Distribution (10 points):
├─ Memory Match: 6 points
└─ Word Builder: 4 points

Carol's Distribution (10 points):
├─ Sudoku Duel: 8 points
└─ Memory Match: 2 points

Step 6: Alice Ends Selection Phase
├─ System tallies points:
│  ├─ Memory Match: 5 + 6 + 2 = 13 points (1st) ✅
│  ├─ Sudoku Duel: 5 + 0 + 8 = 13 points (1st - tie) ✅
│  └─ Word Builder: 0 + 4 + 0 = 4 points (3rd) ❌
└─ Selected for Battle 1: [Memory Match, Sudoku Duel]


═══════════════════════════════════════════════════════════════
BATTLE 1: PLAY PHASE (Simultaneous/Async)
═══════════════════════════════════════════════════════════════

Step 7: All Players Complete Games Independently

Memory Match Results:
├─ Alice (Monday 2pm): 850 points in 9 min
├─ Bob (Monday 8pm): 920 points in 7 min
└─ Carol (Tuesday 10am): 780 points in 11 min

Sudoku Duel Results:
├─ Alice (Monday 3pm): 760 points in 12 min
├─ Bob (Tuesday 9am): 810 points in 10 min
└─ Carol (Tuesday 2pm): 840 points in 8 min


═══════════════════════════════════════════════════════════════
BATTLE 1: RESULTS
═══════════════════════════════════════════════════════════════

Step 8: Battle 1 Totals
├─ Bob: 920 + 810 = 1,730 points 🏆
├─ Carol: 780 + 840 = 1,620 points
└─ Alice: 850 + 760 = 1,610 points


═══════════════════════════════════════════════════════════════
BATTLE 2: SELECTION PHASE - VOTE-TO-SKIP SCENARIO
═══════════════════════════════════════════════════════════════

Step 9: Battle 2 Selection Begins (Monday 9am)

Step 10: Status After 20 Hours (Tuesday 5am)
├─ ✅ Alice: Voted (7→Word Builder, 3→Puzzle Race)
├─ ✅ Bob: Voted (10→Puzzle Race)
└─ ⏳ Carol: AFK (hasn't voted in 20 hours)

Step 11: Vote-to-Skip Initiated
├─ Time: Tuesday 5am (20 hours after Selection began)
├─ Alice clicks: "Vote to Skip Carol's Points for Battle 2"
│
├─ Vote-to-Skip UI Appears:
│  ┌────────────────────────────────────────────────────────┐
│  │  Vote to Skip Carol's Point Allocation?               │
│  │                                                        │
│  │  Carol hasn't voted in 20 hours                       │
│  │  Forfeit her 10 points for Battle 2?                  │
│  │                                                        │
│  │  Skip Rule: Majority (50%+1)                          │
│  │  Votes Required: 2 of 2 eligible voters               │
│  │                                                        │
│  │  Vote Status:                                          │
│  │  ✅ Alice (voted to skip)                              │
│  │  ⏳ Bob (not voted yet)                                │
│  │  👤 Carol (AFK - being skipped, cannot vote)          │
│  │                                                        │
│  │  [Vote to Skip]  [Cancel]                             │
│  └────────────────────────────────────────────────────────┘
│
└─ Notification sent to Bob: "Alice wants to skip Carol's vote"

Step 12: Bob Votes to Skip
├─ Time: Tuesday 6am (1 hour later)
├─ Bob clicks: "Vote to Skip"
├─ Votes: 2/2 ✅ MAJORITY REACHED
└─ System: "Majority vote reached - skipping Carol's points"


═══════════════════════════════════════════════════════════════
BATTLE 2: SKIP EXECUTED
═══════════════════════════════════════════════════════════════

Step 13: Selection Phase Completed with Skip
├─ Carol's 10 points: FORFEITED ❌
├─ Games selected from Alice + Bob votes only:
│  ├─ Word Builder: 7 + 0 = 7 points (2nd) ✅
│  └─ Puzzle Race: 3 + 10 = 13 points (1st) ✅
│
├─ Notifications:
│  ├─ Alice: "Selection complete - Battle 2 starting"
│  ├─ Bob: "Selection complete - Battle 2 starting"
│  └─ Carol: "Your vote was skipped by majority - Battle 2 starting"
│
└─ Battle 2 Play Phase begins


═══════════════════════════════════════════════════════════════
BATTLE 2: PLAY PHASE (Carol Can Still Participate!)
═══════════════════════════════════════════════════════════════

Step 14: All Three Players Complete Games
├─ ✅ Carol CAN still play the selected games
├─ Only her Selection Phase vote was skipped
├─ She can earn points in Play Phase
│
├─ Word Builder Results:
│  ├─ Alice: 880 points
│  ├─ Bob: 790 points
│  └─ Carol: 910 points ✅ (still participates!)
│
└─ Puzzle Race Results:
   ├─ Alice: 720 points
   ├─ Bob: 850 points
   └─ Carol: 770 points


═══════════════════════════════════════════════════════════════
VOTE-TO-SKIP MECHANICS BREAKDOWN
═══════════════════════════════════════════════════════════════

Majority Calculation (3 players, Majority rule):
├─ Total players: 3
├─ Player being skipped: Carol (cannot vote on her own skip)
├─ Eligible voters: 2 (Alice, Bob)
├─ Required for majority: 50% + 1 = 1.5 → round up to 2
└─ Result: BOTH Alice AND Bob must vote to skip

Skip Button Visibility:
├─ Appears: After X hours configured by Big Brain (e.g., 12-24h)
├─ Visible to: All players EXCEPT the one being skipped
├─ Shows: Real-time vote count (1/2, 2/2)
└─ Location: Selection Phase screen, near player list

What Gets Skipped:
├─ ✅ Skipped: Carol's 10 points for THIS Battle's Selection
├─ ❌ NOT Skipped: Carol's ability to play in Play Phase
├─ ❌ NOT Skipped: Carol's participation in future Battles
└─ Result: Carol loses influence on game selection but can still score points

Penalties (Current MVP):
├─ Lost voting power for this Battle
├─ No additional point penalty
└─ Can vote normally in next Battle

Future Enhancements:
├─ Penalty: -10 points if skipped
├─ Warning: "You've been skipped - please stay active!"
└─ Auto-kick: After 3 skips in a Mind War
```

---

## Scenario 3: 5-Player Mind War (Different Skip Rules)

**Players**: Alice (Big Brain), Bob, Carol, Dave, Eve
**Example**: Carol goes AFK during Battle 2 Selection Phase

### Skip Rule Option 1: MAJORITY (50%+1)

```
Configuration:
├─ Total players: 5
├─ Player being skipped: Carol (cannot vote on herself)
├─ Eligible voters: 4 (Alice, Bob, Dave, Eve)
├─ Required votes: 50% + 1 = 2.5 → round up to 3
└─ Result: 3 out of 4 must vote to skip

Vote Sequence:
├─ Hour 0: Battle 2 Selection begins
├─ Hour 18: Carol still hasn't voted
├─ Hour 18: Alice initiates skip vote → Votes: 1/3
├─ Hour 19: Bob votes to skip → Votes: 2/3
├─ Hour 20: Dave votes to skip → Votes: 3/3 ✅ MAJORITY!
├─ Hour 20: Skip executed immediately
└─ Result: Eve's vote not needed (majority already achieved)
```

### Skip Rule Option 2: UNANIMOUS (100%)

```
Configuration:
├─ Total players: 5
├─ Player being skipped: Carol
├─ Eligible voters: 4 (Alice, Bob, Dave, Eve)
├─ Required votes: 100% = 4 votes
└─ Result: ALL 4 must vote to skip (harder to achieve)

Vote Sequence:
├─ Hour 18: Alice initiates → Votes: 1/4
├─ Hour 19: Bob votes → Votes: 2/4
├─ Hour 20: Dave votes → Votes: 3/4
├─ Hour 22: Eve ABSTAINS (doesn't vote)
└─ Result: ❌ Skip CANCELLED - unanimous not reached

Outcome:
├─ Must wait for Carol to return
└─ OR wait for time-based auto-skip (if configured as backup)
```

### Skip Rule Option 3: TIME-BASED (24 hours)

```
Configuration:
├─ Auto-skip after: 24 hours
├─ No voting needed
├─ Timer starts: When Selection Phase begins
└─ Fully automatic

Timeline:
├─ Hour 0: Battle 2 Selection begins
├─ Hour 23: Carol still AFK, countdown visible: "1 hour remaining"
├─ Hour 24: Auto-skip triggered ✅
│  ├─ Carol's 10 points forfeited
│  ├─ Games selected from remaining players' votes
│  └─ Notification: "Carol's vote auto-skipped (timeout)"
└─ Result: No player intervention needed
```

---

## Comparison: Skip Rules

| Skip Rule | Players Needed | Votes Required | Difficulty | Best For |
|-----------|----------------|----------------|------------|----------|
| **Majority** | 3+ | 50% + 1 of eligible | Moderate | Balanced groups |
| **Unanimous** | 3+ | 100% of eligible | Hard | Close-knit friends |
| **Time-Based** | 2+ | 0 (automatic) | N/A | Async play, casual groups |

**Big Brain's Choice Impact:**

```
Majority (Recommended for most):
├─ Pros: Democratic, not too strict, not too lenient
├─ Cons: Requires coordination among voters
└─ Use Case: Standard Mind Wars with active players

Unanimous (Strict):
├─ Pros: Ensures everyone agrees before skipping
├─ Cons: One abstention blocks skip, slower Battles
└─ Use Case: Very tight friend groups who rarely skip

Time-Based (Automatic):
├─ Pros: No coordination needed, predictable timing
├─ Cons: Less democratic, may skip players who intended to vote
└─ Use Case: Async play across time zones, 2-player wars
```

---

## Technical Implementation Requirements

### Database Schema

```sql
-- Vote-to-skip sessions (Selection Phase only)
CREATE TABLE IF NOT EXISTS vote_to_skip_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    battle_number INTEGER NOT NULL,
    player_id_to_skip UUID NOT NULL REFERENCES users(id),
    initiated_by UUID NOT NULL REFERENCES users(id),
    skip_rule VARCHAR(20) NOT NULL, -- 'majority', 'unanimous', 'time_based'
    votes_required INTEGER NOT NULL,
    votes_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active', -- active, executed, cancelled
    phase VARCHAR(20) DEFAULT 'selection', -- Always 'selection' for MVP
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    executed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    time_limit_hours INTEGER -- For time-based skip rule
);

-- Individual skip votes
CREATE TABLE IF NOT EXISTS vote_to_skip_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES vote_to_skip_sessions(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL REFERENCES users(id),
    voted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(session_id, voter_id)
);

CREATE INDEX idx_vote_to_skip_sessions_lobby_id ON vote_to_skip_sessions(lobby_id);
CREATE INDEX idx_vote_to_skip_sessions_status ON vote_to_skip_sessions(status);
CREATE INDEX idx_vote_to_skip_votes_session_id ON vote_to_skip_votes(session_id);
```

### Socket.io Events

```javascript
// Client → Server (Selection Phase only)
'initiate-skip-vote'   // Player starts a vote to skip someone's Selection vote
'cast-skip-vote'       // Player votes to skip
'cancel-skip-vote'     // Player cancels their skip vote

// Server → Client
'skip-vote-initiated'  // Broadcast: Skip vote started for Selection Phase
'skip-vote-updated'    // Broadcast: Vote count changed (1/2, 2/2, etc.)
'skip-vote-executed'   // Broadcast: Player's Selection points forfeited
'skip-vote-cancelled'  // Broadcast: Vote failed, waiting continues
'time-skip-executed'   // Broadcast: Auto-skip triggered (time-based rule)
```

### Flutter Models

```dart
class VoteToSkipSession {
  final String id;
  final String lobbyId;
  final int battleNumber;              // Which Battle's Selection Phase
  final String playerIdToSkip;
  final String playerNameToSkip;
  final String initiatedBy;
  final SkipRule skipRule;             // majority, unanimous, time_based
  final int votesRequired;             // 2 for 3 players, 3 for 5 players, etc.
  final int votesCount;                // Current votes
  final Map<String, bool> votes;       // userId → voted
  final String status;                 // 'active', 'executed', 'cancelled'
  final String phase;                  // Always 'selection' for MVP
  final DateTime createdAt;
  final DateTime? executedAt;
  final int? timeLimitHours;          // For time-based rule

  bool get isExecuted =>
    skipRule == SkipRule.timeBased
      ? _isTimeExpired()
      : votesCount >= votesRequired;

  int get votesRemaining => votesRequired - votesCount;
}

enum SkipRule {
  majority,    // 50% + 1
  unanimous,   // 100%
  timeBased    // Auto after X hours
}
```

### UI Components (Selection Phase Only)

```dart
// Vote-to-skip button (shown during Selection Phase when player AFK)
FloatingActionButton(
  onPressed: _initiateSkipVote,
  child: Icon(Icons.skip_next),
  tooltip: 'Vote to skip ${aFKPlayer.name}\'s Selection vote',
  // Only visible during Selection Phase if player hasn't voted
);

// Vote-to-skip dialog (Selection Phase context)
AlertDialog(
  title: Text('Skip ${playerName}\'s Selection Vote?'),
  content: Column(
    children: [
      Text('${playerName} hasn\'t distributed points in ${hours}h'),
      Text('Forfeit their 10 points for this Battle?'),
      SizedBox(height: 16),
      Text('Skip Rule: ${skipRule.displayName}'),
      Text('Votes: ${votesCount}/${votesRequired}'),
      SizedBox(height: 8),
      ...playerList.map((player) =>
        ListTile(
          leading: player.voted
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.hourglass_empty),
          title: Text(player.name),
          subtitle: Text(
            player.id == playerToSkip.id
              ? 'Being skipped (cannot vote)'
              : player.voted
                ? 'Voted to skip'
                : 'Not voted'
          ),
        )
      ),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel'),
    ),
    ElevatedButton(
      onPressed: _castSkipVote,
      child: Text('Vote to Skip'),
    ),
  ],
);

// Time-based skip countdown (Selection Phase)
if (skipRule == SkipRule.timeBased)
  Container(
    child: Text(
      'Auto-skip in: ${remainingHours}h ${remainingMinutes}m',
      style: TextStyle(color: Colors.orange),
    ),
  )
```

---

## Summary: 2 vs 3+ Players

| Feature | 2 Players | 3+ Players |
|---------|-----------|------------|
| **Vote-to-Skip (Majority)** | ❌ Not available | ✅ Available |
| **Vote-to-Skip (Unanimous)** | ❌ Not available | ✅ Available |
| **Vote-to-Skip (Time-Based)** | ✅ Available | ✅ Available |
| **Recommended Skip Rule** | Time-Based | Majority or Time-Based |
| **Context** | Selection Phase only | Selection Phase only |
| **What Gets Skipped** | Point allocation | Point allocation |
| **Can Still Play?** | Yes (Play Phase) | Yes (Play Phase) |

---

## Key Takeaways for MVP

✅ **All games are simultaneous/async** - No sequential turns in MVP
✅ **Vote-to-skip is for Selection Phase** - When someone doesn't distribute points
✅ **Big Brain configures skip rules** - Majority, Unanimous, or Time-Based
✅ **Skipped players can still play** - Only their Selection vote is forfeited
✅ **Turn-based games are POST-MVP** - Chess, Checkers come later
✅ **Battle structure is key** - Selection → Play → Results
✅ **3 players minimum** - For Majority/Unanimous voting to work

---

## Next Steps for Implementation

1. **Backend**
   - Create vote-to-skip session tracking
   - Implement majority/unanimous/time-based logic
   - Add Selection Phase skip handlers
   - Forfeit points when skip executed

2. **Frontend**
   - Add skip button to Selection Phase screen
   - Create vote dialog with rule-specific UI
   - Show countdown for time-based skips
   - Handle notifications

3. **Testing**
   - Test with 2 players (only time-based works)
   - Test with 3 players (majority 2/2)
   - Test with 5 players (majority 3/4, unanimous 4/4)
   - Test time-based auto-skip
   - Test cancellation flows
