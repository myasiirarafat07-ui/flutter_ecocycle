import 'package:flutter_test/flutter_test.dart';
import 'package:ecocycle/constants/shipping.dart';

void main() {
  group('haversineKm', () {
    test('titik yang sama => 0 km', () {
      expect(Shipping.haversineKm(-6.2, 106.8, -6.2, 106.8), closeTo(0, 0.001));
    });

    test('jarak 1 derajat lintang ≈ 111 km', () {
      final d = Shipping.haversineKm(0, 0, 1, 0);
      expect(d, closeTo(111.19, 0.5));
    });
  });

  group('calcShipping', () {
    test('tanpa lokasi pembeli => tarif fallback', () {
      final q = calcShipping(
        buyerLat: null,
        buyerLng: null,
        legs: const [ShipLeg(lat: -6.2, lng: 106.8, weightKg: 2)],
      );
      expect(q.fallback, isTrue);
      expect(q.cost, Shipping.fallbackFee);
      expect(q.totalWeightKg, 2);
    });

    test('penjual tanpa koordinat => fallback walau pembeli ada', () {
      final q = calcShipping(
        buyerLat: -6.2,
        buyerLng: 106.8,
        legs: const [ShipLeg(weightKg: 1)],
      );
      expect(q.fallback, isTrue);
      expect(q.cost, Shipping.fallbackFee);
    });

    test('jarak ~0 & berat 0 => minimal MIN_FEE', () {
      final q = calcShipping(
        buyerLat: -6.2,
        buyerLng: 106.8,
        legs: const [ShipLeg(lat: -6.2, lng: 106.8, weightKg: 0)],
      );
      expect(q.fallback, isFalse);
      expect(q.cost, Shipping.minFee); // base 3000 dibulatkan, == minFee
    });

    test('ongkir = base + jarak*perKm + berat*perKg, dibulatkan ke 500', () {
      // Pakai jarak nyata yang dihitung, lalu cocokkan dengan formula sumber.
      final q = calcShipping(
        buyerLat: 0,
        buyerLng: 0,
        legs: const [ShipLeg(lat: 0, lng: 0.05, weightKg: 3.5)],
      );
      final raw = Shipping.baseFee +
          q.distanceKm * Shipping.perKm +
          q.totalWeightKg * Shipping.perKg;
      final expected =
          (raw / Shipping.roundTo).round() * Shipping.roundTo;
      expect(q.cost, expected);
      expect(q.cost % Shipping.roundTo, 0); // kelipatan 500
      expect(q.totalWeightKg, 3.5);
    });

    test('multi-penjual => ambil jarak terjauh & berat dijumlahkan', () {
      final q = calcShipping(
        buyerLat: 0,
        buyerLng: 0,
        legs: const [
          ShipLeg(lat: 0, lng: 0.01, weightKg: 1), // dekat
          ShipLeg(lat: 0, lng: 0.10, weightKg: 2), // jauh
        ],
      );
      final far = Shipping.haversineKm(0, 0, 0, 0.10);
      expect(q.distanceKm, closeTo(far, 0.001));
      expect(q.totalWeightKg, 3);
    });
  });
}
