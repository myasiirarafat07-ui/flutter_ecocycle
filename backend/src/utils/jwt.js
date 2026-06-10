const jwt = require('jsonwebtoken');

// Secret default HANYA untuk pengembangan. Di produksi wajib di-override lewat
// JWT_SECRET (lihat assertJwtSecret di server.js yang menggagalkan start bila
// secret masih default).
const DEV_SECRET = 'dev_ecocycle_secret';

function jwtSecret() {
  return process.env.JWT_SECRET || DEV_SECRET;
}

function createToken(user) {
  return jwt.sign(
    {
      user_id: user.user_id,
      email: user.email,
    },
    jwtSecret(),
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    },
  );
}

function verifyToken(token) {
  return jwt.verify(token, jwtSecret());
}

// Token singkat khusus untuk mengizinkan reset kata sandi setelah OTP terverifikasi.
function createResetToken(user) {
  return jwt.sign(
    {
      user_id: user.user_id,
      email: user.email,
      purpose: 'password_reset',
    },
    jwtSecret(),
    {
      expiresIn: '15m',
    },
  );
}

module.exports = {
  createToken,
  verifyToken,
  createResetToken,
  DEV_SECRET,
};
