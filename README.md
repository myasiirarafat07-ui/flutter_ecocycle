# EcoCycle

**EcoCycle** adalah aplikasi marketplace produk berkelanjutan berskala antar-warga (village-scale). Aplikasi menghubungkan warga untuk menjual & membeli produk ramah lingkungan — **Pupuk & Kompos** dan **Karya Daur Ulang** — sambil menambahkan gamifikasi lingkungan: setiap transaksi "hijau" menghasilkan **Eco Points**, melacak **berat limbah terdaur ulang (kg)**, dan menghitung estimasi **pengurangan emisi CO₂e**.

Karakteristik: pengiriman model **antar-warga** (ongkir = jarak Haversine + berat barang), pembayaran **COD-first**, dan satu akun bisa berperan sebagai **pembeli sekaligus penjual**.

> 📘 Dokumentasi teknis menyeluruh (arsitektur, endpoint, skema DB, formula bisnis, changelog) tersedia terpisah sebagai *EcoCycle-Dokumentasi-Lengkap.md*.

## Fitur Utama

- **Autentikasi** — register, login (JWT), reset password 3 langkah (email + telepon → OTP → password baru), dengan rate-limit.
- **Marketplace** — daftar produk dengan filter kategori/harga/rating & pengurutan; infinite scroll (pagination); detail produk dengan galeri gambar dan ulasan.
- **Keranjang & Checkout** — kelola keranjang (validasi stok), hitung ongkir antar-warga otomatis, pilih metode bayar (COD default).
- **Pesanan & Fulfillment** — alur status `DIPROSES → DIKIRIM → SELESAI`; sisi penjual mengirim & mengonfirmasi pembayaran COD; sisi pembeli mengonfirmasi penerimaan.
- **Eco Points & Tier** — 1 poin per Rp1.000 belanja; 5 tier loyalty (Bibit Hijau → Pahlawan Bumi).
- **Sisi Penjual** — buat/edit/hapus produk, unggah galeri (maks 5 gambar), badge toko di drawer.
- **Wishlist** — simpan produk favorit (optimistic update).
- **Notifikasi** — pemberitahuan pesanan/penjualan/ulasan dengan badge belum dibaca + auto-refresh.
- **Ulasan** — tulis review setelah pesanan selesai (1 review per produk per pesanan).
- **Profil** — edit data diri, foto profil (disimpan sebagai file di disk), alamat & lokasi GPS.
- **Tema** — mode terang & gelap, **persisten** lintas sesi (tersimpan via `shared_preferences`).

## Tech Stack

- **Frontend:** Flutter (Dart, SDK ^3.11) — `provider`, `http`, `geolocator`, `flutter_map`, `image_picker`, `shared_preferences`. Font Poppins, Material 3.
- **Backend:** Node.js + Express 5 — `mysql2` (raw SQL, tanpa ORM), `jsonwebtoken`, `bcryptjs`, `multer`, `nodemailer`.
- **Database:** MySQL.

## Struktur Folder

```
ecocycle/
├── lib/         # Aplikasi Flutter: main.dart, constants/ models/ providers/ services/ screens/ widgets/ utils/
├── backend/     # API Express: src/{config,controllers,routes,middleware,utils,scripts}, uploads/
├── database/    # ecocycle_pdm.sql (skema database)
├── assets/      # Gambar, ikon, logo
├── fonts/       # Poppins
├── test/        # Unit & widget test (shipping, eco_tier, product_model, order_status, widget)
└── tools/       # Skrip bantu (deploy_android.ps1)
```

## Menjalankan Aplikasi

### Backend

```bash
cd backend
npm install
cp .env.example .env   # sesuaikan DB_USER, DB_PASSWORD, DB_NAME, dll
# buat database: mysql> SOURCE ../database/ecocycle_pdm.sql;
npm run dev            # atau: npm start
```

Server default di port 3000. Migrasi tabel tambahan & seed kategori berjalan otomatis saat start. Detail lengkap di [`backend/README.md`](backend/README.md).

### Frontend (Flutter)

```bash
flutter pub get
flutter run
```

**Base URL API** (`API_BASE_URL`) di-inject saat build via `--dart-define` (default `http://10.0.2.2:3000`):
- **Android emulator:** `http://10.0.2.2:3000`
- **Web / Windows / desktop:** `http://localhost:3000`
- **HP fisik:** IP host backend — lihat *Deployment* di bawah.

### Deployment ke HP Android nyata

Manifest sudah memuat izin `INTERNET`/`CAMERA`/lokasi + `usesCleartextTraffic` (untuk HTTP LAN); server mendengarkan di semua interface. `applicationId` = `id.ecocycle.app`.

**Jalur A — LAN / Hotspot HP (demo/presentasi):** HP & laptop satu jaringan (hotspot HP paling andal; Wi-Fi kampus/publik sering memblokir antar-perangkat). Build & install berarah IP laptop:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://<IP-laptop>:3000
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Atau pakai skrip: `./tools/deploy_android.ps1` (auto-deteksi IP Wi-Fi → build → install).

**Jalur B — Hosting online (jalan di mana saja pakai data):** host backend + MySQL di server publik (set `JWT_SECRET` kuat, `NODE_ENV=production`, idealnya HTTPS), lalu build dengan `--dart-define=API_BASE_URL=https://api.domainmu.com`.

> Catatan: APK `--release` saat ini memakai *debug key* (cukup untuk sideload/demo, belum untuk Play Store).

## Pengujian & Kualitas

```bash
flutter test       # 36 test (shipping, eco_tier, product_model, order_status, widget)
flutter analyze    # bersih: "No issues found!"
```
