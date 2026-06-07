const { pool } = require('./db');

async function seedUserTypes() {
  await pool.query(
    `INSERT INTO user_types (type_name, description) VALUES
      ('Individual', 'Pengguna perorangan'),
      ('Petani', 'Pengguna dari sektor pertanian'),
      ('Bisnis', 'Pengguna bisnis atau komunitas')
    ON DUPLICATE KEY UPDATE
      description = VALUES(description)`,
  );
}

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

async function seedCategories() {
  await pool.query(
    `INSERT IGNORE INTO product_categories (category_name, description) VALUES
      ('Pupuk & Kompos', 'Pupuk organik, kompos, dan media tanam'),
      ('Karya Daur Ulang', 'Produk hasil daur ulang limbah')`,
  );
}

async function seedRequiredData() {
  await seedUserTypes();
  await ensureProductReviewsTable();
  await seedCategories();
}

module.exports = {
  seedRequiredData,
};
