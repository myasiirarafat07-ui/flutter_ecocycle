const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');

const CART_SELECT = `
  SELECT
    ci.quantity,
    p.product_id,
    p.seller_id,
    s.seller_name,
    c.category_name AS category,
    p.product_name AS name,
    p.description,
    p.price,
    p.stock,
    p.image_url,
    p.weight_kg,
    su.latitude AS seller_lat,
    su.longitude AS seller_lng,
    p.sold_count AS sold,
    p.rating,
    (SELECT COUNT(*) FROM product_reviews r WHERE r.product_id = p.product_id) AS review_count
  FROM cart_items ci
  INNER JOIN carts ca ON ca.cart_id = ci.cart_id
  INNER JOIN products p ON p.product_id = ci.product_id
  INNER JOIN sellers s ON s.seller_id = p.seller_id
  LEFT JOIN users su ON su.user_id = s.user_id
  INNER JOIN product_categories c ON c.product_category_id = p.product_category_id
  WHERE ca.user_id = ?
  ORDER BY ci.cart_item_id`;

function mapCartItem(row) {
  return {
    quantity: Number(row.quantity),
    product: {
      product_id: row.product_id,
      seller_id: row.seller_id,
      seller_name: row.seller_name,
      category: row.category,
      name: row.name,
      description: row.description,
      price: Number(row.price),
      stock: Number(row.stock),
      image_url: row.image_url,
      weight_kg: Number(row.weight_kg),
      seller_lat: row.seller_lat != null ? Number(row.seller_lat) : null,
      seller_lng: row.seller_lng != null ? Number(row.seller_lng) : null,
      sold: Number(row.sold),
      rating: Number(row.rating),
      review_count: Number(row.review_count),
    },
  };
}

async function getOrCreateCartId(userId) {
  const [rows] = await pool.query(
    'SELECT cart_id FROM carts WHERE user_id = ? LIMIT 1',
    [userId],
  );
  if (rows.length > 0) return rows[0].cart_id;
  const [result] = await pool.query(
    'INSERT INTO carts (user_id) VALUES (?)',
    [userId],
  );
  return result.insertId;
}

async function cartPayload(userId) {
  const [rows] = await pool.query(CART_SELECT, [userId]);
  return rows.map(mapCartItem);
}

async function getCart(req, res, next) {
  try {
    res.json({ data: await cartPayload(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function addToCart(req, res, next) {
  try {
    const productId = Number(req.body.product_id);
    const quantity = Number(req.body.quantity || 1);
    if (!productId || quantity <= 0) {
      throw new HttpError(400, 'Produk atau jumlah tidak valid');
    }

    const [products] = await pool.query(
      `SELECT p.product_id, s.user_id AS seller_user_id
       FROM products p INNER JOIN sellers s ON s.seller_id = p.seller_id
       WHERE p.product_id = ? LIMIT 1`,
      [productId],
    );
    if (products.length === 0) throw new HttpError(404, 'Produk tidak ditemukan');
    if (products[0].seller_user_id === req.user.user_id) {
      throw new HttpError(400, 'Tidak bisa membeli produk sendiri');
    }

    const cartId = await getOrCreateCartId(req.user.user_id);
    const [existing] = await pool.query(
      'SELECT cart_item_id, quantity FROM cart_items WHERE cart_id = ? AND product_id = ? LIMIT 1',
      [cartId, productId],
    );

    if (existing.length > 0) {
      await pool.query(
        'UPDATE cart_items SET quantity = quantity + ? WHERE cart_item_id = ?',
        [quantity, existing[0].cart_item_id],
      );
    } else {
      await pool.query(
        'INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)',
        [cartId, productId, quantity],
      );
    }

    res.status(201).json({ data: await cartPayload(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function updateCartItem(req, res, next) {
  try {
    const productId = Number(req.params.productId);
    const quantity = Number(req.body.quantity);
    const cartId = await getOrCreateCartId(req.user.user_id);

    if (!Number.isFinite(quantity) || quantity <= 0) {
      await pool.query(
        'DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?',
        [cartId, productId],
      );
    } else {
      await pool.query(
        'UPDATE cart_items SET quantity = ? WHERE cart_id = ? AND product_id = ?',
        [quantity, cartId, productId],
      );
    }
    res.json({ data: await cartPayload(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function removeCartItem(req, res, next) {
  try {
    const cartId = await getOrCreateCartId(req.user.user_id);
    await pool.query(
      'DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?',
      [cartId, Number(req.params.productId)],
    );
    res.json({ data: await cartPayload(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function clearCart(req, res, next) {
  try {
    const cartId = await getOrCreateCartId(req.user.user_id);
    await pool.query('DELETE FROM cart_items WHERE cart_id = ?', [cartId]);
    res.json({ data: [] });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeCartItem,
  clearCart,
};
