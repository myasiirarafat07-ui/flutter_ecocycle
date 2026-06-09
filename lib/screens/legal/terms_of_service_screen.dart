import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Syarat Layanan',
      lastUpdated: 'Juni 2026',
      intro:
          'Selamat datang di EcoCycle. Dengan membuat akun dan menggunakan '
          'aplikasi ini, kamu setuju untuk terikat pada Syarat Layanan berikut. '
          'EcoCycle adalah marketplace lingkup desa untuk produk pupuk, kompos, '
          'dan barang hasil daur ulang antar-warga.',
      sections: [
        LegalSection('1. Penggunaan Akun', [
          'Kamu wajib memberikan data yang benar saat mendaftar dan menjaga '
              'kerahasiaan kata sandimu. Setiap aktivitas yang terjadi melalui '
              'akunmu menjadi tanggung jawabmu.',
          'Akun ditujukan untuk warga yang ingin membeli atau menjual produk '
              'ramah lingkungan dalam komunitas.',
        ]),
        LegalSection('2. Jual Beli Produk', [
          'Penjual bertanggung jawab atas keakuratan informasi produk, termasuk '
              'harga, stok, berat, dan deskripsi. Produk yang dijual harus benar-'
              'benar berupa pupuk, kompos, atau barang daur ulang.',
          'Pembeli wajib melakukan pembayaran sesuai metode yang dipilih, baik '
              'COD (bayar di tempat) maupun E-Wallet.',
        ]),
        LegalSection('3. Pengiriman Antar-Warga', [
          'EcoCycle tidak menggunakan jasa kurir komersial. Pengiriman dilakukan '
              'langsung antar-warga dalam cakupan desa. Ongkos kirim dihitung '
              'berdasarkan jarak antara penjual dan pembeli serta berat produk.',
          'Lokasi yang kamu bagikan hanya digunakan untuk memperkirakan jarak '
              'dan ongkos kirim.',
        ]),
        LegalSection('4. Eco Points & Dampak Lingkungan', [
          'Kamu memperoleh Eco Points dari transaksi hijau. Poin bersifat '
              'penghargaan dan tidak dapat ditukar dengan uang tunai.',
        ]),
        LegalSection('5. Larangan', [
          'Dilarang menyalahgunakan aplikasi untuk penipuan, menjual barang '
              'ilegal, atau merugikan pengguna lain. Pelanggaran dapat berakibat '
              'penonaktifan akun.',
        ]),
        LegalSection('6. Perubahan Ketentuan', [
          'EcoCycle dapat memperbarui Syarat Layanan sewaktu-waktu. Perubahan '
              'berlaku setelah dipublikasikan di dalam aplikasi.',
        ]),
      ],
    );
  }
}
