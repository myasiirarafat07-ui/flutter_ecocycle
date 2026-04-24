import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import 'consultation/expert_consultation_screen.dart';
import 'home/home_screen.dart';
import 'market/market_screen.dart';
import 'profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Index aktif: 0=Home, 1=Market, 3=Activity, 4=Profile
  int _currentIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(onOpenDrawer: _openDrawer, onNavigateToTab: _onNavTap),
    const MarketScreen(),
    const SizedBox(),
    const ConsultationNotesScreen(embedded: true),
    const ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onAddTap() {
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

      // Drawer menerima callback navigasi tab supaya
      // saat user pilih "Profil Saya" dari drawer,
      // bottom navbar tetap tampil (tidak hilang)
      drawer: AppDrawer(onNavigateToTab: _onNavTap),

      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onAddTap: _onAddTap,
      ),
    );
  }
}
