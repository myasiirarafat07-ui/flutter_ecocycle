import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/payment/payment_method_screen.dart';
import '../utils/logout_dialog.dart';
import '../constants/app_colors.dart';

class AppDrawer extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;

  const AppDrawer({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final displayName = user.name.isEmpty ? 'Pengguna' : user.name;
    final displayEmail = user.email.isEmpty ? 'email@contoh.com' : user.email;
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerHeader(
                    initials: initials,
                    displayName: displayName,
                    displayEmail: displayEmail,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 8),

                  _DrawerSectionLabel(label: 'Menu', isDark: isDark),
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Beranda',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profil Saya',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(4);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.credit_card_outlined,
                    activeIcon: Icons.credit_card,
                    label: 'Metode Pembayaran',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentMethodScreen(),
                        ),
                      );
                    },
                  ),

                  _DrawerDivider(isDark: isDark),

                  _DrawerSectionLabel(label: 'Lainnya', isDark: isDark),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    activeIcon: Icons.info,
                    label: 'Tentang Aplikasi',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context, isDark);
                    },
                  ),
                  
                  _DrawerDivider(isDark: isDark),
                  
                  // Theme Toggle Switch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDark ? Icons.dark_mode : Icons.light_mode,
                              color: isDark ? Colors.white70 : AppColors.lightTextMuted,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isDark ? 'Mode Gelap' : 'Mode Terang',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : AppColors.lightText,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _DrawerDivider(isDark: isDark),
            _DrawerItem(
              icon: Icons.logout,
              activeIcon: Icons.logout,
              label: 'Keluar',
              isDestructive: true,
              isDark: isDark,
              onTap: () => showLogoutDialog(context, closeDrawer: true),
            ),

            _DrawerBranding(isDark: isDark),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        title: Row(
          children: [
            Container(
              child: Image.asset(
                'assets/logo/ecocycle_logo.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'EcoCycle',
              style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
            ),
          ],
        ),
        content: Text(
          'EcoCycle adalah aplikasi pengelolaan sampah berbasis komunitas '
          'yang membantu kamu mendaur ulang dan menjual limbah dengan mudah.\n\n'
          'Versi 1.0.0',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.lightTextMuted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Tutup',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final String initials;
  final String displayName;
  final String displayEmail;
  final bool isDark;

  const _DrawerHeader({
    required this.initials,
    required this.displayName,
    required this.displayEmail,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.primary : AppColors.secondary,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Penjaga Alam',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displayEmail,
            style: TextStyle(
              color: isDark ? Colors.white54 : AppColors.lightTextMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isDark;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.danger
        : (isDark ? Colors.white70 : AppColors.lightText);

    return InkWell(
      onTap: onTap,
      highlightColor: AppColors.primary.withOpacity(0.15),
      splashColor: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DrawerSectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.white30 : AppColors.lightTextMuted.withOpacity(0.5),
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  final bool isDark;

  const _DrawerDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      thickness: 1,
      height: 16,
      indent: 20,
      endIndent: 20,
    );
  }
}

class _DrawerBranding extends StatelessWidget {
  final bool isDark;

  const _DrawerBranding({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            child: Image.asset(
              'assets/logo/ecocycle_logo.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'EcoCycle',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.lightTextMuted,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
