import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';

class AuthState {
  final User? user;
  final String? role; // 'creator' | 'brand'
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

      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
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

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
