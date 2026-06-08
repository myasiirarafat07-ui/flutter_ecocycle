// Skrip utilitas: reset counter statistik (eco points, dampak, jumlah terjual).
//
// Kenapa perlu skrip ini: eco_points, total_waste_kg, green_transactions,
// co2_offset_kg (tabel users) dan sold_count (tabel products) adalah COUNTER
// yang disimpan langsung di kolom dan ditambah saat checkout — bukan dihitung
// ulang dari tabel orders/point_transactions. Jadi menghapus baris order tidak
// menurunkannya; harus di-reset di kolomnya, itulah yang dilakukan skrip ini.
//
// Pemakaian (dari folder backend):
//   npm run reset-stats           -> reset SEMUA user + SEMUA produk + hapus riwayat poin
//   npm run reset-stats -- 6      -> reset hanya user_id 6 (poin, dampak, riwayat poin-nya);
//                                    produk tidak disentuh
require('dotenv').config({ quiet: true });
const { pool } = require('../config/db');

async function main() {
  const arg = process.argv[2];
  const userId = arg ? Number(arg) : null;

  if (arg && (!Number.isInteger(userId) || userId <= 0)) {
    console.error(`user_id tidak valid: "${arg}"`);
    process.exit(1);
  }

  const userStatReset = `
    eco_points = 0,
    total_waste_kg = 0,
    green_transactions = 0,
    co2_offset_kg = 0`;

  if (userId) {
    const [u] = await pool.query(
      `UPDATE users SET ${userStatReset} WHERE user_id = ?`,
      [userId],
    );
    const [t] = await pool.query(
      'DELETE FROM point_transactions WHERE user_id = ?',
      [userId],
    );
    if (u.affectedRows === 0) {
      console.warn(`Tidak ada user dengan user_id ${userId}.`);
    } else {
      console.log(`✓ User ${userId}: poin & dampak direset, ${t.affectedRows} riwayat poin dihapus.`);
    }
  } else {
    const [u] = await pool.query(`UPDATE users SET ${userStatReset}`);
    const [p] = await pool.query('UPDATE products SET sold_count = 0');
    const [t] = await pool.query('DELETE FROM point_transactions');
    console.log(
      `✓ Reset selesai: ${u.affectedRows} user (poin & dampak), ` +
        `${p.affectedRows} produk (jumlah terjual), ` +
        `${t.affectedRows} riwayat poin dihapus.`,
    );
  }

  console.log('Catatan: buka ulang/login ulang aplikasi agar nilai ter-refresh.');
}

main()
  .catch((e) => {
    console.error('Gagal reset:', e.message);
    process.exitCode = 1;
  })
  .finally(() => pool.end());
