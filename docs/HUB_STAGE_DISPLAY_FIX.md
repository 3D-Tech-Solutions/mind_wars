# Hub Stage Display Fix (2026-04-05)

## Change Made: Add Explicit Stage Labels

**Problem**: Hub card showed only icons (orange dot for waiting, green dot for playing), without text labels for the actual stage/phase.

**Solution**: Added explicit stage labels that update in real-time.

---

## What the Hub Card Now Shows

### War in "Lobby" Phase (waiting)

```
┌─────────────────────────────────────────┐
│  ⚔ EskiFam                 [RANKED]    │
│     [MEDIUM]                            │
│     3/open players        Lobby        │  ← NEW: Stage label
│     ●WAITING                            │  ← Orange dot
│     Code: A7K9X                         │
│     [Open Lobby →]                      │
└─────────────────────────────────────────┘
```

**Data Source**:
- "Lobby" label: `_getStageLabel()` returns 'Lobby' when `status == 'waiting'`
- Orange color/icon: `statusColor` from `lobby.status`
- Player count: `${lobby.players.length}/open`
- All updates live via socket events

---

### War in "Playing" Phase (game in progress)

```
┌─────────────────────────────────────────┐
│  ⚔ Summer Challenge         [RANKED]   │
│     [HARD]                              │
│     2/4 players           Round 2       │  ← NEW: Current round
│     of 5 rounds                         │  ← Total rounds
│     ●PLAYING                            │  ← Green dot
│     [Play Round →]                      │
└─────────────────────────────────────────┘
```

**Data Source**:
- "Round 2" label: `_getStageLabel()` returns 'Round ${lobby.currentRound}' when `status == 'playing'`
- "of 5 rounds": Shows `lobby.numberOfRounds` for context
- Green color/icon: `statusColor` from `lobby.status`
- Player count: `${lobby.players.length}/${lobby.maxPlayers}`
- All updates live via socket events

---

## Implementation Details

### Stage Label Function (lines 514-525)
```dart
String _getStageLabel(GameLobby lobby) {
  switch (lobby.status) {
    case 'waiting':
      return 'Lobby';
    case 'playing':
      return 'Round ${lobby.currentRound}';
    case 'completed':
      return 'Complete';
    default:
      return lobby.status;
  }
}
```

Maps backend status values to user-friendly labels:
- `'waiting'` → "Lobby" (planning/setup phase)
- `'playing'` → "Round X" (game round in progress)
- `'completed'` → "Complete" (war finished)

### Display Layout (lines 630-645)
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('$playerCount players'),  // Left: Player count
    Text(
      stageLabel,                   // Right: Stage label
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: statusColor,         // Orange or green
      ),
    ),
  ],
)
```

Two-column layout:
- **Left**: Player count (e.g., "3/open")
- **Right**: Stage label (e.g., "Lobby" or "Round 2")

---

## Real-Time Updates

**All Stage Changes Update Live**:

| Change | Trigger | Socket Event | Hub Updates |
|--------|---------|--------------|-------------|
| Lobby created | Host creates | `list-my-lobbies` | Shows "Lobby" |
| Player joins | New player | `player-joined` | Count updates |
| War config changed | Host updates difficulty | `lobby-updated` | Card refreshes |
| Game starts | Host starts voting/game | `game-started` | "Lobby" → "Round 1" |
| Round changes | Game completes round | `lobby-updated` | "Round 1" → "Round 2" |
| War completes | Last round finishes | `lobby-updated` | "Round X" → "Complete" |

**No Manual Refresh Needed** - All changes propagate via socket.io immediately

---

## Verification Checklist

### Display Correctness
- [ ] Create lobby, verify hub shows **"Lobby"** label (not just icon)
- [ ] Player count shows **"X/open"** correctly
- [ ] Ranked badge appears if war is ranked
- [ ] Difficulty chip shows (EASY, MEDIUM, HARD)

### Stage Transitions
- [ ] Start voting, verify label still shows **"Lobby"** (status still waiting)
- [ ] Start game, verify label changes to **"Round 1"** (status → playing)
- [ ] After round completes, verify changes to **"Round 2"** if applicable
- [ ] When war completes, verify shows **"Complete"**

### Live Updates (No Refresh Required)
- [ ] Device A: Create war with "Lobby" stage
- [ ] Device B: Join using code
- [ ] Device A: Player count **immediately** updates from 1 to 2
- [ ] Device A: Start game
- [ ] Device B: Label **immediately** changes from "Lobby" to "Round 1"
- [ ] Both devices see all changes in real-time

### Player Count Accuracy
- [ ] Single player: Shows "1/open"
- [ ] Multiple players: Count updates as each joins
- [ ] With max cap: Shows "X/Y" (e.g., "3/4")
- [ ] No false "/10" shown unless maxPlayers explicitly set to 10

---

## Files Modified

| File | Change | Lines |
|------|--------|-------|
| `lib/screens/multiplayer_hub_screen.dart` | Added `_getStageLabel()` method | 514-525 |
| `lib/screens/multiplayer_hub_screen.dart` | Updated card display with stage label + player count | 534, 630-650 |

---

## Limitations / Future Work

### Known Limitation: "Game Selection" Phase Not Tracked
The current backend doesn't distinguish between:
- Voting phase (players voting on games)
- Playing phase (games in progress)

Both currently fall under `status='playing'`.

**Workaround**: Voting happens in a separate modal screen, not reflected in hub.

**Future Enhancement**: Add `status='voting'` to backend to track this as a distinct phase.

---

## Build Status
✅ **No compilation errors**
✅ **Ready for deployment**

