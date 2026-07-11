const { pool } = require('./db');

// product_reviews belum ada di skema awal — buat dengan tipe BIGINT UNSIGNED
// agar cocok dengan products.product_id & users.user_id. order_id menautkan
// ulasan ke pesanan agar hanya pesanan SELESAI yang boleh diulas.
async function ensureProductReviewsTable() {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS product_reviews (
      review_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      product_id BIGINT UNSIGNED NOT NULL,
      user_id    BIGINT UNSIGNED NOT NULL,
      order_id   BIGINT UNSIGNED NULL,
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

// Pastikan tipe sebuah kolom — tambah bila belum ada, MODIFY bila tipenya bukan
// salah satu dari expectedTypes (DATA_TYPE lowercase, mis. 'mediumtext').
async function ensureColumnType(table, column, definition, expectedTypes) {
  const [rows] = await pool.query(
    `SELECT DATA_TYPE FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
      LIMIT 1`,
    [table, column],
  );
  if (rows.length === 0) {
    await pool.query(`ALTER TABLE \`${table}\` ADD COLUMN ${definition}`);
  } else if (!expectedTypes.includes(String(rows[0].DATA_TYPE).toLowerCase())) {
    await pool.query(`ALTER TABLE \`${table}\` MODIFY COLUMN ${definition}`);
  }
}

// Hapus kolom bila masih ada (idempotent).
async function dropColumnIfExists(table, column) {
  const [rows] = await pool.query(
    `SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
      LIMIT 1`,
    [table, column],
  );
  if (rows.length > 0) {
    await pool.query(`ALTER TABLE \`${table}\` DROP COLUMN \`${column}\``);
  }
}

// Pastikan sebuah foreign key ada (idempotent) — cek TABLE_CONSTRAINTS.
async function ensureForeignKey(table, constraintName, definition) {
  const [rows] = await pool.query(
    `SELECT 1 FROM information_schema.TABLE_CONSTRAINTS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND CONSTRAINT_NAME = ?
      LIMIT 1`,
    [table, constraintName],
  );
  if (rows.length === 0) {
    await pool.query(`ALTER TABLE \`${table}\` ADD ${definition}`);
  }
}

// Pastikan sebuah index ada (idempotent) — cek information_schema.STATISTICS.
async function ensureIndex(table, indexName, definition) {
  const [rows] = await pool.query(
    `SELECT 1 FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND INDEX_NAME = ?
      LIMIT 1`,
    [table, indexName],
  );
  if (rows.length === 0) {
    await pool.query(`ALTER TABLE \`${table}\` ADD ${definition}`);
  }
}

// Kolom untuk alur status pesanan (COD/non-COD), deep-link notifikasi, gambar
// produk base64, dan ulasan terikat-pesanan.
async function ensureOrderFlowColumns() {
  // image_url VARCHAR(500) -> MEDIUMTEXT agar memuat gambar base64.
  await ensureColumnType('products', 'image_url', 'image_url MEDIUMTEXT NULL', [
    'mediumtext',
    'longtext',
    'text',
  ]);
  // Jejak waktu perubahan status pesanan.
  await ensureColumn('orders', 'updated_at', 'updated_at DATETIME NULL DEFAULT NULL');
  // Tautkan notifikasi ke pesanan (deep-link ke halaman Pesanan).
  await ensureColumn(
    'notifications',
    'related_order_id',
    'related_order_id BIGINT UNSIGNED NULL',
  );
  // Tautkan ulasan ke pesanan + cegah ulasan ganda per (pesanan, produk, user).
  await ensureColumn('product_reviews', 'order_id', 'order_id BIGINT UNSIGNED NULL');
  await ensureIndex(
    'product_reviews',
    'uq_review_order_product_user',
    'UNIQUE KEY uq_review_order_product_user (order_id, product_id, user_id)',
  );
}

// Galeri gambar produk (banyak foto per produk). image_url di products tetap
// dipakai sebagai foto utama/thumbnail demi kompatibilitas mundur.
async function ensureProductImagesTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS product_images (
      image_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      product_id BIGINT UNSIGNED NOT NULL,
      image_path MEDIUMTEXT NOT NULL,
      sort_order INT NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (image_id),
      KEY idx_product_images_product (product_id),
      CONSTRAINT fk_product_images_product
        FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE CASCADE
    )
  `);
  await ensureColumnType('product_images', 'image_path', 'image_path MEDIUMTEXT NOT NULL', [
    'mediumtext',
    'longtext',
    'text',
  ]);
}

// Bersihkan kolom yang tak terpakai + perkuat integritas referensial. Idempotent & aman dijalankan ulang.
async function cleanupSchema() {
  // Kolom mati → hapus.
  await dropColumnIfExists('users', 'trees_planted');
  await dropColumnIfExists('sellers', 'seller_description');
  await dropColumnIfExists('orders', 'discount');

  // Nol-kan notifikasi yatim sebelum menambah FK (agar ALTER tidak gagal).
  await pool.query(
    `UPDATE notifications SET related_order_id = NULL
     WHERE related_order_id IS NOT NULL
       AND related_order_id NOT IN (SELECT order_id FROM orders)`,
  );
  await ensureForeignKey(
    'notifications',
    'fk_notifications_order',
    'CONSTRAINT fk_notifications_order FOREIGN KEY (related_order_id) ' +
      'REFERENCES orders (order_id) ON UPDATE CASCADE ON DELETE SET NULL',
  );
}

// Petakan status pesanan lama (jalur tunggal PENDING/PAID) ke model baru yang
// memisahkan fulfillment (DIPROSES/DIKIRIM/SELESAI) dari pembayaran (payments).
// Idempotent: setelah dijalankan, tak ada lagi order_status PENDING/PAID.
async function migrateOrderStatuses() {
  await pool.query(
    `UPDATE orders SET order_status = 'DIPROSES' WHERE order_status = 'PENDING'`,
  );
  await pool.query(
    `UPDATE orders SET order_status = 'DIKIRIM' WHERE order_status = 'PAID'`,
  );
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

// Kolom lokasi (untuk ongkir berbasis jarak) + berat produk (untuk ongkir).
// Lokasi penjual = lat/lng di baris users miliknya.
async function ensureLocationColumns() {
  await ensureColumn('users', 'latitude', 'latitude DECIMAL(10,7) NULL');
  await ensureColumn('users', 'longitude', 'longitude DECIMAL(10,7) NULL');
  await ensureColumn(
    'products',
    'weight_kg',
    'weight_kg DECIMAL(10,2) NOT NULL DEFAULT 0',
  );
}

async function seedCategories() {
  await pool.query(
    `INSERT IGNORE INTO product_categories (category_name) VALUES
      ('Pupuk & Kompos'),
      ('Karya Daur Ulang')`,
  );
}

async function seedRequiredData() {
  await ensureProductReviewsTable();
  await ensureWishlistsTable();
  await ensurePaymentMethodsTable();
  await ensurePointTransactionsTable();
  await ensurePasswordResetsTable();
  await ensureImpactColumns();
  await ensureLocationColumns();
  await ensureOrderFlowColumns();
  await ensureProductImagesTable();
  await migrateOrderStatuses();
  await cleanupSchema();
  await seedCategories();
}

module.exports = {
  seedRequiredData,
};
