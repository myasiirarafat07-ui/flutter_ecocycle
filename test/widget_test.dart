// This is a basic Flutter widget test for EcoCycle app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecocycle/main.dart';
import 'package:ecocycle/providers/user_provider.dart';
import 'package:ecocycle/screens/auth/login_screen.dart';
import 'package:ecocycle/widgets/app_drawer.dart';

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

  testWidgets('drawer logout returns to login screen', (
    WidgetTester tester,
  ) async {
    final userProvider = UserProvider()
      ..loginAs(name: 'Eco User', email: 'eco@example.com');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: userProvider,
        child: MaterialApp(
          home: Scaffold(
            drawer: const AppDrawer(),
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open drawer'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar Akun'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keluar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(userProvider.name, isEmpty);
    expect(userProvider.email, isEmpty);
  });
}
