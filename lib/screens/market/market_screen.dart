import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/product_api_service.dart';
import '../../widgets/product_card_bits.dart';
import '../../widgets/product_image.dart';
import '../cart/cart_screen.dart';
import 'product_detail_screen.dart';

const List<String> kProductCategories = [
  'Semua',
  'Pupuk & Kompos',
  'Karya Daur Ulang',
];

const Map<String, String> kSortOptions = {
  'terbaru': 'Terbaru',
  'termurah': 'Harga Termurah',
  'termahal': 'Harga Termahal',
  'terlaris': 'Terlaris',
};

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final ProductApiService _api = ProductApiService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Semua';
  String _sort = 'terbaru';
  int? _minPrice;
  int? _maxPrice;
  double? _minRating;
  late Future<List<Product>> _future;

  bool get _hasActiveFilter =>
      _minPrice != null || _maxPrice != null || _minRating != null;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _load() {
    return _api.fetchProducts(
      category: _selectedCategory,
      search: _searchController.text.trim(),
      sort: _sort,
      token: context.read<UserProvider>().token,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _reload();
                  await _future;
                },
                child: FutureBuilder<List<Product>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildMessage(
                        Icons.cloud_off,
                        'Gagal memuat produk.\n${snapshot.error}',
                        showRetry: true,
                      );
                    }
                    final products = snapshot.data ?? [];
                    if (products.isEmpty) {
                      return _buildMessage(
                        Icons.inventory_2_outlined,
                        'Belum ada produk.',
                      );
                    }
                    return _buildGrid(products);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Image.asset(
            'assets/logo/ecocycle_logo.png',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Eco-Market',
              style: TextStyle(
                color: context.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Filter',
            onPressed: _showFilterSheet,
            icon: Icon(
              _hasActiveFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _hasActiveFilter ? AppColors.primary : context.textColor,
              size: 24,
            ),
          ),
          IconButton(
            tooltip: 'Urutkan',
            onPressed: _showSortSheet,
            icon: Icon(Icons.sort, color: context.textColor, size: 24),
          ),
          _buildCartIcon(),
        ],
      ),
    );
  }

  Widget _buildCartIcon() {
    final count = context.watch<CartProvider>().totalCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Keranjang',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: context.textColor,
            size: 24,
          ),
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (_) => _reload(),
          style: TextStyle(color: context.textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari pupuk atau karya daur ulang...',
            hintStyle: TextStyle(color: context.mutedColor, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: context.mutedColor, size: 22),
            suffixIcon: IconButton(
              icon: Icon(Icons.arrow_forward, color: context.mutedColor, size: 20),
              onPressed: _reload,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: kProductCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = kProductCategories[i];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              _reload();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : context.surfaceColor,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? AppColors.primary : context.dividerColor,
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : context.mutedColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.66,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: products[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessage(IconData icon, String text, {bool showRetry = false}) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(icon, color: context.mutedColor, size: 56),
        const SizedBox(height: 12),
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.mutedColor, fontSize: 15),
          ),
        ),
        if (showRetry) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _reload,
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: kSortOptions.entries.map((e) {
            final selected = _sort == e.key;
            return ListTile(
              title: Text(
                e.value,
                style: TextStyle(
                  color: selected ? AppColors.primary : context.textColor,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: selected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _sort = e.key);
                Navigator.pop(context);
                _reload();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    final minCtrl = TextEditingController(
      text: _minPrice?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: _maxPrice?.toString() ?? '',
    );
    double rating = _minRating ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter Produk',
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rentang Harga (Rp)',
                    style: TextStyle(color: context.textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildPriceField(minCtrl, 'Min')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPriceField(maxCtrl, 'Maks')),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    rating > 0
                        ? 'Rating Minimum: ${rating.toStringAsFixed(1)} ★'
                        : 'Rating Minimum: Semua',
                    style: TextStyle(color: context.textColor, fontSize: 14),
                  ),
                  Slider(
                    value: rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: AppColors.primary,
                    label: rating.toStringAsFixed(1),
                    onChanged: (v) => setSheetState(() => rating = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = null;
                              _maxPrice = null;
                              _minRating = null;
                            });
                            Navigator.pop(sheetContext);
                            _reload();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.dividerColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(color: context.textColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = int.tryParse(minCtrl.text.trim());
                              _maxPrice = int.tryParse(maxCtrl.text.trim());
                              _minRating = rating > 0 ? rating : null;
                            });
                            Navigator.pop(sheetContext);
                            _reload();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Terapkan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: context.textColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.mutedColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                    child: ProductImage(
                      imageUrl: product.imageUrl,
                      height: 130,
                      width: double.infinity,
                      iconSize: 40,
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
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
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
