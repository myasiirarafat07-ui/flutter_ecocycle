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
        body: const TabBarView(
          children: [
            _OrderListView(isSales: false, emptyMsg: 'Belum ada pembelian.'),
            _OrderListView(isSales: true, emptyMsg: 'Belum ada penjualan.'),
          ],
        ),
      ),
    );
  }
}

/// Daftar pesanan/penjualan dengan infinite scroll (paginasi server).
class _OrderListView extends StatefulWidget {
  final bool isSales;
  final String emptyMsg;
  const _OrderListView({required this.isSales, required this.emptyMsg});

  @override
  State<_OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<_OrderListView> {
  final _api = OrderApiService();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 12;

  final List<Order> _items = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loadingFirst = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<OrderPage> _fetch(int page) {
    final token = context.read<UserProvider>().token;
    return widget.isSales
        ? _api.mySales(token, page: page, limit: _pageSize)
        : _api.myOrders(token, page: page, limit: _pageSize);
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loadingFirst = true;
      _error = null;
    });
    try {
      final result = await _fetch(1);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.orders);
        _page = 1;
        _hasMore = result.hasMore;
        _loadingFirst = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loadingFirst = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loadingFirst || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final result = await _fetch(next);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.orders);
        _page = next;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: _loadFirst, child: _buildBody());
  }

  Widget _buildBody() {
    if (_loadingFirst) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(
              'Gagal memuat.\n$_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.mutedColor),
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
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
              widget.emptyMsg,
              style: TextStyle(color: context.mutedColor, fontSize: 15),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }
        return _buildCard(_items[i], widget.isSales);
      },
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.paymentStatus.toUpperCase() == 'PENDING') ...[
                      PaymentStatusBadge(order.paymentStatus),
                      const SizedBox(width: 6),
                    ],
                    OrderStatusBadge(order.orderStatus),
                  ],
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
