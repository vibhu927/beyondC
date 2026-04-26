import 'package:dio/dio.dart';

import '../../core/utils/api_error_handler.dart';
import '../services/api_service.dart';

class AgencyRepository {
  AgencyRepository(this._api);

  final ApiService _api;

  Dio get _dio => _api.client;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/agency/profile');
      final data = response.data as Map<String, dynamic>;
      return _normalizeAgencyProfile(data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put('/agency/profile', data: payload);
      final data = response.data as Map<String, dynamic>;
      return _normalizeAgencyProfile(data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<dynamic>> getCreators({Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get('/agency/creators', queryParameters: params);
      return response.data['creators'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<dynamic>> getInvites() async {
    try {
      final response = await _dio.get('/agency/invites');
      return response.data['invites'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<dynamic>> getRoster() async {
    try {
      final response = await _dio.get('/agency/roster');
      return response.data['roster'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<dynamic>> getPitches() async {
    try {
      final response = await _dio.get('/agency/pitches');
      return response.data['pitches'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Future<List<dynamic>> getBids() async {
    try {
      final response = await _dio.get('/agency/bids');
      return response.data['bids'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.parseError(e));
    }
  }

  Map<String, dynamic> _normalizeAgencyProfile(Map<String, dynamic> payload) {
    final profileRaw = payload['profile'];
    if (profileRaw is! Map) {
      return payload;
    }

    final profile = Map<String, dynamic>.from(profileRaw as Map);
    final agencyRaw = profile['agency'];

    Map<String, dynamic> agency = const <String, dynamic>{};
    if (agencyRaw is Map) {
      agency = Map<String, dynamic>.from(agencyRaw as Map);
    } else if (agencyRaw is List &&
        agencyRaw.isNotEmpty &&
        agencyRaw.first is Map) {
      agency = Map<String, dynamic>.from(agencyRaw.first as Map);
    }

    return {
      ...profile,
      ...agency,
      'profile': profile,
      'agency': agency,
    };
  }
}
