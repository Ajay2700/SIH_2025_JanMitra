const config = require('../config/env');

// Custom error class
class AppError extends Error {
  constructor(message, statusCode, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    Error.captureStackTrace(this, this.constructor);
  }
}

// Error handling middleware
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  console.error('Error:', err);

  // Supabase errors
  if (err.code) {
    switch (err.code) {
      case '23505': // Unique constraint violation
        error = new AppError('Duplicate entry. Resource already exists.', 409);
        break;
      case '23503': // Foreign key constraint violation
        error = new AppError('Referenced resource does not exist.', 400);
        break;
      case '23502': // Not null constraint violation
        error = new AppError('Required field is missing.', 400);
        break;
      case '42P01': // Table does not exist
        error = new AppError('Database table not found.', 500);
        break;
      case 'PGRST116': // Row not found
        error = new AppError('Resource not found.', 404);
        break;
      default:
        error = new AppError('Database operation failed.', 500);
    }
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    error = new AppError('Invalid token.', 401);
  }
  if (err.name === 'TokenExpiredError') {
    error = new AppError('Token expired.', 401);
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message).join(', ');
    error = new AppError(message, 400);
  }

  // Multer errors (file upload)
  if (err.code === 'LIMIT_FILE_SIZE') {
    error = new AppError('File too large.', 400);
  }
  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    error = new AppError('Unexpected field.', 400);
  }

  // Default error
  if (!error.statusCode) {
    error = new AppError('Internal server error.', 500);
  }

  // Send error response
  const response = {
    success: false,
    message: error.message
  };

  // Include stack trace in development
  if (config.nodeEnv === 'development') {
    response.stack = err.stack;
  }

  res.status(error.statusCode || 500).json(response);
};

// 404 handler
const notFound = (req, res, next) => {
  const error = new AppError(`Route ${req.originalUrl} not found.`, 404);
  next(error);
};

// Async error wrapper
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = {
  AppError,
  errorHandler,
  notFound,
  asyncHandler
};
