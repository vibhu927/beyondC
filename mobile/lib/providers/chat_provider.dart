import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/collab_chat.dart';
import '../data/models/message.dart';
import '../data/repositories/chat_repository.dart';
import 'auth_provider.dart';
import 'in_app_notification_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

class ChatListNotifier extends AsyncNotifier<ChatListResult> {
  RealtimeChannel? _channel;

  @override
  Future<ChatListResult> build() async {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final role = auth.role;

    if (user == null || role == null) {
      return const ChatListResult(active: [], archived: []);
    }

    final result = await ref.read(chatRepositoryProvider).getChats(user.id, role);

    _channel = ref.read(chatRepositoryProvider).subscribeToChatList(
      user.id,
      () => ref.invalidateSelf(),
    );

    ref.onDispose(() => _channel?.unsubscribe());
    return result;
  }

  int get totalUnread {
    final role = ref.read(authProvider).role ?? 'creator';
    final chats = state.valueOrNull?.active ?? const <CollabChat>[];
    var sum = 0;
    for (final chat in chats) {
      sum += chat.unreadForRole(role);
    }
    return sum;
  }
}

final chatListProvider = AsyncNotifierProvider<ChatListNotifier, ChatListResult>(
  ChatListNotifier.new,
);

class ChatNotifier extends FamilyAsyncNotifier<List<Message>, String> {
  RealtimeChannel? _channel;
  bool _isLoadingMore = false;
  int _page = 1;
  static const int _limit = 50;

  @override
  Future<List<Message>> build(String collabId) async {
    _page = 1;
    final messages = await ref.read(chatRepositoryProvider).getMessages(collabId, page: _page, limit: _limit);

    await _markCurrentChatAsRead(collabId);

    _channel = ref.read(chatRepositoryProvider).subscribeToMessages(
      collabId,
      (newMsg) {
        final current = state.valueOrNull ?? const <Message>[];
        final exists = current.any((m) => m.id == newMsg.id);
        if (exists) return;

        state = AsyncData([newMsg, ...current]);
        ref.read(inAppNotificationProvider.notifier).show(newMsg);

        // Keep unread counters cleared while the chat is open.
        final role = ref.read(authProvider).role;
        if (role != null && newMsg.senderRole != role) {
          ref.read(chatRepositoryProvider).markAsRead(collabId, role).then((_) {
            ref.invalidate(chatListProvider);
          });
        }

        ref.invalidate(chatListProvider);
      },
    );

    ref.onDispose(() => _channel?.unsubscribe());
    return messages;
  }

  Future<void> _markCurrentChatAsRead(String collabId) async {
    final role = ref.read(authProvider).role;
    if (role == null) return;

    await ref.read(chatRepositoryProvider).markAsRead(collabId, role);
    ref.invalidate(chatListProvider);
  }

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final role = ref.read(authProvider).role;
    final user = ref.read(authProvider).user;
    if (role == null || user == null) {
      throw StateError('Missing auth session. Please login again.');
    }

    final temp = Message(
      id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
      collabId: arg,
      senderId: user.id,
      senderRole: role,
      content: trimmed,
      isRead: false,
      createdAt: DateTime.now(),
      senderName: null,
      senderAvatar: null,
      isPending: true,
    );

    final current = state.valueOrNull ?? const <Message>[];
    state = AsyncData([temp, ...current]);

    try {
      final sent = await ref.read(chatRepositoryProvider).sendMessage(arg, trimmed, role);
      final next = (state.valueOrNull ?? const <Message>[])
          .map((m) => m.id == temp.id ? sent : m)
          .toList();
      state = AsyncData(next);
      ref.invalidate(chatListProvider);
    } catch (_) {
      final next = (state.valueOrNull ?? const <Message>[])
          .map(
            (m) => m.id == temp.id
                ? m.copyWith(isPending: false, isFailed: true)
                : m,
          )
          .toList();
      state = AsyncData(next);
      rethrow;
    }
  }

  Future<void> retryMessage(Message failedMessage) async {
    if (!failedMessage.isFailed) return;

    final current = state.valueOrNull ?? const <Message>[];
    final withoutFailed = current.where((m) => m.id != failedMessage.id).toList();
    state = AsyncData(withoutFailed);
    await sendMessage(failedMessage.content);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    final current = state.valueOrNull ?? const <Message>[];
    if (current.length < _limit * _page) return;

    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final more = await ref.read(chatRepositoryProvider).getMessages(
        arg,
        page: nextPage,
        limit: _limit,
      );
      if (more.isEmpty) return;

      final existingIds = current.map((e) => e.id).toSet();
      final filtered = more.where((m) => !existingIds.contains(m.id)).toList();
      if (filtered.isEmpty) return;

      _page = nextPage;
      state = AsyncData([...current, ...filtered]);
    } finally {
      _isLoadingMore = false;
    }
  }
}

final chatProvider = AsyncNotifierProviderFamily<ChatNotifier, List<Message>, String>(
  ChatNotifier.new,
);
