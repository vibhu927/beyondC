import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'api_service.dart';

class InstagramOAuthResult {
  const InstagramOAuthResult({
    required this.status,
    this.username,
  });

  final String status;
  final String? username;

  bool get isSuccess => status == 'success';
}

class InstagramOAuthService {
  InstagramOAuthService(this._apiService);

  final ApiService _apiService;

  Future<InstagramOAuthResult> connectInstagram() async {
    final response = await _apiService.client.get(
      '/auth/instagram/connect',
      queryParameters: const {'platform': 'mobile'},
    );

    final data = response.data;
    final authUrl = data is Map<String, dynamic> ? data['url'] as String? : null;
    if (authUrl == null || authUrl.isEmpty) {
      throw Exception('Could not create Instagram auth URL');
    }

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'beyondc',
    );

    final uri = Uri.parse(result);
    final status = uri.queryParameters['status'] ?? 'error';
    final username = uri.queryParameters['username'];

    return InstagramOAuthResult(status: status, username: username);
  }

  Future<void> refreshStats() async {
    await _apiService.client.post('/instagram/refresh-stats');
  }

  String extractApiError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is String) {
        return data['error'] as String;
      }
      return error.message ?? 'Request failed';
    }

    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}

final instagramOAuthServiceProvider = Provider<InstagramOAuthService>((ref) {
  return InstagramOAuthService(ref.read(apiServiceProvider));
});
