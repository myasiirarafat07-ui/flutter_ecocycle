const mysql = require('mysql2/promise');

async function test() {
  try {
    const pool = mysql.createPool({
      host: 'gateway01.ap-southeast-1.prod.aws.tidbcloud.com',
      port: 4000,
      user: 'KpDsLYFuGm5Z4eN.root',
      password: 'wWC9gh02qar4eHXT',
      database: 'ecocycle_db',
      ssl: {
        minVersion: 'TLSv1.2',
        rejectUnauthorized: true
      }
    });
    
    console.log("Fetching products...");
    const [rows] = await pool.query('SELECT product_id, LENGTH(image_url) as size FROM products');
    console.log("Products:", rows);
    
    const [images] = await pool.query('SELECT product_id, LENGTH(image_path) as size FROM product_images');
    console.log("Images:", images);
    
    pool.end();
  } catch (err) {
    console.error("Failed:", err);
  }
}

test();
