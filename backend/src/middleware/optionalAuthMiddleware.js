const { pool } = require('../config/db');
const { verifyToken } = require('../utils/jwt');

// Seperti authMiddleware, tapi tidak menolak bila token tak ada/invalid.
// Bila token valid, set req.user; selain itu lanjut sebagai tamu.
async function optionalAuthenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const [scheme, token] = authHeader.split(' ');

    if (scheme === 'Bearer' && token) {
      const payload = verifyToken(token);
      const [rows] = await pool.query(
        `SELECT u.user_id, u.full_name, u.email
         FROM users u WHERE u.user_id = ?`,
        [payload.user_id],
      );
      if (rows.length > 0) {
        req.user = rows[0];
      }
    }
  } catch (_) {
    // abaikan token invalid → tetap sebagai tamu
  }
  next();
}

module.exports = optionalAuthenticate;
