const app = require('./app');
const { testConnection } = require('./config/db');
const { seedRequiredData } = require('./config/seed');

const port = Number(process.env.PORT || 3000);

async function startServer() {
  try {
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
