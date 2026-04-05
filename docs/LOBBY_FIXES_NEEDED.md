# Lobby Screen Fixes (2026-04-05)

## Issue 1: Leave Lobby Confirmation + Immediate Hub Removal

**Problem:** When user clicks "Leave Lobby" button, no confirmation appears. Lobby remains in Multi-War hub until user logs back in.

**Root Cause:**
- No confirmation dialog exists
- Hub doesn't get notified when user leaves (only when others do)
- "Leave Lobby" emits only to the leaving user (response ack), not broadcast to hub

**Solution:**

### Step 1A: Add Confirmation Dialog in lobby_screen.dart

Modify `_leaveLobby()` method (around line 440) to show a confirmation dialog first:

```dart
bool _skipLeaveLobbyConfirmation = false;

Future<void> _leaveLobby() async {
  // Show confirmation dialog unless user checked "Do Not Ask Again"
  if (!_skipLeaveLobbyConfirmation) {
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool dontAskAgain = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Leave "${_lobby!.name}"?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Are you sure you want to leave this Mind War?'),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() => dontAskAgain = !dontAskAgain);
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: dontAskAgain,
                          onChanged: (val) {
                            setState(() => dontAskAgain = val ?? false);
                          },
                        ),
                        const Text('Do not ask again'),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _skipLeaveLobbyConfirmation = dontAskAgain;
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Leave'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldLeave != true) return; // User clicked Cancel or dismissed
  }

  // Actually leave the lobby
  try {
    await widget.multiplayerService.leaveLobby();
    if (!mounted) return;
    Navigator.of(context).pop();
  } catch (e) {
    if (!mounted) return;
    _showSnackBar('Failed to leave lobby: ${e.toString()}');
  }
}
```

### Step 1B: Notify Hub When User Leaves

Modify `multiplayer_service.dart` to emit a "left-my-lobby" event when leaveLobby succeeds:

```dart
// In multiplayer_service.dart, around line 232

Future<void> leaveLobby() async {
  if (_socket == null || _currentLobby == null) {
    throw Exception('Not in a lobby');
  }

  final completer = Completer<void>();
  final leftLobbyId = _currentLobby!.id;  // ← Capture lobby ID before clearing

  _socket!.emitWithAck('leave-lobby', {
    'lobbyId': leftLobbyId,
  }, ack: (data) {
    if (data['success']) {
      _currentLobby = null;
      // ← ADD THIS: Broadcast to hub that user left
      _broadcastEvent('left-my-lobby', {'lobbyId': leftLobbyId});
      completer.complete();
    } else {
      completer.completeError(Exception(data['error']));
    }
  });

  return completer.future;
}
```

### Step 1C: Listen in Hub for "left-my-lobby" Event

Modify `multiplayer_hub_screen.dart` to add a listener for when user leaves a lobby:

```dart
// In _setupSocketListeners() method, around line 168, add this listener:

// Listen for when user leaves a lobby
_multiplayerService.on('left-my-lobby', (data) {
  if (!mounted) return;
  final lobbyId = data is Map ? data['lobbyId'] as String? : data as String?;
  if (lobbyId != null) {
    setState(() {
      _myLobbies.removeWhere((l) => l.id == lobbyId);
    });
  }
});
```

---

## Issue 2: War Config Update Fails (Column 'difficulty' Does Not Exist)

**Problem:** When host tries to change difficulty in War Config, error: "Column 'difficulty' of relation 'lobbies' does not exist"

**Root Cause:** Phase 2 columns were not in the database because schema.sql uses ALTER TABLE IF NOT EXISTS, which doesn't run on existing databases.

**Solution:** ✅ APPLIED - Manually added Phase 2 columns to database:

```sql
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS difficulty VARCHAR(10) DEFAULT 'medium';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS hint_policy VARCHAR(20) DEFAULT 'enabled';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS ranked BOOLEAN DEFAULT false;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS game_pack VARCHAR(50) DEFAULT NULL;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS mind_war_id UUID DEFAULT NULL;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS scoring_model_version VARCHAR(20) DEFAULT '1.0';
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS payload_locked BOOLEAN DEFAULT false;
ALTER TABLE lobbies ADD COLUMN IF NOT EXISTS payload_locked_at TIMESTAMPTZ DEFAULT NULL;
```

**Status:** ✅ DONE - War Config updates should now work.

---

## Issue 3: Default View Should Be Chat, Not Player List

**Problem:** When entering a lobby, default view shows player list. Should default to chat.

**Current Flow:**
- User enters lobby_screen.dart
- Displays: Lobby info card + player list + action buttons
- Chat is accessible via top-right icon → opens full ChatScreen

**Desired Flow:**
- User enters lobby_screen.dart
- Displays: Chat view as primary content
- Player list accessible via tab or side panel
- Lobby info card still shown

**Solution:** Refactor lobby_screen.dart to use a TabBarView or replace body with ChatScreen embedded:

### Option A (Simpler): Embed ChatScreen as main content

Replace the current Column-based body with:

```dart
@override
Widget build(BuildContext context) {
  if (_isLoading || _lobby == null) {
    return Scaffold(
      body: Center(child: BrandAnimations.loadingSpinner(size: 64)),
    );
  }

  final isHost = _lobby!.isHost(widget.currentUserId);

  return Scaffold(
    appBar: AppBar(
      title: Text(_lobby!.name),
      actions: [
        // Players count indicator
        IconButton(
          icon: const Icon(Icons.people),
          onPressed: _showPlayersPanel,  // ← New method to show side panel
          tooltip: 'Players (${_lobby!.players.length})',
        ),
        if (isHost)
          PopupMenuButton<String>(
            // ... host menu
          ),
      ],
    ),
    body: SafeArea(
      child: ChatScreen(
        lobbyId: _lobby!.id,
        multiplayerService: widget.multiplayerService,
      ),
    ),
  );
}

// New method to show players in a bottom sheet or side panel
Future<void> _showPlayersPanel() async {
  showModalBottomSheet(
    context: context,
    builder: (context) => _buildPlayersPanel(),
  );
}

Widget _buildPlayersPanel() {
  // ... current player list widget from existing code
}
```

### Option B (More Complex): Use TabBarView

If you want both chat and players visible with tabs:

```dart
// Add to _LobbyScreenState:
late TabController _tabController;

@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  // ... rest of init
}

@override
Widget build(BuildContext context) {
  // ... scaffold setup
  
  return Scaffold(
    appBar: AppBar(
      title: Text(_lobby!.name),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.chat), text: 'Chat'),
          Tab(icon: Icon(Icons.people), text: 'Players'),
        ],
      ),
      // ... actions
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        // Chat tab (index 0 - DEFAULT)
        ChatScreen(lobbyId: _lobby!.id, ...),
        // Players tab (index 1)
        _buildPlayersPanel(),
      ],
    ),
  );
}
```

**Recommendation:** Use **Option A** (simpler) since:
- Chat is the primary interaction point
- Players panel accessible via icon
- Less refactoring needed
- Matches typical messaging app UX

---

## Implementation Checklist

### Issue 1: Leave Confirmation + Hub Removal
- [ ] Add `bool _skipLeaveLobbyConfirmation = false` state variable in lobby_screen.dart
- [ ] Replace `_leaveLobby()` method with confirmation dialog logic
- [ ] Add `_broadcastEvent()` call in multiplayer_service.dart's `leaveLobby()` 
- [ ] Add "left-my-lobby" listener in multiplayer_hub_screen.dart's `_setupSocketListeners()`
- [ ] Test: Leave a lobby, confirm it disappears from hub immediately

### Issue 2: War Config Update
- [ ] ✅ ALREADY APPLIED - Phase 2 columns added to database
- [ ] Test: Change difficulty in War Config, verify it works
- [ ] Check backend logs for any errors

### Issue 3: Chat as Default View
- [ ] Choose Option A or B (recommend A)
- [ ] Implement TabBar or bottom sheet for players
- [ ] Remove current Column body that shows player list
- [ ] Ensure lobby info card is still visible (maybe in ChatScreen header or separate area)
- [ ] Test: Enter lobby, chat is first thing you see

---

## Testing Order

1. **War Config First** (easiest) - Try changing difficulty in lobby, should work now
2. **Leave Lobby** - Leave a lobby, confirm dialog appears, then disappears from hub
3. **Chat Default** - Enter new lobby, chat should be visible by default

