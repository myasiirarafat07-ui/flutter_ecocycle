const { pool } = require('../config/db');

function mapNotification(row) {
  return {
    notification_id: row.notification_id,
    type: row.notification_type,
    title: row.title,
    body: row.body,
    is_read: Boolean(row.is_read),
    created_at: row.created_at,
  };
}

async function listNotifications(req, res, next) {
  try {
    const [rows] = await pool.query(
      `SELECT notification_id, notification_type, title, body, is_read, created_at
       FROM notifications
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [req.user.user_id],
    );
    const data = rows.map(mapNotification);
    res.json({
      data,
      unread_count: data.filter((n) => !n.is_read).length,
    });
  } catch (error) {
    next(error);
  }
}

async function markRead(req, res, next) {
  try {
    await pool.query(
      'UPDATE notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?',
      [Number(req.params.id), req.user.user_id],
    );
    res.json({ message: 'Notifikasi ditandai dibaca' });
  } catch (error) {
    next(error);
  }
}

async function markAllRead(req, res, next) {
  try {
    await pool.query(
      'UPDATE notifications SET is_read = 1 WHERE user_id = ?',
      [req.user.user_id],
    );
    res.json({ message: 'Semua notifikasi ditandai dibaca' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  listNotifications,
  markRead,
  markAllRead,
};
