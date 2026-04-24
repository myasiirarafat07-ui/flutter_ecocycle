import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../payment/payment_success_screen.dart';

// CHECKOUT SCREEN
class CheckoutScreen extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String productImageUrl;

  const CheckoutScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedShipping = 'standar';
  bool _useEcoPoints = false;

  // Harga pengiriman
  static const int _shippingStandar = 15000;
  static const int _shippingEkspres = 35000;
  static const int _ecoPointsValue = 12500;
  static const int _ecoPointsCount = 1250;

  // Parse harga produk dari string "Rp 45.000" → int
  int get _productPriceInt {
    final clean = widget.productPrice
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll('/kg', '')
        .replaceAll(' ', '')
        .trim();
    return int.tryParse(clean) ?? 0;
  }

  int get _shippingCost =>
      _selectedShipping == 'standar' ? _shippingStandar : _shippingEkspres;

  int get _discount => _useEcoPoints ? _ecoPointsValue : 0;

  int get _total => _productPriceInt + _shippingCost - _discount;

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
      backgroundColor: AppColors.bgDark,
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
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textWhite,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
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
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(
                color: AppColors.textWhite,
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
                  color: AppColors.primaryLight,
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
            color: AppColors.bgCard,
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
                  color: AppColors.primaryLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rumah - Budi Santoso',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Jl. Hijau Lestari No. 12,\nJakarta Selatan, DKI\nJakarta, 12345',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '(+62) 812-3456-7890',
                      style: TextStyle(
                        color: AppColors.primaryLight,
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
        const Text(
          'Ringkasan Pesanan',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: _buildOrderItem(
            imageUrl: widget.productImageUrl,
            name: widget.productName,
            qty: '1 unit',
            price: widget.productPrice,
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
                color: const Color(0xFF1E4D1E),
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white24,
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
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  qty,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.textWhite,
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
        const Text(
          'Metode Pengiriman',
          style: TextStyle(
            color: AppColors.textWhite,
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
              : AppColors.bgCard,
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
              color: isSelected ? AppColors.primaryLight : Colors.white54,
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
                      color: isSelected ? AppColors.textWhite : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? AppColors.primaryLight : Colors.white70,
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
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // E-Wallet
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
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-Wallet (GoPay)',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Saldo: Rp 250.000',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _useEcoPoints ? AppColors.primary : AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.eco,
                color: _useEcoPoints ? Colors.white : AppColors.primaryLight,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gunakan Eco Points',
                      style: TextStyle(
                        color: _useEcoPoints
                            ? Colors.white
                            : AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tersedia $_ecoPointsCount poin (${_formatRupiah(_ecoPointsValue)})',
                      style: TextStyle(
                        color: _useEcoPoints ? Colors.white70 : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useEcoPoints,
                onChanged: (val) => setState(() => _useEcoPoints = val),
                activeColor: Colors.white,
                activeTrackColor: AppColors.primaryLight,
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: const Color(0xFF2E5C2E),
              ),
            ],
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
          value: _formatRupiah(_productPriceInt),
        ),
        const SizedBox(height: 10),
        _buildPriceRow(
          label: 'Subtotal pengiriman',
          value: _formatRupiah(_shippingCost),
        ),
        if (_useEcoPoints) ...[
          const SizedBox(height: 10),
          _buildPriceRow(
            label: 'Diskon Eco Points',
            value: '- ${_formatRupiah(_discount)}',
            valueColor: AppColors.primaryLight,
          ),
        ],
        const SizedBox(height: 14),
        const Divider(color: Color(0xFF2E5C2E), thickness: 1),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Pembayaran',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatRupiah(_total),
              style: const TextStyle(
                color: AppColors.primaryLight,
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
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textWhite,
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
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
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

  void _confirmPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.eco, color: AppColors.primaryLight, size: 22),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Pembayaran',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Total yang akan dibayar:\n${_formatRupiah(_total)}\n\nLanjutkan pembayaran?',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // tutup dialog konfirmasi
              // Navigasi ke halaman Payment Success
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentSuccessScreen(
                    orderId: '#EC-${(88000 + _total % 1000).abs()}',
                    totalAmount: _formatRupiah(_total),
                    paymentMethod: _useEcoPoints
                        ? 'EcoWallet + Eco Points'
                        : 'EcoWallet',
                  ),
                ),
              );
            },
            child: const Text(
              'Bayar',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
