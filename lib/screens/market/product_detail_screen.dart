import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  final String name;
  final String categoryLabel;
  final double rating;
  final int sold;
  final String price;
  final String imageUrl;

  const ProductDetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.categoryLabel,
    required this.rating,
    required this.sold,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  // Data detail statis per produk (bisa diganti API nanti)
  static const Map<String, _ProductDetail> _details = {
    '1': _ProductDetail(
      sellerName: 'EcoFarm Indonesia',
      sellerRole: 'Mitra Resmi • Penjual Terverifikasi',
      description:
          'Pupuk Kompos Premium kami dibuat dari bahan organik pilihan melalui proses fermentasi alami selama 3 bulan. Kaya akan unsur hara makro dan mikro yang dibutuhkan tanaman. Cocok untuk semua jenis tanaman hortikultura maupun perkebunan.',
      tags: ['Organik Sertifikasi', 'Bebas Pestisida', 'Ramah Lingkungan'],
      specs: {
        'KANDUNGAN N': '2,5%',
        'KANDUNGAN P': '1,8%',
        'BERAT BERSIH': '10 kg',
        'KANDUNGAN K': '1,2%',
        'JENIS': 'Granular',
        'PH': '6,5 - 7,0',
      },
      ecoPoints: 225,
      reviewCount: '980',
    ),
    '2': _ProductDetail(
      sellerName: 'EcoLivestock Solutions',
      sellerRole: 'Mitra Resmi • Penjual Terverifikasi',
      description:
          'Pelet Organik Ayam kami adalah pakan premium berkualitas tinggi yang dibuat dari 100% bahan alami. Kami menggunakan proses waste-to-feed unik, mengubah surplus pangan organik menjadi pelet bernutrisi tinggi. Membantu mengurangi dampak lingkungan sekaligus memberikan nutrisi terbaik untuk unggas Anda.',
      tags: [
        'Zero Waste Production',
        'No Synthetic Hormones',
        'Antibiotic Free',
      ],
      specs: {
        'PROTEIN CONTENT': '18% - 20%',
        'NET WEIGHT': '5 kg',
        'VITAMINS': 'A, D3, E, B12',
        'FEED TYPE': 'Layer Pellet',
      },
      ecoPoints: 425,
      reviewCount: '1.2k',
    ),
    '3': _ProductDetail(
      sellerName: 'KopiNusantara',
      sellerRole: 'Penjual Terverifikasi',
      description:
          'Ampas kopi bekas pilihan dari biji arabika dan robusta premium. Kaya nitrogen, fosfor, dan kalium — sangat ideal sebagai pupuk organik, media tanam jamur, atau campuran kompos. Sudah melalui proses pengeringan sehingga tidak berbau dan tahan lama.',
      tags: ['Kaya Nitrogen', 'Media Tanam Jamur', 'Pupuk Organik'],
      specs: {
        'KANDUNGAN N': '~2%',
        'BERAT': 'per kg',
        'KONDISI': 'Kering',
        'AROMA': 'Kopi Arabika',
      },
      ecoPoints: 25,
      reviewCount: '1.8k',
    ),
    '4': _ProductDetail(
      sellerName: 'PetaniMaju',
      sellerRole: 'Penjual Terverifikasi',
      description:
          'Jerami padi kering berkualitas tinggi dari sawah organik. Cocok untuk pakan ternak, alas kandang, mulsa tanaman, atau bahan baku kerajinan. Bebas pestisida dan sudah dikeringkan dengan sinar matahari langsung.',
      tags: ['Bebas Pestisida', 'Serbaguna', 'Sawah Organik'],
      specs: {
        'KONDISI': 'Kering',
        'BERAT': 'per kg',
        'PENGGUNAAN': 'Pakan & Mulsa',
        'ASAL': 'Sawah Organik',
      },
      ecoPoints: 100,
      reviewCount: '320',
    ),
    '5': _ProductDetail(
      sellerName: 'RecyclePro',
      sellerRole: 'Penjual Terverifikasi',
      description:
          'Botol plastik PET bersih siap daur ulang. Sudah dipilah, dicuci, dan dipress. Cocok untuk industri daur ulang atau pengepul besar. Kontribusi nyata untuk mengurangi sampah plastik di lingkungan.',
      tags: ['Sudah Dicuci', 'Siap Daur Ulang', 'Dipilah Manual'],
      specs: {
        'JENIS': 'PET / Plastik #1',
        'BERAT': 'per kg',
        'KONDISI': 'Bersih & Kering',
        'BENTUK': 'Dipress',
      },
      ecoPoints: 13,
      reviewCount: '2.1k',
    ),
    '6': _ProductDetail(
      sellerName: 'EcoFarm Indonesia',
      sellerRole: 'Mitra Resmi • Penjual Terverifikasi',
      description:
          'Pupuk kandang sapi murni yang sudah matang dan difermentasi. Meningkatkan kesuburan tanah secara alami, memperbaiki struktur tanah, dan menambah populasi mikroorganisme baik. Cocok untuk semua jenis tanaman.',
      tags: ['Fermentasi Alami', 'Bebas Bau', 'Ramah Lingkungan'],
      specs: {
        'KANDUNGAN N': '1,5%',
        'BERAT BERSIH': '10 kg',
        'PROSES': 'Fermentasi 2 Bln',
        'JENIS': 'Granular',
      },
      ecoPoints: 175,
      reviewCount: '760',
    ),
  };

  _ProductDetail get _detail =>
      _details[widget.id] ??
      const _ProductDetail(
        sellerName: 'EcoCycle Seller',
        sellerRole: 'Penjual Terverifikasi',
        description: 'Produk berkualitas dari mitra terpercaya EcoCycle.',
        tags: ['Ramah Lingkungan'],
        specs: {},
        ecoPoints: 100,
        reviewCount: '100',
      );

  @override
  Widget build(BuildContext context) {
    final detail = _detail;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
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
                      _buildTitleSection(detail),
                      const SizedBox(height: 20),
                      _buildSellerCard(detail),
                      const SizedBox(height: 24),
                      _buildDescription(detail),
                      const SizedBox(height: 24),
                      if (detail.specs.isNotEmpty) ...[
                        _buildSpecifications(detail),
                        const SizedBox(height: 24),
                      ],
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
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.bgDark,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      title: const Text(
        'Detail Produk',
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur bagikan segera hadir!'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.share_outlined, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1E4D1E),
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.white24,
              size: 60,
            ),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
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
    );
  }

  Widget _buildTitleSection(_ProductDetail detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Rating & terjual
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.rating}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${detail.reviewCount} reviews',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${widget.sold} terjual',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Harga
              Text(
                widget.price,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Eco Points
              Row(
                children: [
                  const Icon(
                    Icons.eco,
                    color: AppColors.primaryLight,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Dapatkan ${detail.ecoPoints} Eco Points',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () => setState(() => _isFavorite = !_isFavorite),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white54,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerCard(_ProductDetail detail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar penjual
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),

          // Info penjual
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.sellerName,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail.sellerRole,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mengikuti penjual...'),
                  backgroundColor: AppColors.primary,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Ikuti',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(_ProductDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          detail.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),

        // Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: detail.tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2E5C2E),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSpecifications(_ProductDetail detail) {
    final entries = detail.specs.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specifications',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: entries
              .map(
                (e) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur chat segera hadir!'),
                  backgroundColor: AppColors.primary,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white54,
                  size: 22,
                ),
                SizedBox(height: 3),
                Text(
                  'Hubungi',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.name} ditambahkan ke keranjang'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 16),
              label: const Text(
                'Tambah ke Keranjang',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
                side: const BorderSide(
                  color: AppColors.primaryLight,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),

          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      productName: widget.name,
                      productPrice: widget.price,
                      productImageUrl: widget.imageUrl,
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
}

class _ProductDetail {
  final String sellerName;
  final String sellerRole;
  final String description;
  final List<String> tags;
  final Map<String, String> specs;
  final int ecoPoints;
  final String reviewCount;

  const _ProductDetail({
    required this.sellerName,
    required this.sellerRole,
    required this.description,
    required this.tags,
    required this.specs,
    required this.ecoPoints,
    required this.reviewCount,
  });
}
