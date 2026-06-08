const express = require('express');
const {
  getMethods,
  createMethod,
  deleteMethod,
  clearMethods,
  setDefaultMethod,
} = require('../controllers/paymentMethodController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authenticate);

router.get('/', getMethods);
router.post('/', createMethod);
router.delete('/', clearMethods);
router.delete('/:id', deleteMethod);
router.put('/:id/default', setDefaultMethod);

module.exports = router;
