import 'dart:math' as math;

/// Perhitungan ongkir antar-warga di sisi klien — DICERMINKAN dari
/// backend/src/utils/shipping.js agar estimasi di checkout = nilai otoritatif
/// yang dihitung ulang server.
class Shipping {
  static const int baseFee = 3000;
  static const int perKm = 2000;
  static const int perKg = 1000;
  static const int minFee = 3000;
  static const int fallbackFee = 10000;
  static const int roundTo = 500;

  static const double earthRadiusKm = 6371;

  static double _toRad(double deg) => deg * math.pi / 180;

  /// Jarak Haversine (km) antara dua koordinat.
  static double haversineKm(
    double aLat,
    double aLng,
    double bLat,
    double bLng,
  ) {
    final dLat = _toRad(bLat - aLat);
    final dLng = _toRad(bLng - aLng);
    final lat1 = _toRad(aLat);
    final lat2 = _toRad(bLat);
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);
    return 2 * earthRadiusKm * math.asin(math.sqrt(h));
  }
}

/// Leg per-penjual: koordinat penjual + total berat barangnya (kg).
class ShipLeg {
  final double? lat;
  final double? lng;
  final double weightKg;
  const ShipLeg({this.lat, this.lng, this.weightKg = 0});
}

/// Hasil hitung ongkir.
class ShippingQuote {
  final int cost;
  final double distanceKm;
  final double totalWeightKg;
  final bool fallback; // true bila lokasi tidak lengkap → tarif flat.
  const ShippingQuote({
    required this.cost,
    required this.distanceKm,
    required this.totalWeightKg,
    required this.fallback,
  });
}

bool _isCoord(double? v) => v != null && v.isFinite;

/// Hitung ongkir dari lokasi pembeli + daftar leg penjual.
ShippingQuote calcShipping({
  double? buyerLat,
  double? buyerLng,
  required List<ShipLeg> legs,
}) {
  final totalWeightKg = legs.fold<double>(0, (s, l) => s + l.weightKg);

  final hasBuyer = _isCoord(buyerLat) && _isCoord(buyerLng);
  final distances = <double>[];
  if (hasBuyer) {
    for (final l in legs) {
      if (_isCoord(l.lat) && _isCoord(l.lng)) {
        distances.add(
          Shipping.haversineKm(buyerLat!, buyerLng!, l.lat!, l.lng!),
        );
      }
    }
  }

  if (distances.isEmpty) {
    return ShippingQuote(
      cost: Shipping.fallbackFee,
      distanceKm: 0,
      totalWeightKg: totalWeightKg,
      fallback: true,
    );
  }

  final distanceKm = distances.reduce(math.max);
  final raw =
      Shipping.baseFee +
      distanceKm * Shipping.perKm +
      totalWeightKg * Shipping.perKg;
  final rounded = (raw / Shipping.roundTo).round() * Shipping.roundTo;
  return ShippingQuote(
    cost: math.max(Shipping.minFee, rounded),
    distanceKm: distanceKm,
    totalWeightKg: totalWeightKg,
    fallback: false,
  );
}
