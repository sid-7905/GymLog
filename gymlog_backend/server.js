const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

// Load environment variables
dotenv.config();

// Connect to MongoDB
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health Check Route
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'online',
    message: 'GymLog Backend API is running',
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'GymLog Backend is healthy',
  });
});

// API Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/routines', require('./routes/routineRoutes'));
app.use('/api/workouts', require('./routes/workoutRoutes'));
app.use('/api/bodyweight', require('./routes/bodyWeightRoutes'));
app.use('/api/body-weight', require('./routes/bodyWeightRoutes'));
app.use('/api/feed', require('./routes/feedRoutes'));

// 404 Route Handler
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Resource not found: ${req.method} ${req.originalUrl}`,
  });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err.stack || err);
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'Internal Server Error',
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
});

const PORT = process.env.PORT || 5000;

const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`GymLog Server running on http://0.0.0.0:${PORT} (Network: http://192.168.0.101:${PORT})`);
});

module.exports = app;
