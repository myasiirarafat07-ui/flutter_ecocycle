import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
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
// - Menyediakan Drawer (panel menu samping kiri)
//
// CARA BUKA DRAWER:
// 1. Swipe dari kiri ke kanan di layar mana saja
// 2. Tap ikon hamburger (≡) di AppBar HomeScreen
// ============================================================
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Key ini digunakan untuk membuka drawer secara programatik
  // (dipanggil dari HomeScreen lewat callback openDrawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Index aktif: 0=Home, 1=Search, 3=Activity, 4=Profile
  int _currentIndex = 0;

  // Daftar halaman. Index sesuai bottom nav:
  // 0 = Home, 1 = Search, 2 = placeholder (FAB), 3 = Activity, 4 = Profile
  List<Widget> get _pages => [
    HomeScreen(onOpenDrawer: _openDrawer), // kirim callback ke HomeScreen
    const _PlaceholderScreen(label: 'Pencarian'),   // TODO: Ganti dengan SearchScreen()
    const SizedBox(),                               // slot FAB (tidak dipakai)
    const _PlaceholderScreen(label: 'Aktivitas'),   // TODO: Ganti dengan ActivityScreen()
    const ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  // Fungsi ini dipanggil HomeScreen saat user tap ikon hamburger
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onAddTap() {
    // TODO: Tampilkan bottom sheet atau navigasi ke halaman tambah laporan
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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D1F0F),

      // Drawer panel kiri — muncul saat swipe dari kiri
      // atau saat _openDrawer() dipanggil
      drawer: const AppDrawer(),

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
