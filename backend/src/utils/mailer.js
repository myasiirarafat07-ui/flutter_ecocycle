const nodemailer = require('nodemailer');

let cachedTransporter = null;

function isConfigured() {
  return Boolean(process.env.SMTP_USER && process.env.SMTP_PASS);
}

function getTransporter() {
  if (cachedTransporter) {
    return cachedTransporter;
  }

  cachedTransporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: Number(process.env.SMTP_PORT || 587),
    secure: Number(process.env.SMTP_PORT || 587) === 465,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  return cachedTransporter;
}

/**
 * Mengirim kode OTP reset kata sandi ke email pengguna.
 * Selalu mencetak OTP ke console agar mudah diuji tanpa membuka inbox.
 * Mengembalikan `true` bila email benar-benar terkirim, `false` bila layanan
 * email belum dikonfigurasi (mode dev — pemanggil akan menampilkan OTP langsung).
 */
async function sendOtpEmail(to, otp, fullName) {
  console.log(`[OTP] Kode reset untuk ${to}: ${otp}`);

  if (!isConfigured()) {
    console.warn(
      '[OTP] SMTP belum dikonfigurasi — kode OTP dikembalikan untuk mode dev. ' +
        'Isi SMTP_USER & SMTP_PASS di backend/.env untuk mengirim email asli.',
    );
    return false;
  }

  const minutes = Number(process.env.OTP_EXPIRES_MINUTES || 10);
  const name = fullName || 'Sahabat EcoCycle';

  await getTransporter().sendMail({
    from: process.env.SMTP_FROM || process.env.SMTP_USER,
    to,
    subject: 'Kode Reset Kata Sandi EcoCycle',
    text:
      `Halo ${name},\n\n` +
      `Kode OTP untuk reset kata sandi akun EcoCycle kamu adalah: ${otp}\n` +
      `Kode ini berlaku selama ${minutes} menit.\n\n` +
      `Jika kamu tidak meminta reset kata sandi, abaikan email ini.\n\n` +
      `Salam,\nTim EcoCycle`,
    html:
      `<div style="font-family:Arial,sans-serif;color:#0F172A">` +
      `<p>Halo <b>${name}</b>,</p>` +
      `<p>Kode OTP untuk reset kata sandi akun EcoCycle kamu adalah:</p>` +
      `<p style="font-size:28px;font-weight:bold;letter-spacing:6px;color:#22C55E">${otp}</p>` +
      `<p>Kode ini berlaku selama <b>${minutes} menit</b>.</p>` +
      `<p style="color:#475569">Jika kamu tidak meminta reset kata sandi, abaikan email ini.</p>` +
      `<p>Salam,<br/>Tim EcoCycle</p>` +
      `</div>`,
  });

  return true;
}

module.exports = {
  sendOtpEmail,
  isConfigured,
};
