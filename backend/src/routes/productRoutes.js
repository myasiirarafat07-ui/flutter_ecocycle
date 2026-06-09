const express = require('express');
const {
  listProducts,
  getMyProducts,
  getProduct,
  createProduct,
  updateProduct,
  deleteProduct,
  uploadProductImages,
} = require('../controllers/productController');
const { listReviews, createReview } = require('../controllers/reviewController');
const authenticate = require('../middleware/authMiddleware');
const optionalAuth = require('../middleware/optionalAuthMiddleware');
const { uploadProducts } = require('../utils/upload');

const router = express.Router();

// Publik (optional-auth agar tahu produk milik si pengakses → is_mine)
router.get('/', optionalAuth, listProducts);
// Penjual (harus sebelum '/:id' agar 'mine' tidak tertangkap sebagai id)
router.get('/mine', authenticate, getMyProducts);
router.get('/:id', optionalAuth, getProduct);
router.get('/:id/reviews', listReviews);

// Butuh login
router.post(
  '/images',
  authenticate,
  uploadProducts.array('images', 5),
  uploadProductImages,
);
router.post('/', authenticate, createProduct);
router.put('/:id', authenticate, updateProduct);
router.delete('/:id', authenticate, deleteProduct);
router.post('/:id/reviews', authenticate, createReview);

module.exports = router;
