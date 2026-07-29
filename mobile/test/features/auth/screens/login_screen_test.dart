import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondc/features/auth/screens/login_screen.dart';
import 'package:beyondc/providers/auth_provider.dart';

void main() {
  testWidgets('LoginScreen renders all key elements', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_TestAuthNotifier.new),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
  });
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState();
}
