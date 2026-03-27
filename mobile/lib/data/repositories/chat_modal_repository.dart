import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/api_error_handler.dart';
import '../services/api_service.dart';

class CollabChat {
  const CollabChat({
    required this.collabId,
    required this.otherPartyName,
    this.otherPartyAvatar,
    required this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  final String collabId;
  final String otherPartyName;
  final String? otherPartyAvatar;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  CollabChat copyWith({
    String? collabId,
    String? otherPartyName,
    String? otherPartyAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return CollabChat(
      collabId: collabId ?? this.collabId,
      otherPartyName: otherPartyName ?? this.otherPartyName,
      otherPartyAvatar: otherPartyAvatar ?? this.otherPartyAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ChatModalRequest {
  const ChatModalRequest({
    required this.id,
    required this.name,
    required this.tier,
    required this.budget,
    required this.collabType,
    required this.message,
    this.createdAt,
    required this.status,
    required this.isIncoming,
  });

  final String id;
  final String name;
  final String tier;
  final int budget;
  final String collabType;
  final String message;
  final DateTime? createdAt;
  final String status;
  final bool isIncoming;
}

class ChatModalEventInvite {
  const ChatModalEventInvite({
    required this.id,
    required this.eventName,
    required this.brandName,
    this.eventDate,
    required this.status,
  });

  final String id;
  final String eventName;
  final String brandName;
  final DateTime? eventDate;
  final String status;
}

class ChatModalRepository {
  ChatModalRepository(this._apiService);

  final ApiService _apiService;

  Dio get _dio => _apiService.client;

  Future<List<CollabChat>> getCollabChats({
    required String role,
    required String currentUserId,
  }) async {
    try {
      final response = await _dio.get('/$role/collabs');
      final root = _asMap(response.data);
      final collabs = _asMapList(root['collabs']);

      final items = collabs.map((row) {
        final collabId = _string(row['id']) ?? '';
        final fallbackName = role == 'creator'
            ? (_string(row['brand_name']) ?? 'Brand')
            : (_string(row['creator_name']) ?? 'Creator');

        return CollabChat(
          collabId: collabId,
          otherPartyName: _string(row['other_party_name']) ?? fallbackName,
          otherPartyAvatar: _string(row['other_party_avatar']),
          lastMessage: '',
          lastMessageTime: null,
          unreadCount: 0,
        );
      }).where((item) => item.collabId.isNotEmpty).toList();

      if (items.isEmpty) return items;
      return _enrichWithMessageState(items, currentUserId: currentUserId);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<ChatModalRequest>> getRequests({required String role}) async {
    try {
      final response = await _dio.get('/$role/requests');
      final root = _asMap(response.data);
      final requests = _asMapList(root['requests']);

      return requests.map((row) {
        if (role == 'creator') {
          final brand = _asMap(row['brand']);
          return ChatModalRequest(
            id: _string(row['id']) ?? '',
            name: _string(brand['brand_name']) ?? 'Brand',
            tier: _string(brand['size']) ?? 'brand',
            budget: _int(row['budget']) ?? 0,
            collabType: _string(row['collab_type']) ?? 'paid',
            message: _string(row['message']) ?? 'New request',
            createdAt: _dateTime(row['created_at']),
            status: _string(row['status']) ?? 'pending',
            isIncoming: true,
          );
        }

        final creator = _asMap(row['creator']);
        final creatorUser = _asMap(row['creator_user']);
        final creatorName = _string(row['creator_first_name']) ??
            _string(row['creator_full_name']) ??
            _string(creatorUser['first_name']) ??
            _string(creatorUser['full_name']) ??
            'Creator';

        return ChatModalRequest(
          id: _string(row['id']) ?? '',
          name: creatorName,
          tier: _string(row['creator_tier']) ?? _string(creator['tier']) ?? 'micro',
          budget: _int(row['budget']) ?? 0,
          collabType: _string(row['collab_type']) ?? 'paid',
          message: _string(row['message']) ?? 'Collab request sent',
          createdAt: _dateTime(row['created_at']),
          status: _string(row['status']) ?? 'pending',
          isIncoming: false,
        );
      }).where((item) => item.id.isNotEmpty).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<ChatModalEventInvite>> getEventInvites({required String role}) async {
    try {
      if (role == 'creator') {
        final response = await _dio.get('/creator/events');
        final root = _asMap(response.data);
        final invites = _asMapList(root['invites']);

        return invites.map((row) {
          final event = _asMap(row['event']);
          final brand = _asMap(event['brand']);
          return ChatModalEventInvite(
            id: _string(row['id']) ?? '',
            eventName: _string(event['title']) ?? 'Event',
            brandName: _string(brand['brand_name']) ?? 'Brand',
            eventDate: _dateTime(event['event_date']),
            status: _string(row['status']) ?? 'pending',
          );
        }).where((item) => item.id.isNotEmpty).toList();
      }

      final response = await _dio.get('/brand/events');
      final root = _asMap(response.data);
      final events = _asMapList(root['events']);

      return events.map((row) {
        return ChatModalEventInvite(
          id: _string(row['id']) ?? '',
          eventName: _string(row['title']) ?? 'Event',
          brandName: _string(row['brand_name']) ?? 'Your brand',
          eventDate: _dateTime(row['event_date']),
          status: _string(row['status']) ?? 'upcoming',
        );
      }).where((item) => item.id.isNotEmpty).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> respondToRequest({
    required String role,
    required String requestId,
    required String action,
  }) async {
    try {
      await _dio.put('/$role/requests/$requestId', data: {'action': action});
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _dio.delete('/brand/requests/$requestId');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> respondToEventInvite({
    required String role,
    required String inviteId,
    required String action,
  }) async {
    if (role != 'creator') return;

    try {
      await _dio.put('/creator/events/$inviteId', data: {'action': action});
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<CollabChat>> _enrichWithMessageState(
    List<CollabChat> collabs, {
    required String currentUserId,
  }) async {
    final collabIds = collabs.map((item) => item.collabId).toList();
    if (collabIds.isEmpty) return collabs;

    final rows = await Supabase.instance.client
        .from('messages')
        .select('id, collab_id, sender_id, content, created_at, is_read')
        .inFilter('collab_id', collabIds)
        .order('created_at', ascending: false);

    final byCollab = <String, List<Map<String, dynamic>>>{};
    for (final raw in rows) {
      final row = _asMap(raw);
      final collabId = _string(row['collab_id']);
      if (collabId == null || collabId.isEmpty) continue;
      byCollab.putIfAbsent(collabId, () => <Map<String, dynamic>>[]).add(row);
    }

    return collabs.map((chat) {
      final messages = byCollab[chat.collabId] ?? const <Map<String, dynamic>>[];
      if (messages.isEmpty) return chat;

      final latest = messages.first;
      final unread = messages.where((item) {
        final senderId = _string(item['sender_id']) ?? '';
        final isRead = _bool(item['is_read']) ?? false;
        return senderId != currentUserId && !isRead;
      }).length;

      return chat.copyWith(
        lastMessage: _string(latest['content']) ?? '',
        lastMessageTime: _dateTime(latest['created_at']),
        unreadCount: unread,
      );
    }).toList();
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

  String? _string(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString();
    return parsed.isEmpty ? null : parsed;
  }

  int? _int(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  DateTime? _dateTime(dynamic value) {
    final raw = _string(value);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  bool? _bool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return null;
  }
}
