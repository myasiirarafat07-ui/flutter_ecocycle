const HttpError = require('../utils/httpError');

// Rate-limiter sederhana berbasis memori (tanpa dependency eksternal).
// Cocok untuk satu instance server (skala proyek ini). Untuk multi-instance,
// gunakan store bersama (mis. Redis).
//
// Membatasi jumlah percobaan per kunci (default: IP) dalam jendela waktu.
// Dipakai untuk endpoint sensitif: login, forgot-password, verify-otp.
function rateLimit({ windowMs = 15 * 60 * 1000, max = 10, keyGenerator } = {}) {
  const hits = new Map(); // key -> { count, resetAt }

  // Bersihkan entri kedaluwarsa sesekali agar Map tidak tumbuh tanpa batas.
  function sweep(now) {
    for (const [key, entry] of hits) {
      if (entry.resetAt <= now) hits.delete(key);
    }
  }

  return function rateLimiter(req, res, next) {
    const now = Date.now();
    if (hits.size > 5000) sweep(now);

    const key = keyGenerator
      ? keyGenerator(req)
      : req.ip || req.socket?.remoteAddress || 'unknown';

    let entry = hits.get(key);
    if (!entry || entry.resetAt <= now) {
      entry = { count: 0, resetAt: now + windowMs };
      hits.set(key, entry);
    }

    entry.count += 1;

    if (entry.count > max) {
      const retryMs = Math.max(0, entry.resetAt - now);
      const retrySec = Math.ceil(retryMs / 1000);
      res.set('Retry-After', String(retrySec));
      return next(
        new HttpError(
          429,
          `Terlalu banyak percobaan. Coba lagi dalam ${Math.ceil(retrySec / 60)} menit.`,
        ),
      );
    }

    next();
  };
}

module.exports = rateLimit;
