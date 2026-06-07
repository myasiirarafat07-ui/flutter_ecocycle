const bcrypt = require('bcryptjs');
const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');
const { createToken } = require('../utils/jwt');

function cleanText(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function publicUser(row) {
  return {
    user_id: row.user_id,
    user_type_id: row.user_type_id,
    user_type: row.user_type,
    full_name: row.full_name,
    email: row.email,
    phone_number: row.phone_number,
    address: row.address,
    is_premium: Boolean(row.is_premium),
    eco_points: row.eco_points,
    total_waste_kg: Number(row.total_waste_kg),
    trees_planted: row.trees_planted,
    co2_offset_kg: Number(row.co2_offset_kg),
    account_status: row.account_status,
    created_at: row.created_at,
  };
}

async function getUserTypes(req, res, next) {
  try {
    const [rows] = await pool.query(
      'SELECT user_type_id, type_name, description FROM user_types ORDER BY user_type_id',
    );

    res.json({
      data: rows,
    });
  } catch (error) {
    next(error);
  }
}

async function register(req, res, next) {
  const connection = await pool.getConnection();

  try {
    const fullName = cleanText(req.body.full_name || req.body.name);
    const email = cleanText(req.body.email).toLowerCase();
    const phoneNumber = cleanText(req.body.phone_number || req.body.phone) || null;
    const password = cleanText(req.body.password);
    const userTypeName = cleanText(req.body.user_type);
    const userTypeId = Number(req.body.user_type_id || 0);

    if (!fullName || !email || !password) {
      throw new HttpError(400, 'Nama, email, dan password wajib diisi');
    }

    if (fullName.length < 3) {
      throw new HttpError(400, 'Nama minimal 3 karakter');
    }

    if (!isValidEmail(email)) {
      throw new HttpError(400, 'Format email tidak valid');
    }

    if (password.length < 6) {
      throw new HttpError(400, 'Password minimal 6 karakter');
    }

    const [existingUsers] = await connection.query(
      'SELECT user_id FROM users WHERE email = ? LIMIT 1',
      [email],
    );

    if (existingUsers.length > 0) {
      throw new HttpError(409, 'Email sudah terdaftar');
    }

    let selectedUserTypeId = userTypeId;

    if (!selectedUserTypeId && userTypeName) {
      const [types] = await connection.query(
        'SELECT user_type_id FROM user_types WHERE type_name = ? LIMIT 1',
        [userTypeName],
      );
      selectedUserTypeId = types[0]?.user_type_id || 0;
    }

    // Default: tiap akun adalah pembeli & penjual; pakai 'Individual'.
    if (!selectedUserTypeId) {
      const [defaults] = await connection.query(
        "SELECT user_type_id FROM user_types WHERE type_name = 'Individual' LIMIT 1",
      );
      selectedUserTypeId = defaults[0]?.user_type_id || 0;
    }

    if (!selectedUserTypeId) {
      throw new HttpError(400, 'Tipe pengguna tidak valid');
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const [result] = await connection.query(
      `INSERT INTO users
        (user_type_id, full_name, email, phone_number, password_hash)
      VALUES (?, ?, ?, ?, ?)`,
      [selectedUserTypeId, fullName, email, phoneNumber, passwordHash],
    );

    const [createdRows] = await connection.query(
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
      [result.insertId],
    );

    const user = publicUser(createdRows[0]);

    res.status(201).json({
      message: 'Registrasi berhasil',
      token: createToken(user),
      user,
    });
  } catch (error) {
    next(error);
  } finally {
    connection.release();
  }
}

async function login(req, res, next) {
  try {
    const email = cleanText(req.body.email).toLowerCase();
    const password = cleanText(req.body.password);

    if (!email || !password) {
      throw new HttpError(400, 'Email dan password wajib diisi');
    }

    if (!isValidEmail(email)) {
      throw new HttpError(400, 'Format email tidak valid');
    }

    const [rows] = await pool.query(
      `SELECT
        u.user_id,
        u.user_type_id,
        ut.type_name AS user_type,
        u.full_name,
        u.email,
        u.phone_number,
        u.password_hash,
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
      WHERE u.email = ?
      LIMIT 1`,
      [email],
    );

    if (rows.length === 0) {
      throw new HttpError(401, 'Email atau password salah');
    }

    const userRow = rows[0];

    if (userRow.account_status !== 'ACTIVE') {
      throw new HttpError(403, 'Akun tidak aktif');
    }

    const passwordMatches = await bcrypt.compare(password, userRow.password_hash);

    if (!passwordMatches) {
      throw new HttpError(401, 'Email atau password salah');
    }

    const user = publicUser(userRow);

    res.json({
      message: 'Login berhasil',
      token: createToken(user),
      user,
    });
  } catch (error) {
    next(error);
  }
}

async function me(req, res) {
  res.json({
    user: publicUser(req.user),
  });
}

module.exports = {
  getUserTypes,
  register,
  login,
  me,
};
