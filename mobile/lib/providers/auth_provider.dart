import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';

class AuthState {
  final User? user;
  final String? role; // 'creator' | 'brand' | 'agency'
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.role,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    String? role,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);

    // Listen to Supabase auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        final role = user.userMetadata?['role'] as String?;
        state = state.copyWith(user: user, role: role, isLoading: false);
      } else {
        state = const AuthState();
      }
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      final role = currentUser.userMetadata?['role'] as String?;
      return AuthState(user: currentUser, role: role);
    }

    return const AuthState();
  }

  /// Sign up with email and password

  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String fullName,
    required String phone,
    required String locationState,
    required String locationCity,
    Map<String, dynamic>? extraData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        fullName: fullName,
        phone: phone,
        state: locationState,
        city: locationCity,
        extraData: extraData,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign up via backend API and immediately sign in on device.
  /// This keeps a live local session so router does not bounce back to onboarding.
  Future<AuthResponse> signUpAndSignIn({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String fullName,
    required String phone,
    required String locationState,
    required String locationCity,
    Map<String, dynamic>? extraData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        fullName: fullName,
        phone: phone,
        state: locationState,
        city: locationCity,
        extraData: extraData,
      );

      final authResponse = await _authRepository.signIn(
        email: email,
        password: password,
      );

      final signedInUser = authResponse.user;
      final signedInRole =
          signedInUser?.userMetadata?['role'] as String? ?? role;

      state = state.copyWith(
        user: signedInUser,
        role: signedInRole,
        isLoading: false,
        error: null,
      );

      return authResponse;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      final signedInUser =
          response.user ?? Supabase.instance.client.auth.currentUser;
      final signedInRole = signedInUser?.userMetadata?['role'] as String?;

      state = state.copyWith(
        user: signedInUser,
        role: signedInRole,
        isLoading: false,
        error: null,
      );

      return response;
    } catch (e) {
      final message = e is AuthException
          ? e.message
          : e.toString().replaceFirst('Exception: ', '');

      state = state.copyWith(
        isLoading: false,
        error: message.isEmpty ? 'Login failed' : message,
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Check if user is onboarded
  Future<bool> isOnboarded() async {
    return await _authRepository.isOnboarded();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
