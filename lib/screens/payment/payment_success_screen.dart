import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../main_wrapper.dart';
import 'order_detail_screen.dart';

// ============================================================
// PAYMENT SUCCESS SCREEN
// Ditampilkan setelah user berhasil melakukan pembayaran
// Menerima: orderId, totalAmount, paymentMethod
// ============================================================
class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  final String totalAmount;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    this.paymentMethod = 'EcoWallet',
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // Mulai animasi setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildSuccessIcon(),
                    const SizedBox(height: 24),
                    _buildThankYouText(),
                    const SizedBox(height: 32),
                    _buildTransactionDetail(),
                    const SizedBox(height: 20),
                    _buildEcoImpactBanner(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textWhite, size: 24),
            onPressed: () => _goToHome(context),
          ),
          const Expanded(
            child: Text(
              'PAYMENT SUCCESS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ── Success Icon (animated) ───────────────────────────────
  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.energy_savings_leaf_rounded,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }

  // ── Thank You Text ────────────────────────────────────────
  Widget _buildThankYouText() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: const Column(
          children: [
            Text(
              'Terima kasih!',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Pesanan Anda telah berhasil\nditempatkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Transaction Detail Card ───────────────────────────────
  Widget _buildTransactionDetail() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DETAIL TRANSAKSI',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Order ID',
                    value: widget.orderId,
                    valueBold: true,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    label: 'Jumlah',
                    value: widget.totalAmount,
                    valueColor: AppColors.primaryLight,
                    valueBold: true,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    label: 'Metode Pembayaran',
                    value: widget.paymentMethod,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppColors.textWhite,
                  fontSize: 14,
                  fontWeight:
                      valueBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF2A4D2A),
      thickness: 1,
      height: 1,
    );
  }

  // ── Eco Impact Banner ─────────────────────────────────────
  Widget _buildEcoImpactBanner() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
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
                      'Dampak Lingkungan',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Anda membantu planet ini dengan memilih siklus yang berkelanjutan.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Buttons ────────────────────────────────────────
  Widget _buildBottomButtons(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.bgDark,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        orderId: widget.orderId,
                        totalAmount: widget.totalAmount,
                        paymentMethod: widget.paymentMethod,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Detail Pesanan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => _goToHome(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF2A4D2A), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: navigasi ke Home ──────────────────────────────
  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainWrapper()),
      (route) => false,
    );
  }
}
