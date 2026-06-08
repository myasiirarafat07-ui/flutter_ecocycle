const express = require('express');
const { getPoints } = require('../controllers/pointController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authenticate);

router.get('/', getPoints);

module.exports = router;
