import 'package:dio/dio.dart';

import '../../core/utils/api_error_handler.dart';
import '../services/api_service.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.referenceType,
    this.referenceId,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? referenceType;
  final String? referenceId;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    String? referenceType,
    String? referenceId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  factory AppNotification.fromApi(Map<String, dynamic> raw) {
    return AppNotification(
      id: _string(raw['id']) ?? 'note-${DateTime.now().microsecondsSinceEpoch}',
      userId: _string(raw['user_id']) ?? '',
      type: _string(raw['type']) ?? 'generic',
      title: _string(raw['title']) ?? 'Notification',
      body: _string(raw['body']) ?? _string(raw['message']) ?? '',
      isRead: _bool(raw['is_read']) ?? (_string(raw['status']) == 'read'),
      createdAt:
          DateTime.tryParse(_string(raw['created_at']) ?? '') ?? DateTime.now(),
      referenceType: _string(raw['reference_type']),
      referenceId: _string(raw['reference_id']),
    );
  }
}

class NotificationRepository {
  NotificationRepository(this._apiService);

  final ApiService _apiService;

  Dio get _dio => _apiService.client;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final root = _asMap(response.data);

      final notificationsRaw = _extractNotifications(root);

      final notifications = notificationsRaw
          .map(AppNotification.fromApi)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  List<Map<String, dynamic>> _extractNotifications(Map<String, dynamic> root) {
    final fromNotifications = _asMapList(root['notifications']);
    if (fromNotifications.isNotEmpty) return fromNotifications;

    final fromItems = _asMapList(root['items']);
    if (fromItems.isNotEmpty) return fromItems;

    return const <Map<String, dynamic>>[];
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.map(_asMap).toList();
  }
}

String? _string(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString();
  return parsed.isEmpty ? null : parsed;
}

bool? _bool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return null;
}
