# Multi-War Hub Card Display Audit (2026-04-05)

## Current Hub Card Display

### Layout
```
┌────────────────────────────────────────────┐
│ War Name (bold)              [RANKED]      │
│ [MEDIUM]                                    │
│ 2/open players                              │
│ Round 2 of 5 (if status='playing')          │
│ ●PLAYING (green) or ●WAITING (orange)       │
│ Code: A7K9X (if status='waiting')           │
│ [Open Lobby / Play Round →]                 │
└────────────────────────────────────────────┘
```

---

## Player Count Display ✅ CORRECT

**Current Implementation** (line 518-520):
```dart
final playerCount = lobby.maxPlayers == null
    ? '${lobby.players.length}/open'
    : '${lobby.players.length}/${lobby.maxPlayers}';
```

**Display**: `2/open` or `2/10` depending on maxPlayers setting

**Assessment**: ✅ CORRECT
- Shows actual player count from `lobby.players.length` 
- Shows "/open" for unlimited lobbies (no hard cap)
- Shows "/10" for capped lobbies (if maxPlayers is set)
- Updates in real-time via `player-joined` and `player-left` socket events

---

## Stage Display ⚠️ NEEDS IMPROVEMENT

**Current Implementation** (lines 516-517, 620-622):
```dart
// Visual indicator
final statusColor = lobby.status == 'waiting' ? Colors.orange : Colors.green;
final statusIcon = lobby.status == 'waiting' ? Icons.schedule : Icons.play_circle_filled;

// Text display
if (lobby.status == 'playing')
  Text('Round ${lobby.currentRound} of ${lobby.numberOfRounds}')
```

**What's Currently Shown**:
- Status icon + color dot (no text label for the phase)
- Round info only when `status == 'playing'`

**What User Wants**:
- Explicit text labels: "Lobby", "Game Selection", "Round X"
- Phase should update live as game progresses

**Problem**: 
1. No text like "Lobby" or "Game Selection" - only icons
2. Backend doesn't distinguish between "Game Selection" phase and "Playing" phase
   - Both would likely be `status='playing'` in current backend

**What Needs to Change**:

### Option 1: Add stage information to backend
The backend should track game phase more granularly:
- 'waiting' → "Lobby" (planning phase)
- 'voting' or 'selecting' → "Game Selection" (voting for games phase)
- 'playing' → "Round X" (game is active)
- 'completed' → "Complete" (war finished)

### Option 2: Show stage as text in hub (simpler, immediate fix)
Replace status icon with explicit text:
```dart
// Instead of just icon, show text
String getStageLabel(GameLobby lobby) {
  switch (lobby.status) {
    case 'waiting':
      return 'Lobby';
    case 'playing':
      return 'Round ${lobby.currentRound} of ${lobby.numberOfRounds}';
    case 'completed':
      return 'Complete';
    default:
      return lobby.status;
  }
}
```

Then display:
```dart
Text(
  getStageLabel(lobby),
  style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
),
```

---

## Real-Time Update Verification ✅ CORRECT

**Socket Events Configured** (lines 93-181):

| Event | Triggers | Updates |
|-------|----------|---------|
| `lobby-updated` | War Config changed | Full lobby snapshot, players list |
| `player-joined` | New player joins | Player count, players list |
| `player-left` | Player leaves | Player count, players list |
| `game-started` | Game begins | Status→'playing', currentRound=1 |
| `lobby-closed` | Lobby closed | Removes lobby from list |

**All events replace lobby in-place** (line 100-101):
```dart
final index = _myLobbies.indexWhere((l) => l.id == updatedLobby.id);
if (index >= 0) {
  _myLobbies[index] = updatedLobby;  // Replace with fresh data
}
```

**UI rebuilds immediately** when setState triggers

**Assessment**: ✅ CORRECT - Live updates are working

---

## Data Sources (Backend → Frontend)

| Display Field | Data Source | Backend Column | Live Updates |
|---|---|---|---|
| Player count | `lobby.players.length` | Derived from `fetchLobbyPlayers()` | ✅ Via player-joined/left events |
| Max players | `lobby.maxPlayers` | `lobbies.max_players` | ✅ Via lobby-updated event |
| Status | `lobby.status` | `lobbies.status` | ✅ Via game-started event |
| Round progress | `lobby.currentRound` | `lobbies.current_round` | ✅ Via game-started/lobby-updated |
| Total rounds | `lobby.numberOfRounds` | `lobbies.total_rounds` | ✅ Via lobby-updated |

**All fields are live** - they update when server events arrive

---

## Example: How It Updates in Real-Time

### Scenario: "2 players in waiting lobby, then game starts"

**Initial State**:
```
War Card shows:
- 2/open players
- ●WAITING (orange dot)
- Lobby code: A7K9X
- Button: "Open Lobby"
```

**When Game Starts** (host clicks "Start Vote" → "Start Game"):
1. Backend: `UPDATE lobbies SET status='playing', current_round=1`
2. Backend: Broadcasts `game-started` event with full lobby snapshot
3. Hub receives event:
   ```dart
   _multiplayerService.on('game-started', (data) {
     final updatedLobby = GameLobby.fromJson(data);
     _myLobbies[index] = updatedLobby;  // Replace
     setState(() { });  // Trigger rebuild
   });
   ```
4. Card rebuilds with new data:
   ```
   War Card now shows:
   - 2/open players (unchanged)
   - ●PLAYING (green dot)        ← changed
   - Round 1 of 5               ← changed
   - Button: "Play Round"        ← changed
   ```

**All changes are immediate** (no manual refresh needed)

---

## Missing: Game Phase Granularity

**Current Backend Statuses** (from schema):
- 'waiting' - Lobby/planning phase
- 'playing' - Game running (rounds)
- 'completed' - Finished
- 'closed' - Closed

**What User Asked For**:
- Lobby ← 'waiting' status ✅
- Game Selection ← NOT a separate backend status ❌
- Round X ← Part of 'playing' status ✅

**The Gap**: "Game Selection" phase isn't tracked separately.

In current system:
- Host finishes config → clicks "Start Vote" → enters voting screen (not tracked in lobby status)
- Voting is handled separately, not as a lobby phase
- When voting ends → host clicks "Start Game" → `status='playing'`

So the flow is:
1. 'waiting' - Planning/config
2. (Optional) Voting screen (separate modal, not a lobby status)
3. 'playing' - Rounds are happening

There's no separate "Game Selection" status in the backend.

---

## Issues & Recommendations

### Issue 1: Status Text Not Explicit ⚠️ NEEDS FIX

**Problem**: Hub shows only icon + dot, no text like "Lobby" or "Round 1"

**Fix**: Add stage label text to hub card
```dart
String getStageLabel(GameLobby lobby) {
  if (lobby.status == 'waiting') return 'Lobby';
  if (lobby.status == 'playing') return 'Round ${lobby.currentRound}';
  return lobby.status;
}

// Then in card:
Text(getStageLabel(lobby), style: TextStyle(fontWeight: FontWeight.bold))
```

### Issue 2: "Game Selection" Not a Separate Phase ⚠️ BACKEND LIMITATION

**Current Flow**:
- Players in Lobby (status='waiting')
- Host clicks "Vote" → Voting modal appears (separate screen, status still='waiting')
- Players vote
- Host clicks "Start Game" → status becomes 'playing'

**Option A**: Keep as-is
- Can't show "Game Selection" as a distinct phase
- Would need backend changes to track this

**Option B**: Track voting phase in backend
- Add `status='voting'` when voting starts
- Update status='playing' when round begins
- Would require game handler refactoring

### Issue 3: Player Count Shows "/open" Correctly ✅ NO ISSUE

**Status**: Working as designed
- `${lobby.players.length}/open` for unlimited lobbies ✅
- No false "/10" shown when max players isn't set ✅

---

## Verification Checklist for Device Testing

### Player Count
- [ ] Create lobby, verify shows "1/open" (no max set)
- [ ] Set max players to 4, create new lobby, verify shows "1/4" 
- [ ] Join with second device, verify shows "2/4" live
- [ ] Join with 3rd/4th devices, verify counts to 4/4

### Stage Display
- [ ] Create lobby, verify shows orange dot (waiting/lobby stage)
- [ ] Start voting phase, verify it transitions
- [ ] Start game, verify shows "Round 1 of X"
- [ ] Complete a round, verify shows "Round 2 of X"
- [ ] Finish war, verify shows "Complete" or closes

### Live Updates
- [ ] Device A: Create lobby
- [ ] Device B: Join using code
- [ ] Device A: Player count immediately shows 2 (no refresh needed)
- [ ] Device A: Leave
- [ ] Device B: Player count immediately shows 1 (no refresh needed)
- [ ] Device A: Change difficulty in War Config
- [ ] Device B: Difficulty chip updates live (no refresh needed)
- [ ] Device A: Start game
- [ ] Device B: Hub card transitions from orange to green immediately

---

## Summary

| Aspect | Status | Details |
|--------|--------|---------|
| Player Count Display | ✅ Works | Shows X/open or X/Y correctly, updates live |
| Stage Icon | ✅ Works | Orange=waiting, Green=playing, updates live |
| Round Progress | ✅ Works | Shows "Round 1 of 5" when status='playing' |
| Live Updates | ✅ Works | All 5 socket events trigger immediate UI refresh |
| Stage Text Labels | ❌ Missing | Should show "Lobby", "Round X" as text, not just icons |
| Game Selection Phase | ❌ Not tracked | "Game Selection" isn't a separate backend status |

**Recommendation**: 
1. **Quick fix**: Add stage label text to hub card (30 seconds)
2. **Future enhancement**: Track voting phase separately in backend (more complex)

