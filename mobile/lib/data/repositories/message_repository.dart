import 'package:dio/dio.dart';

import '../../core/utils/api_error_handler.dart';
import '../models/paginated_result.dart';
import '../services/api_service.dart';

class Message {
  const Message({
    required this.id,
    required this.collabId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final String collabId;
  final String senderId;
  final String senderRole;
  final String content;
  final DateTime createdAt;
  final bool isPending;

  Message copyWith({
    String? id,
    String? collabId,
    String? senderId,
    String? senderRole,
    String? content,
    DateTime? createdAt,
    bool? isPending,
  }) {
    return Message(
      id: id ?? this.id,
      collabId: collabId ?? this.collabId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
    );
  }

  factory Message.fromApi(Map<String, dynamic> raw,
      {String? fallbackCollabId}) {
    return Message(
      id: _string(raw['id']) ?? 'msg-${DateTime.now().microsecondsSinceEpoch}',
      collabId: _string(raw['collab_id']) ?? fallbackCollabId ?? '',
      senderId: _string(raw['sender_id']) ?? _string(raw['user_id']) ?? '',
      senderRole:
          _string(raw['sender_role']) ?? _string(raw['role']) ?? 'creator',
      content: _string(raw['content']) ?? '',
      createdAt:
          DateTime.tryParse(_string(raw['created_at']) ?? '') ?? DateTime.now(),
      isPending: _bool(raw['is_pending']) ?? false,
    );
  }
}

class MessageRepository {
  MessageRepository(this._apiService);

  final ApiService _apiService;

  Dio get _dio => _apiService.client;

  Future<PaginatedResult<Message>> getMessages(
    String collabId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/collabs/$collabId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final root = _asMap(response.data);
      final messagesRaw = _extractMessages(root);
      final pagination = _asMap(root['pagination']);

      final messages = messagesRaw
          .map((item) => Message.fromApi(item, fallbackCollabId: collabId))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final totalPages = _int(pagination['total_pages']) ??
          _int(pagination['totalPages']) ??
          _int(root['total_pages']) ??
          page;

      return PaginatedResult<Message>(
        items: messages,
        page: _int(pagination['page']) ?? page,
        limit: _int(pagination['limit']) ?? limit,
        total: _int(pagination['total']) ?? messages.length,
        totalPages: totalPages < 1 ? 1 : totalPages,
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Message> sendMessage(String collabId, String content) async {
    try {
      final response = await _dio.post(
        '/collabs/$collabId/messages',
        data: {'content': content},
      );

      final root = _asMap(response.data);
      final messageRaw = _extractMessage(root);
      return Message.fromApi(messageRaw, fallbackCollabId: collabId);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  List<Map<String, dynamic>> _extractMessages(Map<String, dynamic> root) {
    final fromMessages = _asMapList(root['messages']);
    if (fromMessages.isNotEmpty) return fromMessages;

    final fromItems = _asMapList(root['items']);
    if (fromItems.isNotEmpty) return fromItems;

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractMessage(Map<String, dynamic> root) {
    final nested = _asMap(root['message']);
    return nested.isNotEmpty ? nested : root;
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

  int? _int(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

String? _string(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString();
  return parsed.isEmpty ? null : parsed;
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
