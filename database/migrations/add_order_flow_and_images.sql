-- Migration: alur status pesanan (COD/non-COD), deep-link notifikasi,
-- gambar produk base64, dan ulasan terikat-pesanan.
--
-- Catatan: backend menjalankan perubahan ini secara idempotent saat boot
-- (lihat src/config/seed.js > ensureOrderFlowColumns). File ini disediakan
-- untuk penerapan manual / dokumentasi skema. Aman dijalankan ulang.

USE ecocycle_db;

-- 1) image_url: muat gambar base64 (sebelumnya VARCHAR(500)).
ALTER TABLE products MODIFY COLUMN image_url MEDIUMTEXT NULL;

-- 2) jejak waktu perubahan status pesanan.
ALTER TABLE orders ADD COLUMN updated_at DATETIME NULL DEFAULT NULL;

-- 3) tautkan notifikasi ke pesanan (deep-link ke halaman Pesanan).
ALTER TABLE notifications ADD COLUMN related_order_id BIGINT UNSIGNED NULL;

-- 4) tautkan ulasan ke pesanan + cegah ulasan ganda per (pesanan, produk, user).
ALTER TABLE product_reviews ADD COLUMN order_id BIGINT UNSIGNED NULL;
ALTER TABLE product_reviews
  ADD UNIQUE KEY uq_review_order_product_user (order_id, product_id, user_id);

-- 5) pisahkan fulfillment (order_status) dari pembayaran (payments.payment_status).
--    Model baru order_status: DIPROSES -> DIKIRIM -> SELESAI.
--    Petakan status lama (idempotent): PENDING -> DIPROSES, PAID -> DIKIRIM.
UPDATE orders SET order_status = 'DIPROSES' WHERE order_status = 'PENDING';
UPDATE orders SET order_status = 'DIKIRIM' WHERE order_status = 'PAID';

-- 6) galeri gambar produk (banyak foto). products.image_url tetap = foto utama.
CREATE TABLE IF NOT EXISTS product_images (
  image_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  image_path VARCHAR(500) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (image_id),
  KEY idx_product_images_product (product_id),
  CONSTRAINT fk_product_images_product
    FOREIGN KEY (product_id) REFERENCES products (product_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);
