# EcoCycle

**EcoCycle** adalah aplikasi marketplace produk berkelanjutan berskala antar-warga (village-scale). Aplikasi menghubungkan warga untuk menjual & membeli produk ramah lingkungan — **Pupuk & Kompos** dan **Karya Daur Ulang** — sambil menambahkan gamifikasi lingkungan: setiap transaksi "hijau" menghasilkan **Eco Points**, melacak **berat limbah terdaur ulang (kg)**, dan menghitung estimasi **pengurangan emisi CO₂e**.

Karakteristik: pengiriman model **antar-warga** (ongkir = jarak Haversine + berat barang), pembayaran **COD-first**, dan satu akun bisa berperan sebagai **pembeli sekaligus penjual**.

## Fitur Utama

- **Autentikasi** — register, login (JWT), reset password 3 langkah (email + telepon → OTP → password baru).
- **Marketplace** — daftar produk dengan filter kategori/harga/rating & pengurutan; detail produk dengan galeri gambar dan ulasan.
- **Keranjang & Checkout** — kelola keranjang, hitung ongkir antar-warga otomatis, pilih metode bayar (COD default).
- **Pesanan & Fulfillment** — alur status `DIPROSES → DIKIRIM → SELESAI`; sisi penjual bisa mengirim & mengonfirmasi pembayaran COD; sisi pembeli mengonfirmasi penerimaan.
- **Eco Points & Tier** — 1 poin per Rp1.000 belanja; 5 tier loyalty (Bibit Hijau → Pahlawan Bumi).
- **Sisi Penjual** — buat/edit/hapus produk, unggah galeri (maks 5 gambar), kelola penjualan.
- **Wishlist** — simpan produk favorit.
- **Notifikasi** — pemberitahuan pesanan/penjualan/ulasan dengan badge belum dibaca.
- **Ulasan** — tulis review setelah pesanan selesai (1 review per produk per pesanan).
- **Profil** — edit data diri, foto profil, alamat & lokasi GPS.
- **Tema** — mode terang & gelap.

## Tech Stack

- **Frontend:** Flutter (Dart, SDK ^3.11) — `provider`, `http`, `geolocator`, `flutter_map`, `image_picker`, `shared_preferences`. Font Poppins.
- **Backend:** Node.js + Express 5 — `mysql2` (raw SQL, tanpa ORM), `jsonwebtoken`, `bcryptjs`, `multer`, `nodemailer`.
- **Database:** MySQL.

## Struktur Folder

```
ecocycle/
├── lib/         # Aplikasi Flutter: main.dart, constants/ models/ providers/ services/ screens/ widgets/ utils/
├── backend/     # API Express: src/{config,controllers,routes,middleware,utils,scripts}, uploads/
├── database/    # ecocycle_pdm.sql (skema database)
├── assets/      # Gambar, ikon, logo
└── fonts/       # Poppins
```

## Menjalankan Aplikasi

### Frontend (Flutter)

```bash
flutter pub get
flutter run
```

Base URL API (`API_BASE_URL`): `http://10.0.2.2:3000` (Android emulator), `http://localhost:3000` (web/desktop), atau IP LAN komputer untuk HP fisik.

### Backend

```bash
cd backend
npm install
cp .env.example .env   # sesuaikan DB_USER, DB_PASSWORD, DB_NAME, dll
# buat database: mysql> SOURCE ../database/ecocycle_pdm.sql;
npm run dev            # atau: npm start
```

Server default di port 3000. Migrasi tabel tambahan & seed kategori berjalan otomatis saat start. Detail lengkap di [`backend/README.md`](backend/README.md).
