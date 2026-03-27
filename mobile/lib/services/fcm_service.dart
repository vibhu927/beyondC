import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/router/router_holder.dart';
import '../core/router/route_names.dart';
import '../main.dart';
import '../providers/chat_modal_provider.dart';
import '../providers/notification_provider.dart';

enum PendingNavigationType {
  openChatDrawer,
  openChatRequests,
}

class PendingNavigation {
  const PendingNavigation({
    required this.type,
    this.collabId,
  });

  final PendingNavigationType type;
  final String? collabId;
}

final pendingNavigationProvider =
    StateProvider<PendingNavigation?>((ref) => null);

class FCMService {
  FCMService._internal();

  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize(Ref ref) async {
    if (_initialized) return;
    if (!isFirebaseConfigured) return;

    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);

      final token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }

      _fcm.onTokenRefresh.listen(_saveTokenToSupabase);

      await _initLocalNotifications(ref);

      FirebaseMessaging.onMessage.listen((message) {
        _showLocalNotification(message);
        ref.invalidate(notificationProvider);
        ref.invalidate(chatModalProvider);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleNotificationTap(message, ref);
      });

      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage, ref);
      }

      _initialized = true;
    } catch (_) {
      // Skip push setup on devices/environments without valid Firebase config.
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client
        .from('profiles')
        .update({'fcm_token': token}).eq('id', userId);
  }

  Future<void> _initLocalNotifications(Ref ref) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _localNotif.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload == null || payload.isEmpty) return;
        final decoded = jsonDecode(payload);
        if (decoded is! Map<String, dynamic>) return;

        final type = decoded['type']?.toString();
        final collabId = decoded['collab_id']?.toString();
        if (type == 'new_message' && collabId != null && collabId.isNotEmpty) {
          ref.read(pendingNavigationProvider.notifier).state = PendingNavigation(
                type: PendingNavigationType.openChatDrawer,
                collabId: collabId,
              );
        }
      },
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'beyondc_channel',
          'BeyondC Notifications',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFFC8FF00),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(RemoteMessage message, Ref ref) {
    final data = message.data;
    final type = data['type']?.toString();
    final collabId = data['collab_id']?.toString();
    final eventId = data['event_id']?.toString() ?? data['reference_id']?.toString();

    if (type == null) return;

    switch (type) {
      case 'new_message':
        if (collabId != null && collabId.isNotEmpty) {
          ref.read(pendingNavigationProvider.notifier).state = PendingNavigation(
                type: PendingNavigationType.openChatDrawer,
                collabId: collabId,
              );
        }
        break;
      case 'request_received':
        ref.read(pendingNavigationProvider.notifier).state =
            const PendingNavigation(type: PendingNavigationType.openChatRequests);
        break;
      case 'bid_accepted':
      case 'collab_matched':
        if (collabId != null && collabId.isNotEmpty) {
          _pushRoute(RouteNames.collabDetail.replaceFirst(':id', collabId));
        }
        break;
      case 'bid_received':
        _pushRoute(RouteNames.myBids);
        break;
      case 'event_invite':
        _pushRoute(RouteNames.myTickets);
        break;
      case 'invite_accepted':
        if (eventId != null && eventId.isNotEmpty) {
          _pushRoute(RouteNames.eventInvites.replaceFirst(':id', eventId));
        }
        break;
      default:
        break;
    }
  }

  void _pushRoute(String route) {
    if (route.isEmpty) return;
    RouterHolder.router?.push(route);
  }
}
