import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/api_constants.dart';
import '../../core/router/router_holder.dart';
import '../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';

class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = Supabase.instance.client.auth.currentSession?.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            debugPrint('[API] ${options.method} ${options.uri}');
            if (options.data != null) {
              debugPrint('[API] body: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '[API] ${response.requestOptions.method} ${response.requestOptions.uri} -> ${response.statusCode}',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            debugPrint(
              '[API] ERROR ${error.requestOptions.method} ${error.requestOptions.uri} -> ${error.response?.statusCode}: ${error.message}',
            );
          }

          if (error.response?.statusCode == 401 && !_isHandlingUnauthorized) {
            _isHandlingUnauthorized = true;
            try {
              if (_ref != null) {
                await _ref!.read(authProvider.notifier).signOut();
              } else {
                await Supabase.instance.client.auth.signOut();
              }
            } catch (_) {
              await Supabase.instance.client.auth.signOut();
            } finally {
              RouterHolder.router?.go(RouteNames.login);
              _isHandlingUnauthorized = false;
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late final Dio _dio;
  Ref? _ref;
  bool _isHandlingUnauthorized = false;

  void bindRef(Ref ref) {
    _ref = ref;
  }

  Dio get client => _dio;
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  service.bindRef(ref);
  return service;
});
