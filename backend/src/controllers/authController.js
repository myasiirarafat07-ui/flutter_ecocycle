const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const { pool } = require('../config/db');
const HttpError = require('../utils/httpError');
const { createToken, createResetToken, verifyToken } = require('../utils/jwt');
const { sendOtpEmail } = require('../utils/mailer');

function cleanText(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function publicUser(row) {
  return {
    user_id: row.user_id,
    full_name: row.full_name,
    email: row.email,
    phone_number: row.phone_number,
    address: row.address,
    latitude: row.latitude != null ? Number(row.latitude) : null,
    longitude: row.longitude != null ? Number(row.longitude) : null,
    profile_photo: row.profile_photo || null,
    eco_points: row.eco_points,
    total_waste_kg: Number(row.total_waste_kg),
    green_transactions: row.green_transactions,
    co2_offset_kg: Number(row.co2_offset_kg),
    created_at: row.created_at,
  };
}

async function register(req, res, next) {
  const connection = await pool.getConnection();

  try {
    const fullName = cleanText(req.body.full_name || req.body.name);
    const email = cleanText(req.body.email).toLowerCase();
    const phoneNumber = cleanText(req.body.phone_number || req.body.phone) || null;
    const password = cleanText(req.body.password);

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

    const passwordHash = await bcrypt.hash(password, 10);

    const [result] = await connection.query(
      `INSERT INTO users
        (full_name, email, phone_number, password_hash)
      VALUES (?, ?, ?, ?)`,
      [fullName, email, phoneNumber, passwordHash],
    );

    const [createdRows] = await connection.query(
      `SELECT
        u.user_id,
        u.full_name,
        u.email,
        u.phone_number,
        u.address,
        u.latitude,
        u.longitude,
        u.profile_photo,
        u.eco_points,
        u.total_waste_kg,
        u.green_transactions,
        u.co2_offset_kg,
        u.created_at
      FROM users u
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
        u.full_name,
        u.email,
        u.phone_number,
        u.password_hash,
        u.address,
        u.latitude,
        u.longitude,
        u.profile_photo,
        u.eco_points,
        u.total_waste_kg,
        u.green_transactions,
        u.co2_offset_kg,
        u.created_at
      FROM users u
      WHERE u.email = ?
      LIMIT 1`,
      [email],
    );

    if (rows.length === 0) {
      throw new HttpError(401, 'Email atau password salah');
    }

    const userRow = rows[0];

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

async function updateMe(req, res, next) {
  try {
    const userId = req.user.user_id;
    const fullName = cleanText(req.body.full_name || req.body.name);
    const email = cleanText(req.body.email).toLowerCase();
    const phoneNumber = cleanText(req.body.phone_number || req.body.phone) || null;
    const address = cleanText(req.body.address) || null;

    // Lokasi (opsional) — dipakai menghitung ongkir berbasis jarak.
    const hasLatitude = req.body.latitude !== undefined && req.body.latitude !== null;
    const hasLongitude = req.body.longitude !== undefined && req.body.longitude !== null;
    let latitude = null;
    let longitude = null;
    if (hasLatitude || hasLongitude) {
      latitude = Number(req.body.latitude);
      longitude = Number(req.body.longitude);
      if (
        !Number.isFinite(latitude) ||
        !Number.isFinite(longitude) ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180
      ) {
        throw new HttpError(400, 'Koordinat lokasi tidak valid');
      }
    }

    if (!fullName || fullName.length < 3) {
      throw new HttpError(400, 'Nama minimal 3 karakter');
    }

    if (!isValidEmail(email)) {
      throw new HttpError(400, 'Format email tidak valid');
    }

    const [emailOwners] = await pool.query(
      'SELECT user_id FROM users WHERE email = ? AND user_id <> ? LIMIT 1',
      [email, userId],
    );

    if (emailOwners.length > 0) {
      throw new HttpError(409, 'Email sudah digunakan akun lain');
    }

    // Update lokasi hanya bila dikirim, agar update profil biasa tidak menghapusnya.
    if (hasLatitude || hasLongitude) {
      await pool.query(
        `UPDATE users
          SET full_name = ?, email = ?, phone_number = ?, address = ?, latitude = ?, longitude = ?
        WHERE user_id = ?`,
        [fullName, email, phoneNumber, address, latitude, longitude, userId],
      );
    } else {
      await pool.query(
        `UPDATE users
          SET full_name = ?, email = ?, phone_number = ?, address = ?
        WHERE user_id = ?`,
        [fullName, email, phoneNumber, address, userId],
      );
    }

    const [rows] = await pool.query(
      `SELECT
        user_id, full_name, email, phone_number, address, latitude, longitude,
        profile_photo, eco_points, total_waste_kg, green_transactions,
        co2_offset_kg, created_at
      FROM users WHERE user_id = ?`,
      [userId],
    );

    res.json({
      message: 'Profil diperbarui',
      user: publicUser(rows[0]),
    });
  } catch (error) {
    next(error);
  }
}

// Memperbarui hanya foto profil (base64 / data-URL). Kirim string kosong/null
// untuk menghapus foto. Endpoint terpisah agar update teks tidak ikut membawa
// payload base64 besar.
async function updatePhoto(req, res, next) {
  try {
    const userId = req.user.user_id;
    const raw = req.body.profile_photo;

    let photo = null;
    if (raw !== undefined && raw !== null && raw !== '') {
      if (typeof raw !== 'string') {
        throw new HttpError(400, 'Format foto tidak valid');
      }
      // ~4MB batas aman (base64 lebih besar ~33% dari biner asli).
      if (raw.length > 4 * 1024 * 1024) {
        throw new HttpError(400, 'Ukuran foto terlalu besar');
      }
      photo = raw;
    }

    await pool.query('UPDATE users SET profile_photo = ? WHERE user_id = ?', [
      photo,
      userId,
    ]);

    const [rows] = await pool.query(
      `SELECT
        user_id, full_name, email, phone_number, address, latitude, longitude,
        profile_photo, eco_points, total_waste_kg, green_transactions,
        co2_offset_kg, created_at
      FROM users WHERE user_id = ?`,
      [userId],
    );

    res.json({
      message: photo ? 'Foto profil diperbarui' : 'Foto profil dihapus',
      user: publicUser(rows[0]),
    });
  } catch (error) {
    next(error);
  }
}

// Langkah 1: verifikasi email + nomor HP, kirim OTP ke email.
async function forgotPassword(req, res, next) {
  try {
    const email = cleanText(req.body.email).toLowerCase();
    const phoneNumber = cleanText(req.body.phone_number || req.body.phone);

    if (!email || !phoneNumber) {
      throw new HttpError(400, 'Email dan nomor HP wajib diisi');
    }

    if (!isValidEmail(email)) {
      throw new HttpError(400, 'Format email tidak valid');
    }

    const [rows] = await pool.query(
      'SELECT user_id, full_name, email, phone_number FROM users WHERE email = ? LIMIT 1',
      [email],
    );

    const user = rows[0];

    if (!user || cleanText(user.phone_number) !== phoneNumber) {
      throw new HttpError(404, 'Email atau nomor HP tidak cocok dengan akun mana pun');
    }

    const otp = String(crypto.randomInt(100000, 1000000));
    const otpHash = await bcrypt.hash(otp, 10);
    const minutes = Number(process.env.OTP_EXPIRES_MINUTES || 10);

    // Batalkan OTP lama yang belum dipakai, lalu simpan yang baru.
    await pool.query(
      'UPDATE password_resets SET consumed = TRUE WHERE user_id = ? AND consumed = FALSE',
      [user.user_id],
    );

    await pool.query(
      `INSERT INTO password_resets (user_id, otp_hash, expires_at)
       VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? MINUTE))`,
      [user.user_id, otpHash, minutes],
    );

    const emailSent = await sendOtpEmail(user.email, otp, user.full_name);

    if (emailSent) {
      res.json({ message: 'Kode OTP telah dikirim ke email Anda' });
    } else {
      // Mode dev: SMTP belum dikonfigurasi, kirim OTP langsung agar tetap bisa diuji.
      res.json({
        message: 'Email belum dikonfigurasi — kode OTP ditampilkan untuk pengujian',
        dev_otp: otp,
      });
    }
  } catch (error) {
    next(error);
  }
}

// Langkah 2: verifikasi OTP, balas reset token bila valid.
async function verifyOtp(req, res, next) {
  try {
    const email = cleanText(req.body.email).toLowerCase();
    const otp = cleanText(req.body.otp);

    if (!email || !otp) {
      throw new HttpError(400, 'Email dan kode OTP wajib diisi');
    }

    const [rows] = await pool.query(
      `SELECT pr.reset_id, pr.otp_hash, u.user_id, u.email
         FROM password_resets pr
         JOIN users u ON u.user_id = pr.user_id
        WHERE u.email = ? AND pr.consumed = FALSE AND pr.expires_at > NOW()
        ORDER BY pr.reset_id DESC
        LIMIT 1`,
      [email],
    );

    const resetRow = rows[0];

    if (!resetRow) {
      throw new HttpError(400, 'Kode OTP salah atau sudah kedaluwarsa');
    }

    const otpMatches = await bcrypt.compare(otp, resetRow.otp_hash);

    if (!otpMatches) {
      throw new HttpError(400, 'Kode OTP salah atau sudah kedaluwarsa');
    }

    res.json({
      message: 'Kode OTP terverifikasi',
      resetToken: createResetToken({
        user_id: resetRow.user_id,
        email: resetRow.email,
      }),
    });
  } catch (error) {
    next(error);
  }
}

// Langkah 3: verifikasi reset token, perbarui kata sandi.
async function resetPassword(req, res, next) {
  try {
    const resetToken = cleanText(req.body.resetToken || req.body.reset_token);
    const newPassword = cleanText(req.body.new_password || req.body.password);

    if (!resetToken || !newPassword) {
      throw new HttpError(400, 'Token dan kata sandi baru wajib diisi');
    }

    if (newPassword.length < 6) {
      throw new HttpError(400, 'Password minimal 6 karakter');
    }

    let payload;
    try {
      payload = verifyToken(resetToken);
    } catch (_) {
      throw new HttpError(401, 'Sesi reset tidak valid atau sudah kedaluwarsa');
    }

    if (payload.purpose !== 'password_reset') {
      throw new HttpError(401, 'Token reset tidak valid');
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);

    await pool.query('UPDATE users SET password_hash = ? WHERE user_id = ?', [
      passwordHash,
      payload.user_id,
    ]);

    // Pastikan semua OTP user dianggap terpakai setelah reset berhasil.
    await pool.query(
      'UPDATE password_resets SET consumed = TRUE WHERE user_id = ?',
      [payload.user_id],
    );

    res.json({ message: 'Kata sandi berhasil diperbarui' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  register,
  login,
  me,
  updateMe,
  updatePhoto,
  forgotPassword,
  verifyOtp,
  resetPassword,
};
