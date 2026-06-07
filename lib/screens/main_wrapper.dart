import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import 'home/home_screen.dart';
import 'market/market_screen.dart';
import 'payment/transaction_history_screen.dart';
import 'profile/profile_screen.dart';
import 'seller/sell_product_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(onOpenDrawer: _openDrawer, onNavigateToTab: _onNavTap),
    const MarketScreen(),
    const SizedBox(),
    const TransactionHistoryScreen(embedded: true),
    const ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onAddTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SellProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
