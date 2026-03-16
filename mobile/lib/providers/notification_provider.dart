import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityNotification {
  const ActivityNotification({
    required this.id,
    required this.audience,
    required this.description,
    required this.createdAt,
    required this.icon,
    required this.accentColor,
    this.isUnread = true,
  });

  final String id;
  final String audience;
  final String description;
  final DateTime createdAt;
  final IconData icon;
  final Color accentColor;
  final bool isUnread;
}

class NotificationState {
  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ActivityNotification> notifications;
  final bool isLoading;
  final String? error;

  int get unreadCount => notifications.where((item) => item.isUnread).length;

  NotificationState copyWith({
    List<ActivityNotification>? notifications,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() => const NotificationState();

  Future<void> fetchNotifications() async {
    if (state.isLoading || state.notifications.isNotEmpty) return;
    await _loadNotifications();
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    await Future<void>.delayed(const Duration(milliseconds: 800));

    state = state.copyWith(
      isLoading: false,
      notifications: [
        ActivityNotification(
          id: 'note-1',
          audience: 'brand',
          description: 'Priya S. bid on your Fitness Sprint campaign',
          createdAt: DateTime.now().subtract(const Duration(minutes: 24)),
          icon: Icons.local_fire_department_rounded,
          accentColor: const Color(0xFFFF2D78),
        ),
        ActivityNotification(
          id: 'note-2',
          audience: 'brand',
          description: 'Rahul M. accepted your creator request',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.check_circle_rounded,
          accentColor: const Color(0xFF3D5BFF),
        ),
        ActivityNotification(
          id: 'note-3',
          audience: 'brand',
          description: 'Your Beauty launch campaign got 5 new bids',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          icon: Icons.campaign_rounded,
          accentColor: const Color(0xFFC8FF00),
        ),
        ActivityNotification(
          id: 'note-4',
          audience: 'creator',
          description: 'A new campaign matching your niche just dropped',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          icon: Icons.bolt_rounded,
          accentColor: const Color(0xFF9B5DE5),
        ),
      ],
      error: null,
    );
  }
}

const _sentinel = Object();

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);
