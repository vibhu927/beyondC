class Message {
  const Message({
    required this.id,
    required this.collabId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.isPending = false,
    this.isFailed = false,
  });

  final String id;
  final String collabId;
  final String senderId;
  final String senderRole;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;
  final bool isPending;
  final bool isFailed;

  Message copyWith({
    String? id,
    String? collabId,
    String? senderId,
    String? senderRole,
    String? content,
    bool? isRead,
    DateTime? createdAt,
    Object? senderName = _unset,
    Object? senderAvatar = _unset,
    bool? isPending,
    bool? isFailed,
  }) {
    return Message(
      id: id ?? this.id,
      collabId: collabId ?? this.collabId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      senderName: identical(senderName, _unset) ? this.senderName : senderName as String?,
      senderAvatar: identical(senderAvatar, _unset) ? this.senderAvatar : senderAvatar as String?,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final sender = _asMap(json['sender']);
    return Message(
      id: _string(json['id']) ?? 'msg-${DateTime.now().microsecondsSinceEpoch}',
      collabId: _string(json['collab_id']) ?? _string(json['collabId']) ?? '',
      senderId: _string(json['sender_id']) ?? _string(json['senderId']) ?? '',
      senderRole: _string(json['sender_role']) ?? _string(json['senderRole']) ?? 'creator',
      content: _string(json['content']) ?? '',
      isRead: _bool(json['is_read']) ?? _bool(json['isRead']) ?? false,
      createdAt: _parseDateTime(
            _string(json['created_at']) ?? _string(json['createdAt']) ?? '',
          ) ??
          DateTime.now(),
      senderName: _string(sender['first_name']) ?? _string(sender['full_name']) ?? _string(json['sender_name']) ?? _string(json['senderName']),
      senderAvatar: _string(sender['avatar_url']) ?? _string(json['sender_avatar']) ?? _string(json['senderAvatar']),
    );
  }
}

const _unset = Object();

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

String? _string(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? null : parsed;
}

bool? _bool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return null;
}

DateTime? _parseDateTime(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  return parsed.toLocal();
}
