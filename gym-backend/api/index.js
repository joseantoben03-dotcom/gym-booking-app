// api/index.js — Vercel serverless entry point
// Vercel automatically serves anything in /api folder
require('dotenv').config();
const app = require('../src/app');

module.exports = app;
