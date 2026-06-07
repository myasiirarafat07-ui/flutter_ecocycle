import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/order_api_service.dart';
import '../payment/payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;

  /// Bila true, keranjang dikosongkan setelah pembayaran berhasil.
  final bool fromCart;

  const CheckoutScreen({super.key, required this.items, this.fromCart = false});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderApiService _orderApi = OrderApiService();
  bool _processing = false;
  String _selectedShipping = 'standar';

  static const int _shippingStandar = 15000;
  static const int _shippingEkspres = 35000;

  int get _itemsSubtotal =>
      widget.items.fold(0, (sum, item) => sum + item.subtotal);

  int get _shippingCost =>
      _selectedShipping == 'standar' ? _shippingStandar : _shippingEkspres;

  int get _total => _itemsSubtotal + _shippingCost;

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlamatPengiriman(),
                    const SizedBox(height: 24),
                    _buildRingkasanPesanan(),
                    const SizedBox(height: 24),
                    _buildMetodePengiriman(),
                    const SizedBox(height: 24),
                    _buildMetodePembayaran(),
                    const SizedBox(height: 24),
                    _buildRingkasanHarga(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: context.textColor,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAlamatPengiriman() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alamat Pengiriman',
              style: TextStyle(
                color: context.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur ubah alamat segera hadir!'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text(
                'Ubah',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rumah - Budi Santoso',
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jl. Hijau Lestari No. 12,\nJakarta Selatan, DKI\nJakarta, 12345',
                      style: TextStyle(
                        color: context.mutedColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '(+62) 812-3456-7890',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRingkasanPesanan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Pesanan',
          style: TextStyle(
            color: context.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: widget.items
                .map(
                  (item) => _buildOrderItem(
                    imageUrl: item.product.imageUrl,
                    name: item.product.name,
                    qty: '${item.quantity} unit',
                    price: _formatRupiah(item.subtotal),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String imageUrl,
    required String name,
    required String qty,
    required String price,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: context.surfaceAltColor,
                child: Icon(
                  Icons.image_not_supported,
                  color: context.mutedColor,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  qty,
                  style: TextStyle(color: context.mutedColor, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetodePengiriman() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pengiriman',
          style: TextStyle(
            color: context.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildShippingOption(
          value: 'standar',
          icon: Icons.local_shipping_outlined,
          label: 'Standar',
          sublabel: 'Estimasi tiba 2-3 hari',
          price: 'Rp 15.000',
        ),
        const SizedBox(height: 10),
        _buildShippingOption(
          value: 'ekspres',
          icon: Icons.bolt_outlined,
          label: 'Ekspres',
          sublabel: 'Estimasi tiba Besok',
          price: 'Rp 35.000',
        ),
      ],
    );
  }

  Widget _buildShippingOption({
    required String value,
    required IconData icon,
    required String label,
    required String sublabel,
    required String price,
  }) {
    final isSelected = _selectedShipping == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedShipping = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : context.mutedColor,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? context.textColor : context.mutedColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(color: context.mutedColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? AppColors.primary : context.mutedColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodePembayaran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: TextStyle(
            color: context.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ganti metode pembayaran segera hadir!'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-Wallet (GoPay)',
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Saldo: Rp 250.000',
                        style: TextStyle(color: context.mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.mutedColor,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRingkasanHarga() {
    return Column(
      children: [
        _buildPriceRow(
          label: 'Subtotal untuk produk',
          value: _formatRupiah(_itemsSubtotal),
        ),
        const SizedBox(height: 10),
        _buildPriceRow(
          label: 'Subtotal pengiriman',
          value: _formatRupiah(_shippingCost),
        ),
        const SizedBox(height: 14),
        Divider(color: context.dividerColor, thickness: 1),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Pembayaran',
              style: TextStyle(
                color: context.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatRupiah(_total),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: context.mutedColor, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? context.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.dividerColor, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => _confirmPayment(context),
          icon: const Icon(Icons.lock_outline, size: 18),
          label: const Text(
            'Bayar Sekarang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_processing) return;
    setState(() => _processing = true);
    final token = context.read<UserProvider>().token;
    try {
      final order = await _orderApi.createOrder(
        token: token,
        shippingMethod: _selectedShipping,
        items: widget.fromCart
            ? null
            : widget.items
                .map((i) => {'product_id': i.product.id, 'quantity': i.quantity})
                .toList(),
      );
      if (!mounted) return;
      if (widget.fromCart) context.read<CartProvider>().reset();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            orderId: order.orderId,
            orderCode: order.orderCode,
            totalAmount: order.formattedTotal,
            paymentMethod:
                order.paymentMethod.isEmpty ? 'EcoWallet' : order.paymentMethod,
          ),
        ),
      );
    } on OrderApiException catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa terhubung ke server'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _confirmPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.eco, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Konfirmasi Pembayaran',
              style: TextStyle(color: context.textColor, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Total yang akan dibayar:\n${_formatRupiah(_total)}\n\nLanjutkan pembayaran?',
          style: TextStyle(color: context.mutedColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: context.mutedColor)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _placeOrder();
            },
            child: const Text(
              'Bayar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
