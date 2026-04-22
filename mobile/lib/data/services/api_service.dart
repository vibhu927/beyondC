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
        // Keep dev requests alive while Next.js compiles routes on first hit.
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        headers: const {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getValidAccessToken();
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
            final responseData = error.response?.data;
            final responseBody = responseData == null
                ? '<empty>'
                : responseData is String
                    ? responseData
                    : responseData.toString();

            debugPrint(
              '[API] ERROR ${error.requestOptions.method} ${error.requestOptions.uri} -> ${error.response?.statusCode}: ${error.message} | body=$responseBody',
            );
            debugPrint('[API] ERROR BODY: $responseBody');
          }

          final isUnauthorized = error.response?.statusCode == 401;
          final isRetried = error.requestOptions.extra['retried401'] == true;

          if (isUnauthorized && !isRetried) {
            final refreshed = await _refreshSessionSilently();
            if (refreshed) {
              try {
                final retryOptions = Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization':
                        'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken ?? ''}',
                  },
                  responseType: error.requestOptions.responseType,
                  contentType: error.requestOptions.contentType,
                  sendTimeout: error.requestOptions.sendTimeout,
                  receiveTimeout: error.requestOptions.receiveTimeout,
                  extra: {
                    ...error.requestOptions.extra,
                    'retried401': true,
                  },
                );

                final retryResponse = await _dio.request<dynamic>(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: retryOptions,
                );

                handler.resolve(retryResponse);
                return;
              } catch (_) {
                // If retry fails, continue with default error handling below.
              }
            }
          }

          if (isUnauthorized && !_isHandlingUnauthorized) {
            _isHandlingUnauthorized = true;
            try {
              final refreshed = await _refreshSessionSilently();
              if (!refreshed) {
                if (_ref != null) {
                  await _ref!.read(authProvider.notifier).signOut();
                } else {
                  await Supabase.instance.client.auth.signOut();
                }
                RouterHolder.router?.go(RouteNames.login);
              }
            } catch (_) {
              await Supabase.instance.client.auth.signOut();
              RouterHolder.router?.go(RouteNames.login);
            } finally {
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

  Future<String?> _getValidAccessToken() async {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    if (session == null) return null;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) {
      return session.accessToken;
    }

    final expiryUtc = DateTime.fromMillisecondsSinceEpoch(
      expiresAt * 1000,
      isUtc: true,
    );

    // Refresh a little early to avoid edge 401s during request transit.
    final shouldRefresh = expiryUtc
        .subtract(const Duration(minutes: 2))
        .isBefore(DateTime.now().toUtc());

    if (!shouldRefresh) {
      return session.accessToken;
    }

    final refreshed = await _refreshSessionSilently();
    if (!refreshed) {
      return session.accessToken;
    }

    return auth.currentSession?.accessToken;
  }

  Future<bool> _refreshSessionSilently() async {
    try {
      final auth = Supabase.instance.client.auth;
      final current = auth.currentSession;
      if (current == null) return false;

      final refreshed = await auth.refreshSession();
      return refreshed.session != null;
    } catch (_) {
      return false;
    }
  }

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
