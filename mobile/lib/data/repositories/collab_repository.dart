import 'package:dio/dio.dart';

import '../../core/utils/api_error_handler.dart';
import '../models/creator_models.dart';
import '../services/api_service.dart';

class CollabRepository {
  CollabRepository(this._apiService);

  final ApiService _apiService;

  Dio get _dio => _apiService.client;

  Future<Collab> getCollab(String collabId) async {
    try {
      final response = await _dio.get('/collabs/$collabId');
      final root = _asMap(response.data);
      final collabRaw = _extractCollabMap(root);
      return _collabFromApi(collabRaw, fallbackId: collabId);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Collab> updateBrandMilestone(String collabId, String milestone) async {
    try {
      final response = await _dio.put(
        '/brand/collabs/$collabId/milestone',
        data: {'milestone': milestone},
      );

      final root = _asMap(response.data);
      final collabRaw = _extractCollabMap(root);
      return _collabFromApi(collabRaw, fallbackId: collabId, fallbackMilestone: milestone);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Collab> updateCreatorMilestone(String collabId, String milestone) async {
    try {
      final response = await _dio.put(
        '/creator/collabs/$collabId/milestone',
        data: {'milestone': milestone},
      );

      final root = _asMap(response.data);
      final collabRaw = _extractCollabMap(root);
      return _collabFromApi(collabRaw, fallbackId: collabId, fallbackMilestone: milestone);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> submitRating(
    String collabId,
    String ratedUserId,
    int score,
    String? review,
  ) async {
    try {
      await _dio.post(
        '/ratings',
        data: {
          'collab_id': collabId,
          'rated_user': ratedUserId,
          'score': score,
          if (review != null && review.trim().isNotEmpty) 'review': review.trim(),
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Collab _collabFromApi(
    Map<String, dynamic> raw, {
    required String fallbackId,
    String? fallbackMilestone,
  }) {
    final brand = _asMap(raw['brand']);
    final creator = _asMap(raw['creator']);

    return Collab.fromJson({
      'id': _string(raw['id']) ?? fallbackId,
      'brandId': _string(raw['brand_id']) ?? _string(brand['id']) ?? '',
      'creatorId': _string(raw['creator_id']) ?? _string(creator['id']) ?? '',
      'brandCategory': _string(brand['brand_category']) ??
          _string(brand['category']) ??
          _string(raw['brand_category']) ??
          'General',
      'agreedAmountPaise': _int(raw['agreed_amount']) ??
          _int(raw['agreed_amount_paise']) ??
          _int(raw['amount']) ??
          0,
      'collabType': _normalizeCollabType(_string(raw['collab_type'])),
      'status': _string(raw['status']) ?? 'in_progress',
      'milestoneStatus': _string(raw['milestone_status']) ?? fallbackMilestone,
      'createdAt': _string(raw['created_at']),
      'completedAt': _string(raw['completed_at']),
      'rating': _int(raw['rating']),
    });
  }

  String _normalizeCollabType(String? rawType) {
    switch ((rawType ?? '').toLowerCase()) {
      case 'barter':
        return 'barter';
      case 'hybrid':
        return 'hybrid';
      default:
        return 'paid';
    }
  }

  Map<String, dynamic> _extractCollabMap(Map<String, dynamic> root) {
    final nested = _asMap(root['collab']);
    return nested.isNotEmpty ? nested : root;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  int? _int(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String? _string(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString();
    return parsed.isEmpty ? null : parsed;
  }
}
