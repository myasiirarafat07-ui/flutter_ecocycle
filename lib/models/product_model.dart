class Product {
  final int id;
  final int sellerId;
  final String sellerName;
  final String category;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String imageUrl;
  final List<String> images;
  final double wasteKg;
  final double weightKg;
  final double? sellerLat;
  final double? sellerLng;
  final int sold;
  final double rating;
  final int reviewCount;
  final bool isMine;

  const Product({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    this.images = const [],
    this.wasteKg = 0,
    this.weightKg = 0,
    this.sellerLat,
    this.sellerLng,
    required this.sold,
    required this.rating,
    required this.reviewCount,
    this.isMine = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _toInt(json['product_id']),
      sellerId: _toInt(json['seller_id']),
      sellerName: json['seller_name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _toInt(json['price']),
      stock: _toInt(json['stock']),
      imageUrl: json['image_url']?.toString() ?? '',
      images: _toStringList(json['images'], json['image_url']?.toString() ?? ''),
      wasteKg: _toDouble(json['waste_kg']),
      weightKg: _toDouble(json['weight_kg']),
      sellerLat: _toNullableDouble(json['seller_lat']),
      sellerLng: _toNullableDouble(json['seller_lng']),
      sold: _toInt(json['sold']),
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['review_count']),
      isMine: json['is_mine'] == true || json['is_mine'] == 1,
    );
  }

  /// Format harga ke "Rp 45.000".
  String get formattedPrice {
    final str = price.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}

class Review {
  final int id;
  final int productId;
  final int userId;
  final String userName;
  final int rating;
  final String comment;
  final String createdAt;

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: _toInt(json['review_id']),
      productId: _toInt(json['product_id']),
      userId: _toInt(json['user_id']),
      userName: json['user_name']?.toString() ?? '',
      rating: _toInt(json['rating']),
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

/// Daftar URL gambar dari field `images`; fallback ke [fallbackUrl] tunggal
/// agar produk lama (hanya image_url) tetap punya galeri 1 foto.
List<String> _toStringList(dynamic value, String fallbackUrl) {
  if (value is List) {
    final list = value
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    if (list.isNotEmpty) return list;
  }
  return fallbackUrl.isNotEmpty ? [fallbackUrl] : const [];
}
