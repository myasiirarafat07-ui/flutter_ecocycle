import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../notification/notification_screen.dart';
import '../payment/payment_method_screen.dart';
import 'personal_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 20),
              _buildProfileHeader(user),
              const SizedBox(height: 28),
              _buildStatistikDampak(user),
              const SizedBox(height: 32),
              _buildPengaturanAkun(context),
              const SizedBox(height: 32),
              _buildKeluar(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.settings_outlined, color: Colors.white70, size: 26),
          const Text('Profil Saya', style: TextStyle(
              color: AppColors.textWhite, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(width: 26),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProvider user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
                color: AppColors.bgCard,
              ),
              child: ClipOval(
                child: user.name.isNotEmpty
                    ? Center(
                        child: Text(user.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white,
                                fontSize: 40, fontWeight: FontWeight.bold)))
                    : const Icon(Icons.person, color: Colors.white54, size: 60),
              ),
            ),
            Positioned(
              right: 0, bottom: 4,
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgDark, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          user.name.isEmpty ? 'Pengguna' : user.name,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        if (user.isPremium)
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: AppColors.primaryLight, size: 16),
              SizedBox(width: 4),
              Text('PREMIUM MEMBER', style: TextStyle(
                  color: AppColors.primaryLight, fontSize: 13,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
        if (user.email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
        const SizedBox(height: 4),
        Text(
          user.memberSince.isEmpty ? '' : 'Member sejak ${user.memberSince}',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatistikDampak(UserProvider user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.bar_chart_outlined, color: AppColors.textWhite, size: 22),
            SizedBox(width: 8),
            Text('Statistik Dampak', style: TextStyle(
                color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.recycling, iconColor: AppColors.primaryLight,
                value: '${user.totalWasteKg.toStringAsFixed(0)} kg', label: 'Limbah',
              )),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(
                icon: Icons.park_outlined, iconColor: AppColors.primaryLight,
                value: '${user.treesPlanted}', label: 'Pohon',
              )),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(
                icon: Icons.cloud_outlined, iconColor: AppColors.primaryLight,
                value: '${user.co2OffsetKg.toStringAsFixed(0)} kg', label: 'Offset', topLabel: 'CO₂',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPengaturanAkun(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline,
        label: 'Informasi Pribadi',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PersonalInfoScreen())),
      ),
      _MenuItem(icon: Icons.credit_card_outlined, label: 'Metode Pembayaran', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodScreen()));
      }),
      _MenuItem(icon: Icons.notifications_outlined, label: 'Notifikasi', onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
      }),
      _MenuItem(icon: Icons.help_outline, label: 'Pusat Bantuan', onTap: () {}),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengaturan Akun', style: TextStyle(
              color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ...menuItems.map(_buildMenuItem),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.primaryLight, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(item.label,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 15))),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildKeluar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('Keluar Akun', style: TextStyle(color: Colors.white)),
            content: const Text('Apakah kamu yakin ingin keluar?',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  context.read<UserProvider>().logout();
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: AppColors.danger, size: 20),
          SizedBox(width: 8),
          Text('Keluar Akun', style: TextStyle(
              color: AppColors.danger, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? topLabel;

  const _StatCard({required this.icon, required this.iconColor,
      required this.value, required this.label, this.topLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (topLabel != null)
                  Text(topLabel!, style: const TextStyle(
                      color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w600)),
                Icon(icon, color: iconColor, size: 26),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(
              color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _MenuItem({required this.icon, required this.label, required this.onTap});
}