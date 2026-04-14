const express = require('express');
const router = express.Router();
const { getStats, getAllUsers, getAllAdmins, addAdmin, removeAdmin } = require('../controllers/admin.controller');
const { authMiddleware, requireRole } = require('../middleware/auth.middleware');

// All routes require JWT + admin role
router.use(authMiddleware, requireRole('admin'));

router.get('/stats',         getStats);
router.get('/users',         getAllUsers);
router.get('/admins',        getAllAdmins);
router.post('/admins',       addAdmin);
router.delete('/admins/:id', removeAdmin);

module.exports = router;
