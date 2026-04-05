# Endpoint Verification Guide for 2-Device Testing

**Date**: 2026-04-04  
**Status**: Ready for testing

This guide provides step-by-step verification that all endpoints are working correctly during 2-device multiplayer testing.

---

## Quick Reference: What Data Each Endpoint Should Send/Receive

### PHASE 1: Auth & Registration

#### ✅ POST /api/auth/register
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "player.a@test.com",
    "password": "SecurePass123"
  }'
```

**Expected Response**:
- Status: **201 Created**
- Contains `user.username` (auto-generated from email)
- Contains `accessToken` and `refreshToken`
- User displayName is empty/null (will be set during profile setup)

**Verify in Database**:
```sql
psql -U postgres -d mind_wars -c "SELECT id, email, username, display_name FROM users WHERE email = 'player.a@test.com';"
```

Expected: username = `player_a` (or similar), display_name = empty

---

#### ✅ POST /api/auth/login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "player.a@test.com",
    "password": "SecurePass123"
  }'
```

**Expected Response**:
- Status: **200 OK**
- Contains `user.avatarChecksum` (MD5 hash for cache validation)
- Contains `user.level`, `user.totalScore`
- Contains `accessToken` and `refreshToken`

---

### PHASE 2: Lobbies

#### ✅ Socket.io 'create-lobby' (Device 1)

**What the app sends**:
```javascript
// From lib/services/multiplayer_service.dart line 58
multiplayerService.createLobby({
  name: 'Test Lobby 1',
  maxPlayers: 2,
  isPrivate: true,
  numberOfRounds: 1,
  votingPointsPerPlayer: 10,
})
```

**What backend returns** (in callback):
- `lobby.id` (UUID)
- `lobby.code` (memorable code like "SWIFTMIND42")
- `lobby.status` = "waiting"
- `lobby.playerCount` = 1 (only host)

**Verify in Database**:
```sql
psql -U postgres -d mind_wars -c "SELECT * FROM lobbies ORDER BY created_at DESC LIMIT 1;"
psql -U postgres -d mind_wars -c "SELECT COUNT(*) FROM lobby_players WHERE lobby_id = '<lobby_id>';"
```

Expected:
- 1 lobby record with `status='waiting'`
- 1 player record (host)

---

#### ✅ GET /api/lobbies (Device 2)

**What the app calls**:
```bash
curl -H "Authorization: Bearer <token>" \
  'http://localhost:3000/api/lobbies?status=waiting&page=1&limit=20'
```

**Critical: Verify PLAYER COUNT**
- Response must include `playerCount: 1` (or correct current count)
- This is calculated by: `SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id`
- **MUST NOT be hardcoded** — it needs to update in real-time

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "lobbies": [
      {
        "id": "<uuid>",
        "code": "SWIFTMIND42",
        "name": "Test Lobby 1",
        "playerCount": 1,    // ← CRITICAL: Verify this updates to 2 after join
        "maxPlayers": 2,
        "status": "waiting"
      }
    ]
  }
}
```

**Verify Player Count Updates**:
1. Before Device 2 joins: `playerCount: 1`
2. After Device 2 joins: `playerCount: 2`

If `playerCount` doesn't update, the query isn't calculating it correctly.

---

#### ✅ Socket.io 'join-lobby' (Device 2)

**What the app sends**:
```javascript
multiplayerService.joinLobby('<lobby_id>')
```

**What backend broadcasts** (to Device 1):
```json
{
  "event": "player-joined",
  "data": {
    "userId": "<player_b_uuid>",
    "displayName": "PlayerB",
    "avatarUrl": "/uploads/avatars/...",
    "level": 1,
    "timestamp": "2026-04-04T..."
  }
}
```

**Verify in Database**:
```sql
psql -U postgres -d mind_wars -c "SELECT COUNT(*) FROM lobby_players WHERE lobby_id = '<lobby_id>';"
```

Expected: **2 players**

---

### PHASE 3: Chat

#### ✅ Socket.io 'chat-message'

**What Device 1 sends**:
```javascript
multiplayerService.sendMessage('Hello from Device 1')
```

**What all devices receive** (broadcast event):
```json
{
  "event": "chat-message",
  "data": {
    "id": "<message_uuid>",
    "userId": "<player_a_uuid>",
    "displayName": "PlayerA",
    "avatarUrl": "/uploads/avatars/...",
    "message": "Hello from Device 1",
    "timestamp": "2026-04-04T..."
  }
}
```

**Verify in Database**:
```sql
psql -U postgres -d mind_wars -c "SELECT * FROM chat_messages WHERE lobby_id = '<lobby_id>' ORDER BY timestamp DESC LIMIT 5;"
```

Expected:
- All messages stored with correct userId, message text, timestamp
- `filtered_message` should match `message` (unless profanity filter applied)

---

#### ✅ Socket.io 'typing-indicator'

**What Device 1 sends** (when user starts typing):
```javascript
multiplayerService.sendTypingIndicator(true)
```

**What Device 2 receives** (broadcast as 'player-typing'):
```json
{
  "event": "player-typing",
  "data": {
    "userId": "<player_a_uuid>",
    "isTyping": true,
    "timestamp": "2026-04-04T..."
  }
}
```

**Verify**: Chat input should show "PlayerA is typing..." while typing, disappear when finished.

---

### PHASE 4: Voting

#### ✅ Socket.io 'start-voting' (Host)

**What Device 1 sends**:
```javascript
multiplayerService.startVotingSession({
  pointsPerPlayer: 10,
  totalRounds: 1,
  gamesPerRound: 1,
})
```

**What all devices receive** (broadcast):
```json
{
  "event": "voting-started",
  "data": {
    "votingId": "<voting_uuid>",
    "pointsPerPlayer": 10,
    "timestamp": "2026-04-04T..."
  }
}
```

**Verify in Database**:
```sql
psql -U postgres -d mind_wars -c "SELECT * FROM voting_sessions WHERE lobby_id = '<lobby_id>' ORDER BY started_at DESC LIMIT 1;"
```

Expected:
- 1 active voting session with `status='active'`

---

#### ✅ Socket.io 'vote-game'

**What Device 1 sends**:
```javascript
multiplayerService.voteForGame(gameId: 'memory-match', points: 5)
```

**What Device 2 receives** (broadcast as 'vote-cast'):
```json
{
  "event": "vote-cast",
  "data": {
    "userId": "<player_a_uuid>",
    "gameId": "memory-match",
    "points": 5,
    "totalVotes": 5,    // Total votes for this game across all players
    "timestamp": "2026-04-04T..."
  }
}
```

**Verify in Database**:
```sql
psql -U postgres -d mind_wars -c "SELECT * FROM votes WHERE voting_id = '<voting_id>' ORDER BY created_at;"
```

Expected:
- One vote record per game per player
- Points stored correctly

---

#### ✅ Socket.io 'end-voting' (Host)

**What Device 1 sends**:
```javascript
// Called by host when ready to start games
multiplayerService.endVotingRound()
```

**What all devices receive** (broadcast):
```json
{
  "event": "voting-ended",
  "data": {
    "votingId": "<voting_uuid>",
    "results": [
      {
        "gameId": "memory-match",
        "totalVotes": 5
      },
      {
        "gameId": "code-breaker",
        "totalVotes": 3
      }
    ],
    "timestamp": "2026-04-04T..."
  }
}
```

**Verify**: Both devices should see games sorted by total votes.

---

### PHASE 5-7: Games & Results

#### ✅ POST /api/games/:id/submit (After each game turn)

**What each device sends** (when completing a game):
```bash
curl -X POST http://localhost:3000/api/games/memory-match/submit \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "lobbyId": "<lobby_id>",
    "sessionType": "vs_friends",
    "timeTaken": 45000,
    "hintsUsed": 0,
    "perfect": true,
    "gameData": {
      "pairsFound": 5,
      "moves": 10,
      "timeTaken": 45000,
      "hintsUsed": 0
    }
  }'
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "id": "<result_uuid>",
    "validatedScore": 50,    // SERVER CALCULATED (not trusted from client)
    "originalScore": 50,
    "timeTaken": 45000,
    "hintsUsed": 0,
    "perfect": true,
    "sessionType": "vs_friends"
  }
}
```

**Critical**: `validatedScore` must be **server-calculated** from game metrics, NOT from client `score` field.

**Verify in Database**:
```sql
psql -U postgres -d mind_wars -c "SELECT * FROM game_results WHERE lobby_id = '<lobby_id>' ORDER BY created_at;"
```

Expected:
- 2 result records (one per player)
- Scores calculated server-side
- sessionType = 'vs_friends'

---

#### ✅ GET /api/games/:id/results (After both players submit)

**What the app calls**:
```bash
curl -H "Authorization: Bearer <token>" \
  'http://localhost:3000/api/games/memory-match/results?lobbyId=<lobby_id>'
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "gameId": "memory-match",
    "gameName": "Game",
    "lobbyId": "<lobby_id>",
    "results": [
      {
        "resultId": "<result_uuid>",
        "userId": "<player_a_uuid>",
        "displayName": "PlayerA",
        "avatarUrl": "/uploads/avatars/...",
        "score": 50,
        "timeTaken": 45000,
        "hintsUsed": 0,
        "perfect": true,
        "completedAt": "2026-04-04T..."
      },
      {
        "resultId": "<result_uuid>",
        "userId": "<player_b_uuid>",
        "displayName": "PlayerB",
        "avatarUrl": "/uploads/avatars/...",
        "score": 45,
        "timeTaken": 52000,
        "hintsUsed": 1,
        "perfect": false,
        "completedAt": "2026-04-04T..."
      }
    ],
    "winner": {
      "userId": "<player_a_uuid>",
      "displayName": "PlayerA",
      "score": 50
    }
  }
}
```

**Critical Checks**:
1. Results should be **sorted by score DESC** (highest first)
2. Winner should have **highest score**
3. Both players' avatars should be included
4. Timestamps should match database records

---

### PHASE 8: Leaderboards

#### ✅ GET /api/leaderboards/all-time

**What the app calls**:
```bash
curl -H "Authorization: Bearer <token>" \
  'http://localhost:3000/api/leaderboards/all-time?limit=100'
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "leaderboard": [
      {
        "rank": 1,
        "userId": "<player_a_uuid>",
        "displayName": "PlayerA",
        "avatarUrl": "/uploads/avatars/...",
        "level": 1,
        "score": 50,
        "gamesPlayed": 1,
        "averageTimeTaken": 45000
      },
      {
        "rank": 2,
        "userId": "<player_b_uuid>",
        "displayName": "PlayerB",
        "avatarUrl": "/uploads/avatars/...",
        "level": 1,
        "score": 45,
        "gamesPlayed": 1,
        "averageTimeTaken": 52000
      }
    ],
    "currentUserRank": {
      "rank": 1,
      "score": 50,
      "averageTimeTaken": 45000
    }
  }
}
```

**Critical Checks**:
1. Both players appear in leaderboard
2. Scores match game results
3. Ranking is correct (highest score first)
4. Avatar URLs are present (for cache validation)

---

## Testing Checklist

### Device 1 (Host)
- [ ] Register new account
- [ ] Verify username auto-generated in response
- [ ] Avatar checkbox displays correctly
- [ ] Create lobby
- [ ] See lobby created successfully
- [ ] See "Waiting for players..." message
- [ ] Receive "player-joined" Socket.io event when Device 2 joins
- [ ] See Device 2 in player list (2/2 players)
- [ ] Open chat, send message
- [ ] See Device 2's messages appear in real-time
- [ ] Close chat, start voting
- [ ] See voting UI with available games
- [ ] Vote for games (allocate 10 points total)
- [ ] See Device 2's vote counts update in real-time (vote-cast events)
- [ ] Complete game and submit result
- [ ] See game results with both players' scores
- [ ] Check leaderboard, see both players listed

### Device 2 (Joiner)
- [ ] Register different account
- [ ] Browse lobbies, see Device 1's lobby listed (1/2 players)
- [ ] Join lobby
- [ ] Receive "player-joined" Socket.io broadcast (your own join)
- [ ] See Device 1 in player list (2/2 players)
- [ ] Open chat
- [ ] See Device 1's messages
- [ ] Send messages, verify Device 1 receives them
- [ ] See typing indicators when Device 1 is typing
- [ ] Close chat, wait for voting to start
- [ ] See voting UI
- [ ] Vote for games
- [ ] See Device 1's vote counts update in real-time
- [ ] Complete game and submit result
- [ ] See game results showing both players
- [ ] Check leaderboard, see both players with correct scores

---

## Database Commands for Quick Verification

```bash
# After registration
psql -U postgres -d mind_wars -c "SELECT id, email, username, display_name, level, total_score FROM users ORDER BY created_at DESC LIMIT 2;"

# After lobby creation
psql -U postgres -d mind_wars -c "SELECT id, name, host_id, status, created_at FROM lobbies ORDER BY created_at DESC LIMIT 1;"

# Player count
psql -U postgres -d mind_wars -c "SELECT COUNT(*) as player_count FROM lobby_players WHERE lobby_id = '<lobby_id>';"

# Chat messages
psql -U postgres -d mind_wars -c "SELECT user_id, message, timestamp FROM chat_messages WHERE lobby_id = '<lobby_id>' ORDER BY timestamp;"

# Votes cast
psql -U postgres -d mind_wars -c "SELECT user_id, game_id, points FROM votes WHERE voting_id = '<voting_id>' ORDER BY game_id, user_id;"

# Game results
psql -U postgres -d mind_wars -c "SELECT user_id, score, time_taken, perfect FROM game_results WHERE lobby_id = '<lobby_id>' ORDER BY score DESC;"

# Leaderboard
psql -U postgres -d mind_wars -c "SELECT id, display_name, level, total_score, games_played, games_won FROM users WHERE total_score > 0 ORDER BY total_score DESC;"
```

---

## Common Issues & Debug Steps

### Issue: Player count doesn't update after join
- **Check**: `GET /api/lobbies` response
- **Verify**: Player count calculation in backend: `SELECT COUNT(*) FROM lobby_players WHERE lobby_id = $1`
- **Fix**: Ensure query is executed for each request, not cached incorrectly

### Issue: Chat messages not appearing on Device 2
- **Check**: Socket.io connection established (look for "connected" event)
- **Verify**: Both devices in same `lobby:<lobby_id>` room
- **Debug**: Check multiplayer server logs for chat-message events

### Issue: Voting updates not received
- **Check**: Voting session created (`SELECT * FROM voting_sessions`)
- **Verify**: Both players in lobby_players table
- **Debug**: Check for vote-cast Socket.io events in server logs

### Issue: Game results not showing
- **Check**: Game results saved to database (`SELECT * FROM game_results WHERE lobby_id = '<lobby_id>'`)
- **Verify**: GET /api/games/:id/results endpoint returns data
- **Ensure**: Both players submitted results before calling endpoint

### Issue: Leaderboard shows wrong scores
- **Check**: Game results have correct validated scores (not client-submitted)
- **Verify**: Users table total_score matches sum of game results
- **Fix**: Server should calculate scores from game metrics, not trust client

---

## Success Criteria

All of the following must be true for endpoints to be considered "working":

1. ✅ Authentication endpoints return correct fields (username, tokens)
2. ✅ Lobby creation returns lobby with code and correct status
3. ✅ Lobby listing shows correct player counts
4. ✅ Socket.io 'player-joined' broadcast received by host
5. ✅ Chat messages transmitted and received in real-time
6. ✅ Typing indicators broadcast to other players
7. ✅ Voting session starts and broadcasts to all players
8. ✅ Vote-cast events broadcast updated vote totals
9. ✅ Game results submitted with server-calculated scores
10. ✅ Game results retrieved with both players' data
11. ✅ Leaderboard displays both players with correct scores
12. ✅ All data in database matches what displays to users

---

## Files Modified (2026-04-04)

- ✅ `backend/multiplayer-server/src/handlers/chatHandlers.js` - Added typing-indicator handler
- ✅ `backend/api-server/src/routes/games.js` - Added GET /api/games/:id/results endpoint
- ✅ `lib/screens/chat_screen.dart` - Fixed to use on('chat-message') and on('player-typing')
- ✅ `lib/models/models.dart` - Added displayName field to Player class
- ✅ `lib/screens/lobby_screen.dart` - Updated Player constructor to include displayName

All endpoints are now implemented and ready for 2-device testing.
