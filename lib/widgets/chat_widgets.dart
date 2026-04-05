/**
 * Chat Widgets - Phase 2 Social Features
 * In-game chat UI components
 */

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Individual chat message bubble widget
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
    final isSystemMessage = message.senderId == 'system';

    if (isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

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
            if (message.message.isNotEmpty)
              Text(
                message.message,
                style: const TextStyle(fontSize: 14),
              ),
            if (message.emoji != null) ...[
              const SizedBox(height: 4),
              Text(
                message.emoji!,
                style: const TextStyle(fontSize: 22),
              ),
            ],
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
        if (widget.scrollController != null && widget.scrollController!.hasClients) {
          widget.scrollController!.animateTo(
            widget.scrollController!.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
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

/// Chat input field with typing indicator
class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(bool) onTypingStatusChanged;
  final Function(String)? onSendReaction;

  const ChatInputField({
    Key? key,
    required this.onSendMessage,
    required this.onTypingStatusChanged,
    this.onSendReaction,
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onSendReaction != null)
                  EmojiPicker(
                    onEmojiSelected: widget.onSendReaction!,
                  ),
                Row(
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
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _isTyping ? _sendMessage : null,
                      backgroundColor: _isTyping ? Theme.of(context).primaryColor : Colors.grey,
                      child: const Icon(Icons.send, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Emoji picker widget for quick reactions
class EmojiPicker extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const EmojiPicker({
    Key? key,
    required this.onEmojiSelected,
  }) : super(key: key);

  static const List<String> allowedEmojis = [
    '👍',
    '❤️',
    '😂',
    '🎉',
    '🔥',
    '👏',
    '😮',
    '🤔'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: allowedEmojis
            .map(
              (emoji) => IconButton(
                icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                onPressed: () => onEmojiSelected(emoji),
                tooltip: 'Send $emoji reaction',
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Recent emoji reactions display
class EmojiReactionsList extends StatelessWidget {
  final List<EmojiReaction> reactions;
  final int maxToShow;

  const EmojiReactionsList({
    Key? key,
    required this.reactions,
    this.maxToShow = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group reactions by emoji and count them
    final Map<String, int> emojiCounts = {};
    for (var reaction in reactions.take(maxToShow)) {
      emojiCounts[reaction.emoji] = (emojiCounts[reaction.emoji] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: emojiCounts.entries
            .map(
              (entry) => Chip(
                label: Text(
                  '${entry.key} ${entry.value > 1 ? entry.value : ''}',
                  style: const TextStyle(fontSize: 14),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Emoji reaction model
class EmojiReaction {
  final String id;
  final String userId;
  final String displayName;
  final String emoji;
  final DateTime timestamp;

  EmojiReaction({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.emoji,
    required this.timestamp,
  });

  factory EmojiReaction.fromJson(Map<String, dynamic> json) {
    return EmojiReaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      emoji: json['emoji'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
