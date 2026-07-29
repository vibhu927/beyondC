import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondc/providers/auth_provider.dart';

void main() {
  group('AuthState', () {
    test('isAuthenticated returns false when user is null', () {
      const state = AuthState();
      expect(state.isAuthenticated, false);
    });

    test('copyWith updates fields correctly', () {
      const state = AuthState();
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, true);
      expect(updated.user, isNull);
    });

    test('copyWith clears error when null is passed', () {
      const state = AuthState(error: 'some error');
      final updated = state.copyWith(error: null);
      expect(updated.error, isNull);
    });

    test('initial state has correct defaults', () {
      const state = AuthState();
      expect(state.user, isNull);
      expect(state.role, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });
  });
}
