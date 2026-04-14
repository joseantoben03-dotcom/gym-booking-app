require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const authRoutes    = require('./routes/auth.routes');
const slotRoutes    = require('./routes/slot.routes');
const bookingRoutes = require('./routes/booking.routes');
const adminRoutes   = require('./routes/admin.routes');

const app = express();

// ─── MongoDB ───────────────────────────────────────────────────────────────────
connectDB();

// ─── CORS ─────────────────────────────────────────────────────────────────────
const corsOptions = {
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false,
};
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));

// ─── Body parsing ─────────────────────────────────────────────────────────────
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use('/api/auth',     authRoutes);
app.use('/api/slots',    slotRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/admin',    adminRoutes);

// ─── Health check ─────────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Gym Booking API is running' });
});

// ─── 404 ──────────────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
  });
});

// ─── Global error handler ─────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

// ─── Local dev server ─────────────────────────────────────────────────────────
// Vercel is serverless — it does NOT use app.listen().
// This block only runs when you do `npm run dev` locally.
if (require.main === module) {
  const PORT = process.env.PORT || 5000;
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Server running on http://localhost:${PORT}`);
    console.log(`   Health: http://localhost:${PORT}/api/health`);
  });
}

// ─── IMPORTANT: export app for Vercel serverless ──────────────────────────────
module.exports = app;
