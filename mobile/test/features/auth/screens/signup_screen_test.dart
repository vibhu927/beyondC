import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondc/features/auth/screens/signup_screen.dart';
import 'package:beyondc/providers/auth_provider.dart';

void main() {
  testWidgets('SignupScreen renders for creator role', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_TestAuthNotifier.new),
        ],
        child: const MaterialApp(home: SignupScreen(role: 'creator')),
      ),
    );

    await tester.pump();

    expect(find.byType(SignupScreen), findsOneWidget);
  });

  testWidgets('SignupScreen renders for brand role', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_TestAuthNotifier.new),
        ],
        child: const MaterialApp(home: SignupScreen(role: 'brand')),
      ),
    );

    await tester.pump();

    expect(find.byType(SignupScreen), findsOneWidget);
  });
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState();
}
