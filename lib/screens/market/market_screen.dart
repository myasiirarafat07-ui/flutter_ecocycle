import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'product_detail_screen.dart';

// pencarian, dan grid produk.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Limbah pertanian',
    'Limbah daur ulang',
    'Pupuk & Kompos',
    'Pakan Ternak',
  ];

  // Data produk dummy
  final List<_Product> _allProducts = const [
    _Product(
      id: '1',
      category: 'Pupuk & Kompos',
      categoryLabel: 'PUPUK ORGANIK',
      name: 'Pupuk Kompos Premium',
      rating: 4.9,
      sold: 120,
      price: 'Rp 45.000',
      imageUrl:
          'https://images.unsplash.com/photo-1611735341450-74d61e660ad2?w=400',
      isFavorite: false,
    ),
    _Product(
      id: '2',
      category: 'Pakan Ternak',
      categoryLabel: 'PAKAN TERNAK',
      name: 'Pelet Organik Ayam',
      rating: 4.8,
      sold: 85,
      price: 'Rp 120.000',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
      isFavorite: false,
    ),
    _Product(
      id: '3',
      category: 'Limbah pertanian',
      categoryLabel: 'LIMBAH MENTAH',
      name: 'Ampas Kopi Bekas',
      rating: 4.7,
      sold: 240,
      price: 'Rp 5.000 /kg',
      imageUrl:
          'https://images.unsplash.com/photo-1559496417-e7f25cb247f3?w=400',
      isFavorite: false,
    ),
    _Product(
      id: '4',
      category: 'Limbah pertanian',
      categoryLabel: 'PRODUK DAUR ULANG',
      name: 'Jerami',
      rating: 5.0,
      sold: 54,
      price: 'Rp 20.000 /kg',
      imageUrl:
          'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=400',
      isFavorite: false,
    ),
    _Product(
      id: '5',
      category: 'Limbah daur ulang',
      categoryLabel: 'LIMBAH DAUR ULANG',
      name: 'Botol Plastik PET',
      rating: 4.5,
      sold: 320,
      price: 'Rp 2.500 /kg',
      imageUrl:
          'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400',
      isFavorite: false,
    ),
    _Product(
      id: '6',
      category: 'Pupuk & Kompos',
      categoryLabel: 'PUPUK ORGANIK',
      name: 'Pupuk Kandang Sapi',
      rating: 4.6,
      sold: 98,
      price: 'Rp 35.000',
      imageUrl:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
      isFavorite: false,
    ),
  ];

  List<_Product> _favorites = [];

  List<_Product> get _filteredProducts {
    final query = _searchController.text.toLowerCase();
    return _allProducts.where((p) {
      final matchCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchSearch = query.isEmpty || p.name.toLowerCase().contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  void _toggleFavorite(_Product product) {
    setState(() {
      if (_favorites.any((p) => p.id == product.id)) {
        _favorites.removeWhere((p) => p.id == product.id);
      } else {
        _favorites.add(product);
      }
    });
  }

  bool _isFavorite(_Product product) =>
      _favorites.any((p) => p.id == product.id);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryChips(),
            _buildSectionTitle(),
            Expanded(child: _buildProductGrid()),
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
          Container(
            child: Image.asset(
              'assets/logo/ecocycle_logo.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Eco-Market',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Keranjang belanja segera hadir!'),
                  backgroundColor: AppColors.primary,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white70,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Cari pupuk, pakan, atau limbah...',
            hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.white38, size: 22),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(100), // capsule
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF2E5C2E),
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
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

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Produk Terbaru',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: Colors.white24, size: 56),
            SizedBox(height: 12),
            Text(
              'Produk tidak ditemukan',
              style: TextStyle(color: Colors.white38, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              id: products[i].id,
              name: products[i].name,
              categoryLabel: products[i].categoryLabel,
              rating: products[i].rating,
              sold: products[i].sold,
              price: products[i].price,
              imageUrl: products[i].imageUrl,
            ),
          ),
        ),
        child: _ProductCard(
          product: products[i],
          isFavorite: _isFavorite(products[i]),
          onFavorite: () => _toggleFavorite(products[i]),
          onAddToCart: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${products[i].name} ditambahkan ke keranjang'),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  product.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: const Color(0xFF1E4D1E),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white24,
                      size: 40,
                    ),
                  ),
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140,
                      color: const Color(0xFF1E4D1E),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryLight,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryLabel,
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),

                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rating & terjual
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating} (${product.sold} terjual)',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Harga + tombol keranjang
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.price,
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MODEL PRODUK
class _Product {
  final String id;
  final String category;
  final String categoryLabel;
  final String name;
  final double rating;
  final int sold;
  final String price;
  final String imageUrl;
  final bool isFavorite;

  const _Product({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.name,
    required this.rating,
    required this.sold,
    required this.price,
    required this.imageUrl,
    required this.isFavorite,
  });
}
