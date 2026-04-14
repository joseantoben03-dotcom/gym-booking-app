const Slot = require('../models/Slot');
const Booking = require('../models/Booking');
const { sendSuccess, sendError } = require('../utils/response');

// Helper: normalize date to start of day UTC
const normalizeDate = (dateStr) => {
  const d = new Date(dateStr);
  d.setUTCHours(0, 0, 0, 0);
  return d;
};

// GET /api/slots
const getSlots = async (req, res) => {
  try {
    const { date, upcoming, hideFull } = req.query;
    const filter = {};

    if (date) {
      const start = normalizeDate(date);
      const end = new Date(start);
      end.setUTCHours(23, 59, 59, 999);
      filter.date = { $gte: start, $lte: end };
    } else if (upcoming === 'true') {
      const today = normalizeDate(new Date());
      filter.date = { $gte: today };
    }

    let slots = await Slot.find(filter).sort({ date: 1, startTime: 1 });

    if (hideFull === 'true') {
      slots = slots.filter((s) => s.bookedCount < s.capacity);
    }

    return sendSuccess(res, { slots }, 'Slots fetched.');
  } catch (error) {
    console.error('getSlots error:', error);
    return sendError(res, 'Failed to fetch slots.', 500);
  }
};

// GET /api/slots/:id
const getSlotById = async (req, res) => {
  try {
    const slot = await Slot.findById(req.params.id);
    if (!slot) return sendError(res, 'Slot not found.', 404);
    return sendSuccess(res, { slot }, 'Slot fetched.');
  } catch (error) {
    return sendError(res, 'Failed to fetch slot.', 500);
  }
};

// POST /api/slots  (admin)
const createSlot = async (req, res) => {
  try {
    const { title, description, date, startTime, endTime, capacity } = req.body;

    if (!date || !startTime || !endTime || !capacity) {
      return sendError(res, 'date, startTime, endTime, and capacity are required.', 400);
    }

    const normalizedDate = normalizeDate(date);

    // Check for overlapping slot on same date/startTime
    const existing = await Slot.findOne({
      date: normalizedDate,
      startTime,
    });
    if (existing) {
      return sendError(res, 'A slot already exists at this date and start time.', 409);
    }

    const slot = await Slot.create({
      title,
      description,
      date: normalizedDate,
      startTime,
      endTime,
      capacity,
    });

    return sendSuccess(res, { slot }, 'Slot created.', 201);
  } catch (error) {
    console.error('createSlot error:', error);
    return sendError(res, 'Failed to create slot.', 500);
  }
};

// PUT /api/slots/:id  (admin)
const updateSlot = async (req, res) => {
  try {
    const { title, description, date, startTime, endTime, capacity } = req.body;
    const update = {};

    if (title !== undefined) update.title = title;
    if (description !== undefined) update.description = description;
    if (date) update.date = normalizeDate(date);
    if (startTime) update.startTime = startTime;
    if (endTime) update.endTime = endTime;
    if (capacity) update.capacity = capacity;

    const slot = await Slot.findByIdAndUpdate(req.params.id, update, {
      new: true,
      runValidators: true,
    });

    if (!slot) return sendError(res, 'Slot not found.', 404);
    return sendSuccess(res, { slot }, 'Slot updated.');
  } catch (error) {
    console.error('updateSlot error:', error);
    return sendError(res, 'Failed to update slot.', 500);
  }
};

// DELETE /api/slots/:id  (admin)
const deleteSlot = async (req, res) => {
  try {
    const slot = await Slot.findById(req.params.id);
    if (!slot) return sendError(res, 'Slot not found.', 404);

    // Cancel all bookings for this slot
    await Booking.updateMany({ slot: slot._id }, { status: 'cancelled' });
    await slot.deleteOne();

    return sendSuccess(res, {}, 'Slot deleted and related bookings cancelled.');
  } catch (error) {
    console.error('deleteSlot error:', error);
    return sendError(res, 'Failed to delete slot.', 500);
  }
};

module.exports = { getSlots, getSlotById, createSlot, updateSlot, deleteSlot };
