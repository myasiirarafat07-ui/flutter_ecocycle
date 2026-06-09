const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');
const { CO2E_PER_WASTE_KG } = require('../utils/impact');
const { calcShipping } = require('../utils/shipping');

// Metode pengiriman: antar-warga dalam desa, ongkir dihitung dari jarak + berat.
const SHIPPING_METHOD = 'antar_warga';

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
    total_amount: Number(row.total_amount),
    payment_status: row.payment_status || 'PENDING',
    item_count: Number(row.item_count || 0),
    first_item: row.first_item || '',
    needs_review: Boolean(row.needs_review),
    created_at: row.created_at,
  };
}

async function createOrder(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const shippingMethod = SHIPPING_METHOD;
    const paymentMethod = (req.body.payment_method || 'COD').toString();
    // COD: belum lunas saat checkout — penjual mengonfirmasi terima uang dulu.
    // Non-COD (e-wallet/transfer): dianggap langsung lunas.
    const isCod = paymentMethod.trim().toUpperCase() === 'COD';
    // Fulfillment selalu mulai DIPROSES (penjual menyiapkan barang).
    // Pembayaran: PENDING untuk COD (lunas saat penjual terima uang),
    // PAID untuk non-COD (e-wallet/transfer dianggap langsung lunas).
    const initialOrderStatus = 'DIPROSES';
    const initialPaymentStatus = isCod ? 'PENDING' : 'PAID';

    // Lokasi pembeli (opsional) untuk hitung ongkir berbasis jarak.
    const rawBuyerLat = Number(req.body.buyer_lat);
    const rawBuyerLng = Number(req.body.buyer_lng);
    const buyer =
      Number.isFinite(rawBuyerLat) && Number.isFinite(rawBuyerLng)
        ? { lat: rawBuyerLat, lng: rawBuyerLng }
        : null;

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
    let buyerWaste = 0;
    const lines = [];
    const sellerUserIds = new Set();
    const sellerWaste = new Map(); // seller_user_id -> total limbah (kg)
    const sellerShipWeight = new Map(); // seller_user_id -> total berat kirim (kg)
    const sellerCoord = new Map(); // seller_user_id -> { lat, lng }

    for (const item of requested) {
      const productId = Number(item.product_id);
      const qty = Number(item.quantity) || 1;
      if (qty <= 0) continue;

      const [rows] = await connection.query(
        `SELECT p.product_id, p.product_name, p.price, p.stock, p.waste_kg, p.weight_kg,
                s.user_id AS seller_user_id, su.latitude AS seller_lat, su.longitude AS seller_lng
         FROM products p
         INNER JOIN sellers s ON s.seller_id = p.seller_id
         LEFT JOIN users su ON su.user_id = s.user_id
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
      const lineWaste = Number(p.waste_kg) * qty;
      buyerWaste += lineWaste;
      sellerWaste.set(
        p.seller_user_id,
        (sellerWaste.get(p.seller_user_id) || 0) + lineWaste,
      );
      sellerShipWeight.set(
        p.seller_user_id,
        (sellerShipWeight.get(p.seller_user_id) || 0) + Number(p.weight_kg) * qty,
      );
      if (!sellerCoord.has(p.seller_user_id)) {
        sellerCoord.set(p.seller_user_id, {
          lat: p.seller_lat != null ? Number(p.seller_lat) : null,
          lng: p.seller_lng != null ? Number(p.seller_lng) : null,
        });
      }
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

    // Ongkir otoritatif: hitung ulang di server dari koordinat penjual + berat,
    // abaikan nilai apa pun yang dikirim client.
    const shipLegs = [];
    for (const [sellerUserId, coord] of sellerCoord) {
      shipLegs.push({
        lat: coord.lat,
        lng: coord.lng,
        weightKg: sellerShipWeight.get(sellerUserId) || 0,
      });
    }
    const shippingCost = calcShipping(buyer, shipLegs).cost;
    const total = subtotal + shippingCost;
    const orderCode = genOrderCode();
    const shippingAddress =
      (req.user.address && req.user.address.trim()) || 'Alamat belum diatur';

    // 3) Insert order.
    const [orderResult] = await connection.query(
      `INSERT INTO orders
        (user_id, order_code, shipping_address, shipping_method, order_status, subtotal, shipping_cost, total_amount)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [req.user.user_id, orderCode, shippingAddress, shippingMethod, initialOrderStatus, subtotal, shippingCost, total],
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

    // 5) Payment. COD belum lunas (PENDING, paid_at NULL); non-COD langsung lunas.
    await connection.query(
      `INSERT INTO payments
        (order_id, payment_method, payment_status, paid_amount, paid_at)
      VALUES (?, ?, ?, ?, ?)`,
      [orderId, paymentMethod, initialPaymentStatus, total, isCod ? null : new Date()],
    );

    // 6) Notifikasi: pembeli + tiap penjual (ditautkan ke pesanan untuk deep-link).
    const buyerBody = isCod
      ? `Pesanan ${orderCode} dibuat. Penjual akan memproses & mengirim pesananmu (bayar tunai saat barang diterima).`
      : `Pesanan ${orderCode} berhasil dibuat & dibayar. Menunggu penjual mengirim.`;
    await connection.query(
      `INSERT INTO notifications (user_id, notification_type, title, body, related_order_id)
      VALUES (?, 'ORDER', 'Pesanan berhasil', ?, ?)`,
      [req.user.user_id, buyerBody, orderId],
    );
    for (const sellerUserId of sellerUserIds) {
      if (sellerUserId === req.user.user_id) continue;
      await connection.query(
        `INSERT INTO notifications (user_id, notification_type, title, body, related_order_id)
        VALUES (?, 'SALE', 'Pesanan baru', ?, ?)`,
        [sellerUserId, `Ada pesanan baru (${orderCode}) untuk produkmu.`, orderId],
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

    // 8) Dampak lingkungan: akumulasi ke pembeli & tiap penjual yang terlibat.
    //    Menambah limbah + 1 transaksi hijau, dan menghitung ulang CO2e dari total.
    // Catatan: MySQL mengevaluasi SET kiri-ke-kanan, sehingga saat menghitung
    // co2_offset_kg, total_waste_kg SUDAH bertambah → langsung kali faktor.
    const applyImpact = (userId, addedWaste) =>
      connection.query(
        `UPDATE users
          SET total_waste_kg = total_waste_kg + ?,
              green_transactions = green_transactions + 1,
              co2_offset_kg = total_waste_kg * ?
        WHERE user_id = ?`,
        [addedWaste, CO2E_PER_WASTE_KG, userId],
      );

    await applyImpact(req.user.user_id, buyerWaste);
    for (const [sellerUserId, waste] of sellerWaste) {
      await applyImpact(sellerUserId, waste);
    }

    // 9) Kosongkan keranjang.
    if (cartId) {
      await connection.query('DELETE FROM cart_items WHERE cart_id = ?', [cartId]);
    }

    await connection.commit();

    res.status(201).json({
      message: 'Pesanan berhasil dibuat',
      order: {
        order_id: orderId,
        order_code: orderCode,
        order_status: initialOrderStatus,
        payment_status: initialPaymentStatus,
        shipping_method: shippingMethod,
        subtotal,
        shipping_cost: shippingCost,
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
              o.subtotal, o.shipping_cost, o.total_amount, o.created_at,
              pay.payment_status,
              (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) AS item_count,
              (SELECT oi.product_name FROM order_items oi WHERE oi.order_id = o.order_id LIMIT 1) AS first_item,
              (o.order_status = 'SELESAI' AND EXISTS (
                 SELECT 1 FROM order_items oi2
                 WHERE oi2.order_id = o.order_id
                   AND NOT EXISTS (
                     SELECT 1 FROM product_reviews r
                     WHERE r.order_id = o.order_id
                       AND r.product_id = oi2.product_id
                       AND r.user_id = o.user_id
                   )
              )) AS needs_review
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
              0 AS shipping_cost,
              SUM(oi.subtotal) AS total_amount,
              COUNT(*) AS item_count,
              MIN(oi.product_name) AS first_item,
              pay.payment_status
       FROM order_items oi
       INNER JOIN products p ON p.product_id = oi.product_id
       INNER JOIN sellers s ON s.seller_id = p.seller_id
       INNER JOIN orders o ON o.order_id = oi.order_id
       INNER JOIN users buyer ON buyer.user_id = o.user_id
       LEFT JOIN payments pay ON pay.order_id = o.order_id
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
              o.shipping_method, o.subtotal, o.shipping_cost, o.total_amount, o.created_at,
              pay.payment_status, pay.payment_method, pay.paid_at
       FROM orders o
       LEFT JOIN payments pay ON pay.order_id = o.order_id
       WHERE o.order_id = ? LIMIT 1`,
      [orderId],
    );
    if (orders.length === 0) throw new HttpError(404, 'Pesanan tidak ditemukan');
    const order = orders[0];

    // Akses: pembeli, atau penjual salah satu item.
    const isBuyer = order.user_id === req.user.user_id;
    const isSeller = await isSellerOfOrder(pool, orderId, req.user.user_id);
    if (!isBuyer && !isSeller) {
      throw new HttpError(403, 'Tidak ada akses ke pesanan ini');
    }

    const [items] = await pool.query(
      `SELECT oi.product_id, oi.product_name, oi.unit_price, oi.quantity, oi.subtotal, p.image_url,
              (SELECT COUNT(*) FROM product_reviews r
                WHERE r.order_id = oi.order_id
                  AND r.product_id = oi.product_id
                  AND r.user_id = ?) AS reviewed
       FROM order_items oi
       LEFT JOIN products p ON p.product_id = oi.product_id
       WHERE oi.order_id = ?`,
      [order.user_id, orderId],
    );

    // Pesanan butuh ulasan bila sudah SELESAI dan ada item yang belum diulas.
    const needsReview =
      String(order.order_status).toUpperCase() === 'SELESAI' &&
      items.some((i) => Number(i.reviewed) === 0);

    res.json({
      order: {
        order_id: order.order_id,
        order_code: order.order_code,
        order_status: order.order_status,
        shipping_address: order.shipping_address,
        shipping_method: order.shipping_method,
        subtotal: Number(order.subtotal),
        shipping_cost: Number(order.shipping_cost),
        total_amount: Number(order.total_amount),
        payment_status: order.payment_status || 'PENDING',
        payment_method: order.payment_method || '',
        paid_at: order.paid_at,
        created_at: order.created_at,
        is_buyer: isBuyer,
        is_seller: isSeller,
        needs_review: needsReview,
        items: items.map((i) => ({
          product_id: i.product_id,
          product_name: i.product_name,
          unit_price: Number(i.unit_price),
          quantity: Number(i.quantity),
          subtotal: Number(i.subtotal),
          image_url: i.image_url || '',
          reviewed: Number(i.reviewed) > 0,
        })),
      },
    });
  } catch (error) {
    next(error);
  }
}

// Apakah user adalah penjual salah satu item di order ini?
async function isSellerOfOrder(connection, orderId, userId) {
  const [rows] = await connection.query(
    `SELECT 1 FROM order_items oi
     INNER JOIN products p ON p.product_id = oi.product_id
     INNER JOIN sellers s ON s.seller_id = p.seller_id
     WHERE oi.order_id = ? AND s.user_id = ? LIMIT 1`,
    [orderId, userId],
  );
  return rows.length > 0;
}

// Penjual mengirim/menyerahkan barang: DIPROSES -> DIKIRIM.
async function shipOrder(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const orderId = Number(req.params.id);
    await connection.beginTransaction();

    const [orders] = await connection.query(
      'SELECT order_id, user_id, order_code, order_status FROM orders WHERE order_id = ? LIMIT 1 FOR UPDATE',
      [orderId],
    );
    if (orders.length === 0) throw new HttpError(404, 'Pesanan tidak ditemukan');
    const order = orders[0];

    if (!(await isSellerOfOrder(connection, orderId, req.user.user_id))) {
      throw new HttpError(403, 'Hanya penjual yang bisa mengirim pesanan');
    }
    if (order.order_status !== 'DIPROSES') {
      throw new HttpError(400, 'Pesanan tidak dalam status diproses');
    }

    await connection.query(
      "UPDATE orders SET order_status = 'DIKIRIM', updated_at = NOW() WHERE order_id = ?",
      [orderId],
    );
    await connection.query(
      `INSERT INTO notifications (user_id, notification_type, title, body, related_order_id)
      VALUES (?, 'ORDER', 'Pesanan dikirim', ?, ?)`,
      [order.user_id, `Pesanan ${order.order_code} sedang dikirim/diserahkan penjual.`, orderId],
    );

    await connection.commit();
    res.json({ message: 'Pesanan dikirim', order_status: 'DIKIRIM' });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

// Penjual mengonfirmasi sudah menerima uang (COD): payment PENDING -> PAID.
// Terpisah dari fulfillment (order_status) — penjual biasanya menekan ini saat
// serah-terima barang.
async function confirmPayment(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const orderId = Number(req.params.id);
    await connection.beginTransaction();

    const [orders] = await connection.query(
      'SELECT order_id, user_id, order_code FROM orders WHERE order_id = ? LIMIT 1 FOR UPDATE',
      [orderId],
    );
    if (orders.length === 0) throw new HttpError(404, 'Pesanan tidak ditemukan');
    const order = orders[0];

    if (!(await isSellerOfOrder(connection, orderId, req.user.user_id))) {
      throw new HttpError(403, 'Hanya penjual yang bisa mengonfirmasi pembayaran');
    }

    const [pays] = await connection.query(
      'SELECT payment_status FROM payments WHERE order_id = ? LIMIT 1 FOR UPDATE',
      [orderId],
    );
    if (pays.length === 0) throw new HttpError(404, 'Data pembayaran tidak ditemukan');
    if (pays[0].payment_status === 'PAID') {
      throw new HttpError(400, 'Pembayaran sudah lunas');
    }

    await connection.query(
      "UPDATE payments SET payment_status = 'PAID', paid_at = NOW() WHERE order_id = ?",
      [orderId],
    );
    await connection.query(
      `INSERT INTO notifications (user_id, notification_type, title, body, related_order_id)
      VALUES (?, 'ORDER', 'Pembayaran dikonfirmasi', ?, ?)`,
      [order.user_id, `Pembayaran pesanan ${order.order_code} telah dikonfirmasi penjual.`, orderId],
    );

    await connection.commit();
    res.json({ message: 'Pembayaran dikonfirmasi', payment_status: 'PAID' });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

// Pembeli mengonfirmasi pesanan sudah diterima: PAID -> SELESAI.
async function completeOrder(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const orderId = Number(req.params.id);
    await connection.beginTransaction();

    const [orders] = await connection.query(
      'SELECT order_id, user_id, order_code, order_status FROM orders WHERE order_id = ? LIMIT 1 FOR UPDATE',
      [orderId],
    );
    if (orders.length === 0) throw new HttpError(404, 'Pesanan tidak ditemukan');
    const order = orders[0];

    if (order.user_id !== req.user.user_id) {
      throw new HttpError(403, 'Hanya pembeli yang bisa menyelesaikan pesanan');
    }
    if (order.order_status !== 'DIKIRIM') {
      throw new HttpError(400, 'Pesanan belum dikirim / tidak bisa diselesaikan');
    }
    // Pembayaran harus lunas (COD: penjual sudah konfirmasi terima uang).
    const [pays] = await connection.query(
      'SELECT payment_status FROM payments WHERE order_id = ? LIMIT 1',
      [orderId],
    );
    if (pays.length === 0 || pays[0].payment_status !== 'PAID') {
      throw new HttpError(400, 'Pembayaran belum lunas. Konfirmasi pembayaran ke penjual dulu.');
    }

    await connection.query(
      "UPDATE orders SET order_status = 'SELESAI', updated_at = NOW() WHERE order_id = ?",
      [orderId],
    );

    // Beri tahu tiap penjual yang terlibat.
    const [sellers] = await connection.query(
      `SELECT DISTINCT s.user_id
       FROM order_items oi
       INNER JOIN products p ON p.product_id = oi.product_id
       INNER JOIN sellers s ON s.seller_id = p.seller_id
       WHERE oi.order_id = ? AND s.user_id IS NOT NULL`,
      [orderId],
    );
    for (const s of sellers) {
      if (s.user_id === req.user.user_id) continue;
      await connection.query(
        `INSERT INTO notifications (user_id, notification_type, title, body, related_order_id)
        VALUES (?, 'SALE', 'Pesanan selesai', ?, ?)`,
        [s.user_id, `Pesanan ${order.order_code} telah diselesaikan pembeli.`, orderId],
      );
    }

    // Ingatkan pembeli untuk memberi ulasan (deep-link ke detail pesanan).
    await connection.query(
      `INSERT INTO notifications (user_id, notification_type, title, body, related_order_id)
      VALUES (?, 'REVIEW', 'Beri ulasan', ?, ?)`,
      [order.user_id, `Pesanan ${order.order_code} selesai. Yuk beri ulasan produknya!`, orderId],
    );

    await connection.commit();
    res.json({ message: 'Pesanan selesai', order_status: 'SELESAI' });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

module.exports = {
  createOrder,
  listMyOrders,
  listMySales,
  getOrder,
  shipOrder,
  confirmPayment,
  completeOrder,
};
