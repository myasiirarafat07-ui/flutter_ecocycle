const { pool } = require('../config/db');

function publicTransaction(row) {
  return {
    point_transaction_id: row.point_transaction_id,
    transaction_type: row.transaction_type,
    points: Number(row.points),
    description: row.description,
    created_at: row.created_at,
  };
}

async function getPoints(req, res, next) {
  try {
    const [userRows] = await pool.query(
      `SELECT eco_points, total_waste_kg, trees_planted, co2_offset_kg
       FROM users WHERE user_id = ? LIMIT 1`,
      [req.user.user_id],
    );
    const u = userRows[0] || {};

    const [txRows] = await pool.query(
      `SELECT point_transaction_id, transaction_type, points, description, created_at
       FROM point_transactions WHERE user_id = ?
       ORDER BY created_at DESC, point_transaction_id DESC`,
      [req.user.user_id],
    );

    res.json({
      balance: Number(u.eco_points || 0),
      total_waste_kg: Number(u.total_waste_kg || 0),
      trees_planted: Number(u.trees_planted || 0),
      co2_offset_kg: Number(u.co2_offset_kg || 0),
      data: txRows.map(publicTransaction),
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getPoints,
};
