import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/product_api_service.dart';
import '../seller/sell_product_screen.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = ProductApiService();
  late Future<List<Review>> _reviewsFuture;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _api.fetchReviews(product.id);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(context),
                      const SizedBox(height: 20),
                      _buildSellerCard(context),
                      const SizedBox(height: 24),
                      _buildDescription(context),
                      const SizedBox(height: 24),
                      _buildReviews(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final isFav = context.watch<WishlistProvider>().isFavorite(product.id);
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: context.surfaceColor,
      foregroundColor: context.textColor,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        if (!product.isMine)
          GestureDetector(
            onTap: () => context.read<WishlistProvider>().toggle(product),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
      title: Text(
        'Detail Produk',
        style: TextStyle(
          color: context.textColor,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: context.surfaceAltColor,
            child: Icon(
              Icons.image_not_supported,
              color: context.mutedColor,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: TextStyle(
            color: context.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.warning, size: 16),
            const SizedBox(width: 4),
            Text(
              '${product.rating}',
              style: TextStyle(
                color: context.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '• ${product.reviewCount} ulasan  •  ${product.sold} terjual',
              style: TextStyle(color: context.mutedColor, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          product.formattedPrice,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Stok tersedia: ${product.stock}',
          style: TextStyle(color: context.mutedColor, fontSize: 13),
        ),
        if (product.wasteKg > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.recycling, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                'Menyelamatkan ${product.wasteKg.toStringAsFixed(1)} kg limbah per unit',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSellerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.sellerName,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Penjual EcoCycle',
                  style: TextStyle(color: context.mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: TextStyle(
            color: context.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          product.description.isEmpty
              ? 'Tidak ada deskripsi.'
              : product.description,
          style: TextStyle(
            color: context.mutedColor,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildReviews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ulasan',
              style: TextStyle(
                color: context.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _openReviewDialog,
              icon: const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.primary),
              label: const Text(
                'Tulis Ulasan',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Review>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada ulasan. Jadilah yang pertama!',
                  style: TextStyle(color: context.mutedColor),
                ),
              );
            }
            return Column(
              children: reviews.map((r) => _buildReviewTile(context, r)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewTile(BuildContext context, Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: TextStyle(
                  color: context.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: TextStyle(color: context.mutedColor, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  void _openReviewDialog() {
    final token = context.read<UserProvider>().token;
    if (token.isEmpty) {
      _snack('Kamu harus login untuk menulis ulasan');
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: ctx.surfaceColor,
          title: Text('Tulis Ulasan', style: TextStyle(color: ctx.textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () => setStateDialog(() => rating = i + 1),
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                style: TextStyle(color: ctx.textColor),
                decoration: InputDecoration(
                  hintText: 'Tulis komentarmu...',
                  hintStyle: TextStyle(color: ctx.mutedColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: TextStyle(color: ctx.mutedColor)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _submitReview(rating, commentController.text.trim());
              },
              child: const Text('Kirim',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(int rating, String comment) async {
    final token = context.read<UserProvider>().token;
    try {
      await _api.createReview(
        token: token,
        productId: product.id,
        rating: rating,
        comment: comment,
      );
      if (!mounted) return;
      _snack('Ulasan terkirim');
      setState(() => _reviewsFuture = _api.fetchReviews(product.id));
    } on ProductApiException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack('Tidak bisa terhubung ke server');
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.dividerColor, width: 1)),
      ),
      child: product.isMine
          ? _buildOwnerBar(context)
          : Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final token = context.read<UserProvider>().token;
                if (token.isEmpty) {
                  _snack('Login dulu untuk menambah ke keranjang');
                  return;
                }
                try {
                  await context.read<CartProvider>().add(token, product);
                  _snack('Ditambahkan ke keranjang');
                } catch (e) {
                  _snack('$e');
                }
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 16),
              label: const Text(
                'Keranjang',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      items: [CartItem(product: product)],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Beli Sekarang',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ini produk Anda',
          style: TextStyle(color: context.mutedColor, fontSize: 12),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => SellProductScreen(product: product),
                ),
              );
              if (changed == true && mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text(
              'Edit Produk',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
