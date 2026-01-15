# Chat Infrastructure - Quick Reference Guide

## Key Files Reference

### Backend (Node.js/JavaScript)

| File | Purpose | Status | Notes |
|------|---------|--------|-------|
| `/backend/multiplayer-server/src/handlers/chatHandlers.js` | Chat event handlers | ✅ COMPLETE | Implements `chat-message` and `emoji-reaction` events |
| `/backend/multiplayer-server/src/index.js` | Server setup | ✅ COMPLETE | Registers all event handlers including chat |
| `/backend/database/schema.sql` | Database schema | ⚠️ PARTIAL | Missing `chat_messages` and `emoji_reactions` tables |
| `/backend/multiplayer-server/src/utils/profanityFilter.js` | Profanity filtering | ❌ MISSING | Needs creation - currently stub in chatHandlers.js |

### Frontend (Flutter/Dart)

| File | Purpose | Status | Notes |
|------|---------|--------|-------|
| `/lib/models/models.dart` | Chat models | ✅ COMPLETE | `ChatMessage` class defined (lines 312-347) |
| `/lib/services/multiplayer_service.dart` | Multiplayer service | ✅ COMPLETE | Has `sendMessage()`, `sendReaction()`, `sendTypingIndicator()` methods |
| `/lib/widgets/player_presence_widget.dart` | Presence indicators | ✅ PARTIAL | Has `TypingIndicator` widget |
| `/lib/screens/lobby_screen.dart` | Lobby UI | ⚠️ PARTIAL | Handles typing indicators but no chat UI |
| `/lib/widgets/chat_widgets.dart` | Chat UI components | ❌ MISSING | Needs creation - no chat bubbles, input, list |

### Configuration Files

| File | Purpose | Notes |
|------|---------|-------|
| `pubspec.yaml` | Flutter dependencies | socket_io_client ^2.0.3 already included |
| `backend/multiplayer-server/package.json` | Node dependencies | socket.io ^4.6.2 already included |

---

## Current Implementation Status

### Working Features ✅
- Socket.io server with JWT authentication
- Real-time chat message broadcasting
- Message validation (empty, 500 char limit)
- User verification (player in lobby check)
- Emoji reaction system with allowlist (8 emojis)
- Typing indicators
- Player presence tracking
- Server-side logging

### Partial Features ⚠️
- Chat models exist but not used in UI
- Typing indicator widget exists but integration minimal
- Message event listeners set up

### Missing Features ❌
- Chat UI components (input, message list, bubbles)
- Chat message list in lobby screen
- Emoji picker UI
- Database persistence for chat messages
- Database persistence for emoji reactions
- Production profanity filter
- Rate limiting on messages
- Message moderation/flagging
- Chat history retrieval
- Game-screen chat integration

---

## Architecture Overview

### Real-Time Communication Stack
```
Frontend (Flutter)
  ↓
socket_io_client (WebSocket)
  ↓
Node.js Socket.io Server (Port 3001)
  ↓
Event Handlers (chatHandlers.js)
  ↓
PostgreSQL (optional persistence)
```

### Chat Message Flow
1. User types message in UI
2. `sendMessage()` called in MultiplayerService
3. Message emitted via Socket.io to server
4. Server validates (user in lobby, message not empty, <500 chars)
5. Server applies profanity filter
6. Message broadcast to all users in lobby via `io.to('lobby:${id}').emit()`
7. All clients receive 'chat-message' event
8. UI updates with new message

### Typing Indicator Flow
1. User starts typing
2. `sendTypingIndicator(true)` called
3. Event sent to server
4. Server broadcasts to lobby
5. Other clients receive 'player-typing' event
6. UI shows "username is typing..." with animation

---

## Database Schema (MISSING)

### Required Additions

```sql
-- Chat messages persistence
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id),
    user_id UUID NOT NULL REFERENCES users(id),
    message TEXT NOT NULL,
    filtered_message TEXT,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    flagged_for_review BOOLEAN DEFAULT false
);

-- Emoji reactions persistence
CREATE TABLE emoji_reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id),
    user_id UUID NOT NULL REFERENCES users(id),
    emoji VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);
```

---

## Socket.io Events

### Client → Server
- `chat-message`: `{ lobbyId, message }`
- `emoji-reaction`: `{ lobbyId, emoji }`
- `typing-indicator`: `{ lobbyId, isTyping }`

### Server → Client
- `chat-message`: `{ id, userId, displayName, avatarUrl, message, timestamp }`
- `emoji-reaction`: `{ userId, displayName, emoji, timestamp }`
- `player-typing`: `{ playerId, isTyping }`

---

## Profanity Filter Status

### Current (STUB)
```javascript
const profanityFilter = (message) => {
  const badWords = ['badword1', 'badword2']; // Only 2 examples!
  // Basic regex replacement
};
```

### Recommended Production Implementation
```javascript
const BadWords = require('bad-words');
const filter = new BadWords();

// Handles variations, leetspeak, unicode, etc.
const profanityFilter = (message) => {
  if (filter.isProfane(message)) {
    logger.warn(`Profanity detected: ${message}`);
    return filter.clean(message);
  }
  return message;
};
```

### Installation
```bash
cd backend/multiplayer-server
npm install better-profanity
```

---

## Phase 2 Implementation Checklist

### Backend Tasks
- [ ] Add database schema for chat messages
- [ ] Add database schema for emoji reactions
- [ ] Implement production profanity filter
- [ ] Update chatHandlers.js to save messages to DB
- [ ] Add message retrieval API
- [ ] Add rate limiting middleware
- [ ] Add message logging for moderation

### Frontend Tasks
- [ ] Create ChatMessage widget
- [ ] Create ChatListView widget
- [ ] Create ChatInputField widget
- [ ] Create EmojiPickerButton widget
- [ ] Integrate chat into LobbyScreen
- [ ] Add message animations
- [ ] Add emoji animations
- [ ] Handle connection/disconnection
- [ ] Add loading states
- [ ] Add error handling

### Testing Tasks
- [ ] Unit tests for profanity filter
- [ ] Integration tests for chat flow
- [ ] Load testing (concurrent messages)
- [ ] Unicode/emoji testing
- [ ] Network error handling tests
- [ ] UI responsiveness tests

---

## Key Methods Reference

### MultiplayerService (Dart)
```dart
// Send a message
void sendMessage(String message)

// Send emoji reaction
void sendReaction(String messageId, String emoji)

// Send typing indicator
void sendTypingIndicator(bool isTyping)

// Subscribe to chat events
void on(String event, Function callback)
  // Events: 'chat-message', 'emoji-reaction', 'player-typing'

// Unsubscribe from events
void off(String event, Function callback)
```

### ChatHandlers (JavaScript)
```javascript
// Events registered on socket connection:
// socket.on('chat-message', callback)
// socket.on('emoji-reaction', callback)

// Methods called from event handler:
// io.to(`lobby:${lobbyId}`).emit('chat-message', data)
// logger.info/error(message, data)
```

---

## Common Issues & Solutions

### Issue: Messages not appearing in UI
**Solutions**:
- Check MultiplayerService is connected
- Verify event listener registered with `on('chat-message', ...)`
- Check message is being emitted from server
- Verify lobby ID matches current lobby

### Issue: Profanity not being filtered
**Solutions**:
- Check profanityFilter function is called
- Verify bad words list is comprehensive
- Test with actual profanity (current list only has examples)
- Need to implement better-profanity library

### Issue: Typing indicator not showing
**Solutions**:
- Check sendTypingIndicator is called on text input
- Verify 'player-typing' event listener is registered
- Check typing timeout is handled

### Issue: Emoji reactions not working
**Solutions**:
- Verify emoji is in allowedEmojis list
- Check emoji-reaction event listener registered
- Verify emoji encoding (use Unicode)

---

## Performance Considerations

### Bottlenecks
- Chat history loading (need pagination)
- Profanity filter on every message (needs caching)
- Message broadcasting to large lobbies
- Emoji animations on multiple reactions

### Optimization Strategies
1. Paginate message history (load 50 at a time)
2. Cache profanity filter results
3. Batch emoji reactions
4. Debounce typing indicator (send every 1s)
5. Lazy load avatars
6. Limit message history in memory

---

## Testing Strategy

### Unit Tests
- Profanity filter variations
- Message validation logic
- Timestamp formatting
- Emoji validation

### Integration Tests
- Socket.io connection
- Message send/receive
- Event broadcasting
- Typing indicators
- Error handling

### Manual Testing
- Cross-lobby message isolation
- Rapid message sending
- Special characters & emoji
- Network disconnection
- Multiple users in lobby

---

## Recommended Phase 2 Effort Estimate

| Component | Points | Duration |
|-----------|--------|----------|
| Database schema | 2 | 1-2 days |
| Profanity filter | 3 | 2-3 days |
| Chat UI components | 5 | 3-4 days |
| Lobby integration | 2 | 1-2 days |
| Emoji UI | 3 | 2-3 days |
| Testing & Polish | 3 | 2-3 days |
| **TOTAL** | **18** | **11-18 days** |

(Original Phase 2 estimate was 13 pts for chat + 8 pts for emoji = 21 pts)

---

## Resources & References

- [Socket.io Documentation](https://socket.io/docs/)
- [Flutter Socket.io Client](https://pub.dev/packages/socket_io_client)
- [better-profanity NPM](https://www.npmjs.com/package/better-profanity)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Flutter Material Design](https://flutter.dev/docs/development/ui/widgets)

