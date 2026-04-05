import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/multiplayer_service.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  final String lobbyId;
  final String currentUserId;
  final MultiplayerService multiplayerService;

  const ChatScreen({
    Key? key,
    required this.lobbyId,
    required this.currentUserId,
    required this.multiplayerService,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final MultiplayerService _multiplayerService;
  final List<ChatMessage> _messages = [];
  final List<EmojiReaction> _reactions = [];
  final ScrollController _scrollController = ScrollController();
  final Set<String> _typingUserIds = {};
  late final void Function(dynamic) _chatMessageListener;
  late final void Function(dynamic) _typingListener;
  late final void Function(dynamic) _reactionListener;

  @override
  void initState() {
    super.initState();
    _multiplayerService = widget.multiplayerService;

    _chatMessageListener = (data) {
      _handleChatMessage(ChatMessage.fromJson(data));
    };
    _typingListener = (data) {
      final userId = data['userId'] as String?;
      final isTyping = data['isTyping'] as bool?;
      if (userId != null && isTyping != null) {
        _handleTypingStatus(userId, isTyping);
      }
    };
    _reactionListener = (data) {
      _handleReaction(EmojiReaction.fromJson(Map<String, dynamic>.from(data as Map)));
    };

    _multiplayerService.on('chat-message', _chatMessageListener);
    _multiplayerService.on('player-typing', _typingListener);
    _multiplayerService.on('emoji-reaction', _reactionListener);
    _loadHistory();
  }

  @override
  void dispose() {
    _multiplayerService.off('chat-message', _chatMessageListener);
    _multiplayerService.off('player-typing', _typingListener);
    _multiplayerService.off('emoji-reaction', _reactionListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final messages = await _multiplayerService.fetchChatHistory(
        lobbyId: widget.lobbyId,
      );
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chat history: $error')),
      );
    }
  }

  void _handleChatMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _handleReaction(EmojiReaction reaction) {
    setState(() {
      _reactions.insert(0, reaction);
      if (_reactions.length > 12) {
        _reactions.removeLast();
      }
      _messages.add(
        ChatMessage(
          id: 'reaction_${reaction.id}',
          senderId: reaction.userId,
          senderName: reaction.displayName,
          message: '',
          timestamp: reaction.timestamp,
          emoji: reaction.emoji,
        ),
      );
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

  Future<void> _sendMessage(String message) async {
    try {
      await _multiplayerService.sendMessage(message);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    }
  }

  void _onTypingStatusChanged(bool isTyping) {
    _multiplayerService.sendTypingIndicator(isTyping);
  }

  Future<void> _sendReaction(String emoji) async {
    try {
      await _multiplayerService.sendReaction('lobby_reaction', emoji);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reaction: $error')),
      );
    }
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
          EmojiReactionsList(reactions: _reactions),
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
            onSendReaction: _sendReaction,
          ),
        ],
      ),
    );
  }
}
