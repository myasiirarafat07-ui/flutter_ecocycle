const express = require('express');
const {
  getUserTypes,
  register,
  login,
  me,
} = require('../controllers/authController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/user-types', getUserTypes);
router.post('/register', register);
router.post('/login', login);
router.get('/me', authenticate, me);

module.exports = router;
