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
    final userId = _string(raw['user_id']) ?? '';
    final type = _string(raw['type']) ?? 'generic';
    final title = _string(raw['title']) ?? 'Notification';
    final body = _string(raw['body']) ?? _string(raw['message']) ?? '';
    final createdAtRaw = _string(raw['created_at']) ?? '';
    final referenceType = _string(raw['reference_type']);
    final referenceId = _string(raw['reference_id']);

    final resolvedId = _string(raw['id']) ??
        _string(raw['notification_id']) ??
        _string(raw['notificationId']) ??
        _buildStableFallbackId(
          userId: userId,
          type: type,
          title: title,
          body: body,
          createdAtRaw: createdAtRaw,
          referenceType: referenceType,
          referenceId: referenceId,
        );

    return AppNotification(
      id: resolvedId,
      userId: userId,
      type: type,
      title: title,
      body: body,
      isRead: _bool(raw['is_read']) ??
          _bool(raw['read']) ??
          (_string(raw['status']) == 'read'),
      createdAt: DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
      referenceType: referenceType,
      referenceId: referenceId,
    );
  }
}

String _buildStableFallbackId({
  required String userId,
  required String type,
  required String title,
  required String body,
  required String createdAtRaw,
  String? referenceType,
  String? referenceId,
}) {
  return [
    'note',
    userId,
    type,
    createdAtRaw,
    referenceType ?? '',
    referenceId ?? '',
    title,
    body,
  ].join('|');
}

class NotificationRepository {
  NotificationRepository(this._apiService);

  final ApiService _apiService;

  Dio get _dio => _apiService.client;

  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
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
      await _dio.put('/notifications/$notificationId');
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
