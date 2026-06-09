-- Migrasi: tambah kolom foto profil (disimpan sebagai base64 / data-URL).
-- Jalankan pada database yang sudah ada:
--   mysql -u <user> -p ecocycle_db < database/migrations/add_profile_photo.sql

USE ecocycle_db;

ALTER TABLE users
  ADD COLUMN profile_photo LONGTEXT NULL AFTER address;
