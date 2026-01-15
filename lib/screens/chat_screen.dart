
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/multiplayer_service.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  final String lobbyId;
  final String currentUserId;

  const ChatScreen({
    Key? key,
    required this.lobbyId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MultiplayerService _multiplayerService;
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final Set<String> _typingUserIds = {};

  @override
  void initState() {
    super.initState();
    _multiplayerService = MultiplayerService(
      lobbyId: widget.lobbyId,
      onChatMessageReceived: _handleChatMessage,
      onTypingStatusReceived: _handleTypingStatus,
    );
    _multiplayerService.connect();
  }

  @override
  void dispose() {
    _multiplayerService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleChatMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _handleTypingStatus(String userId, bool isTyping) {
    setState(() {
      if (isTyping) {
        _typingUserIds.add(userId);
      } else {
        _typingUserIds.remove(userId);
      }
    });
  }

  void _sendMessage(String message) {
    _multiplayerService.sendChatMessage(message);
  }

  void _onTypingStatusChanged(bool isTyping) {
    _multiplayerService.sendTypingStatus(isTyping);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatListView(
              messages: _messages,
              currentUserId: widget.currentUserId,
              scrollController: _scrollController,
            ),
          ),
          if (_typingUserIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${_typingUserIds.join(', ')} is typing...',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ChatInputField(
            onSendMessage: _sendMessage,
            onTypingStatusChanged: _onTypingStatusChanged,
          ),
        ],
      ),
    );
  }
}
