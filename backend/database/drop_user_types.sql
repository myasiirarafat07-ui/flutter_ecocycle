-- Migrasi: hapus tabel user_types beserta FK-nya di users.
-- Jalankan pada database yang sudah berisi data lama.
USE ecocycle_db;

ALTER TABLE users DROP FOREIGN KEY fk_users_user_type;
ALTER TABLE users DROP COLUMN user_type_id;
DROP TABLE IF EXISTS user_types;
