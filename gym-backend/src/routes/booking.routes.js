const express = require('express');
const router = express.Router();
const {
  createBooking,
  getMyBookings,
  getBookingsBySlot,
  cancelBooking,
  cancelBookingPatch,
} = require('../controllers/booking.controller');
const { authMiddleware, requireRole } = require('../middleware/auth.middleware');

// IMPORTANT: /my and /slot/:slotId must come BEFORE /:id
// Otherwise Express matches "my" as the :id parameter

// Member routes (auth required)
router.get('/my', authMiddleware, getMyBookings);
router.post('/', authMiddleware, createBooking);
router.delete('/:id', authMiddleware, cancelBooking);
router.patch('/:id/cancel', authMiddleware, cancelBookingPatch);

// Admin routes
router.get('/slot/:slotId', authMiddleware, requireRole('admin'), getBookingsBySlot);

module.exports = router;
