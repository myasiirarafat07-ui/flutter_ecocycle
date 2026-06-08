const express = require('express');
const {
  register,
  login,
  me,
  updateMe,
  forgotPassword,
  verifyOtp,
  resetPassword,
} = require('../controllers/authController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOtp);
router.post('/reset-password', resetPassword);
router.get('/me', authenticate, me);
router.put('/me', authenticate, updateMe);

module.exports = router;
