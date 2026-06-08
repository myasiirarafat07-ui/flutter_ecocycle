const { pool } = require('./db');

// product_reviews belum ada di skema awal — buat dengan tipe BIGINT UNSIGNED
// agar cocok dengan products.product_id & users.user_id.
async function ensureProductReviewsTable() {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS product_reviews (
      review_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      product_id BIGINT UNSIGNED NOT NULL,
      user_id    BIGINT UNSIGNED NOT NULL,
      rating     TINYINT NOT NULL,
      comment    TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_reviews_product
        FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
      CONSTRAINT fk_reviews_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )`,
  );
}

// Favorit pengguna (wishlist) tersimpan di DB.
async function ensureWishlistsTable() {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS wishlists (
      wishlist_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      user_id    BIGINT UNSIGNED NOT NULL,
      product_id BIGINT UNSIGNED NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uq_wishlist_user_product (user_id, product_id),
      CONSTRAINT fk_wishlist_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
      CONSTRAINT fk_wishlist_product
        FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
    )`,
  );
}

// Metode pembayaran tersimpan milik pengguna.
async function ensurePaymentMethodsTable() {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS payment_methods (
      payment_method_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      user_id     BIGINT UNSIGNED NOT NULL,
      method_type VARCHAR(20) NOT NULL,
      label       VARCHAR(80) NOT NULL,
      detail      VARCHAR(120) NOT NULL,
      is_default  BOOLEAN NOT NULL DEFAULT FALSE,
      created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_payment_methods_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )`,
  );
}

// Riwayat transaksi eco-points (tidak selalu ada di DB lama).
async function ensurePointTransactionsTable() {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS point_transactions (
      point_transaction_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      user_id          BIGINT UNSIGNED NOT NULL,
      transaction_type VARCHAR(20) NOT NULL,
      points           INT NOT NULL,
      description      VARCHAR(255) NOT NULL,
      created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_point_transactions_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )`,
  );
}

async function seedCategories() {
  await pool.query(
    `INSERT IGNORE INTO product_categories (category_name, description) VALUES
      ('Pupuk & Kompos', 'Pupuk organik, kompos, dan media tanam'),
      ('Karya Daur Ulang', 'Produk hasil daur ulang limbah')`,
  );
}

async function seedRequiredData() {
  await ensureProductReviewsTable();
  await ensureWishlistsTable();
  await ensurePaymentMethodsTable();
  await ensurePointTransactionsTable();
  await seedCategories();
}

module.exports = {
  seedRequiredData,
};
