const fs = require('fs');
const path = require('path');
const multer = require('multer');
const HttpError = require('./httpError');

const uploadBaseDir = process.env.VERCEL === '1'
  ? path.join('/tmp', 'uploads')
  : path.join(__dirname, '..', '..', 'uploads');

const uploadDir = path.join(uploadBaseDir, 'products');
fs.mkdirSync(uploadDir, { recursive: true });

const avatarDir = path.join(uploadBaseDir, 'avatars');
fs.mkdirSync(avatarDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const ext = (path.extname(file.originalname) || '.jpg').toLowerCase();
    const name = `p_${Date.now()}_${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, name);
  },
});

const avatarStorage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, avatarDir),
  filename: (req, file, cb) => {
    const ext = (path.extname(file.originalname) || '.jpg').toLowerCase();
    const name = `a_${Date.now()}_${Math.round(Math.random() * 1e9)}${ext}`;
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

// Foto profil: 1 file, <= 5MB.
const uploadAvatars = multer({
  storage: avatarStorage,
  fileFilter: imageFilter,
  limits: { fileSize: 5 * 1024 * 1024, files: 1 },
});

module.exports = { uploadProducts, uploadAvatars, uploadDir, avatarDir };
