import 'dart:async';

import 'package:flutter/foundation.dart';
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
  static const int _pageSize = 10;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  final Set<String> _baselineIds = <String>{};
  bool _baselineEstablished = false;

  final StreamController<AppNotification> _newNotificationController =
      StreamController<AppNotification>.broadcast();

  /// Emits notifications that arrive AFTER the initial baseline.
  /// The initial fetch (REST + first realtime emit) is treated as the
  /// baseline and does NOT fire any toast.
  Stream<AppNotification> get onNewNotification =>
      _newNotificationController.stream;

  @override
  Future<List<AppNotification>> build() async {
    final userId = ref.watch(authProvider.select((state) => state.user?.id));
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _baselineEstablished = false;
    _baselineIds.clear();

    final notifications =
        await ref.read(notificationRepositoryProvider).getNotifications(
              page: _currentPage,
              limit: _pageSize,
            );
    _hasMore = notifications.length >= _pageSize;

    _subscribe(userId);
    ref.onDispose(() {
      _notificationSubscription?.cancel();
      _newNotificationController.close();
    });

    return notifications;
  }

  Future<void> fetchNotifications() async {
    try {
      ref.invalidateSelf();
      await future;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Notifications] fetch failed: $error');
      }

      // Avoid bubbling an unhandled exception from fire-and-forget calls.
      if (state.valueOrNull == null) {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    final current = state.valueOrNull;
    if (current == null) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final nextItems =
          await ref.read(notificationRepositoryProvider).getNotifications(
                page: nextPage,
                limit: _pageSize,
              );

      if (nextItems.isEmpty) {
        _hasMore = false;
        return;
      }

      _currentPage = nextPage;
      _hasMore = nextItems.length >= _pageSize;

      final merged = [...current];
      final existingIds = merged.map((item) => item.id).toSet();
      for (final item in nextItems) {
        if (!existingIds.contains(item.id)) {
          merged.add(item);
        }
      }
      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _applyIncoming(merged);
    } finally {
      _isLoadingMore = false;
    }
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

      _currentPage = 1;
      _hasMore = incoming.length >= _pageSize;

      _applyIncoming(incoming);
    });
  }

  /// Applies an incoming notification list to state.
  /// - On the very first apply (baseline) all IDs are recorded silently.
  /// - On subsequent applies, only IDs that are NOT in the baseline
  ///   fire a new-notification event (toast) — this is what fixes the
  ///   "toast appears on every login" glitch.
  void _applyIncoming(List<AppNotification> incoming) {
    final isBaseline = !_baselineEstablished;
    if (isBaseline) {
      _baselineIds
        ..clear()
        ..addAll(incoming.map((item) => item.id));
      _baselineEstablished = true;
      state = AsyncData(incoming);
      return;
    }

    final current = state.valueOrNull;
    final hasMaterialChange =
        current == null || !_isSameList(current, incoming);

    if (!hasMaterialChange) return;

    final newItems = incoming
        .where((item) => !_baselineIds.contains(item.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (newItems.isNotEmpty) {
      _baselineIds.addAll(newItems.map((item) => item.id));
      // Fire only the most recent so a single toast appears at a time.
      _newNotificationController.add(newItems.first);
    }

    state = AsyncData(incoming);
  }

  bool _isSameList(List<AppNotification> a, List<AppNotification> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.id != y.id || x.isRead != y.isRead || x.createdAt != y.createdAt) {
        return false;
      }
    }

    return true;
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
