const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');

// SELECT produk dengan alias yang cocok dengan model Product di Flutter,
// difilter berdasarkan isi wishlist milik user.
const WISHLIST_SELECT = `
  SELECT
    p.product_id,
    p.seller_id,
    s.seller_name,
    c.category_name AS category,
    p.product_name AS name,
    p.description,
    p.price,
    p.stock,
    p.image_url,
    p.sold_count AS sold,
    p.rating,
    (s.user_id = ?) AS is_mine,
    (SELECT COUNT(*) FROM product_reviews r WHERE r.product_id = p.product_id) AS review_count
  FROM wishlists w
  INNER JOIN products p ON p.product_id = w.product_id
  INNER JOIN sellers s ON s.seller_id = p.seller_id
  INNER JOIN product_categories c ON c.product_category_id = p.product_category_id
  WHERE w.user_id = ?
  ORDER BY w.created_at DESC`;

function publicProduct(row) {
  return {
    product_id: row.product_id,
    seller_id: row.seller_id,
    seller_name: row.seller_name,
    category: row.category,
    name: row.name,
    description: row.description,
    price: Number(row.price),
    stock: Number(row.stock),
    image_url: row.image_url,
    sold: Number(row.sold),
    rating: Number(row.rating),
    review_count: Number(row.review_count),
    is_mine: Boolean(row.is_mine),
    created_at: row.created_at,
  };
}

async function listWishlist(userId) {
  const [rows] = await pool.query(WISHLIST_SELECT, [userId, userId]);
  return rows.map(publicProduct);
}

async function getWishlist(req, res, next) {
  try {
    res.json({ data: await listWishlist(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function addToWishlist(req, res, next) {
  try {
    const productId = Number(req.body.product_id);
    if (!Number.isInteger(productId) || productId <= 0) {
      throw new HttpError(400, 'product_id tidak valid');
    }

    const [exists] = await pool.query(
      'SELECT product_id FROM products WHERE product_id = ? LIMIT 1',
      [productId],
    );
    if (exists.length === 0) throw new HttpError(404, 'Produk tidak ditemukan');

    await pool.query(
      'INSERT IGNORE INTO wishlists (user_id, product_id) VALUES (?, ?)',
      [req.user.user_id, productId],
    );

    res.status(201).json({ data: await listWishlist(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function removeFromWishlist(req, res, next) {
  try {
    await pool.query(
      'DELETE FROM wishlists WHERE user_id = ? AND product_id = ?',
      [req.user.user_id, Number(req.params.productId)],
    );
    res.json({ data: await listWishlist(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getWishlist,
  addToWishlist,
  removeFromWishlist,
};
