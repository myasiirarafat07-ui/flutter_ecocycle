const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');

const TYPES = ['KARTU_KREDIT', 'KARTU_DEBIT', 'EWALLET'];

function cleanText(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function publicMethod(row) {
  return {
    payment_method_id: row.payment_method_id,
    method_type: row.method_type,
    label: row.label,
    detail: row.detail,
    is_default: Boolean(row.is_default),
    created_at: row.created_at,
  };
}

async function listMethods(userId) {
  const [rows] = await pool.query(
    `SELECT payment_method_id, method_type, label, detail, is_default, created_at
     FROM payment_methods WHERE user_id = ?
     ORDER BY is_default DESC, created_at DESC`,
    [userId],
  );
  return rows.map(publicMethod);
}

async function getMethods(req, res, next) {
  try {
    res.json({ data: await listMethods(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function createMethod(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const methodType = cleanText(req.body.method_type).toUpperCase();
    const label = cleanText(req.body.label);
    const detail = cleanText(req.body.detail);

    if (!TYPES.includes(methodType)) {
      throw new HttpError(400, 'Tipe metode tidak valid');
    }
    if (!label) throw new HttpError(400, 'Label wajib diisi');

    await connection.beginTransaction();

    // Metode pertama otomatis jadi default.
    const [countRows] = await connection.query(
      'SELECT COUNT(*) AS n FROM payment_methods WHERE user_id = ?',
      [req.user.user_id],
    );
    const isDefault = countRows[0].n === 0 ? 1 : 0;

    await connection.query(
      `INSERT INTO payment_methods (user_id, method_type, label, detail, is_default)
       VALUES (?, ?, ?, ?, ?)`,
      [req.user.user_id, methodType, label, detail || '-', isDefault],
    );

    await connection.commit();
    res.status(201).json({ data: await listMethods(req.user.user_id) });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

async function deleteMethod(req, res, next) {
  try {
    const id = Number(req.params.id);
    const [rows] = await pool.query(
      'SELECT is_default FROM payment_methods WHERE payment_method_id = ? AND user_id = ? LIMIT 1',
      [id, req.user.user_id],
    );
    if (rows.length === 0) throw new HttpError(404, 'Metode tidak ditemukan');

    await pool.query(
      'DELETE FROM payment_methods WHERE payment_method_id = ? AND user_id = ?',
      [id, req.user.user_id],
    );

    // Bila yang dihapus adalah default, jadikan metode terbaru sebagai default.
    if (rows[0].is_default) {
      await pool.query(
        `UPDATE payment_methods SET is_default = 1
         WHERE user_id = ?
         ORDER BY created_at DESC LIMIT 1`,
        [req.user.user_id],
      );
    }

    res.json({ data: await listMethods(req.user.user_id) });
  } catch (error) {
    next(error);
  }
}

async function clearMethods(req, res, next) {
  try {
    await pool.query('DELETE FROM payment_methods WHERE user_id = ?', [
      req.user.user_id,
    ]);
    res.json({ data: [] });
  } catch (error) {
    next(error);
  }
}

async function setDefaultMethod(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const id = Number(req.params.id);
    const [rows] = await connection.query(
      'SELECT payment_method_id FROM payment_methods WHERE payment_method_id = ? AND user_id = ? LIMIT 1',
      [id, req.user.user_id],
    );
    if (rows.length === 0) throw new HttpError(404, 'Metode tidak ditemukan');

    await connection.beginTransaction();
    await connection.query(
      'UPDATE payment_methods SET is_default = 0 WHERE user_id = ?',
      [req.user.user_id],
    );
    await connection.query(
      'UPDATE payment_methods SET is_default = 1 WHERE payment_method_id = ? AND user_id = ?',
      [id, req.user.user_id],
    );
    await connection.commit();

    res.json({ data: await listMethods(req.user.user_id) });
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

module.exports = {
  getMethods,
  createMethod,
  deleteMethod,
  clearMethods,
  setDefaultMethod,
};
