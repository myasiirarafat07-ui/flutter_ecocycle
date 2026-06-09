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
const { uploadAvatars } = require('../utils/upload');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/verify-otp', verifyOtp);
router.post('/reset-password', resetPassword);
router.get('/me', authenticate, me);
router.put('/me', authenticate, updateMe);
router.put('/me/photo', authenticate, uploadAvatars.single('photo'), updatePhoto);

module.exports = router;
