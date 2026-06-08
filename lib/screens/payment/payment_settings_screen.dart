import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_method_api_service.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final PaymentMethodApiService _api = PaymentMethodApiService();
  bool _busy = false;

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSection(
                      judul: 'Kelola Metode',
                      ikon: Icons.credit_card_outlined,
                      anak: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                          child: Text(
                            'Hapus seluruh metode pembayaran yang tersimpan di akunmu. Tindakan ini tidak dapat dibatalkan.',
                            style: TextStyle(
                              color: context.mutedColor,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                        _buildTombolItem(
                          label: 'Hapus Semua Metode',
                          ikon: Icons.delete_sweep_outlined,
                          onTap: _busy ? null : _konfirmasiHapusSemua,
                          warnaMerah: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: context.textColor, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Pengaturan Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String judul,
    required IconData ikon,
    required List<Widget> anak,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(ikon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              judul,
              style: TextStyle(
                color: context.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: anak),
        ),
      ],
    );
  }

  Widget _buildTombolItem({
    required String label,
    required IconData ikon,
    required VoidCallback? onTap,
    bool warnaMerah = false,
  }) {
    final warna = warnaMerah ? AppColors.danger : context.textColor;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(
              ikon,
              color: warnaMerah ? AppColors.danger : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: warna,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.chevron_right,
                color: warnaMerah
                    ? AppColors.danger.withOpacity(0.6)
                    : context.dividerColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _tampilSnackbar(String pesan, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: error ? AppColors.danger : AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _konfirmasiHapusSemua() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Semua Metode',
          style: TextStyle(color: context.textColor),
        ),
        content: Text(
          'Tindakan ini akan menghapus semua metode pembayaran tersimpan. Lanjutkan?',
          style: TextStyle(color: context.mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: context.mutedColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hapusSemua();
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusSemua() async {
    if (_busy) return;
    final token = context.read<UserProvider>().token;
    setState(() => _busy = true);
    try {
      await _api.clearAll(token);
      if (!mounted) return;
      setState(() => _busy = false);
      _tampilSnackbar('Semua metode pembayaran dihapus.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _tampilSnackbar('Gagal menghapus: $e', error: true);
    }
  }
}
