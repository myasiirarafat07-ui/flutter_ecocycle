import 'package:flutter_test/flutter_test.dart';
import 'package:ecocycle/constants/eco_tier.dart';

void main() {
  group('EcoTier.currentFor', () {
    test('0 poin => Bibit Hijau', () {
      expect(EcoTier.currentFor(0).name, 'Bibit Hijau');
    });

    test('tepat di ambang tier naik ke tier itu', () {
      expect(EcoTier.currentFor(100).name, 'Tunas Muda');
      expect(EcoTier.currentFor(500).name, 'Penjaga Alam');
      expect(EcoTier.currentFor(1500).name, 'Pelindung Bumi');
      expect(EcoTier.currentFor(5000).name, 'Pahlawan Bumi');
    });

    test('di bawah ambang tetap tier sebelumnya', () {
      expect(EcoTier.currentFor(99).name, 'Bibit Hijau');
      expect(EcoTier.currentFor(499).name, 'Tunas Muda');
      expect(EcoTier.currentFor(4999).name, 'Pelindung Bumi');
    });

    test('poin sangat besar => tier tertinggi', () {
      expect(EcoTier.currentFor(999999).name, 'Pahlawan Bumi');
    });
  });

  group('EcoTier.nextFor & pointsToNextFor', () {
    test('0 poin => berikutnya Tunas Muda, sisa 100', () {
      expect(EcoTier.nextFor(0)?.name, 'Tunas Muda');
      expect(EcoTier.pointsToNextFor(0), 100);
    });

    test('tier tertinggi => tidak ada berikutnya, sisa 0', () {
      expect(EcoTier.nextFor(5000), isNull);
      expect(EcoTier.pointsToNextFor(5000), 0);
    });
  });

  group('EcoTier.progressFor', () {
    test('di awal rentang => 0.0', () {
      expect(EcoTier.progressFor(100), 0.0);
    });

    test('di tengah rentang 100..500 => ~0.5', () {
      expect(EcoTier.progressFor(300), closeTo(0.5, 0.001));
    });

    test('tier tertinggi => 1.0', () {
      expect(EcoTier.progressFor(5000), 1.0);
    });
  });
}
