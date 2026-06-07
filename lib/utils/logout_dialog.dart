import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/auth/login_screen.dart';

void showLogoutDialog(BuildContext context, {bool closeDrawer = false}) {
  final navigator = Navigator.of(context);
  final userProvider = context.read<UserProvider>();
  final cartProvider = context.read<CartProvider>();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Keluar Akun', style: TextStyle(color: context.textColor)),
      content: Text(
        'Apakah kamu yakin ingin keluar?',
        style: TextStyle(color: context.mutedColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Batal', style: TextStyle(color: context.mutedColor)),
        ),
        TextButton(
          onPressed: () {
            userProvider.logout();
            cartProvider.reset();
            Navigator.pop(ctx);
            if (closeDrawer) {
              navigator.pop();
            }
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
          child: const Text(
            'Keluar',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
}
