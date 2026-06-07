const express = require('express');
const {
  createOrder,
  listMyOrders,
  listMySales,
  getOrder,
} = require('../controllers/orderController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authenticate);

router.post('/', createOrder);
router.get('/', listMyOrders);
router.get('/sales', listMySales);
router.get('/:id', getOrder);

module.exports = router;
