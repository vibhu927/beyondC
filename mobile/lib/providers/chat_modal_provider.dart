import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/chat_modal_repository.dart';
import '../data/services/api_service.dart';
import 'auth_provider.dart';

enum ChatModalTab {
  collabs,
  requests,
  events,
}

class ChatModalState {
  const ChatModalState({
    this.collabs = const <CollabChat>[],
    this.requests = const <ChatModalRequest>[],
    this.eventInvites = const <ChatModalEventInvite>[],
    this.searchQuery = '',
    this.openCollabId,
  });

  final List<CollabChat> collabs;
  final List<ChatModalRequest> requests;
  final List<ChatModalEventInvite> eventInvites;
  final String searchQuery;
  final String? openCollabId;

  List<CollabChat> get filteredCollabs {
    if (searchQuery.trim().isEmpty) return collabs;
    final query = searchQuery.toLowerCase();
    return collabs.where((item) {
      return item.otherPartyName.toLowerCase().contains(query) ||
          item.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  List<ChatModalRequest> get filteredRequests {
    if (searchQuery.trim().isEmpty) return requests;
    final query = searchQuery.toLowerCase();
    return requests.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query) ||
          item.collabType.toLowerCase().contains(query);
    }).toList();
  }

  List<ChatModalEventInvite> get filteredEvents {
    if (searchQuery.trim().isEmpty) return eventInvites;
    final query = searchQuery.toLowerCase();
    return eventInvites.where((item) {
      return item.eventName.toLowerCase().contains(query) ||
          item.brandName.toLowerCase().contains(query) ||
          item.status.toLowerCase().contains(query);
    }).toList();
  }

  int get unreadCount {
    return collabs.fold<int>(0, (sum, item) => sum + item.unreadCount);
  }

  ChatModalState copyWith({
    List<CollabChat>? collabs,
    List<ChatModalRequest>? requests,
    List<ChatModalEventInvite>? eventInvites,
    String? searchQuery,
    Object? openCollabId = _sentinel,
  }) {
    return ChatModalState(
      collabs: collabs ?? this.collabs,
      requests: requests ?? this.requests,
      eventInvites: eventInvites ?? this.eventInvites,
      searchQuery: searchQuery ?? this.searchQuery,
      openCollabId: identical(openCollabId, _sentinel)
          ? this.openCollabId
          : openCollabId as String?,
    );
  }
}

class ChatModalNotifier extends AsyncNotifier<ChatModalState> {
  final Map<String, StreamSubscription<dynamic>> _messageSubscriptions =
      <String, StreamSubscription<dynamic>>{};

  ChatModalRepository get _repo => ref.read(chatModalRepositoryProvider);

  @override
  Future<ChatModalState> build() async {
    ref.onDispose(() {
      for (final subscription in _messageSubscriptions.values) {
        subscription.cancel();
      }
      _messageSubscriptions.clear();
    });

    final auth = ref.watch(authProvider);
    final role = auth.role;
    final userId = auth.user?.id;

    if (role == null || userId == null) {
      return const ChatModalState();
    }

    final results = await Future.wait<dynamic>([
      _repo.getCollabChats(role: role, currentUserId: userId),
      _repo.getRequests(role: role),
      _repo.getEventInvites(role: role),
    ]);

    final next = ChatModalState(
      collabs: results[0] as List<CollabChat>,
      requests: results[1] as List<ChatModalRequest>,
      eventInvites: results[2] as List<ChatModalEventInvite>,
    );

    _resubscribeToMessages(next.collabs.map((item) => item.collabId));
    return next;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void setSearchQuery(String query) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(searchQuery: query));
  }

  void setOpenCollabId(String? collabId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(openCollabId: collabId));
  }

  Future<void> handleRequestAction({
    required String requestId,
    required String action,
  }) async {
    final auth = ref.read(authProvider);
    final role = auth.role;
    if (role == null) return;

    await _repo.respondToRequest(
      role: role,
      requestId: requestId,
      action: action,
    );

    await refresh();
  }

  Future<void> cancelRequest(String requestId) async {
    await _repo.cancelRequest(requestId);
    await refresh();
  }

  Future<void> handleEventAction({
    required String inviteId,
    required String action,
  }) async {
    final auth = ref.read(authProvider);
    final role = auth.role;
    if (role == null) return;

    await _repo.respondToEventInvite(
      role: role,
      inviteId: inviteId,
      action: action,
    );

    await refresh();
  }

  void _resubscribeToMessages(Iterable<String> collabIds) {
    final desired = collabIds.where((id) => id.trim().isNotEmpty).toSet();

    final stale = _messageSubscriptions.keys
        .where((id) => !desired.contains(id))
        .toList(growable: false);

    for (final collabId in stale) {
      _messageSubscriptions.remove(collabId)?.cancel();
    }

    final auth = ref.read(authProvider);
    final userId = auth.user?.id;
    if (userId == null) return;

    for (final collabId in desired) {
      if (_messageSubscriptions.containsKey(collabId)) continue;

      final stream = Supabase.instance.client
          .from('messages')
          .stream(primaryKey: const ['id']).eq('collab_id', collabId);

      _messageSubscriptions[collabId] = stream.listen((dynamic rows) {
        if (rows is! List) return;

        final normalized = rows
            .whereType<Map>()
            .map((entry) =>
                entry.map((key, value) => MapEntry(key.toString(), value)))
            .toList()
          ..sort((a, b) {
            final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '');
            final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '');
            return (bTime ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(aTime ?? DateTime.fromMillisecondsSinceEpoch(0));
          });

        final latest = normalized.isEmpty ? null : normalized.first;
        final unread = normalized.where((message) {
          final senderId = message['sender_id']?.toString() ?? '';
          final isRead = message['is_read'] == true;
          final collabOpen =
              state.valueOrNull?.openCollabId != null && state.valueOrNull?.openCollabId == collabId;
          return senderId != userId && !isRead && !collabOpen;
        }).length;

        final current = state.valueOrNull;
        if (current == null) return;

        final updated = current.collabs.map((item) {
          if (item.collabId != collabId) return item;
          return item.copyWith(
            lastMessage: latest?['content']?.toString() ?? item.lastMessage,
            lastMessageTime:
                DateTime.tryParse(latest?['created_at']?.toString() ?? ''),
            unreadCount: unread,
          );
        }).toList();

        state = AsyncData(current.copyWith(collabs: updated));
      });
    }
  }
}

final chatModalRepositoryProvider = Provider<ChatModalRepository>((ref) {
  return ChatModalRepository(ref.read(apiServiceProvider));
});

final chatModalProvider = AsyncNotifierProvider<ChatModalNotifier, ChatModalState>(
  ChatModalNotifier.new,
);

final chatModalUnreadCountProvider = Provider<int>((ref) {
  final value = ref.watch(chatModalProvider).valueOrNull;
  return value?.unreadCount ?? 0;
});

const _sentinel = Object();
