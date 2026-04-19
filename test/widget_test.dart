// This is a basic Flutter widget test for EcoCycle app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecocycle/main.dart';
import 'package:ecocycle/providers/user_provider.dart';

void main() {
  testWidgets('EcoCycle app smoke test', (WidgetTester tester) async {
    // Build our app wrapped with required Provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
        child: const MyApp(),
      ),
    );

    // Verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
