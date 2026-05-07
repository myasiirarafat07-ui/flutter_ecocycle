import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
import '../screens/auth/login_screen.dart';

void showLogoutDialog(BuildContext context, {bool closeDrawer = false}) {
  final navigator = Navigator.of(context);
  final userProvider = context.read<UserProvider>();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Keluar Akun', style: TextStyle(color: Colors.white)),
      content: const Text(
        'Apakah kamu yakin ingin keluar?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            userProvider.logout();
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
