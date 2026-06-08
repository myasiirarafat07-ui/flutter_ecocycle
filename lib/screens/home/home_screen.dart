import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/user_provider.dart';
import '../../services/product_api_service.dart';
import '../../widgets/product_card_bits.dart';
import '../market/product_detail_screen.dart';
import '../notification/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({super.key, this.onOpenDrawer, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ProductApiService();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchProducts(sort: 'terlaris', token: context.read<UserProvider>().token);
  }

  void _goToMarket() => widget.onNavigateToTab?.call(1);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() => _future = _api.fetchProducts(sort: 'terlaris', token: context.read<UserProvider>().token));
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildHeader(context, user),
              const SizedBox(height: 20),
              _buildSearchBar(context),
              const SizedBox(height: 20),
              _buildCategoryShortcuts(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context),
              const SizedBox(height: 14),
              _buildProductGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProvider user) {
    final displayName = user.name.isEmpty
        ? 'Pengguna'
        : user.name.split(' ').first;
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onOpenDrawer,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.menu, color: context.mutedColor, size: 26),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(color: context.mutedColor, fontSize: 13),
              ),
              Text(
                'Halo, $displayName!',
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: context.mutedColor,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: _goToMarket,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: context.mutedColor, size: 22),
            const SizedBox(width: 12),
            Text(
              'Cari pupuk atau karya daur ulang...',
              style: TextStyle(color: context.mutedColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShortcuts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _categoryCard(
            context,
            icon: Icons.compost,
            label: 'Pupuk & Kompos',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _categoryCard(
            context,
            icon: Icons.recycling,
            label: 'Karya Daur Ulang',
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: _goToMarket,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Produk Terlaris',
          style: TextStyle(
            color: context.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: _goToMarket,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text(
                'Gagal memuat produk.',
                style: TextStyle(color: context.mutedColor),
              ),
            ),
          );
        }
        final products = (snapshot.data ?? []).take(4).toList();
        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Text(
                'Belum ada produk.',
                style: TextStyle(color: context.mutedColor),
              ),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => _HomeProductCard(product: products[i]),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 19) return 'Selamat sore,';
    return 'Selamat malam,';
  }
}

class _HomeProductCard extends StatelessWidget {
  final Product product;
  const _HomeProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Opacity(
                    opacity: product.stock <= 0 ? 0.45 : 1,
                    child: Image.network(
                      product.imageUrl,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 110,
                        color: context.surfaceAltColor,
                        child: Icon(
                          Icons.image_not_supported,
                          color: context.mutedColor,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  if (product.stock <= 0)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: StokHabisBadge(),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ProductMetaRow(product: product),
                    const Spacer(),
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
