import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecocycle/main.dart';
import 'package:ecocycle/providers/cart_provider.dart';
import 'package:ecocycle/providers/notification_provider.dart';
import 'package:ecocycle/providers/theme_provider.dart';
import 'package:ecocycle/providers/user_provider.dart';
import 'package:ecocycle/providers/wishlist_provider.dart';
import 'package:ecocycle/screens/auth/login_screen.dart';
import 'package:ecocycle/widgets/app_drawer.dart';

Widget _withProviders(Widget child, {UserProvider? userProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(
        value: userProvider ?? UserProvider(),
      ),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ],
    child: child,
  );
}

void main() {
  testWidgets('EcoCycle app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(_withProviders(const MyApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('drawer logout returns to login screen', (
    WidgetTester tester,
  ) async {
    final userProvider = UserProvider()
      ..setAuthenticatedUser(
        token: 'test-token',
        user: {
          'full_name': 'Eco User',
          'email': 'eco@example.com',
          'phone_number': '',
          'address': '',
          'user_type': 'Individual',
          'is_premium': false,
          'total_waste_kg': 0,
          'trees_planted': 0,
          'co2_offset_kg': 0,
        },
      );

    await tester.pumpWidget(
      _withProviders(
        MaterialApp(
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
        userProvider: userProvider,
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
