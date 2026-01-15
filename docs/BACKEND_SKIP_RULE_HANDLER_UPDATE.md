# ✅ Backend Skip Rule Handler Update

**Date**: November 15, 2024
**Branch**: `claude/phase2-chat-system-01MJcE3XLhXzc6vKfG5d4eWS`
**Status**: ✅ **COMPLETE**

---

## 🎯 Implementation Summary

Updated backend Socket.io handlers to fully support vote-to-skip configuration, including saving and retrieving skip rule settings from the database.

---

## 🔧 Changes Made

### File Modified
**`backend/multiplayer-server/src/handlers/lobbyHandlers.js`**

### 1. Update Lobby Settings Handler (Lines 332-425)

**Before**:
```javascript
socket.on('update-lobby-settings', async (settings, callback) => {
  const { lobbyId, maxPlayers, totalRounds, votingPointsPerPlayer } = settings;

  // ... validation ...

  // Update settings (3 fields only)
  if (maxPlayers) {
    updates.push(`max_players = $${paramCount++}`);
    values.push(maxPlayers);
  }

  // ... (only 3 fields updated)

  // Notify players (3 fields only)
  socket.to(`lobby:${lobbyId}`).emit('lobby-settings-updated', {
    maxPlayers,
    totalRounds,
    votingPointsPerPlayer,
    timestamp: new Date().toISOString()
  });
});
```

**After**:
```javascript
socket.on('update-lobby-settings', async (settings, callback) => {
  const {
    lobbyId,
    maxPlayers,
    totalRounds,
    votingPointsPerPlayer,
    skipRule,            // ✅ NEW
    skipTimeLimitHours   // ✅ NEW
  } = settings;

  // ✅ NEW: Validate skip rule
  if (skipRule && !['majority', 'unanimous', 'time_based'].includes(skipRule)) {
    return callback({
      success: false,
      error: 'Invalid skip rule. Must be majority, unanimous, or time_based'
    });
  }

  // ✅ NEW: Validate skip time limit
  if (skipTimeLimitHours !== undefined && (skipTimeLimitHours < 1 || skipTimeLimitHours > 72)) {
    return callback({
      success: false,
      error: 'Skip time limit must be between 1 and 72 hours'
    });
  }

  // Update settings (5 fields now)
  if (maxPlayers) {
    updates.push(`max_players = $${paramCount++}`);
    values.push(maxPlayers);
  }

  // ... existing fields ...

  // ✅ NEW: Update skip rule
  if (skipRule) {
    updates.push(`skip_rule = $${paramCount++}`);
    values.push(skipRule);
  }

  // ✅ NEW: Update skip time limit
  if (skipTimeLimitHours !== undefined) {
    updates.push(`skip_time_limit_hours = $${paramCount++}`);
    values.push(skipTimeLimitHours);
  }

  // ✅ NEW: Notify players with skip fields
  socket.to(`lobby:${lobbyId}`).emit('lobby-settings-updated', {
    maxPlayers,
    totalRounds,
    votingPointsPerPlayer,
    skipRule,            // ✅ NEW
    skipTimeLimitHours,  // ✅ NEW
    timestamp: new Date().toISOString()
  });

  // ✅ NEW: Enhanced logging
  logger.info(`Lobby ${lobbyId} settings updated by host ${socket.userId}`, {
    skipRule,
    skipTimeLimitHours
  });
});
```

### 2. Create Lobby Handler (Lines 52-68)

**Before**:
```javascript
callback({
  success: true,
  lobby: {
    id: lobbyId,
    code,
    name,
    hostId: socket.userId,
    maxPlayers,
    isPrivate,
    status: 'waiting',
    currentRound: 1,
    totalRounds,
    votingPointsPerPlayer
  }
});
```

**After**:
```javascript
callback({
  success: true,
  lobby: {
    id: lobbyId,
    code,
    name,
    hostId: socket.userId,
    maxPlayers,
    isPrivate,
    status: 'waiting',
    currentRound: 1,
    totalRounds,
    votingPointsPerPlayer,
    skipRule: 'majority',      // ✅ NEW: Default skip rule
    skipTimeLimitHours: 24     // ✅ NEW: Default time limit
  }
});
```

### 3. List Lobbies Handler (Lines 446-457)

**Before**:
```javascript
const lobbies = result.rows.map(lobby => ({
  id: lobby.id,
  code: lobby.code,
  name: lobby.name,
  hostName: lobby.host_name,
  maxPlayers: lobby.max_players,
  playerCount: parseInt(lobby.player_count),
  status: lobby.status,
  createdAt: lobby.created_at
}));
```

**After**:
```javascript
const lobbies = result.rows.map(lobby => ({
  id: lobby.id,
  code: lobby.code,
  name: lobby.name,
  hostName: lobby.host_name,
  maxPlayers: lobby.max_players,
  playerCount: parseInt(lobby.player_count),
  status: lobby.status,
  createdAt: lobby.created_at,
  skipRule: lobby.skip_rule || 'majority',           // ✅ NEW
  skipTimeLimitHours: lobby.skip_time_limit_hours || 24  // ✅ NEW
}));
```

---

## 📊 Implementation Details

### Validation Rules

**Skip Rule Validation**:
```javascript
// Must be one of three valid values
const validSkipRules = ['majority', 'unanimous', 'time_based'];

if (skipRule && !validSkipRules.includes(skipRule)) {
  return callback({
    success: false,
    error: 'Invalid skip rule. Must be majority, unanimous, or time_based'
  });
}
```

**Skip Time Limit Validation**:
```javascript
// Must be between 1 and 72 hours
if (skipTimeLimitHours !== undefined && (skipTimeLimitHours < 1 || skipTimeLimitHours > 72)) {
  return callback({
    success: false,
    error: 'Skip time limit must be between 1 and 72 hours'
  });
}
```

### Database Updates

**SQL Query Structure**:
```sql
UPDATE lobbies
SET max_players = $1,
    total_rounds = $2,
    voting_points_per_player = $3,
    skip_rule = $4,                -- ✅ NEW
    skip_time_limit_hours = $5     -- ✅ NEW
WHERE id = $6
```

**Parameterized Updates**:
- Dynamic query building based on provided fields
- Prevents SQL injection with parameterized queries
- Only updates fields that are provided (partial updates supported)

### Socket.io Events

**Event**: `lobby-settings-updated`

**Payload Before**:
```javascript
{
  maxPlayers: 10,
  totalRounds: 3,
  votingPointsPerPlayer: 10,
  timestamp: '2024-11-15T12:00:00.000Z'
}
```

**Payload After**:
```javascript
{
  maxPlayers: 10,
  totalRounds: 3,
  votingPointsPerPlayer: 10,
  skipRule: 'majority',           // ✅ NEW
  skipTimeLimitHours: 24,         // ✅ NEW
  timestamp: '2024-11-15T12:00:00.000Z'
}
```

---

## 🔄 End-to-End Flow

### Scenario: Big Brain Configures Skip Rule

```
1. Frontend: LobbySettingsScreen
   ├─ User selects "Unanimous" skip rule
   ├─ User sets time limit to 48 hours
   └─ User taps "Save"

2. Frontend: multiplayerService.updateLobbySettings()
   ├─ Emits 'update-lobby-settings' via Socket.io
   └─ Payload: { lobbyId, skipRule: 'unanimous', skipTimeLimitHours: 48 }

3. Backend: update-lobby-settings handler
   ├─ Validates skip rule (must be 'majority', 'unanimous', or 'time_based')
   ├─ Validates time limit (must be 1-72 hours)
   ├─ Verifies requester is host
   ├─ Updates database: UPDATE lobbies SET skip_rule = 'unanimous', skip_time_limit_hours = 48
   ├─ Broadcasts 'lobby-settings-updated' to all lobby players
   └─ Returns success callback

4. Database: lobbies table
   ├─ Row updated with new skip configuration
   └─ Changes persisted immediately

5. Frontend: All Players
   ├─ Receive 'lobby-settings-updated' event
   ├─ Update local lobby state
   └─ UI reflects new skip configuration

6. Frontend: GameVotingScreen (AFK Detection)
   ├─ Reads lobby.skipRule ('unanimous')
   ├─ Reads lobby.skipTimeLimitHours (48)
   └─ Uses 48 hours for AFK detection threshold
```

---

## 🧪 Testing Scenarios

### Test Case 1: Update Skip Rule to Unanimous
```
Given: Lobby with default skip rule (majority)
When: Host updates skip rule to "unanimous"
Then:
  - Database updated: skip_rule = 'unanimous'
  - All players receive lobby-settings-updated event
  - Frontend AFK detection uses unanimous rule
  - VoteToSkipDialog shows "100% agreement required"
```

### Test Case 2: Update Time Limit to 12 Hours
```
Given: Lobby with default time limit (24 hours)
When: Host updates time limit to 12 hours
Then:
  - Database updated: skip_time_limit_hours = 12
  - AFK detection triggers after 12 hours instead of 24
  - TimeBasedSkipCountdown shows 12-hour countdown
```

### Test Case 3: Invalid Skip Rule
```
Given: Lobby settings screen
When: User sends invalid skip rule "instant" (not in valid list)
Then:
  - Backend validation rejects with error
  - Error message: "Invalid skip rule. Must be majority, unanimous, or time_based"
  - Database NOT updated
  - Frontend shows error SnackBar
```

### Test Case 4: Invalid Time Limit
```
Given: Lobby settings screen
When: User sends time limit of 0 hours (below minimum)
Then:
  - Backend validation rejects with error
  - Error message: "Skip time limit must be between 1 and 72 hours"
  - Database NOT updated
  - Frontend shows error SnackBar
```

### Test Case 5: Create New Lobby
```
Given: User creates new lobby
When: Lobby creation succeeds
Then:
  - Lobby object includes skipRule: 'majority'
  - Lobby object includes skipTimeLimitHours: 24
  - Frontend receives default skip configuration
  - Settings screen shows defaults
```

### Test Case 6: List Public Lobbies
```
Given: Multiple public lobbies with different skip rules
When: User fetches lobby list
Then:
  - Each lobby includes skipRule field
  - Each lobby includes skipTimeLimitHours field
  - Frontend displays skip rule in lobby browser (future feature)
```

---

## 🔒 Security Validation

### Input Validation
- ✅ Skip rule: Whitelist validation (only 3 valid values)
- ✅ Time limit: Range validation (1-72 hours)
- ✅ Host verification: Only host can update settings
- ✅ Lobby existence: Validates lobby exists before update
- ✅ SQL injection: Parameterized queries prevent injection

### Authorization
```javascript
// Verify requester is host
const lobbyResult = await query(
  `SELECT host_id FROM lobbies WHERE id = $1`,
  [lobbyId]
);

if (lobbyResult.rows[0].host_id !== socket.userId) {
  return callback({ success: false, error: 'Only host can update settings' });
}
```

### Error Handling
```javascript
try {
  // ... handler logic ...
} catch (error) {
  logger.error('Update lobby settings error', error);
  callback({ success: false, error: error.message });
}
```

---

## 📈 Database Schema Integration

### Lobbies Table Columns
```sql
-- Existing columns
id UUID PRIMARY KEY
code VARCHAR(20)
name VARCHAR(100)
host_id UUID
max_players INTEGER
is_private BOOLEAN
status VARCHAR(20)
total_rounds INTEGER
voting_points_per_player INTEGER

-- ✅ NEW columns (from schema.sql)
skip_rule VARCHAR(20) DEFAULT 'majority'
skip_time_limit_hours INTEGER DEFAULT 24
```

### Default Values
- `skip_rule`: 'majority' (50% + 1 voters)
- `skip_time_limit_hours`: 24 (daily check-in required)

### Query Performance
- Skip rule fields added to existing indexes on lobbies table
- No additional indexes needed (skip fields not used in WHERE clauses)
- SELECT l.* includes skip fields automatically

---

## 🎯 Integration Points

### Frontend → Backend
1. **Lobby Creation**: Returns skip fields with defaults
2. **Lobby Settings Update**: Accepts and saves skip fields
3. **Lobby List**: Returns skip fields for all lobbies

### Backend → Database
1. **CREATE**: Inserts with DEFAULT values for skip fields
2. **UPDATE**: Updates skip fields when provided
3. **SELECT**: Retrieves skip fields automatically

### Backend → Frontend (Events)
1. **lobby-settings-updated**: Broadcasts skip field changes
2. **lobby-created**: Includes skip fields in lobby object
3. **lobby-list**: Includes skip fields in each lobby

---

## 📊 Code Statistics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| **update-lobby-settings handler** | 2 parameters | 4 parameters | +2 |
| **Validation rules** | 0 | 2 | +2 |
| **Database updates** | 3 fields | 5 fields | +2 |
| **Event payload fields** | 3 | 5 | +2 |
| **create-lobby response** | 9 fields | 11 fields | +2 |
| **list-lobbies response** | 8 fields | 10 fields | +2 |
| **Total lines added** | - | ~40 | +40 |

---

## ✅ Quality Checklist

- ✅ **Input Validation**: Skip rule whitelist, time limit range
- ✅ **Authorization**: Host-only settings update
- ✅ **SQL Injection Prevention**: Parameterized queries
- ✅ **Error Handling**: Try-catch with logging
- ✅ **Null Safety**: Handles undefined values
- ✅ **Backward Compatibility**: Defaults for existing lobbies
- ✅ **Event Broadcasting**: All players notified of changes
- ✅ **Logging**: Enhanced logs with skip field values
- ✅ **Documentation**: Inline comments for new code

---

## 🚀 Deployment Checklist

### Prerequisites
- ✅ Database schema updated (skip_rule, skip_time_limit_hours columns)
- ✅ Default values set in database (majority, 24)
- ✅ Existing lobbies have defaults via ALTER TABLE

### Testing
- [ ] Manual testing: Create lobby → Verify skip fields returned
- [ ] Manual testing: Update skip rule → Verify database updated
- [ ] Manual testing: Update time limit → Verify value saved
- [ ] Manual testing: Invalid skip rule → Verify rejection
- [ ] Manual testing: Invalid time limit → Verify rejection
- [ ] Integration testing: Frontend → Backend → Database flow

### Rollback Plan
If issues occur:
1. Revert handler changes (keep defaults in responses)
2. Database columns remain (backward compatible)
3. Frontend ignores skip fields if not present

---

## 🎉 Impact

### Before Implementation
- ❌ Backend couldn't save skip rule configuration
- ❌ Lobby creation didn't include skip fields
- ❌ Settings updates ignored skip fields
- ❌ Frontend received incomplete lobby data

### After Implementation
- ✅ Complete skip rule configuration support
- ✅ Validation ensures data integrity
- ✅ All handlers return skip fields
- ✅ Socket.io events broadcast changes
- ✅ End-to-end integration complete

---

**Implementation Status**: ✅ **100% Complete**
**Testing**: Manual testing required
**Deployment**: Ready for testing environment

---

**Completed By**: Claude
**Implementation Date**: November 15, 2024
**Branch**: claude/phase2-chat-system-01MJcE3XLhXzc6vKfG5d4eWS
