import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// PAYMENT SETTINGS SCREEN
class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  bool _notifTransaksi = true;
  bool _notifPoin = true;
  bool _konfirmasiPembayaran = true;
  bool _autoPenukaranPoin = false;
  bool _modePinaman = false;

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
                    _buildSection(
                      judul: 'Notifikasi',
                      ikon: Icons.notifications_outlined,
                      anak: [
                        _buildToggleItem(
                          label: 'Notifikasi Transaksi',
                          deskripsi:
                              'Terima pemberitahuan setiap ada transaksi',
                          nilai: _notifTransaksi,
                          onUbah: (v) => setState(() => _notifTransaksi = v),
                        ),
                        _buildToggleItem(
                          label: 'Notifikasi Poin',
                          deskripsi:
                              'Pemberitahuan saat poin bertambah atau berkurang',
                          nilai: _notifPoin,
                          onUbah: (v) => setState(() => _notifPoin = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      judul: 'Keamanan',
                      ikon: Icons.security_outlined,
                      anak: [
                        _buildToggleItem(
                          label: 'Konfirmasi Pembayaran',
                          deskripsi:
                              'Minta konfirmasi sebelum setiap pembayaran',
                          nilai: _konfirmasiPembayaran,
                          onUbah: (v) =>
                              setState(() => _konfirmasiPembayaran = v),
                        ),
                        _buildToggleItem(
                          label: 'Mode Hemat (PIN)',
                          deskripsi:
                              'Gunakan PIN untuk transaksi di atas Rp 50.000',
                          nilai: _modePinaman,
                          onUbah: (v) => setState(() => _modePinaman = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      judul: 'Eco Points',
                      ikon: Icons.eco_outlined,
                      anak: [
                        _buildToggleItem(
                          label: 'Auto Tukar Poin',
                          deskripsi:
                              'Tukar poin otomatis saat mencapai batas reward',
                          nilai: _autoPenukaranPoin,
                          onUbah: (v) => setState(() => _autoPenukaranPoin = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      judul: 'Lainnya',
                      ikon: Icons.more_horiz,
                      anak: [
                        _buildTombolItem(
                          label: 'Ubah PIN Pembayaran',
                          ikon: Icons.lock_outline,
                          onTap: () =>
                              _tampilSnackbar('Fitur ubah PIN segera hadir!'),
                        ),
                        _buildTombolItem(
                          label: 'Ekspor Riwayat Transaksi',
                          ikon: Icons.download_outlined,
                          onTap: () =>
                              _tampilSnackbar('Mengekspor data transaksi...'),
                        ),
                        _buildTombolItem(
                          label: 'Hapus Semua Metode',
                          ikon: Icons.delete_sweep_outlined,
                          onTap: () => _konfirmasiHapusSemua(),
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
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Pengaturan Pembayaran',
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
            Icon(ikon, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text(
              judul,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: anak),
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required String label,
    required String deskripsi,
    required bool nilai,
    required ValueChanged<bool> onUbah,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  deskripsi,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: nilai,
            onChanged: onUbah,
            activeColor: AppColors.primaryLight,
            activeTrackColor: AppColors.primary.withOpacity(0.5),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildTombolItem({
    required String label,
    required IconData ikon,
    required VoidCallback onTap,
    bool warnaMerah = false,
  }) {
    final warna = warnaMerah ? AppColors.danger : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(
              ikon,
              color: warnaMerah ? AppColors.danger : AppColors.primaryLight,
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
            Icon(
              Icons.chevron_right,
              color: warnaMerah
                  ? AppColors.danger.withOpacity(0.6)
                  : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _tampilSnackbar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _konfirmasiHapusSemua() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Semua Metode',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tindakan ini akan menghapus semua metode pembayaran tersimpan. Lanjutkan?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tampilSnackbar('Semua metode pembayaran dihapus.');
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
}
