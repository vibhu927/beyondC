import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/collab_chat.dart';
import '../models/message.dart';

class ChatRepository {
  ChatRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<ChatListResult> getChats(String userId, String role) async {
    dynamic collabRows;
    try {
      collabRows = await _supabase
          .from('collabs')
          .select(
            'id, status, last_message, last_message_at, last_message_by, unread_count_creator, unread_count_brand, is_archived, archived_at, created_at, agreed_amount, collab_type, brand_id, creator_id, campaign:campaigns!collabs_campaign_id_fkey(title)',
          )
          .or('brand_id.eq.$userId,creator_id.eq.$userId')
          .order('last_message_at', ascending: false, nullsFirst: false)
          .order('created_at', ascending: false);
    } on PostgrestException catch (error) {
      // Backward-compat fallback for environments where chat migration is not applied yet.
      if (error.code != '42703') rethrow;

      collabRows = await _supabase
          .from('collabs')
          .select('id, status, created_at, agreed_amount, collab_type, brand_id, creator_id')
          .or('brand_id.eq.$userId,creator_id.eq.$userId')
          .order('created_at', ascending: false);
    }

    final collabs = (collabRows as List)
        .whereType<Map>()
        .map((entry) => entry.map((key, value) => MapEntry(key.toString(), value)))
        .toList();

    final brandIds = collabs
        .map((item) => item['brand_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final creatorIds = collabs
        .map((item) => item['creator_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final allProfileIds = {...brandIds, ...creatorIds}.toList();

    final brandProfiles = <String, Map<String, dynamic>>{};
    if (brandIds.isNotEmpty) {
      final rows = await _supabase
          .from('brand_profiles')
          .select('id, brand_name, brand_category, logo_url')
          .inFilter('id', brandIds);
      for (final raw in rows as List) {
        final item = _asMap(raw);
        final id = item['id']?.toString() ?? '';
        if (id.isNotEmpty) brandProfiles[id] = item;
      }
    }

    final creatorProfiles = <String, Map<String, dynamic>>{};
    if (creatorIds.isNotEmpty) {
      final rows = await _supabase
          .from('creator_profiles')
          .select('id, niche, instagram_username, instagram_verified')
          .inFilter('id', creatorIds);
      for (final raw in rows as List) {
        final item = _asMap(raw);
        final id = item['id']?.toString() ?? '';
        if (id.isNotEmpty) creatorProfiles[id] = item;
      }
    }

    final creatorDiscoveryProfiles = <String, Map<String, dynamic>>{};
    if (creatorIds.isNotEmpty) {
      try {
        final rows = await _supabase
            .from('creator_discovery_view')
            .select('id, first_name, avatar_url')
            .inFilter('id', creatorIds);
        for (final raw in rows as List) {
          final item = _asMap(raw);
          final id = item['id']?.toString() ?? '';
          if (id.isNotEmpty) creatorDiscoveryProfiles[id] = item;
        }
      } on PostgrestException {
        // View may be unavailable in some environments; continue with other fallbacks.
      }
    }

    final baseProfiles = <String, Map<String, dynamic>>{};
    if (allProfileIds.isNotEmpty) {
      final rows = await _supabase
          .from('profiles')
          .select('id, first_name, full_name, avatar_url')
          .inFilter('id', allProfileIds);
      for (final raw in rows as List) {
        final item = _asMap(raw);
        final id = item['id']?.toString() ?? '';
        if (id.isNotEmpty) baseProfiles[id] = item;
      }
    }

    final chats = collabs
        .map((item) {
          final brandId = item['brand_id']?.toString() ?? '';
          final creatorId = item['creator_id']?.toString() ?? '';

          final withRole = <String, dynamic>{
            ...item,
            '_viewer_role': role,
            'brand': {
              ...(brandProfiles[brandId] ?? const <String, dynamic>{}),
              'id': brandId,
              'profile': baseProfiles[brandId] ?? const <String, dynamic>{},
            },
            'creator': {
              ...(creatorProfiles[creatorId] ?? const <String, dynamic>{}),
              'id': creatorId,
              'profile': {
                ...(creatorDiscoveryProfiles[creatorId] ??
                    const <String, dynamic>{}),
                ...(baseProfiles[creatorId] ?? const <String, dynamic>{}),
              },
            },
          };

          return CollabChat.fromJson(withRole);
        })
        .where((chat) => chat.id.isNotEmpty)
        .toList();

    return ChatListResult(
      active: chats.where((c) => !c.isArchived).toList(),
      archived: chats.where((c) => c.isArchived).toList(),
    );
  }

  Future<List<Message>> getMessages(
    String collabId, {
    int page = 1,
    int limit = 50,
  }) async {
    final from = (page - 1) * limit;

    final data = await _supabase
        .from('messages')
        .select('*, sender:profiles(first_name, full_name, avatar_url)')
        .eq('collab_id', collabId)
        .order('created_at', ascending: false)
        .range(from, from + limit - 1);

    return (data as List)
        .whereType<Map>()
        .map((entry) => entry.map((key, value) => MapEntry(key.toString(), value)))
        .map(Message.fromJson)
        .toList();
  }

  Future<Message> sendMessage(
    String collabId,
    String content,
    String senderRole,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    final data = await _supabase
        .from('messages')
        .insert({
          'collab_id': collabId,
          'sender_id': user.id,
          'sender_role': senderRole,
          'content': content,
          'is_read': false,
        })
        .select('*, sender:profiles(first_name, full_name, avatar_url)')
        .single();

    return Message.fromJson(data);
  }

  Future<void> markAsRead(String collabId, String role) async {
    final field = role == 'creator' ? 'unread_count_creator' : 'unread_count_brand';
    try {
      await _supabase.from('collabs').update({field: 0}).eq('id', collabId);
    } on PostgrestException catch (error) {
      // Ignore missing-column errors when DB migration is pending.
      if (error.code != '42703') rethrow;
    }
  }

  RealtimeChannel subscribeToMessages(
    String collabId,
    void Function(Message) onMessage,
  ) {
    return _supabase
        .channel('messages:$collabId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'collab_id',
            value: collabId,
          ),
          callback: (payload) {
            final map = payload.newRecord;
            final normalized = map.map((key, value) => MapEntry(key.toString(), value));
            onMessage(Message.fromJson(normalized));
          },
        )
        .subscribe();
  }

  RealtimeChannel subscribeToChatList(
    String userId,
    void Function() onUpdate,
  ) {
    return _supabase
        .channel('collab_updates:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'collabs',
          callback: (_) => onUpdate(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (_) => onUpdate(),
        )
        .subscribe();
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}
