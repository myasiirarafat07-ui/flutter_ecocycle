import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/product_model.dart';

/// Baris meta pada kartu produk: rating bintang + jumlah ulasan + jumlah terjual.
class ProductMetaRow extends StatelessWidget {
  final Product product;
  const ProductMetaRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: AppColors.warning, size: 13),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            '${product.rating.toStringAsFixed(1)} (${product.reviewCount})  ·  ${product.sold} terjual',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.mutedColor,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// Badge "Stok Habis" untuk overlay gambar kartu produk.
class StokHabisBadge extends StatelessWidget {
  const StokHabisBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Stok Habis',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
