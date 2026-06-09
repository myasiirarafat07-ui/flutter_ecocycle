const express = require('express');
const {
  createOrder,
  listMyOrders,
  listMySales,
  getOrder,
  shipOrder,
  confirmPayment,
  completeOrder,
} = require('../controllers/orderController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authenticate);

router.post('/', createOrder);
router.get('/', listMyOrders);
router.get('/sales', listMySales);
router.get('/:id', getOrder);
router.put('/:id/ship', shipOrder);
router.put('/:id/confirm-payment', confirmPayment);
router.put('/:id/complete', completeOrder);

module.exports = router;
