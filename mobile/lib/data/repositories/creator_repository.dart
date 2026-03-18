import 'package:dio/dio.dart';

import '../../core/utils/api_error_handler.dart';
import '../models/creator_models.dart';
import '../models/paginated_result.dart';
import '../services/api_service.dart';

class CreatorRepository {
  CreatorRepository(this._apiService);

  final ApiService _apiService;

  Dio get _dio => _apiService.client;

  Future<CreatorProfile> fetchCreatorProfile() async {
    try {
      final response = await _dio.get('/creator/profile');
      final root = _asMap(response.data);
      final profile = _asMap(root['profile']);
      final baseProfile = _asMap(profile['profiles']);

      final displayName = _string(baseProfile['display_name']);
      final fullName = _string(baseProfile['full_name']) ?? displayName ?? 'Creator';
      final firstName = _string(baseProfile['first_name']) ??
          (fullName.trim().isEmpty ? 'Creator' : fullName.trim().split(' ').first);

      final normalized = <String, dynamic>{
        'id': _string(profile['id']) ?? _string(baseProfile['id']) ?? '',
        'firstName': firstName,
        'fullName': fullName,
        'displayName': displayName,
        'tier': _string(profile['tier']) ?? 'Rising Creator',
        'followersCount': _int(profile['followers_count']) ?? _int(profile['follower_count']) ?? 0,
        'engagementRate': _double(profile['engagement_rate']) ?? 0,
        'avgCollabPaise': _int(profile['avg_collab_price']) ?? 0,
        'bio': _string(profile['bio']) ?? '',
        'niches': _stringList(profile['niches'] ?? profile['niche']),
        'contentTypes': _stringList(profile['platforms']),
        'startingPricePaise': _int(profile['starting_price']) ?? 0,
        'instagramHandle': _string(profile['instagram_handle']),
        'youtubeHandle': _string(profile['youtube_handle']),
        'walletBalancePaise': _int(profile['wallet_balance']) ?? 0,
      };

      return CreatorProfile.fromJson(normalized);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<PaginatedResult<Campaign>> fetchCampaigns({
    String? niche,
    CampaignCollabType? collabType,
    int? minBudget,
    int? maxBudget,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/creator/campaigns',
        queryParameters: {
          if (niche != null && niche.isNotEmpty) 'niche': niche,
          if (collabType != null) 'collab_type': collabType.name,
          if (minBudget != null) 'budget_min': minBudget,
          if (maxBudget != null) 'budget_max': maxBudget,
          'page': page,
          'limit': limit,
        },
      );

      final root = _asMap(response.data);
      final campaignsRaw = _asMapList(root['campaigns']);
      final pagination = _asMap(root['pagination']);

      final campaigns = campaignsRaw.map(_campaignFromApi).toList();

      return PaginatedResult<Campaign>(
        items: campaigns,
        page: _int(pagination['page']) ?? page,
        limit: _int(pagination['limit']) ?? limit,
        total: _int(pagination['total']) ?? campaigns.length,
        totalPages: _int(pagination['totalPages']) ?? 1,
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<List<Bid>> fetchMyBids() async {
    try {
      final response = await _dio.get('/creator/bids');
      final root = _asMap(response.data);
      final bids = _asMapList(root['bids'])
          .map((item) {
            final campaignMap = _asMap(item['campaign']);
            final normalized = <String, dynamic>{
              'id': _string(item['id']) ?? '',
              'campaignId': _string(item['campaign_id']) ?? _string(campaignMap['id']) ?? '',
              'creatorId': _string(item['creator_id']),
              'status': _string(item['status']) ?? 'pending',
              'message': _string(item['message']),
              'createdAt': _string(item['created_at']),
              if (campaignMap.isNotEmpty) 'campaign': _campaignFromApi(campaignMap).toJson(),
            };
            return Bid.fromJson(normalized);
          })
          .toList();

      return bids;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<Bid> placeBid({
    required String campaignId,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/creator/bids',
        data: {
          'campaign_id': campaignId,
          'message': message,
        },
      );

      final root = _asMap(response.data);
      final bid = _asMap(root['bid']);
      return Bid.fromJson({
        'id': _string(bid['id']) ?? '',
        'campaignId': _string(bid['campaign_id']) ?? campaignId,
        'creatorId': _string(bid['creator_id']),
        'status': _string(bid['status']) ?? 'pending',
        'message': _string(bid['message']) ?? message,
        'createdAt': _string(bid['created_at']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<void> withdrawBid(String bidId) async {
    try {
      await _dio.delete('/creator/bids/$bidId');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<List<CollabRequest>> fetchRequests() async {
    try {
      final response = await _dio.get('/creator/requests');
      final root = _asMap(response.data);

      return _asMapList(root['requests'])
          .map((item) {
            final brand = _asMap(item['brand']);
            return CollabRequest.fromJson({
              'id': _string(item['id']) ?? '',
              'brandId': _string(item['brand_id']) ?? '',
              'brandName': _string(brand['brand_name']) ?? 'Brand',
              'brandCategory': _string(brand['brand_category']) ?? 'General',
              'brandInitial': _brandInitial(brand),
              'budgetPaise': _int(item['budget']) ?? 0,
              'collabType': _string(item['collab_type']) ?? 'paid',
              'deliverables': _stringList(item['deliverables']),
              'status': _string(item['status']) ?? 'pending',
              'createdAt': _string(item['created_at']),
            });
          })
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<Collab?> respondToRequest({
    required String requestId,
    required String action,
  }) async {
    try {
      final response = await _dio.put(
        '/creator/requests/$requestId',
        data: {'action': action},
      );

      final root = _asMap(response.data);
      final collabRaw = _asMap(root['collab']);
      if (collabRaw.isEmpty) return null;

      return Collab.fromJson({
        'id': _string(collabRaw['id']) ?? '',
        'brandId': _string(collabRaw['brand_id']) ?? '',
        'creatorId': _string(collabRaw['creator_id']) ?? '',
        'brandCategory': 'General',
        'agreedAmountPaise': _int(collabRaw['agreed_amount']) ?? 0,
        'collabType': _string(collabRaw['collab_type']) ?? 'paid',
        'status': _string(collabRaw['status']) ?? 'in_progress',
        'milestoneStatus': _string(collabRaw['milestone_status']),
        'createdAt': _string(collabRaw['created_at']),
        'completedAt': _string(collabRaw['completed_at']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<List<Collab>> fetchCreatorCollabs() async {
    try {
      final bids = await fetchMyBids();
      return bids
          .where(
            (bid) =>
                bid.status == 'accepted' ||
                bid.status == 'in_progress' ||
                bid.status == 'completed',
          )
          .map(
            (bid) => Collab(
              id: bid.id,
              brandId: bid.campaign?.id ?? '',
              creatorId: bid.creatorId ?? '',
              brandCategory: bid.campaign?.brandCategory ?? 'General',
              agreedAmountPaise: bid.campaign?.maxBudget ?? 0,
              collabType: bid.campaign?.collabType ?? CampaignCollabType.paid,
              status: bid.status,
              milestoneStatus: null,
              createdAt: bid.createdAt,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<Collab> updateCollabMilestone({
    required String collabId,
    required String milestone,
  }) async {
    try {
      final response = await _dio.put(
        '/creator/collabs/$collabId/milestone',
        data: {'milestone': milestone},
      );
      final root = _asMap(response.data);
      final collabRaw = _asMap(root['collab']);

      return Collab.fromJson({
        'id': _string(collabRaw['id']) ?? collabId,
        'brandId': _string(collabRaw['brand_id']) ?? '',
        'creatorId': _string(collabRaw['creator_id']) ?? '',
        'brandCategory': 'General',
        'agreedAmountPaise': _int(collabRaw['agreed_amount']) ?? 0,
        'collabType': _string(collabRaw['collab_type']) ?? 'paid',
        'status': _string(collabRaw['status']) ?? 'in_progress',
        'milestoneStatus': _string(collabRaw['milestone_status']) ?? milestone,
        'createdAt': _string(collabRaw['created_at']),
        'completedAt': _string(collabRaw['completed_at']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<WalletData> fetchWallet() async {
    try {
      final response = await _dio.get('/creator/wallet');
      final root = _asMap(response.data);
      return WalletData.fromJson({
        'balance': _int(root['balance']) ?? 0,
        'transactions': _asMapList(root['transactions'])
            .map(
              (txn) => {
                'id': _string(txn['id']) ?? '',
                'type': _string(txn['type']) ?? 'topup',
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
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<RazorpayOrder> createWalletTopupOrder(int amountPaise) async {
    try {
      final response = await _dio.post(
        '/creator/wallet',
        data: {'amount': amountPaise},
      );
      final root = _asMap(response.data);
      return RazorpayOrder.fromJson({
        'orderId': _string(root['order_id']) ?? '',
        'amountPaise': _int(root['amount']) ?? 0,
        'currency': _string(root['currency']) ?? 'INR',
        'keyId': _string(root['key_id']),
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<int> verifyWalletTopup({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _dio.post(
        '/creator/wallet/verify',
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        },
      );
      final root = _asMap(response.data);
      return _int(root['new_balance']) ?? 0;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<List<EventInvite>> fetchEventInvites({String? status}) async {
    try {
      final response = await _dio.get(
        '/creator/events',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      final root = _asMap(response.data);

      return _asMapList(root['invites'])
          .map(
            (item) {
              final event = _asMap(item['event']);
              final brand = _asMap(event['brand']);
              return EventInvite.fromJson({
                'id': _string(item['id']) ?? '',
                'eventId': _string(item['event_id']) ?? _string(event['id']) ?? '',
                'status': _string(item['status']) ?? 'pending',
                'qrCodeData': _string(item['qr_code_data']),
                'createdAt': _string(item['created_at']),
                'eventTitle': _string(event['title']) ?? 'Event',
                'eventDate': _string(event['event_date']),
                'location': _string(event['location']) ?? _string(event['venue_address']),
                'brandName': _string(brand['brand_name']),
                'brandLogoUrl': _string(brand['logo_url']),
              });
            },
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<EventInvite> respondToEventInvite({
    required String inviteId,
    required String action,
  }) async {
    try {
      final response = await _dio.put(
        '/creator/events/$inviteId',
        data: {'action': action},
      );
      final root = _asMap(response.data);
      final invite = _asMap(root['invite']);

      return EventInvite.fromJson({
        'id': _string(invite['id']) ?? inviteId,
        'eventId': _string(invite['event_id']) ?? '',
        'status': _string(invite['status']) ?? (action == 'accept' ? 'accepted' : 'declined'),
        'qrCodeData': _string(invite['qr_code_data']),
        'createdAt': _string(invite['created_at']),
        'eventTitle': 'Event',
      });
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Future<List<EventTicket>> fetchTickets() async {
    try {
      final response = await _dio.get('/creator/events/tickets');
      final root = _asMap(response.data);

      return _asMapList(root['tickets'])
          .map(
            (item) {
              final event = _asMap(item['event']);
              final brand = _asMap(event['brand']);
              return EventTicket.fromJson({
                'id': _string(item['id']) ?? '',
                'ticketCode': _string(item['ticket_code']),
                'qrCodeData': _string(item['qr_code_data']),
                'status': _string(item['status']) ?? 'accepted',
                'createdAt': _string(item['created_at']),
                'eventId': _string(event['id']) ?? '',
                'eventTitle': _string(event['title']) ?? 'Event',
                'eventDescription': _string(event['description']),
                'eventDate': _string(event['event_date']),
                'location': _string(event['location']) ?? _string(event['venue_address']),
                'imageUrl': _string(event['image_url']),
                'brandName': _string(brand['brand_name']),
                'brandLogoUrl': _string(brand['logo_url']),
              });
            },
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parse(e));
    }
  }

  Campaign _campaignFromApi(Map<String, dynamic> item) {
    final brand = _asMap(item['brand']);
    final bidCountRaw = item['bid_count'];

    final normalized = <String, dynamic>{
      'id': _string(item['id']) ?? '',
      'title': _string(item['title']) ?? 'Campaign',
      'brandCategory': _string(brand['brand_category']) ?? 'General',
      'brandInitial': _brandInitial(brand),
      'brandSize': _string(brand['size']),
      'minBudget': _int(item['budget_min']) ?? _int(item['min_budget']) ?? 0,
      'maxBudget': _int(item['budget_max']) ?? _int(item['max_budget']) ?? 0,
      'collabType': _string(item['collab_type']) ?? 'paid',
      'deliverables': _stringList(item['deliverables']),
      'bidCount': _extractBidCount(bidCountRaw),
      'deadline': _string(item['deadline']) ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'status': _string(item['status']) ?? 'active',
      'createdAt': _string(item['created_at']),
    };

    return Campaign.fromJson(normalized);
  }

  int _extractBidCount(dynamic raw) {
    if (raw is int) return raw;
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map && first['count'] is int) {
        return first['count'] as int;
      }
      if (first is Map && first['count'] is String) {
        return int.tryParse(first['count'] as String) ?? 0;
      }
    }
    return 0;
  }

  String _brandInitial(Map<String, dynamic> brand) {
    final name = _string(brand['brand_name']) ?? _string(brand['name']) ?? 'Brand';
    return name.trim().isEmpty ? 'B' : name.trim().substring(0, 1).toUpperCase();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value.map(_asMap).toList();
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.whereType<Object>().map((e) => e.toString()).toList();
    }
    return const [];
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

  String? _string(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString();
    return parsed.isEmpty ? null : parsed;
  }
}
