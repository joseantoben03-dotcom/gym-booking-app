const express = require('express');
const router = express.Router();
const {
  getSlots,
  getSlotById,
  createSlot,
  updateSlot,
  deleteSlot,
} = require('../controllers/slot.controller');
const { authMiddleware, requireRole } = require('../middleware/auth.middleware');

// Public / Member routes
router.get('/', getSlots);
router.get('/:id', getSlotById);

// Admin only routes
router.post('/', authMiddleware, requireRole('admin'), createSlot);
router.put('/:id', authMiddleware, requireRole('admin'), updateSlot);
router.delete('/:id', authMiddleware, requireRole('admin'), deleteSlot);

module.exports = router;
