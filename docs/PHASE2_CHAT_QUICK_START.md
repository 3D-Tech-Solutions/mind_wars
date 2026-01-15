# Phase 2 Chat Implementation - Quick Start Guide

## For Developers Starting Phase 2 Work

This guide helps you get up to speed on the chat infrastructure and begin implementing the missing pieces.

---

## 30-Minute Overview

### What's Already Done (Don't Duplicate)
- Backend Socket.io chat event handler
- Multiplayer service methods (sendMessage, sendReaction)
- Chat message model
- Typing indicator widget
- Socket.io server configuration

### What You Need to Build
- Chat UI components (input field, message list, bubbles)
- Integration in lobby screen
- Database tables for persistence
- Production profanity filter

---

## Day 1: Understanding the Existing Code

### Morning (2 hours)
1. **Read the analysis documents**
   - PHASE2_CHAT_INFRASTRUCTURE_ANALYSIS.md (30 min)
   - CHAT_INFRASTRUCTURE_QUICK_REFERENCE.md (15 min)

2. **Review backend chat handler** (45 min)
   ```bash
   cd /home/user/mind-wars
   cat backend/multiplayer-server/src/handlers/chatHandlers.js
   ```
   Key points:
   - Socket event: `socket.on('chat-message', callback)`
   - Validation: empty message check, 500 char limit
   - User verification: `SELECT FROM lobby_players`
   - Broadcasting: `io.to('lobby:${lobbyId}').emit()`
   - Profanity filter: `profanityFilter(message)` ← NEEDS UPGRADE

3. **Review multiplayer service** (30 min)
   ```bash
   cat lib/services/multiplayer_service.dart | grep -A 15 "sendMessage\|sendReaction\|sendTypingIndicator"
   ```
   Key methods:
   - `void sendMessage(String message)`
   - `void sendReaction(String messageId, String emoji)`
   - `void sendTypingIndicator(bool isTyping)`

### Afternoon (2 hours)
1. **Review chat model** (30 min)
   ```bash
   cat lib/models/models.dart | sed -n '312,347p'
   ```
   Class: ChatMessage with id, senderId, senderName, message, timestamp, emoji

2. **Review typing indicator widget** (30 min)
   ```bash
   cat lib/widgets/player_presence_widget.dart | sed -n '118,189p'
   ```
   Reference implementation for animations

3. **Review Socket.io event setup** (30 min)
   ```bash
   grep -n "on('chat-message\|on('emoji-reaction\|on('player-typing" lib/services/multiplayer_service.dart
   ```
   All event listeners are already registered

4. **Review current lobby screen** (30 min)
   ```bash
   grep -n "chat\|typing\|message" lib/screens/lobby_screen.dart -i
   ```
   Currently shows only typing indicator in player list

---

## Day 2-3: Backend Foundation

### Database Schema (4 hours)

1. **Add to `/backend/database/schema.sql`**:

```sql
-- Chat messages table
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    filtered_message TEXT,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    flagged_for_review BOOLEAN DEFAULT false,
    flagged_reason VARCHAR(255)
);

CREATE INDEX idx_chat_messages_lobby_id ON chat_messages(lobby_id);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp DESC);
CREATE INDEX idx_chat_messages_flagged ON chat_messages(flagged_for_review);

-- Emoji reactions table
CREATE TABLE IF NOT EXISTS emoji_reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    emoji VARCHAR(20) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_emoji_reactions_lobby_id ON emoji_reactions(lobby_id);
CREATE INDEX idx_emoji_reactions_timestamp ON emoji_reactions(timestamp DESC);
```

2. **Run migration**:
```bash
cd backend
npm run migrate
```

### Production Profanity Filter (6 hours)

1. **Install dependency**:
```bash
cd backend/multiplayer-server
npm install better-profanity
```

2. **Create `/backend/multiplayer-server/src/utils/profanityFilter.js`**:

```javascript
const BadWords = require('bad-words');

class ProfanityFilterService {
  constructor() {
    this.filter = new BadWords();
    // Add custom words if needed
    // this.filter.addWords(...customWords);
  }

  filter(message) {
    if (this.filter.isProfane(message)) {
      return {
        filtered: this.filter.clean(message),
        hasProfanity: true,
        originalLength: message.length,
      };
    }
    return {
      filtered: message,
      hasProfanity: false,
      originalLength: message.length,
    };
  }

  isProfane(message) {
    return this.filter.isProfane(message);
  }
}

module.exports = new ProfanityFilterService();
```

3. **Update chatHandlers.js** to use new service:

```javascript
const profanityFilterService = require('../utils/profanityFilter');

// In socket.on('chat-message', async (data, callback) => {
const filterResult = profanityFilterService.filter(message);
const filteredMessage = filterResult.filtered;

// Save to database:
await query(
  `INSERT INTO chat_messages (lobby_id, user_id, message, filtered_message, timestamp)
   VALUES ($1, $2, $3, $4, NOW())`,
  [lobbyId, socket.userId, message, filteredMessage]
);

// Optional: flag suspicious content
if (filterResult.hasProfanity) {
  await query(
    `UPDATE chat_messages SET flagged_for_review = true WHERE id = $1`,
    [messageId]
  );
}
```

---

## Day 4-5: Frontend UI Components

### Create Chat Widgets (8 hours)

1. **Create `/lib/widgets/chat_widgets.dart`**:

```dart
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Individual chat message widget
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

/// Chat message list view
class ChatListView extends StatefulWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final ScrollController? scrollController;

  const ChatListView({
    Key? key,
    required this.messages,
    required this.currentUserId,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  void didUpdateWidget(ChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to bottom when new messages arrive
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController?.animateTo(
          widget.scrollController!.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start chatting!',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        return ChatMessageBubble(
          message: message,
          isCurrentUser: message.senderId == widget.currentUserId,
        );
      },
    );
  }
}

/// Chat input field
class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(bool) onTypingStatusChanged;

  const ChatInputField({
    Key? key,
    required this.onSendMessage,
    required this.onTypingStatusChanged,
  }) : super(key: key);

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late TextEditingController _controller;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final newIsTyping = text.isNotEmpty;
    if (newIsTyping != _isTyping) {
      setState(() => _isTyping = newIsTyping);
      widget.onTypingStatusChanged(newIsTyping);
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty && message.length <= 500) {
      widget.onSendMessage(message);
      _controller.clear();
      setState(() => _isTyping = false);
      widget.onTypingStatusChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              maxLength: 500,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _isTyping ? _sendMessage : null,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
```

2. **Integrate into LobbyScreen** (`lib/screens/lobby_screen.dart`):

Add to state class:
```dart
final List<ChatMessage> _messages = [];
late ScrollController _chatScrollController;
final TextEditingController _messageController = TextEditingController();

@override
void initState() {
  super.initState();
  _chatScrollController = ScrollController();
  _setupChatListeners();
}

void _setupChatListeners() {
  widget.multiplayerService.on('chat-message', (data) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(
        id: data['id'],
        senderId: data['userId'],
        senderName: data['displayName'],
        message: data['message'],
        timestamp: DateTime.parse(data['timestamp']),
      ));
    });
  });
}

void _sendMessage(String message) {
  widget.multiplayerService.sendMessage(message);
  widget.multiplayerService.sendTypingIndicator(false);
}
```

Add to build() - Chat section in body:
```dart
// Add to Column children (after lobby info card):
Expanded(
  flex: 1,
  child: Card(
    margin: const EdgeInsets.all(8),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: const Text(
            'Chat',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ChatListView(
            messages: _messages,
            currentUserId: widget.currentUserId,
            scrollController: _chatScrollController,
          ),
        ),
        ChatInputField(
          onSendMessage: _sendMessage,
          onTypingStatusChanged: (isTyping) {
            widget.multiplayerService.sendTypingIndicator(isTyping);
          },
        ),
      ],
    ),
  ),
),
```

---

## Day 6-7: Testing & Polish

### Test Cases to Implement

```dart
// Unit tests for profanity filter
test('Filter removes profanity', () {
  final result = profanityFilterService.filter('badword here');
  expect(result.hasProfanity, true);
  expect(result.filtered.contains('badword'), false);
});

// Integration tests
test('Message is broadcast to lobby', () async {
  // Setup
  // Send message via sendMessage()
  // Listen for 'chat-message' event
  // Verify message received
});

// Widget tests
testWidgets('ChatInputField sends message', (WidgetTester tester) async {
  // Build widget
  // Type message
  // Tap send button
  // Verify callback called
});
```

### Performance Checks

- [ ] Chat history loads in <1 second (100 messages)
- [ ] Message send latency <200ms
- [ ] Typing indicator shows <300ms after user starts typing
- [ ] UI remains responsive with 50+ messages
- [ ] Memory usage stays <50MB in chat

---

## Deployment Checklist

Before marking Phase 2 Chat as complete:

- [ ] Database migrations applied
- [ ] Profanity filter tested with variations (leetspeak, unicode)
- [ ] All Socket.io events tested
- [ ] Chat UI integrated in lobby screen
- [ ] Message persistence working
- [ ] Emoji reactions functional
- [ ] Typing indicators show/hide correctly
- [ ] Network error handling tested
- [ ] Rate limiting (if implemented) tested
- [ ] Security review completed

---

## Common Gotchas

1. **Message IDs**: Use `Date.now().toString()` on backend, not UUID (for sorting)
2. **Timestamp consistency**: Store in UTC, format in local time in UI
3. **Socket rooms**: Messages only sent to `io.to('lobby:${lobbyId}').emit()`
4. **Profanity context**: Some words are OK in certain contexts (e.g., "Scunthorpe problem")
5. **Emoji encoding**: Use Unicode escape sequences, not emoji directly
6. **Message order**: Sort by timestamp, not insertion order
7. **Database indexes**: Critical for chat history queries

---

## References

- Full analysis: `PHASE2_CHAT_INFRASTRUCTURE_ANALYSIS.md`
- Quick ref: `CHAT_INFRASTRUCTURE_QUICK_REFERENCE.md`
- Backend chat: `/backend/multiplayer-server/src/handlers/chatHandlers.js`
- Multiplayer service: `/lib/services/multiplayer_service.dart`
- Typing indicator: `/lib/widgets/player_presence_widget.dart` (lines 118-189)

---

## Time Estimate

- Day 1: Understanding code (4 hours) ✓
- Day 2-3: Backend database & filter (10 hours)
- Day 4-5: Frontend UI components (16 hours)
- Day 6-7: Testing & polish (16 hours)
- **Total: 46 hours (6 days at 8 hrs/day) = ~1.5 weeks**

Aligns with 18 story points estimate (3 pts/day).

