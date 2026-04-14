const mongoose = require('mongoose');

// Cache the connection across serverless function calls (Vercel cold starts).
// Without this, every request would open a new connection and exhaust the pool.
let cached = global._mongooseConnection;

if (!cached) {
  cached = global._mongooseConnection = { conn: null, promise: null };
}

const connectDB = async () => {
  // Already connected — reuse
  if (cached.conn) {
    return cached.conn;
  }

  // Connection in progress — wait for it
  if (!cached.promise) {
    cached.promise = mongoose
      .connect(process.env.MONGO_URI, {
        serverSelectionTimeoutMS: 10000,
        socketTimeoutMS: 45000,
      })
      .then((conn) => {
        console.log(`MongoDB Connected: ${conn.connection.host}`);
        return conn;
      })
      .catch((err) => {
        cached.promise = null; // reset so next call retries
        console.error(`MongoDB connection error: ${err.message}`);
        throw err;
      });
  }

  cached.conn = await cached.promise;
  return cached.conn;
};

module.exports = connectDB;
