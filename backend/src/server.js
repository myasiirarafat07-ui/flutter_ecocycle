const app = require('./app');
const { testConnection } = require('./config/db');
const { seedRequiredData } = require('./config/seed');
const { DEV_SECRET } = require('./utils/jwt');

const port = Number(process.env.PORT || 3000);
const isProduction = process.env.NODE_ENV === 'production';

// Cegah berjalan di produksi dengan secret JWT default/lemah.
function assertJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (isProduction) {
    if (!secret || secret === DEV_SECRET || secret.length < 16) {
      throw new Error(
        'JWT_SECRET produksi belum diatur dengan aman. Set JWT_SECRET yang kuat (minimal 16 karakter) di .env.',
      );
    }
  } else if (!secret) {
    console.warn(
      '[PERINGATAN] JWT_SECRET belum diatur — memakai secret default DEV. Jangan dipakai di produksi.',
    );
  }
}

async function startServer() {
  try {
    assertJwtSecret();
    await testConnection();
    await seedRequiredData();

    app.listen(port, () => {
      console.log(`EcoCycle API running on http://localhost:${port}`);
    });
  } catch (error) {
    console.error('Failed to start EcoCycle API:', error.message);
    process.exit(1);
  }
}

startServer();
