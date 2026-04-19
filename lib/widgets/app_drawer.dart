import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/payment/payment_settings_screen.dart';

// ============================================================
// APP DRAWER
// Panel samping kiri yang muncul saat:
// - User swipe dari kiri ke kanan
// - User tap ikon ☰ di AppBar (HomeScreen)
//
// Isi drawer: hal-hal yang tidak muat di bottom navbar,
// seperti Settings, Bantuan, Tentang, dan Logout.
// ============================================================
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final displayName = user.name.isEmpty ? 'Pengguna' : user.name;
    final displayEmail = user.email.isEmpty ? 'email@contoh.com' : user.email;
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Drawer(
      backgroundColor: const Color(0xFF0D1F0F),
      child: SafeArea(
        child: Column(
          children: [
            // ── Header: Avatar + Nama + Role ──────────────────
            _DrawerHeader(
              initials: initials,
              displayName: displayName,
              displayEmail: displayEmail,
              isPremium: user.isPremium,
            ),

            const SizedBox(height: 8),

            // ── Menu Utama ────────────────────────────────────
            _DrawerSectionLabel(label: 'Menu'),
            _DrawerItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Beranda',
              onTap: () => Navigator.pop(context), // sudah di home, tutup saja
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil Saya',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: 'Notifikasi',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet,
              label: 'Pembayaran',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentSettingsScreen()),
                );
              },
            ),

            const _DrawerDivider(),

            // ── Menu Lainnya ──────────────────────────────────
            _DrawerSectionLabel(label: 'Lainnya'),
            _DrawerItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Pengaturan',
              onTap: () {
                Navigator.pop(context);
                // TODO: Buat SettingsScreen dan navigasi ke sana
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman Pengaturan segera hadir!'),
                    backgroundColor: Color(0xFF2E7D32),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline,
              activeIcon: Icons.help,
              label: 'Pusat Bantuan',
              onTap: () {
                Navigator.pop(context);
                // TODO: Buat HelpCenterScreen dan navigasi ke sana
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman Bantuan segera hadir!'),
                    backgroundColor: Color(0xFF2E7D32),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.info_outline,
              activeIcon: Icons.info,
              label: 'Tentang Aplikasi',
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),

            const Spacer(),

            // ── Logout ────────────────────────────────────────
            const _DrawerDivider(),
            _DrawerItem(
              icon: Icons.logout,
              activeIcon: Icons.logout,
              label: 'Keluar',
              isDestructive: true,
              onTap: () => _confirmLogout(context),
            ),

            // ── Branding bawah ────────────────────────────────
            const _DrawerBranding(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Dialog konfirmasi sebelum logout
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B1A),
        title: const Text('Keluar?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Kamu akan keluar dari akun ini.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // tutup dialog
              Navigator.pop(context); // tutup drawer
              context.read<UserProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
            },
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  // Dialog info tentang app
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B1A),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('EcoCycle', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'EcoCycle adalah aplikasi pengelolaan sampah berbasis komunitas '
          'yang membantu kamu mendaur ulang dan menjual limbah dengan mudah.\n\n'
          'Versi 1.0.0',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF66BB6A))),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUB-WIDGETS DRAWER
// ============================================================

class _DrawerHeader extends StatelessWidget {
  final String initials;
  final String displayName;
  final String displayEmail;
  final bool isPremium;

  const _DrawerHeader({
    required this.initials,
    required this.displayName,
    required this.displayEmail,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A3B1A),
        border: Border(bottom: BorderSide(color: Color(0xFF2E5C2E), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar dengan badge verified
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF66BB6A), width: 2.5),
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
                    color: const Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0D1F0F), width: 2),
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nama user
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),

          // Role / badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isPremium ? 'Anggota Premium' : 'Penjaga Alam',
              style: const TextStyle(color: Color(0xFF66BB6A), fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),

          // Email
          Text(
            displayEmail,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
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

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFE53935) : Colors.white70;

    return InkWell(
      onTap: onTap,
      highlightColor: const Color(0xFF2E7D32).withOpacity(0.15),
      splashColor: const Color(0xFF2E7D32).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  const _DrawerSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white30,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFF1A3B1A),
      thickness: 1,
      height: 16,
      indent: 20,
      endIndent: 20,
    );
  }
}

class _DrawerBranding extends StatelessWidget {
  const _DrawerBranding();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'EcoCycle',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
