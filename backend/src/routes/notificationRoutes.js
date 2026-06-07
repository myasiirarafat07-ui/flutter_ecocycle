const express = require('express');
const {
  listNotifications,
  markRead,
  markAllRead,
} = require('../controllers/notificationController');
const authenticate = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authenticate);

router.get('/', listNotifications);
router.put('/read-all', markAllRead);
router.put('/:id/read', markRead);

module.exports = router;
