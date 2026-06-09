import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/payment/payment_method_screen.dart';
import '../screens/profile/personal_info_screen.dart';
import '../screens/seller/my_products_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../utils/logout_dialog.dart';
import '../constants/app_colors.dart';
import '../constants/eco_tier.dart';
import 'profile_avatar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final displayName = user.name.isEmpty ? 'Pengguna' : user.name;
    final displayEmail = user.email.isEmpty ? 'email@contoh.com' : user.email;
    final tier = EcoTier.currentFor(user.ecoPoints);

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
                    user: user,
                    displayName: displayName,
                    displayEmail: displayEmail,
                    tier: tier,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 8),

                  _DrawerSectionLabel(label: 'Akun', isDark: isDark),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Informasi Pribadi',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront,
                    label: 'Produk Saya',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyProductsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    label: 'Favorit',
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WishlistScreen(),
                        ),
                      );
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
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    activeIcon: Icons.notifications,
                    label: 'Notifikasi',
                    isDark: isDark,
                    badgeCount:
                        context.watch<NotificationProvider>().unreadCount,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context
                              .read<NotificationProvider>()
                              .refresh(context.read<UserProvider>().token);
                        }
                      });
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
  final UserProvider user;
  final String displayName;
  final String displayEmail;
  final EcoTier tier;
  final bool isDark;

  const _DrawerHeader({
    required this.user,
    required this.displayName,
    required this.displayEmail,
    required this.tier,
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
              ProfileAvatar(
                user: user,
                size: 72,
                borderWidth: 2.5,
                borderColor: isDark ? AppColors.primary : AppColors.secondary,
                backgroundColor: AppColors.primary,
                initialColor: Colors.white,
              ),
              // Badge penjual: hanya tampil bila user sudah jadi penjual
              // (punya entri di tabel `sellers`). Default pembeli: tanpa badge.
              if (user.isSeller)
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
                      Icons.storefront,
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
              color: tier.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tier.icon, color: tier.color, size: 13),
                const SizedBox(width: 4),
                Text(
                  tier.name,
                  style: TextStyle(color: tier.color, fontSize: 12),
                ),
              ],
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
  final int badgeCount;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    required this.isDark,
    this.badgeCount = 0,
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
            if (badgeCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
