import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'transaction_history_screen.dart';
import 'payment_settings_screen.dart';

// ============================================================
// MODEL METODE PEMBAYARAN
// ============================================================
enum PaymentType { kartuKredit, kartuDebit, eWallet }

class PaymentMethod {
  final String id;
  final String nama;
  final String detail;
  final PaymentType tipe;
  bool isPrimary;

  PaymentMethod({
    required this.id,
    required this.nama,
    required this.detail,
    required this.tipe,
    this.isPrimary = false,
  });
}

// ============================================================
// PAYMENT METHOD SCREEN
// ============================================================
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // Data dummy metode pembayaran
  final List<PaymentMethod> _methods = [
    PaymentMethod(
      id: '1',
      nama: 'Visa Classic',
      detail: '•••• •••• •••• 4242',
      tipe: PaymentType.kartuKredit,
      isPrimary: true,
    ),
    PaymentMethod(
      id: '2',
      nama: 'Mastercard Gold',
      detail: '•••• •••• •••• 8890',
      tipe: PaymentType.kartuDebit,
      isPrimary: false,
    ),
    PaymentMethod(
      id: '3',
      nama: 'GoPay E-Wallet',
      detail: 'Terhubung: +62 812 •••• 44',
      tipe: PaymentType.eWallet,
      isPrimary: false,
    ),
  ];

  // Data Eco Points
  final int _ecoPoints = 2450;
  final int _pointsNextReward = 150;
  final int _currentXP = 2450;
  final int _maxXP = 2600;
  final String _level = 'ECO WARRIOR';

  void _setPrimary(String id) {
    setState(() {
      for (final m in _methods) {
        m.isPrimary = m.id == id;
      }
    });
  }

  void _hapusMetode(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Metode', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Apakah kamu yakin ingin menghapus metode pembayaran ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _methods.removeWhere((m) => m.id == id));
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _tambahMetode() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TambahMetodeSheet(
        onTambah: (method) {
          setState(() => _methods.add(method));
        },
      ),
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildEcoPointsSection(),
                    const SizedBox(height: 28),
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
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Metode Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
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

  // ── ECO POINTS ──────────────────────────────────────────
  Widget _buildEcoPointsSection() {
    final double progress = _currentXP / _maxXP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saldo Eco Points',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.primaryLight, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    '${_formatAngka(_ecoPoints)} Poin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$_pointsNextReward poin lagi untuk reward berikutnya',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur tukar poin segera hadir!'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Tukarkan Poin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEVEL: $_level',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.bgDark,
                  color: AppColors.accent,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$_currentXP / $_maxXP XP',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── SAVED METHODS ────────────────────────────────────────
  Widget _buildSavedMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Metode Tersimpan',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _tambahMetode,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.primaryLight, size: 18),
                  const SizedBox(width: 4),
                  const Text(
                    'Tambah Baru',
                    style: TextStyle(color: AppColors.primaryLight, fontSize: 13),
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
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: method.isPrimary
            ? Border.all(color: AppColors.primary.withOpacity(0.6), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getPaymentIcon(method.tipe),
              color: AppColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.nama,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: method.isPrimary ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  method.detail,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (method.isPrimary)
            const Icon(Icons.check_circle, color: AppColors.primaryLight, size: 24)
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54, size: 22),
              color: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'utama') _setPrimary(method.id);
                if (val == 'hapus') _hapusMetode(method.id);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'utama',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, color: Colors.white70, size: 18),
                      SizedBox(width: 10),
                      Text('Jadikan Utama',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'hapus',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 18),
                      SizedBox(width: 10),
                      Text('Hapus',
                          style: TextStyle(color: Color(0xFFE53935), fontSize: 14)),
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
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.credit_card_off_outlined, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          const Text('Belum ada metode pembayaran',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _tambahMetode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('+ Tambah Sekarang',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS ────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            color: AppColors.textWhite,
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
                  MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
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
                  MaterialPageRoute(builder: (_) => const PaymentSettingsScreen()),
                ),
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
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
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

  // ── HELPERS ──────────────────────────────────────────────
  IconData _getPaymentIcon(PaymentType tipe) {
    switch (tipe) {
      case PaymentType.kartuKredit:
        return Icons.credit_card;
      case PaymentType.kartuDebit:
        return Icons.payment;
      case PaymentType.eWallet:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _formatAngka(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

// ============================================================
// BOTTOM SHEET TAMBAH METODE PEMBAYARAN
// ============================================================
class _TambahMetodeSheet extends StatefulWidget {
  final Function(PaymentMethod) onTambah;
  const _TambahMetodeSheet({required this.onTambah});

  @override
  State<_TambahMetodeSheet> createState() => _TambahMetodeSheetState();
}

class _TambahMetodeSheetState extends State<_TambahMetodeSheet> {
  String? _terpilih; // id opsi yang dipilih

  final List<Map<String, dynamic>> _opsiKartu = [
    {'id': 'visa', 'nama': 'Kartu Visa', 'tipe': PaymentType.kartuKredit},
    {'id': 'mastercard', 'nama': 'Kartu Mastercard', 'tipe': PaymentType.kartuDebit},
  ];

  final List<Map<String, dynamic>> _opsiEwallet = [
    {'id': 'gopay', 'nama': 'GoPay', 'tipe': PaymentType.eWallet},
    {'id': 'shopeepay', 'nama': 'ShopeePay', 'tipe': PaymentType.eWallet},
    {'id': 'dana', 'nama': 'DANA', 'tipe': PaymentType.eWallet},
    {'id': 'ovo', 'nama': 'OVO', 'tipe': PaymentType.eWallet},
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
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20, right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          const Text('Tambah Metode Baru',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Kartu', style: TextStyle(
              color: AppColors.primaryLight, fontSize: 12,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          ..._opsiKartu.map((o) => _buildOpsi(o)),
          const SizedBox(height: 14),
          const Text('E-Wallet', style: TextStyle(
              color: AppColors.primaryLight, fontSize: 12,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          ..._opsiEwallet.map((o) => _buildOpsi(o)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _terpilih == null ? null : _konfirmasi,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.bgCard,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tambahkan',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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

  Widget _buildOpsi(Map<String, dynamic> opsi) {
    final bool dipilih = _terpilih == opsi['id'];
    return GestureDetector(
      onTap: () => setState(() => _terpilih = opsi['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: dipilih ? AppColors.primary.withOpacity(0.3) : AppColors.bgDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dipilih ? AppColors.primaryLight : Colors.white12,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              opsi['tipe'] == PaymentType.eWallet
                  ? Icons.account_balance_wallet_outlined
                  : Icons.credit_card,
              color: dipilih ? AppColors.primaryLight : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(opsi['nama'],
                style: TextStyle(
                  color: dipilih ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: dipilih ? FontWeight.w600 : FontWeight.normal,
                )),
            const Spacer(),
            if (dipilih)
              const Icon(Icons.check_circle, color: AppColors.primaryLight, size: 18),
          ],
        ),
      ),
    );
  }

  void _konfirmasi() {
    final semua = [..._opsiKartu, ..._opsiEwallet];
    final opsi = semua.firstWhere((o) => o['id'] == _terpilih);
    final newMethod = PaymentMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: opsi['nama'] as String,
      detail: opsi['tipe'] == PaymentType.eWallet
          ? 'Terhubung: Nomor baru'
          : '•••• •••• •••• ????',
      tipe: opsi['tipe'] as PaymentType,
    );
    widget.onTambah(newMethod);
    Navigator.pop(context);
  }
}