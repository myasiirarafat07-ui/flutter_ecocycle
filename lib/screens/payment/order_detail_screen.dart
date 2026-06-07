import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/user_provider.dart';
import '../../services/order_api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = OrderApiService();
  late Future<Order> _future;

  @override
  void initState() {
    super.initState();
    final token = context.read<UserProvider>().token;
    _future = _api.getOrder(token, widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SafeArea(
        child: FutureBuilder<Order>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}',
                    style: TextStyle(color: context.mutedColor)),
              );
            }
            final order = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _statusCard(context, order),
                const SizedBox(height: 16),
                _section(context, 'Alamat Pengiriman', order.shippingAddress),
                const SizedBox(height: 16),
                _itemsCard(context, order),
                const SizedBox(height: 16),
                _summaryCard(context, order),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statusCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderCode,
                    style: TextStyle(
                        color: context.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(order.createdAt,
                    style: TextStyle(color: context.mutedColor, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.paymentStatus,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: context.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: context.mutedColor, height: 1.5)),
        ],
      ),
    );
  }

  Widget _itemsCard(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Item Pesanan',
              style: TextStyle(
                  color: context.textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: context.surfaceAltColor,
                          child: Icon(Icons.image_not_supported,
                              color: context.mutedColor, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: context.textColor, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('${item.quantity} x ${rupiah(item.unitPrice)}',
                              style: TextStyle(
                                  color: context.mutedColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(rupiah(item.subtotal),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, Order order) {
    Widget row(String label, String value, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      color: bold ? context.textColor : context.mutedColor,
                      fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
              Text(value,
                  style: TextStyle(
                      color: bold ? AppColors.primary : context.textColor,
                      fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          row('Subtotal', rupiah(order.subtotal)),
          row('Ongkos Kirim (${order.shippingMethod})', rupiah(order.shippingCost)),
          if (order.discount > 0) row('Diskon', '- ${rupiah(order.discount)}'),
          Divider(color: context.dividerColor, height: 20),
          row('Total', rupiah(order.totalAmount), bold: true),
          const SizedBox(height: 6),
          row('Pembayaran', '${order.paymentMethod} · ${order.paymentStatus}'),
        ],
      ),
    );
  }
}
