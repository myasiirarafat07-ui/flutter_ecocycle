require('dotenv').config({ path: __dirname + '/.env', quiet: true });
const { pool } = require('./src/config/db');
(async () => {
  try {
    const [fks] = await pool.query(
      `SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME
       FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
       WHERE TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME = 'user_types'`);
    console.log('FK refs to user_types =>', JSON.stringify(fks));
    const [cnt] = await pool.query('SELECT COUNT(*) n FROM users');
    console.log('users rows =>', cnt[0].n);
  } catch (e) { console.error('ERR', e.message); }
  finally { process.exit(0); }
})();
