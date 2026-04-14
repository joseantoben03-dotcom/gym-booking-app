const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { sendSuccess, sendError } = require('../utils/response');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

// ─── Helper: build user response ─────────────────────────────────────────────
const userPayload = (user) => ({
  id: user._id,
  name: user.name,
  email: user.email,
  role: user.role,
});

// POST /api/auth/register  (member self-registration)
const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !name.trim()) return sendError(res, 'Name is required.', 400);
    if (!email || !email.trim()) return sendError(res, 'Email is required.', 400);
    if (!password) return sendError(res, 'Password is required.', 400);
    if (password.length < 6) return sendError(res, 'Password must be at least 6 characters.', 400);

    const existing = await User.findOne({ email: email.toLowerCase().trim() });
    if (existing) return sendError(res, 'This email is already registered.', 409);

    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password,
      role: 'member', // always member via public registration
    });

    const token = generateToken(user._id);
    return sendSuccess(res, { token, user: userPayload(user) }, 'Registration successful.', 201);
  } catch (error) {
    console.error('Register error:', error);
    if (error.code === 11000) return sendError(res, 'This email is already registered.', 409);
    if (error.name === 'ValidationError') {
      const msg = Object.values(error.errors)[0]?.message || 'Validation failed.';
      return sendError(res, msg, 400);
    }
    return sendError(res, 'Registration failed. Please try again.', 500);
  }
};

// POST /api/auth/register-admin  (admin self-registration, requires setup key)
const registerAdmin = async (req, res) => {
  try {
    const { name, email, password, setupKey } = req.body;

    // Validate setup key — must match ADMIN_SETUP_KEY in .env
    const validSetupKey = process.env.ADMIN_SETUP_KEY || 'gymbook-setup-2024';
    if (!setupKey || setupKey !== validSetupKey) {
      return sendError(res, 'Invalid setup key. Contact the system administrator.', 403);
    }

    if (!name || !name.trim()) return sendError(res, 'Name is required.', 400);
    if (!email || !email.trim()) return sendError(res, 'Email is required.', 400);
    if (!password) return sendError(res, 'Password is required.', 400);
    if (password.length < 6) return sendError(res, 'Password must be at least 6 characters.', 400);

    const existing = await User.findOne({ email: email.toLowerCase().trim() });
    if (existing) {
      // If user exists but is a member, upgrade to admin
      if (existing.role === 'member') {
        existing.role = 'admin';
        await existing.save();
        const token = generateToken(existing._id);
        return sendSuccess(res, { token, user: userPayload(existing) }, 'Account upgraded to admin.', 200);
      }
      return sendError(res, 'This email is already registered as an admin.', 409);
    }

    const user = await User.create({
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password,
      role: 'admin',
    });

    const token = generateToken(user._id);
    return sendSuccess(res, { token, user: userPayload(user) }, 'Admin account created successfully.', 201);
  } catch (error) {
    console.error('Register admin error:', error);
    if (error.code === 11000) return sendError(res, 'This email is already registered.', 409);
    if (error.name === 'ValidationError') {
      const msg = Object.values(error.errors)[0]?.message || 'Validation failed.';
      return sendError(res, msg, 400);
    }
    return sendError(res, 'Admin registration failed. Please try again.', 500);
  }
};

// POST /api/auth/login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !email.trim()) return sendError(res, 'Email is required.', 400);
    if (!password) return sendError(res, 'Password is required.', 400);

    const user = await User.findOne({ email: email.toLowerCase().trim() }).select('+password');
    if (!user) return sendError(res, 'Invalid email or password.', 401);

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return sendError(res, 'Invalid email or password.', 401);

    const token = generateToken(user._id);
    return sendSuccess(res, { token, user: userPayload(user) }, 'Login successful.');
  } catch (error) {
    console.error('Login error:', error);
    return sendError(res, 'Login failed. Please try again.', 500);
  }
};

// GET /api/auth/me
const getMe = async (req, res) => {
  try {
    return sendSuccess(res, { user: req.user }, 'User fetched.');
  } catch (error) {
    return sendError(res, 'Failed to fetch user.', 500);
  }
};

module.exports = { register, registerAdmin, login, getMe };
