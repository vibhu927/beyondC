// BeyondC App Widget Test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beyondc/app.dart';

void main() {
  testWidgets('BeyondC app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BeyondCApp()));

    // Wait for splash screen animation
    await tester.pumpAndSettle();

    // Verify the app loaded successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
