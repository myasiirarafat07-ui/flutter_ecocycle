import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Kebijakan Privasi',
      lastUpdated: 'Juni 2026',
      intro:
          'Privasimu penting bagi EcoCycle. Kebijakan ini menjelaskan data apa '
          'yang kami kumpulkan, bagaimana penggunaannya, dan hakmu atas data '
          'tersebut.',
      sections: [
        LegalSection('1. Data yang Kami Kumpulkan', [
          'Data akun: nama, email, nomor telepon, alamat, dan foto profil '
              '(opsional).',
          'Data lokasi: koordinat yang kamu bagikan saat menjual produk atau '
              'saat checkout, digunakan untuk menghitung jarak dan ongkos kirim.',
          'Data transaksi: produk, pesanan, metode pembayaran, dan riwayat '
              'Eco Points.',
        ]),
        LegalSection('2. Penggunaan Data', [
          'Kami menggunakan data untuk menjalankan marketplace: menampilkan '
              'produk, memproses pesanan, menghitung ongkos kirim, dan '
              'memberikan Eco Points.',
          'Lokasi hanya diakses saat kamu menekan tombol untuk membagikannya, '
              'dan tidak dilacak di latar belakang.',
        ]),
        LegalSection('3. Berbagi Data', [
          'Informasi terbatas seperti nama penjual/pembeli dan perkiraan lokasi '
              'dapat ditampilkan kepada pihak transaksi untuk memudahkan '
              'pengiriman antar-warga. Kami tidak menjual datamu ke pihak ketiga.',
        ]),
        LegalSection('4. Keamanan', [
          'Kata sandi disimpan dalam bentuk ter-hash. Kami berupaya melindungi '
              'datamu, namun tidak ada sistem yang sepenuhnya bebas risiko.',
        ]),
        LegalSection('5. Hak Kamu', [
          'Kamu dapat memperbarui data profil kapan saja melalui menu Informasi '
              'Pribadi, serta menghapus metode pembayaran tersimpan.',
        ]),
        LegalSection('6. Kontak', [
          'Untuk pertanyaan terkait privasi, hubungi pengelola EcoCycle melalui '
              'kanal resmi komunitas.',
        ]),
      ],
    );
  }
}
