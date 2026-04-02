import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/message.dart';
import 'auth_provider.dart';
import 'chat_provider.dart';

class InAppNotificationState {
  const InAppNotificationState({
    this.isVisible = false,
    this.message,
    this.chatTitle,
    this.collabId,
  });

  final bool isVisible;
  final Message? message;
  final String? chatTitle;
  final String? collabId;
}

class InAppNotificationNotifier extends Notifier<InAppNotificationState> {
  Timer? _timer;
  String? _currentOpenCollabId;

  @override
  InAppNotificationState build() {
    ref.onDispose(() => _timer?.cancel());
    return const InAppNotificationState();
  }

  void setCurrentChat(String? collabId) {
    _currentOpenCollabId = collabId;
  }

  void show(Message message) {
    final currentUserId = ref.read(authProvider).user?.id;
    if (message.senderId == currentUserId) return;
    if (_currentOpenCollabId == message.collabId) return;

    final chatsState = ref.read(chatListProvider).valueOrNull;
    final allChats = [
      ...(chatsState?.active ?? const []),
      ...(chatsState?.archived ?? const []),
    ];

    String? title;
    for (final chat in allChats) {
      if (chat.id == message.collabId) {
        title = chat.otherPartyName;
        break;
      }
    }

    _timer?.cancel();
    state = InAppNotificationState(
      isVisible: true,
      message: message,
      chatTitle: title ?? 'New message',
      collabId: message.collabId,
    );

    _timer = Timer(const Duration(seconds: 4), hide);
  }

  void hide() {
    _timer?.cancel();
    state = const InAppNotificationState(isVisible: false);
  }
}

final inAppNotificationProvider =
    NotifierProvider<InAppNotificationNotifier, InAppNotificationState>(
  InAppNotificationNotifier.new,
);
