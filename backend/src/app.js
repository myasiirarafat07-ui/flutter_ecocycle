require('dotenv').config({ quiet: true });

const cors = require('cors');
const express = require('express');
const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const notificationRoutes = require('./routes/notificationRoutes');

const app = express();

app.use(cors());
app.use(express.json());

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

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/notifications', notificationRoutes);

app.use((req, res) => {
  res.status(404).json({
    message: 'Endpoint tidak ditemukan',
  });
});

app.use((error, req, res, next) => {
  console.error(error);
  res.status(error.statusCode || 500).json({
    message: error.message || 'Terjadi kesalahan pada server',
  });
});

module.exports = app;
