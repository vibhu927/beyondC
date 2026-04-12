class CollabChat {
  const CollabChat({
    required this.id,
    required this.status,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    required this.unreadCountCreator,
    required this.unreadCountBrand,
    required this.isArchived,
    this.archivedAt,
    required this.createdAt,
    this.agreedAmount,
    this.collabType,
    required this.otherPartyId,
    required this.otherPartyName,
    this.otherPartyFullName,
    this.otherPartyAvatar,
    this.otherPartyNiche,
    this.otherPartyBrandName,
    this.otherPartyCategory,
    this.otherPartyInstagramVerified,
    this.otherPartyInstagramUsername,
    this.otherPartyState,
    this.otherPartyCity,
  });

  final String id;
  final String status;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final int unreadCountCreator;
  final int unreadCountBrand;
  final bool isArchived;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final int? agreedAmount;
  final String? collabType;
  final String otherPartyId;
  final String otherPartyName;
  final String? otherPartyFullName;
  final String? otherPartyAvatar;
  final String? otherPartyNiche;
  final String? otherPartyBrandName;
  final String? otherPartyCategory;
  final bool? otherPartyInstagramVerified;
  final String? otherPartyInstagramUsername;
  final String? otherPartyState;
  final String? otherPartyCity;

  int unreadForRole(String role) {
    if (role == 'creator') return unreadCountCreator;
    return unreadCountBrand;
  }

  CollabChat copyWith({
    String? id,
    String? status,
    Object? lastMessage = _unset,
    Object? lastMessageAt = _unset,
    Object? lastMessageBy = _unset,
    int? unreadCountCreator,
    int? unreadCountBrand,
    bool? isArchived,
    Object? archivedAt = _unset,
    DateTime? createdAt,
    Object? agreedAmount = _unset,
    Object? collabType = _unset,
    String? otherPartyId,
    String? otherPartyName,
    Object? otherPartyFullName = _unset,
    Object? otherPartyAvatar = _unset,
    Object? otherPartyNiche = _unset,
    Object? otherPartyBrandName = _unset,
    Object? otherPartyCategory = _unset,
    Object? otherPartyInstagramVerified = _unset,
    Object? otherPartyInstagramUsername = _unset,
    Object? otherPartyState = _unset,
    Object? otherPartyCity = _unset,
  }) {
    return CollabChat(
      id: id ?? this.id,
      status: status ?? this.status,
      lastMessage: identical(lastMessage, _unset) ? this.lastMessage : lastMessage as String?,
      lastMessageAt: identical(lastMessageAt, _unset) ? this.lastMessageAt : lastMessageAt as DateTime?,
      lastMessageBy: identical(lastMessageBy, _unset) ? this.lastMessageBy : lastMessageBy as String?,
      unreadCountCreator: unreadCountCreator ?? this.unreadCountCreator,
      unreadCountBrand: unreadCountBrand ?? this.unreadCountBrand,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: identical(archivedAt, _unset) ? this.archivedAt : archivedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      agreedAmount: identical(agreedAmount, _unset) ? this.agreedAmount : agreedAmount as int?,
      collabType: identical(collabType, _unset) ? this.collabType : collabType as String?,
      otherPartyId: otherPartyId ?? this.otherPartyId,
      otherPartyName: otherPartyName ?? this.otherPartyName,
      otherPartyFullName: identical(otherPartyFullName, _unset) ? this.otherPartyFullName : otherPartyFullName as String?,
      otherPartyAvatar: identical(otherPartyAvatar, _unset) ? this.otherPartyAvatar : otherPartyAvatar as String?,
      otherPartyNiche: identical(otherPartyNiche, _unset) ? this.otherPartyNiche : otherPartyNiche as String?,
      otherPartyBrandName: identical(otherPartyBrandName, _unset) ? this.otherPartyBrandName : otherPartyBrandName as String?,
      otherPartyCategory: identical(otherPartyCategory, _unset) ? this.otherPartyCategory : otherPartyCategory as String?,
      otherPartyInstagramVerified: identical(otherPartyInstagramVerified, _unset)
          ? this.otherPartyInstagramVerified
          : otherPartyInstagramVerified as bool?,
      otherPartyInstagramUsername: identical(otherPartyInstagramUsername, _unset)
          ? this.otherPartyInstagramUsername
          : otherPartyInstagramUsername as String?,
        otherPartyState: identical(otherPartyState, _unset)
          ? this.otherPartyState
          : otherPartyState as String?,
        otherPartyCity: identical(otherPartyCity, _unset)
          ? this.otherPartyCity
          : otherPartyCity as String?,
    );
  }

  factory CollabChat.fromJson(Map<String, dynamic> json) {
    final brand = _asMap(json['brand']);
    final creator = _asMap(json['creator']);
    final brandProfile = _asMap(brand['profile']);
    final creatorProfile = _asMap(creator['profile']);

    final viewerRole = _string(json['_viewer_role']) ?? 'creator';
    final other = viewerRole == 'creator' ? brand : creator;
    final otherProfile = viewerRole == 'creator' ? brandProfile : creatorProfile;

    final name = _string(other['brand_name']) ??
        _string(otherProfile['first_name']) ??
        _string(otherProfile['full_name']) ??
        (viewerRole == 'creator' ? 'Brand' : 'Creator');

    return CollabChat(
      id: _string(json['id']) ?? '',
      status: _string(json['status']) ?? 'active',
      lastMessage: _string(json['last_message']),
      lastMessageAt: _parseDate(json['last_message_at']),
      lastMessageBy: _string(json['last_message_by']),
      unreadCountCreator: _int(json['unread_count_creator']) ?? 0,
      unreadCountBrand: _int(json['unread_count_brand']) ?? 0,
      isArchived: _bool(json['is_archived']) ?? false,
      archivedAt: _parseDate(json['archived_at']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      agreedAmount: _int(json['agreed_amount']),
      collabType: _string(json['collab_type']),
      otherPartyId: _string(other['id']) ?? _string(otherProfile['id']) ?? '',
      otherPartyName: name,
      otherPartyFullName: _string(otherProfile['full_name']),
      otherPartyAvatar: _string(otherProfile['avatar_url']) ?? _string(other['logo_url']),
      otherPartyNiche: _toNicheString(other['niche']),
      otherPartyBrandName: _string(other['brand_name']),
      otherPartyCategory: _string(other['brand_category']),
      otherPartyInstagramVerified: _bool(other['instagram_verified']),
      otherPartyInstagramUsername: _string(other['instagram_username']),
      otherPartyState: _string(otherProfile['state']),
      otherPartyCity: _string(otherProfile['city']),
    );
  }
}

class ChatListResult {
  const ChatListResult({
    required this.active,
    required this.archived,
  });

  final List<CollabChat> active;
  final List<CollabChat> archived;
}

const _unset = Object();

String _toNicheString(dynamic raw) {
  if (raw is List) {
    return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).join(' · ');
  }
  final parsed = _string(raw);
  return parsed ?? '';
}

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

int? _int(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _bool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  final raw = _string(value);
  if (raw == null) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return null;
  return parsed.toLocal();
}
