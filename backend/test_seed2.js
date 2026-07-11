process.env.DB_HOST = 'gateway01.ap-southeast-1.prod.aws.tidbcloud.com';
process.env.DB_PORT = '4000';
process.env.DB_USER = 'KpDsLYFuGm5Z4eN.root';
process.env.DB_PASSWORD = 'wWC9gh02qar4eHXT';
process.env.DB_NAME = 'ecocycle_db';

const { seedRequiredData } = require('./src/config/seed');
const { pool } = require('./src/config/db');

async function test() {
  try {
    console.log("Testing full seed against TiDB...");
    await seedRequiredData();
    console.log("Success!");
    pool.end();
  } catch (err) {
    console.error("Failed:", err);
    pool.end();
  }
}

test();
