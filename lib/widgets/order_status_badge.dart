import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Label bahasa Indonesia untuk status fulfillment pesanan.
String orderStatusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'DIPROSES':
      return 'Diproses';
    case 'DIKIRIM':
      return 'Dikirim';
    case 'SELESAI':
      return 'Selesai';
    // Status lama (sebelum decouple) — tetap dipetakan agar data lama terbaca.
    case 'PENDING':
      return 'Menunggu Pembayaran';
    case 'PAID':
      return 'Dibayar';
    default:
      return status.isEmpty ? '-' : status;
  }
}

/// Warna penanda status fulfillment pesanan.
Color orderStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'DIPROSES':
    case 'PENDING':
      return AppColors.warning;
    case 'DIKIRIM':
    case 'PAID':
      return const Color(0xFF2196F3); // Blue 500
    case 'SELESAI':
      return AppColors.primary;
    default:
      return AppColors.primary;
  }
}

/// Label status pembayaran (jalur terpisah dari fulfillment).
String paymentStatusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'PAID':
      return 'Lunas';
    case 'PENDING':
      return 'Belum dibayar';
    default:
      return status.isEmpty ? '-' : status;
  }
}

/// Warna status pembayaran.
Color paymentStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PAID':
      return AppColors.primary;
    case 'PENDING':
      return AppColors.warning;
    default:
      return AppColors.primary;
  }
}

/// Chip status pesanan yang dipakai bersama di daftar & detail pesanan.
class OrderStatusBadge extends StatelessWidget {
  final String status;
  const OrderStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        orderStatusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Chip status pembayaran (Lunas / Belum dibayar).
class PaymentStatusBadge extends StatelessWidget {
  final String status;
  const PaymentStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = paymentStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        paymentStatusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
