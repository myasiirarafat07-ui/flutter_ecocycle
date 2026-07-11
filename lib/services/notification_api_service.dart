import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_model.dart';

class NotificationApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://flutter-ecocycle.vercel.app',
  );

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<List<AppNotification>> list(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: _headers(token),
    );
    if (r.statusCode != 200) {
      throw Exception('Gagal memuat notifikasi');
    }
    final data = (jsonDecode(r.body) as Map)['data'] as List<dynamic>?;
    return (data ?? [])
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Jumlah notifikasi belum dibaca (untuk badge), dari field `unread_count`.
  Future<int> unreadCount(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: _headers(token),
    );
    if (r.statusCode != 200) return 0;
    final body = jsonDecode(r.body) as Map;
    return (body['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String token, int id) async {
    await http.put(
      Uri.parse('$baseUrl/api/notifications/$id/read'),
      headers: _headers(token),
    );
  }

  Future<void> markAllRead(String token) async {
    await http.put(
      Uri.parse('$baseUrl/api/notifications/read-all'),
      headers: _headers(token),
    );
  }
}
