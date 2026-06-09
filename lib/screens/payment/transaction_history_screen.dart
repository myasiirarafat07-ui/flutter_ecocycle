import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/user_provider.dart';
import '../../services/order_api_service.dart';
import '../../widgets/order_status_badge.dart';
import 'order_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final bool embedded;
  const TransactionHistoryScreen({super.key, this.embedded = false});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _api = OrderApiService();
  late Future<List<Order>> _purchases;
  late Future<List<Order>> _sales;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final token = context.read<UserProvider>().token;
    _purchases = _api.myOrders(token);
    _sales = _api.mySales(token);
  }

  Future<void> _refresh(bool isSales) async {
    final token = context.read<UserProvider>().token;
    final next = isSales ? _api.mySales(token) : _api.myOrders(token);
    setState(() {
      if (isSales) {
        _sales = next;
      } else {
        _purchases = next;
      }
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.bgColor,
        appBar: AppBar(
          automaticallyImplyLeading: !widget.embedded,
          title: const Text('Pesanan'),
          centerTitle: true,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: context.mutedColor,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Pembelian'),
              Tab(text: 'Penjualan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(_purchases, 'Belum ada pembelian.', isSales: false),
            _buildList(_sales, 'Belum ada penjualan.', isSales: true),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    Future<List<Order>> future,
    String emptyMsg, {
    required bool isSales,
  }) {
    return RefreshIndicator(
      onRefresh: () => _refresh(isSales),
      child: FutureBuilder<List<Order>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Text(
                    'Gagal memuat.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.mutedColor),
                  ),
                ),
              ],
            );
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Icon(
                  Icons.receipt_long_outlined,
                  color: context.mutedColor,
                  size: 56,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    emptyMsg,
                    style: TextStyle(color: context.mutedColor, fontSize: 15),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _buildCard(orders[i], isSales),
          );
        },
      ),
    );
  }

  Widget _buildCard(Order order, bool isSales) {
    final subtitle = order.itemCount > 1
        ? '${order.firstItem} +${order.itemCount - 1} lainnya'
        : order.firstItem;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: order.orderId),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.orderCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      if (order.paymentStatus.toUpperCase() == 'PENDING')
                        PaymentStatusBadge(order.paymentStatus),
                      OrderStatusBadge(order.orderStatus),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.mutedColor, fontSize: 13),
            ),
            if (isSales && order.buyerName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Pembeli: ${order.buyerName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.mutedColor, fontSize: 12),
              ),
            ],
            if (!isSales && order.needsReview) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_outline,
                      size: 13,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Belum diulas',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.createdAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.mutedColor, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  order.formattedTotal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
