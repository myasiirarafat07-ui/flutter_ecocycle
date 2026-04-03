import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
// TODO: Import screen lain saat sudah dibuat:
// import 'search/search_screen.dart';
// import 'activity/activity_screen.dart';

// ============================================================
// MAIN WRAPPER
// Bertanggung jawab untuk:
// - Menampilkan halaman aktif sesuai tab yang dipilih
// - Menyediakan bottom nav bar yang konsisten di semua halaman
// ============================================================
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Index aktif: 0=Home, 1=Search, 3=Activity, 4=Profile
  int _currentIndex = 0;

  // Daftar halaman. Index sesuai bottom nav:
  // 0 = Home, 1 = Search, 2 = placeholder (FAB), 3 = Activity, 4 = Profile
  final List<Widget> _pages = [
    const HomeScreen(),
    const _PlaceholderScreen(label: 'Pencarian'),   // TODO: Ganti dengan SearchScreen()
    const SizedBox(),                             // slot FAB (tidak dipakai)
    const _PlaceholderScreen(label: 'Aktivitas'), // TODO: Ganti dengan ActivityScreen()
    const ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _onAddTap() {
    // TODO: Tampilkan bottom sheet atau navigasi ke halaman tambah laporan
    // showModalBottomSheet(context: context, builder: (_) => AddReportSheet());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tambah laporan baru'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0F),
      // IndexedStack menjaga state tiap halaman tetap hidup saat pindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onAddTap: _onAddTap,
      ),
    );
  }
}

// ============================================================
// PLACEHOLDER SCREEN
// Hapus class ini saat semua screen sudah dibuat
// ============================================================
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman $label\n(Segera Hadir)',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white54, fontSize: 16),
      ),
    );
  }
}