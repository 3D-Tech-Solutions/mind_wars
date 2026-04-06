import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mind_wars/providers/chat_provider.dart';
import 'package:mind_wars/widgets/chat_sheet.dart';

/// Chat icon button for the Activity Hub
/// Appears in the top-right of game and lobby screens
/// Shows unread count badge
class ChatIconButton extends StatelessWidget {
  final String mindWarId;

  const ChatIconButton({
    Key? key,
    required this.mindWarId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final unreadCount = chatProvider.getUnreadCount(mindWarId);

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, size: 28),
              onPressed: () => _openChatSheet(context),
              tooltip: 'Mind War Activity',
            ),
            // Unread badge
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
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
