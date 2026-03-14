import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Dio _dio = Dio();

  /// Sign up with email, password, and role metadata
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String fullName,
    required String phone,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.apiBaseUrl}/auth/signup',
        data: {
          'email': email,
          'password': password,
          'role': role,
          'display_name': firstName,
          'first_name': firstName,
          'full_name': fullName,
          'phone': phone,
          ...?extraData,
        },
        options: Options(
          headers: const {
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['error'] is String) {
        throw Exception(data['error'] as String);
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
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
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
      await _supabase.auth.resetPasswordForEmail(email);
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

  /// Check if user has completed onboarding
  /// For now, we consider user onboarded if they have a role in metadata
  /// In future, you might check a separate onboarding_completed flag
  Future<bool> isOnboarded() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final role = user.userMetadata?['role'];
    return role != null && (role == 'creator' || role == 'brand');
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
