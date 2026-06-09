-- Migrasi: tambah kolom lokasi pengguna (untuk ongkir berbasis jarak)
-- dan berat produk (kg, dipakai menghitung ongkir).
-- Jalankan pada database yang sudah ada:
--   mysql -u <user> -p ecocycle_db < database/migrations/add_location_and_weight.sql

USE ecocycle_db;

-- Lokasi penjual diambil dari baris users miliknya.
ALTER TABLE users
  ADD COLUMN latitude DECIMAL(10,7) NULL AFTER address,
  ADD COLUMN longitude DECIMAL(10,7) NULL AFTER latitude;

-- Berat produk per unit (kg) — berbeda dari waste_kg (dampak lingkungan).
ALTER TABLE products
  ADD COLUMN weight_kg DECIMAL(10,2) NOT NULL DEFAULT 0 AFTER waste_kg;
