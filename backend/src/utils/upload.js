const fs = require('fs');
const path = require('path');
const multer = require('multer');
const HttpError = require('./httpError');

// Folder penyimpanan gambar produk: backend/uploads/products.
const uploadDir = path.join(__dirname, '..', '..', 'uploads', 'products');
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const ext = (path.extname(file.originalname) || '.jpg').toLowerCase();
    const name = `p_${Date.now()}_${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, name);
  },
});

function imageFilter(req, file, cb) {
  if (/^image\//.test(file.mimetype)) return cb(null, true);
  cb(new HttpError(400, 'Hanya file gambar yang diperbolehkan'));
}

// Maks 5 file, masing-masing <= 5MB.
const uploadProducts = multer({
  storage,
  fileFilter: imageFilter,
  limits: { fileSize: 5 * 1024 * 1024, files: 5 },
});

module.exports = { uploadProducts, uploadDir };
