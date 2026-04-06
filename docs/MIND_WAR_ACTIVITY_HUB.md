---
name: Mind War Activity Hub (Chat + Events)
description: Architecture for unified activity feed combining player chat messages and game/admin system events
type: project
---

# Mind War Activity Hub Architecture

## Overview

The **Activity Hub** is the central social/information hub for each Mind War. It unifies three types of messages in a single, chronological feed:

1. **Player Messages** — Team chat, banter, coordination ("Emma: you got lucky!")
2. **Game Events** — Completions, high scores, personal records ("🎮 Emma finished Logic Duel - 2:14 • Personal best! • 2nd place")
3. **System Events** — Admin changes, mind war lifecycle, player joins ("⚙️ Dad updated max_games_per_round: 3 → 5")

**Key Properties:**
- Scoped to a single Mind War (messages don't cross lobbies)
- Persists as long as the Mind War exists; deleted when Mind War is deleted
- Accessible from any game screen via a chat icon
- Notifications configurable per player
- Activity feed remains read-only after Mind War ends

---

## Message Types & Schemas

### 1. Player Message

```javascript
{
  type: "player_message",
  mind_war_id: "abc123",
  timestamp: "2026-04-06T14:32:45Z",
  player_id: "user_456",
  display_name: "Emma",
  content: "haha you got me this time",
  id: "msg_xyz789"
}
```

**UI Display:**
```
Emma: haha you got me this time
```

---

### 2. Game Event

```javascript
{
  type: "game_event",
  subtype: "game_completed",
  mind_war_id: "abc123",
  timestamp: "2026-04-06T14:32:15Z",
  player_id: "user_456",
  display_name: "Emma",
  game_name: "Logic Duel",
  score: 2140,
  time_taken: "2:14",
  rank: 2,
  total_players: 5,
  newPersonalBest: true,
  id: "evt_abc123"
}
```

**UI Display (Styled Box):**
```
🎮 Emma finished Logic Duel - 2:14 • Personal best! 🔥 • 2nd place
```

**Formatting Logic:**
```dart
String formatGameEvent(GameEventMessage msg) {
  final rank = msg.rank == 1 
    ? "🥇 1st place" 
    : "🥈 2nd place" 
    : "🥉 3rd place"
    : "${msg.rank.ordinal} place";
  
  final pb = msg.newPersonalBest ? "• Personal best! 🔥" : "";
  
  return "🎮 ${msg.displayName} finished ${msg.gameName} - ${msg.timeTaken} $pb • $rank";
}
```

---

### 3. System Event - Admin Setting Changed

```javascript
{
  type: "system_event",
  subtype: "admin_setting_changed",
  mind_war_id: "abc123",
  timestamp: "2026-04-06T14:20:00Z",
  admin_id: "user_123",
  admin_name: "Dad",
  setting_name: "max_games_per_round",
  old_value: 3,
  new_value: 5,
  id: "evt_def456"
}
```

**UI Display (Subtle, Gray Box):**
```
⚙️ Dad updated max_games_per_round: 3 → 5
```

---

### 3b. System Event - Player Joined

```javascript
{
  type: "system_event",
  subtype: "player_joined",
  mind_war_id: "abc123",
  timestamp: "2026-04-06T14:05:00Z",
  player_id: "user_789",
  player_name: "Sarah",
  id: "evt_ghi789"
}
```

**UI Display:**
```
➕ Sarah joined the mind war
```

---

### 3c. System Event - Mind War Started

```javascript
{
  type: "system_event",
  subtype: "mind_war_started",
  mind_war_id: "abc123",
  timestamp: "2026-04-06T14:00:00Z",
  round_number: 1,
  players: ["Emma", "David", "Sarah"],
  id: "evt_jkl012"
}
```

**UI Display:**
```
🚀 Mind War Round 1 started! Players: Emma, David, Sarah
```

---

### 3d. System Event - Mind War Ended

```javascript
{
  type: "system_event",
  subtype: "mind_war_ended",
  mind_war_id: "abc123",
  timestamp: "2026-04-06T18:45:00Z",
  winner_id: "user_456",
  winner_name: "Emma",
  final_scores: { "user_456": 15000, "user_789": 14200 },
  id: "evt_mno345"
}
```

**UI Display:**
```
🏆 Mind War ended! Winner: Emma with 15,000 points
```

---

## Frontend Architecture

### 1. ChatProvider (State Management)

Manages all activity hub state and Socket.io subscriptions.

```dart
class ChatProvider extends ChangeNotifier {
  // Messages per mind war
  final Map<String, List<ChatMessage>> _messages = {};
  
  // Unread counts per mind war
  final Map<String, int> _unreadCounts = {};
  
  // Notification preferences
  late NotificationPreferences notificationPrefs;
  
  // Socket.io subscription for current mind war
  String? _activeSubscription;
  
  // Get all messages for a mind war (chronological)
  List<ChatMessage> getMessages(String mindWarId) 
    => _messages[mindWarId] ?? [];
  
  // Add a message (from WebSocket)
  void addMessage(String mindWarId, ChatMessage msg) {
    _messages.putIfAbsent(mindWarId, () => []).add(msg);
    _updateUnreadCount(mindWarId);
    notifyListeners();
  }
  
  // Send a player message
  Future<void> sendMessage({
    required String mindWarId,
    required String content,
  }) async {
    // Emit to backend
    multiplayerService.emit('chat:message', {
      'mind_war_id': mindWarId,
      'content': content,
    });
  }
  
  // Subscribe to a mind war's chat
  void subscribeToChatForMindWar(String mindWarId) {
    _activeSubscription = mindWarId;
    multiplayerService.on('chat:message', (data) {
      final msg = ChatMessage.fromJson(data);
      addMessage(mindWarId, msg);
    });
  }
  
  // Unsubscribe
  void unsubscribeFromChat() {
    if (_activeSubscription != null) {
      multiplayerService.off('chat:message');
      _activeSubscription = null;
    }
  }
  
  // Notification preferences
  Future<void> updateNotificationPreferences(NotificationPreferences prefs) async {
    notificationPrefs = prefs;
    // Save to user profile
    await apiService.updateUserPreferences(prefs);
    notifyListeners();
  }
  
  // Check if should notify for this event
  bool shouldNotify(ChatMessage msg) {
    if (notificationPrefs.muteDuringHours && _isInQuietHours()) {
      return false;
    }
    
    switch (msg.type) {
      case 'player_message':
        return notificationPrefs.notifyOnChatMessage;
      case 'game_event':
        return notificationPrefs.notifyOnGameCompletion;
      case 'system_event':
        if (msg.subtype == 'admin_setting_changed') {
          return notificationPrefs.notifyOnAdminChanges;
        }
        if (msg.subtype == 'player_joined') {
          return notificationPrefs.notifyOnPlayerJoined;
        }
        break;
    }
    return true;
  }
}
```

---

### 2. ChatIconButton (Reusable Widget)

Top-right icon, appears on all game/lobby screens.

```dart
class ChatIconButton extends StatelessWidget {
  final String mindWarId;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final unreadCount = chatProvider.getUnreadCount(mindWarId);
        
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.chat_bubble, size: 28),
              onPressed: () => _openChatSheet(context),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    '$unreadCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  void _openChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChatSheet(mindWarId: mindWarId),
    );
  }
}
```

---

### 3. ChatSheet (Modal Bottom Sheet)

```dart
class ChatSheet extends StatefulWidget {
  final String mindWarId;
  
  @override
  State<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<ChatSheet> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Subscribe to chat for this mind war
    context.read<ChatProvider>().subscribeToChatForMindWar(widget.mindWarId);
    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
  
  @override
  void dispose() {
    context.read<ChatProvider>().unsubscribeFromChat();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text('Mind War Activity'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              final messages = chatProvider.getMessages(widget.mindWarId);
              
              return ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _buildMessage(msg);
                },
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }
  
  Widget _buildMessage(ChatMessage msg) {
    if (msg.type == 'player_message') {
      return _buildPlayerMessage(msg);
    } else if (msg.type == 'game_event') {
      return _buildGameEvent(msg);
    } else if (msg.type == 'system_event') {
      return _buildSystemEvent(msg);
    }
    return SizedBox.shrink();
  }
  
  Widget _buildPlayerMessage(ChatMessage msg) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${msg.displayName}:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(msg.content, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
  
  Widget _buildGameEvent(ChatMessage msg) {
    final color = msg.rank == 1 ? Colors.amber.shade100 : Colors.blue.shade50;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          msg.formatAsGameEvent(),
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
        ),
      ),
    );
  }
  
  Widget _buildSystemEvent(ChatMessage msg) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          msg.formatAsSystemEvent(),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
  
  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    
    context.read<ChatProvider>().sendMessage(
      mindWarId: widget.mindWarId,
      content: content,
    );
    
    _messageController.clear();
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
```

---

### 4. ChatMessage Model (Updated)

```dart
class ChatMessage {
  final String id;
  final String type;  // 'player_message', 'game_event', 'system_event'
  final String? subtype;  // For system_event: 'admin_setting_changed', 'player_joined', etc.
  final String mindWarId;
  final DateTime timestamp;
  final String playerId;
  final String displayName;
  
  // For player messages
  final String? content;
  
  // For game events
  final String? gameName;
  final int? score;
  final String? timeTaken;
  final int? rank;
  final int? totalPlayers;
  final bool newPersonalBest;
  
  // For system events
  final String? adminId;
  final String? adminName;
  final String? settingName;
  final dynamic oldValue;
  final dynamic newValue;
  final List<String>? playerNames;
  
  ChatMessage({
    required this.id,
    required this.type,
    this.subtype,
    required this.mindWarId,
    required this.timestamp,
    required this.playerId,
    required this.displayName,
    this.content,
    this.gameName,
    this.score,
    this.timeTaken,
    this.rank,
    this.totalPlayers,
    this.newPersonalBest = false,
    this.adminId,
    this.adminName,
    this.settingName,
    this.oldValue,
    this.newValue,
    this.playerNames,
  });
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      type: json['type'],
      subtype: json['subtype'],
      mindWarId: json['mind_war_id'],
      timestamp: DateTime.parse(json['timestamp']),
      playerId: json['player_id'],
      displayName: json['display_name'],
      content: json['content'],
      gameName: json['game_name'],
      score: json['score'],
      timeTaken: json['time_taken'],
      rank: json['rank'],
      totalPlayers: json['total_players'],
      newPersonalBest: json['newPersonalBest'] ?? false,
      adminId: json['admin_id'],
      adminName: json['admin_name'],
      settingName: json['setting_name'],
      oldValue: json['old_value'],
      newValue: json['new_value'],
      playerNames: List<String>.from(json['players'] ?? []),
    );
  }
  
  String formatAsGameEvent() {
    if (type != 'game_event') return '';
    
    final rankStr = rank == 1
      ? "🥇 1st place"
      : rank == 2
      ? "🥈 2nd place"
      : rank == 3
      ? "🥉 3rd place"
      : "🎯 ${rank.ordinal} place";
    
    final pb = newPersonalBest ? "• Personal best! 🔥" : "";
    
    return "🎮 $displayName finished $gameName - $timeTaken $pb • $rankStr";
  }
  
  String formatAsSystemEvent() {
    if (type != 'system_event') return '';
    
    switch (subtype) {
      case 'admin_setting_changed':
        return "⚙️ $adminName updated $settingName: $oldValue → $newValue";
      case 'player_joined':
        return "➕ $displayName joined the mind war";
      case 'mind_war_started':
        return "🚀 Mind War Round 1 started! Players: ${playerNames?.join(', ')}";
      case 'mind_war_ended':
        return "🏆 Mind War ended! Winner: $displayName";
      default:
        return "";
    }
  }
}
```

---

### 5. NotificationPreferences Model

```dart
class NotificationPreferences {
  bool notifyOnGameCompletion = true;
  bool notifyOnAdminChanges = true;
  bool notifyOnPlayerJoined = false;
  bool notifyOnChatMessage = true;
  
  bool muteDuringHours = true;
  String muteStart = "22:00";  // 10 PM
  String muteEnd = "08:00";    // 8 AM
  
  Map<String, dynamic> toJson() => {
    'notify_on_game_completion': notifyOnGameCompletion,
    'notify_on_admin_changes': notifyOnAdminChanges,
    'notify_on_player_joined': notifyOnPlayerJoined,
    'notify_on_chat_message': notifyOnChatMessage,
    'mute_during_hours': muteDuringHours,
    'mute_start': muteStart,
    'mute_end': muteEnd,
  };
  
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences()
      ..notifyOnGameCompletion = json['notify_on_game_completion'] ?? true
      ..notifyOnAdminChanges = json['notify_on_admin_changes'] ?? true
      ..notifyOnPlayerJoined = json['notify_on_player_joined'] ?? false
      ..notifyOnChatMessage = json['notify_on_chat_message'] ?? true
      ..muteDuringHours = json['mute_during_hours'] ?? true
      ..muteStart = json['mute_start'] ?? "22:00"
      ..muteEnd = json['mute_end'] ?? "08:00";
  }
}
```

---

## Backend Integration

### 1. Game Completion → Chat Event

In `gameHandlers.js`:

```javascript
const handleGameCompletion = async (io, playerId, gameId, score, mindWarId) => {
  // Save score to database
  await saveGameScore(playerId, gameId, score, mindWarId);
  
  // Get rank info
  const { rank, newPersonalBest } = await getRankInfo(playerId, gameId, mindWarId);
  const displayName = await getDisplayName(playerId);
  const gameName = getGameName(gameId);
  
  // Emit to chat channel for this mind war
  io.to(`mindwar:${mindWarId}`).emit('chat:message', {
    type: 'game_event',
    subtype: 'game_completed',
    mind_war_id: mindWarId,
    timestamp: new Date().toISOString(),
    player_id: playerId,
    display_name: displayName,
    game_name: gameName,
    score: score,
    rank: rank,
    newPersonalBest: newPersonalBest,
  });
};
```

### 2. Admin Changes → Chat Event

In `lobbyHandlers.js`:

```javascript
const updateMindWarSettings = async (io, mindWarId, adminId, newSettings) => {
  const oldSettings = await getMindWarSettings(mindWarId);
  
  // Update in DB
  await saveMindWarSettings(mindWarId, newSettings);
  
  const adminName = await getDisplayName(adminId);
  
  // Emit event for each changed setting
  for (const [key, newValue] of Object.entries(newSettings)) {
    const oldValue = oldSettings[key];
    if (oldValue !== newValue) {
      io.to(`mindwar:${mindWarId}`).emit('chat:message', {
        type: 'system_event',
        subtype: 'admin_setting_changed',
        mind_war_id: mindWarId,
        timestamp: new Date().toISOString(),
        admin_id: adminId,
        admin_name: adminName,
        setting_name: key,
        old_value: oldValue,
        new_value: newValue,
      });
    }
  }
};
```

### 3. Player Message Handling

In `chatHandlers.js` (already exists, just re-scope to mind war):

```javascript
socket.on('chat:message', async (data) => {
  const { mind_war_id, content } = data;
  const playerId = socket.userId;
  
  // Validate
  if (!content.trim() || content.length > 500) return;
  
  // Get player info
  const displayName = await getDisplayName(playerId);
  
  // Emit to mind war room
  io.to(`mindwar:${mind_war_id}`).emit('chat:message', {
    type: 'player_message',
    mind_war_id: mind_war_id,
    timestamp: new Date().toISOString(),
    player_id: playerId,
    display_name: displayName,
    content: content.trim(),
  });
  
  // Persist to database (optional, for history)
  await saveChatMessage(mind_war_id, playerId, content);
});
```

---

## Integration Points (Phase 1)

```
lib/
├── providers/
│   ├── chat_provider.dart              ← NEW
│   └── notification_provider.dart      ← NEW
├── widgets/
│   ├── chat_icon_button.dart           ← NEW
│   └── chat_sheet.dart                 ← NEW
├── screens/
│   ├── game_screen.dart                ← UPDATE: add ChatIconButton
│   ├── lobby_screen.dart               ← UPDATE: add ChatIconButton
│   └── profile_settings_screen.dart    ← UPDATE: add notification prefs UI
└── models/
    ├── chat_message.dart               ← UPDATE: add formatting methods
    └── notification_preferences.dart   ← NEW

backend/multiplayer-server/src/handlers/
├── chatHandlers.js                     ← UPDATE: re-scope to mind war
├── gameHandlers.js                     ← UPDATE: emit game events
└── lobbyHandlers.js                    ← UPDATE: emit admin events
```

---

## Phase 1 Implementation Tasks

**Week 1 (Backend Foundation):**
- [ ] Update chatHandlers.js to emit player messages to `mindwar:{id}` room
- [ ] Add game_event emission to gameHandlers.js (game completion)
- [ ] Add system_event emission to lobbyHandlers.js (admin setting changes)

**Week 1-2 (Frontend UI):**
- [ ] Create ChatProvider with state management
- [ ] Create ChatMessage model with formatting methods
- [ ] Create NotificationPreferences model
- [ ] Create ChatIconButton widget
- [ ] Create ChatSheet modal with message list + input
- [ ] Add ChatIconButton to game_screen.dart
- [ ] Add ChatIconButton to lobby_screen.dart

**Week 2 (Polish + Testing):**
- [ ] Notification preferences in profile settings
- [ ] Auto-scroll to latest message
- [ ] Unread count tracking
- [ ] Test with real family group (multi-device)

---

## Success Criteria

- ✅ Players can send/receive chat messages in real-time
- ✅ Game completions appear as styled events in the feed
- ✅ Admin setting changes appear as system events
- ✅ Chat accessible from any game screen via icon
- ✅ Messages persist for the lifetime of the Mind War
- ✅ Notification preferences configurable per player
- ✅ Unread badge shows on chat icon
- ✅ Works with 2+ concurrent players
- ✅ Family group tested for 3+ game rounds

---

## Related Documentation

- **CHAT_SYSTEM_DOCUMENTATION_INDEX.md** — Existing chat infrastructure analysis
- **CHAT_INFRASTRUCTURE_QUICK_REFERENCE.md** — Quick reference for chat implementation
- **system_architecture.md** — Overall Mind Wars architecture

