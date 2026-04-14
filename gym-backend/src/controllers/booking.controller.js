const Booking = require('../models/Booking');
const Slot = require('../models/Slot');
const { sendSuccess, sendError } = require('../utils/response');

// POST /api/bookings
const createBooking = async (req, res) => {
  try {
    const { slotId } = req.body;
    const userId = req.user._id;

    if (!slotId) return sendError(res, 'slotId is required.', 400);

    const slot = await Slot.findById(slotId);
    if (!slot) return sendError(res, 'Slot not found.', 404);

    if (slot.bookedCount >= slot.capacity) {
      return sendError(res, 'This slot is fully booked.', 400);
    }

    // Check for duplicate booking
    const existingBooking = await Booking.findOne({ user: userId, slot: slotId });
    if (existingBooking) {
      if (existingBooking.status === 'booked') {
        return sendError(res, 'You have already booked this slot.', 409);
      }
      // Re-activate cancelled booking
      existingBooking.status = 'booked';
      await existingBooking.save();
      await Slot.findByIdAndUpdate(slotId, { $inc: { bookedCount: 1 } });
      const populated = await existingBooking.populate('slot');
      return sendSuccess(res, { booking: populated }, 'Slot re-booked successfully.', 201);
    }

    const booking = await Booking.create({ user: userId, slot: slotId });
    await Slot.findByIdAndUpdate(slotId, { $inc: { bookedCount: 1 } });

    const populated = await booking.populate('slot');
    return sendSuccess(res, { booking: populated }, 'Slot booked successfully.', 201);
  } catch (error) {
    console.error('createBooking error:', error);
    if (error.code === 11000) {
      return sendError(res, 'You have already booked this slot.', 409);
    }
    return sendError(res, 'Failed to create booking.', 500);
  }
};

// GET /api/bookings/my
const getMyBookings = async (req, res) => {
  try {
    const userId = req.user._id;
    const now = new Date();

    const bookings = await Booking.find({ user: userId, status: 'booked' })
      .populate('slot')
      .sort({ createdAt: -1 });

    const upcoming = [];
    const past = [];

    bookings.forEach((b) => {
      if (!b.slot) return;
      const slotDate = new Date(b.slot.date);
      const [hours, minutes] = b.slot.startTime.split(':').map(Number);
      slotDate.setUTCHours(hours, minutes, 0, 0);

      if (slotDate >= now) {
        upcoming.push(b);
      } else {
        past.push(b);
      }
    });

    return sendSuccess(res, { upcoming, past }, 'Bookings fetched.');
  } catch (error) {
    console.error('getMyBookings error:', error);
    return sendError(res, 'Failed to fetch bookings.', 500);
  }
};

// GET /api/bookings/slot/:slotId  (admin)
const getBookingsBySlot = async (req, res) => {
  try {
    const { slotId } = req.params;
    const bookings = await Booking.find({ slot: slotId, status: 'booked' })
      .populate('user', 'name email')
      .populate('slot');

    return sendSuccess(res, { bookings }, 'Slot bookings fetched.');
  } catch (error) {
    console.error('getBookingsBySlot error:', error);
    return sendError(res, 'Failed to fetch slot bookings.', 500);
  }
};

// DELETE /api/bookings/:id  (cancel)
const cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id).populate('slot');
    if (!booking) return sendError(res, 'Booking not found.', 404);

    // Only the owner or admin can cancel
    if (
      booking.user.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return sendError(res, 'Not authorized to cancel this booking.', 403);
    }

    if (booking.status === 'cancelled') {
      return sendError(res, 'Booking is already cancelled.', 400);
    }

    booking.status = 'cancelled';
    await booking.save();
    await Slot.findByIdAndUpdate(booking.slot._id, { $inc: { bookedCount: -1 } });

    return sendSuccess(res, { booking }, 'Booking cancelled.');
  } catch (error) {
    console.error('cancelBooking error:', error);
    return sendError(res, 'Failed to cancel booking.', 500);
  }
};

// PATCH /api/bookings/:id/cancel  (alias)
const cancelBookingPatch = cancelBooking;

module.exports = { createBooking, getMyBookings, getBookingsBySlot, cancelBooking, cancelBookingPatch };
