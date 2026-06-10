import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../utils/logout_dialog.dart';
import '../../widgets/profile_avatar.dart';
import '../notification/notification_screen.dart';
import '../payment/payment_method_screen.dart';
import '../seller/my_products_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'eco_points_screen.dart';
import 'personal_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => user.refreshMe(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildAppBar(context),
                const SizedBox(height: 20),
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),
                _buildEcoPointsCard(context, user),
                const SizedBox(height: 28),
                _buildPengaturanAkun(context),
                const SizedBox(height: 32),
                _buildKeluar(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    // ProfileScreen selalu berupa tab di MainWrapper (bukan route yang di-push),
    // jadi tidak boleh ada tombol back. Menggunakan Navigator.canPop di sini
    // keliru karena bernilai true saat ada route lain (mis. EcoPoints) di atas
    // stack, sehingga back nyangkut & menutup seluruh MainWrapper → layar hitam.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 26),
          Text(
            'Profil Saya',
            style: TextStyle(
              color: context.textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 26),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProvider user) {
    return Column(
      children: [
        ProfileAvatar(
          user: user,
          size: 110,
          showCameraBadge: true,
          onTap: () => pickAndUploadProfilePhoto(context, user),
        ),
        const SizedBox(height: 14),
        Text(
          user.name.isEmpty ? 'Pengguna' : user.name,
          style: TextStyle(
            color: context.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        if (user.email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: context.mutedColor, fontSize: 13),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          user.memberSince.isEmpty ? '' : 'Member sejak ${user.memberSince}',
          style: TextStyle(color: context.mutedColor, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEcoPointsCard(BuildContext context, UserProvider user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EcoPointsScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Eco Points',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.ecoPoints} poin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Text(
                    'Lihat Riwayat',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPengaturanAkun(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline,
        label: 'Informasi Pribadi',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.storefront_outlined,
        label: 'Produk Saya',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyProductsScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.favorite_border,
        label: 'Favorit',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WishlistScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.credit_card_outlined,
        label: 'Metode Pembayaran',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Akun',
            style: TextStyle(
              color: context.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...menuItems.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(color: context.textColor, fontSize: 15),
              ),
            ),
            Icon(Icons.chevron_right, color: context.mutedColor, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildKeluar(BuildContext context) {
    return GestureDetector(
      onTap: () => showLogoutDialog(context),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: AppColors.danger, size: 20),
          SizedBox(width: 8),
          Text(
            'Keluar Akun',
            style: TextStyle(
              color: AppColors.danger,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
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
