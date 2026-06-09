import 'package:flutter/foundation.dart';

import '../services/notification_api_service.dart';

/// Menyimpan jumlah notifikasi belum dibaca untuk badge di seluruh aplikasi.
/// Panggil [refresh] saat sesi dipulihkan, setelah membuka halaman notifikasi,
/// dan setelah aksi yang membuat notifikasi (checkout, konfirmasi, selesai).
class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _api = NotificationApiService();
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  Future<void> refresh(String token) async {
    if (token.isEmpty) return;
    try {
      final count = await _api.unreadCount(token);
      if (count != _unreadCount) {
        _unreadCount = count;
        notifyListeners();
      }
    } catch (_) {
      // Diam saja — badge bukan fitur kritis.
    }
  }

  void clear() {
    if (_unreadCount != 0) {
      _unreadCount = 0;
      notifyListeners();
    }
  }
}
