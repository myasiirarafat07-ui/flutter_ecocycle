import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/notification_api_service.dart';

/// Menyimpan jumlah notifikasi belum dibaca untuk badge di seluruh aplikasi.
/// Panggil [refresh] saat sesi dipulihkan, setelah membuka halaman notifikasi,
/// dan setelah aksi yang membuat notifikasi (checkout, konfirmasi, selesai).
///
/// Selain itu, [startAutoRefresh] menyalakan polling ringan agar badge ikut
/// terbarui untuk notifikasi yang dipicu pihak lain (mis. pembeli memesan
/// produk kita) tanpa perlu hot restart.
class NotificationProvider extends ChangeNotifier {
  final NotificationApiService _api = NotificationApiService();
  int _unreadCount = 0;

  Timer? _timer;
  static const Duration _pollInterval = Duration(seconds: 30);

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

  /// Mulai polling periodik. Idempoten: timer lama dibatalkan dulu.
  /// Langsung melakukan satu refresh agar badge cepat sinkron.
  void startAutoRefresh(String token) {
    stopAutoRefresh();
    if (token.isEmpty) return;
    refresh(token);
    _timer = Timer.periodic(_pollInterval, (_) => refresh(token));
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  void clear() {
    if (_unreadCount != 0) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
