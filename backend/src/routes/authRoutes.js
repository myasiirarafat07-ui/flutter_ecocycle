const express = require('express');
const {
  register,
  login,
  me,
  updateMe,
  updatePhoto,
  forgotPassword,
  verifyOtp,
  resetPassword,
} = require('../controllers/authController');
const authenticate = require('../middleware/authMiddleware');
const rateLimit = require('../middleware/rateLimit');
const { uploadAvatars } = require('../utils/upload');

const router = express.Router();

// Batasi percobaan pada endpoint sensitif (anti brute-force OTP/login).
const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 10 });

router.post('/register', register);
router.post('/login', authLimiter, login);
router.post('/forgot-password', authLimiter, forgotPassword);
router.post('/verify-otp', authLimiter, verifyOtp);
router.post('/reset-password', resetPassword);
router.get('/me', authenticate, me);
router.put('/me', authenticate, updateMe);
router.put('/me/photo', authenticate, uploadAvatars.single('photo'), updatePhoto);

module.exports = router;
