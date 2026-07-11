const mysql = require('mysql2/promise');

let poolConfig;

if (process.env.DB_HOST && process.env.DB_HOST.startsWith('mysql://')) {
  // Jika user memasukkan URI utuh ke DB_HOST (misal mysql://user:pass@host/db)
  const uri = new URL(process.env.DB_HOST);
  poolConfig = {
    host: uri.hostname,
    port: Number(uri.port) || 4000,
    user: decodeURIComponent(uri.username || ''),
    password: decodeURIComponent(uri.password || ''),
    database: uri.pathname.replace('/', '') || process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    ssl: {
      minVersion: 'TLSv1.2',
      rejectUnauthorized: true
    }
  };
} else {
  poolConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ecocycle_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    ssl: {
      minVersion: 'TLSv1.2',
      rejectUnauthorized: true
    }
  };
}

const pool = mysql.createPool(poolConfig);

pool.on('error', (err) => {
  console.error('Unexpected DB error:', err);
});

async function testConnection() {
  const connection = await pool.getConnection();
  connection.release();
}

module.exports = {
  pool,
  testConnection,
};
