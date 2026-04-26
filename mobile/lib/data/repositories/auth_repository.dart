import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import '../../core/constants/api_constants.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  /// Sign up with email, password, and role metadata
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String fullName,
    required String phone,
    required String state,
    required String city,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/auth/signup',
        data: {
          'email': email,
          'password': password,
          'role': role,
          'display_name': firstName,
          'first_name': firstName,
          'full_name': fullName,
          'phone': phone,
          'state': state,
          'city': city,
          ...?extraData,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Could not create account. Please try again.');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        throw Exception(data['error'] as String);
      }

      final code = e.response?.statusCode;
      if (code == null) {
        throw Exception(
          'Could not reach local backend. Ensure API is running at ${ApiConstants.apiBaseUrl}.',
        );
      }

      throw Exception(e.message ?? 'Signup failed');
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      return response;
    } on SocketException {
      // Physical devices can fail DNS lookup for *.supabase.co on some networks.
      // Fallback to backend login and hydrate local Supabase session from tokens.
      return await _signInViaBackend(
        email: normalizedEmail,
        password: password,
      );
    } on AuthRetryableFetchException {
      return await _signInViaBackend(
        email: normalizedEmail,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> _signInViaBackend({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid login response from backend.');
      }

      final session = data['session'];
      if (session is! Map<String, dynamic>) {
        throw Exception('Session missing in backend login response.');
      }

      final accessToken = (session['access_token'] ?? session['accessToken']) as String?;
      final refreshToken = (session['refresh_token'] ?? session['refreshToken']) as String?;

      if (accessToken == null || refreshToken == null) {
        throw Exception('Login tokens missing from backend response.');
      }

      final authResponse = await _supabase.auth.setSession(refreshToken);

      return authResponse;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        throw Exception(data['error'] as String);
      }

      final code = e.response?.statusCode;
      if (code == null) {
        throw Exception(
          'Network issue: could not reach Supabase or backend. Check internet and API host (${ApiConstants.apiBaseUrl}).',
        );
      }

      throw Exception(e.message ?? 'Login failed');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiBaseUrl}/auth/forgot-password',
        data: {
          'email': email.trim().toLowerCase(),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Could not send reset link. Please try again.');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) {
        throw Exception(data['error'] as String);
      }
      throw Exception(
        e.message ?? 'Could not send reset link. Please try again.',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user's role from metadata
  String? getCurrentRole() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return user.userMetadata?['role'] as String?;
  }

  /// Check if user has completed onboarding.
  /// For now, we consider user onboarded if they have a supported role in metadata.
  Future<bool> isOnboarded() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final role = user.userMetadata?['role'];
    return role != null &&
        (role == 'creator' || role == 'brand' || role == 'agency');
  }

  /// Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Get auth state stream
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
