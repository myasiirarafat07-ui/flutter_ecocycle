const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'gateway01.ap-southeast-1.prod.aws.tidbcloud.com',
  port: 4000,
  user: 'KpDsLYFuGm5Z4eN.root',
  password: 'wWC9gh02qar4eHXT',
  database: 'ecocycle_db',
  waitForConnections: true,
  connectionLimit: 1,
  queueLimit: 0,
  ssl: {
    minVersion: 'TLSv1.2',
    rejectUnauthorized: true
  }
});

async function ensureColumn(table, column, definition) {
  const [rows] = await pool.query(
    `SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
      LIMIT 1`,
    [table, column],
  );
  if (rows.length === 0) {
    await pool.query(`ALTER TABLE \`${table}\` ADD COLUMN ${definition}`);
  }
}

async function test() {
  try {
    console.log("Testing seed...");
    await ensureColumn(
      'products',
      'waste_kg',
      'waste_kg DECIMAL(10,2) NOT NULL DEFAULT 0',
    );
    console.log("Success!");
    pool.end();
  } catch (err) {
    console.error("Failed:", err);
  }
}

test();
