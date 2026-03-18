import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/notification_repository.dart';
import '../data/services/api_service.dart';
import 'auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiServiceProvider));
});

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  StreamSubscription<dynamic>? _notificationSubscription;

  @override
  Future<List<AppNotification>> build() async {
    final userId = ref.watch(authProvider.select((state) => state.user?.id));
    final notifications =
        await ref.read(notificationRepositoryProvider).getNotifications();

    _subscribe(userId);
    ref.onDispose(() {
      _notificationSubscription?.cancel();
    });

    return notifications;
  }

  Future<void> fetchNotifications() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  Future<void> markRead(String notificationId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref.read(notificationRepositoryProvider).markRead(notificationId);

    state = AsyncData(
      current
          .map(
            (item) =>
                item.id == notificationId ? item.copyWith(isRead: true) : item,
          )
          .toList(),
    );
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref.read(notificationRepositoryProvider).markAllRead();

    state = AsyncData(
      current.map((item) => item.copyWith(isRead: true)).toList(),
    );
  }

  void _subscribe(String? userId) {
    _notificationSubscription?.cancel();

    if (userId == null || userId.isEmpty) {
      return;
    }

    final stream = Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: const ['id']).eq('user_id', userId);

    _notificationSubscription = stream.listen((dynamic rows) {
      if (rows is! List) return;

      final incoming = rows
          .whereType<Map>()
          .map((entry) =>
              entry.map((key, value) => MapEntry(key.toString(), value)))
          .map(AppNotification.fromApi)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncData(incoming);
    });
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
  NotificationNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider).valueOrNull;
  if (notifications == null) return 0;
  return notifications.where((item) => !item.isRead).length;
});
