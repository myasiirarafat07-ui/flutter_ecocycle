const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');

const SHIPPING = { standar: 15000, ekspres: 35000 };

function genOrderCode() {
  const rand = Math.random().toString(36).slice(2, 7).toUpperCase();
  return `EC-${Date.now().toString(36).toUpperCase()}-${rand}`;
}

function mapOrderRow(row) {
  return {
    order_id: row.order_id,
    order_code: row.order_code,
    order_status: row.order_status,
    shipping_method: row.shipping_method,
    subtotal: Number(row.subtotal),
    shipping_cost: Number(row.shipping_cost),
    discount: Number(row.discount),
    total_amount: Number(row.total_amount),
    payment_status: row.payment_status || 'PENDING',
    item_count: Number(row.item_count || 0),
    first_item: row.first_item || '',
    created_at: row.created_at,
  };
}

async function createOrder(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const shippingMethod =
      req.body.shipping_method === 'ekspres' ? 'ekspres' : 'standar';
    const paymentMethod = (req.body.payment_method || 'EcoWallet').toString();

    await connection.beginTransaction();

    // 1) Tentukan sumber item: buy-now (body.items) atau keranjang.
    let requested = Array.isArray(req.body.items) ? req.body.items : null;
    let cartId = null;

    if (!requested || requested.length === 0) {
      const [carts] = await connection.query(
        'SELECT cart_id FROM carts WHERE user_id = ? LIMIT 1',
        [req.user.user_id],
      );
      cartId = carts[0]?.cart_id;
      const [cartItems] = cartId
        ? await connection.query(
            'SELECT product_id, quantity FROM cart_items WHERE cart_id = ?',
            [cartId],
          )
        : [[]];
      requested = cartItems.map((r) => ({
        product_id: r.product_id,
        quantity: Number(r.quantity),
      }));
    }

    if (!requested || requested.length === 0) {
      throw new HttpError(400, 'Tidak ada item untuk dipesan');
    }

    // 2) Validasi & hitung dari harga server (lock baris produk).
    let subtotal = 0;
    const lines = [];
    const sellerUserIds = new Set();

    for (const item of requested) {
      const productId = Number(item.product_id);
      const qty = Number(item.quantity) || 1;
      if (qty <= 0) continue;

      const [rows] = await connection.query(
        `SELECT p.product_id, p.product_name, p.price, p.stock, s.user_id AS seller_user_id
         FROM products p
         INNER JOIN sellers s ON s.seller_id = p.seller_id
         WHERE p.product_id = ? FOR UPDATE`,
        [productId],
      );
      if (rows.length === 0) {
        throw new HttpError(404, `Produk #${productId} tidak ditemukan`);
      }
      const p = rows[0];
      if (p.seller_user_id === req.user.user_id) {
        throw new HttpError(400, 'Tidak bisa membeli produk sendiri');
      }
      if (Number(p.stock) < qty) {
        throw new HttpError(400, `Stok "${p.product_name}" tidak cukup`);
      }
      const lineSubtotal = Number(p.price) * qty;
      subtotal += lineSubtotal;
      lines.push({
        product_id: p.product_id,
        product_name: p.product_name,
        unit_price: Number(p.price),
        quantity: qty,
        subtotal: lineSubtotal,
      });
      sellerUserIds.add(p.seller_user_id);
    }

    if (lines.length === 0) throw new HttpError(400, 'Item pesanan tidak valid');

    const shippingCost = SHIPPING[shippingMethod];
    const total = subtotal + shippingCost;
    const orderCode = genOrderCode();
    const shippingAddress =
      (req.user.address && req.user.address.trim()) || 'Alamat belum diatur';

    // 3) Insert order.
    const [orderResult] = await connection.query(
      `INSERT INTO orders
        (user_id, order_code, shipping_address, shipping_method, order_status, subtotal, shipping_cost, discount, total_amount)
      VALUES (?, ?, ?, ?, 'PAID', ?, ?, 0, ?)`,
      [req.user.user_id, orderCode, shippingAddress, shippingMethod, subtotal, shippingCost, total],
    );
    const orderId = orderResult.insertId;

    // 4) Order items + update stok/sold.
    for (const line of lines) {
      await connection.query(
        `INSERT INTO order_items
          (order_id, product_id, product_name, unit_price, quantity, subtotal)
        VALUES (?, ?, ?, ?, ?, ?)`,
        [orderId, line.product_id, line.product_name, line.unit_price, line.quantity, line.subtotal],
      );
      await connection.query(
        'UPDATE products SET stock = stock - ?, sold_count = sold_count + ? WHERE product_id = ?',
        [line.quantity, line.quantity, line.product_id],
      );
    }

    // 5) Payment (simulasi sukses).
    await connection.query(
      `INSERT INTO payments
        (order_id, payment_method, payment_status, paid_amount, paid_at)
      VALUES (?, ?, 'PAID', ?, NOW())`,
      [orderId, paymentMethod, total],
    );

    // 6) Notifikasi: pembeli + tiap penjual.
    await connection.query(
      `INSERT INTO notifications (user_id, notification_type, title, body)
      VALUES (?, 'ORDER', 'Pesanan berhasil', ?)`,
      [req.user.user_id, `Pesanan ${orderCode} berhasil dibuat & dibayar.`],
    );
    for (const sellerUserId of sellerUserIds) {
      if (sellerUserId === req.user.user_id) continue;
      await connection.query(
        `INSERT INTO notifications (user_id, notification_type, title, body)
        VALUES (?, 'SALE', 'Pesanan baru', ?)`,
        [sellerUserId, `Ada pesanan baru (${orderCode}) untuk produkmu.`],
      );
    }

    // 7) Eco-points: hadiahkan poin dari pembelian (1 poin / Rp1.000).
    const earnedPoints = Math.floor(total / 1000);
    if (earnedPoints > 0) {
      await connection.query(
        `INSERT INTO point_transactions (user_id, transaction_type, points, description)
        VALUES (?, 'EARN', ?, ?)`,
        [req.user.user_id, earnedPoints, `Pembelian ${orderCode}`],
      );
      await connection.query(
        'UPDATE users SET eco_points = eco_points + ? WHERE user_id = ?',
        [earnedPoints, req.user.user_id],
      );
    }

    // 8) Kosongkan keranjang.
    if (cartId) {
      await connection.query('DELETE FROM cart_items WHERE cart_id = ?', [cartId]);
    }

    await connection.commit();

    res.status(201).json({
      message: 'Pesanan berhasil dibuat',
      order: {
        order_id: orderId,
        order_code: orderCode,
        order_status: 'PAID',
        payment_status: 'PAID',
        shipping_method: shippingMethod,
        subtotal,
        shipping_cost: shippingCost,
        discount: 0,
        total_amount: total,
        items: lines,
      },
    });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

async function listMyOrders(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT o.order_id, o.order_code, o.order_status, o.shipping_method,
              o.subtotal, o.shipping_cost, o.discount, o.total_amount, o.created_at,
              pay.payment_status,
              (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) AS item_count,
              (SELECT oi.product_name FROM order_items oi WHERE oi.order_id = o.order_id LIMIT 1) AS first_item
       FROM orders o
       LEFT JOIN payments pay ON pay.order_id = o.order_id
       WHERE o.user_id = ?
       ORDER BY o.created_at DESC`,
      [req.user.user_id],
    );
    res.json({ data: rows.map(mapOrderRow) });
  } catch (error) {
    next(error);
  }
}

async function listMySales(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT o.order_id, o.order_code, o.order_status, o.shipping_method, o.created_at,
              buyer.full_name AS buyer_name,
              SUM(oi.subtotal) AS subtotal,
              0 AS shipping_cost, 0 AS discount,
              SUM(oi.subtotal) AS total_amount,
              COUNT(*) AS item_count,
              MIN(oi.product_name) AS first_item,
              'PAID' AS payment_status
       FROM order_items oi
       INNER JOIN products p ON p.product_id = oi.product_id
       INNER JOIN sellers s ON s.seller_id = p.seller_id
       INNER JOIN orders o ON o.order_id = oi.order_id
       INNER JOIN users buyer ON buyer.user_id = o.user_id
       WHERE s.user_id = ?
       GROUP BY o.order_id
       ORDER BY o.created_at DESC`,
      [req.user.user_id],
    );
    res.json({
      data: rows.map((r) => ({ ...mapOrderRow(r), buyer_name: r.buyer_name })),
    });
  } catch (error) {
    next(error);
  }
}

async function getOrder(req, res, next) {
  try {
    const orderId = Number(req.params.id);
    const [orders] = await pool.query(
      `SELECT o.order_id, o.user_id, o.order_code, o.order_status, o.shipping_address,
              o.shipping_method, o.subtotal, o.shipping_cost, o.discount, o.total_amount, o.created_at,
              pay.payment_status, pay.payment_method, pay.paid_at
       FROM orders o
       LEFT JOIN payments pay ON pay.order_id = o.order_id
       WHERE o.order_id = ? LIMIT 1`,
      [orderId],
    );
    if (orders.length === 0) throw new HttpError(404, 'Pesanan tidak ditemukan');
    const order = orders[0];

    // Akses: pembeli, atau penjual salah satu item.
    let allowed = order.user_id === req.user.user_id;
    if (!allowed) {
      const [own] = await pool.query(
        `SELECT 1 FROM order_items oi
         INNER JOIN products p ON p.product_id = oi.product_id
         INNER JOIN sellers s ON s.seller_id = p.seller_id
         WHERE oi.order_id = ? AND s.user_id = ? LIMIT 1`,
        [orderId, req.user.user_id],
      );
      allowed = own.length > 0;
    }
    if (!allowed) throw new HttpError(403, 'Tidak ada akses ke pesanan ini');

    const [items] = await pool.query(
      `SELECT oi.product_id, oi.product_name, oi.unit_price, oi.quantity, oi.subtotal, p.image_url
       FROM order_items oi
       LEFT JOIN products p ON p.product_id = oi.product_id
       WHERE oi.order_id = ?`,
      [orderId],
    );

    res.json({
      order: {
        order_id: order.order_id,
        order_code: order.order_code,
        order_status: order.order_status,
        shipping_address: order.shipping_address,
        shipping_method: order.shipping_method,
        subtotal: Number(order.subtotal),
        shipping_cost: Number(order.shipping_cost),
        discount: Number(order.discount),
        total_amount: Number(order.total_amount),
        payment_status: order.payment_status || 'PENDING',
        payment_method: order.payment_method || '',
        paid_at: order.paid_at,
        created_at: order.created_at,
        items: items.map((i) => ({
          product_id: i.product_id,
          product_name: i.product_name,
          unit_price: Number(i.unit_price),
          quantity: Number(i.quantity),
          subtotal: Number(i.subtotal),
          image_url: i.image_url || '',
        })),
      },
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  createOrder,
  listMyOrders,
  listMySales,
  getOrder,
};
