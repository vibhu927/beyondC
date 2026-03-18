import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/message_repository.dart';
import '../data/services/api_service.dart';
import 'auth_provider.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(ref.read(apiServiceProvider));
});

class ChatState {
  const ChatState({
    required this.messages,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Message> messages;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  ChatState copyWith({
    List<Message>? messages,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ChatNotifier extends FamilyAsyncNotifier<ChatState, String> {
  StreamSubscription<dynamic>? _messagesSubscription;

  @override
  Future<ChatState> build(String collabId) async {
    final page =
        await ref.read(messageRepositoryProvider).getMessages(collabId);

    _subscribe(collabId);

    ref.onDispose(() {
      _messagesSubscription?.cancel();
    });

    return ChatState(
      messages: page.items,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Chat not loaded.');
    }

    final auth = ref.read(authProvider);
    final senderId = auth.user?.id ?? '';
    final senderRole = auth.role ?? 'creator';
    final tempId = 'pending-${DateTime.now().microsecondsSinceEpoch}';

    final optimistic = Message(
      id: tempId,
      collabId: arg,
      senderId: senderId,
      senderRole: senderRole,
      content: trimmed,
      createdAt: DateTime.now(),
      isPending: true,
    );

    state = AsyncData(
      current.copyWith(messages: [optimistic, ...current.messages]),
    );

    try {
      final sent =
          await ref.read(messageRepositoryProvider).sendMessage(arg, trimmed);
      final latest = state.valueOrNull ?? current;

      final updated = latest.messages
          .map((message) => message.id == tempId ? sent : message)
          .toList();

      state = AsyncData(latest.copyWith(messages: updated));
    } catch (_) {
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        latest.copyWith(
          messages:
              latest.messages.where((message) => message.id != tempId).toList(),
        ),
      );
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.page + 1;
      final result = await ref.read(messageRepositoryProvider).getMessages(
            arg,
            page: nextPage,
          );

      final existingIds = current.messages.map((message) => message.id).toSet();
      final older =
          result.items.where((item) => !existingIds.contains(item.id));

      state = AsyncData(
        current.copyWith(
          messages: [...current.messages, ...older],
          page: result.page,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  void _subscribe(String collabId) {
    _messagesSubscription?.cancel();

    final stream = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: const ['id']).eq('collab_id', collabId);

    _messagesSubscription = stream.listen((dynamic rows) {
      if (rows is! List) return;

      final incoming = rows
          .whereType<Map>()
          .map((entry) =>
              entry.map((key, value) => MapEntry(key.toString(), value)))
          .map((item) => Message.fromApi(item, fallbackCollabId: collabId))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final current = state.valueOrNull;
      if (current == null) {
        state = AsyncData(
          ChatState(
            messages: incoming,
            page: 1,
            hasMore: false,
          ),
        );
        return;
      }

      final merged = _mergeMessages(current.messages, incoming);
      state = AsyncData(current.copyWith(messages: merged));
    });
  }

  List<Message> _mergeMessages(List<Message> existing, List<Message> incoming) {
    final mergedById = <String, Message>{
      for (final message in existing) message.id: message,
    };

    for (final message in incoming) {
      mergedById[message.id] = message;
    }

    final merged = mergedById.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return merged;
  }
}

final chatProvider =
    AsyncNotifierProviderFamily<ChatNotifier, ChatState, String>(
  ChatNotifier.new,
);
