import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/api_error_handler.dart';
import '../models/brand_models.dart';
import '../models/home_carousel_item.dart';
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
        'portfolioLinks': _stringList(brand['portfolio_links']),
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
        'state': _string(profile['state']),
        'city': _string(profile['city']),
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
        'portfolioLinks': _stringList(brand['portfolio_links']),
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
        'state': _string(profile['state']),
        'city': _string(profile['city']),
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

  Future<List<HomeCarouselItem>> fetchHomeCarouselItems() async {
    try {
      final response = await _dio.get(
        '/home/carousel',
        queryParameters: {'audience': 'brand'},
      );

      final root = _asMap(response.data);
      final payload = _asMap(root['data']);
      final items = _asMapList(
        payload['items'] ?? root['items'],
      );

      return items
          .map((item) {
            return HomeCarouselItem(
              id: _string(item['id']) ?? '',
              audience: _string(item['audience']) ?? 'brand',
              mediaUrl: _string(item['media_url']) ?? '',
              caption: _string(item['caption']),
              sortOrder: _int(item['sort_order']) ?? 0,
            );
          })
          .where((item) => item.id.isNotEmpty && item.mediaUrl.isNotEmpty)
          .toList();
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
    String? state,
    String? city,
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
          if (state != null && state.isNotEmpty) 'state': state,
          if (city != null && city.isNotEmpty) 'city': city,
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
          'firstName': _resolveCreatorFirstName(item),
          'avatarUrl': _string(item['avatar_url']),
          'state': _string(item['state']),
          'city': _string(item['city']),
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
          'instagramVerified': _bool(item['instagram_verified']) ?? false,
        });
      }).toList();

      final enrichedCreators = await _hydrateCreatorNamesFromProfiles(creators);

      if (enrichedCreators.isNotEmpty) {
        return PaginatedResult<CreatorDiscovery>(
          items: enrichedCreators,
          page: _int(pagination['page']) ?? page,
          limit: _int(pagination['limit']) ?? limit,
          total: _int(pagination['total']) ?? enrichedCreators.length,
          totalPages: _int(pagination['total_pages']) ??
              _int(pagination['totalPages']) ??
              1,
        );
      }

      final fallback = await _getCreatorsFallback(
        niche: niche,
        tier: tier,
        minFollowers: minFollowers,
        state: state,
        city: city,
        page: page,
        limit: limit,
      );

      if (fallback.items.isNotEmpty) {
        return fallback;
      }

      return PaginatedResult<CreatorDiscovery>(
        items: enrichedCreators,
        page: _int(pagination['page']) ?? page,
        limit: _int(pagination['limit']) ?? limit,
        total: _int(pagination['total']) ?? enrichedCreators.length,
        totalPages: _int(pagination['total_pages']) ??
            _int(pagination['totalPages']) ??
            1,
      );
    } on DioException catch (e) {
      final fallback = await _getCreatorsFallback(
        niche: niche,
        tier: tier,
        minFollowers: minFollowers,
        state: state,
        city: city,
        page: page,
        limit: limit,
      );

      if (fallback.items.isNotEmpty) {
        return fallback;
      }

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
        'creatorInstagramHandle':
            _string(request['creator_instagram_handle']) ??
                _string(request['creator_instagram_username']),
        'creatorTier': _string(request['creator_tier']),
        'collabId': _string(request['collab_id']),
        'message': _string(request['message']),
        'budget': _int(request['budget']),
        'collabType': _normalizeCollabType(_string(request['collab_type'])),
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

      final parsed = <CollabRequest>[];
      for (final item in _asMapList(root['requests'])) {
        try {
          final creator = _asMap(item['creator']);
          final creatorUser = _asMap(item['creator_user']);
          final creatorFirstName = _string(creatorUser['first_name']) ??
              _string(item['creator_first_name']) ??
              _string(creatorUser['full_name']) ??
              _string(item['creator_full_name']) ??
              'Creator';
          final creatorFullName = _string(creatorUser['full_name']) ??
              _string(item['creator_full_name']) ??
              _string(creatorUser['first_name']) ??
              _string(item['creator_first_name']) ??
              'Creator';

          parsed.add(
            CollabRequest.fromJson({
              'id': _string(item['id']) ?? '',
              'brandId': _string(item['brand_id']) ?? '',
              'creatorId': _string(item['creator_id']) ?? '',
              'creatorFirstName': creatorFirstName,
              'creatorFullName': creatorFullName,
              'creatorInstagramHandle':
                  _string(creator['instagram_username']) ??
                      _string(item['creator_instagram_handle']) ??
                      _string(creator['instagram_handle']),
              'creatorTier': _string(creator['tier']) ??
                  _string(item['creator_tier']) ??
                  'micro',
              'collabId': _string(item['collab_id']),
              'message': _string(item['message']),
              'budget': _int(item['budget']),
              'collabType': _normalizeCollabType(_string(item['collab_type'])),
              'deliverables': _stringList(item['deliverables']),
              'status': _string(item['status']) ?? 'pending',
              'expiresAt': _string(item['expires_at']),
              'createdAt': _string(item['created_at']),
              'updatedAt': _string(item['updated_at']),
            }),
          );
        } catch (_) {
          // Skip malformed rows instead of failing the whole requests screen.
        }
      }
      return parsed;
    } on DioException {
      final fallback = await _getRequestsFallback();
      if (fallback.isNotEmpty) return fallback;

      // Keep requests UI functional on hosted schema mismatches by
      // surfacing an empty state instead of crashing the provider.
      return const <CollabRequest>[];
    }
  }

  Future<PaginatedResult<CreatorDiscovery>> _getCreatorsFallback({
    String? niche,
    String? tier,
    int? minFollowers,
    String? state,
    String? city,
    required int page,
    required int limit,
  }) async {
    final client = Supabase.instance.client;
    final from = (page - 1) * limit;
    final to = from + limit - 1;

    try {
      var filterQuery = client.from('creator_discovery_view').select();

      if (niche != null && niche.isNotEmpty) {
        filterQuery = filterQuery.contains('niche', [niche]);
      }
      if (tier != null && tier.isNotEmpty) {
        filterQuery = filterQuery.eq('tier', tier.toLowerCase());
      }
      if (minFollowers != null) {
        filterQuery = filterQuery.gte('follower_count', minFollowers);
      }
      if (state != null && state.isNotEmpty) {
        filterQuery = filterQuery.eq('state', state);
      }
      if (city != null && city.isNotEmpty) {
        filterQuery = filterQuery.eq('city', city);
      }

      final rows = (await filterQuery
          .order('follower_count', ascending: false)
          .range(from, to)) as List<dynamic>;
      final mapped = rows
          .whereType<Map>()
          .map((row) => _mapCreatorRow(row.cast<String, dynamic>()))
          .toList();

      if (mapped.isNotEmpty) {
        return PaginatedResult<CreatorDiscovery>(
          items: mapped,
          page: page,
          limit: limit,
          total: mapped.length,
          totalPages: 1,
        );
      }
    } catch (_) {
      // Fall through to table fallback.
    }

    try {
      var filterQuery = client.from('creator_profiles').select(
            'id,niche,content_type,platforms,tier,starting_price,avg_rating,total_collabs,engagement_rate,bio,portfolio_links,follower_count,instagram_username,profile:profiles(first_name,avatar_url)',
          );

      if (niche != null && niche.isNotEmpty) {
        filterQuery = filterQuery.contains('niche', [niche]);
      }
      if (tier != null && tier.isNotEmpty) {
        filterQuery = filterQuery.eq('tier', tier.toLowerCase());
      }
      if (minFollowers != null) {
        filterQuery = filterQuery.gte('follower_count', minFollowers);
      }

      final rows = (await filterQuery
          .order('follower_count', ascending: false)
          .range(from, to)) as List<dynamic>;
      final mapped = <CreatorDiscovery>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final data = row.cast<String, dynamic>();
        final profile = _firstMap(data['profile']);
        mapped.add(
          CreatorDiscovery.fromJson({
            'id': _string(data['id']) ?? '',
            'firstName': _resolveCreatorFirstName(data, profile: profile),
            'avatarUrl': _string(profile['avatar_url']),
            'state': _string(profile['state']),
            'city': _string(profile['city']),
            'niches': _stringList(data['niche']),
            'contentTypes':
                _stringList(data['platforms'] ?? data['content_type']),
            'tier': _string(data['tier']) ?? 'micro',
            'startingPrice': _int(data['starting_price']) ?? 0,
            'avgRating': _double(data['avg_rating']) ?? 0,
            'totalCollabs': _int(data['total_collabs']) ?? 0,
            'engagementRate': _double(data['engagement_rate']) ?? 0,
            'bio': _string(data['bio']) ?? '',
            'portfolioLinks': _stringList(data['portfolio_links']),
            'followerRange':
                _followerRangeFromCount(_int(data['follower_count']) ?? 0),
            'followersCount': _int(data['follower_count']) ?? 0,
            'instagramVerified': false,
          }),
        );
      }

      final enriched = await _hydrateCreatorNamesFromProfiles(mapped);

      return PaginatedResult<CreatorDiscovery>(
        items: enriched,
        page: page,
        limit: limit,
        total: enriched.length,
        totalPages: 1,
      );
    } catch (_) {
      return PaginatedResult<CreatorDiscovery>(
        items: const <CreatorDiscovery>[],
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
      );
    }
  }

  CreatorDiscovery _mapCreatorRow(Map<String, dynamic> item) {
    final followers =
        _int(item['follower_count']) ?? _int(item['followers_count']) ?? 0;
    final profile = _firstMap(item['profile']);

    return CreatorDiscovery.fromJson({
      'id': _string(item['id']) ?? '',
      'firstName': _resolveCreatorFirstName(item, profile: profile),
      'avatarUrl':
          _string(item['avatar_url']) ?? _string(profile['avatar_url']),
      'niches': _stringList(item['niches'] ?? item['niche']),
      'contentTypes': _stringList(item['platforms'] ?? item['content_type']),
      'tier': _string(item['tier']) ?? 'micro',
      'startingPrice': _int(item['starting_price']) ?? 0,
      'avgRating': _double(item['avg_rating']) ?? 0,
      'totalCollabs': _int(item['total_collabs']) ?? 0,
      'engagementRate': _double(item['engagement_rate']) ?? 0,
      'bio': _string(item['bio']) ?? '',
      'portfolioLinks': _stringList(item['portfolio_links']),
      'followerRange':
          _string(item['follower_range']) ?? _followerRangeFromCount(followers),
      'followersCount': followers,
      'instagramVerified': _bool(item['instagram_verified']) ?? false,
    });
  }

  String _resolveCreatorFirstName(
    Map<String, dynamic> item, {
    Map<String, dynamic>? profile,
  }) {
    final sourceProfile = profile ?? _firstMap(item['profile']);

    final firstName = _normalizedName(_string(item['first_name'])) ??
        _normalizedName(_string(sourceProfile['first_name'])) ??
        _normalizedName(_firstToken(_string(item['display_name']))) ??
        _normalizedName(_firstToken(_string(sourceProfile['display_name']))) ??
        _normalizedName(_firstToken(_string(item['full_name']))) ??
        _normalizedName(_firstToken(_string(sourceProfile['full_name']))) ??
        _normalizedName(_firstToken(_string(item['creator_full_name']))) ??
        _normalizedName(_firstToken(_string(item['username']))) ??
        _normalizedName(_firstToken(_string(item['instagram_username'])));

    return firstName ?? 'Creator';
  }

  String? _normalizedName(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final lowered = trimmed.toLowerCase();
    if (lowered == 'creator' || lowered == 'user' || lowered == 'unknown') {
      return null;
    }

    return trimmed;
  }

  String? _firstToken(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final token = trimmed.split(RegExp(r'\s+')).first.trim();
    return token.isEmpty ? null : token;
  }

  Future<List<CreatorDiscovery>> _hydrateCreatorNamesFromProfiles(
    List<CreatorDiscovery> creators,
  ) async {
    final unresolvedIds = creators
        .where((c) => _normalizedName(c.firstName) == null)
        .map((c) => c.id)
        .where((id) => id.trim().isNotEmpty)
        .toList();

    if (unresolvedIds.isEmpty) return creators;

    try {
      final rows = await Supabase.instance.client
          .from('profiles')
          .select('id,first_name,full_name')
          .inFilter('id', unresolvedIds);

      final byId = <String, String>{};
      for (final row in rows) {
        final item = row;
        final resolved = _normalizedName(_string(item['first_name'])) ??
            _normalizedName(_firstToken(_string(item['full_name'])));
        final id = _string(item['id']);
        if (id != null && resolved != null) {
          byId[id] = resolved;
        }
      }

      return creators
          .map((c) =>
              byId.containsKey(c.id) ? c.copyWith(firstName: byId[c.id]!) : c)
          .toList();
    } catch (_) {
      return creators;
    }
  }

  Future<List<CollabRequest>> _getRequestsFallback() async {
    final client = Supabase.instance.client;

    try {
      final rows = await client
          .from('collab_requests')
          .select(
            'id,brand_id,creator_id,message,budget,collab_type,deliverables,status,expires_at,created_at,updated_at,creator:creator_profiles(id,tier)',
          )
          .order('created_at', ascending: false);

      final parsed = <CollabRequest>[];
      for (final row in rows) {
        final item = row;
        final creator = _asMap(item['creator']);
        parsed.add(
          CollabRequest.fromJson({
            'id': _string(item['id']) ?? '',
            'brandId': _string(item['brand_id']) ?? '',
            'creatorId': _string(item['creator_id']) ?? '',
            'creatorFirstName':
                _string(item['creator_first_name']) ?? 'Creator',
            'creatorFullName': _string(item['creator_full_name']) ?? 'Creator',
            'creatorInstagramHandle': _string(item['creator_instagram_handle']),
            'creatorTier': _string(creator['tier']) ??
                _string(item['creator_tier']) ??
                'micro',
            'collabId': _string(item['collab_id']),
            'message': _string(item['message']),
            'budget': _int(item['budget']),
            'collabType': _normalizeCollabType(_string(item['collab_type'])),
            'deliverables': _stringList(item['deliverables']),
            'status': _string(item['status']) ?? 'pending',
            'expiresAt': _string(item['expires_at']),
            'createdAt': _string(item['created_at']),
            'updatedAt': _string(item['updated_at']),
          }),
        );
      }

      return parsed;
    } catch (_) {
      return const <CollabRequest>[];
    }
  }

  String _followerRangeFromCount(int count) {
    if (count >= 500000) return '500K+';
    if (count >= 100000) return '100K-500K';
    if (count >= 50000) return '50K-100K';
    if (count >= 10000) return '10K-50K';
    if (count >= 5000) return '5K-10K';
    return '1K-5K';
  }

  Future<Campaign> postCampaign(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/brand/campaigns',
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
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

      final collabs = _asMapList(root['collabs']).map((item) {
        return ActiveCollabSummary.fromJson({
          'id': _string(item['id']) ?? '',
          'creatorId': _string(item['creator_id']) ?? '',
          'creatorName': _resolveCreatorName(item),
          'campaignId': _string(item['campaign_id']),
          'campaignTitle': _string(item['campaign_title']) ?? 'Campaign',
          'status': _string(item['status']) ?? 'active',
          'agreedAmount': _int(item['agreed_amount']),
          'startedAt':
              _string(item['started_at']) ?? _string(item['created_at']),
        });
      }).toList();

      return _hydrateCollabNamesFromProfiles(collabs);
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

      final collabs = _asMapList(root['collabs']).map((item) {
        return ActiveCollabSummary.fromJson({
          'id': _string(item['id']) ?? '',
          'creatorId': _string(item['creator_id']) ?? '',
          'creatorName': _resolveCreatorName(item),
          'campaignId': _string(item['campaign_id']),
          'campaignTitle': _string(item['campaign_title']) ?? 'Campaign',
          'status': _string(item['status']) ?? 'completed',
          'agreedAmount': _int(item['agreed_amount']),
          'startedAt':
              _string(item['started_at']) ?? _string(item['created_at']),
        });
      }).toList();

      return _hydrateCollabNamesFromProfiles(collabs);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  String _resolveCreatorName(Map<String, dynamic> item) {
    return _normalizedName(_string(item['creator_name'])) ??
        _normalizedName(_firstToken(_string(item['creator_full_name']))) ??
        _normalizedName(_firstToken(_string(item['full_name']))) ??
        _normalizedName(_string(item['creator_first_name'])) ??
        _normalizedName(_string(item['first_name'])) ??
        _normalizedName(
            _firstToken(_string(item['creator_instagram_handle']))) ??
        _normalizedName(_firstToken(_string(item['instagram_username']))) ??
        'Creator';
  }

  Future<List<ActiveCollabSummary>> _hydrateCollabNamesFromProfiles(
    List<ActiveCollabSummary> collabs,
  ) async {
    final unresolvedIds = collabs
        .where((c) => _normalizedName(c.creatorName) == null)
        .map((c) => c.creatorId)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();

    if (unresolvedIds.isEmpty) return collabs;

    try {
      final rows = await Supabase.instance.client
          .from('profiles')
          .select('id,first_name,full_name')
          .inFilter('id', unresolvedIds);

      final byId = <String, String>{};
      for (final row in rows) {
        final item = row;
        final resolved = _normalizedName(_string(item['first_name'])) ??
            _normalizedName(_firstToken(_string(item['full_name'])));
        final id = _string(item['id']);
        if (id != null && resolved != null) {
          byId[id] = resolved;
        }
      }

      return collabs.map((collab) {
        final hydratedName = byId[collab.creatorId];
        if (hydratedName == null) return collab;

        return ActiveCollabSummary(
          id: collab.id,
          creatorId: collab.creatorId,
          creatorName: hydratedName,
          campaignId: collab.campaignId,
          campaignTitle: collab.campaignTitle,
          status: collab.status,
          agreedAmount: collab.agreedAmount,
          startedAt: collab.startedAt,
        );
      }).toList();
    } catch (_) {
      return collabs;
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
        final campaign = _asMap(item['campaign']);
        final creatorId =
            _string(item['creator_id']) ?? _string(creator['id']) ?? '';
        final creatorNiche = creator['niche'] ?? creator['niches'];
        final creatorFollowers =
            _int(creator['follower_count']) ?? _int(creator['followers_count']);
        final creatorEngagement = _double(creator['engagement_rate']) ??
            _double(creator['avg_rating']) ??
            0;
        final creatorFullName =
            _string(item['creator_full_name']) ?? _string(creator['full_name']);
        final creatorFirstName = _string(item['creator_first_name']) ??
            _string(creator['first_name']) ??
            (() {
              final name = (creatorFullName ?? '').trim();
              if (name.isEmpty) return null;
              return name.split(RegExp(r'\s+')).first;
            })();
        final creatorAvatarUrl = _string(item['creator_avatar_url']) ??
            _string(creator['avatar_url']);
        final bidAmount = _int(item['bid_amount']) ??
            _int(campaign['budget_min']) ??
            _int(campaign['budget']) ??
            _int(campaign['budget_max']) ??
            0;

        return Bid.fromJson({
          'id': _string(item['id']) ?? '',
          'campaignId': _string(item['campaign_id']) ?? campaignId,
          'creatorId': creatorId,
          'bidAmount': bidAmount,
          'deliverables': _string(item['deliverables']) ?? '',
          'message': _string(item['message']),
          'status': _string(item['status']) ?? 'pending',
          'includeBarter': _bool(item['include_barter']) ?? false,
          'createdAt': _string(item['created_at']),
          'updatedAt': _string(item['updated_at']),
          'creatorFirstName': creatorFirstName ?? 'Creator',
          'creatorFullName': creatorFullName ?? creatorFirstName ?? 'Creator',
          'creatorHandle': _string(creator['instagram_handle']) ??
              _string(creator['handle']) ??
              '',
          'tier': _string(creator['tier']) ?? 'micro',
          'followersCount': creatorFollowers ?? 0,
          'engagementRate': creatorEngagement,
          'niches': _stringList(creatorNiche),
          'creatorAvatarUrl': creatorAvatarUrl,
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
      'targetState': _string(item['target_state']),
      'targetCity': _string(item['target_city']),
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
      'state': _string(item['state']),
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
