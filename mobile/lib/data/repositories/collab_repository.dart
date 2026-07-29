import 'package:dio/dio.dart';

import '../../core/utils/api_error_handler.dart';
import '../models/creator_models.dart';
import '../services/api_service.dart';

class CollabRepository {
  CollabRepository(this._apiService);

  final ApiService _apiService;

  Dio get _dio => _apiService.client;

  Future<Collab> getCollab(String collabId) async {
    // Try creator-scoped endpoint first
    try {
      final response = await _dio.get('/creator/collabs/$collabId');
      final root = _asMap(response.data);
      final collabRaw = _extractCollabMap(root);
      return _collabFromApi(collabRaw, fallbackId: collabId);
    } on DioException catch (_) {}
    
    // Try brand-scoped endpoint
    try {
      final response = await _dio.get('/brand/collabs/$collabId');
      final root = _asMap(response.data);
      final collabRaw = _extractCollabMap(root);
      return _collabFromApi(collabRaw, fallbackId: collabId);
    } on DioException catch (_) {}
    
    // Try shared endpoint
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
      'collabStatus': _string(raw['collab_status']) ?? 'started',
      'statusUpdatedAt': _string(raw['status_updated_at']),
      'statusUpdateMessage': _string(raw['status_update_message']),
      'contractTerms': raw['contract_terms'] as Map<String, dynamic>?,
      'creatorContractAccepted': raw['creator_contract_accepted'] == true,
      'brandContractAccepted': raw['brand_contract_accepted'] == true,
      'creatorContractAcceptedAt': _string(raw['creator_contract_accepted_at']),
      'brandContractAcceptedAt': _string(raw['brand_contract_accepted_at']),
      'paymentStructure': _string(raw['payment_structure']) ?? 'full_upfront',
    });
  }

  Future<Collab> updateCollabStatus(String collabId, String status, {String? message}) async {
    try {
      final response = await _dio.put(
        '/creator/collabs/$collabId/status',
        data: {
          'status': status,
          if (message != null && message.isNotEmpty) 'message': message,
        },
      );

      final root = _asMap(response.data);
      final collabRaw = _extractCollabMap(root);
      return _collabFromApi(collabRaw, fallbackId: collabId);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Map<String, dynamic>> getContract(String collabId) async {
    try {
      final response = await _dio.get('/collabs/$collabId/contract');
      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> createContract(String collabId, Map<String, dynamic> terms) async {
    try {
      await _dio.post('/collabs/$collabId/contract', data: terms);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> acceptContract(String collabId) async {
    try {
      await _dio.put('/collabs/$collabId/contract/accept');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<Map<String, dynamic>>> getContentSubmissions(String collabId) async {
    try {
      final response = await _dio.get('/collabs/$collabId/submissions');
      final data = _asMap(response.data);
      final list = data['submissions'];
      if (list is List) {
        return list.map((e) => _asMap(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Map<String, dynamic>> submitContent(
    String collabId, {
    required String contentUrl,
    required String contentType,
    String? caption,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/collabs/$collabId/submissions',
        data: {
          'content_url': contentUrl,
          'content_type': contentType,
          if (caption != null) 'caption': caption,
          if (notes != null) 'notes': notes,
        },
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> reviewContent(
    String collabId,
    String submissionId, {
    required String status,
    String? feedback,
  }) async {
    try {
      await _dio.put(
        '/collabs/$collabId/submissions/$submissionId',
        data: {
          'status': status,
          if (feedback != null) 'brand_feedback': feedback,
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentMilestones(String collabId) async {
    try {
      final response = await _dio.get('/collabs/$collabId/payment-milestones');
      final data = _asMap(response.data);
      final list = data['milestones'];
      if (list is List) {
        return list.map((e) => _asMap(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> setPaymentMilestones(
    String collabId, {
    required String paymentStructure,
    List<Map<String, dynamic>>? milestones,
  }) async {
    try {
      await _dio.post(
        '/collabs/$collabId/payment-milestones',
        data: {
          'payment_structure': paymentStructure,
          if (milestones != null) 'milestones': milestones,
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<void> releasePaymentMilestone(String collabId, String milestoneId) async {
    try {
      await _dio.post('/collabs/$collabId/payment-milestones/$milestoneId/release');
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
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
