import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/order_api_service.dart';
import '../../services/product_api_service.dart';
import '../../widgets/product_image.dart';
import '../../widgets/order_status_badge.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = OrderApiService();
  final _productApi = ProductApiService();
  late Future<Order> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _fetchOrder();
  }

  Future<Order> _fetchOrder() {
    final token = context.read<UserProvider>().token;
    return _api.getOrder(token, widget.orderId);
  }

  void _reload() {
    setState(() {
      _future = _fetchOrder();
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  Future<void> _shipOrder() async {
    if (_busy) return;
    setState(() {
      _busy = true;
    });
    final token = context.read<UserProvider>().token;
    try {
      await _api.shipOrder(token, widget.orderId);
      if (!mounted) return;
      _snack('Pesanan ditandai dikirim');
      context.read<NotificationProvider>().refresh(token);
      _reload();
    } on OrderApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Tidak bisa terhubung ke server');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_busy) return;
    setState(() {
      _busy = true;
    });
    final token = context.read<UserProvider>().token;
    try {
      await _api.confirmPayment(token, widget.orderId);
      if (!mounted) return;
      _snack('Pembayaran dikonfirmasi');
      context.read<NotificationProvider>().refresh(token);
      _reload();
    } on OrderApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Tidak bisa terhubung ke server');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _completeOrder(Order order) async {
    if (_busy) return;
    setState(() {
      _busy = true;
    });
    final token = context.read<UserProvider>().token;
    try {
      await _api.completeOrder(token, widget.orderId);
      if (!mounted) return;
      _snack('Pesanan selesai. Yuk beri ulasan!');
      context.read<NotificationProvider>().refresh(token);
      setState(() {
        _busy = false;
      });
      await _promptReviews(order);
    } on OrderApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Tidak bisa terhubung ke server');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  /// Minta ulasan untuk tiap produk yang belum diulas (dipanggil saat selesai
  /// atau lewat tombol "Beri Ulasan"). Setelah selesai, segarkan tampilan.
  Future<void> _promptReviews(Order order) async {
    for (final item in order.items) {
      if (!mounted) return;
      if (item.reviewed) continue;
      await _showReviewDialog(item);
    }
    if (!mounted) return;
    context.read<NotificationProvider>().refresh(
      context.read<UserProvider>().token,
    );
    _reload();
  }

  Future<bool> _showReviewDialog(OrderItem item) async {
    int rating = 5;
    bool submitting = false;
    String? errorText;
    final commentController = TextEditingController();

    try {
      final submit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setStateDialog) => AlertDialog(
            backgroundColor: ctx.surfaceColor,
            title: Text(
              'Ulasan: ${item.productName}',
              style: TextStyle(color: ctx.textColor, fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      onPressed: submitting
                          ? null
                          : () => setStateDialog(() => rating = i + 1),
                      icon: Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: commentController,
                  enabled: !submitting,
                  maxLines: 3,
                  style: TextStyle(color: ctx.textColor),
                  decoration: InputDecoration(
                    hintText: 'Tulis komentarmu...',
                    hintStyle: TextStyle(color: ctx.mutedColor),
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorText!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: submitting ? null : () => Navigator.pop(ctx, false),
                child: Text('Lewati', style: TextStyle(color: ctx.mutedColor)),
              ),
              TextButton(
                onPressed: submitting
                    ? null
                    : () async {
                        if (!mounted) return;
                        setStateDialog(() {
                          submitting = true;
                          errorText = null;
                        });
                        try {
                          await _productApi.createReview(
                            token: context.read<UserProvider>().token,
                            productId: item.productId,
                            orderId: widget.orderId,
                            rating: rating,
                            comment: commentController.text.trim(),
                          );
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        } on ProductApiException catch (e) {
                          if (!ctx.mounted) return;
                          setStateDialog(() {
                            submitting = false;
                            errorText = e.message;
                          });
                        } catch (_) {
                          if (!ctx.mounted) return;
                          setStateDialog(() {
                            submitting = false;
                            errorText = 'Tidak bisa terhubung ke server';
                          });
                        }
                      },
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Text(
                        'Kirim',
                        style: TextStyle(color: AppColors.primary),
                      ),
              ),
            ],
          ),
        ),
      );

      if (submit == true && mounted) {
        _snack('Ulasan "${item.productName}" terkirim');
      }
      return submit == true;
    } finally {
      commentController.dispose();
    }
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
                child: Text(
                  '${snapshot.error}',
                  style: TextStyle(color: context.mutedColor),
                ),
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
                _actionCard(context, order),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.orderCode,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.createdAt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OrderStatusBadge(order.orderStatus),
              PaymentStatusBadge(order.paymentStatus),
            ],
          ),
        ],
      ),
    );
  }

  /// Tombol aksi sesuai peran + dua jalur status (fulfillment & pembayaran):
  /// - Penjual + DIPROSES                 → "Kirim / Serahkan Barang"
  /// - Penjual + pembayaran PENDING (COD) → "Terima Pembayaran"
  /// - Pembeli + DIKIRIM + lunas          → "Pesanan Diterima" + ulasan
  /// - Pembeli + DIKIRIM + belum lunas    → info (tunggu konfirmasi penjual)
  /// - Pembeli + SELESAI                  → "Beri Ulasan"
  Widget _actionCard(BuildContext context, Order order) {
    final status = order.orderStatus.toUpperCase();
    final pay = order.paymentStatus.toUpperCase();

    Widget button(String label, IconData icon, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : onTap,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, size: 20),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      );
    }

    final actions = <Widget>[];

    if (order.isSeller) {
      if (status == 'DIPROSES') {
        actions.add(
          button(
            'Kirim / Serahkan Barang',
            Icons.local_shipping_outlined,
            _shipOrder,
          ),
        );
      }
      if (pay == 'PENDING') {
        actions.add(
          button('Terima Pembayaran', Icons.payments_outlined, _confirmPayment),
        );
      }
    }

    if (order.isBuyer) {
      if (status == 'DIKIRIM' && pay == 'PAID') {
        actions.add(
          button(
            'Pesanan Diterima',
            Icons.check_circle_outline,
            () => _completeOrder(order),
          ),
        );
      } else if (status == 'DIKIRIM' && pay == 'PENDING') {
        actions.add(
          _infoNote(
            context,
            'Bayar tunai ke penjual saat barang diterima. Tombol "Pesanan Diterima" aktif setelah penjual mengonfirmasi pembayaran.',
          ),
        );
      }
      if (status == 'SELESAI' && order.needsReview) {
        actions.add(
          button(
            'Beri Ulasan',
            Icons.star_outline,
            () => _promptReviews(order),
          ),
        );
      }
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: actions,
    );
  }

  Widget _infoNote(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: context.textColor, fontSize: 13),
              ),
            ),
          ],
        ),
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
          Text(
            title,
            style: TextStyle(
              color: context.textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          Text(
            'Item Pesanan',
            style: TextStyle(
              color: context.textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(
                      imageUrl: item.imageUrl,
                      width: 50,
                      height: 50,
                      iconSize: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity} x ${rupiah(item.unitPrice)}',
                          style: TextStyle(
                            color: context.mutedColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      rupiah(item.subtotal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context, Order order) {
    Widget row(String label, String value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: bold ? context.textColor : context.mutedColor,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: bold ? AppColors.primary : context.textColor,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
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
          row(
            'Ongkos Kirim (${order.shippingMethod})',
            rupiah(order.shippingCost),
          ),
          Divider(color: context.dividerColor, height: 20),
          row('Total', rupiah(order.totalAmount), bold: true),
          const SizedBox(height: 6),
          row('Pembayaran', '${order.paymentMethod} - ${order.paymentStatus}'),
        ],
      ),
    );
  }
}
