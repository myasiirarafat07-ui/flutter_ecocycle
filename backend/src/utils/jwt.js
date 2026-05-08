const jwt = require('jsonwebtoken');

function createToken(user) {
  return jwt.sign(
    {
      user_id: user.user_id,
      email: user.email,
    },
    process.env.JWT_SECRET || 'dev_ecocycle_secret',
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    },
  );
}

function verifyToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET || 'dev_ecocycle_secret');
}

module.exports = {
  createToken,
  verifyToken,
};
