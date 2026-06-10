import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_method_api_service.dart';
import 'transaction_history_screen.dart';
import 'payment_settings_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final PaymentMethodApiService _api = PaymentMethodApiService();
  List<PaymentMethod> _methods = [];
  bool _loading = true;
  bool _busy = false;

  String get _token => context.read<UserProvider>().token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _api.getMethods(_token);
      if (!mounted) return;
      setState(() {
        _methods = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e);
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e'), backgroundColor: AppColors.danger),
    );
  }

  Future<void> _setPrimary(int id) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final list = await _api.setDefault(_token, id);
      if (!mounted) return;
      setState(() => _methods = list);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _hapusMetode(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Metode',
          style: TextStyle(color: context.textColor),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus metode pembayaran ini?',
          style: TextStyle(color: context.mutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: context.mutedColor)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteMethod(id);
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

  Future<void> _deleteMethod(int id) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final list = await _api.remove(_token, id);
      if (!mounted) return;
      setState(() => _methods = list);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _tambahMetode() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TambahMetodeSheet(
        onTambah: (methodType, label, detail) async {
          Navigator.pop(context);
          await _addMethod(methodType, label, detail);
        },
      ),
    );
  }

  Future<void> _addMethod(
      String methodType, String label, String detail) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final list = await _api.add(
        _token,
        methodType: methodType,
        label: label,
        detail: detail,
      );
      if (!mounted) return;
      setState(() => _methods = list);
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildSavedMethodsSection(),
                          const SizedBox(height: 28),
                          _buildQuickActions(context),
                          const SizedBox(height: 24),
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
              'Metode Pembayaran',
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

  Widget _buildSavedMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Metode Tersimpan',
              style: TextStyle(
                color: context.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _tambahMetode,
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Tambah Baru',
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
        const SizedBox(height: 14),
        if (_methods.isEmpty)
          _buildEmptyMethods()
        else
          ..._methods.map(_buildMethodTile),
      ],
    );
  }

  Widget _buildMethodTile(PaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: method.isDefault
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getPaymentIcon(method.methodType),
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
                  method.label,
                  style: TextStyle(
                    color: context.textColor,
                    fontSize: 15,
                    fontWeight: method.isDefault
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  method.detail,
                  style: TextStyle(color: context.mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          if (method.isDefault)
            const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 24,
            )
          else
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: context.mutedColor,
                size: 22,
              ),
              color: context.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (val) {
                if (val == 'utama') _setPrimary(method.id);
                if (val == 'hapus') _hapusMetode(method.id);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'utama',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, color: context.mutedColor, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Jadikan Utama',
                        style: TextStyle(color: context.textColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'hapus',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Hapus',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyMethods() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off_outlined,
            color: context.dividerColor,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada metode pembayaran',
            style: TextStyle(color: context.mutedColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _tambahMetode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '+ Tambah Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            color: context.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.receipt_long_outlined,
                label: 'Riwayat\nTransaksi',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionHistoryScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.tune_outlined,
                label: 'Pengaturan\nPembayaran',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentSettingsScreen(),
                  ),
                ).then((_) => _load()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String methodType) {
    switch (methodType) {
      case 'KARTU_KREDIT':
        return Icons.credit_card;
      case 'KARTU_DEBIT':
        return Icons.payment;
      case 'EWALLET':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.credit_card;
    }
  }
}

class _TambahMetodeSheet extends StatefulWidget {
  /// Callback: (methodType, label, detail).
  final Future<void> Function(String methodType, String label, String detail)
      onTambah;
  const _TambahMetodeSheet({required this.onTambah});

  @override
  State<_TambahMetodeSheet> createState() => _TambahMetodeSheetState();
}

class _TambahMetodeSheetState extends State<_TambahMetodeSheet> {
  String? _terpilih; // id opsi yang dipilih

  final List<Map<String, String>> _opsiEwallet = [
    {'id': 'gopay', 'nama': 'GoPay', 'tipe': 'EWALLET'},
    {'id': 'shopeepay', 'nama': 'ShopeePay', 'tipe': 'EWALLET'},
    {'id': 'dana', 'nama': 'DANA', 'tipe': 'EWALLET'},
    {'id': 'ovo', 'nama': 'OVO', 'tipe': 'EWALLET'},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Metode Baru',
                    style: TextStyle(
                      color: context.textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'E-Wallet',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._opsiEwallet.map((o) => _buildOpsi(o)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _terpilih == null ? null : _konfirmasi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: context.surfaceColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tambahkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildOpsi(Map<String, String> opsi) {
    final bool dipilih = _terpilih == opsi['id'];
    return GestureDetector(
      onTap: () => setState(() => _terpilih = opsi['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: dipilih
              ? AppColors.primary.withValues(alpha: 0.3)
              : context.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dipilih ? AppColors.primary : context.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              opsi['tipe'] == 'EWALLET'
                  ? Icons.account_balance_wallet_outlined
                  : Icons.credit_card,
              color: dipilih ? AppColors.primary : context.mutedColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              opsi['nama']!,
              style: TextStyle(
                color: dipilih ? Colors.white : context.mutedColor,
                fontSize: 14,
                fontWeight: dipilih ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (dipilih)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  void _konfirmasi() {
    final opsi = _opsiEwallet.firstWhere((o) => o['id'] == _terpilih);
    widget.onTambah(opsi['tipe']!, opsi['nama']!, 'Terhubung');
  }
}
