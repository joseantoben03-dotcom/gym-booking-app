const express = require('express');
const router = express.Router();
const { register, registerAdmin, login, getMe } = require('../controllers/auth.controller');
const { authMiddleware } = require('../middleware/auth.middleware');

router.post('/register', register);
router.post('/register-admin', registerAdmin); // protected by setupKey in request body
router.post('/login', login);
router.get('/me', authMiddleware, getMe);

module.exports = router;
