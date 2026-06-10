import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecocycle/constants/app_colors.dart';
import 'package:ecocycle/widgets/order_status_badge.dart';

void main() {
  group('orderStatusLabel (alur fulfillment)', () {
    test('status aktif dipetakan ke label Indonesia', () {
      expect(orderStatusLabel('DIPROSES'), 'Diproses');
      expect(orderStatusLabel('DIKIRIM'), 'Dikirim');
      expect(orderStatusLabel('SELESAI'), 'Selesai');
    });

    test('tidak peka huruf besar/kecil', () {
      expect(orderStatusLabel('diproses'), 'Diproses');
      expect(orderStatusLabel('Dikirim'), 'Dikirim');
    });

    test('status lama (PENDING/PAID) tetap terbaca', () {
      expect(orderStatusLabel('PENDING'), 'Menunggu Pembayaran');
      expect(orderStatusLabel('PAID'), 'Dibayar');
    });

    test('status kosong/tak dikenal', () {
      expect(orderStatusLabel(''), '-');
      expect(orderStatusLabel('ENTAH'), 'ENTAH');
    });
  });

  group('orderStatusColor', () {
    test('DIPROSES & PENDING => warning', () {
      expect(orderStatusColor('DIPROSES'), AppColors.warning);
      expect(orderStatusColor('PENDING'), AppColors.warning);
    });

    test('DIKIRIM & PAID => biru', () {
      expect(orderStatusColor('DIKIRIM'), const Color(0xFF2196F3));
      expect(orderStatusColor('PAID'), const Color(0xFF2196F3));
    });

    test('SELESAI & default => primary', () {
      expect(orderStatusColor('SELESAI'), AppColors.primary);
      expect(orderStatusColor('ENTAH'), AppColors.primary);
    });
  });

  group('status pembayaran (jalur terpisah)', () {
    test('label', () {
      expect(paymentStatusLabel('PAID'), 'Lunas');
      expect(paymentStatusLabel('PENDING'), 'Belum dibayar');
      expect(paymentStatusLabel(''), '-');
    });

    test('warna', () {
      expect(paymentStatusColor('PAID'), AppColors.primary);
      expect(paymentStatusColor('PENDING'), AppColors.warning);
    });
  });

  testWidgets('OrderStatusBadge menampilkan label sesuai status', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OrderStatusBadge('DIKIRIM')),
      ),
    );
    expect(find.text('Dikirim'), findsOneWidget);
  });
}
