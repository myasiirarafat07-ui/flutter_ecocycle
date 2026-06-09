-- Catatan: tabel `products`, `product_categories`, `sellers` SUDAH ADA di skema
-- utama EcoCycle (BIGINT UNSIGNED). File ini hanya menambah `product_reviews`
-- (fitur ulasan) + seed kategori. Semua ini juga dijalankan otomatis saat
-- server boot via src/config/seed.js, jadi menjalankan file ini opsional.

USE ecocycle_db;

-- Ulasan & rating produk (mengikuti tipe BIGINT UNSIGNED skema utama)
CREATE TABLE IF NOT EXISTS product_reviews (
  review_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL,
  user_id    BIGINT UNSIGNED NOT NULL,
  order_id   BIGINT UNSIGNED NULL,
  rating     TINYINT NOT NULL,
  comment    TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_review_order_product_user (order_id, product_id, user_id),
  CONSTRAINT fk_reviews_product
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_user
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Kategori produk untuk fokus marketplace
INSERT IGNORE INTO product_categories (category_name, description) VALUES
  ('Pupuk & Kompos', 'Pupuk organik, kompos, dan media tanam'),
  ('Karya Daur Ulang', 'Produk hasil daur ulang limbah');
