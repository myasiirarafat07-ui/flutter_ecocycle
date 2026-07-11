const mysql = require('mysql2/promise');

async function test() {
  try {
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
    console.log("Connecting...");
    const conn = await pool.getConnection();
    console.log("Connected!");
    const [rows] = await pool.query('SELECT 1 as val');
    console.log("Query success:", rows);
    conn.release();
    pool.end();
  } catch (err) {
    console.error("Connection failed:", err);
  }
}

test();
