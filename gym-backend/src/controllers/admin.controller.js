const User = require('../models/User');
const Booking = require('../models/Booking');
const { sendSuccess, sendError } = require('../utils/response');

// GET /api/admin/stats
const getStats = async (req, res) => {
  try {
    const totalUsers    = await User.countDocuments({ role: 'member' });
    const totalAdmins   = await User.countDocuments({ role: 'admin' });
    const totalBookings = await Booking.countDocuments({ status: 'booked' });

    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const bookingsPerDay = await Booking.aggregate([
      { $match: { status: 'booked', createdAt: { $gte: sevenDaysAgo } } },
      { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } },
    ]);

    return sendSuccess(res, { totalUsers, totalAdmins, totalBookings, bookingsPerDay }, 'Stats fetched.');
  } catch (error) {
    console.error('getStats error:', error);
    return sendError(res, 'Failed to fetch stats.', 500);
  }
};

// GET /api/admin/users  — all members
const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ role: 'member' }).select('-password').sort({ createdAt: -1 });
    return sendSuccess(res, { users }, 'Users fetched.');
  } catch (error) {
    return sendError(res, 'Failed to fetch users.', 500);
  }
};

// GET /api/admin/admins  — all admins
const getAllAdmins = async (req, res) => {
  try {
    const admins = await User.find({ role: 'admin' }).select('-password').sort({ createdAt: -1 });
    return sendSuccess(res, { admins }, 'Admins fetched.');
  } catch (error) {
    return sendError(res, 'Failed to fetch admins.', 500);
  }
};

// POST /api/admin/admins  — add a new admin (only existing admin can do this)
const addAdmin = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !name.trim()) return sendError(res, 'Name is required.', 400);
    if (!email || !email.trim()) return sendError(res, 'Email is required.', 400);
    if (!password) return sendError(res, 'Password is required.', 400);
    if (password.length < 6) return sendError(res, 'Password must be at least 6 characters.', 400);

    const existing = await User.findOne({ email: email.toLowerCase().trim() });

    if (existing) {
      // If already an admin — just return info
      if (existing.role === 'admin') {
        return sendError(res, 'This email is already registered as an admin.', 409);
      }
      // If a member — upgrade to admin
      existing.role = 'admin';
      await existing.save();
      return sendSuccess(
        res,
        { user: { id: existing._id, name: existing.name, email: existing.email, role: existing.role } },
        `${existing.name} has been upgraded to admin.`,
        200
      );
    }

    // Create brand new admin
    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password,
      role: 'admin',
    });

    return sendSuccess(
      res,
      { user: { id: user._id, name: user.name, email: user.email, role: user.role } },
      `Admin account created for ${user.name}.`,
      201
    );
  } catch (error) {
    console.error('addAdmin error:', error);
    if (error.code === 11000) return sendError(res, 'This email is already registered.', 409);
    if (error.name === 'ValidationError') {
      const msg = Object.values(error.errors)[0]?.message || 'Validation failed.';
      return sendError(res, msg, 400);
    }
    return sendError(res, 'Failed to create admin.', 500);
  }
};

// DELETE /api/admin/admins/:id  — remove admin role (demote to member)
const removeAdmin = async (req, res) => {
  try {
    const { id } = req.params;

    // Prevent self-demotion
    if (id === req.user._id.toString()) {
      return sendError(res, 'You cannot remove your own admin privileges.', 400);
    }

    const user = await User.findById(id);
    if (!user) return sendError(res, 'User not found.', 404);
    if (user.role !== 'admin') return sendError(res, 'User is not an admin.', 400);

    user.role = 'member';
    await user.save();

    return sendSuccess(res, {}, `${user.name} has been demoted to member.`);
  } catch (error) {
    console.error('removeAdmin error:', error);
    return sendError(res, 'Failed to remove admin.', 500);
  }
};

module.exports = { getStats, getAllUsers, getAllAdmins, addAdmin, removeAdmin };
