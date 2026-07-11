require('dotenv').config({ quiet: true });

const path = require('path');
const cors = require('cors');
const express = require('express');
const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const wishlistRoutes = require('./routes/wishlistRoutes');
const paymentMethodRoutes = require('./routes/paymentMethodRoutes');
const pointRoutes = require('./routes/pointRoutes');

const app = express();

app.use(cors());
app.use(express.json({ limit: '5mb' })); // ruang untuk foto profil base64

const uploadPath = process.env.VERCEL === '1' 
  ? path.join('/tmp', 'uploads') 
  : path.join(__dirname, '..', 'uploads');
app.use('/uploads', express.static(uploadPath));

app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    service: 'ecocycle-api',
    message: 'EcoCycle API is running',
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'ecocycle-api',
  });
});

app.get('/api/testdb', async (req, res) => {
  const { pool } = require('./config/db');
  try {
    const [rows] = await pool.query('SELECT 1 + 1 AS solution');
    res.json({ message: 'DB Connected', result: rows });
  } catch (err) {
    res.status(500).json({ error: err.message, code: err.code });
  }
});

app.get('/api/seed', async (req, res) => {
  const { seedRequiredData } = require('./config/seed');
  try {
    await seedRequiredData();
    res.json({ message: 'Seeded successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/alter', async (req, res) => {
  const { pool } = require('./config/db');
  try {
    await pool.query('ALTER TABLE product_images MODIFY COLUMN image_path MEDIUMTEXT NOT NULL');
    await pool.query('ALTER TABLE products MODIFY COLUMN image_url MEDIUMTEXT NULL');
    res.json({ message: 'Altered successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message, sqlMessage: error.sqlMessage });
  }
});

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/wishlist', wishlistRoutes);
app.use('/api/payment-methods', paymentMethodRoutes);
app.use('/api/points', pointRoutes);

app.use((req, res) => {
  res.status(404).json({
    message: 'Endpoint tidak ditemukan',
  });
});

app.use((error, req, res, next) => {
  console.error(error);
  // Error multer (ukuran/jumlah file) → 400 dengan pesan ramah.
  if (error && error.name === 'MulterError') {
    const msg =
      error.code === 'LIMIT_FILE_SIZE'
        ? 'Ukuran gambar maksimal 5MB'
        : error.code === 'LIMIT_FILE_COUNT' || error.code === 'LIMIT_UNEXPECTED_FILE'
          ? 'Maksimal 5 gambar per produk'
          : 'Gagal mengunggah gambar';
    return res.status(400).json({ message: msg });
  }
  res.status(error.statusCode || 500).json({
    message: error.message || 'Terjadi kesalahan pada server',
  });
});

module.exports = app;
