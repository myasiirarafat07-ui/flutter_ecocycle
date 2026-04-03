import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// ============================================================
// MODEL TRANSAKSI
// ============================================================
enum TipeTransaksi { penjualan, pembelian, penukaran, bonus }

class ItemTransaksi {
  final String id;
  final String judul;
  final String subjudul;
  final String tanggal;
  final String nominal;
  final bool isPositif;
  final TipeTransaksi tipe;

  const ItemTransaksi({
    required this.id,
    required this.judul,
    required this.subjudul,
    required this.tanggal,
    required this.nominal,
    required this.isPositif,
    required this.tipe,
  });
}

// ============================================================
// TRANSACTION HISTORY SCREEN
// ============================================================
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filterAktif = 'Semua';
  final List<String> _filterList = ['Semua', 'Penjualan', 'Pembelian', 'Penukaran'];

  final List<ItemTransaksi> _semuaTransaksi = const [
    ItemTransaksi(
      id: '1',
      judul: 'Penjualan Plastik PET',
      subjudul: 'Bank Sampah Maju Jaya',
      tanggal: 'Hari ini, 14:20',
      nominal: '+Rp 12.500',
      isPositif: true,
      tipe: TipeTransaksi.penjualan,
    ),
    ItemTransaksi(
      id: '2',
      judul: 'Penukaran Eco Points',
      subjudul: '500 poin → Voucher belanja',
      tanggal: 'Kemarin, 10:05',
      nominal: '-500 Poin',
      isPositif: false,
      tipe: TipeTransaksi.penukaran,
    ),
    ItemTransaksi(
      id: '3',
      judul: 'Penjualan Kardus',
      subjudul: 'Bank Sampah Harapan',
      tanggal: '30 Mar, 09:15',
      nominal: '+Rp 8.000',
      isPositif: true,
      tipe: TipeTransaksi.penjualan,
    ),
    ItemTransaksi(
      id: '4',
      judul: 'Pembelian Pupuk Kompos',
      subjudul: 'Marketplace EcoCycle',
      tanggal: '28 Mar, 16:40',
      nominal: '-Rp 25.000',
      isPositif: false,
      tipe: TipeTransaksi.pembelian,
    ),
    ItemTransaksi(
      id: '5',
      judul: 'Bonus Eco Points',
      subjudul: 'Verifikasi daur ulang plastik',
      tanggal: '27 Mar, 11:00',
      nominal: '+50 Poin',
      isPositif: true,
      tipe: TipeTransaksi.bonus,
    ),
    ItemTransaksi(
      id: '6',
      judul: 'Penjualan Aluminium',
      subjudul: 'Bank Sampah Maju Jaya',
      tanggal: '25 Mar, 13:30',
      nominal: '+Rp 32.000',
      isPositif: true,
      tipe: TipeTransaksi.penjualan,
    ),
  ];

  List<ItemTransaksi> get _transaksiTerfilter {
    if (_filterAktif == 'Semua') return _semuaTransaksi;
    final map = {
      'Penjualan': TipeTransaksi.penjualan,
      'Pembelian': TipeTransaksi.pembelian,
      'Penukaran': TipeTransaksi.penukaran,
    };
    return _semuaTransaksi.where((t) => t.tipe == map[_filterAktif]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            _buildFilterChips(),
            Expanded(
              child: _transaksiTerfilter.isEmpty
                  ? _buildKosong()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _transaksiTerfilter.length,
                      itemBuilder: (_, i) => _buildTileTransaksi(_transaksiTerfilter[i]),
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
              'Riwayat Transaksi',
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: _filterList.map((f) {
          final aktif = f == _filterAktif;
          return GestureDetector(
            onTap: () => setState(() => _filterAktif = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: aktif ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: aktif
                    ? null
                    : Border.all(color: Colors.white12, width: 1),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: aktif ? Colors.white : Colors.white54,
                  fontSize: 13,
                  fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTileTransaksi(ItemTransaksi item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: item.isPositif
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.red.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIkonTransaksi(item.tipe),
              color: item.isPositif ? AppColors.primaryLight : AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.judul,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.subjudul,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 2),
                Text(item.tanggal,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text(
            item.nominal,
            style: TextStyle(
              color: item.isPositif ? AppColors.primaryLight : AppColors.danger,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKosong() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 56),
          SizedBox(height: 14),
          Text('Tidak ada transaksi',
              style: TextStyle(color: Colors.white38, fontSize: 15)),
        ],
      ),
    );
  }

  IconData _getIkonTransaksi(TipeTransaksi tipe) {
    switch (tipe) {
      case TipeTransaksi.penjualan: return Icons.sell_outlined;
      case TipeTransaksi.pembelian: return Icons.shopping_bag_outlined;
      case TipeTransaksi.penukaran: return Icons.swap_horiz;
      case TipeTransaksi.bonus: return Icons.stars_outlined;
    }
  }
}
