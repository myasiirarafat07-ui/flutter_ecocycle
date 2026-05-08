const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');
const { verifyToken } = require('../utils/jwt');

async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const [scheme, token] = authHeader.split(' ');

    if (scheme !== 'Bearer' || !token) {
      throw new HttpError(401, 'Token tidak ditemukan');
    }

    const payload = verifyToken(token);
    const [rows] = await pool.query(
      `SELECT
        u.user_id,
        u.user_type_id,
        ut.type_name AS user_type,
        u.full_name,
        u.email,
        u.phone_number,
        u.address,
        u.is_premium,
        u.eco_points,
        u.total_waste_kg,
        u.trees_planted,
        u.co2_offset_kg,
        u.account_status,
        u.created_at
      FROM users u
      INNER JOIN user_types ut ON ut.user_type_id = u.user_type_id
      WHERE u.user_id = ?`,
      [payload.user_id],
    );

    if (rows.length === 0 || rows[0].account_status !== 'ACTIVE') {
      throw new HttpError(401, 'Akun tidak valid');
    }

    req.user = rows[0];
    next();
  } catch (error) {
    next(error.statusCode ? error : new HttpError(401, 'Token tidak valid'));
  }
}

module.exports = authenticate;
