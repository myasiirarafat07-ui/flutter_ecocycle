import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/shipping.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import '../../services/order_api_service.dart';
import '../../services/payment_method_api_service.dart';
import '../../widgets/product_image.dart';
import '../payment/payment_success_screen.dart';
import '../profile/personal_info_screen.dart';

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
  final PaymentMethodApiService _paymentApi = PaymentMethodApiService();
  bool _processing = false;

  // Pembayaran: COD jadi default, sisanya E-Wallet tersimpan.
  String _paymentLabel = 'COD (Bayar di Tempat)';
  String _paymentValue = 'COD';
  IconData _paymentIcon = Icons.payments_outlined;
  List<PaymentMethod> _ewallets = [];

  // Pengiriman antar-warga berbasis lokasi.
  double? _buyerLat;
  double? _buyerLng;
  bool _locating = false;
  ShippingQuote _quote = const ShippingQuote(
    cost: Shipping.fallbackFee,
    distanceKm: 0,
    totalWeightKg: 0,
    fallback: true,
  );

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _recomputeQuote();
  }

  /// Bangun leg per-penjual: koordinat penjual + total berat barangnya.
  List<ShipLeg> _buildLegs() {
    final bySeller = <int, ShipLeg>{};
    final weightBySeller = <int, double>{};
    for (final item in widget.items) {
      final p = item.product;
      weightBySeller[p.sellerId] =
          (weightBySeller[p.sellerId] ?? 0) + p.weightKg * item.quantity;
      bySeller[p.sellerId] = ShipLeg(
        lat: p.sellerLat,
        lng: p.sellerLng,
        weightKg: weightBySeller[p.sellerId]!,
      );
    }
    return bySeller.values.toList();
  }

  void _recomputeQuote() {
    setState(() {
      _quote = calcShipping(
        buyerLat: _buyerLat,
        buyerLng: _buyerLng,
        legs: _buildLegs(),
      );
    });
  }

  Future<void> _useMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final pos = await LocationService.getCurrentPosition();
      if (!mounted) return;
      _buyerLat = pos.latitude;
      _buyerLng = pos.longitude;
      _recomputeQuote();
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengambil lokasi'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    final token = context.read<UserProvider>().token;
    if (token.isEmpty) return;
    try {
      final list = await _paymentApi.getMethods(token);
      if (!mounted) return;
      setState(() {
        // Kartu sudah tidak dipakai — hanya E-Wallet yang ditawarkan.
        _ewallets =
            list.where((m) => m.methodType == 'EWALLET').toList(growable: false);
      });
    } catch (_) {
      // Diam saja; COD tetap tersedia sebagai default.
    }
  }

  int get _itemsSubtotal =>
      widget.items.fold(0, (sum, item) => sum + item.subtotal);

  int get _shippingCost => _quote.cost;

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
    final user = context.watch<UserProvider>();
    final hasAddress = user.address.trim().isNotEmpty;
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalInfoScreen(),
                  ),
                );
              },
              child: Text(
                hasAddress ? 'Ubah' : 'Lengkapi',
                style: const TextStyle(
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
                      user.name.isEmpty ? 'Penerima' : user.name,
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasAddress
                          ? user.address
                          : 'Alamat belum diatur. Tekan "Lengkapi" untuk menambah alamat pengiriman.',
                      style: TextStyle(
                        color: context.mutedColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    if (user.phone.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
            child: ProductImage(
              imageUrl: imageUrl,
              width: 64,
              height: 64,
              iconSize: 28,
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
    final hasBuyerLoc = _buyerLat != null && _buyerLng != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengiriman Antar-Warga',
          style: TextStyle(
            color: context.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ongkir dihitung dari jarak penjual ke lokasimu dan berat barang.',
          style: TextStyle(color: context.mutedColor, fontSize: 12),
        ),
        const SizedBox(height: 12),
        if (hasBuyerLoc) _buildMap(),
        if (hasBuyerLoc) const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    hasBuyerLoc ? Icons.location_on : Icons.location_off_outlined,
                    color: hasBuyerLoc ? AppColors.primary : context.mutedColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasBuyerLoc
                          ? 'Lokasimu: ${_buyerLat!.toStringAsFixed(5)}, ${_buyerLng!.toStringAsFixed(5)}'
                          : 'Bagikan lokasimu untuk ongkir yang akurat.',
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _locating ? null : _useMyLocation,
                  icon: _locating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.my_location, size: 18),
                  label: Text(hasBuyerLoc ? 'Perbarui Lokasi' : 'Gunakan Lokasi Saya'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildShippingInfoRow(
                Icons.route_outlined,
                'Jarak',
                _quote.fallback
                    ? 'Belum dihitung'
                    : '± ${_quote.distanceKm.toStringAsFixed(1)} km',
              ),
              const SizedBox(height: 8),
              _buildShippingInfoRow(
                Icons.scale_outlined,
                'Total berat',
                '${_quote.totalWeightKg.toStringAsFixed(_quote.totalWeightKg % 1 == 0 ? 0 : 1)} kg',
              ),
              const SizedBox(height: 8),
              _buildShippingInfoRow(
                Icons.local_shipping_outlined,
                'Ongkos kirim',
                _formatRupiah(_quote.cost),
                highlight: true,
              ),
              if (_quote.fallback) ...[
                const SizedBox(height: 8),
                Text(
                  'Lokasi penjual/pembeli belum lengkap — memakai tarif perkiraan. '
                  'Tekan "Gunakan Lokasi Saya" untuk ongkir akurat.',
                  style: TextStyle(color: context.mutedColor, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShippingInfoRow(
    IconData icon,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: context.mutedColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: context.mutedColor, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.primary : context.textColor,
            fontSize: highlight ? 15 : 13,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final buyer = LatLng(_buyerLat!, _buyerLng!);
    final sellerPoints = <LatLng>[];
    for (final item in widget.items) {
      final p = item.product;
      if (p.sellerLat != null && p.sellerLng != null) {
        final point = LatLng(p.sellerLat!, p.sellerLng!);
        if (!sellerPoints.any((s) => s.latitude == point.latitude &&
            s.longitude == point.longitude)) {
          sellerPoints.add(point);
        }
      }
    }

    // Pusatkan peta di antara pembeli & penjual pertama (bila ada).
    final center = sellerPoints.isNotEmpty
        ? LatLng(
            (buyer.latitude + sellerPoints.first.latitude) / 2,
            (buyer.longitude + sellerPoints.first.longitude) / 2,
          )
        : buyer;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: sellerPoints.isEmpty ? 15 : 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ecocycle.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: buyer,
                  width: 44,
                  height: 44,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                for (final s in sellerPoints)
                  Marker(
                    point: s,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.store_mall_directory,
                      color: AppColors.danger,
                      size: 36,
                    ),
                  ),
              ],
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
          onTap: _pilihMetodePembayaran,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(_paymentIcon, color: AppColors.primary, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _paymentLabel,
                        style: TextStyle(
                          color: context.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _paymentValue == 'COD'
                            ? 'Bayar tunai saat barang diterima'
                            : 'E-Wallet',
                        style: TextStyle(color: context.mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.mutedColor, size: 22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pilihMetodePembayaran() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildPaymentOptionTile(
                  icon: Icons.payments_outlined,
                  label: 'COD (Bayar di Tempat)',
                  value: 'COD',
                ),
                ..._ewallets.map(
                  (m) => _buildPaymentOptionTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: m.label,
                    value: m.label,
                  ),
                ),
                if (_ewallets.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan E-Wallet di menu Metode Pembayaran untuk opsi lain.',
                    style: TextStyle(color: context.mutedColor, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOptionTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final bool selected = _paymentValue == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentLabel = label;
          _paymentValue = value;
          _paymentIcon = icon;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : context.bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : context.dividerColor,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : context.mutedColor,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
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
        shippingMethod: 'antar_warga',
        paymentMethod: _paymentValue,
        buyerLat: _buyerLat,
        buyerLng: _buyerLng,
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
                order.paymentMethod.isEmpty ? 'COD' : order.paymentMethod,
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
