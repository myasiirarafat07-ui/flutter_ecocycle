import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

// ============================================================
// MODEL NOTIFIKASI
// ============================================================
enum NotifType { pickup, expertReply, article, ecoPoints, communityEvent }

class NotifItem {
  final NotifType type;
  final String title;
  final String body;
  final String timeAgo;
  bool isRead;

  NotifItem({
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });
}

// ============================================================
// NOTIFICATION SCREEN
// ============================================================
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotifItem> _allNotifs = [
    NotifItem(
      type: NotifType.pickup,
      title: 'Penjemputan tiba dalam 5 menit',
      body: 'Petugas sampah sudah dekat lokasimu. Pastikan tempat sampah mudah dijangkau.',
      timeAgo: '5m',
      isRead: false,
    ),
    NotifItem(
      type: NotifType.expertReply,
      title: 'Ahli Budi menjawab pertanyaanmu',
      body: '"Untuk mengompos kulit jeruk secara efektif, sebaiknya potong kecil-kecil terlebih dahulu..."',
      timeAgo: '2j',
      isRead: false,
    ),
    NotifItem(
      type: NotifType.article,
      title: 'Artikel baru: Tips Urban Farming',
      body: 'Pelajari cara memaksimalkan balkon untuk kebun herbal yang berkelanjutan.',
      timeAgo: '6j',
      isRead: true,
    ),
    NotifItem(
      type: NotifType.ecoPoints,
      title: 'Kamu mendapat 50 Eco Points',
      body: 'Bagus! Kontribusi daur ulang plastikmu sudah terverifikasi.',
      timeAgo: '9j',
      isRead: true,
    ),
    NotifItem(
      type: NotifType.communityEvent,
      title: 'Event Komunitas di dekatmu',
      body: 'Ikuti \'Green Park Cleanup\' Sabtu ini pukul 08:00 pagi.',
      timeAgo: '12j',
      isRead: true,
    ),
  ];

  List<NotifItem> get _unreadNotifs =>
      _allNotifs.where((n) => !n.isRead).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllRead() {
    setState(() {
      for (final n in _allNotifs) {
        n.isRead = true;
      }
    });
  }

  // Kelompokkan notifikasi berdasarkan waktu
  Map<String, List<NotifItem>> _groupNotifs(List<NotifItem> items) {
    final Map<String, List<NotifItem>> grouped = {};
    for (final item in items) {
      final timeVal = int.tryParse(item.timeAgo.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final isMinutes = item.timeAgo.contains('m');
      final isHours = item.timeAgo.contains('j');

      String group;
      if (isMinutes || (isHours && timeVal < 3)) {
        group = 'BARU-BARU INI';
      } else {
        group = 'HARI INI';
      }

      grouped.putIfAbsent(group, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _unreadNotifs.length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, unreadCount),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotifList(_allNotifs),
                  _buildNotifList(_unreadNotifs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int unreadCount) {
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
              'Pusat Notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: AppColors.bgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              if (val == 'read_all') _markAllRead();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Colors.white70, size: 18),
                    SizedBox(width: 10),
                    Text('Tandai semua dibaca',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        indicatorColor: AppColors.primaryLight,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.divider,
        tabs: [
          const Tab(text: 'Semua'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Belum Dibaca'),
                if (_unreadNotifs.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_unreadNotifs.length}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifList(List<NotifItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = _groupNotifs(items);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        for (final entry in grouped.entries) ...[
          _buildGroupLabel(entry.key),
          ...entry.value.map(_buildNotifTile),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildGroupLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildNotifTile(NotifItem item) {
    return GestureDetector(
      onTap: () {
        setState(() => item.isRead = true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.bgCard : AppColors.bgCard.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          border: item.isRead
              ? null
              : Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotifIcon(item.type),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.timeAgo,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifIcon(NotifType type) {
    late IconData icon;
    late Color bgColor;
    late Color iconColor;

    switch (type) {
      case NotifType.pickup:
        icon = Icons.local_shipping_outlined;
        bgColor = const Color(0xFF1A3B2A);
        iconColor = AppColors.primaryLight;
        break;
      case NotifType.expertReply:
        icon = Icons.chat_bubble_outline;
        bgColor = const Color(0xFF1A2B3B);
        iconColor = const Color(0xFF64B5F6);
        break;
      case NotifType.article:
        icon = Icons.menu_book_outlined;
        bgColor = const Color(0xFF2B2A1A);
        iconColor = AppColors.warning;
        break;
      case NotifType.ecoPoints:
        icon = Icons.stars_outlined;
        bgColor = const Color(0xFF1A3B1A);
        iconColor = AppColors.accent;
        break;
      case NotifType.communityEvent:
        icon = Icons.groups_outlined;
        bgColor = const Color(0xFF2A1A3B);
        iconColor = const Color(0xFFCE93D8);
        break;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Semua notifikasi sudah dibaca!',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}