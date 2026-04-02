import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _activities = [
    ActivityItem(
      title: 'Penjualan Plastik PET',
      subtitle: 'Kemarin, 14:20',
      amount: '+Rp 12.500',
      isPositive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 20),
              _buildTotalWasteCard(user),
              const SizedBox(height: 28),
              _buildServicesSection(),
              const SizedBox(height: 28),
              _buildRecommendationSection(),
              const SizedBox(height: 28),
              _buildRecentActivities(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProvider user) {
    final greeting = _getGreeting();
    final displayName = user.name.isEmpty ? 'Pengguna' : user.name.split(' ').first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.bgCard,
              child: user.name.isNotEmpty
                  ? Text(user.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                  : const Icon(Icons.person, color: Colors.white70, size: 26),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                Text('Halo, $displayName!',
                    style: const TextStyle(
                        color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const Icon(Icons.notifications_outlined, color: Colors.white70, size: 26),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 19) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  Widget _buildTotalWasteCard(UserProvider user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Sampah Terolah',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    user.totalWasteKg.toStringAsFixed(0),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 48,
                        fontWeight: FontWeight.bold, height: 1),
                  ),
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('kg', style: TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.black26, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      user.weeklyChangePercent == 0
                          ? 'Mulai catat limbahmu!'
                          : '+${user.weeklyChangePercent}% dari minggu lalu',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: -10, bottom: -10,
            child: Opacity(
              opacity: 0.15,
              child: const Icon(Icons.recycling, color: Colors.white, size: 100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final services = [
      _ServiceItem(label: 'Konsultasi\nAhli', icon: Icons.psychology_outlined, onTap: () {}),
      _ServiceItem(label: 'Limbah', icon: Icons.label_outline, onTap: () {}),
      _ServiceItem(label: 'Marketplace', icon: Icons.shopping_bag_outlined, onTap: () {}),
      _ServiceItem(label: 'Edukasi', icon: Icons.school_outlined, onTap: () {}),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Layanan Kami', style: TextStyle(
            color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: services.map((s) => _buildServiceIcon(
              label: s.label, icon: s.icon, onTap: s.onTap)).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceIcon({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white70, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center, maxLines: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rekomendasi Pintar', style: TextStyle(
                color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(Icons.auto_awesome, color: AppColors.primaryLight, size: 22),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                    color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tips Hari Ini', style: TextStyle(
                        color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(
                      'Anda punya limbah organik? Ubah jadi pupuk cair hari ini! Klik untuk panduan lengkapnya.',
                      style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Pelajari Sekarang', style: TextStyle(
                            color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: AppColors.primaryLight, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aktivitas Terakhir', style: TextStyle(
                color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Lihat Semua', style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 14),
        ..._activities.map(_buildActivityItem),
      ],
    );
  }

  Widget _buildActivityItem(ActivityItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: Color(0xFF2E2B00), shape: BoxShape.circle),
            child: const Icon(Icons.recycling, color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(
                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(item.amount, style: TextStyle(
            color: item.isPositive ? AppColors.primaryLight : AppColors.danger,
            fontSize: 14, fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _ServiceItem({required this.label, required this.icon, required this.onTap});
}