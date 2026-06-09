-- Migration: bersihkan kolom tak terpakai + perkuat integritas referensial.
-- Backend menjalankan ini idempotent saat boot (src/config/seed.js > cleanupSchema).
-- File ini untuk penerapan manual/dokumentasi.

USE ecocycle_db;

-- 1) Kolom mati (tak pernah dibaca) → hapus.
ALTER TABLE users DROP COLUMN trees_planted;
ALTER TABLE sellers DROP COLUMN seller_description;
ALTER TABLE orders DROP COLUMN discount;

-- 2) Nol-kan notifikasi yatim lalu tambah FK ke orders (cegah orphan).
UPDATE notifications SET related_order_id = NULL
  WHERE related_order_id IS NOT NULL
    AND related_order_id NOT IN (SELECT order_id FROM orders);

ALTER TABLE notifications
  ADD CONSTRAINT fk_notifications_order
  FOREIGN KEY (related_order_id) REFERENCES orders (order_id)
  ON UPDATE CASCADE ON DELETE SET NULL;
