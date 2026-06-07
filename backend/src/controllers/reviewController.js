const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');

function cleanText(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function publicReview(row) {
  return {
    review_id: row.review_id,
    product_id: row.product_id,
    user_id: row.user_id,
    user_name: row.user_name,
    rating: Number(row.rating),
    comment: row.comment,
    created_at: row.created_at,
  };
}

async function listReviews(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT
        r.review_id,
        r.product_id,
        r.user_id,
        u.full_name AS user_name,
        r.rating,
        r.comment,
        r.created_at
      FROM product_reviews r
      INNER JOIN users u ON u.user_id = r.user_id
      WHERE r.product_id = ?
      ORDER BY r.created_at DESC`,
      [req.params.id],
    );
    res.json({ data: rows.map(publicReview) });
  } catch (error) {
    next(error);
  }
}

async function createReview(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const productId = Number(req.params.id);
    const rating = Number(req.body.rating);
    const comment = cleanText(req.body.comment);

    if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      throw new HttpError(400, 'Rating harus antara 1 sampai 5');
    }

    const [products] = await connection.query(
      'SELECT product_id FROM products WHERE product_id = ? LIMIT 1',
      [productId],
    );
    if (products.length === 0) {
      throw new HttpError(404, 'Produk tidak ditemukan');
    }

    await connection.query(
      `INSERT INTO product_reviews (product_id, user_id, rating, comment)
      VALUES (?, ?, ?, ?)`,
      [productId, req.user.user_id, rating, comment],
    );

    // Perbarui cache rating rata-rata pada produk.
    await connection.query(
      `UPDATE products
        SET rating = (
          SELECT ROUND(AVG(rating), 2) FROM product_reviews WHERE product_id = ?
        )
      WHERE product_id = ?`,
      [productId, productId],
    );

    const [rows] = await connection.query(
      `SELECT
        r.review_id,
        r.product_id,
        r.user_id,
        u.full_name AS user_name,
        r.rating,
        r.comment,
        r.created_at
      FROM product_reviews r
      INNER JOIN users u ON u.user_id = r.user_id
      WHERE r.product_id = ?
      ORDER BY r.created_at DESC
      LIMIT 1`,
      [productId],
    );

    res.status(201).json({
      message: 'Ulasan berhasil dikirim',
      review: publicReview(rows[0]),
    });
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
}

module.exports = {
  listReviews,
  createReview,
};
