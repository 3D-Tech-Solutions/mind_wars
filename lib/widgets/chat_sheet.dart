import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_wars/models/chat_message.dart';
import 'package:mind_wars/providers/chat_provider.dart';

/// Chat sheet modal for the Activity Hub
/// Shows unified feed of player messages, game events, and system events
class ChatSheet extends StatefulWidget {
  final String mindWarId;

  const ChatSheet({
    Key? key,
    required this.mindWarId,
  }) : super(key: key);

  @override
  State<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<ChatSheet> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Subscribe to chat for this mind war
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().subscribeToChatForMindWar(widget.mindWarId);
    });
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mind War Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Messages list
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  final messages = chatProvider.getMessages(widget.mindWarId);

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No activity yet. Start playing!',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                      return _buildMessage(msg);
                    },
                  );
                },
              ),
            ),
            // Message input
            _buildMessageInput(),
          ],
        );
      },
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    switch (msg.type) {
      case 'player_message':
        return _buildPlayerMessage(msg);
      case 'game_event':
        return _buildGameEvent(msg);
      case 'system_event':
        return _buildSystemEvent(msg);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlayerMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${msg.displayName}:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg.content ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameEvent(ChatMessage msg) {
    final color = msg.rank == 1 ? Colors.amber.shade100 : Colors.blue.shade50;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          msg.formatAsGameEvent(),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildSystemEvent(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          msg.formatAsSystemEvent(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
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
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
