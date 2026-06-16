# EcoCycle Backend

Backend API EcoCycle menggunakan Node.js, Express, dan MySQL. API ini menangani autentikasi, marketplace produk ramah lingkungan, keranjang, checkout, pesanan COD, wishlist, metode pembayaran, notifikasi, ulasan, dan Eco Points.

## Setup

1. Buat database dari skema fisik:

```sql
SOURCE ../database/ecocycle_pdm.sql;
```

2. Salin konfigurasi environment:

```bash
cp .env.example .env
```

3. Sesuaikan nilai `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, dan `JWT_SECRET` di `.env`.

4. Install dependency dan jalankan server:

```bash
npm install
npm run dev
```

Server default berjalan di `http://localhost:3000`.

## Skema Database

Skema utama ada di `../database/ecocycle_pdm.sql` dan mencakup tabel:

- `users`, `sellers`, `product_categories`, `products`, `product_images`
- `carts`, `cart_items`, `orders`, `order_items`, `payments`
- `point_transactions`, `notifications`, `product_reviews`
- `wishlists`, `payment_methods`, `password_resets`

Saat server start, `src/config/seed.js` tetap menjalankan migrasi idempoten untuk memastikan tabel/kolom tambahan tersedia pada database lama, lalu melakukan seed kategori produk wajib.

## Endpoint Utama

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/forgot-password`
- `POST /api/auth/verify-otp`
- `POST /api/auth/reset-password`
- `GET /api/auth/me`
- `PUT /api/auth/me`
- `PUT /api/auth/me/photo`
- `GET /api/products`
- `GET /api/products/mine`
- `GET /api/products/:id`
- `POST /api/products/images`
- `POST /api/products`
- `PUT /api/products/:id`
- `DELETE /api/products/:id`
- `GET /api/products/:id/reviews`
- `POST /api/products/:id/reviews`
- `GET /api/cart`
- `POST /api/cart`
- `PUT /api/cart/:productId`
- `DELETE /api/cart/:productId`
- `DELETE /api/cart`
- `POST /api/orders`
- `GET /api/orders`
- `GET /api/orders/sales`
- `GET /api/orders/:id`
- `PUT /api/orders/:id/ship`
- `PUT /api/orders/:id/confirm-payment`
- `PUT /api/orders/:id/complete`
- `GET /api/notifications`
- `PUT /api/notifications/:id/read`
- `PUT /api/notifications/read-all`
- `GET /api/wishlist`
- `POST /api/wishlist`
- `DELETE /api/wishlist/:productId`
- `GET /api/payment-methods`
- `POST /api/payment-methods`
- `PUT /api/payment-methods/:id/default`
- `DELETE /api/payment-methods/:id`
- `DELETE /api/payment-methods`
- `GET /api/points`

## Catatan Alur Bisnis

- Produk hanya memakai kategori `Pupuk & Kompos` dan `Karya Daur Ulang`.
- User otomatis memiliki peran penjual ketika pertama kali membuat produk.
- Checkout menghitung ongkir secara otoritatif di server dari jarak Haversine dan berat barang.
- COD dimulai dengan `payment_status = PENDING`; penjual mengonfirmasi pembayaran setelah menerima uang.
- Fulfillment pesanan berjalan melalui `DIPROSES -> DIKIRIM -> SELESAI`.
- Eco Points diberikan saat checkout dengan rumus 1 poin per Rp1.000 total transaksi.
