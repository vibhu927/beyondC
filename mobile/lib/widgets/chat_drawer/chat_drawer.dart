import 'package:flutter/material.dart';

import '../../features/shared/screens/chat_screen.dart';

void openChatDrawer(BuildContext context, String collabId) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => ChatDrawer(collabId: collabId),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    ),
  );
}

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({
    super.key,
    required this.collabId,
  });

  final String collabId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 300) {
          Navigator.of(context).pop();
        }
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ChatScreen(collabId: collabId),
          ),
        ),
      ),
    );
  }
}
