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

// Kode OTP reset kata sandi (fitur Lupa Kata Sandi). otp_hash di-hash bcrypt.
async function ensurePasswordResetsTable() {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS password_resets (
      reset_id   BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      user_id    BIGINT UNSIGNED NOT NULL,
      otp_hash   VARCHAR(255) NOT NULL,
      expires_at DATETIME NOT NULL,
      consumed   BOOLEAN NOT NULL DEFAULT FALSE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      CONSTRAINT fk_password_resets_user
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )`,
  );
}

// Pastikan sebuah kolom ada (idempotent, portabel MySQL/MariaDB) — cek dulu ke
// information_schema lalu ALTER bila belum ada.
async function ensureColumn(table, column, definition) {
  const [rows] = await pool.query(
    `SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
      LIMIT 1`,
    [table, column],
  );
  if (rows.length === 0) {
    await pool.query(`ALTER TABLE \`${table}\` ADD COLUMN ${definition}`);
  }
}

// Kolom dampak lingkungan: berat limbah per produk + jumlah transaksi hijau user.
async function ensureImpactColumns() {
  await ensureColumn(
    'products',
    'waste_kg',
    'waste_kg DECIMAL(10,2) NOT NULL DEFAULT 0',
  );
  await ensureColumn(
    'users',
    'green_transactions',
    'green_transactions INT NOT NULL DEFAULT 0',
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
  await ensurePasswordResetsTable();
  await ensureImpactColumns();
  await seedCategories();
}

module.exports = {
  seedRequiredData,
};
