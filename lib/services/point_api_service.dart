import 'dart:convert';

import 'package:http/http.dart' as http;

class PointApiException implements Exception {
  final String message;
  const PointApiException(this.message);
  @override
  String toString() => message;
}

class PointTransaction {
  final int id;
  final String type; // EARN | REDEEM
  final int points;
  final String description;
  final DateTime? createdAt;

  const PointTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: (json['point_transaction_id'] as num).toInt(),
      type: json['transaction_type']?.toString() ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class PointsSummary {
  final int balance;
  final double totalWasteKg;
  final int greenTransactions;
  final double co2OffsetKg;
  final List<PointTransaction> transactions;

  const PointsSummary({
    required this.balance,
    required this.totalWasteKg,
    required this.greenTransactions,
    required this.co2OffsetKg,
    required this.transactions,
  });
}

class PointApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  Future<PointsSummary> getPoints(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/points'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode != 200) {
      throw PointApiException(body['message']?.toString() ?? 'Request gagal');
    }

    final data = (body['data'] as List<dynamic>?) ?? [];
    return PointsSummary(
      balance: (body['balance'] as num?)?.toInt() ?? 0,
      totalWasteKg: (body['total_waste_kg'] as num?)?.toDouble() ?? 0,
      greenTransactions: (body['green_transactions'] as num?)?.toInt() ?? 0,
      co2OffsetKg: (body['co2_offset_kg'] as num?)?.toDouble() ?? 0,
      transactions: data
          .map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
