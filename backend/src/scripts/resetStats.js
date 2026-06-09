// Skrip utilitas: reset counter statistik (eco points, dampak, jumlah terjual),
// dengan opsi membersihkan data pembelian sekaligus mengembalikan stok.
//
// Kenapa perlu skrip ini: eco_points, total_waste_kg, green_transactions,
// co2_offset_kg (tabel users) dan sold_count (tabel products) adalah COUNTER
// yang disimpan langsung di kolom & ditambah saat checkout — bukan dihitung
// ulang dari tabel orders/point_transactions. Jadi menghapus baris order tidak
// menurunkan counter, dan stok yang berkurang saat beli juga tidak balik sendiri.
//
// Pemakaian (dari folder backend):
//   npm run reset-stats                      -> reset SEMUA user + SEMUA produk (sold_count) + hapus riwayat poin
//   npm run reset-stats -- 6                 -> reset hanya user_id 6 (poin, dampak, riwayat poin-nya)
//   npm run reset-stats -- --purchases       -> di atas + hapus SEMUA order/payment, KEMBALIKAN stok, hapus SEMUA notif ORDER/SALE
//   npm run reset-stats -- 6 --purchases     -> sama tapi hanya pembelian user 6 (notif ORDER pembeli + SALE penjual order itu ikut terhapus)
//
// Flag --purchases punya alias: --orders, --all
require('dotenv').config({ quiet: true });
const { pool } = require('../config/db');

const PURCHASE_FLAGS = ['--purchases', '--orders', '--all'];

async function main() {
  const args = process.argv.slice(2);
  const wipePurchases = args.some((a) => PURCHASE_FLAGS.includes(a));
  const userArg = args.find((a) => /^\d+$/.test(a));
  const userId = userArg ? Number(userArg) : null;

  const unknown = args.filter(
    (a) => a !== userArg && !PURCHASE_FLAGS.includes(a),
  );
  if (unknown.length > 0) {
    console.error(`Argumen tidak dikenal: ${unknown.join(', ')}`);
    process.exit(1);
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // Filter scope: per-user atau global.
    const where = userId ? 'WHERE o.user_id = ?' : '';
    const p = userId ? [userId] : [];

    let restoredStock = 0;
    let removedOrders = 0;

    if (wipePurchases) {
      // 0) Kumpulkan order_code yang akan dihapus. Dipakai untuk membersihkan
      //    notifikasi terkait — termasuk notif SALE milik PENJUAL yang user_id-nya
      //    berbeda dari scope reset (tabel notifications tak punya kolom order_id,
      //    jadi dicocokkan lewat order_code yang tertulis di body).
      const [orderRows] = await connection.query(
        `SELECT o.order_code FROM orders o ${where}`,
        p,
      );
      const orderCodes = orderRows.map((r) => r.order_code);

      // 1) Kembalikan stok dari item yang akan dihapus.
      const [items] = await connection.query(
        `SELECT oi.product_id, SUM(oi.quantity) AS qty
           FROM order_items oi
           JOIN orders o ON o.order_id = oi.order_id
           ${where}
          GROUP BY oi.product_id`,
        p,
      );
      for (const it of items) {
        await connection.query(
          'UPDATE products SET stock = stock + ? WHERE product_id = ?',
          [it.qty, it.product_id],
        );
        restoredStock += 1;
      }

      // 2) Hapus payments & order_items (anak), lalu orders (induk).
      await connection.query(
        `DELETE pay FROM payments pay
           JOIN orders o ON o.order_id = pay.order_id ${where}`,
        p,
      );
      await connection.query(
        `DELETE oi FROM order_items oi
           JOIN orders o ON o.order_id = oi.order_id ${where}`,
        p,
      );
      const [delOrders] = await connection.query(
        `DELETE FROM orders ${userId ? 'WHERE user_id = ?' : ''}`,
        p,
      );
      removedOrders = delOrders.affectedRows;

      // 3) Hapus notifikasi hasil checkout (ORDER untuk pembeli, SALE untuk penjual).
      if (userId) {
        // Per-user: cocokkan via order_code di body agar notif SALE milik penjual
        // (user_id berbeda) ikut terhapus, bukan hanya notif milik user ini.
        if (orderCodes.length > 0) {
          const likeClause = orderCodes.map(() => 'body LIKE ?').join(' OR ');
          await connection.query(
            `DELETE FROM notifications
              WHERE notification_type IN ('ORDER', 'SALE') AND (${likeClause})`,
            orderCodes.map((c) => `%${c}%`),
          );
        }
      } else {
        // Global: bersihkan semua notifikasi order/sale (termasuk yang yatim).
        await connection.query(
          `DELETE FROM notifications WHERE notification_type IN ('ORDER', 'SALE')`,
        );
      }
    }

    // 4) sold_count: hitung ulang dari order_items yang tersisa (akurat utk semua mode).
    await connection.query(
      `UPDATE products p
          SET sold_count = (
            SELECT COALESCE(SUM(oi.quantity), 0)
              FROM order_items oi WHERE oi.product_id = p.product_id
          )`,
    );

    // 5) Reset stat user + hapus riwayat poin.
    const userStatReset = `
      eco_points = 0,
      total_waste_kg = 0,
      green_transactions = 0,
      co2_offset_kg = 0`;
    const [u] = await connection.query(
      `UPDATE users SET ${userStatReset} ${userId ? 'WHERE user_id = ?' : ''}`,
      userId ? [userId] : [],
    );
    const [t] = await connection.query(
      `DELETE FROM point_transactions ${userId ? 'WHERE user_id = ?' : ''}`,
      userId ? [userId] : [],
    );

    await connection.commit();

    const scope = userId ? `user ${userId}` : 'semua user';
    console.log(`✓ Reset ${scope}: poin & dampak di-nol-kan, ${t.affectedRows} riwayat poin dihapus.`);
    if (wipePurchases) {
      console.log(
        `✓ Pembelian dibersihkan: ${removedOrders} order dihapus, ` +
          `stok ${restoredStock} produk dikembalikan, notifikasi order/sale dihapus.`,
      );
    } else {
      console.log('  (Order & stok TIDAK disentuh. Tambahkan --purchases untuk membersihkannya.)');
    }
    console.log('Catatan: buka ulang/login ulang aplikasi agar nilai ter-refresh.');
  } catch (e) {
    await connection.rollback();
    throw e;
  } finally {
    connection.release();
  }
}

main()
  .catch((e) => {
    console.error('Gagal reset:', e.message);
    process.exitCode = 1;
  })
  .finally(() => pool.end());
