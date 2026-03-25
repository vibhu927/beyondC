import 'package:dio/dio.dart';

import '../../core/utils/api_error_handler.dart';
import '../models/brand_models.dart';
import '../models/paginated_result.dart';
import '../services/api_service.dart';

class BrandRepository {
  BrandRepository(this._api);

  final ApiService _api;

  Dio get _dio => _api.client;

  Future<BrandProfile> getProfile() async {
    try {
      final response = await _dio.get('/brand/profile');
      final root = _asMap(response.data);
      final profile = _asMap(root['profile']);
      final profileBrand = _firstMap(profile['brand']);
      final rootBrand = _firstMap(root['brand']);
      final brand = profileBrand.isNotEmpty ? profileBrand : rootBrand;

      return BrandProfile.fromJson({
        'id': _string(profile['id']) ?? '',
        'displayName':
            _string(profile['display_name']) ?? _string(profile['full_name']),
        'avatarUrl': _string(profile['avatar_url']),
        'onboarded': _bool(profile['onboarded']) ??
            _bool(profile['is_onboarded']) ??
            false,
        'brandName': _string(brand['brand_name']) ??
            _string(profile['full_name']) ??
            _string(profile['display_name']) ??
            'Brand',
        'brandCategory': _string(brand['brand_category']) ??
            _string(brand['category']) ??
            'General',
        'description': _string(brand['description']) ?? '',
        'logoUrl': _string(brand['logo_url']),
        'website': _string(brand['website']) ?? '',
        'contactEmail': _string(brand['contact_email']),
        'size': _string(brand['size']),
        'creditsBalance': _int(brand['credit_balance']) ??
            _int(brand['credits_balance']) ??
            0,
        'verified': _bool(brand['verified']) ??
            _bool(brand['is_brand_verified']) ??
            false,
        'totalCollabs': _int(brand['total_collabs']) ?? 0,
        'avgRating': _double(brand['avg_rating']) ?? 0,
        'createdAt': _string(profile['created_at']),
        'updatedAt': _string(profile['updated_at']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<BrandProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/brand/profile', data: data);
      final root = _asMap(response.data);
      final profile = _asMap(root['profile']);
      final profileBrand = _firstMap(profile['brand']);
      final rootBrand = _firstMap(root['brand']);
      final brand = profileBrand.isNotEmpty ? profileBrand : rootBrand;

      return BrandProfile.fromJson({
        'id': _string(profile['id']) ?? '',
        'displayName':
            _string(profile['display_name']) ?? _string(profile['full_name']),
        'avatarUrl': _string(profile['avatar_url']),
        'onboarded': _bool(profile['onboarded']) ??
            _bool(profile['is_onboarded']) ??
            false,
        'brandName': _string(brand['brand_name']) ??
            _string(profile['full_name']) ??
            _string(profile['display_name']) ??
            'Brand',
        'brandCategory': _string(brand['brand_category']) ??
            _string(brand['category']) ??
            'General',
        'description': _string(brand['description']) ?? '',
        'logoUrl': _string(brand['logo_url']),
        'website': _string(brand['website']) ?? '',
        'contactEmail': _string(brand['contact_email']),
        'size': _string(brand['size']),
        'creditsBalance': _int(brand['credit_balance']) ??
            _int(brand['credits_balance']) ??
            0,
        'verified': _bool(brand['verified']) ??
            _bool(brand['is_brand_verified']) ??
            false,
        'totalCollabs': _int(brand['total_collabs']) ?? 0,
        'avgRating': _double(brand['avg_rating']) ?? 0,
        'createdAt': _string(profile['created_at']),
        'updatedAt': _string(profile['updated_at']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<PaginatedResult<CreatorDiscovery>> getCreators({
    String? niche,
    String? tier,
    int? minFollowers,
    int? maxPrice,
    String? platform,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/brand/creators',
        queryParameters: {
          if (niche != null && niche.isNotEmpty) 'niche': niche,
          if (tier != null && tier.isNotEmpty) 'tier': tier,
          if (minFollowers != null) 'min_followers': minFollowers,
          if (maxPrice != null) 'max_price': maxPrice,
          if (platform != null && platform.isNotEmpty) 'platform': platform,
          'page': page,
          'limit': limit,
        },
      );

      final root = _asMap(response.data);
      final creatorsRaw = _asMapList(root['creators']);
      final pagination = _asMap(root['pagination']);

      final creators = creatorsRaw.map((item) {
        return CreatorDiscovery.fromJson({
          'id': _string(item['id']) ?? '',
          'firstName': _string(item['first_name']) ?? 'Creator',
          'avatarUrl': _string(item['avatar_url']),
          'niches': _stringList(item['niches'] ?? item['niche']),
          'contentTypes':
              _stringList(item['platforms'] ?? item['content_type']),
          'tier': _string(item['tier']) ?? 'micro',
          'startingPrice': _int(item['starting_price']) ?? 0,
          'avgRating': _double(item['avg_rating']) ?? 0,
          'totalCollabs': _int(item['total_collabs']) ?? 0,
          'engagementRate': _double(item['engagement_rate']) ?? 0,
          'bio': _string(item['bio']) ?? '',
          'portfolioLinks': _stringList(item['portfolio_links']),
          'followerRange': _string(item['follower_range']) ?? '1K-5K',
          'followersCount': _int(item['follower_count']) ??
              _int(item['followers_count']) ??
              0,
        });
      }).toList();

      return PaginatedResult<CreatorDiscovery>(
        items: creators,
        page: _int(pagination['page']) ?? page,
        limit: _int(pagination['limit']) ?? limit,
        total: _int(pagination['total']) ?? creators.length,
        totalPages: _int(pagination['total_pages']) ??
            _int(pagination['totalPages']) ??
            1,
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<CollabRequest> sendRequest(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/brand/requests', data: data);
      final root = _asMap(response.data);
      final request = _asMap(root['request']);

      return CollabRequest.fromJson({
        'id': _string(request['id']) ?? '',
        'brandId': _string(request['brand_id']) ?? '',
        'creatorId': _string(request['creator_id']) ?? '',
        'creatorFirstName': _string(request['creator_first_name']),
        'creatorFullName': _string(request['creator_full_name']),
        'creatorInstagramHandle': _string(request['creator_instagram_handle']),
        'creatorTier': _string(request['creator_tier']),
        'collabId': _string(request['collab_id']),
        'message': _string(request['message']),
        'budget': _int(request['budget']),
        'collabType': _string(request['collab_type']) ?? 'paid',
        'deliverables': _stringList(request['deliverables']),
        'status': _string(request['status']) ?? 'pending',
        'expiresAt': _string(request['expires_at']),
        'createdAt': _string(request['created_at']),
        'updatedAt': _string(request['updated_at']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<CollabRequest>> getRequests() async {
    try {
      final response = await _dio.get('/brand/requests');
      final root = _asMap(response.data);

      return _asMapList(root['requests']).map(
        (item) {
          final creator = _asMap(item['creator']);
          final creatorUser = _asMap(item['creator_user']);
          return CollabRequest.fromJson({
            'id': _string(item['id']) ?? '',
            'brandId': _string(item['brand_id']) ?? '',
            'creatorId': _string(item['creator_id']) ?? '',
            'creatorFirstName': _string(creatorUser['first_name']) ??
                _string(creatorUser['full_name']) ??
                'Creator',
            'creatorFullName': _string(creatorUser['full_name']) ??
                _string(creatorUser['first_name']) ??
                'Creator',
            'creatorInstagramHandle': _string(creator['instagram_handle']),
            'creatorTier': _string(creator['tier']) ?? 'micro',
            'collabId': _string(item['collab_id']),
            'message': _string(item['message']),
            'budget': _int(item['budget']),
            'collabType': _string(item['collab_type']) ?? 'paid',
            'deliverables': _stringList(item['deliverables']),
            'status': _string(item['status']) ?? 'pending',
            'expiresAt': _string(item['expires_at']),
            'createdAt': _string(item['created_at']),
            'updatedAt': _string(item['updated_at']),
          });
        },
      ).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Campaign> postCampaign(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/brand/campaigns', data: data);
      final root = _asMap(response.data);
      final campaign = _asMap(root['campaign']);
      return _campaignFromApi(campaign);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<Campaign>> getCampaigns() async {
    try {
      final response = await _dio.get('/brand/campaigns');
      final root = _asMap(response.data);
      return _asMapList(root['campaigns']).map(_campaignFromApi).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<ActiveCollabSummary>> getActiveCollabs() async {
    try {
      final response = await _dio.get('/brand/collabs');
      final root = _asMap(response.data);

      return _asMapList(root['collabs']).map((item) {
        return ActiveCollabSummary.fromJson({
          'id': _string(item['id']) ?? '',
          'creatorId': _string(item['creator_id']) ?? '',
          'creatorName': _string(item['creator_name']) ?? 'Creator',
          'campaignId': _string(item['campaign_id']),
          'campaignTitle': _string(item['campaign_title']) ?? 'Campaign',
          'status': _string(item['status']) ?? 'active',
          'agreedAmount': _int(item['agreed_amount']),
          'startedAt':
              _string(item['started_at']) ?? _string(item['created_at']),
        });
      }).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<ActiveCollabSummary>> getCompletedCollabs() async {
    try {
      final response = await _dio.get(
        '/brand/collabs',
        queryParameters: {'status': 'completed'},
      );
      final root = _asMap(response.data);

      return _asMapList(root['collabs']).map((item) {
        return ActiveCollabSummary.fromJson({
          'id': _string(item['id']) ?? '',
          'creatorId': _string(item['creator_id']) ?? '',
          'creatorName': _string(item['creator_name']) ?? 'Creator',
          'campaignId': _string(item['campaign_id']),
          'campaignTitle': _string(item['campaign_title']) ?? 'Campaign',
          'status': _string(item['status']) ?? 'completed',
          'agreedAmount': _int(item['agreed_amount']),
          'startedAt':
              _string(item['started_at']) ?? _string(item['created_at']),
        });
      }).toList();
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

  Future<Campaign> updateCampaign(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/brand/campaigns/$id', data: data);
      final root = _asMap(response.data);
      final campaign = _asMap(root['campaign']);
      return _campaignFromApi(campaign);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<Bid>> getCampaignBids(String campaignId) async {
    try {
      final response = await _dio.get('/brand/campaigns/$campaignId/bids');
      final root = _asMap(response.data);

      final bids = _asMapList(root['bids']).map((item) {
        final creator = _asMap(item['creator']);
        final creatorId =
            _string(item['creator_id']) ?? _string(creator['id']) ?? '';

        return Bid.fromJson({
          'id': _string(item['id']) ?? '',
          'campaignId': _string(item['campaign_id']) ?? campaignId,
          'creatorId': creatorId,
          'bidAmount': _int(item['bid_amount']) ?? 0,
          'deliverables': _string(item['deliverables']) ?? '',
          'message': _string(item['message']),
          'status': _string(item['status']) ?? 'pending',
          'includeBarter': _bool(item['include_barter']) ?? false,
          'createdAt': _string(item['created_at']),
          'updatedAt': _string(item['updated_at']),
          'creatorFirstName': _string(creator['first_name']) ?? 'Creator',
          'creatorFullName': _string(creator['first_name']) ?? 'Creator',
          'creatorHandle': _string(creator['handle']) ?? '',
          'tier': _string(creator['tier']) ?? 'micro',
          'followersCount': _int(creator['followers_count']) ?? 0,
          'engagementRate': _double(creator['engagement_rate']) ??
              _double(creator['avg_rating']) ??
              0,
          'niches': _stringList(creator['niches'] ?? creator['niche']),
          'collabType': 'paid',
        });
      }).toList();

      return bids;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Bid> respondToBid(
      String campaignId, String bidId, String action) async {
    try {
      await _dio.put(
        '/brand/campaigns/$campaignId/bids/$bidId',
        data: {'action': action},
      );

      return Bid.fromJson({
        'id': bidId,
        'campaignId': campaignId,
        'creatorId': '',
        'status': action == 'accept' ? 'accepted' : 'rejected',
        'isAccepted': action == 'accept',
        'isUnlocked': action == 'accept',
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<CreditsData> getCredits() async {
    try {
      final response = await _dio.get('/brand/credits');
      final root = _asMap(response.data);

      return CreditsData.fromJson({
        'balance': _int(root['balance']) ?? 0,
        'transactions': _asMapList(root['transactions'])
            .map(
              (txn) => {
                'id': _string(txn['id']) ?? '',
                'type': _string(txn['type']) ?? 'deduct',
                'amount': _int(txn['amount']) ?? 0,
                'reason': _string(txn['reason']) ?? '',
                'referenceId': _string(txn['reference_id']),
                'balanceAfter': _int(txn['balance_after']) ?? 0,
                'createdAt': _string(txn['created_at']),
              },
            )
            .toList(),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<RazorpayOrder> initiateCreditPurchase(String pack) async {
    try {
      final normalizedPack = pack == 'scale' ? 'pro' : pack;
      final response = await _dio.post(
        '/brand/credits',
        data: {'pack': normalizedPack},
      );
      final root = _asMap(response.data);

      return RazorpayOrder.fromJson({
        'orderId': _string(root['order_id']) ?? '',
        'amount': _int(root['amount']) ?? 0,
        'currency': _string(root['currency']) ?? 'INR',
        'credits': _int(root['credits']),
        'keyId': _string(root['key_id']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> verifyCreditPurchase(Map<String, String> paymentData) async {
    try {
      await _dio.post('/brand/credits/verify', data: paymentData);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<BrandEvent> createEvent(Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{
        'title': data['title'] ?? data['event_name'],
        'description': data['description'] ?? data['what_creators_get'],
        'event_date':
            data['event_date'] ?? data['eventDate'] ?? data['event_date_iso'],
        'location': data['location'] ?? data['venue_address'],
        if (data['image_url'] != null) 'image_url': data['image_url'],
      };

      final response = await _dio.post('/brand/events', data: payload);
      final root = _asMap(response.data);
      final event = _asMap(root['event']);
      return _eventFromApi(event);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<BrandEvent>> getEvents() async {
    try {
      final response = await _dio.get('/brand/events');
      final root = _asMap(response.data);

      return _asMapList(root['events']).map((item) {
        final event = _eventFromApi(item);
        final invitesCount = _extractCount(item['invites']);
        final acceptedCount = _extractCount(item['accepted']);
        return event.copyWith(
          invitesSent: invitesCount,
          invitesAccepted: acceptedCount,
          slotsFilled: acceptedCount,
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<EventInvite> sendEventInvite(String eventId, String creatorId) async {
    try {
      final response = await _dio.post(
        '/brand/events/$eventId/invites',
        data: {
          'creator_id': creatorId,
          'creator_ids': [creatorId],
        },
      );

      final root = _asMap(response.data);
      final invites = _asMapList(root['invites']);
      final invite = invites.isEmpty ? <String, dynamic>{} : invites.first;

      return EventInvite.fromJson({
        'id': _string(invite['id']) ??
            'temp-${DateTime.now().microsecondsSinceEpoch}',
        'eventId': _string(invite['event_id']) ?? eventId,
        'creatorId': _string(invite['creator_id']) ?? creatorId,
        'status': _string(invite['status']) ?? 'pending',
        'ticketCode': _string(invite['ticket_code']),
        'ticketGeneratedAt': _string(invite['ticket_generated_at']),
        'acceptedAt': _string(invite['accepted_at']),
        'createdAt':
            _string(invite['created_at']) ?? DateTime.now().toIso8601String(),
        'creatorFirstName': 'Creator',
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<EventInvite>> getEventInvites(String eventId) async {
    try {
      final response = await _dio.get('/brand/events/$eventId/invites');
      final root = _asMap(response.data);

      return _asMapList(root['invites']).map((item) {
        final creator = _asMap(item['creator']);
        final creatorId =
            _string(item['creator_id']) ?? _string(creator['id']) ?? '';
        return EventInvite.fromJson({
          'id': _string(item['id']) ?? '',
          'eventId': _string(item['event_id']) ?? eventId,
          'creatorId': creatorId,
          'status': _string(item['status']) ?? 'pending',
          'ticketCode': _string(item['ticket_code']),
          'ticketGeneratedAt': _string(item['ticket_generated_at']),
          'acceptedAt': _string(item['accepted_at']),
          'createdAt': _string(item['created_at']),
          'creatorFirstName': _string(creator['first_name']) ?? 'Creator',
          'tier': _string(creator['tier']) ?? 'micro',
          'creatorNiches': _stringList(creator['niches'] ?? creator['niche']),
          'creatorFollowersCount': _int(creator['followers_count']) ?? 0,
          'creatorAvgRating': _double(creator['avg_rating']) ?? 0,
          'creatorBio': _string(creator['bio']) ?? '',
        });
      }).toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Campaign _campaignFromApi(Map<String, dynamic> item) {
    final countFromBids = _extractCount(item['bids']);
    final bidCount =
        countFromBids > 0 ? countFromBids : (_int(item['bid_count']) ?? 0);
    final deadline = _string(item['deadline']) ??
        DateTime.now().add(const Duration(days: 7)).toIso8601String();
    final collabType = _normalizeCollabType(_string(item['collab_type']));
    final status = _normalizeCampaignStatus(_string(item['status']));

    return Campaign.fromJson({
      'id': _string(item['id']) ?? '',
      'title': _string(item['title']) ?? 'Campaign',
      'description': _string(item['description']) ?? '',
      'niche': _stringList(item['niche'] ?? item['niches']),
      'collabType': collabType,
      'budget': _int(item['budget']),
      'budgetMin': _int(item['budget_min']),
      'budgetMax': _int(item['budget_max']),
      'deliverables': _stringList(item['deliverables']),
      'requirements': _string(item['requirements']) ?? '',
      'deadline': deadline,
      'status': status,
      'slots': _int(item['slots']) ?? 1,
      'slotsFilled': _int(item['slots_filled']) ?? 0,
      'bidCount': bidCount,
      'createdAt': _string(item['created_at']),
      'updatedAt': _string(item['updated_at']),
    });
  }

  BrandEvent _eventFromApi(Map<String, dynamic> item) {
    return BrandEvent.fromJson({
      'id': _string(item['id']) ?? '',
      'title': _string(item['title']) ?? 'Event',
      'description': _string(item['description']) ?? '',
      'eventType': _string(item['event_type']) ?? 'other',
      'eventDate':
          _string(item['event_date']) ?? DateTime.now().toIso8601String(),
      'location': _string(item['location']),
      'imageUrl': _string(item['image_url']),
      'venueName': _string(item['venue_name']),
      'venueAddress': _string(item['venue_address']),
      'city': _string(item['city']),
      'isVirtual': _bool(item['is_virtual']) ?? false,
      'virtualLink': _string(item['virtual_link']),
      'totalSlots': _int(item['total_slots']) ?? 10,
      'slotsFilled': _int(item['slots_filled']) ?? 0,
      'whatCreatorsGet': _string(item['what_creators_get']) ?? '',
      'targetNiche': _stringList(item['target_niche']),
      'targetTier': _stringList(item['target_tier']),
      'status': _string(item['status']) ??
          (DateTime.tryParse(_string(item['event_date']) ?? '')
                      ?.isBefore(DateTime.now()) ==
                  true
              ? 'completed'
              : 'upcoming'),
      'createdAt': _string(item['created_at']),
      'updatedAt': _string(item['updated_at']),
    });
  }

  int _extractCount(dynamic value) {
    if (value is int) return value;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map) {
        final count = first['count'];
        return _int(count) ?? 0;
      }
    }
    return 0;
  }

  String _normalizeCampaignStatus(String? rawStatus) {
    switch ((rawStatus ?? '').toLowerCase()) {
      case 'active':
        return 'active';
      case 'paused':
      case 'draft':
        return 'paused';
      case 'completed':
      case 'closed':
      case 'cancelled':
      case 'canceled':
        return 'completed';
      default:
        return 'active';
    }
  }

  String _normalizeCollabType(String? rawType) {
    switch ((rawType ?? '').toLowerCase()) {
      case 'paid':
        return 'paid';
      case 'barter':
        return 'barter';
      case 'hybrid':
        return 'hybrid';
      default:
        return 'paid';
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  Map<String, dynamic> _firstMap(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return _asMap(value.first);
    }
    return _asMap(value);
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.map(_asMap).toList();
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.whereType<Object>().map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  int? _int(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _double(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool? _bool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      if (value == 'true') return true;
      if (value == 'false') return false;
    }
    return null;
  }

  String? _string(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString();
    return parsed.isEmpty ? null : parsed;
  }
}
