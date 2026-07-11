const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');
const { parsePaging } = require('../utils/paging');

const CATEGORIES = ['Pupuk & Kompos', 'Karya Daur Ulang'];

const SORT_MAP = {
  terbaru: 'p.created_at DESC',
  termurah: 'p.price ASC',
  termahal: 'p.price DESC',
  terlaris: 'p.sold_count DESC',
};

// Bentuk SELECT yang di-alias agar cocok dengan model Product di Flutter.
const BASE_SELECT = `
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
    p.waste_kg,
    p.weight_kg,
    su.latitude AS seller_lat,
    su.longitude AS seller_lng,
    p.sold_count AS sold,
    p.rating,
    (s.user_id = ?) AS is_mine,
    (SELECT COUNT(*) FROM product_reviews r WHERE r.product_id = p.product_id) AS review_count
  FROM products p
  INNER JOIN sellers s ON s.seller_id = p.seller_id
  LEFT JOIN users su ON su.user_id = s.user_id
  INNER JOIN product_categories c ON c.product_category_id = p.product_category_id`;

function cleanText(value) {
  return typeof value === 'string' ? value.trim() : '';
}

// Lampirkan daftar gambar (galeri) ke tiap produk dalam satu query.
// Fallback ke image_url legacy bila produk belum punya baris product_images.
async function attachImages(products) {
  if (products.length === 0) return products;
  const ids = products.map((p) => p.product_id);
  const [imgs] = await pool.query(
    `SELECT product_id, image_path FROM product_images
     WHERE product_id IN (?) ORDER BY product_id, sort_order, image_id`,
    [ids],
  );
  const byProduct = new Map();
  for (const r of imgs) {
    if (!byProduct.has(r.product_id)) byProduct.set(r.product_id, []);
    byProduct.get(r.product_id).push(r.image_path);
  }
  for (const p of products) {
    const list = byProduct.get(p.product_id) || [];
    p.images = list.length ? list : p.image_url ? [p.image_url] : [];
  }
  return products;
}

// Ganti seluruh galeri produk dengan daftar baru (urut sesuai indeks).
async function replaceProductImages(productId, images) {
  await pool.query('DELETE FROM product_images WHERE product_id = ?', [productId]);
  for (let i = 0; i < images.length; i += 1) {
    await pool.query(
      'INSERT INTO product_images (product_id, image_path, sort_order) VALUES (?, ?, ?)',
      [productId, images[i], i],
    );
  }
}

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
    waste_kg: Number(row.waste_kg),
    weight_kg: Number(row.weight_kg),
    seller_lat: row.seller_lat != null ? Number(row.seller_lat) : null,
    seller_lng: row.seller_lng != null ? Number(row.seller_lng) : null,
    sold: Number(row.sold),
    rating: Number(row.rating),
    review_count: Number(row.review_count),
    is_mine: Boolean(row.is_mine),
    created_at: row.created_at,
  };
}

async function categoryIdByName(name) {
  const [rows] = await pool.query(
    'SELECT product_category_id FROM product_categories WHERE category_name = ? LIMIT 1',
    [name],
  );
  return rows[0]?.product_category_id;
}

/// Pastikan user punya baris seller; buat bila belum ada.
async function getOrCreateSellerId(user) {
  const [rows] = await pool.query(
    'SELECT seller_id FROM sellers WHERE user_id = ? LIMIT 1',
    [user.user_id],
  );
  if (rows.length > 0) return rows[0].seller_id;

  const [result] = await pool.query(
    `INSERT INTO sellers (user_id, seller_name) VALUES (?, ?)`,
    [user.user_id, user.full_name || 'Penjual EcoCycle'],
  );
  return result.insertId;
}

async function listProducts(req, res, next) {
  try {
    const where = [];
    const params = [req.user?.user_id ?? 0]; // untuk is_mine

    const category = cleanText(req.query.category);
    if (category && category !== 'Semua' && CATEGORIES.includes(category)) {
      where.push('c.category_name = ?');
      params.push(category);
    }

    const search = cleanText(req.query.search);
    if (search) {
      where.push('p.product_name LIKE ?');
      params.push(`%${search}%`);
    }

    const minPrice = Number(req.query.min_price);
    if (Number.isFinite(minPrice) && minPrice > 0) {
      where.push('p.price >= ?');
      params.push(minPrice);
    }

    const maxPrice = Number(req.query.max_price);
    if (Number.isFinite(maxPrice) && maxPrice > 0) {
      where.push('p.price <= ?');
      params.push(maxPrice);
    }

    const minRating = Number(req.query.min_rating);
    if (Number.isFinite(minRating) && minRating > 0) {
      where.push('p.rating >= ?');
      params.push(minRating);
    }

    const orderBy = SORT_MAP[cleanText(req.query.sort)] || SORT_MAP.terbaru;
    const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const { limit, offset, page } = parsePaging(req.query);

    const [rows] = await pool.query(
      `${BASE_SELECT} ${whereSql} ORDER BY ${orderBy} LIMIT ? OFFSET ?`,
      [...params, limit, offset],
    );
    const products = await attachImages(rows.map(publicProduct));
    res.json({
      data: products,
      page,
      limit,
      has_more: products.length === limit,
    });
  } catch (error) {
    next(error);
  }
}

async function getMyProducts(req, res, next) {
  try {
    const [rows] = await pool.query(
      `${BASE_SELECT} WHERE s.user_id = ? ORDER BY p.created_at DESC`,
      [req.user.user_id, req.user.user_id],
    );
    const products = await attachImages(rows.map(publicProduct));
    res.json({ data: products });
  } catch (error) {
    next(error);
  }
}

async function getProduct(req, res, next) {
  try {
    const [rows] = await pool.query(
      `${BASE_SELECT} WHERE p.product_id = ? LIMIT 1`,
      [req.user?.user_id ?? 0, req.params.id],
    );
    if (rows.length === 0) throw new HttpError(404, 'Produk tidak ditemukan');
    const [product] = await attachImages([publicProduct(rows[0])]);
    res.json({ product });
  } catch (error) {
    next(error);
  }
}

function validateProductBody(body) {
  const name = cleanText(body.name);
  const category = cleanText(body.category);
  const description = cleanText(body.description);
  const imageUrl = cleanText(body.image_url || body.imageUrl);
  const price = Number(body.price);
  const stock = Number(body.stock);
  const wasteKg = Number(body.waste_kg ?? body.wasteKg ?? 0);
  const weightKg = Number(body.weight_kg ?? body.weightKg ?? 0);
  // Galeri gambar (URL relatif/absolut atau base64). Foto pertama = utama.
  const images = Array.isArray(body.images)
    ? body.images.map(cleanText).filter(Boolean).slice(0, 5)
    : [];

  if (!name || name.length < 3) {
    throw new HttpError(400, 'Nama produk minimal 3 karakter');
  }
  if (!CATEGORIES.includes(category)) {
    throw new HttpError(400, 'Kategori tidak valid');
  }
  if (!Number.isFinite(price) || price < 0) {
    throw new HttpError(400, 'Harga tidak valid');
  }
  if (!Number.isFinite(stock) || stock < 0) {
    throw new HttpError(400, 'Stok tidak valid');
  }
  if (!Number.isFinite(wasteKg) || wasteKg < 0) {
    throw new HttpError(400, 'Berat limbah tidak valid');
  }
  if (!Number.isFinite(weightKg) || weightKg < 0) {
    throw new HttpError(400, 'Berat produk tidak valid');
  }
  // Foto utama: gambar pertama galeri, jika ada; selain itu image_url terkirim.
  const primaryImage = images[0] || imageUrl;
  return {
    name,
    category,
    description,
    imageUrl: primaryImage,
    images,
    price,
    stock,
    wasteKg,
    weightKg,
  };
}

async function createProduct(req, res, next) {
  try {
    const { name, category, description, imageUrl, images, price, stock, wasteKg, weightKg } =
      validateProductBody(req.body);

    const categoryId = await categoryIdByName(category);
    if (!categoryId) throw new HttpError(400, 'Kategori tidak ditemukan');

    const sellerId = await getOrCreateSellerId(req.user);

    const [result] = await pool.query(
      `INSERT INTO products
        (seller_id, product_category_id, product_name, description, price, stock, waste_kg, weight_kg, image_url, rating, sold_count, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, NOW())`,
      [sellerId, categoryId, name, description, price, stock, wasteKg, weightKg, imageUrl],
    );

    if (images.length) await replaceProductImages(result.insertId, images);

    const [rows] = await pool.query(
      `${BASE_SELECT} WHERE p.product_id = ?`,
      [req.user.user_id, result.insertId],
    );
    const [product] = await attachImages([publicProduct(rows[0])]);
    res.status(201).json({
      message: 'Produk berhasil ditambahkan',
      product,
    });
  } catch (error) {
    next(error);
  }
}

/// Pastikan produk dimiliki oleh user yang login (lewat sellers.user_id).
async function assertOwnership(productId, userId) {
  const [rows] = await pool.query(
    `SELECT p.product_id
     FROM products p
     INNER JOIN sellers s ON s.seller_id = p.seller_id
     WHERE p.product_id = ? AND s.user_id = ? LIMIT 1`,
    [productId, userId],
  );
  if (rows.length === 0) {
    // Bedakan 404 vs 403.
    const [exists] = await pool.query(
      'SELECT product_id FROM products WHERE product_id = ? LIMIT 1',
      [productId],
    );
    if (exists.length === 0) throw new HttpError(404, 'Produk tidak ditemukan');
    throw new HttpError(403, 'Kamu tidak punya akses ke produk ini');
  }
}

async function updateProduct(req, res, next) {
  try {
    await assertOwnership(Number(req.params.id), req.user.user_id);
    const { name, category, description, imageUrl, images, price, stock, wasteKg, weightKg } =
      validateProductBody(req.body);
    const categoryId = await categoryIdByName(category);
    if (!categoryId) throw new HttpError(400, 'Kategori tidak ditemukan');

    await pool.query(
      `UPDATE products
        SET product_category_id = ?, product_name = ?, description = ?, price = ?, stock = ?, waste_kg = ?, weight_kg = ?, image_url = ?
      WHERE product_id = ?`,
      [categoryId, name, description, price, stock, wasteKg, weightKg, imageUrl, req.params.id],
    );

    await replaceProductImages(Number(req.params.id), images);

    const [rows] = await pool.query(
      `${BASE_SELECT} WHERE p.product_id = ?`,
      [req.user.user_id, req.params.id],
    );
    const [product] = await attachImages([publicProduct(rows[0])]);
    res.json({
      message: 'Produk berhasil diperbarui',
      product,
    });
  } catch (error) {
    next(error);
  }
}

async function deleteProduct(req, res, next) {
  try {
    await assertOwnership(Number(req.params.id), req.user.user_id);
    await pool.query('DELETE FROM products WHERE product_id = ?', [
      req.params.id,
    ]);
    res.json({ message: 'Produk berhasil dihapus' });
  } catch (error) {
    next(error);
  }
}

// Terima unggahan multipart gambar produk; kembalikan URL relatif tersaji.
async function uploadProductImages(req, res, next) {
  try {
    const files = req.files || [];
    if (files.length === 0) throw new HttpError(400, 'Tidak ada gambar diunggah');
    const urls = files.map((f) => {
      const b64 = f.buffer.toString('base64');
      return `data:${f.mimetype};base64,${b64}`;
    });
    res.status(201).json({ urls });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  CATEGORIES,
  listProducts,
  getMyProducts,
  getProduct,
  createProduct,
  updateProduct,
  deleteProduct,
  uploadProductImages,
};
