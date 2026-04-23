import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../main_wrapper.dart';

// ============================================================
// ORDER DETAIL SCREEN
// Ditampilkan saat user tap "Lihat Detail Pesanan" di
// PaymentSuccessScreen
// ============================================================
class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final String totalAmount;
  final String paymentMethod;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    this.paymentMethod = 'EcoWallet',
  });

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
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                    _buildStatusPesanan(),
                    const SizedBox(height: 24),
                    _buildInfoPengiriman(),
                    const SizedBox(height: 24),
                    _buildItemPesanan(),
                    const SizedBox(height: 24),
                    _buildRincianPembayaran(),
                    const SizedBox(height: 8),
                    _buildEcoPointsBanner(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: AppColors.textWhite, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Detail Pesanan',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.5), width: 1),
            ),
            child: Text(
              orderId,
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              side: const BorderSide(
                  color: AppColors.primaryLight, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Butuh Bantuan?',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainWrapper()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ── Status Pesanan ────────────────────────────────────────
  Widget _buildStatusPesanan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pesanan',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Estimasi tiba: 24 Okt',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusStep(
            icon: Icons.check,
            label: 'Pesanan Dibuat',
            sublabel: '20 Okt, 10:30',
            state: _StepState.done,
            isLast: false,
          ),
          _buildStatusStep(
            icon: Icons.check,
            label: 'Diproses',
            sublabel: '21 Okt, 09:15',
            state: _StepState.done,
            isLast: false,
          ),
          _buildStatusStep(
            icon: Icons.local_shipping_outlined,
            label: 'Dikirim',
            sublabel: 'Sedang dalam perjalanan oleh kurir',
            state: _StepState.active,
            isLast: false,
          ),
          _buildStatusStep(
            icon: Icons.assignment_turned_in_outlined,
            label: 'Selesai',
            sublabel: '',
            state: _StepState.pending,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep({
    required IconData icon,
    required String label,
    required String sublabel,
    required _StepState state,
    required bool isLast,
  }) {
    final isDone = state == _StepState.done;
    final isActive = state == _StepState.active;

    Color iconBg = isDone
        ? AppColors.primary
        : isActive
            ? AppColors.bgCard
            : AppColors.bgCard;
    Color iconColor = isDone
        ? Colors.white
        : isActive
            ? AppColors.primaryLight
            : Colors.white38;
    Color labelColor = isDone || isActive ? AppColors.textWhite : Colors.white38;
    Color sublabelColor = isDone
        ? AppColors.primaryLight
        : isActive
            ? Colors.white60
            : Colors.white38;

    Border? iconBorder = isActive
        ? Border.all(color: AppColors.primaryLight, width: 1.5)
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + line
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: iconBorder,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone
                    ? AppColors.primary.withOpacity(0.5)
                    : Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (sublabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(color: sublabelColor, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Informasi Pengiriman ──────────────────────────────────
  Widget _buildInfoPengiriman() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on_outlined,
                  color: AppColors.primaryLight, size: 18),
              SizedBox(width: 8),
              Text(
                'Informasi Pengiriman',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'ALAMAT PENGIRIMAN',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Budi Santoso',
            style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            'Jl. Kebon Jeruk No. 12, Jakarta Barat, DKI Jakarta,\n11530',
            style: TextStyle(
                color: Colors.white54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'KURIR',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.eco_outlined,
                  color: AppColors.primaryLight, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Eco-Courier - JNE Express (REG)',
                style: TextStyle(
                    color: AppColors.textWhite, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Item Pesanan ──────────────────────────────────────────
  Widget _buildItemPesanan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Pesanan',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildOrderItem(
          imageUrl:
              'https://images.unsplash.com/photo-1585664811087-47f65abbad64?w=200',
          name: 'Organic Fertilizer XL',
          variant: 'Kompos Alami - 5kg',
          price: 'Rp 45.000',
          qty: 'x2',
        ),
        const SizedBox(height: 10),
        _buildOrderItem(
          imageUrl:
              'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=200',
          name: 'Recycled Plant Pot',
          variant: 'Diameter 20cm - Grey',
          price: 'Rp 25.000',
          qty: 'x1',
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String imageUrl,
    required String name,
    required String variant,
    required String price,
    required String qty,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 68,
                height: 68,
                color: const Color(0xFF1E4D1E),
                child: const Icon(Icons.image_not_supported,
                    color: Colors.white24, size: 28),
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
                ),
                const SizedBox(height: 2),
                Text(
                  variant,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            qty,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ── Rincian Pembayaran ────────────────────────────────────
  Widget _buildRincianPembayaran() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Subtotal', 'Rp 115.000'),
          const SizedBox(height: 10),
          _buildPriceRow('Ongkos Kirim', 'Rp 12.000'),
          const SizedBox(height: 10),
          _buildPriceRow('Biaya Layanan (Eco Tax)', 'Rp 2.000'),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF2A4D2A), thickness: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                totalAmount,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Eco Points Banner ─────────────────────────────────────
  Widget _buildEcoPointsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_rounded,
              color: AppColors.primaryLight, size: 18),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13),
              children: [
                TextSpan(
                    text: 'Kamu mendapatkan ',
                    style: TextStyle(color: Colors.white54)),
                TextSpan(
                    text: '129 Eco Points',
                    style: TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: '.',
                    style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, active, pending }
