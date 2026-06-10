import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/user_provider.dart';
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

class _MainWrapperState extends State<MainWrapper>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  // Kategori yang diteruskan ke MarketScreen dari shortcut Home.
  // ValueKey memaksa MarketScreen dibangun ulang dengan kategori awal baru.
  String? _marketCategory;

  List<Widget> get _pages => [
    HomeScreen(onOpenDrawer: _openDrawer, onNavigateToTab: _onNavTap),
    MarketScreen(
      key: ValueKey(_marketCategory),
      initialCategory: _marketCategory,
    ),
    const SizedBox(),
    const TransactionHistoryScreen(embedded: true),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Mulai polling badge notifikasi + satu refresh awal.
    final token = context.read<UserProvider>().token;
    context.read<NotificationProvider>().startAutoRefresh(token);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<NotificationProvider>().stopAutoRefresh();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notif = context.read<NotificationProvider>();
    final token = context.read<UserProvider>().token;
    if (state == AppLifecycleState.resumed) {
      // Kembali ke foreground: refresh segera + nyalakan lagi polling.
      notif.startAutoRefresh(token);
    } else if (state == AppLifecycleState.paused) {
      notif.stopAutoRefresh();
    }
  }

  void _onNavTap(int index, {String? category}) {
    setState(() {
      _currentIndex = index;
      if (index == 1 && category != null) _marketCategory = category;
    });
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

      drawer: const AppDrawer(),

      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        onAddTap: _onAddTap,
      ),
    );
  }
}
