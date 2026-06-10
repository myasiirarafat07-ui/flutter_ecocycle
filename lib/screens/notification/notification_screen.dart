import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_api_service.dart';
import '../payment/order_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _api = NotificationApiService();
  List<AppNotification> _items = [];
  bool _loading = true;
  bool _showUnreadOnly = false;

  String get _token => context.read<UserProvider>().token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _api.list(_token);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
      context.read<NotificationProvider>().refresh(_token);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    await _api.markAllRead(_token);
    await _load();
  }

  /// Tap notifikasi: tandai dibaca, lalu buka pesanan terkait bila ada.
  Future<void> _onTap(AppNotification n) async {
    if (!n.isRead) {
      await _api.markRead(_token, n.id);
      await _load();
    }
    if (!mounted || n.orderId == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: n.orderId!)),
    );
    if (mounted) _load();
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'SALE':
        return Icons.sell_outlined;
      case 'ORDER':
        return Icons.receipt_long_outlined;
      case 'REVIEW':
        return Icons.star_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((n) => !n.isRead).length;
    final visible = _showUnreadOnly
        ? _items.where((n) => !n.isRead).toList()
        : _items;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAll,
              child: const Text(
                'Tandai semua',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilter(unread),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: visible.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 120),
                                Icon(
                                  Icons.notifications_none,
                                  color: context.mutedColor,
                                  size: 56,
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'Tidak ada notifikasi.',
                                    style: TextStyle(color: context.mutedColor),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: visible.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) => _buildTile(visible[i]),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(int unread) {
    Widget chip(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : context.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : context.mutedColor,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          chip(
            'Semua',
            !_showUnreadOnly,
            () => setState(() => _showUnreadOnly = false),
          ),
          chip(
            'Belum dibaca ($unread)',
            _showUnreadOnly,
            () => setState(() => _showUnreadOnly = true),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(AppNotification n) {
    return GestureDetector(
      onTap: () => _onTap(n),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: n.isRead
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconFor(n.type), color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: TextStyle(
                      color: context.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.body,
                    style: TextStyle(color: context.mutedColor, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.createdAt,
                    style: TextStyle(color: context.mutedColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
