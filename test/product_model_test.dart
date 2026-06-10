import 'package:flutter_test/flutter_test.dart';
import 'package:ecocycle/models/product_model.dart';

void main() {
  group('Product.fromJson', () {
    test('parse lengkap dari tipe numerik asli', () {
      final p = Product.fromJson({
        'product_id': 7,
        'seller_id': 3,
        'seller_name': 'Bu Tani',
        'category': 'Pupuk & Kompos',
        'name': 'Kompos Organik',
        'description': 'Kompos matang',
        'price': 45000,
        'stock': 12,
        'image_url': '/uploads/products/a.jpg',
        'waste_kg': 2.5,
        'weight_kg': 5.0,
        'seller_lat': -6.2,
        'seller_lng': 106.8,
        'sold': 4,
        'rating': 4.5,
        'review_count': 8,
      });

      expect(p.id, 7);
      expect(p.sellerName, 'Bu Tani');
      expect(p.price, 45000);
      expect(p.wasteKg, 2.5);
      expect(p.sellerLat, -6.2);
      expect(p.rating, 4.5);
      expect(p.isMine, isFalse);
    });

    test('angka dalam bentuk String (umum dari MySQL) tetap ter-parse', () {
      final p = Product.fromJson({
        'product_id': '15',
        'price': '30000',
        'stock': '0',
        'waste_kg': '1.25',
        'rating': '3.7',
        'review_count': '2',
      });

      expect(p.id, 15);
      expect(p.price, 30000);
      expect(p.stock, 0);
      expect(p.wasteKg, 1.25);
      expect(p.rating, 3.7);
    });

    test('field hilang/null memakai nilai default aman', () {
      final p = Product.fromJson({});

      expect(p.id, 0);
      expect(p.name, '');
      expect(p.price, 0);
      expect(p.wasteKg, 0);
      expect(p.sellerLat, isNull);
      expect(p.sellerLng, isNull);
      expect(p.images, isEmpty);
    });

    test('is_mine menerima bool true maupun angka 1', () {
      expect(Product.fromJson({'is_mine': true}).isMine, isTrue);
      expect(Product.fromJson({'is_mine': 1}).isMine, isTrue);
      expect(Product.fromJson({'is_mine': 0}).isMine, isFalse);
      expect(Product.fromJson({'is_mine': false}).isMine, isFalse);
    });

    test('images: pakai list bila ada, fallback ke image_url tunggal', () {
      final withList = Product.fromJson({
        'image_url': '/uploads/a.jpg',
        'images': ['/uploads/a.jpg', '/uploads/b.jpg'],
      });
      expect(withList.images, ['/uploads/a.jpg', '/uploads/b.jpg']);

      final fallback = Product.fromJson({'image_url': '/uploads/solo.jpg'});
      expect(fallback.images, ['/uploads/solo.jpg']);

      final none = Product.fromJson({'images': <String>[]});
      expect(none.images, isEmpty);
    });

    test('formattedPrice menyisipkan pemisah ribuan', () {
      expect(Product.fromJson({'price': 45000}).formattedPrice, 'Rp 45.000');
      expect(Product.fromJson({'price': 1500000}).formattedPrice, 'Rp 1.500.000');
      expect(Product.fromJson({'price': 500}).formattedPrice, 'Rp 500');
      expect(Product.fromJson({'price': 0}).formattedPrice, 'Rp 0');
    });
  });

  group('Review.fromJson', () {
    test('parse ulasan lengkap', () {
      final r = Review.fromJson({
        'review_id': 1,
        'product_id': 7,
        'user_id': 9,
        'user_name': 'Andi',
        'rating': 5,
        'comment': 'Bagus',
        'created_at': '2026-01-01',
      });
      expect(r.id, 1);
      expect(r.productId, 7);
      expect(r.userName, 'Andi');
      expect(r.rating, 5);
      expect(r.comment, 'Bagus');
    });

    test('field kosong default aman', () {
      final r = Review.fromJson({});
      expect(r.id, 0);
      expect(r.userName, '');
      expect(r.comment, '');
      expect(r.createdAt, '');
    });
  });
}
